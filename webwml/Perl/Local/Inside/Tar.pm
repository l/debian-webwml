#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Local::Inside::Tar - examine tarfile contents

=head1 DESCRIPTION

This package is the base class for all C<Local::Inside> classes.
Unlike most tar processors, this one does perform all operations in
memory, but retrieves only specified files, so it should not consume too
much memory if you are specific enough.

=head1 METHODS

=over 4

=cut

package Local::Inside::Tar;
use strict;
use Carp;
use Symbol;
use File::Path;
use File::Basename;
use Local::Inside::Diff;

=item new

This is the constructor. It has a mandatory argument, which is either a
tarfile, or a string containing command for a pipe creation.

 my $tar1 = Local::Inside::Tar->new("foo-0.1.tar");
 my $tar2 = Local::Inside::Tar->new("foo-0.1.tar.gz");
 my $tar3 = Local::Inside::Tar->new("gzip -dc foo-0.1.tar.gz |");

The last two are strictly equivalent, since this package does not know
how to handle compressed files, they are gunzipped on the fly if they
have a F<.gz> extension.

Options can be passed in the form of a hash array; these options are
currently supported:

=over 6

=item C<debug>

Set to 1 if you want to see lots of garbage on screen

=item C<parse_dft>

This option sets default argument if C<parse> method is called without
argument.

=item C<maxmem>

Sets maximum amount of memory used to store file content.  Scanning is
aborted and an error is reported when this amount is exceeded.

=back

Example:

 my $tar2 = Local::Inside::Tar->new("foo-0.1.tar.gz",
        debug => 1,
        parse_dft => 32,
 );

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $file  = shift ||
                Carp::croak "Missing argument in ".__PACKAGE__."::new";

        my $fh = Symbol::gensym();
        my $self = {
                name    => $file,
                handle  => $fh,
                dir     => "",
                wrongdir=> 0,
                cached  => 0,
                offset  => 0,
                memory  => 0,
                maxcache        => 0,
                patch   => undef,
                data    => {
                        list_files      => [],
                        list_dirs       => [],
                        files           => {},
                        dirs            => {},
                },
                parse_last      => 0,
                #   these options can be overriden by caller
                _parse_dft      => 0,
                _debug  => 0,
                _maxmem => 0,
        };

        if ($#_ >= 0) {
                my %opts = @_;
                while (my ($key, $val) = each %opts) {
                        $self->{"_".$key} = $val;
                }
        }
        bless ($self, $class);
        return $self;
}

sub _debug {
        my $self = shift;
        return unless $self->{_debug};
        print STDERR __PACKAGE__." Debug: ".$_[0] . "\n";
}

sub _io_open {
        my $self = shift;
        if ($self->{name} =~ m/\.gz$/) {
                open ($self->{handle}, "gzip -dc $self->{name} |")
                        or Carp::croak "Unable to open $self->{name}";
        } elsif ($self->{name} =~ m/\.bz2$/) {
                open ($self->{handle}, "bzip2 -dc $self->{name} |")
                        or Carp::croak "Unable to open $self->{name}";
        } elsif ($self->{name} =~ m/\|/) {
                open ($self->{handle}, $self->{name})
                        or Carp::croak "Unable to execute \`$self->{name}'";
        } elsif (-f $self->{name}) {
                open ($self->{handle}, $self->{name})
                        or Carp::croak "Unable to open \`$self->{name}'";
        } else {
                Carp::croak "Do not know what to do with this argument: $self->{name}";
        }

        $self->{offset} = 0;
}

sub _io_close {
        my $self = shift;

        close($self->{handle});
        $self->{offset} = -1;
}

sub _io_read {
        my $self = shift;
        my $nbytes = shift;
        my $getData = shift || 0;

        return '' if $nbytes <= 0;

        my $text = '';
        my ($nread, $buffer);

        $self->_debug("Reading $nbytes bytes at offset $self->{offset}");

        $self->{offset} += $nbytes;
        while ($nbytes > 4096) {
                $nbytes -= read($self->{handle}, $buffer, $nbytes) ||
                        Carp::croak "End of file found when reading \`$self->{name}'";
                $text .= $buffer if $getData;
        }
        if ($nbytes > 0) {
                read($self->{handle}, $buffer, $nbytes) ||
                        Carp::croak "End of file found when reading \`$self->{name}'";
                $text .= $buffer if $getData;
        }
        return $text;
}

=item parse

This is where all processing is done.  It has an optional argument, which is
either a subroutine reference or a number.

For each file found in archive, this routine will be called with filename
given as attribute, and it returns either a number or a string beginning
with a colon.  All other return values are discarded and treated as 0.
The former gives the number of bytes of file content stored in internal
cache (see below the C<file_content> method), and the latter specifies a
path where content is stored.

Example:

 my $match = sub {
      my $file = shift;
      if ($file =~ m|po/.*\.po$|) {
           $file =~ s|/|_|g;
           return ':po-files/'.$file;
      }
      $file =~ m|\.c$| && return 32;
      return 0;
 };
 $tar1->parse($match);

This example writes on disk all files matching the Perl regular
expression C<po/.*\.po$>, and reads in memory all C source files, but
truncate them to 32 chars.  When file content is retrieved via the
C<file_content> method, it will be immediately available if less than 32
chars are requested.  Otherwise, archive will be parsed again to
retrieve the desired amount of chars of the specified file.

When C<parse> method's argument is a number, this is a shortcut to
truncate and store all files to the desired length.  There are two
special cases: if this argument is missing or is null, then archive is
scanned and structure is stored, but file contents are not retrieved.
If this argument is -1,  then files contents are kept in memory.  Of
course, this option should not be used on large tarballs.

When C<parse> method is called the first time, an internal representation of
tarfile is stored to let further parsing faster, and tarfile will be read only
if result has not been cached by previous calls.

=cut

sub parse {
        my $self  = shift;
        my $matchfiles;

        $self->_debug("Begin parsing");
        if ($#_ >= 0) {
                $matchfiles = shift;
        } else {
                $matchfiles = $self->{_parse_dft} || sub { return 0; };
        }

        #   Transform argument if necessary
        if (ref($matchfiles) ne 'CODE') {
                Carp::confess "Invalid argument of ".__PACKAGE__."::parse"
                        unless $matchfiles =~ m/^-?\d+$/;
                eval "\$matchfiles = sub { return $matchfiles; }";
        }
        $self->{parse_last} = $matchfiles;

        if ($self->{cached}) {
                $self->_parse_cache($matchfiles);
        } else {
                #   This tarball was never read before
                $self->_debug("First time parsing");
                $self->_io_open();
                1 while ($self->_read_firsttime($matchfiles));
                $self->_io_close();
        }
        $self->{cached} = 1;
        $self->_debug("End parsing");
        $self->_debug("Number of chars in cache: ".$self->get_max_memory());
}

sub _read_firsttime {
        my $self  = shift;
        my $matchfiles = shift;

        my ($block, $data, $maxlength, $numbytes, $offset);

        my ($name, $type, $size) = $self->_read_header(0) or return 0;
        my $path = '';

        $offset = $self->{offset};
        if ($type eq "file") {
                $maxlength = &$matchfiles($name) || 0;
                if ($maxlength =~ s/^://) {
                        $path = $maxlength;
                        $maxlength = -1;
                } elsif ($maxlength !~ m/^-?[0-9]+$/) {
                        $maxlength = 0;
                }
                $maxlength = $size if $maxlength == -1;
                $numbytes  = ($size > $maxlength ? $maxlength : $size);
                $self->{memory} += $numbytes if $path eq '';
                #  Abort if memory needed is too large
                if ($self->{_maxmem} > 0) {
                        Carp::croak "Not enough memory: maximum set to $self->{_maxmem}, and at least $self->{memory} needed"
                                if $self->{memory} > $self->{_maxmem};
                }

                $data = $self->_io_read($numbytes, 1);

                # Always read in full 512 byte blocks
                $block = ($size & 0x01ff) ? ($size & ~0x01ff) + 512 : $size;
                $self->_io_read($block - $numbytes) if $numbytes < $block;

                # Store information
                push(@{$self->{data}->{list_files}}, $name);
                if ($path ne '') {
                        my $dir = File::Basename::dirname($path);
                        File::Path::mkpath($dir, 0, 0755);
                        open(DISK, "> ".$path)
                                || warn "Unable to write to $path\n";
                        print DISK $data;
                        close(DISK);
                        $data = '';
                }
                $self->{data}->{files}->{$name} = {
                        offset => $offset,
                        size   => $size,
                        data   => $data,
                        read   => $numbytes,
                        path   => $path,
                        dchars => 0,
                        patch  => 0,
                };
                $self->_debug("   Type   : file");
                $self->_debug("   Size   : $size");
                $self->_debug("   Offset : $offset");
                $self->_debug("   Path   : $path") if $path ne '';
        } elsif ($type eq "dir") {
                $name =~ s|/$||;
                push (@{$self->{data}->{list_dirs}}, $name);
                $self->{data}->{dirs}->{$name} = 1;
                $self->_debug("   Type   : directory");
                $self->_debug("   Offset : $offset");
        } else {
                $self->_debug("   Type   : unknown ($type)");
        }

        #  This entry is not the last one
        return 1;
}

sub _read_header {
        my $self  = shift;
        my $cont  = shift;   #  1 when reading long filenames, 0 otherwise

        #  Read header
        my $head = $self->_io_read(512, 1) ||
                Carp::croak "End of file found when reading \`$self->{name}'";
        if ($head eq "\0" x 512) {
                $self->_debug("EOF detected");
                return;
        }

        #  Unpack it
        my ($name, $mode, $uid, $gid, $size, $mtime, $chksum, $type,
            $linkname, $magic, $version, $uname, $gname, $devmajor,
            $devminor, $prefix) =
            unpack ("A100 A8 A8 A8 A12 A12 A8 A1 A100 A6 A2 A32 A32 A8 A8 A155 x12", $head);

        if ($name eq '') {
                $self->_debug("Missing filename, assuming it is EOF");
                return;
        }

        $size   = oct $size;
        $chksum = oct $chksum;

        #   Calculate checksum
        substr ($head, 148, 8) = "        ";
        Carp::carp "$name: checksum error.\n"
                if unpack ("%16C*", $head) != $chksum;

        #   Handle long filename (>100 chars)
        if ($prefix ne "") {
                #  POSIX way
                $name = $prefix."/".$name;
        } elsif ($name eq "././\@LongLink" && $type eq "L") {
                #  GNU way
                my $realname = $self->_io_read($size, 1) ||
                        Carp::croak "End of file found when reading \`$self->{name}'";
                $self->_io_read(($size & ~0x01ff) + 512 - $size)
                        if ($size & 0x01ff);
                ($name, $type, $size) = $self->_read_header(1) or return 0;
                $name = $realname;
        }

        $self->_debug("Found $name");

        $type = "file" if $type eq "";
        if ($type =~ m/^\d/) {
                if ($type == 0) {
                        $type = "file";
                } elsif ($type == 5) {
                        $type = "dir";
                } else {
                        $type = "unknozn";
                }
        }
        $name .= '/' if $type eq 'dir' && $name !~ m#/#;

        if ($name =~ s|^([^/]+)/||) {
                if ($self->{wrongdir} == 0) {
                        if ($self->{dir} ne "" && $self->{dir} ne $1) {
                                $name = $1 . '/' . $name;
                                $self->{wrongdir} = 1;
                                warn "Warning: unable to determine top-level directory in $self->{name}, assuming there is no root directory\n";
                                #   Adapt already scanned files and
                                #   directories
                                $self->_prepend_dir($self->{dir});
                                $self->{dir} = '';
                        } else {
                                $self->{dir} = $1;
                        }
                } else {
                        $name = $1 . '/' . $name;
                }
        } else {
                if ($self->{wrongdir} == 0) {
                        $self->{wrongdir} = 1;
                        warn "Warning: unable to determine top-level directory in $self->{name}, assuming there is no root directory\n";
                        $self->_prepend_dir($self->{dir}) if $self->{dir} ne '';
                }
        }

        #   Fix broken archives
        $type = "dir"  if $name =~ m|/$| and $type eq "file" and !$cont;

        return ($name, $type, $size);
}

sub _prepend_dir {
        my $self  = shift;
        my $dir = shift;

        foreach (keys %{$self->{data}->{files}}) {
                $self->{data}->{files}->{$dir.'/'.$_} =
                        $self->{data}->{files}->{$_};
                delete $self->{data}->{files}->{$_};
        }
        foreach (keys %{$self->{data}->{dirs}}) {
                $self->{data}->{dirs}->{$dir.'/'.$_} =
                        $self->{data}->{dirs}->{$_};
                delete $self->{data}->{dirs}->{$_};
        }
        my @list_files = ();
        foreach (@{$self->{data}->{list_files}}) {
                push(@list_files, $dir.'/'.$_);
        }
        $self->{data}->{list_files} = [@list_files];
        my @list_dirs = ();
        foreach (@{$self->{data}->{list_dirs}}) {
                push(@list_dirs, $dir.'/'.$_);
        }
        $self->{data}->{list_dirs} = [@list_dirs];
}

sub _parse_cache {
        my $self  = shift;
        my $matchfiles = shift;

        my ($name, $offset, $numbytes, $maxlength, $block, $path);
        my ($filesize, $fileoffset, $text);

        $self->_debug("Checking in memory representation");

        $self->_io_open();
        foreach $name (@{$self->{data}->{list_files}}) {
                $maxlength = &$matchfiles($name) || 0;
                $path = '';
                if ($maxlength =~ s/^://) {
                        $path = $maxlength;
                        $fileoffset = $self->{data}->{files}->{$name}->{offset};
                        $filesize   = $self->{data}->{files}->{$name}->{size};
                        $maxlength  = $filesize;
                        unless (-r $path) {
                                $maxlength  = $filesize;
                                if ($self->{data}->{files}->{$name}->{patch}
                                    || $self->{data}->{files}->{$name}->{read} < $maxlength) {
                                        $self->_io_read($fileoffset - $self->{offset});
                                        $text = $self->_io_read($maxlength, 1);
                                        $self->{offset} = $fileoffset + $maxlength;
                                } else {
                                        $text = $self->{data}->{files}->{$name}->{data};
                                }
                                $self->{data}->{files}->{$name}->{patch} = 1
                                        if defined $self->{patch}
                                        && $self->{patch}->{data}->{files}->{$name};
                                $text = $self->{patch}->apply_patch($name, $text)
                                        if $self->{data}->{files}->{$name}->{patch};
                                my $dir = File::Basename::dirname($path);
                                File::Path::mkpath($dir, 0, 0755);
                                open(DISK, "> ".$path)
                                        || warn "Unable to write to $path\n";
                                print DISK $text;
                                close(DISK);
                                $self->{data}->{files}->{$name}->{data} = '';
                                $self->{data}->{files}->{$name}->{read} = 0;
                        }
                        next;
                } elsif ($maxlength !~ m/^-?[0-9]+$/) {
                        $maxlength = 0;
                }
                next unless $maxlength == -1 || $maxlength =~ m/^[0-9]+$/;

                #  Look if result is cached
                $fileoffset = $self->{data}->{files}->{$name}->{offset};
                $filesize   = $self->{data}->{files}->{$name}->{size};
                $maxlength  = $filesize
                        if $maxlength == -1 || $maxlength > $filesize;

                #   File content is in cache
                next if $self->{data}->{files}->{$name}->{read} >= $maxlength;

                #   New file added by patch
                next if $self->{data}->{files}->{$name}->{offset} == -1;

                $numbytes  = ($filesize > $maxlength ? $maxlength : $filesize);

                #  Abort if memory needed is too large
                $self->{memory} += $numbytes - $self->{data}->{files}->{$name}->{read}
                        if $path eq '';
                if ($self->{_maxmem} > 0) {
                        Carp::croak "Not enough memory: maximum set to $self->{_maxmem}, and at least $self->{memory} needed"
                                if $self->{memory} > $self->{_maxmem};
                }

                $self->_debug("Found $name at offset $fileoffset");

                $self->_io_read($fileoffset - $self->{offset});
                $self->{offset} = $fileoffset;
                $self->{data}->{files}->{$name}->{data} =
                                $self->_io_read($numbytes, $maxlength);
                $self->{data}->{files}->{$name}->{read}  = $numbytes;
                $self->{data}->{files}->{$name}->{patch} = 1
                        if defined $self->{patch}
                           && $self->{patch}->{data}->{files}->{$name};
        }
        $self->_io_close();
}

=item list_dirs

Return the list of directories.

 my @listdirs  = $tar1->list_dirs();

=cut

sub list_dirs {
        my $self = shift;
        $self->parse()
                unless $self->{cached};
        return @{$self->{data}->{list_dirs}};
}

=item list_files

Return the list of files.

 my @listfiles = $tar1->list_files();

=cut

sub list_files {
        my $self = shift;
        $self->parse()
                unless $self->{cached};
        return @{$self->{data}->{list_files}};
}

=item file_exists

Return 1 if argument is a file found in package, 0 otherwise.

 if ($tar1->file_exists("debian/template")) {
      print "Hey, this package uses Debconf!\n";
 }

=cut

sub file_exists {
        my $self = shift;
        $self->parse()
                unless $self->{cached};
        return defined($self->{data}->{files}->{$_[0]}) ? 1 : 0;
}

=item file_matches

Return the list of files matching argument, which is a Perl regular
expression.

 my @c = $self->file_matches("^c");

=cut

sub file_matches {
        my $self = shift;
        my $expr = shift;
        my @found = ();
        my $match = sub { my $file = shift; $file =~ m/$expr/; };
        foreach ($self->list_files()) {
                push (@found, $_) if &$match($_);
        }
        return @found;
}

=item file_content

Return the content of a file if it resides in archive.

 my $control = $self->file_content("debian/control");

An optional second argument is the number of bytes to read.

=cut

sub file_content {
        my $self = shift;
        my $file = shift;
        my $length = shift || -1;

        $self->_debug("Retrieve content of file $file");
        unless ($self->file_exists($file)) {
                Carp::carp "File \`$file' not found in archive";
                return;
        }

        return $self->_file_content_patch($file, $length)
                if defined $self->{patch}
                   && $self->{patch}->{data}->{files}->{$file};

        if ($self->{data}->{files}->{$file}->{path} ne '') {
                local $/ = undef;
                open(DISK, "< ".$self->{data}->{files}->{$file}->{path})
                        || warn "Unable to read from ".
                                $self->{data}->{files}->{$file}->{path}."\n";
                my $text = <DISK>;
                close(DISK);
                return $text;
        }

        $length = $self->{data}->{files}->{$file}->{size}
                if $length == -1
                   || $length > $self->{data}->{files}->{$file}->{size};

        return substr($self->{data}->{files}->{$file}->{data}, 0, $length)
                if $self->{data}->{files}->{$file}->{read} >= $length;

        $self->_io_open() unless $self->{offset} >= 0 && $self->{data}->{files}->{$file}->{offset} >= $self->{offset};
        $self->_io_read($self->{data}->{files}->{$file}->{offset} - $self->{offset});
        $self->_debug("Read $length bytes of $file");
        $self->{data}->{files}->{$file}->{data} = $self->_io_read($length, 1);
        return $self->{data}->{files}->{$file}->{data};
}

sub _file_content_patch {
        my $self = shift;
        my $file = shift;
        my $length = shift || -1;
        my ($text, $strlen);

        $self->_debug("Retrieve content of file $file with patches applied");
        unless ($self->file_exists($file)) {
                Carp::carp "File \`$file' not found in archive";
                return;
        }

        if ($self->{data}->{files}->{$file}->{path} ne '') {
                local $/ = undef;
                open(DISK, "< ".$self->{data}->{files}->{$file}->{path})
                        || warn "Unable to read from ".
                                $self->{data}->{files}->{$file}->{path}."\n";
                $text = <DISK>;
                close(DISK);
                #   We read text, but do not know yet if it has to be
                #   patched
        }

        if ($self->{data}->{files}->{$file}->{patch}) {
                #   File already patched in cache

                #   New file not in tarball
                return $self->{patch}->apply_patch($file, $text)
                        if $self->{data}->{files}->{$file}->{offset} == -1;

                $length = $self->{data}->{files}->{$file}->{size} +
                          $self->{data}->{files}->{$file}->{dchars}
                        if $length == -1
                           || $length > $self->{data}->{files}->{$file}->{size} +
                                        $self->{data}->{files}->{$file}->{dchars};
                return $text if $self->{data}->{files}->{$file}->{path} ne '';
                return substr($self->{data}->{files}->{$file}->{data}, 0, $length)
                        if $self->{data}->{files}->{$file}->{read} >= $length;
        }

        if ($self->{data}->{files}->{$file}->{path} ne '') {
                #   Original file has been stored on disk, it must
                #   be patched and overwritten
                $text = $self->{patch}->apply_patch($file, $text);
                open(DISK, "> ".$self->{data}->{files}->{$file}->{path})
                        || warn "Unable to write to ".
                                $self->{data}->{files}->{$file}->{path}."\n";
                print DISK $text;
                close(DISK);
                $self->{data}->{files}->{$file}->{patch} = 1;
                return $text;
        }

        #   Read the whole source file
        $strlen = $self->{data}->{files}->{$file}->{size};
        $self->_io_open() unless $self->{offset} >= 0 && $self->{data}->{files}->{$file}->{offset} >= $self->{offset};
        $self->_io_read($self->{data}->{files}->{$file}->{offset} - $self->{offset});
        $self->_debug("Read $strlen bytes of $file");
        $text = $self->_io_read($strlen, 1);

        $text = $self->{patch}->apply_patch($file, $text);
        substr($text, $length) = ''
                if length($text) > $length && $length != -1;
        $self->{data}->{files}->{$file}->{data}  = $text;
        $self->{data}->{files}->{$file}->{read}  = length($text);
        $self->{data}->{files}->{$file}->{patch} = 1;
        return $text;
}

=item bind_patch

Bind current tarball to a patch, so that all files are retrieved
as if patch was applied after extracting files from tarball.

 $self->bind_patch("foo-0.1.diff.gz");
 my $text = $self->file_content("debian/control");

This routine accepts the same optional arguments as
C<Local::Inside::Diff-E<gt>new>.

=cut

sub bind_patch {
        my $self = shift;
        my $file = shift;

        Carp::croak "Another patch is already bound"
                if defined $self->{patch};

        $self->parse(0)
                unless $self->{cached};

        $self->_debug("Apply patch file $file");

        my %opts = ();
        %opts = @_ if $#_ >= 0;

        $opts{parse_dft} ||= $self->{parse_last};
        $self->{patch} = Local::Inside::Diff->new($file, %opts);
        $self->{patch}->parse();

        foreach ($self->{patch}->list_files()) {
                $self->{data}->{files}->{$_}->{dchars} = $self->{patch}->{data}->{files}->{$_}->{dchars};
        }
        foreach ($self->{patch}->list_new_files()) {
                $self->_debug("New file added to archive: $_");
                my $data = $self->{patch}->{data}->{files}->{$_}->{data};
                $data =~ s/^\+//mg;
                $self->{data}->{files}->{$_} = {
                        offset => -1,
                        size   => 0,
                        data   => $data,
                        read   => length($data),
                        path   => '',
                        dchars => length($data),
                        patch  => 1,
                };
                push (@{$self->{data}->{list_files}}, $_);
        }
}

=item get_memory

Get number of characters currently stored in cache.

 print "Memory used: ".$tar1->get_memory()."\n";

=cut

sub get_memory {
        return $_[0]->{memory};
}

=item get_max_memory

Get maximum number of characters stored in this object during its timelife.

 print "Max memory used: ".$tar1->get_max_memory()."\n";

=cut

sub get_max_memory {
        my $self = shift;
        $self->{maxcache} = $self->{memory} if $self->{maxcache} < $self->{memory};
        return $self->{maxcache};
}

=item free

Free memory by removing all previous remembered data.

 $tar1->free();

=cut

sub free {
        my $self = shift;
        return unless $self->{cached};

        $self->{maxcache} = $self->{memory}
                if $self->{maxcache} < $self->{memory};
        $self->_debug("Free memory");
        foreach (@{$self->{data}->{list_files}}) {
                $self->{data}->{files}->{$_}->{read} = 0;
                $self->{data}->{files}->{$_}->{data} = '';
        }
        $self->{memory} = 0;
}

=back

=head1 AUTHOR

Copyright (C) 2001  Denis Barbier <barbier@debian.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut

1;

