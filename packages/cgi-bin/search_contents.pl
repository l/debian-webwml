#!/usr/bin/perl -wT
#
# search_contents -- CGI interface to the Contents files on packages.debian.org
#
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000, 2001 Josip Rodin
# Copyright (C) 2001 Adam Heath
#
# use is allowed under the terms of the GNU Public License (GPL)                              
# see http://www.fsf.org/copyleft/gpl.html for a copy of the license

require 5.001;
use strict;
use CGI;
use POSIX;
use URI::Escape;

use lib "../lib";

use Deb::Versions;
use Packages::Search;
use Packages::HTML ();

my $thisscript = "search_contents.pl";
my $HOME = "http://www.debian.org";

# the number of results displayed per each page
my $results_per_page = 40;

$ENV{PATH} = "/bin:/usr/bin";

# Read in all the variables set by the form
my $input = new CGI;

print $input->header;

print Packages::HTML::header( title => 'Package Contents Search Results' ,
			      lang => 'en',
			      title_tag => 'Debian package contents search results',
			      print_title_above => 1 );


# If you want, just print out a list of all of the variables and exit.
# print $input->dump;
# exit;

# parsing and untainting of parameters
my $keyword = $input->param('word');
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
my $case = '';
$case = $input->param('case');
$case = "insensitive" unless (defined $case);
my $searchmode = '';
$searchmode = $input->param('searchmode');
$searchmode = "" unless (defined $searchmode);
my $arch = "i386";
if (defined $input->param('arch') && $input->param('arch') =~ m/^([\w-]+)$/) {
  $arch = $1; # $arch now untainted
  $arch = 'i386' if $arch eq 'all'; # there is no Contents-all file
}
my $page = 1;
$page = $input->param('page') if (defined $input->param('page'));

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

my $cdir = $topdir . "/files/contents";
my $file = "$cdir/$version/Contents-$arch";
my $file_nonus = "$cdir/$version/Contents-$arch.non-US";

# The keyword needs to be modified for the actual search, but left alone
# for future reference, so we create a different variable for searching
my $searchkeyword = $keyword;
$searchkeyword =~ s/[.]/[.]/;

# check if the Contents file is there
if (!-r $file) {
# XXX has to be updated for post-woody
  if ($version eq "stable" and $arch =~ /^(hurd|sh)$/) {
    print "Error: the $arch architecture didn't exist in $version.<br>\n"
         ."Please go back and choose a different distribution.\n";
  } else {
    print "Error: Contents file not found.<br>\n"
         ."If the problem persists, please inform $ENV{SERVER_ADMIN}.\n";
  }
  &printfooter;
  exit;
}

my $timestamp = time() - (-M $file) * 86_400;
my ($sec,$min,$hour,$mday,undef,$year) = gmtime($timestamp);
my $time_str = gmtime($timestamp);
my ($wday, $month) = ($time_str =~ /^(\w{3})\s+(\w+)/);

$year += 1900;
$time_str = sprintf( "$wday, $mday $month $year %02d:%02d:%02d +0000", 
		     $hour, $min, $sec );


# now grep the contents file appropriately
    my $grep;
if ($searchmode eq "filelist") {
  $searchkeyword = lc $searchkeyword; # just in case
  $searchkeyword =~ s/\+/\\\\+/g;
  $grep = "egrep -h /$searchkeyword".'"(,[^ ]+)?$"';
} else {
    $grep = "grep -h ";
    if ($case =~ /^insensitive/) {
	$grep .= "-i ";
    }
    if ($searchmode eq "searchword") {
	$grep .= "$searchkeyword.* ";
    } else {
	$grep .= "\"\\(^\\|/\\)\"$searchkeyword";
	if ($searchmode eq "searchfiles") {
	    $grep .= "\"[ \t]\"";
	} elsif ($searchmode eq "searchfilesanddirs") {
	    $grep .= "\"[/ \t]\"";
	} 
    }
}

my $command = $grep." ".$file." ".$file_nonus;
#print $command."<br>\n"; # just for debugging

my @results = qx( $command );

if (!@results) {
  if ($searchmode eq "filelist") {
    print "Can't find that package, at least not in that distribution and on that architecture.\n";
  } else {
    print "Can't find that file, at least not in that distribution and on that architecture.\n";
  }
  &printfooter;
  exit
}

# multiple-page stuff written by doogie
my $number = 1;
my $start = ($page - 1) * $results_per_page + 1;
my $end = $page * $results_per_page + 1;
my %line;
foreach (@results) {
   $number++;
   if ($start <= $number && $number < $end) {
      $line{$number - $start} = $_;
   }
}

my $numpages = ceil($number / $results_per_page);
my $index_line = "";

for (my $i = 1; $i <= $numpages; $i++) {
	my $url_keyword = uri_escape($keyword);
	$index_line .= "<a href=\"$thisscript?page=$i&amp;word=$url_keyword".
                    "&amp;version=$version&amp;arch=$arch&amp;case=$case".
                    "&amp;searchmode=$searchmode\">$i</a>\n";
	if ($i < $numpages) {
	   $index_line .= " | ";
	}
}

print "<CENTER>$index_line</CENTER>\n" if ($index_line);

print <<END;
<PRE>
<STRONG>FILE                                                       PACKAGE</STRONG>
</PRE>
<HR>
<PRE>
END

for (my $i = 0; $i < $results_per_page; $i++) {
  if (defined($line{$i})) {
    # fixing up some of the directory oddities
    $line{$i} =~ s,non-US/main,non-US,;
    $line{$i} =~ s,non-US/contrib,non-US,;
    $line{$i} =~ s,non-US/non-free,non-US,;
    $line{$i} =~ s,non-free/(.+)$,$1,;
    $line{$i} =~ s,contrib/(.+)$,$1,;
    # make an HTML anchor to the file for the package
    my $list = '';
    if ($line{$i} =~ /(\S*)\s*$/) {
      foreach my $p (split (/,/,$1)) {
	$list .= "," if ($list);
	$list .= sprintf ('<a href="http://packages.debian.org/%s/%s">%s</a>', $version, $p, $p);
      }
      $line{$i} =~ s,(\S*\s*)$,$list,;
    }
    print $line{$i} . "\n";
  }
}

print <<END;
</PRE>
<HR>
END
print "<CENTER>$index_line</CENTER>\n" if ($index_line);
print "<p align=\"left\"><small><i>The used contents file was last updated $time_str</i></small></p>\n";

&printfooter;

exit;

sub printfooter {
print <<END;

<p align="right"><small><i><a href="http://packages.debian.org/">
Packages search page</a></i></small></p>
END

print $input->end_html;
}
