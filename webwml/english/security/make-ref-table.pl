#!/usr/bin/perl
# Extracts the data file and makes a CVE cross-reference
# 
# Copyright (c) 2003-2004 - Javier Fernandez-Sanguino <jfs@debian.org>
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
# TODO
# - provide a way for localization of header text
# DONE:
# - printed references should follow some order - done by date
# - use the same code as in the security template to make URL entries
#   for the security references
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

# Stdin options
# -v verbose
# -a print all references (in HTML mode side by side)
# -b bugtraq refs
# -c CERT refs
# -k CERT kb refs
# -m mitre refs
# -p pretty print mode (HTML)
# -s sort | don't sort
# -f print full page (header and footer)
getopts('hpmkcbva');
if ( $opt_h ) {
# Help!
	print "usage: $0 [-vp] [-b|c|m]\n";
	print "\t-v\tverbose mode\n";
	print "\t-m\tPrint CVE/Mitre references (default)\n";
	print "\t-b\tPrint Bugtraq references\n";
	print "\t-c\tPrint CERT references\n";
	print "\t-p\tPretty-Print mode (HTML)\n";
	exit 0;
}

# Default is to print only Mitre's
$opt_m = 1 if !defined ($opt_m) && ! defined($opt_c) && ! defined ($opt_b) && ! defined ($opt_k);
if (defined ($opt_a)) {
	$opt_m=1;
	$opt_c=1;
	$opt_b=1;
	$opt_k=1;
}

parsedirs (".", "data", 2);

$reference{mitre}{url}="http://cve.mitre.org/cve/refs/refmap/source-DEBIAN.html";
$reference{mitre}{name}='<gettext domain="security">Mitre CVE dictionary</gettext>';
$reference{mitre}{perlre}="(CVE|CAN)";

$reference{bid}{name}='<gettext domain="security">Securityfocus Bugtraq database</gettext>';
$reference{bid}{url}="http://www.securityfocus.com/bid";
$reference{bid}{perlre}="BID";

$reference{cert}{name}='<gettext domain="security">CERT Advisories</gettext>';
$reference{cert}{url}="http://www.cert.org/advisories/";
$reference{cert}{perlre}="CA-";

$reference{certvu}{name}='<gettext domain="security">US-CERT vulnerabilities Notes</gettext>';
$reference{certvu}{url}="http://www.kb.cert.org/vuls";
$reference{certvu}{perlre}="VU";

# We just print for the time being only CVE references
printheader() if $opt_p && $opt_f;
# Table with information
printrefs();
printfooter() if $opt_p && $opt_f;

#printrefs($reference{mitre}{name},$reference{mitre}{perlre},$reference{mitre}{url}) if $opt_m;
#printrefs($reference{bid}{name},$reference{bid}{perlre},$reference{bid}{url}) if $opt_b;
#printrefs($reference{cert}{name},$reference{cert}{perlre},$reference{cert}{url}) if $opt_c;
#printrefs($reference{certvu}{name},$reference{certkb}{perlre},$reference{certvu}{url}) if $opt_k;

# But we could also print all the keys like this:
# printallkeys();
exit 0;

sub printallkeys {
	foreach $dsa (sort { $dsaref{$b}{'date'} <=> $dsaref{$a}{'date'} } keys %dsaref) {
		print "$dsa:\t";
		foreach $key (keys %{$dsaref{$dsa}} ) {
			print "$dsaref{$dsa}{$key}\t";
		}
		print "\n";
	}
	return 0;
}

sub printtableheader {
	my ($key) = @_;
	if (defined $reference{$key}{url}) {
			print "<th><a href=\"$reference{$key}{url}\">$reference{$key}{name}</A></th>\n";
		} else {
			print "<th>$reference{$key}{name}</th>\n";
		}
	return 0;
}

sub getreferences {
	my ($key,$dsa) = @_;
	return if ! defined ($dsaref{$dsa}{'secrefs'});
	my @references;
	my (@references) = split(' ', $dsaref{$dsa}{'secrefs'}); 
	my $text = "";
	my $type = $reference{$key}{perlre};
	foreach $ref ( @references ) {
		print STDERR "Comparing $ref for $dsa against $type\n" if $opt_v;
		if ( $ref =~ /^$type/  ) {
			$text .= "\t" if $text;
			$text .= $ref ;
		}
	}
	print STDERR "References for $dsa of $type: $text\n" if $opt_v;
	if ( $opt_p ) {
		if ( $text eq "" ) {
			$text = "<td>&nbsp;</td>" ;
		} else {
			$text = "<td><:= bid_secref(\"$text\") :><:= cert_secref(\"$text\") :><:= cve_secref(\"$text\") :></td>";
		}
	}
	$dsaref{$dsa}{'printtext'} .= $text;
	return 0;
}

sub printrefs {
	if ( ! $opt_p ) {
		print "DSA\t$text\n";
	} else { 
		print "<table BORDER=\"2\" CELLPADDING=\"2\" CELLSPACING=\"2\"><tr VALIGN=\"TOP\"><th>Debian DSA</th>";
		printtableheader("mitre") if $opt_m;
		printtableheader("bid") if $opt_b;
		printtableheader("cert") if $opt_c;
		printtableheader("certvu") if $opt_k;
		print "</tr>\n";
	}
	foreach $dsa (sort { $dsaref{$b}{'date'} <=> $dsaref{$a}{'date'} } keys %dsaref) {
		getreferences("mitre",$dsa) if ( $opt_m ) ;
		getreferences("bid",$dsa)  if ( $opt_b ) ;
		getreferences("cert",$dsa)  if ( $opt_c ) ;
		getreferences("certvu",$dsa) if ( $opt_k );
		# Print only if there is text _and_ it includes
		# some numbers (otherwise there are no references)
		if ( defined($dsaref{$dsa}{'printtext'} ) && $dsaref{$dsa}{'printtext'} =~ /\d/ ) {
			if ( ! $opt_p ) {
			#Don't print DSA- for those that have year format (old
			#type of advisories)
				print uc($dsa);			    
				print "\t$dsaref{$dsa}{'printtext'}\t";
				print  gmctime($dsaref{$dsa}{'date'})."\n" ;
			} else {
				print "<tr VALIGN=\"TOP\"><td>";
				print "<a href=\"https://www.debian.org/security/".$dsaref{$dsa}{'location'}."\">";
				print uc($dsa)."</a>";
				print "</td>$dsaref{$dsa}{'printtext'} </tr>\n";
			}
		}
	}
	print "</table>\n" if $opt_p;
}

sub parsefile {
	my ($file,$filename) = @_ ;
# The filename gives us the DSA we are parsing
	if ( $filename =~ /(d[ls]a\-\d+)/ || $filename =~ /(\d+\w+)/ ) {
		$dsa=$1;
	} else {
		print STDERR "File $file does not look like a proper DSA, not checking\n" if $opt_v;
		return 1;
	}
	print STDERR "Parsing DSA $dsa from file $file\n" if $opt_v;

	open (DATAFILE , $file) || die ("Cannot read $file: $!");
	while ($line=<DATAFILE>) {
		chomp $line;
		print STDERR "Reading $line\n" if $opt_v;
		if ( $line =~ /report_date\>(.*?)\<\/define-tag/ )  {
			my $dsadate=$1;
			# Just in case...
			# Remove multiple dates, keep only the first one
			$dsadate =~ s/,.*$//;
			$dsadate =~ s/\-(\d)\-/-0$1-/;
			$dsadate =~ s/\-(\d)$/-0$1/;
			$dsaref{$dsa}{'date'}=str2time($dsadate) ;
		}
		if ( $line =~ /secrefs\>(.*?)\<\/define-tag/ ) {
			$dsaref{$dsa}{'secrefs'}=$1 ;
			print STDERR "Extracted security references: $dsaref{$dsa}{'secrefs'}\n" if $opt_v;
		}
		$dsaref{$dsa}{'packages'}=$1 if ( $line =~ /packages\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'vulnerable'}=$1 if ( $line =~ /isvulnerable\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'fixed'}=$1 if ( $line =~ /fixed\>(.*?)\<\/define-tag/ ) ;
	}
	$dsaref{$dsa}{'date'} = 0 if ! defined $dsaref{$dsa}{'date'};
	$dsaref{$dsa}{'location'}=$file;
	$dsaref{$dsa}{'location'} =~ s/.data$//;
	$dsaref{$dsa}{'location'} =~ s/^.\///;
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
			parsefile($directory."/".$file,$file);
		}
	} # of the while
	closedir $dir;
	return 0;
}


sub printheader {
	print <<EOF;
#use wml::debian::template title="Security Crossreferences" GEN_TIME="yes"
#use wml::debian::securityreferences
<H1>Cross References of Debian Security Advisories</H1>
<P>The data below shows cross references of Debian Security Advisories
to other security information sources. This data is provided in the
hopes that might be useful to track down information relevant
to security issues and fixes in the Debian distribution.

<P>Please notice that the Debian Security Team makes every effort possible
to include cross-references in DSAs (even after they have been published),
however, some DSAs might not have proper references to some security
information sources. If you find information lacking please
<a href="mailto:security\@debian.org?subject=DSA_cross_references_info">let us 
know</a>.

<P><em>Note:</em> The data below is sorted in reverse chronological order.

EOF
	return 0;
}

sub printfooter {
# Nothing here (yet)
	return 0;
}
