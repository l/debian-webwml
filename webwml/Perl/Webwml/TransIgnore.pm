#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Webwml::TransIgnore - get list of files to ignore for translation

=head1 SYNOPSIS

 use Webwml::TransIgnore;
 my $ti = Webwml::TransIgnore->new("foo/bar");
 my @ignore = $ti->list();

=head1 DESCRIPTION

This module searches for F<.transignore> files in directories and returns
files listed within.  If a F<.transignore> file is found in top-level
directory, it contains files which must be ignored in all languages.

=head1 METHODS

=over 4

=cut

package Webwml::TransIgnore;
use Carp;
use strict;
use Local::Cvsinfo;

=item new

This is the constructor.  If called with an argument, it tells where to
find top-level webwml directory.  Otherwise it is automatically
determined by parsing F<CVS/Repository>.

   my $ti = Webwml::TransIgnore->new("foo/bar");

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $dir   = shift
                or croak "Missing argument in Webwml::TransIgnore->new";
        my $self  = {
                GLOBAL => [],
                LOCAL  => [],
                FOUND  => 0,
        };
        bless ($self, $class);
        my $root;
        if (@_) {
                $root = shift;
        } else {
                my $cvs = Local::Cvsinfo->new();
                $cvs->readinfo('.');
                $root = $cvs->topdir()
                        or croak "Unable to determine top-level directory";
        }
        #   Read global .transignore file
        $self->_read($root);
        for (0 .. $#{$self->{LOCAL}}) {
               ${$self->{LOCAL}}[$_] =~ s{^$root/}{}; 
        }
        $self->{GLOBAL} = $self->{LOCAL};
        #   reinitialize $self->{LOCAL}
        $self->{LOCAL}  = [];
        #   and read $dir/.transignore
        $self->{FOUND} = $self->_read($dir);
        return $self;
}

sub _read {
        my $self = shift;
        my $dir  = shift;
        $dir .= "/";
        my $status = 0;
        my $file = $dir . ".transignore";
        my $line;
        splice (@{$self->{LOCAL}}, 0);
        open(FILE, "< $file") or return 0;
        while (<FILE>) {
                next if m/^#/;
                next if m/^\s*$/;
                chomp;
                push (@{$self->{LOCAL}}, $dir.$_);
        }
        close(FILE);
        return 1;
}

=item found

Return 1 if .transignore file was found, 0 otherwise.

=cut

sub found {
        my $self = shift;
        return $self->{FOUND};
}

=item local

Return the list of files found in F<.transignore> file.

   my @ignore = $ti->local();

=cut

sub local {
        my $self = shift;
        return $self->{LOCAL};
}

=item global

Return the list of files defined 

   my @ignore = $ti->global();

=cut

sub global {
        my $self = shift;
        return $self->{GLOBAL};
}

=item is_local

Return 1 if argument is listed in .transignore, 0 otherwise

   my $rc = $ti->is_local("/foo/bar.wml");

=cut

sub is_local {
        my $self  = shift;
        my $entry = shift;
        foreach (@{$self->{LOCAL}}) {
                return 1 if $_ eq $entry;
        }
        return 0;
}

=item is_global

Return 1 if argument has been defined, 0 otherwise.

   my $rc = $ti->is_global("/foo/bar.wml");

=cut

sub is_global {
        my $self  = shift;
        my $entry = shift;
        foreach (@{$self->{GLOBAL}}) {
                return 1 if $_ eq $entry;
        }
        return 0;
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

