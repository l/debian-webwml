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

use CGI qw( -oldstyle_urls );
use POSIX;
use HTML::Entities;

use Deb::Versions;
use Exporter;

our @ISA = qw( Exporter );

our @EXPORT_OK = qw( nextlink prevlink indexline
                     resperpagelink );
our %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );

our $VERSION = 0.01;
our $RCS_VERSION = '$Revision$';

our $USE_PAGED_MODE = 1;
use constant DEFAULT_PAGE => 1;
use constant DEFAULT_RES_PER_PAGE => 50;
our %page_params = ( page => { default => DEFAULT_PAGE,
                               match => '(\d+)' },
                     number => { default => DEFAULT_RES_PER_PAGE,
                                 match => '(\d+)' } );

my $debug = 0;

sub parse_params {
    my ( $cgi, $params_def ) = @_;

    my %params_ret = ( values => {}, errors => {} );
    my %params;
    if ($USE_PAGED_MODE) {
        print "DEBUG: Use PAGED_MODE<br>" if $debug;
        %params = %$params_def;
        foreach (keys %page_params) {
            delete $params{$_};
        }
        %params = ( %params, %page_params );
    } else {
        %params = %$params_def;
    }

    foreach my $param ( keys %params ) {
	
	print "DEBUG: Param $param<br>" if $debug;

	my $p_value_orig = $cgi->param($param);
	my $p_value = $p_value_orig;

        #TODO: don't produce "uninitialized value" warnings
	print "DEBUG: Value (Orig) $p_value_orig<br>" if $debug;

	if ($params_def->{$param}{match} && defined $p_value_orig) {
	    ($p_value) = ($p_value_orig =~ m/$params_def->{$param}{match}/);
	}

	print "DEBUG: Value (Match) $p_value<br>" if $debug;

	unless (defined $p_value) {
	    if (defined $params{$param}{default}) {
		$p_value = $params{$param}{default};
	    } else {
		$params_ret{errors}{$param} = "undef";
		next;
	    }
	}

	print "DEBUG: Value (Default) $p_value<br>" if $debug;
	my $p_value_no_replace = $p_value;

	if ($params{$param}{replace} && $p_value) {
	    foreach (keys %{$params{$param}{replace}}) {
		if ($p_value eq $_) {
		    $p_value = $params{$param}{replace}{$_};
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

    if ($USE_PAGED_MODE) {
        $cgi->delete( "page" );
        $cgi->delete( "number" );
    }

    return %params_ret;
}

sub start { 
    my $params = shift;

    my $page = $params->{values}{page}{final}
    || DEFAULT_PAGE;
    my $res_per_page = $params->{values}{number}{final}
    || DEFAULT_RES_PER_PAGE;

    return 1 if $res_per_page =~ /^all$/i;
    return $res_per_page * ($page - 1) + 1;
}

sub end {
    my $params = shift;

    my $page = $params->{values}{page}{final}
    || DEFAULT_PAGE;
    my $res_per_page = $params->{values}{number}{final}
    || DEFAULT_RES_PER_PAGE;

    return $page * $res_per_page;
}

sub indexline {
    my ($cgi, $params, $num_res) = @_;

    my $index_line = "";
    my $page = $params->{values}{page}{final}
    || DEFAULT_PAGE;
    my $res_per_page = $params->{values}{number}{final}
    || DEFAULT_RES_PER_PAGE;
    my $numpages = ceil($num_res /
                        $res_per_page);
    for (my $i = 1; $i <= $numpages; $i++) {
        if ($i == $page) {
            $index_line .= $i;
        } else {
            $index_line .= "<a href=\"".encode_entities($cgi->self_url).
                "&amp;page=$i&amp;number=$res_per_page\">".
                "$i</a>";
        }
	if ($i < $numpages) {
	   $index_line .= " | ";
	}
    }
    return $index_line;
}

sub nextlink {
    my ($cgi, $params, $no_results ) = @_;

    my $page = $params->{values}{page}{final}
    || DEFAULT_PAGE;
    $page++;
    my $res_per_page = $params->{values}{number}{final}
    || DEFAULT_RES_PER_PAGE;

    if ((($page-1)*$res_per_page + 1) > $no_results) {
        return "&gt;&gt;";
    }

    return "<a href=\"".encode_entities($cgi->self_url).
        "&amp;page=$page&amp;number=$res_per_page\">&gt;&gt;</a>";
}

sub prevlink {
    my ($cgi, $params ) = @_;

    my $page = $params->{values}{page}{final}
    || DEFAULT_PAGE;
    $page--;
    if (!$page) {
        return "&lt;&lt;";
    }

    my $res_per_page = $params->{values}{number}{final}
    || DEFAULT_RES_PER_PAGE;

    return "<a href=\"".encode_entities($cgi->self_url).
        "&amp;page=$page&amp;number=$res_per_page\">&lt;&lt;</a>";
}

sub resperpagelink {
    my ($cgi, $params, $res_per_page ) = @_;

    my $page;
    if ($res_per_page =~ /^all$/i) {
	$page = 1;
    } else {
	$page = ceil(start( $params ) / $res_per_page);
    }

    return "<a href=\"".encode_entities($cgi->self_url).
        "&amp;page=$page&amp;number=$res_per_page\">$res_per_page</a>";
}


1;
