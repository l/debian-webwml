#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Local::Inside::Diff - examine and apply patch

=head1 DESCRIPTION

This package reads a patch file in memory, and apply hunks on demand.

=head1 METHODS

=over 4

=cut

package Local::Inside::Diff;
use strict;
use Carp;
use Symbol;

=item new

This is the constructor. It has a mandatory argument, which is either a
tarfile, or a string containing command for a pipe creation.

 my $diff1 = Local::Inside::Diff->new("foo-0.1.diff");
 my $diff2 = Local::Inside::Diff->new("foo-0.1.diff.gz");
 my $diff3 = Local::Inside::Diff->new("gzip -dc foo-0.1.diff.gz |");

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

=item Path specifications

A patch file typically contains line like these ones:

  --- foo-0.4.orig/Makefile
  +++ foo-0.4/Makefile

  --- foo-0.4/Makefile
  +++ foo-0.4.new/Makefile

  --- foo-0.4/Makefile.orig
  +++ foo-0.4/Makefile

So a general representation for all such cases is

  --- <odp>foo-0.4<ods>/Makefile<ofs>
  +++ <ndp>foo-0.4<nds>/Makefile<nfs>

Six other arguments of the C<new> method can be specified, namely
C<olddirprefix>, C<olddirsuffix>, C<oldfilesuffix>, C<newdirprefix>,
C<newdirsuffix> and C<newfilesuffix>, to treat all cases above.

=back

Example:

 my $diff2 = Local::Inside::Diff->new("foo-0.1.diff.gz",
        olddirsuffix => '.orig',
        parse_dft    => -1,
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
                cached  => 0,
                offset  => 0,
                memory  => 0,
                maxcache        => 0,
                curr_line       => '',
                data    => {
                        list_files      => [],
                        list_new_files  => [],
                        files           => {},
                        new_files       => {},
                },
                #   these options can be overriden by caller
                _parse_dft      => 0,
                _debug  => 0,
                _maxmem => 0,
                _olddirprefix   => '',
                _olddirsuffix   => '',
                _oldfilesuffix  => '',
                _newdirprefix   => '',
                _newdirsuffix   => '',
                _newfilesuffix  => '',
        };

        if ($#_ >= 0) {
                my %opts = @_;
                while (my ($key, $val) = each %opts) {
                        $self->{"_".$key} = $val;
                }
        }
        #   Special characters in these variables must be escaped
        $self->{_olddirprefix}  = quotemeta($self->{_olddirprefix});
        $self->{_olddirsuffix}  = quotemeta($self->{_olddirsuffix});
        $self->{_oldfilesuffix} = quotemeta($self->{_oldfilesuffix});
        $self->{_newdirprefix}  = quotemeta($self->{_newdirprefix});
        $self->{_newdirsuffix}  = quotemeta($self->{_newdirsuffix});
        $self->{_newfilesuffix} = quotemeta($self->{_newfilesuffix});

        bless ($self, $class);
        return $self;
}

sub _debug {
        my $self = shift;
        print STDERR __PACKAGE__." Debug: ".$_[0] . "\n"
                if $self->{_debug};
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
        close($_[0]->{handle});
}

sub _io_read_lines {
        my $self = shift;
        my $nlines = shift;
        my $getData = shift || 0;

        $self->_debug("Reading $nlines lines");
        return '' if $nlines <= 0;

        my $fh = $self->{handle};
        my $text = '';
        while ($nlines) {
                $text .= $self->{curr_line} if $getData;
                $self->{offset} += length($self->{curr_line});
                $self->{curr_line} = <$fh>;
                last if !defined($self->{curr_line});
                $nlines --;
        }
        return $text;
}

sub _io_read {
        my $self = shift;
        my $nbytes = shift;
        my $getData = shift || 0;

        return '' if $nbytes <= 0;

        my $text = '';
        my $fh = $self->{handle};
        my ($nread, $buffer);

        $self->_debug("Reading $nbytes bytes at offset $self->{offset}");

        $self->{offset} += $nbytes;
        while ($nbytes > 4096) {
                $nbytes -= read($fh, $buffer, $nbytes) ||
                        Carp::croak "End of file found when reading \`$self->{name}'";
                $text .= $buffer if $getData;
        }
        if ($nbytes > 0) {
                read($fh, $buffer, $nbytes) ||
                        Carp::croak "End of file found when reading \`$self->{name}'";
                $text .= $buffer if $getData;
        }
        return $text;
}

=item parse

Parse patch and store informations in memory.  See the
C<Local::Inside::Tar> documentation for a detailed description of this
function, but note that in most cases, -1 is the argument to pass to it.

=cut

sub parse {
        my $self  = shift;
        my $matchfiles;
        my $fh = $self->{handle};

        $self->_debug("Begin parsing");
        if ($#_ >= 0) {
                $matchfiles = shift;
        } else {
                $matchfiles = $self->{_parse_dft} || sub { return 0; };
        }

        #   Transform argument when necessary
        if (ref($matchfiles) ne 'CODE') {
                Carp::confess "Invalid argument of ".__PACKAGE__."::parse"
                        unless $matchfiles =~ m/^-?\d+$/;
                eval "\$matchfiles = sub { return $matchfiles; }";
        }

        $self->{curr_line} = '';
        if ($self->{cached}) {
                $self->_parse_cache($matchfiles);
        } else {
                #   This patch was never read before
                $self->_debug("First time parsing");
                $self->_io_open();
                #   Initialize $self->{curr_line}
                $self->{curr_line} = <$fh>;
                1 while ($self->_read_firsttime($matchfiles));
                $self->_io_close();
        }
        $self->{cached} = 1;
        $self->_debug("End parsing");
}

sub _read_firsttime {
        my $self  = shift;
        my $matchfiles = shift;

        return 0 if !defined($self->{curr_line});
        my $name = $self->_read_header() or return 0;
        my $maxlength = &$matchfiles($name);
        $self->_read_patches($name, $maxlength);

        #  This entry is not the last one
        return 1;
}

sub _read_header {
        my $self = shift;
        my ($dir, $file);

        #  Read header
        Carp::croak "Malformed diff: line does not begin with ---:\n$self->{curr_line}\n"
                unless $self->{curr_line} =~ m|^--- ([^/]+)$self->{_olddirsuffix}/(\S+)$self->{_oldfilesuffix}|;
        ($dir, $file) = ($1, $2);
        my $fh = $self->{handle};
        $self->{offset} += length($self->{curr_line});
        $self->{curr_line} = <$fh>;
        Carp::croak "Malformed diff: found\n$self->{curr_line}when expecting\n+++ $self->{_newdirprefix}$dir$self->{_newdirsuffix}/$file$self->{_newfilesuffix}"
                unless $self->{curr_line} =~ m#^\+\+\+ $self->{_newdirprefix}\Q$dir\E$self->{_newdirsuffix}/\Q$file\E$self->{_newfilesuffix}(\b|$)#;
        $self->{offset} += length($self->{curr_line});
        $self->{curr_line} = <$fh>;

        return $file;
}

sub _read_patches {
        my $self = shift;
        my $name = shift;
        my $nbytes = shift;

        my $text = '';
        my @patch_list = ();
        my ($offset, $nlines, $chars, $dchars, $entry);

        $nlines = 0;
        $dchars = 0;
        $offset = $self->{offset};
        while (1) {
                ($entry, $chars) = $self->_read_chunk();
                last unless ref($entry) eq 'HASH';
                $text   .= $entry->{data} if $nbytes != 0;
                $nlines += $entry->{nlines};
                $dchars += $chars;
                push (@patch_list, $entry);
                last if !defined($self->{curr_line})
                        or $self->{curr_line} =~ m/^--- /;
        }

        if ($nbytes > 0 && $nbytes < length($text)) {
                substr($text, $nbytes) = '';
        }

        # Store information
        push(@{$self->{data}->{list_files}}, $name)
                unless $self->{cached};
        $self->{data}->{files}->{$name} = {
                offset => $offset,
                size   => $self->{offset} - $offset,
                data   => $text,
                read   => length($text),
                dchars => $dchars,
                patch_list      => \@patch_list,
        };
        if ($self->{data}->{files}->{$name}->{patch_list}->[0]->{oldfirstline} eq 0
           && !$self->{cached}) {
                push(@{$self->{data}->{list_new_files}}, $name);
                $self->{data}->{new_files}->{$name} = 1;
        }
        $self->_debug("   Name   : ".$name);
        $self->_debug("   Type   : file");
        $self->_debug("   Size   : ".($self->{offset} - $offset));
        $self->_debug("   Read   : ".length($text));
        $self->_debug("   Offset : $offset");
}

sub _read_chunk {
        my $self = shift;

        my ($nread, $buffer, $size, $line, %entry);
        my ($nlines, $nlinesold, $nlinesnew, $nchars);

        $line = $self->{curr_line};
        chomp $line;
        $self->_debug("Chunk found: ".$line);

        if ($line =~ m/^\@\@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? \@\@/) {
                %entry = (
                        oldfirstline    => $1,
                        oldnblines      => (defined($2) ? $2 : 1),
                        newfirstline    => $3,
                        newnblines      => (defined($4) ? $4 : 1),
                );
        } else {
                Carp::croak "Malformed patch, first line is:\n$self->{curr_line}"
        }
        my $text = '';
        $nlines    = 0;
        $nlinesold = 0;
        $nlinesnew = 0;
        $nchars    = 0;
        while ($nlinesold != $entry{oldnblines}
            || $nlinesnew != $entry{newnblines}) {
                $self->_io_read_lines(1, 1);
                if (defined($self->{curr_line})
                    && $self->{curr_line} eq "\\ No newline at end of file\n") {
                        $self->{curr_line} = '';
                        next;
                }
                last if !defined($self->{curr_line})
                        or $self->{curr_line} =~ m/^\@\@ /;
                $text .= $self->{curr_line};
                if ($self->{curr_line} =~ m/^-/) {
                        $nlinesold ++;
                        $nchars -= length($self->{curr_line}) - 1;
                } elsif ($self->{curr_line} =~ m/^\+/) {
                        $nlinesnew ++;
                        $nchars += length($self->{curr_line}) - 1;
                } else {
                        $nlinesold ++;
                        $nlinesnew ++;
                }
                $nlines ++;
        };
        $self->_io_read_lines(1, 1)
                if defined($self->{curr_line})
                   && $self->{curr_line} !~ m/^\@\@ /;
        $self->_io_read_lines(1, 1)
                if defined($self->{curr_line})
                   && $self->{curr_line} eq "\\ No newline at end of file\n";

        $entry{data}   = $text;
        $entry{nlines} = $nlines;
        return (\%entry, $nchars);
}

sub _parse_cache {
        my $self  = shift;
        my $matchfiles = shift;

        my ($name, $offset, $numbytes, $maxlength, $block);
        my ($filesize, $fileoffset);

        $self->_debug("Checking in memory representation");

        $self->{offset} = 0;
        foreach $name (@{$self->{data}->{list_files}}) {
                $maxlength = &$matchfiles($name);
                next
                        if $maxlength == 0;

                #  Look if result is cached
                $fileoffset = $self->{data}->{files}->{$name}->{offset};
                $filesize   = $self->{data}->{files}->{$name}->{size};
                $maxlength  = $filesize
                        if $maxlength == -1 || $maxlength > $filesize;
                next
                        if $self->{data}->{files}->{$name}->{read} >= $maxlength;

                $numbytes  = ($filesize > $maxlength ? $maxlength : $filesize);

                #  Abort if memory needed is too large
                $self->{memory} += $numbytes - $self->{data}->{files}->{$name}->{read};
                if ($self->{_maxmem} > 0) {
                        Carp::croak "Not enough memory: maximum set to $self->{_maxmem}, and at least $self->{memory} needed"
                                if $self->{memory} > $self->{_maxmem};
                }

                #  Open filehandle if it has not been done before
                $self->_io_open() unless $self->{offset} > 0;

                $self->_debug("Found $name at offset $fileoffset");

                $self->_io_read($fileoffset - $self->{offset});
                $self->{offset} = $fileoffset;

                #  Read next line to initialize $self->{curr_line}
                $self->{curr_line} = '';
                $self->_io_read_lines(1);

                $self->_read_patches($name, $numbytes);
                $self->{offset} += length($self->{curr_line})
                        if defined($self->{curr_line});
        }
        $self->_io_close() if $self->{offset} > 0;
}

=item list_files

Return the list of files patched.

 my @listfiles = $diff1->list_files();

=cut

sub list_files {
        my $self = shift;
        $self->parse()
                unless $self->{cached};
        return @{$self->{data}->{list_files}};
}

=item list_new_files

Return the list of files which are added by this patch.

 my @newfiles = $diff1->list_new_files();

=cut

sub list_new_files {
        my $self = shift;
        $self->parse()
                unless $self->{cached};
        return @{$self->{data}->{list_new_files}};
}

=item is_file_patched

Return 1 if argument is a file found in patch and 0 otherwise.

 if ($diff1->is_file_patched("configure.in")) {
      print "File configure.in found in patch\n";
 }

=cut

sub is_file_patched {
        my $self = shift;
        $self->parse()
                unless $self->{cached};
        return defined($self->{data}->{files}->{$_[0]}) ? 1 : 0;
}

=item patch_file_matches

Return the list of files being patched and matching argument, which is a
Perl regular expression.

 my @c = $self->patch_file_matches("^c");

=cut

sub patch_file_matches {
        my $self = shift;
        my $expr = shift;
        my @found = ();
        my $match = sub { my $file = shift; $file =~ m/$expr/; };
        foreach ($self->list_files()) {
                push (@found, $_) if &$match($_);
        }
        return @found;
}

=item apply_patch

Given a text, returns patched version against given file.

 $patched = $diff1->apply_patch("src/main.c", $text);

=cut

sub apply_patch {
        my $self = shift;
        my $name = shift;
        my $text = shift || '';

        $self->_debug("Applying patch to file $name");
        my $match = sub { my $file = shift; $file eq $name && return -1; };
        $self->parse($match)
                unless $self->{cached}
                    || $self->{data}->{files}->{read} == $self->{data}->{files}->{size};
        if (!defined($self->{data}->{files}->{$name})) {
                Carp::carp "File $name does not appear in patch";
                return $text;
        }
        if ($self->{data}->{files}->{$name}->{patch_list}->[0]->{oldfirstline} == 0) {
                #   Special case, this is a new file
                Carp::carp "In ".__PACKAGE__."::apply_patch, patch new file with non-empty text"
                        if $text ne '';
                $text = $self->{data}->{files}->{$name}->{patch_list}->[0]->{data};
                $text =~ s/^[^\n]+\n//s;
                $text =~ s/^\+//mg;
                return $text;
        } else {
                #   3rd argument is to prevent stripping of trailing
                #   newlines
                my @out = split(/\n/, $text, -1);
                pop(@out) if $text =~ m/\n$/s;
                foreach my $p (@{$self->{data}->{files}->{$name}->{patch_list}}) {
                        my @patch = split(/\n/, $p->{data}, -1);
                        pop(@patch) if $p->{data} =~ m/\n$/s;
                        my @new = ();
                        my $begin = $p->{newfirstline} - 1;
                        my $length = $p->{oldnblines};
                        my $old = $begin - 1;
                        foreach (@patch) {
                                if (s/^ //) {
                                        $old ++;
                                        Carp::carp __PACKAGE__."::apply_patch invoked on non-matching text on file $name near line $old\n"
                                                unless defined($out[$old]) && $_ eq $out[$old];
                                        push @new, $_;
                                } elsif (s/^-//) {
                                        $old ++;
                                        Carp::carp __PACKAGE__."::apply_patch invoked on non-matching text on file $name near line $old\n"
                                                unless defined($out[$old]) && $_ eq $out[$old];
                                } elsif (s/^\+//) {
                                        push @new, $_;
                                } else {
                                        Carp::carp __PACKAGE__."::apply_patch invoked on non-matching text on file $name near line $old\n";
                                }
                        }
                        splice @out, $begin, $length, @new;
                }
                $text = join("\n", @out)."\n";
        }
        return $text;
}

=item get_memory

Get number of characters currently stored in cache

 print "Memory used: ".$diff1->get_memory()."\n";

=cut

sub get_memory {
        return $_[0]->{memory};
}

=item get_max_memory

Get maximum number of characters stored in this object during its timelife

 print "Max memory used: ".$diff1->get_max_memory()."\n";

=cut

sub get_max_memory {
        my $self = shift;
        $self->{maxcache} = $self->{memory} if $self->{maxcache} < $self->{memory};
        return $self->{maxcache};
}

=item free

Free memory by removing all previous remembered data.

 $diff1->free();

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

