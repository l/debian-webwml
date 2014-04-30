#!/usr/bin/perl -w
# 
# Script to count the vulnerabilities fixed in DSAs and count the
# different type of root security issues.
#
# Note: The 'type' of a security issue is extracted directly from the advisory
# text using regular expressions and is not necessarily accurate.
# 
# Copyright (c) 2004 - Javier Fernandez-Sanguino <jfs@debian.org>
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

use Getopt::Std;
use Time::gmtime;
use IO::File;
use Date::Parse;
use strict;

my %HASH;
my %DSAcount;
my %dsaref;
my $opt_h;
my $opt_v;

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


# Extract data
#parsedirs (".", "data", 2);
parsedirs (".", "wml", 2);

# Print page
countvuln();
printtable();

exit 0;

sub countvuln {
# Count the vulnerabilities in %dsaref based on description
	foreach my $dsa (keys %dsaref) {
		if  ( defined $dsaref{$dsa}{'description'} ) {
			my $type = $dsaref{$dsa}{'description'};
			$type =~ s/ *$//;
			$type =~ s/(overflow|file)s$/$1/;
			$type =~ s/saniti[zs]ing|validation/validation/;
			$type =~ s/unsanitised input/missing input validation/;
			$HASH{ $type } += 1;  # Increase type of flaw.
			$DSAcount{ $type } .= " " . $dsa ;
		}
	}
}

##
##  Simple HTML output
##
sub printtable {
	print "<table>";
	foreach my $key ( sort { $HASH{$b} <=> $HASH{$a} } keys %HASH )
	{
		print "<tr bgcolor=\"#cccccc\"><td>" . $key . "</td><td>" . $HASH{ $key }  . "</tr>\n";

		print "<tr><td></td><td>";
		foreach my $vuln ( split( / /, $DSAcount{ $key } ) )
		{
			next if not length( $vuln );

			$vuln = lc($vuln);
			print "<a href=\"https://www.debian.org/security/2005/$vuln\">$vuln</a> ";
		}
		print "</td></tr>\n";
	}
	print "</table>";
}

sub parsewmlfile {
	my ($file,$filename) = @_ ;
	my $dsa;
	my $line;
# The filename gives us the DSA we are parsing
	if ( $filename =~ /dsa\-(\d+)/ || $filename =~ /(\d+\w+)/ ) {
		$dsa=$1;
	} else {
		print STDERR "File $file does not look like a proper DSA, not checking\n" if $opt_v;
		return 1;
	}
	print STDERR "Parsing DSA $dsa from file $file\n" if $opt_v;
	open (WMLFILE , $file) || die ("Cannot read $file: $!");
	while ($line=<WMLFILE>) {
		chomp $line;
		if ( $line =~ /description\>(.*?)\<\/define-tag/ )  {
			$dsaref{$dsa}{'description'}=$1;
		}
		last if defined $dsaref{$dsa}{'description'};
	}
	close WMLFILE;
	return 0;
}

sub parsedatafile {
	my ($file,$filename) = @_ ;
	my $dsa;
	my $line;
# The filename gives us the DSA we are parsing
	if ( $filename =~ /dsa\-(\d+)/ || $filename =~ /(\d+\w+)/ ) {
		$dsa=$1;
	} else {
		print STDERR "File $file does not look like a proper DSA, not checking\n" if $opt_v;
		return 1;
	}
	print STDERR "Parsing DSA $dsa from file $file\n" if $opt_v;

	open (DATAFILE , $file) || die ("Cannot read $file: $!");
	while ($line=<DATAFILE>) {
		chomp $line;
		if ( $line =~ /report_date\>([\d\-\/]+)\<\/define-tag/ )  {
			my $dsadate=$1;
			# Just in case...
			$dsadate =~ s/\-(\d)\-/-0$1-/;
			$dsadate =~ s/\-(\d)$/-0$1/;
			$dsaref{$dsa}{'date'}=$dsadate ;
		}
		if ( $line =~ /secrefs\>(.*?)\<\/define-tag/ ) {
			$dsaref{$dsa}{'secrefs'}=$1 ;
			print STDERR "Extracted security references: $dsaref{$dsa}{'secrefs'}\n" if $opt_v;
		}
		$dsaref{$dsa}{'package'}=$1 if ( $line =~ /packages\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'vulnerable'}=$1 if ( $line =~ /isvulnerable\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'fixed'}=$1 if ( $line =~ /fixed\>(.*?)\<\/define-tag/ ) ;
	}
	close DATAFILE;
	return 0;
}

sub parsedirs {
	my ($directory, $postfix, $depth) = @_ ;
	my $dir = new IO::File;
	if ( $depth == 0 ) {
		print STDERR "Maximum depth reached ($depth) at $directory\n" if $opt_v;
		return 0;
	}
	opendir ($dir , $directory) || die ("Cannot read $directory: $!");
	while ( my $file = readdir ($dir) ) {
		print STDERR "Checking $file (for $postfix at $depth)\n" if $opt_v;
		if ( -d "${directory}/${file}"  and ! -l "${directory}/${file}" && $file !~ /^\./ ) {
			print STDERR "Entering directory ${directory}/${file}\n" if $opt_v;
			parsedirs ( "${directory}/${file}", $postfix, $depth - 1 );
		} 
		if ( -r "${directory}/${file}" && $file =~ /$postfix/ && $file !~ /^[\.\#]/ ) {
			parsedatafile($directory."/".$file,$file) if $file =~ /data$/;
			parsewmlfile($directory."/".$file,$file) if $file =~ /wml$/;
		}
	} # of the while
	closedir $dir;
	return 0;
}

