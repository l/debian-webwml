#!/usr/bin/perl

=head1 NAME

Local::Utils - generic utils for use in webwml script

=head1 SYNOPSIS

 use Local::Utils ':all';

=head1 DESCRIPTION

This module contains a few helper routines that are useful in the webwml
scripts, and for which we don't want to add dependencies on external modules.

=head1 METHODS

=over 4

=cut

package Local::Util;

use 5.008;
use Carp;

use strict;
use warnings;

BEGIN {
	use base qw( Exporter );
	our $VERSION = "1.2.3";
	our @EXPORT_OK = qw( uniq read_file );
	our %EXPORT_TAGS = ( 'all' => [@EXPORT_OK] );
}


=item uniq

Returns a new list by stripping duplicate values in LIST. The order of elements
in the returned list is the same as in LIST. In scalar context, returns the
number of unique elements in LIST.

Example use:

    my @x = uniq 1, 1, 2, 2, 3, 5, 3, 4; # returns 1 2 3 5 4
    my $x = uniq 1, 1, 2, 2, 3, 5, 3, 4; # returns 5


This code was copied literally from List::MoreUtils.

Copyright (C) 2004-2006 by Tassilo von Parseval <tassilo.von.parseval@rwth-aachen.de
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.8.4 or, at your option,
any later version of Perl 5 you may have available.

=cut
sub uniq (@) 
{
	my %h;
	map { $h{$_}++ == 0 ? $_ : () } @_;
}

=item read_file

Slurps an entire file and returns the contents of the file as a scalar, or
undef if an error occured (actual error will be in $!).

The optional second argument can be used to specify the charset the file is in.

This function is mean as a light-weight replacement for File::Slurp.

=cut
sub read_file
{
	my $filename = shift 
		or croak("Local::Util::read_file: no file specified");
	my $encoding = shift;

	my $input = '<';
	if ( $encoding )
	{
		$input .= ":encoding($encoding)";
	}

	# slurp mode
	local $/ = undef;

	# read the file
	open( my $fd, $input, $filename ) or return;
	my $text = <$fd>;
	close( $fd );

	return $text;
}


42;

__END__
