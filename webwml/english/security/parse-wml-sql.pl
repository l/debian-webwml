#!/usr/bin/perl
# Extracts the data file and creates SQL calls to insert into
# a database
# 
# Copyright (c) 2004-2006 - Javier Fernandez-Sanguino <jfs@debian.org>
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
#    along with this program; if not, write to the Free Software Foundation:
#    51 Franklin Street, Suite 500, Boston, MA 02110-1335
#    (http://www.fsf.org/about/contact/)
#
# For more information please see
#  http://www.gnu.org/licenses/licenses.html#GPL
#
#
# TODO add tag
# moreinfo and description to the database
#

# Format of data files is:
#<define-tag pagetitle>DSA-###-# PACKAGE</define-tag>
#<define-tag report_date>yyyy-mm-dd</define-tag>
#<define-tag secrefs>CAN|CVE-XXXX-XXXX</define-tag>
#<define-tag packages>PACKAGE</define-tag>
#<define-tag isvulnerable>yes|no</define-tag>
#<define-tag fixed>yes|no</define-tag>

use Getopt::Std;
use Time::gmtime;
use IO::File;
use Date::Parse;
use parse_wml qw{%dsaref $VERBOSE};

# Stdin options
# -v verbose
getopts('hv');
if ( $opt_h ) {
# Help!
	print "usage: $0 [-vh]\n";
	print "\t-v\tverbose mode\n";
	print "\t-h\tthis help\n";
	exit 0;
}
$ParseDSA::VERBOSE=$opt_v;


ParseDSA::parsedirs (".", "data", 2);


# Data
printdsas();
# References
printrefs();

exit 0;

sub printdsas {
	foreach $dsa ( keys %ParseDSA::dsaref) {
		print "INSERT INTO DSA (\"dsaid\") VALUES ('$dsa');\n";
		print "UPDATE DSA SET ";
		foreach $key (keys %{$ParseDSA::dsaref{$dsa}} ) {
			print "\"$key\"='$ParseDSA::dsaref{$dsa}{$key}', " if ( $key ne "secrefs" ) ;
		}
		print " \"dsaid\"='$dsa' ";
		print "WHERE \"dsaid\"='$dsa';\n";
	}
	return 0;
}

sub printreferences {
	my ($dsa) = @_;
	print "Printing references for $dsa\n" if $opt_v;
	foreach $ref ( split(' ', $ParseDSA::dsaref{$dsa}{'secrefs'}) ) {
		my $query="INSERT INTO ";
		if ( $ref =~ /((CVE|CAN)-[\d-]+)/i )  {
			$query .= "cvedsa (\"cve\", \"dsaid\") ";
			$query .= "VALUES ('$ref','$dsa');\n";
		}
		if ( $ref =~ /BID(\d+)/i ) {
			$query .= "biddsa (\"bid\", \"dsaid\") ";
			$query .= "VALUES ('$1','$dsa');\n";
		}
		if ( $ref =~ /CA-[\d-]+/i ) {
			$query .= "certcadsa (\"caid\", \"dsaid\") ";
			$query .= "VALUES ('$ref','$dsa');\n";
		}
		if ( $ref =~ /VU\#([\d-]+)/i ) {
			$query .= "certvudsa (\"vuid\", \"dsaid\") ";
			$query .= "VALUES ('$1','$dsa');\n";
		}
		# Since we don't support some references like  Bug#XXXXX
		# exclude them
		print $query if $query ne "INSERT INTO ";
	}
	return 0;
}

sub printrefs {
	foreach $dsa ( keys %ParseDSA::dsaref) {
		printreferences($dsa);
	}
}


