#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Local::Inside::DebSrc - extract contents from Debian source package

=head1 SYNOPSIS

 use Local::Inside::DebSrc;
 my $deb = Local::Inside::DebSrc->new("/path/to/foo_0.1-1.dsc");
 my @list = $deb->list_files();
 my $body = $deb->file_content("debian/control");

=head1 DESCRIPTION

This module extracts informations and files from a Debian source
package.  It is built upon the C<Local::Inside::Tar> module, see
its documentation for further details on available methods.

=head1 METHODS

=over 4

=cut

package Local::Inside::DebSrc;

use Local::Inside::Tar;
@ISA = ("Local::Inside::Tar");

use strict;
use Carp;

=item new

This is the constructor.

   my $deb = Local::Inside::DebSrc->new("/path/to/foo_0.1-1.dsc");

Basically, C<dsc> file is parsed to read tarball and patch file
names, then C<Local::Inside::Tar-E<gt>new> is called with tarball
filename being first argument.  When a patch file is found,
C<Local::Inside::Tar-E<gt>bind_patch> method is invoked.
Optional arguments with a C<patch_> prefix are passed along to the
latter (with the prefix removed), whereas other arguments are passed
along to the former.

   my $deb = Local::Inside::DebSrc->new("/path/to/foo_0.1-1.dsc",
        parse_dft => 0,
        patch_parse_dft => -1,
   );

is almost equivalent to

   my $deb = Local::Inside::Tar->new("/path/to/foo_0.1.orig.tar.gz",
        parse_dft => 0,
   );
   $deb->bind_patch( parse_dft => -1 );
   $deb->parse();

When tarball or patch file is required but does not exist, the C<new>
method returns C<undef> after printing a warning.

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $file = shift;

        my $dir  = $file;
        $dir =~ s|/+[^/]*$||;

        my $origtargz = '';
        my $diffgz = '';
        open(DSC, "< ".$file) or Carp::croak ("Unable to read $file");
        while (<DSC>) {
                last if m/^Files:/;
        }
        while (<DSC>) {
                chomp;
                last unless s/^ \S* \S* //;
                if (m/\.tar\.gz$/) {
                        $origtargz = $dir . '/' . $_;
                        unless (-f $origtargz) {
                                warn "$origtargz: No such file\n";
                                return undef;
                        }
                } elsif (m/\.diff\.gz$/) {
                        $diffgz = $dir . '/' . $_;
                        unless (-f $diffgz) {
                                warn "$diffgz No such file\n";
                                return undef;
                        }
                }
        }
        close(DSC);
        my $self = $class->SUPER::new("$origtargz", @_);
        bless ($self, $class);

        #   Apply patch if found
        my %patch_opts = ();
        if ($#_ >= 0) {
                my %opts = @_;
                foreach (keys %opts) {
                        next unless s/^patch_//;
                        $patch_opts{$_} = $opts{'patch_'.$_};
                }
        }
        $patch_opts{olddirsuffix} = '.orig'
                if !defined($patch_opts{olddirsuffix});
        $self->bind_patch($diffgz, %patch_opts) if $diffgz ne '';
        $self->parse();
        return $self;
}

=item get_tar_name

Returns the full qualified name of tarball

   my $tarfile = $deb->get_tar_name();

=cut

sub get_tar_name {
        my $self = shift;
        return $self->{name};
}

=item get_diff_name

Returns the full qualified name of the diff file, or empty string if it
does not exist.

   my $patchname = $deb->get_diff_name();

=cut

sub get_diff_name {
        my $self = shift;
        return (defined($self->{patch}) ? $self->{patch}->{name} : '');
}

=back

=head1 LIMITATIONS

It is a pain to retrieve content of Debian packages when in dbs format,
since C<debian/rules> must be called to apply patches on upstream tarball.
It does not make much sense to use an in-memory representation is such a
case, so this module will surely not try to ease parsing such packages.

=head1 AUTHOR

Copyright (C) 2001  Denis Barbier <barbier@debian.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut

1;

