#!/usr/bin/perl -wT
#
# download.pl -- CGI interface for downloading files on packages.debian.org
#
# Copyright (C) 1998 (?) James Treacy
# Copyright (C) 2001 Josip Rodin
#
# Licensed under the GPL or something.

require 5.001;
use strict;
use CGI;

my ($input,   # The CGI data
    $file, $filen, $md5sum, @file_components, $type);

# TODO: find a way to get the U.S. mirror list from a more authoritive
# location automatically. might not be overly smart to automatize it
# completely, since I hand pick sites that are up-to-date, fast, and
# have HTTP on a reasonably short URL
#   -- Joy

# hint:
# grep-dctrl -F Site,Alias -e '(udel|bigfoot|download.sourceforge|kernel|crosslink|internap|cerias|lcs.mit|progeny)' Mirrors.masterlist | timestamps/archive_mirror_check.py
my @north_american_sites = (
	"ftp.us.debian.org/debian",
	"http.us.debian.org/debian",
	"ftp.debian.org/debian",
#	"ftp.ca.debian.org/debian",
	"ftp.egr.msu.edu/debian",
	"mirrors.kernel.org/debian",
	"archive.progeny.com/debian",
	"osdn.dl.sourceforge.net/debian",
	"debian.crosslink.net/debian",
	"ftp-mirror.internap.com/pub/debian",
	"ftp.cerias.purdue.edu/pub/os/debian",
	"ftp.lug.udel.edu/debian",
	"debian.lcs.mit.edu/debian",
	"debian.teleglobe.net",
	);
my @european_sites = (
	"ftp.de.debian.org/debian",
	"ftp.at.debian.org/debian",
	"ftp.bg.debian.org/debian",
	"ftp.cz.debian.org/debian",
	"ftp.dk.debian.org/debian",
	"ftp.ee.debian.org/debian",
	"ftp.fi.debian.org/debian",
	"ftp.fr.debian.org/debian",
	"ftp.hr.debian.org/debian",
	"ftp.hu.debian.org/debian",
	"ftp.it.debian.org/debian",
	"ftp.nl.debian.org/debian",
	"ftp.no.debian.org/debian",
	"ftp.pl.debian.org/debian",
	"ftp.si.debian.org/debian",
	"ftp.es.debian.org/debian",
	"ftp.se.debian.org/debian",
	"ftp.tr.debian.org/debian",
	"ftp.uk.debian.org/debian",
	);
my @south_american_sites = (
	"ftp.br.debian.org/debian",
	"ftp.cl.debian.org/debian",
	);
my @australian_sites = (
	"ftp.au.debian.org/debian",
	"ftp.wa.au.debian.org/debian",
	"ftp.nz.debian.org/debian",
	);
my @asian_sites = (
	"ftp.jp.debian.org/debian",
#	"ftp.kr.debian.org/debian",
	"linux.csie.nctu.edu.tw/debian",
	"debian.linux.org.tw/debian",
	"linux.cdpa.nsysu.edu.tw/debian",
	); 

my @nonus_north_american_sites = (
#	"ftp.ca.debian.org/debian-non-US",
	"debian.yorku.ca/debian/non-US",
	"mirror.direct.ca/linux/debian-non-US",
	);
my @nonus_european_sites = (
	"non-us.debian.org/debian-non-US",
	"ftp.de.debian.org/debian-non-US",
	"ftp.at.debian.org/debian-non-US",
	"ftp.bg.debian.org/debian-non-US",
	"ftp.cz.debian.org/debian-non-US",
	"ftp.fi.debian.org/debian-non-US",
	"ftp.fr.debian.org/debian-non-US",
	"ftp.hr.debian.org/debian-non-US",
	"ftp.hu.debian.org/debian-non-US",
	"ftp.it.debian.org/debian-non-US",
	"ftp.nl.debian.org/debian-non-US",
	"ftp.no.debian.org/debian-non-US",
	"ftp.pl.debian.org/debian/non-US",
	"ftp.si.debian.org/debian-non-US",
	"ftp.es.debian.org/debian-non-US",
	"ftp.se.debian.org/debian-non-US",
	"ftp.tr.debian.org/debian-non-US",
	"ftp.uk.debian.org/debian/non-US",
	);
my @nonus_australian_sites = (
	"ftp.au.debian.org/debian-non-US",
	"ftp.wa.au.debian.org/debian-non-US",
	"ftp.nz.debian.org/debian-non-US",
	);
my @nonus_asian_sites = (
	"ftp.jp.debian.org/debian-non-US",
#	"ftp.kr.debian.org/debian-non-US",
	"linux.csie.nctu.edu.tw/debian-non-US",
	"debian.linux.org.tw/debian-non-US",
	"linux.cdpa.nsysu.edu.tw/debian-non-US",
	);
my @nonus_south_american_sites = (
	"ftp.br.debian.org/debian-non-US",
	"ftp.cl.debian.org/debian-non-US",
	);

#if (exists $ENV{'HTTP_REFERER'}) {
#	$urlbase= $ENV{'HTTP_REFERER'};
#}
#else {
#	$urlbase = '';
#}
#if ($urlbase =~ m,(http://www\.(..\.)?debian.org),) {
#	$urlbase = $1;
#}
#else {
#	$urlbase = "http://www.debian.org";
#}
my $urlbase = "http://www.debian.org";

$ENV{PATH} = "/bin:/usr/bin";
# Read in all the variables set by the form
$input = new CGI;

print $input->header;

# If you want, just print out a list of all of the variables.
# print $input->dump;
# exit;

$file = $input->param('file');
unless (defined $file) {
  print "<p>Internal error: Required parameter \"file\" is missing.\n";
  print "<p>If the problem persists, please inform $ENV{SERVER_ADMIN}.\n";
  exit;
}
@file_components = split('/', $file);
$filen = pop(@file_components);

$md5sum = $input->param('md5sum');
unless (defined $md5sum) {
  print "<p>Internal error: Required parameter \"md5sum\" is missing.\n";
  print "<p>If the problem persists, please inform $ENV{SERVER_ADMIN}.\n";
  exit;
}

$type = $input->param('type');
unless (defined $type) {
  print "<p>Internal error: Required parameter \"type\" is missing.\n";
  print "<p>If the problem persists, please inform $ENV{SERVER_ADMIN}.\n";
  exit;
}

print <<END;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html lang="en">
<head>
  <title>Debian GNU/Linux -- Download Page</title>
  <link rev="made" href="mailto:webmaster\@debian.org">
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <meta name="Author" content="Debian Webmaster, webmaster\@debian.org">
  <meta name="Language" content="English">
</head>
<body text="#000000" bgcolor="#FFFFFF" link="#0000FF" vlink="#800080" alink="#FF0000">

<table border="0" cellpadding="3" cellspacing="0" align="center" summary="">
<tr>
<td>
<a href="$urlbase/logos/"><IMG src="$urlbase/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="" width="50" height="61"></A>
<a href="$urlbase/"><IMG src="$urlbase/Pics/debian.jpg" border="0" hspace="0" vspace="0" alt="Debian Project" width="179" height="61"></a>
</td>
</tr>
</table>
<table bgcolor="#DF0451" border="0" cellpadding="0" cellspacing="0" width="100%" summary="">
<tr>
<td valign="top">
<img src="$urlbase/Pics/red-upperleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
<td rowspan="2" align="center">
<a href="$urlbase/intro/about"><img src="$urlbase/Pics/about.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="About&nbsp;Debian" width="58" height="18"></A>
<a href="$urlbase/News/"><img src="$urlbase/Pics/news.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="News" width="53" height="18"></A>
<a href="$urlbase/distrib/"><img src="$urlbase/Pics/getting.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Getting Debian" width="117" height="18"></A>
<a href="$urlbase/support"><img src="$urlbase/Pics/support.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Support" width="72" height="18"></A>
<a href="$urlbase/devel/"><img src="$urlbase/Pics/devel.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Developers'&nbsp;Corner" width="105" height="18"></A>
<a href="$urlbase/sitemap"><img src="$urlbase/Pics/sitemap.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Site map" width="76" height="18"></A>
<a href="http://search.debian.org/"><img src="$urlbase/Pics/search.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Search" width="64" height="18"></A>
</td>
<td valign="top">
<img src="$urlbase/Pics/red-upperright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
</td>
</tr>
<tr>
<td valign="bottom">
<img src="$urlbase/Pics/red-lowerleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
</td>
<td valign="bottom">
<img src="$urlbase/Pics/red-lowerright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
</tr>
</table>

<h2>Download Page for <kbd>$filen</kbd> on Intel x86 machines</h2>

<p>You can download the requested file from the <tt>
END
my $dir;
foreach $dir (@file_components) { print "$dir/"; };
print "</tt> subdirectory at";
print $type ne 'security' ? " any of these sites:" : ":";

if ($type eq 'security') {

	print <<END;
<ul>
  <li><a href="http://security.debian.org/debian-security/$file">security.debian.org/debian-security</a>
</ul>

<p>Debian security updates are currently officially distributed only via
security.debian.org.</p>
END

} elsif ($type eq 'nonus') {

	print "<p><em>North America</em>";
	print "<ul>";
	foreach (@nonus_north_american_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";

	print "<p><em>Europe</em>";
	print "<ul>";
	foreach (@nonus_european_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";

	print "<p><em>Australia and New Zealand</em>";
	print "<ul>";
	foreach (@nonus_australian_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";

	print "<p><em>Asia</em>";
	print "<ul>";
	foreach (@nonus_asian_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";

	print "<p><em>South America</em>";
	print "<ul>";
	foreach (@nonus_south_american_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";

	print <<END;
<p>If none of the above sites are fast enough for you, please see our
<a href="http://www.debian.org/mirror/list-non-US">complete mirror list</a>.
END

} elsif ($type eq 'main') {

	print "<table border=0><tr><td valign=top>";
	print "<p><em>North America</em>";
	print "<ul>";
	foreach (@north_american_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";
	print "</td>";

	print "<td>";
	print "<p><em>Europe</em>";
	print "<ul>";
	foreach (@european_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";
	print "</td></tr>";

	print "<tr><td>";
	print "<p><em>Australia and New Zealand</em>";
	print "<ul>";
	foreach (@australian_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";
	print "</td>";

	print "<td>";
	print "<p><em>Asia</em>";
	print "<ul>";
	foreach (@asian_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";
	print "</td></tr>";

	print "<tr><td>";
	print "<p><em>South America</em>";
	print "<ul>";
	foreach (@south_american_sites) {
		print "<li><a href=\"http://$_/$file\">$_</a>\n";
		# print "<li><a href=\"ftp://$_/$file\">$_</a>\n";
	}
	print "</ul>";
	print "</td></tr></table>";

	print <<END;
<p>If none of the above sites are fast enough for you, please see our
<a href="http://www.debian.org/mirror/list">complete mirror list</a>.
END
}

print <<END;
<p>Note that in some browsers you will need to tell your browser you want
the file saved to a file. For example, in Netscape or Mozilla, you should
hold the Shift key when you click on the URL.
END

print "<p>The MD5sum for <tt>$filen</tt> is <strong>$md5sum</strong>\n" if ($md5sum);

print <<END;
<div align="center">
<hr>
<p><a href="http://www.debian.org/">Debian Project homepage</a> || 
<a href="http://packages.debian.org/">Packages search page</a>

<p><small>See the Debian <a href="http://www.debian.org/contact">contact page</A>
for information on contacting us.</small>

<p><small>Last modified: Thu Apr  5 20:24:50 UTC 2001
<br>
Copyright &copy; 1997-2001 <A href="http://www.spi-inc.org/">SPI</a>;
See <a href="http://www.debian.org/license">license terms</a></small>
</div>
END

print $input->end_html;
