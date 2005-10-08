#!/usr/bin/perl
# Extracts the data file and creates SQL calls to insert into
# a database
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
require 'parse_wml.pm';

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
$VERBOSE=$opt_v;


ParseDSA::parsedirs (".", "data", 2);


# Data
printdsas();
# References
printrefs();

exit 0;

sub printdsas {
	foreach $dsa ( keys %dsaref) {
		print "INSERT INTO DSA (\"dsaid\") VALUES ('$dsa');\n";
		print "UPDATE DSA SET ";
		foreach $key (keys %{$dsaref{$dsa}} ) {
			print "\"$key\"='$dsaref{$dsa}{$key}', " if ( $key ne "secrefs" ) ;
		}
		print " \"dsaid\"='$dsa' ";
		print "WHERE \"dsaid\"='$dsa';\n";
	}
	return 0;
}

sub printreferences {
	my ($dsa) = @_;
	print "Printing references for $dsa\n" if $opt_v;
	foreach $ref ( split(' ', $dsaref{$dsa}{'secrefs'}) ) {
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
	foreach $dsa ( keys %dsaref) {
		printreferences($dsa);
	}
}


