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
use CGI qw( -oldstyle_urls );
use POSIX;
use URI::Escape;
use HTML::Entities;

use lib "../lib";

use Deb::Versions;
use Packages::Search qw( :all );
use Packages::HTML ();

my $thisscript = "search_contents.pl";
my $HOME = "http://www.debian.org";

$ENV{PATH} = "/bin:/usr/bin";

# Read in all the variables set by the form
my $input = new CGI;

print $input->header;

# If you want, just print out a list of all of the variables and exit.
# print $input->dump;
# exit;


my %params_def = ( word => { default => undef, match => '^\s*([-+\@\w\/.:]+)\s*$' },
		   version => { default => 'stable', match => '^(\w+)$' },
		   case => { default => 'insensitive', match => '^(\w+)$' },
		   searchmode => { default => "" },
		   searchon => { default => 'all', match => '^(\w+)$' },
		   arch => { default => 'i386', match => '^([\w-]+)$',
			     replace => { all => 'i386'} },
		   );
my %params = Packages::Search::parse_params( $input, \%params_def );

my $keyword = $params{values}{word}{final};
unless (defined $keyword) {
   print "No keyword given for search.";
   exit 0;
}
$keyword =~ s,^/,,;

my $version = $params{values}{version}{final};
my $case = $params{values}{case}{final};
my $searchmode = $params{values}{searchmode}{final};
my $arch = $params{values}{arch}{final};
my $page = $params{values}{page}{final};
my $results_per_page = $params{values}{number}{final};

my $keyword_enc = encode_entities $keyword;
my $version_enc = encode_entities $version;
my $arch_enc = encode_entities $arch;

print Packages::HTML::header( title => 'Package Contents Search Results' ,
			      lang => 'en',
			      title_tag => 'Debian package contents search results',
			      print_title_above => 1,
			      print_search_field => 'contents',
			      search_field_values => { 
				  keyword => $keyword_enc,
				  searchmode => $searchmode,
			      },
			      );


# read the configuration
my $topdir;
if (!open (C, "../config.sh")) {
    print "\nInternal Error: Cannot open configuration file.\n\n";
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

if ($searchmode eq "filelist") {
	print "<p>You have searched for the contents of <em>$keyword_enc</em> in <em>$version_enc</em>, architecture <em>$arch_enc</em>.<br>";
} else {
	print "<p>You have searched for <em>$keyword_enc</em> in <em>$version_enc</em>, architecture <em>$arch_enc</em>.<br>";
}

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
my $no_results = @results;
my ($start, $end);
if ($results_per_page =~ /^all$/i) {
	$start = 1;
	$end = $no_results;
	$results_per_page = $no_results;
} else {
	$start = Packages::Search::start( \%params );
	$end = Packages::Search::end( \%params );
	if ($end > $no_results) { $end = $no_results; }
}

if ($searchmode eq "filelist") {
    print "Package contains $no_results files, displaying files $start to $end.</p>";
} else {
    print "Found <em>$no_results</em> matching files/directories, displaying files/directories $start to $end.</p>";
}

my $number = 0;
my %line;
foreach (@results) {
   $number++;
   if (($start <= $number) && ($number <= $end)) {
      $line{$number - $start} = $_;
   }
}

my $index_line;
if ($no_results > $results_per_page) {

    $index_line = prevlink($input,\%params)." | ".indexline( $input, \%params, $no_results)." | ".nextlink($input,\%params, $no_results);

    print "<center>$index_line</center>";
}

if ($no_results > 100) {
    print "<p>Results per page: ";
    my @resperpagelinks;
    for (50, 100, 200) {
        if ($results_per_page == $_) {
            push @resperpagelinks, $_;
        } else {
            push @resperpagelinks, resperpagelink($input,\%params,$_);
        }
    }
    if ($params{values}{number}{final} =~ /^all$/i) {
    	push @resperpagelinks, "all";
    } else {
	push @resperpagelinks, resperpagelink($input, \%params, "all");
    }
    print join( " | ", @resperpagelinks )."</p>";
}

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
print "<center>$index_line</center>" if $index_line;
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
