#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Webwml::TransCheck - retrieve information embedded in translated documents

=head1 SYNOPSIS

 use Webwml::TransCheck;
 my $tc = Webwml::TransCheck->new("foo.wml");
 my $rev = $tc->revision();

=head1 DESCRIPTION

This module search for C<#use wml::debian::translation-check> line in files
and retrieve related information.

=head1 METHODS

=over 4

=cut

package Webwml::TransCheck;
use Carp;
use strict;

=item new

This is the constructor.  It has an argument, which is the filename to parse.

   my $tc = Webwml::TransCheck->new("foo.wml");

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {
                KEYS => {
                        maintainer      => 'MAINT',
                        translation     => 'REV',
                        original        => 'ORIG',
                        maxdelta        => 'MAX',
                        mindelta        => 'MIN',
                        },
                DATA => {},
        };
        bless ($self, $class);
        croak "Missing argument in \`new' method" unless @_;
        $self->_read(@_);
        return $self;
}

sub _read {
        my $self = shift;
        my $file = shift
                or croak "Missing argument in Webwml::TransCheck->new";
        my ($line, $key, $value);
        open(FILE, "< $file") or return;
        while ($line = <FILE>) {
                if ($line =~ m/^\#use\s+wml::debian::translation-check/) {
                        #   There may be continuation lines
                        while ($line =~ s/\\\s*\n$//s) {
                                $line .= <FILE> || last;
                        }
                        while (($key, $value) = each %{$self->{KEYS}}) {
                                $line =~ m/$key="([^"]+)"/ and
                                        $self->{DATA}->{$value} = $1;
                        }
                        last;
                }
        }
        close(FILE);
}

=item maintainer

Return the maintainer name of the translated document.

   my $maint = $tc->maintainer();

=cut

sub maintainer {
        my $self = shift;
        return defined($self->{DATA}->{MAINT}) ? $self->{DATA}->{MAINT} : undef;
}

=item revision

Return the revision number of the original document.

   my $rev = $tc->revision();

=cut

sub revision {
        my $self = shift;
        return defined($self->{DATA}->{REV}) ? $self->{DATA}->{REV} : undef;
}

=item original

Return the original document language, if not English.

   my $orig = $tc->original();

=cut

sub original {
        my $self = shift;
        return defined($self->{DATA}->{ORIG}) ? $self->{DATA}->{ORIG} : undef;
}

=item maxdelta

   my $maxdelta = $tc->maxdelta();

=cut

sub maxdelta {
        my $self = shift;
        return defined($self->{DATA}->{MAX}) ? $self->{DATA}->{MAX} : undef;
}

=item mindelta

   my $mindelta = $tc->mindelta();

=cut

sub mindelta {
        my $self = shift;
        return defined($self->{DATA}->{MIN}) ? $self->{DATA}->{MIN} : undef;
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

