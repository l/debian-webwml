#!/usr/bin/perl
# Extracts the data file and makes a CVE cross-reference
#
# TODO
# - use the same code as in the security template to make URL entries
#   for the security references
# DONE:
# - printed references should follow some order - done by date
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
# -b bugtraq refs
# -c CERT refs
# -m mitre refs
# -p pretty print mode (HTML)
# -s sort | don't sort
getopts('hpmcbv');
if ( $opt_h ) {
# Help!
	print "usage: $0 [-vp] [-b|c|m]\n";
	print "\t-v\tverbose mode\n";
	print "\t-m\tPrint CVE/Mitre references (default)\n";
	print "\t-b\tPrint Bugtraq references\n";
	print "\t-c\tPrint CERT references\n";
	print "\t-p\tPretty-Print mode (HMTL)\n";
	exit 0;
}

# Default is to print only Mitre's
$opt_m = 1 if !defined ($opt_m) && ! defined($opt_c) && ! defined ($opt_b);

parsedirs (".", "data", 2);

# We just print for the time being only CVE references
printheader() if $opt_p;
printrefs("Mitre CVE dictionary","(CVE|CAN)","http://cve.mitre.org/cve/refs/refmap/source-DEBIAN.html") if $opt_m;
printrefs("Securityfocus Bugtraq database","BID","http://online.securityfocus.com/bid") if $opt_b;
printrefs("CERT alerts","CA-","http://www.cert.org/advisories/") if $opt_c;
printfooter() if $opt_p;

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

sub printrefs {
	my ($text,$type,$url) = @_;
	if ( ! $opt_p ) {
		print "DSA\t$text\n";
	} else { 
		print "<table BORDER=\"2\" CELLPADDING=\"2\" CELLSPACING=\"2\"><tr VALIGN=\"TOP\">\n<td>DEBIAN DSA</td>\n";
		if ( $url ) {
			print "<td><a href=\"$url\">$text</A></td></tr>\n";
		} else {
			print "<td>$text</td></tr>\n";
		}
	}
	foreach $dsa (sort { $dsaref{$b}{'date'} <=> $dsaref{$a}{'date'} } keys %dsaref) {
		my (@references) = split(' ', $dsaref{$dsa}{'secrefs'});
		my $refexists=0;
		my $refs="";
		foreach $ref ( @references ) {
		print STDERR "Checking $ref for $dsa against $type\n" if $opt_v;
			if ( $ref =~ /^$type/  ) {
				$refs .= "\t" if $refs;
				$refs .= $ref ;
				$refexists=1;
			}
		}
		print STDERR "References for $dsa of $type are $refs\n" if $opt_v;
		if ($refexists) {
			if ( ! $opt_p ) {
				print "DSA-$dsa\t$refs\t";
				print  gmctime($dsaref{$dsa}{'date'})."\n" ;
			} else {
				print "<tr VALIGN=\"TOP\"><td>DSA-$dsa</td><td>$refs</td></tr>\n";
			}
		}
	}
}

sub parsefile {
	my ($file,$filename) = @_ ;
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
		print STDERR "Reading $line\n" if $opt_v;
		if ( $line =~ /report_date\>(.*?)\<\/define-tag/ )  {
			my $dsadate=$1;
			# Just in case...
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
<H1>Cross References of Debian Security Advisories</H1>
<P>The data below shows the cross references of Debian Security Advisories
to other security information sources. These data is provided as 
references that might be useful to track down information relevant
to security fixes in Debian.

<P>Please notice that the Debian Security Team makes every effort possible
to include cross-references in DSAs (even after they have been published),
however, some DSAs might not have proper references to some security
information sources. If you find information lacking please
<a href="mailto:security@debian.org?subject=DSA cross references info">let us 
know</a>

<P><em>Note:</em> The data below is sorted in reverse chronological order.

EOF
	return 0;
}

sub printfooter {
# Nothing here (yet)
	return 0;
}
