#!/usr/bin/perl -wT
#
# search_packages.pl -- CGI interface to the Packages files on packages.debian.org
#
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000, 2001 Josip Rodin
# Copyright (C) 2001 Adam Heath
# Copyright (C) 2004 Martin Schulze
# Copyright (C) 2004 Frank Lichtenheld
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

my $thisscript = "search_packages.pl";
my $HOME = "http://www.debian.org";
my $ROOT = "";
my $SEARCHPAGE = "http://packages.debian.org/";

$ENV{PATH} = "/bin:/usr/bin";

# Read in all the variables set by the form
my $input = new CGI;

print $input->header;

# If you want, just print out a list of all of the variables and exit.
# print $input->dump;
# exit;

my %params_def = ( keywords => { default => undef, match => '^\s*([-+\@\w\/.:]+)\s*$' },
		   version => { default => 'stable', match => '^(\w+)$',
				replace => { all => '*' } },
		   case => { default => 'insensitive', match => '^(\w+)$' },
		   subword => { default => 0, match => '^(\w+)$' },
		   exact => { default => undef, match => '^(\w+)$' },
		   searchon => { default => 'all', match => '^(\w+)$' },
		   release => { default => 'all', match => '^(\w+)$',
				replace => { all => '*'} },
		   arch => { default => 'any', match => '^(\w+)$',
			     replace => { any => '*'} },
		   );
my %params = Packages::Search::parse_params( $input, \%params_def );

if ($params{errors}{keywords}) {
    print "Error: keyword not valid or missing";
    exit 0;
}
my $keyword = $params{values}{keywords}{final};
my $version = $params{values}{version}{final};
my $case = $params{values}{case}{final};
my $subword = $params{values}{subword}{final};
my $exact = $params{values}{exact}{final};
$exact = !$subword unless defined $exact;
my $searchon = $params{values}{searchon}{final};
my $releases = $params{values}{release}{final};
my $arch = $params{values}{arch}{final};
my $page = $params{values}{page}{final};
my $results_per_page = $params{values}{number}{final};

# for URL construction
my $version_param = $params{values}{version}{no_replace};
my $releases_param = $params{values}{release}{no_replace};
my $arch_param = $params{values}{arch}{no_replace};

# for output
my $keyword_enc = encode_entities $keyword;
my $searchon_enc = encode_entities $searchon;
my $version_enc = encode_entities $version_param;
my $releases_enc = encode_entities $releases_param;
my $arch_enc = encode_entities $arch_param;

print Packages::HTML::header( title => 'Package Search Results' ,
			      lang => 'en',
			      title_tag => 'Debian Package Search Results',
			      print_title_above => 1,
			      print_search_field => 'packages',
			      search_field_values => { 
				  keywords => $keyword_enc,
				  searchon => $searchon,
				  arch => $arch_enc,
				  version => $version_enc,
				  releases => $releases_enc,
				  subword => $subword,
				  exact => $exact,
				  case => $case,
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

my $fdir = $topdir . "/files/flat/$version/$releases";
my $file = "Packages-$arch.*";
my $srcfile = "Sources.*";
my $search_on_sources = 0;

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

    if (@results) {
	@results = split (/\t/, $results[0], 3);
	$desc =  $results[2] if ($#results >= 2);
    }
    return $desc;
}

# The keyword needs to be modified for the actual search, but left alone
# for future reference, so we create a different variable for searching
my $searchkeyword = $keyword;
$searchkeyword =~ s/[.]/[.]/;
if (($searchon eq 'names') || ($searchon eq 'sourcenames')) {
    if ($searchon eq 'sourcenames') {
	$file = $srcfile;
	$search_on_sources = 1;
    }
    if ($exact) {
	$searchkeyword = "\"^".$searchkeyword." \"";
    } else {
	$searchkeyword = "\"^[^ ]*".$searchkeyword."[^ ]* \"";
    }
} else {
    if ($subword != 1) {
	$searchkeyword = "\"\\(^$searchkeyword\\b\\|\\b$searchkeyword\\b\\)\"";
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
    print "Error: Packages/Sources file not found.<br>\n"
         ."If the problem persists, please inform $ENV{SERVER_ADMIN}.\n";
    printf "<p>$file</p>";
  }
  &printfooter;
  exit;
}

# now grep the packages file appropriately
my $grep = "grep -H ";
if ($case =~ /^insensitive/) {
  $grep .= "-i ";
}
$grep .= "$searchkeyword";


my $command = "find $fdir -name $file|xargs ".$grep;
#print "<br>".$command."<br>\n"; # just for debugging

my @results = qx( $command );

my $dist_wording = $version_param eq "all" ? "all distributions"
    : "distribution <em>$version_enc</em>";
my $section_wording = $releases_param eq 'all' ? "all sections"
    : "section <em>$releases_enc</em>";
my $arch_wording = $arch_param eq 'any' ? "all architectures"
    : "architecture <em>$arch_enc</em>";
if (($searchon eq "names") || ($searchon eq 'sourcenames')) {
    my $source_wording = $search_on_sources ? "source " : "";
    my $exact_wording = $exact ? "named" : "that names contain";
    print "<p>You have searched for ${source_wording}packages $exact_wording <em>$keyword_enc</em> in $dist_wording, $section_wording, and $arch_wording.</p>";
} else {
    my $exact_wording = $exact ? "" : " (including subword matching)";
    print "<p>You have searched for <em>$keyword_enc</em> in packages names and descriptions in $dist_wording, $section_wording, and $arch_wording$exact_wording.</p>";
}

if (!@results) {
  my $keyword_esc = uri_escape( $keyword );
  my $printed = 0;
  if (($searchon eq "names") || ($searchon eq 'sourcenames')) {
      if (($version_param eq 'all')
	  && ($arch_param eq 'any')
	  && ($releases_param eq 'all')) {
	  print "<p><strong>Can't find that package.</strong></p>\n";
      } else {
	  print "<p><strong>Can't find that package, at least not in that distribution ".( $search_on_sources ? "" : " and on that architecture" ).".</strong></p>\n";
      }

    if ($exact) {
	$printed = 1;
	print "<p>You have searched only for exact matches of the package name. You can try to search for <a href=\"$thisscript?exact=0&amp;searchon=$searchon&amp;version=$version_param&amp;case=$case&amp;release=$releases_param&amp;keywords=$keyword_esc&amp;arch=$arch_param\">package names that contain your search string</a>.</p>";
    }
  } else {
      if (($version_param eq 'all')
	  && ($arch_param eq 'any')
	  && ($releases_param eq 'all')) {
	  print "<p><strong>Can't find that string.</strong></p>\n";
      } else {
	  print "<p><strong>Can't find that string, at least not in that distribution ($version_param, section $releases_param) and on that architecture ($arch_param).</strong></p>\n";
      }

    unless ($subword) {
	$printed = 1;
        print "<p>You have searched only for words exactly matching your keywords. You can try to search <a href=\"$thisscript?subword=1&amp;searchon=$searchon&amp;version=$version_param&amp;case=$case&amp;release=$releases_param&amp;keywords=$keyword_esc&amp;arch=$arch_param\">allowing subword matching</a>.</p>";
    }
  }
  print "<p>".( $printed ? "Or you" : "You" )." can try a different search on the <a href=\"http://packages.debian.org/#search_packages\">Packages search page</a>.</p>";

  &printfooter;
  exit
}

my (%pkgs, %sect, %part, %desc, %binaries);
my (@colon, $package, $pkg_t, $section, $ver, $foo, $binaries);

unless ($search_on_sources) {
    foreach my $line (@results) {
	@colon = split (/:/, $line);
	($pkg_t, $section, $ver, $arch, $foo) = split (/ /, $#colon >1 ? $colon[1].":".$colon[2]:$colon[1], 5);
	$section =~ s,^(non-free|contrib)/,,;
	$section =~ s,^non-US.*$,non-US,,;
	my ($dist,$part,undef) = $colon[0] =~ m,.*/([^/]+)/([^/]+)/Packages-([^\.]+)\.,; #$1=stable, $2=main, $3=alpha

	($package) = $pkg_t =~ m/^(.+)/; # untaint
	$pkgs{$package}{$dist}{$ver}{$arch} = 1;
	$sect{$package}{$dist}{$ver} = $section;
	$part{$package}{$dist}{$ver} = $part unless $part eq 'main';

	$desc{$package}{$dist}{$ver} = find_desc ($package, $dist, $part) if (! exists $desc{$package}{$dist}{$ver});

    }

    my ( $start, $end) = multipageheader( scalar keys %pkgs );
    my $count = 0;

    foreach my $pkg (sort keys %pkgs) {
	$count++;
	next if $count < $start or $count > $end;
	printf "<h3>Package %s</h3>\n", $pkg;
	print "<ul>\n";
	foreach $ver (('stable','testing','unstable','experimental')) {
	    if (exists $pkgs{$pkg}{$ver}) {
		my @versions = version_sort keys %{$pkgs{$pkg}{$ver}};
		my $part_str = "";
		if ($part{$pkg}{$ver}{$versions[0]}) {
			$part_str = "[<span style=\"color:red\">$part{$pkg}{$ver}{$versions[0]}</span>]";
		}
		printf "<li><a href=\"$ROOT/%s/%s/%s\">%s</a> (%s): %s   %s\n",
		$ver, $sect{$pkg}{$ver}{$versions[0]}, $pkg, $ver, $sect{$pkg}{$ver}{$versions[0]}, $desc{$pkg}{$ver}{$versions[0]}, $part_str;
		
		foreach my $v (@versions) {
		    printf "<br>%s: %s\n",
		    $v, join (" ", (sort keys %{$pkgs{$pkg}{$ver}{$v}}) );
		}
		print "</li>\n";
	    }
	}
	print "</ul>\n";
    }
} else {
    foreach my $line (@results) {
	chomp($line);
	@colon = split (/:/, $line);
	($package, $section, $ver, $binaries) = split (/ /, $#colon >1 ? $colon[1].":".$colon[2]:$colon[1], 4);
	$section =~ s,^(non-free|contrib)/,,;
	$section =~ s,^non-US.*$,non-US,,;
	$colon[0] =~ m,.*/([^/]+)/([^/]+)/Sources\.,; #$1=stable, $2=main
	
	my ($suite, $part) = ($1, $2);
	$pkgs{$package}{$suite} = $ver;
	$sect{$package}{$suite}{source} = $section;
	$part{$package}{$suite}{source} = $part unless $part eq 'main';

	$binaries{$package}{$suite} = [ sort split( /\s*,\s*/, $binaries ) ];

    }

    my ( $start, $end) = multipageheader( scalar keys %pkgs );
    my $count = 0;

    foreach my $pkg (sort keys %pkgs) {
	$count++;
	next if ($count < $start) or ($count > $end);
	printf "<h3>Source package %s</h3>\n", $pkg;
	print "<ul>\n";
	foreach $ver (('stable','testing','unstable','experimental')) {
	    if (exists $pkgs{$pkg}{$ver}) {
		my $part_str = "";
		if ($part{$pkg}{$ver}{source}) {
			$part_str = "[<span style=\"color:red\">$part{$pkg}{$ver}{source}</span>]";
		}
		printf "<li><a href=\"$ROOT/%s/source/%s\">%s</a> (%s): %s   %s", $ver, $pkg, $ver, $sect{$pkg}{$ver}{source}, $pkgs{$pkg}{$ver}, $part_str;
		
		print "<br>Binary packages: ";
		my @bp_links;
		foreach my $bp (@{$binaries{$pkg}{$ver}}) {
		    my $bp_link = sprintf "<a href=\"$thisscript?exact=1&amp;searchon=names&amp;version=$ver&amp;keywords=%s\">%s</a>", uri_escape( $bp ),  $bp;
		    push @bp_links, $bp_link;
		}
		print join( ", ", @bp_links );
	    print "</li>\n";
	}
    }
    print "</ul>\n";
}
}



print "<hr>\n";
&printfooter;

exit;

sub multipageheader {
    my $no_results = shift;

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

    print "<p>Found <em>$no_results</em> matching packages,";
    if ($end == $start) {
	print " displaying package $end.</p>";
    } else {
	print " displaying packages $start to $end.</p>";
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
	    push @resperpagelinks, resperpagelink($input, \%params,"all");
	}
	print join( " | ", @resperpagelinks )."</p>";
    }
    return ( $start, $end );
}

sub printfooter {
print <<END;

<p align="right"><small><i><a href="$SEARCHPAGE">
Packages search page</a></i></small></p>
END

print $input->end_html;
}
