#!/usr/bin/perl -w
# copyright 1998 by James Treacy
require 5.001;

use Getopt::Long;
%opthash = (
	"mirror|m=s" => \$mirror_source,
	"type|t=s" => \$output_type
	);

my ($site, %mirror, %countries, $count, %longest);

sub process_line {
	($line) = @_;
	$field = '';

	if ($line =~ /^Site:\s*(.*)\s*$/i) {
		$site = $1;
		$count++;
		if (!defined($longest{site}) || length($site) > $longest{site}) {
			$longest{site} = length($site);
		}
		return;
	}
	elsif ($line =~ /^Aliases:\s*(.*)\s*$/is) {
		@tmp = split("\n", $1);
		$mirror{$site}{aliases} = [ @tmp ];
	}
	elsif ($line=~ /^((Archive|nonUS|WWW|Incoming|CDimage|Old)-(\w*)):\s*(.*)\s*$/i) {
		$type = lc $1;
		$mirror{$site}{method}{$type} = $4;
		if (!defined($longest{$type}) || length($4) > $longest{$type}) {
			$longest{$type} = length($4);
		}
	}
	elsif ($line =~ /^([\w-]+):\s*(.*?)\s*$/s) {
		$field = lc $1;
		$mirror{$site}{$field} = $2;
		if (!defined($longest{$field}) || length($2) > $longest{$field}) {
			$longest{$field} = length($2);
		}
	}
	else {
		die "Error: incorrect line format\n\"$line\"\n";
	}

	if ($field eq 'country') {
		$mirror{$site}{country} =~ s/^USA$/US/;
		$mirror{$site}{country} =~ s/^United States$/US/;
		$mirror{$site}{country} =~ s/^United Kingdom$/UK/;
		$mirror{$site}{country} =~ s/^England$/UK/;
		push @{ $countries{$mirror{$site}{country}} }, $site;
	}
}


sub table_html {
	print <<END;
<p><table border="1">
<caption>Secondary FTP and HTTP mirrors of the Debian archive</caption>
<tr><th><strong>hostname</strong> <th><strong>FTP</strong> <th><strong>http</strong>
	<th><strong>ports mirrored</strong>
END

	foreach $country (sort keys %countries) {
		# print "$_ = ".join(', ', @{$countries{$_}})."\n";
		print "<tr><td colspan=\"0\"><strong>$country</strong>\n";
		foreach (@{ $countries{$country} }) {
			if (defined $mirror{$_}{method}{'archive-ftp'} || defined $mirror{$_}{method}{'archive-http'}) {
				print "<tr>\n\t<td>$_\n\t<td>";
				if (defined $mirror{$_}{method}{'archive-ftp'}) {
					print "<a href=\"ftp://$_".$mirror{$_}{method}{'archive-ftp'}."\">".
						$mirror{$_}{method}{'archive-ftp'}."</a>";
				}
				print "\n\t<td>";
				if (defined $mirror{$_}{method}{'archive-http'}) {
					print "<a href=\"http://$_".$mirror{$_}{method}{'archive-http'}."\">".
						$mirror{$_}{method}{'archive-http'}."</a>";
				}
				print "\n";
			}
		}
	}

	print "</table>\n";
}


sub aptlines {
	foreach $country (sort keys %countries) {
		print "\n$country\n";
		$under = ''; for (my $i=0; $i<length($country); $i++) { $under .= "-";}
		print "$under\n";
		foreach (@{ $countries{$country} }) {
			if (defined $mirror{$_}{method}{'archive-ftp'}) {
				print "deb ftp://$_$mirror{$_}{method}{'archive-ftp'} stable main contrib non-free\n";
			}
			if (defined $mirror{$_}{method}{'nonus-ftp'}) {
				print "deb ftp://$_$mirror{$_}{method}{'nonus-ftp'} stable non-US\n";
			}
			if (defined $mirror{$_}{method}{'archive-http'}) {
				print "deb http://$_$mirror{$_}{method}{'archive-http'} stable main contrib non-free\n";
			}
			if (defined $mirror{$_}{method}{'nonus-http'}) {
				print "deb http://$_$mirror{$_}{method}{'nonus-http'} stable non-US\n";
			}
			print "\n";
		}
	}
}


sub table_archive {
	print "<b>" if $html;
	print   "Secondary FTP and HTTP mirrors of the Debian archive";
	print "</b>" if $html;
	print "\n----------------------------------------------------\n";
	# $tmp = "%-$longest{site}s %-$longest{'archive-ftp'}s%-$longest{'archive-http'}sPORTS MIRRORED\n";
	# printf $tmp, "HOSTNAME", "FTP", "HTTP";
	# $tmp =~ s/PORTS MIRRORED/--------------/;
	# printf $tmp, "--------", "---", "----";
	$tmp = "%-$longest{site}s %-$longest{'archive-ftp'}s%s\n";
	printf $tmp, "HOSTNAME", "FTP", "HTTP";
	printf $tmp, "--------", "---", "----";
	foreach $country (sort keys %countries) {
		if ($html) {
			print "\n<b>$country</b>\n";
		}
		else {
			print "\n$country\n";
		}
		$under = ''; for (my $i=0; $i<length($country); $i++) { $under .= "-";}
		print "$under\n";
		foreach (@{ $countries{$country} }) {
			if (defined $mirror{$_}{method}{'archive-ftp'} || defined $mirror{$_}{method}{'archive-http'}) {
				$tmp = "%-$longest{site}s ";
				printf $tmp, $_;
				if (defined $mirror{$_}{method}{'archive-ftp'} && $html) {
					$rest = $longest{'archive-ftp'} - length($mirror{$_}{method}{'archive-ftp'});
					$tmp = "<a href=\"%s\">%s</a>%${rest}s";
					printf $tmp, "ftp://$_$mirror{$_}{method}{'archive-ftp'}", $mirror{$_}{method}{'archive-ftp'}, '';
				}
				elsif (defined $mirror{$_}{method}{'archive-ftp'}) {
					$rest = $longest{'archive-ftp'} - length($mirror{$_}{method}{'archive-ftp'});
					$tmp = "%s%${rest}s";
					printf $tmp, $mirror{$_}{method}{'archive-ftp'}, '';
				}
				else {
					$tmp = "%-$longest{'archive-ftp'}s";
					printf $tmp, " ";
				}
				$tmp = "%-$longest{'archive-http'}s";
				if (defined $mirror{$_}{method}{'archive-http'} && $html) {
					$tmp = "<a href=\"%s\">%s</a>";
					printf $tmp, "http://$_$mirror{$_}{method}{'archive-http'}",$mirror{$_}{method}{'archive-http'};
				}
				elsif (defined $mirror{$_}{method}{'archive-http'}) {
					$tmp = "%s";
					printf $tmp, $mirror{$_}{method}{'archive-http'};
				}
				else {
					$tmp = "%-$longest{'archive-http'}s";
					printf $tmp, " ";
				}
				print "\n";
			}
		}
	}
}


sub intro {
	print "<h1>" if $html;
	print "Debian GNU/Linux - worldwide mirror sites";
	print "</h1>" if $html;
	print "\n\n";

	print "<p>" if $html;
	print "This file is broken up into two separate mirror listings:\n";
	print "primary and Secondary mirror sites.  The definitions are as follows:\n\n";

	print "<p>" if $html;
	print "A Primary mirror site has good bandwidth, is available 24 hours a day,\n";
	print "and has an easy to remember names of the form ftp.&lt;country&gt;.debian.org.\n";
	print "Additionally, most of them are updated automatically after updates to the\n";
	print "Debian archive.\n\n";

	print "<p>" if $html;
	print "A Secondary mirror site may have restrictions on what they\n";
	print "mirror (due to space restrictions). Just because a site is Secondary doesn't\n";
	print "necessarily mean it'll be any slower or less up to date than a Primary site.\n\n";

	print "<p>" if $html;
	print "Use the site closest to you for the fastest downloads possible whether is be\n";
	print "a primary or secondary site. The program <em>netselect</em> can be used to\n";
	print "determine the fastest of a list of sites.\n\n";

	print "<p>" if $html;
	print "If you know of any mirrors that are missing from this list,\n";
	print "please have the site maintainer fill out\n";

	if ($html) {
		print <<END;
<a href=\"http://www.debian.org/mirror/submit\">http://www.debian.org/mirror/submit</a>.
To contact the maintainer of this page, write to
<a href="mailto:mirrors\@debian.org">mirrors\@debian.org</a>.

<p><pre><small><b>Primary ISO Mirror Sites</b>
------------------------         	<b>/debian?</b>	<b>/debian-non-US?</b>
Australia     -   <a href="ftp://ftp.au.debian.org/debian/">ftp.au.debian.org</a>	Yes		<a
href="ftp://ftp.au.debian.org/debian-non-US">Yes</a>
Austria       -   <a href="ftp://ftp.at.debian.org/debian/">ftp.at.debian.org</a>	Yes		<a
href="ftp://ftp.at.debian.org/debian-non-US">Yes</a>
Germany       -   <a href="ftp://ftp.de.debian.org/debian/">ftp.de.debian.org</a>	Yes		<a
href="ftp://ftp.de.debian.org/debian-non-US">Yes</a>
Japan         -   <a href="ftp://ftp.jp.debian.org/debian/">ftp.jp.debian.org</a>	Yes		No
Korea         -   <a href="ftp://ftp.kr.debian.org/debian/">ftp.kr.debian.org</a>	Yes		No
United States -   <a href="ftp://ftp.debian.org/debian/">ftp.debian.org</a>   	Yes		No
   
</small></pre>
END
	}
	else {
		print <<END;
http://www.debian.org/mirror/submit
To contact the maintainer of this page, write to
mirrors\@debian.org

Primary ISO Mirror Sites
------------------------         	/debian?	/debian-non-US?
Australia     -   ftp.au.debian.org	Yes		Yes
Austria       -   ftp.at.debian.org	Yes		Yes
Germany       -   ftp.de.debian.org	Yes		Yes
Japan         -   ftp.jp.debian.org	Yes		No
Korea         -   ftp.kr.debian.org	Yes		No
United States -   ftp.debian.org   	Yes		No
   
END
	}
}


sub header {
	print <<END;
<html>

<head>
<title>Debian GNU/Linux Worldwide Mirror Sites</title>
</head>

<body>
END
}

sub trailer {
	print "</body>\n</html>\n";
}


sub access_methods {
	print <<END;
<h1>Access Methods for the Debian mirror sites</h1>
This page contains a list of mirrors of Debian. For each site, the different types
of material available are listed, along with the access method for each type.

<p>The following things are mirrored:
<dl>
<dt><b>Archive</b><dd>The Debian archive.
<dt><b>nonUS</b><dd>The nonUS portion of the Debian archive. Software is placed here if
	it can't be distributed in the US due to software patents or uses encryption.
<dt><b>Incoming</b><dd>The Incoming directory for packages destined to go into the archive.
	These packages are untested so you should only use these if you like living on the edge.
<dt><b>WWW</b><dd>The Debian web pages.
<dt><b>CDimage</b><dd>Official Debian CD Images. See
	<a href="http://cdimage.debian.org/">http://cdimage.debian.org/</a> for details.
</dl>

<p>The following access methods are available:
<dl compact>
<dt><b>http</b><dd>Standard web access.
<dt><b>ftp</b><dd>File Transfer Protocol
<dt><b>rsync</b><dd>An efficient means of mirroring
<dt><b>nfs</b><dd>If you don't know what it is, you don't need it.
</dl>

<p>The 'Type' entry is one of:
<dl compact>
<dt><b>leaf</b><dd>These comprise the bulk of the mirrors. Most of them mirror from a Push-Primary.
<dt><b>Push-Primary</b><dd>These sites mirror directly from the master archive site (which is
	not publicly accessable).
</dl>

<p><pre>
END
	foreach $country (sort keys %countries) {
		if ($html) {
			print "\n<b>$country</b>\n";
		}
		else {
			print "\n$country\n";
		}
		$under = ''; for (my $i=0; $i<length($country); $i++) { $under .= "-";}
		print "$under\n";
		foreach $site (@{ $countries{$country} }) {
			print "Site: $site";
			if (exists $mirror{$site}{'aliases'}) {
				print ", ".join(", ", @{ $mirror{$site}{'aliases'} })."\n";
			}
			else {
				print "\n";
			}
			if (! defined $mirror{$site}{'type'}) {
				print "Type: undefined\n";
			}
			else {
				print "Type: $mirror{$site}{'type'}\n";
			}
			foreach ( sort keys %{ $mirror{$site}{method} } ) {
				if ($_ =~ /http/) {
					print $_.":	<a href=\"http://$site$mirror{$site}{method}{$_}\">$mirror{$site}{method}{$_}</a>\n";
				}
				elsif ($_ =~ /ftp/) {
					print $_.":	<a href=\"ftp://$site$mirror{$site}{method}{$_}\">$mirror{$site}{method}{$_}</a>\n";
				}
				else {
					print $_.":	".$mirror{$site}{method}{$_}."\n";
				}
			}
			if (exists $mirror{$site}{'comment'}) {
				print "Comment: ".$mirror{$site}{comment}."\n";
			}
			print "\n";
		}
	}
	print "</pre>\n";
}

######### Begin main routine ###########################
Getopt::Long::config('no_getopt_compat', 'no_auto_abbrev');
GetOptions(%opthash) or fail("error parsing options");
if (! defined $mirror_source) {
	print "Error: No --mirror option given\n";
	exit;
}
# $mirror_source = "Mirrors";
if (! defined $output_type) { # choices are wml, html or text
	$output_type = 'html';
}

open(SRC, "<$mirror_source") || die "Error: problem opening mirror source file, $mirror_source\n";

$current = '';
$count = 0;
foreach (<SRC>) {
	chop;
	if (/^$/) {
		process_line($current);
		$current = '';
		next;
	}
	elsif (/^\s+(.*)$/) { # add line to current entry
		$current .= "\n$1";
	}
	elsif (/^[\w-]+:\s/) {
		if ($current ne "") { # need to process previous line
			process_line($current);
		}
		$current = $_;
			
	}
	else {
		die "Error: unknown line format\n$_\n";
	}
}
if ($current ne "") {
	process_line($current);
}

# count the number of mirrors
@tmp = keys %mirror;
$count = $#tmp + 1;

@stat = stat($mirror_source);
$last_modify = gmtime($stat[9]);
# print "$last_modify<br>";

if ($output_type eq 'html') {
	$html=1;
	header();
	intro();
	print "<small>\n<pre>\n";
	table_archive();
	print "<hr>Last modified: $last_modify                              Number of sites listed: $count\n";
	print "</pre>\n";
	print "</small>";
	trailer();
}
elsif ($output_type eq 'text') {
	# print "http://www.debian.org/mirror/submit\n\n";
	$html=0;
	intro();
	table_archive();
}
elsif ($output_type eq 'apt') {
	# print "http://www.debian.org/mirror/submit\n\n";
	header();
	print "<pre>\n";
	aptlines();
	print "</pre>\n";
	trailer();
}
elsif ($output_type eq 'methods') {
	$html=1;
	header();
	access_methods();
	trailer();
}
else {
	die "Error: unknown output type requested, $output_type\n";
}
