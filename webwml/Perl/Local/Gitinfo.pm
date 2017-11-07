#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Local::Cvsinfo - retrieve CVS related informations from a checked out copy

=head1 SYNOPSIS

 use Local::Cvsinfo;
 my $cvs = Local::Cvsinfo->new();
 $cvs->readinfo('.', recursive => 1, verbose => 1 );
 my $top = $cvs->topdir();
 my $rev = $cvs->revision('foo/bar');

=head1 DESCRIPTION

This module retrieves CVS related informations from a checked out
working directory, by scanning the F<CVS/*> files found within.

=head1 METHODS

=over 4

=cut

package Local::Cvsinfo;
use Carp;
use strict;

=item new

This is the constructor.

   my $cvs = Local::Cvsinfo->new();

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {
                TOP      => '',
                IGNORE   => [],
                DIRS     => [],
                FILES    => {},
                GLOBAL_OPTIONS => {},
                SKIP     => sub {},
        };
        bless ($self, $class);
        return $self;
}

=item options

Without arguments, return a reference to a hash array containing the
list of options.
If there is an argument, set some global options for the timelife of
this object.  Argument is a hash array, currently C<recursive>,
C<verbose>, C<skipdir> and C<matchfile> keys are recognized.  Processing
is recursive (resp. verbose) if C<recursive> (resp. C<verbose>) is set
to a non-null value.  The C<skipdir> and C<matchfile> values must be
arrays containing Perl regular expressions, the former specifies
directory to skip in recursive mode (C<CVS> directories are always
skipped), and the latter specifies which files do match (default: all).

   $cvs->options(recursive => 1, matchfile => [ '\.c$' ]);
   while (($key, $val) = each %{$cvs->options()}) {
       print $key . ":" . $val . "\n";
   }

=cut

sub options {
        my $self = shift;
        my %arg  = @_;
        if (!@_) {
                return $self->{GLOBAL_OPTIONS};
        }
        $self->{GLOBAL_OPTIONS} = \%arg;
        $self->{GLOBAL_OPTIONS}->{matchfile} ||= [ '' ];
        $self->{OPTIONS} = $self->{GLOBAL_OPTIONS};
        $self->_fix_skip();
}

sub _verbose {
        my $self = shift;
        return unless $self->{OPTIONS}->{verbose};
        print STDERR "Verbose: ".$_[0] . "\n";
}

=item readinfo

This is where processing is done.  First argument is a directory name,
the F<CVS/Entries> and F<CVS/Repository> files will be searched in that
directory and informations on entries defined within are internally
stored, unless this entry has been discarded by an C<skipdir> attribute.
Optional remaining arguments are a hash array overriding global options.

   $cvs->readinfo("src");
   $cvs->readinfo("src", recursive => 1);

=cut

sub readinfo {
        my $self    = shift;
        my $dir     = shift;
        my %options = @_;
        my @heredir = ();
        my ($entry, $oldoptions, $line);

        $dir =~ s|/+$||;
        -r $dir."/CVS/Entries" or do {
                carp "Unable to read file $dir/CVS/Entries ...  skipped";
                return;
        };
        -r $dir."/CVS/Repository" or do {
                carp "Unable to read file $dir/CVS/Repository ...  skipped";
                return;
        };

        #   Set options
        $oldoptions = $self->{OPTIONS};
        $self->{OPTIONS} = $self->{GLOBAL_OPTIONS};
        if (%options) {
                foreach (keys %options) {
                        $self->{OPTIONS}->{$_} = $options{$_};
                }
        }
        $self->_fix_skip()
                unless ref($oldoptions->{skipdir}) eq "ARRAY"
                and ref($oldoptions->{matchfile}) eq "ARRAY"
                and ref($self->{OPTIONS}->{skipdir}) eq "ARRAY"
                and ref($self->{OPTIONS}->{matchfile}) eq "ARRAY"
                and join("\n", $oldoptions->{skipdir}) eq join("\n", $self->{OPTIONS}->{skipdir})
                and join("\n", $oldoptions->{matchfile}) eq join("\n", $self->{OPTIONS}->{matchfile});

        #   Read CVS/Repository and CVS/Root to determine top-level
        #   directory
        open(REP, "< $dir/CVS/Repository")
                or croak "Unable to read file $dir/CVS/Repository\n";
        $self->_verbose("Reading $dir/CVS/Repository");
        $line = <REP>;
        close(REP);
        if ($line =~ m#^/#) {
                #   Absolute path, we must read CVS/Root
                open(ROOT, "< $dir/CVS/Root")
                        or croak "Unable to read file $dir/CVS/Root\n";
                $self->_verbose("Reading $dir/CVS/Root");
                my $root = <ROOT>;
                close(ROOT);
                chomp $root;
                $root =~ s/^.*://;
                $line =~ s#^$root/##
                        or croak "Unable to determine toplevel CVS directory\n";
        }
        chomp $line;
        $line =~ s{[^/]+}{..}g;
        $line =~ s{^\.\.}{.};
        $line =~ s{^\./}{};
        $self->{TOP} = $line;

        #   Read CVS/Entries
        open(ENTRIES, "< $dir/CVS/Entries")
                or croak "Unable to read file $dir/CVS/Entries\n";
        $self->_verbose("Reading $dir/CVS/Entries");
        my @entries = <ENTRIES>;
        close(ENTRIES);
        #   Entries are sorted so that DIRS is also sorted.
        foreach (sort @entries) {
                chomp;
                if (m|^D/([^/]+)/|) {
                        $entry = $dir."/".$1;
                        next if $self->_skippable($entry) or ! -d $entry;
                        push (@{$self->{DIRS}}, $entry);
                        push (@heredir, $entry);
                        $self->_verbose("Found directory: $entry");
                } elsif (m|^/([^/]+)/([^/]+)/([^/]+)/([^/]*)/(?:T[^/]+)?$|) {
                        $entry = $dir."/".$1;
                        next if $self->_skippable($entry) or ! -f $entry;
                        $self->{FILES}->{$entry} = {
                                REV     => $2,
                                DATE    => $3,
                                KEYWORD => $4,
                        };
                        $self->_verbose("Found file $entry, rev. $2, date $3");
                } elsif (m|^D$|) {
                        #  Hmmm, what is this entry for?
                } else {
                        carp "Unable to parse line:\n\t$_\n";
                }
        }
        return unless $self->{OPTIONS}->{recursive};
        foreach my $d (@heredir) {
                next if $self->_skippable($d);
                $self->readinfo($d, %options);
        }
}

#   Set $self->{SKIP} according to $self->{OPTIONS}->{skipdir} and
#   $self->{OPTIONS}->{matchfile}
sub _fix_skip {
        my $self = shift;
        if (ref($self->{OPTIONS}) eq "HASH") {
                my $sub = "\$_ = shift; if (-d \$_) { return 1 if m{^(.*/)?CVS\$};";
                ref($self->{OPTIONS}->{skipdir}) eq "ARRAY" and do {
                        foreach (@{$self->{OPTIONS}->{skipdir}}) {
                                $sub .= "return 1 if m{/$_\$};";
                        }
                };
                $sub .= "return 0; }";
                ref($self->{OPTIONS}->{matchfile}) eq "ARRAY" and do {
                        foreach (@{$self->{OPTIONS}->{matchfile}}) {
                                $sub .= "return 0 if m{$_};";
                        }
                };
                $sub .= "return 1";
                $self->{SKIP} = eval "sub {$sub}";
        } else {
                $self->{SKIP} = sub {};
        }
}

sub _skippable {
        my $self = shift;
        return 0 unless &{$self->{SKIP}}($_[0]);
        $self->_verbose("Skipping $_[0]");
        return 1;
}

=item reset

Clear all data set by previous call to C<readinfo>.

   $cvs->readinfo("src");
   $cvs->reset();
   $cvs->readinfo("doc");

=cut

sub reset {
        my $self = shift;
        $self->{DIRS}  = [];
        $self->{FILES} = {};
}

=item topdir

Return relative path of the top directory CVS checked out copy.
This path is the one when C<readinfo> was called.

   my $root = $cvs->topdir();

=cut

sub topdir {
        my $self = shift;
        return $self->{TOP};
}

=item removefile

Remove an entry from the file list.

   $cvs->removefile("src/main.c");

=cut

sub removefile {
        my $self = shift;
        delete $self->{FILES}->{$_[0]};
}

=item dirs

Return a reference to the list of directories contained in current
working directory.

   foreach (@{$cvs->dirs()}) {
        print "Found directory: $_\n";
   }

=cut

sub dirs {
        my $self = shift;
        return $self->{DIRS};
}

=item files

Return a reference to file list.

   foreach (@{$cvs->files()}) {
        print "Found file: $_\n";
   }

=cut

sub files {
        my $self = shift;
        return [keys %{$self->{FILES}}];
}

=item revision

First argument is a filename.  If there is no more argument, the CVS
revision of this file is returned, otherwise it is set to the 2nd
argument.

   my $rev = $cvs->revision("src/foo.c");

=cut

sub revision {
        my $self = shift;
        my $file = shift;
        return undef if !defined($self->{FILES}->{$file});
        $self->{FILES}->{$file}->{REV} = $_[0] if @_;
        return $self->{FILES}->{$file}->{REV};
}

=item date

First argument is a filename.  If there is no more argument, the latest
commit date of this file is returned (in a format similar to the
C<date> command output), otherwise it is set to the 2nd argument.

   my $date = $cvs->date("src/foo.c");

=cut

sub date {
        my $self = shift;
        my $file = shift;
        return undef if !defined($self->{FILES}->{$file});
        $self->{FILES}->{$file}->{DATE} = $_[0] if @_;
        return $self->{FILES}->{$file}->{DATE};
}

=item keyword

First argument is a filename.  If there is no more argument, the keyword
substitution method (see the B<-k> flag of the C<cvs> command) for this
file is returned, otherwise it is set to the 2nd argument.

   my $kflag = $cvs->keyword("src/foo.c");

=cut

sub keyword {
        my $self = shift;
        my $file = shift;
        return undef if !defined($self->{FILES}->{$file});
        $self->{FILES}->{$file}->{KEYWORD} = $_[0] if @_;
        return $self->{FILES}->{$file}->{KEYWORD};
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

