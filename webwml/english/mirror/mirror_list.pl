#!/usr/bin/perl -w
# copyright 1998 by James Treacy
require 5.001;

use Getopt::Long;
%opthash = (
	"mirror|m=s" => \$mirror_source,
	"type|t=s" => \$output_type,
	"help|h!" => \$help,
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
	elsif ($line =~ /^Alias(es)?:\s*(.*)\s*$/is) {
		@tmp = split("\n", $2);
		$mirror{$site}{aliases} = [ @tmp ];
	}
	elsif ($line=~ /^((Archive|nonUS|WWW|Incoming|CDimage|Old)-(\w*)):\s*(.*)\s*$/i) {
		$type = lc $1;
		$mirror{$site}{method}{$type} = $4;
		if (!defined($longest{$type}) || length($4) > $longest{$type}) {
			$longest{$type} = length($4);
		}
	}
	elsif ($line =~ /^Includes:\s*(.*)\s*$/i) {
		@tmp = split(" ", $1);
		$mirror{$site}{includes} = [ @tmp ];
	}
	elsif ($line =~ /^Sponsor:\s*(.*)\s*$/i) {
		push @{ $mirror{$site}{sponsor} }, $1;
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
	print "<h3 align=\"center\">" if $html;
	print "\n\n                   " if (!$html);
	print "Secondary mirrors of the Debian archive";
	print "\n                   ---------------------------------------\n\n" if (!$html);
	print "</h3>\n\n" if $html;
	print "\n<pre><small>\n" if $html;
	# $tmp = "%-$longest{site}s %-$longest{'archive-ftp'}s%-$longest{'archive-http'}sPORTS MIRRORED\n";
	# printf $tmp, "HOSTNAME", "FTP", "HTTP";
	# $tmp =~ s/PORTS MIRRORED/--------------/;
	# printf $tmp, "--------", "---", "----";
	$tmp = "%-$longest{site}s %-$longest{'archive-ftp'}s%s\n";
	print "<strong>" if $html;
	printf $tmp, "HOSTNAME", "FTP", "HTTP";
	printf $tmp, "--------", "---", "----";
	print "</strong>" if $html;
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
	print "</small></pre>" if $html;
}


sub intro {
	print "<h1 align=\"center\">" if $html;
	print "                 " if (!$html);
	print "Debian GNU/Linux - worldwide mirror sites";
	print "</h1>" if $html;
	print "\n                 -----------------------------------------\n" if (!$html);
	print "\n";

	print "<p>" if $html;
	print <<END;
This file is broken up into two separate mirror listings: Primary and
Secondary mirror sites.  The definitions are as follows:

END
	print "<p>" if $html;
	print <<END;
END
	if ($html) {
          print <<END;
  A <strong>Primary mirror</strong> site has good bandwidth, is available 24 hours a day,
  and has an easy to remember name of the form ftp.&lt;country&gt;.debian.org.
END
	} else {
	  print <<END;
  A Primary mirror site has good bandwidth, is available 24 hours a day,
  and has an easy to remember name of the form ftp.<country>.debian.org.
END
	}

	print <<END;
  Additionally, most of them are updated automatically after updates to the
  Debian archive. The Debian archive on those sites is normally available
  using both FTP and HTTP protocols.

END
	print "<p>" if $html;
	if ($html) {
          print <<END;
  A <strong>Secondary mirror</strong> site may have restrictions on what they mirror (due to
END
	} else {
	  print <<END;
  A Secondary mirror site may have restrictions on what they mirror (due to
END
	}
	print <<END;
  space restrictions). Just because a site is Secondary doesn't necessarily
  mean it'll be any slower or less up to date than a Primary site.

END
	print "<p>" if $html;
	print <<END;
Use the site closest to you for the fastest downloads possible whether it is
END
	if ($html) {
          print "
a primary or secondary site. The program
<a href=\"http://packages.debian.org/stable/net/netselect.html\">
<em>netselect</em></a> can be used to\n";
	} else {
	  print "a primary or secondary site. The program `netselect' can be used to\n";
	}
	print <<END;
determine the fastest of a list of sites.

END
	print "<p>" if $html;
	print "The authoritative copy of this list can always be found at:\n";
	print "<a href=\"http://ftp.debian.org/debian/README.mirrors\">" if $html;
	print "                 http://ftp.debian.org/debian/README.mirrors";
	print "</a>.<br>" if $html;
	print "\n";

	print <<END;
If you know of any mirrors that are missing from this list,
please have the site maintainer fill out the form at:
END
	print "<a href=\"http://www.debian.org/mirror/submit\">" if $html;
	print "                     http://www.debian.org/mirror/submit";
	print "</a>. " if $html;
	print "<br>\n";

	print <<END;
Everything else you want to know about Debian mirrors:
END
	print "<a href=\"http://www.debian.org/mirror/\">" if $html;
	print "                        http://www.debian.org/mirror/";
	print "</a>.<br>" if $html;
	print "\n";
}

sub primary_mirrors {
  if ($html) {
    print <<END;

<h2 align="center">Primary Debian Mirror Sites</h2>

<table border="0" align="center">
<tr>
  <th>Country</th>
  <th>Site</th>
  <th><b>Debian&nbsp;archive</b></th>
  <th><b>Debian&nbsp;non-US&nbsp;archive</b></th>
</tr>
<tr><td colspan="4"><hr></td></tr>
END
  } else {
    print <<END;


                         Primary Debian Mirror Sites
                         ---------------------------

 Country         Site                Debian archive    Debian non-US archive
 ---------------------------------------------------------------------------
END
  }
  foreach $country (sort keys %countries) {
    foreach $site (sort @{ $countries{$country} }) {
      if ($site =~ /^ftp\d?\...\.debian.org$/ || $site =~ /^http\.us\.debian\.org$/) {
        (my $countryplain = $country) =~ s/^.. //;
	if ($html) {
	  $countryplain =~ s/ /&nbsp;/;
	  print <<END;
<tr>
  <td width="25%">$countryplain</td>
  <td width="25%" align="center"><code>$site</code></td>
  <td width="25%"><a href="ftp://$site$mirror{$site}{method}{'archive-ftp'}">$mirror{$site}{method}{'archive-ftp'}</a></td>
END
          if (defined $mirror{$site}{method}{'nonus-ftp'}) {
            print <<END;
  <td width="25%"><a href="ftp://$site$mirror{$site}{method}{'nonus-ftp'}">$mirror{$site}{method}{'nonus-ftp'}</a></td>
END
          } else {
            print <<END;
  <td width="25%">Not mirrored.</td>
END
          }
          print <<END;
</tr>
END
        } else {
          if (defined $mirror{$site}{method}{'nonus-ftp'}) {
            $nonusftp = $mirror{$site}{method}{'nonus-ftp'};
          } else {
            $nonusftp = "Not mirrored."
          }
          printf " %-14s  %-18s  %-16s  %s\n", $countryplain, $site, $mirror{$site}{method}{'archive-ftp'}, $nonusftp;
#          print <<END;
# $countryplain	-   $site		$mirror{$site}{method}{'archive-ftp'}	$mirror{$site}{method}{'nonus-ftp'}
#END
        }
      }
    }
  }
  print "</table>\n" if $html;
}

# meant to be output into a file which is then included into a .wml file
# and processed by WML
sub primary_mirror_sponsors {
  return unless $html;
  print <<END;
<tr><td colspan="3"><hr></td></tr>
END
  foreach $country (sort keys %countries) {
    foreach $site (sort @{ $countries{$country} }) {
      if ($site =~ /^ftp\d?\...\.debian.org$/) {
        (my $countrycode = $country) =~ s/^(..).*/$1/;
	print <<END;
<tr>
  <td valign="top"><${countrycode}c></td>
  <td valign="top" align="center"><a href="ftp://$site$mirror{$site}{method}{'archive-ftp'}">$site</a></td>
  <td>
END
	if ($site eq "ftp.us.debian.org") {
	  die unless exists $mirror{$site}{includes}; # must be an error
	  my $numsubsites = @{ $mirror{$site}{includes} };
	  my $snum = 0;
	  foreach my $subsite (@{ $mirror{$site}{includes} }) {
	    die "$subsite\n" unless exists $mirror{$subsite}{sponsor}; # must be an error
	    my $numsponsors = @{ $mirror{$subsite}{sponsor} };
	    my $num = 0;
	    foreach my $sponsor (@{ $mirror{$subsite}{sponsor} }) {
	      if ($sponsor =~ /^(.+) (http:.*)$/) {
	        $sponsorname = $1;
	        $sponsorurl = $2;
	      }
	      print "<a href=\"$sponsorurl\">$sponsorname</a>";
	      $num++;
	      print ", " unless ($num >= $numsponsors);
	    }
	    $snum++;
	    print ", " unless ($snum >= $numsubsites);
	  }
	} else {
	  die "$site\n" unless exists $mirror{$site}{sponsor}; # must be an error
	  my $numsponsors = @{ $mirror{$site}{sponsor} };
	  my $num = 0;
	  foreach my $sponsor (@{ $mirror{$site}{sponsor} }) {
	    if ($sponsor =~ /^(.+) (http:.*)$/) {
	      $sponsorname = $1;
	      $sponsorurl = $2;
	    }
	    print "<a href=\"$sponsorurl\">$sponsorname</a>";
	    $num++;
	    print ", " unless ($num >= $numsponsors);
	  }
	}
        print <<END;

  </td>
</tr>
END
      }
    }
  }
  print "</table>\n";
}

# meant to be output into a file which is then included into a .wml file
# and processed by WML
sub cdimage_mirrors {
  my $which = shift;
  return unless $html;
  print "<ul>\n";
  foreach $country (sort keys %countries) {
    foreach $site (sort @{ $countries{$country} }) {
      (my $countrycode = $country) =~ s/^(..) .*/$1/;
      if ($which eq "httpftp") {
        if (defined $mirror{$site}{method}{'cdimage-ftp'} ||
            defined $mirror{$site}{method}{'cdimage-http'}) {
          print "<li><${countrycode}c>: $site: ";
          if (defined $mirror{$site}{method}{'cdimage-ftp'}) {
            print <<END;
    <a href="ftp://$site$mirror{$site}{method}{'cdimage-ftp'}">FTP</a>
END
          }
          if (defined $mirror{$site}{method}{'cdimage-http'}) {
            print <<END;
    <a href="http://$site$mirror{$site}{method}{'cdimage-http'}">HTTP</a>
END
          }
          print "</li>\n";
        }
      } elsif ($which eq "rsync") {
        if (defined $mirror{$site}{method}{'cdimage-rsync'}) {
          print <<END;
  <li><${countrycode}c>: $site:
    <font color="#6b1300">rsync $site\:\:$mirror{$site}{method}{'cdimage-rsync'}</font>
  </li>
END
        }
      }
    }
  }
  print "</ul>\n";
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

<p>This is a complete list of mirrors of Debian. For each site, the different types
of material available are listed, along with the access method for each type.

<p>The following things are mirrored:
<dl>
<dt><strong>Packages</strong>
	<dd>The Debian package pool.
<dt><strong>Non-US packages</strong>
	<dd>A pool for Debian packages that can't be distributed in the US
	due to software patents or use of encryption.
<dt><strong>CD Images</strong>
	<dd>Official Debian CD Images. See
	<a href="http://www.debian.org/CD/">http://www.debian.org/CD/</a> for details.
<dt><strong>WWW pages</strong>
	<dd>The Debian web pages.
</dl>

<p>The following access methods are possible:
<dl compact>
<dt><strong>HTTP</strong>
	<dd>Standard web access, but it can be used for downloading files.
<dt><strong>FTP</strong>
	<dd>The file transfer protocol.
<dt><strong>rsync</strong>
	<dd>An efficient means of mirroring.
<dt><strong>NFS</strong>
	<dd>Network file system (if you don't know what it is, you don't need it).
</dl>

<p>The 'Type' entry is one of:
<dl compact>
<dt><strong>leaf</strong>
	<dd>These comprise the bulk of the mirrors.
<dt><strong>Push-Secondary</strong>
	<dd>These sites mirror directly from a Push-Primary site, using push
	mirroring.
<dt><strong>Push-Primary</strong>
	<dd>These sites mirror directly from the master archive site (which
	is not publicly accessible), using push mirroring.
</dl>
(See <a href="http://www.debian.org/mirror/push_mirroring">the page on push
mirroring</a> for details on that.)
END

	print <<END;

<p>The authoritative copy of this list can always be found at:
<a href="http://www.debian.org/mirror/mirrors_full">
http://www.debian.org/mirror/mirrors_full</a>.
<br>
Everything else you want to know about Debian mirrors:
<a href="http://www.debian.org/mirror/">http://www.debian.org/mirror/</a>.
<br>
END
}

sub full_listing {
	print "<pre>\n";
	foreach $country (sort keys %countries) {
		if ($html) {
			print "\n<strong>$country</strong>\n";
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
				my $display = $_;
				$display =~ s/archive-/Packages /;
				$display =~ s/nonus-/Non-US packages /;
				$display =~ s/www-/WWW pages /;
				$display =~ s/cdimage-/CD Images /;
				$display =~ s/old-/Old releases /;
				$display =~ s/ftp/over FTP/;
				$display =~ s/http/over HTTP/;
				$display =~ s/nfs/over NFS/;
				$display =~ s/rsync/over rsync/;
				if (/http/) {
					print $display.":	<a href=\"http://$site$mirror{$site}{method}{$_}\">$mirror{$site}{method}{$_}</a>\n";
				}
				elsif (/ftp/) {
					print $display.":	<a href=\"ftp://$site$mirror{$site}{method}{$_}\">$mirror{$site}{method}{$_}</a>\n";
				}
				else {
					print $display.":	".$mirror{$site}{method}{$_}."\n";
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

sub readmenonus {
	print <<_END_;

                      Debian GNU/Linux non-US packages
                      --------------------------------

United States laws place restrictions on the export of certain defense
articles, which, unfortunately, includes some types of cryptographic software.
PGP and SSH, among others, fall into this category.  It is legal however, to
import such software into the US.

To prevent anyone from taking unnecessary legal risks, some Debian
packages are only available from a site in Leiden, The Netherlands.
Available access methods are:
	ftp://non-us.debian.org/debian-non-US/
	http://non-us.debian.org/debian-non-US/
	rsync://non-us.debian.org/debian-non-US/  (limited)

To use these packages with APT, you can add the following lines to your
sources.list file:

  deb http://non-us.debian.org/debian-non-US stable/non-US main contrib non-free
  deb-src http://non-us.debian.org/debian-non-US stable/non-US main contrib non-free

Read sources.list(5) on your Debian system for more information.

-------------------------------------------------------------------------------

Mirrors of non-us.debian.org are normally located outside of the US.
If they are located within the US they should be registered with the
US government. This is the official list:

_END_
	my $hasmirrors = 0; my $nonuscount = 0;
	foreach $country (sort keys %countries) {
		$hasmirrors = 0;
		foreach $id (@{ $countries{$country} }) {
		  $hasmirrors++ if (defined $mirror{$id}{method}{'nonus-ftp'} || defined $mirror{$id}{method}{'nonus-http'});
		}
		($countryplain = $country) =~ s/^.. //;
		if ($hasmirrors) { print "\n$countryplain:\n"; } else { next; }
		foreach $id (@{ $countries{$country} }) {
		  if (defined $mirror{$id}{method}{'nonus-ftp'}) {
		    print "  ftp://$id$mirror{$id}{method}{'nonus-ftp'}";
		    if (defined $mirror{$id}{method}{'nonus-http'}) {
		      print "\n    http://$id$mirror{$id}{method}{'nonus-http'}";
		    }
		    print "\n\n";
		    $nonuscount++;
		  } elsif (defined $mirror{$id}{method}{'nonus-http'}) {
		    print "  http://$id$mirror{$id}{method}{'nonus-http'}";
		    print "\n\n";
		    $nonuscount++;
		  }
		}
	}
	print <<_END_;

-------------------------------------------------------------------------------
Last modified: $last_modify             Number of sites listed: $nonuscount
_END_
	print <<END;

The authoritative copy of this list can always be found at:
                 http://ftp.debian.org/debian/README.non-US

Everything else you want to know about Debian mirrors:
                        http://www.debian.org/mirror/
END
# that should be http://non-us.debian.org/debian-non-US/README.non-US
# but the FTP admins still haven't made it happen, sigh
}

sub footer_stuff() {
  if ($html) {
	print <<END;
<hr>
<table border="0" width="100%"><tr>
  <td align="left"><small>Last modified: $last_modify</small></td>
  <td align="right"><small>Number of sites listed: $count</small></td>
</tr></table>
END
  } else {
	print <<END;

-------------------------------------------------------------------------------
Last modified: $last_modify             Number of sites listed: $count
END
  }
}

######### Begin main routine ###########################
Getopt::Long::config('no_getopt_compat', 'no_auto_abbrev');
GetOptions(%opthash) or die "error parsing options";

$output_type = 'html' if (! defined $output_type);

if (!defined $mirror_source && !defined $help) {
	warn "Error: No --mirror option given.\n\n";
	$help = '';
}

if (defined $help) {
	print <<END;
Usage: $0 -m|--mirror mirror_list_source [-t|--type type]

`mirror_list_source\' is usually Mirrors.masterlist file
`type\' can be one of:
	html
	text
	apt
	methods
	nonus
	sponsors
	cdimages-httpftp
	cdimages-rsync
END
	exit;
}

open(SRC, "<$mirror_source") || die "Error: problem opening mirror source file, $mirror_source\n";

$current = '';
foreach (<SRC>) {
	chop;
	if (/^$/ && $current eq '') {
		next;
	}
	elsif (/^$/) {
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
		die "Error: unknown format on line $.:\n$_\n";
	}
}
if ($current ne "") {
	process_line($current);
}

# count the number of mirrors
@tmp = keys %mirror;
$count = 0;
$count = $#tmp + 1;

@stat = stat($mirror_source);
$last_modify = gmtime($stat[9]);
# print "$last_modify<br>";

if ($output_type eq 'html') {
	$html=1;
	header();
	intro();
	primary_mirrors();
	table_archive();
	footer_stuff();
	trailer();
}
elsif ($output_type eq 'text') {
	# print "http://www.debian.org/mirror/submit\n\n";
	$html=0;
	intro();
	primary_mirrors();
	table_archive();
	footer_stuff();
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
	full_listing();
	footer_stuff();
	trailer();
}
elsif ($output_type eq 'nonus') {
	readmenonus();
}
elsif ($output_type eq 'sponsors') {
	$html=1;
	primary_mirror_sponsors();
}
elsif ($output_type eq 'cdimages-httpftp') {
	$html=1;
	cdimage_mirrors("httpftp");
}
elsif ($output_type eq 'cdimages-rsync') {
	$html=1;
	cdimage_mirrors("rsync");
}
else {
	die "Error: unknown output type requested, $output_type\n";
}
