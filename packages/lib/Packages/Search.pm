#
# Packages::Search
# $Id$
#
# Copyright 2004 Frank Lichtenheld <frank@lichtenheld.de>
# 
# The code is based on the old search_packages.pl script that
# was:
#
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000, 2001 Josip Rodin
# Copyright (C) 2001 Adam Heath
# Copyright (C) 2004 Martin Schulze
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 1 of the License, or
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

Packages::Search - 

=head1 SYNOPSIS

=head1 DESCRIPTION

=over 4

=cut

package Packages::Search;

use strict;
use warnings;

use CGI;

use Deb::Versions;

our $VERSION = 0.01;
our $RCS_VERSION = '$Revision$';

my $debug = 0;

sub parse_params {
    my ( $cgi, $params_def ) = @_;

    my %params_ret = ( values => {}, errors => {} );

    foreach my $param ( keys %$params_def ) {
	
	print "DEBUG: Param $param<br>" if $debug;

	my $p_value_orig = $cgi->param($param);
	my $p_value = $p_value_orig;

	print "DEBUG: Value (Orig) $p_value_orig<br>" if $debug;

	if ($params_def->{$param}{match} && defined $p_value_orig) {
	    ($p_value) = ($p_value_orig =~ m/$params_def->{$param}{match}/);
	}

	print "DEBUG: Value (Match) $p_value<br>" if $debug;

	unless (defined $p_value) {
	    if (defined $params_def->{$param}{default}) {
		$p_value = $params_def->{$param}{default};
	    } else {
		$params_ret{errors}{$param} = "undef";
		next;
	    }
	}

	print "DEBUG: Value (Default) $p_value<br>" if $debug;
	my $p_value_no_replace = $p_value;

	if ($params_def->{$param}{replace} && $p_value) {
	    foreach (keys %{$params_def->{$param}{replace}}) {
		if ($p_value eq $_) {
		    $p_value = $params_def->{$param}{replace}{$_};
		}
	    }
	}
	
	print "DEBUG: Value (Final) $p_value<br>" if $debug;
	$params_ret{values}{$param} = {
	    orig => $p_value_orig,
	    no_replace => $p_value_no_replace,
	    final => $p_value,
	};
    }
    return %params_ret;
}

1;
