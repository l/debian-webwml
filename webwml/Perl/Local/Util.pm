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

use strict;
use warnings;

BEGIN {
	use base qw( Exporter );

	our $VERSION = sprintf "%d", q$Revision$ =~ /(\d+)/g;
	our @EXPORT_OK = qw( uniq );
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

42;

__END__
