#!/usr/bin/perl

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
use File::Spec::Functions;
use Local::VCS;

use strict;
use warnings;

=item new

This is the constructor.  The argument specifies where to find the
top-level webwml directory.  If the method is called without arguments, to
top-level directory is automatically determined.

   my $ti = Webwml::TransIgnore->new("foo/bar");

=cut

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $dir   = shift;

	# init the object
	my $self  =
	{
		GLOBAL => [],
		LOCAL  => [],
		FOUND  => 0,
	};
	bless ($self, $class);

	# determine the root dir
	my $VCS = Local::VCS->new();
	my $root = shift || $VCS->get_topdir('.');

	# Read global .transignore file
	$self->_read($root);

	# remove the root path from the front of the files
	for (0 .. $#{$self->{LOCAL}})
	{
		${$self->{LOCAL}}[$_] =~ s{^$root/}{}; 
	}
	$self->{GLOBAL} = $self->{LOCAL};

	# reinitialize $self->{LOCAL}
	$self->{LOCAL}  = [];
	# and read $dir/.transignore
	$self->{FOUND} = $self->_read($dir);

	return $self;
}

sub _read
{
	my $self = shift;
	my $dir  = shift;

	my $status = 0;
	my $file = catfile( $dir, '.transignore' );

	my $line;
	splice( @{$self->{LOCAL}}, 0 );

	open( my $fd, '<', $file) or return 0;
	while ( my $line = <$fd> )
	{
		next  if  $line =~ m/^#/;
		next  if  $line =~ m/^\s*$/;
		chomp $line;

		push( @{$self->{LOCAL}}, catfile($dir, $line) );
	}
	close($fd);

	return 1;
}

=item found

Return 1 if .transignore file was found, 0 otherwise.

=cut

sub found
{
	my $self = shift;
	return $self->{FOUND};
}

=item local

Return the list of files found in F<.transignore> file.

   my @ignore = $ti->local();

=cut

sub local
{
	my $self = shift;
	return $self->{LOCAL};
}

=item global

Return the list of files defined 

   my @ignore = $ti->global();

=cut

sub global
{
	my $self = shift;
	return $self->{GLOBAL};
}

=item is_local

Return 1 if argument is listed in .transignore, 0 otherwise

   my $rc = $ti->is_local("/foo/bar.wml");

=cut

sub is_local
{
	my $self  = shift;
	my $entry = shift;

	foreach my $file ( @{$self->{LOCAL}} )
	{
		return 1  if  $file eq $entry;
	}

	return 0;
}

=item is_global

Return 1 if argument has been defined, 0 otherwise.

   my $rc = $ti->is_global("/foo/bar.wml");

=cut

sub is_global
{
	my $self  = shift;
	my $entry = shift;

	foreach my $file ( @{$self->{GLOBAL}} )
	{
		return 1  if  $file eq $entry;
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
