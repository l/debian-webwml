#
# Deb::Versions
# $Id$
#
# Copyright 2003, 2004 Frank Lichtenheld <frank@lichtenheld.de>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

=head1 NAME

Deb::Versions - compare Versions of Debian packages

=head1 SYNOPSIS

    use Deb::Versions

    my $res = version_cmp( "1:0.2.2-2woody1", "1:0.2.3-7" );
    
    my @sorted = version_sort( "1:0.2.2-2woody1", "1:0.2.3-7", "2:0.1.1" );

=head1 DESCRIPTION

This module allows you to compare version numbers like defined
in the Debian policy, section 5.6.11 (L<SEE ALSO>).

It provides two functions:

=over 4

=item *

version_cmp() gets two version strings as parameters and returns
-1, if the first is lower than the second, 0 if equal, 1 if greater.
You can use this function as first parameter for the sort() function.

=item *

version_sort() is just an usefull abbrevation for 

    sort { version_cmp( $b, $a ) } @_;

=back

=head1 EXPORTS

By default, Deb::Versions exports version_cmp() and version_sort().

=cut

package Deb::Versions;

use strict;
use Exporter;

our @ISA = qw( Exporter );
our @EXPORT = qw( version_cmp version_sort );

our $VERSION = v1.0.0;

sub version_cmp {
    my ( $ver1, $ver2 ) = @_;

    my ( $e1, $e2, $u1, $u2, $d1, $d2 );
    my $re = qr/^(?:(\d+):)?([\w.+:~-]+?)(?:-([\w+.~]+))?$/;
    if ( $ver1 =~ $re ) {
	( $e1, $u1, $d1 ) = ( $1, $2, $3 );
	$e1 ||= 0;
    } else {
	warn "This seems not to be a valid version number:"
	    . "<$ver1>\n";
	return -1;
    }
    if ( $ver2 =~ $re ) {
        ( $e2, $u2, $d2 ) = ( $1, $2, $3 );
	$e2 ||= 0;
    } else {
        warn "This seems not to be a valid version number:"
            . "<$ver2>\n";
        return 1;
    }

#    warn "D: <$e1><$u1><$d1> <=> <$e2><$u2><$d2>\n";

    my $res = ($e1 <=> $e2);
    return $res if $res;
    $res = _cmp_part ( $u1, $u2 );
    return $res if $res;
    $res = _cmp_part ( $d1, $d2 );
    return $res;
}

sub version_sort {
    return sort { version_cmp( $b, $a ) } @_;
}

sub _cmp_part {
    my ( $v1, $v2 ) = @_;
    my $r;

    while ( $v1 && $v2 ) {
	$v1 =~ s/^(\D*)//o;
	my $sp1 = $1;
	$v2 =~ s/^(\D*)//o;
	my $sp2 = $1;
#	warn "$sp1 cmp $sp2 = "._lcmp( $sp1,$sp2)."\n";
	if ( $r = _lcmp( $sp1, $sp2 ) ) {
	    return $r;
	}
	$v1 =~ s/^(\d*)//o;
	my $np1 = $1 || 0;
	$v2 =~ s/^(\d*)//o;
	my $np2 = $1 || 0;
#	warn "$np1 <=> $np2 = ".($np1 <=> $np2)."\n";
	if ( $r = ($np1 <=> $np2) ) {
	    return $r;
	}
    }
    if ( $v1 || $v2 ) {
	return $v1 ? 1 : -1;
    }

    return 0;
}

sub _lcmp {
    my ( $v1, $v2 ) = @_;
    
    for ( my $i = 0; $i < length( $v1 ); $i++ ) {
	my ( $n1, $n2 ) = ( ord( substr( $v1, $i, 1 ) ), 
			    ord( substr( $v2, $i, 1 ) ) );
	$n1 += 256 if $n1 < 65; # letters sort earlier than non-letters
	$n1 = -1 if $n1 == 126; # '~' sorts earlier than everything else
	$n2 += 256 if $n2 < 65;
	$n2 = -1 if $n2 == 126;
	if ( my $r = ($n1 <=> $n2) ) {
	    return $r;
	}
    }
    return length( $v1 ) <=> length( $v2 );
}

1;
__END__

=head1 COPYRIGHT

Copyright 2003, 2004 Frank Lichtenheld <frank@lichtenheld.de>

This file is distributed under the terms of the GNU Public
License, Version 2. See the source code for more details.

=head1 SEE ALSO

Debian policy <URL:http://www.debian.org/doc/debian-policy/>
