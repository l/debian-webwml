#!/usr/bin/perl -w
#
# search_packages.pl -- CGI interface to the Packages files on packages.debian.org
#
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000, 2001 Josip Rodin
# Copyright (C) 2001 Adam Heath
# Copyright (C) 2004 Martin Schulze
#
# use is allowed under the terms of the GNU Public License (GPL)                              
# see http://www.fsf.org/copyleft/gpl.html for a copy of the license

require 5.001;
use strict;
use CGI;
use POSIX;
use URI::Escape;

my $thisscript = "search_packages.pl";
my $HOME = "http://www.debian.org";

$ENV{PATH} = "/bin:/usr/bin";

# Read in all the variables set by the form
my $input = new CGI;

print $input->header;
print $input->start_html(-title=>'Debian package search results',
			 -text=>'#000000',
			 -bgcolor=>'#FFFFFF',
			 -link=>'#0000FF',
			 -vlink=>'#800080',
			 -alink=>'#FF0000');

# If you want, just print out a list of all of the variables and exit.
# print $input->dump;
# exit;

# parsing and untainting of parameters
my $keyword = $input->param('keywords');
unless (defined $keyword) {
   print "No keyword given for search.";
   exit 0;
}
$keyword =~ s,^/,,;
if ($keyword =~ /^([-+\@\w\/.:]+)$/) {
   $keyword = $1;                          # $keyword now untainted
} else {
   print "Error: \"$keyword\" is not a valid search request";
   exit 0;
}
(my $version) = $input->param('version') =~ m/^(\w+)$/; # $version now untainted
$version = "stable" unless (defined $version);
$version = '*' if ($version eq 'all');
my $case = '';
$case = $input->param('case');
$case = "insensitive" unless (defined $case);
my $subword = $input->param('subword');
$subword = 0 unless (defined $subword);
my $searchon = $input->param('searchon');
$searchon = 'all' unless (defined $searchon);
my $exact = $input->param('exact');
$exact = 0 unless (defined $exact);
my $releases = $input->param('release');
$releases = '*' unless (defined $releases);
$releases = '*' if ($releases eq 'all');

my $arch = "*";
if (defined $input->param('arch') && $input->param('arch') =~ m/^([\w-]+)$/) {
  $arch = $1; # $arch now untainted
}
$arch = '*' if ($arch eq 'any');

# read the configuration
my $topdir;
if (!open (C, "../config.sh")) {
    printf "\nInternal Error: Cannot open configuration file.\n\n";
    exit 0;
}
while (<C>) {
    $topdir = $1 if (/^\s*topdir="?(.*)"?\s*$/);
}
close (C);

my $fdir = $topdir . "/files/flat/$version/$releases";
my $file = "Packages-$arch.*";

sub find_desc
{
    my $pkg = shift;
    my $suite = shift;
    my $part = shift;
    my $desc = '';

    $pkg =~ s/[.]/[.]/;

    my $cmd = sprintf ("/bin/grep '^%s\t' %s/files/flat/%s/%s/Description",
		      $pkg, $topdir, $suite, $part);

    my @results = qx( $cmd );

    return @results ? $results[0] : "";
}

# The keyword needs to be modified for the actual search, but left alone
# for future reference, so we create a different variable for searching
my $searchkeyword = $keyword;
$searchkeyword =~ s/[.]/[.]/;
if ($searchon eq 'names') {
    if ($exact) {
	$searchkeyword = "\"^".$searchkeyword." \"";
    } else {
	$searchkeyword = "\"^[^ ]*".$searchkeyword."[^ ]* \"";
    }
} else {
    if ($subword != 1) {
	$searchkeyword = "\"\\(^\\| \\)".$searchkeyword." \"";
    }
}

# check if the Packages files are there
my @files = glob ("$fdir/$file");
if ($#files == -1) {
# XXX has to be updated for post-woody
  if ($version eq "stable" and $arch =~ /^(hurd|sh)$/) {
    print "Error: the $arch architecture didn't exist in $version.<br>\n"
         ."Please go back and choose a different distribution.\n";
  } else {
    print "Error: Packages file not found.<br>\n"
         ."If the problem persists, please inform $ENV{SERVER_ADMIN}.\n";
    printf "<p>$file</p>";
  }
  &printfooter;
  exit;
}

print <<END;

<table border="0" cellpadding="3" cellspacing="0" width="100%" summary="">
<tr>
<td align="left" valign="middle">
<a href="$HOME/"><img src="$HOME/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="" width="50" height="61"></a>
<a href="$HOME/" rel="start"><img src="$HOME/Pics/debian.jpg" border="0" hspace="0" vspace="0" alt="Debian Project" width="179" height="61"></a>
</td>
<td align="right" valign="middle">
<h1>Package Search Results</h1>
</td>
</tr>
</table>
<table bgcolor="#DF0451" border="0" cellpadding="0" cellspacing="0" width="100%" summary="">
<tr>
<td valign="top">
<img src="$HOME/Pics/red-upperleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
<td rowspan="2" align="center">
<a href="$HOME/intro/about"><img src="$HOME/Pics/about.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="About Debian" width="58" height="18"></a>
<a href="$HOME/News/"><img src="$HOME/Pics/news.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="News" width="53" height="18"></a>
<a href="$HOME/distrib/"><img src="$HOME/Pics/getting.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Getting Debian" width="117" height="18"></a>
<a href="$HOME/support"><img src="$HOME/Pics/support.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Support" width="72" height="18"></a>
<a href="$HOME/devel/"><img src="$HOME/Pics/devel.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Developers'&nbsp;Corner" width="105" height="18"></a>
<a href="$HOME/sitemap" rel="contents"><img src="$HOME/Pics/sitemap.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Site map" width="76" height="18"></a>
<a href="http://search.debian.org/"><img src="$HOME/Pics/search.en.gif" align="middle" border="0" hspace="4" vspace="7" alt="Search" width="64" height="18"></a>
</td>
<td valign="top">
<img src="$HOME/Pics/red-upperright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
</td>
</tr>
<tr>
<td valign="bottom">
<img src="$HOME/Pics/red-lowerleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
</td>
<td valign="bottom">
<img src="$HOME/Pics/red-lowerright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
</tr>
</table>
END

# now grep the packages file appropriately
my $grep = "grep -H ";
if ($case =~ /^insensitive/) {
  $grep .= "-i ";
}
$grep .= "$searchkeyword";


my $command = "find $fdir -name $file|xargs ".$grep;
# print "<br>".$command."<br>\n"; # just for debugging

my @results = qx( $command );

if (!@results) {
  if ($searchon eq "names") {
    print "<p><strong>Can't find that package, at least not in that distribution and on that architecture.</strong></p>\n";
  } else {
    print "<p><strong>Can't find that string, at least not in that distribution and on that architecture.</strong></p>\n";
  }
  &printfooter;
  exit
}

my (%pkgs, %sect, %desc);
my (@colon, $package, $section, $ver, $foo);
foreach my $line (@results) {
    @colon = split (/:/, $line);
    ($package, $section, $ver, $foo) = split (/ /, $#colon >1 ? $colon[1].":".$colon[2]:$colon[1], 4);
    $section =~ s,^(non-free|contrib)/,,;
    $section =~ s,^non-US.*$,non-US,,;
    $colon[0] =~ m,.*/([^/]+)/([^/]+)/Packages-([^\.]+)\.,; #$1=stable, $2=main, $3=alpha

    $pkgs{$package}{$1}{$ver}{$3} = 1;
    $sect{$package}{$1} = $section;

    $desc{$package}{$1} = find_desc ($package, $1, $2) if (! exists $desc{$package}{$1});

}

foreach my $pkg (sort keys %pkgs) {
    printf "<h3>Package %s</h3>\n", $pkg;
    print "<ul>\n";
    foreach $ver (('stable','testing','unstable','experimental')) {
	if (exists $pkgs{$pkg}{$ver}) {
	    printf "<li><a href=\"http://packages.debian.org/%s/%s/%s\">%s</a> (%s): %s\n",
	    $ver, $sect{$pkg}{$ver}, $pkg, $ver, $sect{$pkg}{$ver}, $desc{$pkg}{$ver};

	    foreach my $v (sort keys %{$pkgs{$pkg}{$ver}}) {
		printf "<br>%s: %s\n",
		$v, join (" ", (sort keys %{$pkgs{$pkg}{$ver}{$v}}) );
	    }
	}
    }
    print "</ul>\n";
}

print "<hr>\n";
&printfooter;

exit;

sub printfooter {
print <<END;

<p align=right><small><i><a href="http://packages.debian.org/">
Packages search page</a></i></small></p>
END

print $input->end_html;
}
