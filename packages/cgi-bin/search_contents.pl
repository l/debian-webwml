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

my $thisscript = "search_contents.pl";

# the number of results displayed per each page
my $results_per_page = 40;

$ENV{PATH} = "/bin:/usr/bin";

# Read in all the variables set by the form
my $input = new CGI;

print $input->header;
print $input->start_html(-title=>'Debian package contents search results');

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
}
my $page = 1;
$page = $input->param('page') if (defined $input->param('page'));

my $cdir = "/org/packages.debian.org/contents";
my $file = "$cdir/$version/Contents-$arch";
my $file_nonus = "$cdir/$version/non-US/Contents-$arch";

# The keyword needs to be modified for the actual search, but left alone
# for future reference, so we create a different variable for searching
my $searchkeyword = $keyword;
$searchkeyword =~ s/[.]/[.]/;

# check if the Contents file is there
if (!-f $file) {
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

print <<END;
<h1>
<img src="http://www.debian.org/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="" width="50" height="61">
<img src="http://www.debian.org/Pics/debian.jpg" border="0" hspace="0" vspace="0" alt="Debian" width="179" height="61">
package contents search results
</h1>
END

# TODO: tail +32 the contents file in order to skip the opening lines
# not sure if running zcat | tail | grep will waste too much resources

# now grep the contents file appropriately
my $grep = "grep -h ";
if ($case =~ /^insensitive/) {
  $grep .= "-i ";
}
$grep .= "$searchkeyword";
if ($searchmode eq "searchfiles") {
  $grep .= '"[^/ ]"';
} elsif ($searchmode eq "searchfilesanddirs") {
  $grep .= '"[^ ]"';
} elsif ($searchmode eq "filelist") {
  $searchkeyword = lc $searchkeyword; # just in case
  $searchkeyword =~ s/\+/\\\\+/g;
  $grep = "zegrep -h /$searchkeyword".'"(,[^ ]+)?$"';
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
	$index_line .= "<a href=\"$thisscript?page=$i&word=$keyword".
                    "&version=$version&arch=$arch&case=$case".
                    "&searchmode=$searchmode\">$i</a>\n";
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
    # hopefully this won't ruin (too m)any real file names
    $line{$i} =~ s,non-US/,non-us/,g;
    # check if multiple packages own the file
    if ($line{$i} !~ /(\S+,\S+)$/) {
      # make an HTML anchor to the file for the package
      $line{$i} =~ s,(\S*)$,<a href="http://packages.debian.org/$version/$1.html">$1</a>,;
    } else {
      # make an HTML anchor just to the file for the first package
      # some real Perl hacker will have to fix this :) -- Joy
      $line{$i} =~ s#,(\S[^,]+)$#,<a href="http://packages.debian.org/$version/$1.html">$1</a>#;
    }
    print $line{$i} . "\n";
  }
}

print <<END;
</PRE>
<HR>
END
print "<CENTER>$index_line</CENTER>\n" if ($index_line);
&printfooter;

exit;

sub printfooter {
print <<END;

<p align=right><small><i><a href="http://packages.debian.org/">
Packages search page</a></i></small></p>
END

print $input->end_html;
}
