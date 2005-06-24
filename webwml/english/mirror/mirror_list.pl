#!/usr/bin/perl -w
#
# mirror_list.pl -- generate various Debian mirror lists
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000-2002 Josip Rodin

use strict;
require 5.001;

# Arches not to list.
my @filter_arches=qw(amd64);

my ($html, $last_modify);

use Getopt::Long;
my ($mirror_source, $output_type, $help);
my %opthash = (
	"mirror|m=s" => \$mirror_source,
	"type|t=s" => \$output_type,
	"help|h!" => \$help,
	);
	
my (@mirror, %countries, $count, %longest);


sub process_line {
	my ($line) = @_;
	my $field = '';

	if ($line =~ /^Site:\s*(.+)\s*$/i) {
		my $site = $1;
		$count++;
		if (!defined($longest{site}) || length($site) > $longest{site}) {
			$longest{site} = length($site);
		}
		$mirror[$count-1]{site} = $1;
		return;
	}
	elsif ($line =~ /^Alias(?:es)?:\s*(.+)\s*$/is) {
		push @{ $mirror[$count-1]{aliases} }, $_ foreach (split("\n", $1));
	}
	elsif ($line =~ /^Archive-architecture:\s*(.+)\s*$/i && length $1) { 
		my @arches=split(' ', $1);
		foreach my $f (@filter_arches) {
			@arches=grep { ! /^$f$/ } @arches;
		}
		if (! @arches) {
			# Mirror only carries filtered architectures.
			$mirror[$count-1]{filtered}=1;
		}
		foreach my $f (@filter_arches) {
			@arches=grep { ! /^\!$f$/ } @arches;
		}
		if (@arches) {
			$mirror[$count-1]{'archive-architecture'}=\@arches;
		}
	}
	elsif ($line=~ /^((Archive|NonUS|Security|WWW|CDimage|Jigdo|Old)-(\w*)):\s*(.*)\s*$/i) {
		my $type = lc $1;
		$mirror[$count-1]{method}{$type} = $4;
		if (!defined($longest{$type}) || length($4) > $longest{$type}) {
			$longest{$type} = length($4);
		}
	}
	elsif ($line =~ /^Includes:\s*(.+)\s*$/i) {
		push @{ $mirror[$count-1]{includes} }, $_ foreach (split(" ", $1));
	}
	elsif ($line =~ /^Sponsor:\s*(.+)\s*$/i) {
		push @{ $mirror[$count-1]{sponsor} }, $1;
	}
	elsif ($line =~ /^([\w-]+):\s*(.+)\s*$/s) {
		$field = lc $1;
		$mirror[$count-1]{$field} = $2;
		if (!defined($longest{$field}) || length($2) > $longest{$field}) {
			$longest{$field} = length($2);
		}
	}
	else {
		die "Error: incorrect line format\n\"$line\"\n";
	}
}


sub aptlines {
	foreach my $country (sort keys %countries) {
		print "\n$country\n";
		my $i = length($country);
		print "-" while ($i--); # underline
		print "\n";
		foreach my $id (@{ $countries{$country} }) {
			my $archcomm="";
			if ($mirror[$id]{'archive-architecture'}) {
				$archcomm=" # ".join(" ", sort @{$mirror[$id]{'archive-architecture'}})."\n";
			}
			if (defined $mirror[$id]{method}{'archive-ftp'}) {
				print "deb ftp://$mirror[$id]{site}$mirror[$id]{method}{'archive-ftp'} stable main contrib non-free$archcomm\n";
			}
			if (defined $mirror[$id]{method}{'nonus-ftp'}) {
				print "deb ftp://$mirror[$id]{site}$mirror[$id]{method}{'nonus-ftp'} stable/non-US main contrib non-free$archcomm\n";
			}
			if (defined $mirror[$id]{method}{'archive-http'}) {
				print "deb http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'} stable main contrib non-free$archcomm\n";
			}
			if (defined $mirror[$id]{method}{'nonus-http'}) {
				print "deb http://$mirror[$id]{site}$mirror[$id]{method}{'nonus-http'} stable/non-US main contrib non-free$archcomm\n";
			}
			print "\n";
		}
	}
}


sub secondary_mirrors {
	# TODO clean up the html to match the primary list and make the
	# text version not have such long lines.
	print "<h2 align=\"center\">" if $html;
	print "\n\n                   " if (!$html);
	print "Secondary mirrors of the Debian archive";
	print "\n                   ---------------------------------------\n\n" if (!$html);
	print "</h2>\n\n" if $html;
	print "\n<pre><small>\n" if $html;
	my $tmp = "%-$longest{site}s %-$longest{'archive-ftp'}s %-$longest{'archive-http'}s %s\n";
	print "<strong>" if $html;
	printf $tmp, "HOST NAME", "FTP", "HTTP", "ARCHITECTURES";
	printf $tmp, "---------", "---", "----", "-------------";
	print "</strong>" if $html;
	foreach my $country (sort keys %countries) {
		my $hasmirrors = 0;
		foreach my $id (@{ $countries{$country} }) {
		  $hasmirrors++ if (defined $mirror[$id]{method}{'archive-ftp'} || defined $mirror[$id]{method}{'archive-http'});
		}
		if ($hasmirrors) {
		  print "\n";
		  print $html ? "<b>$country</b>" : "$country";
		  print "\n";
		} else {
		  next;
		}
		my $i = length($country);
		print "-" while ($i--); # underline
		print "\n";
		# first list the official sites
		foreach my $id (@{ $countries{$country} }) {
			next unless ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/);
			$tmp = "%-$longest{site}s ";
			printf $tmp, $mirror[$id]{site};
			if (defined $mirror[$id]{method}{'archive-ftp'} && $html) {
				my $rest = $longest{'archive-ftp'} - length($mirror[$id]{method}{'archive-ftp'});
				$tmp = "<a href=\"%s\">%s</a>%${rest}s";
				printf $tmp, "ftp://$mirror[$id]{site}$mirror[$id]{method}{'archive-ftp'}", $mirror[$id]{method}{'archive-ftp'}, '';
			} elsif (defined $mirror[$id]{method}{'archive-ftp'}) {
				my $rest = $longest{'archive-ftp'} - length($mirror[$id]{method}{'archive-ftp'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'archive-ftp'}, '';
			} else {
				$tmp = "%-$longest{'archive-ftp'}s";
				printf $tmp, " ";
			}
			$tmp = "%-$longest{'archive-http'}s";
			if (defined $mirror[$id]{method}{'archive-http'} && $html) {
				my $rest = $longest{'archive-http'} - length($mirror[$id]{method}{'archive-http'});
				$tmp = "<a href=\"%s\">%s</a>%${rest}s";
				printf $tmp, "http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}",$mirror[$id]{method}{'archive-http'}, '';
			} elsif (defined $mirror[$id]{method}{'archive-http'}) {
				my $rest = $longest{'archive-http'} - length($mirror[$id]{method}{'archive-http'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'archive-http'}, '';
			} else {
				$tmp = "%-$longest{'archive-http'}s";
				printf $tmp, " ";
			}
          		if (exists $mirror[$id]{'archive-architecture'}) {
				print join(" ", sort @{$mirror[$id]{'archive-architecture'}});
			}
			else {
				print "all";
			}
			print "\n";
		}
		# then list the unofficial sites
		foreach my $id (@{ $countries{$country} }) {
			next if ($mirror[$id]{site} =~ /^(saens|gluck|raff|ftp\d?(?:\.wa)?\...)\.debian\.org$/);
			next unless (defined $mirror[$id]{method}{'archive-ftp'} || defined $mirror[$id]{method}{'archive-http'});
			$tmp = "%-$longest{site}s ";
			printf $tmp, $mirror[$id]{site};
			if (defined $mirror[$id]{method}{'archive-ftp'} && $html) {
				my $rest = $longest{'archive-ftp'} - length($mirror[$id]{method}{'archive-ftp'});
				$tmp = "<a href=\"%s\">%s</a>%${rest}s";
				printf $tmp, "ftp://$mirror[$id]{site}$mirror[$id]{method}{'archive-ftp'}", $mirror[$id]{method}{'archive-ftp'}, '';
			} elsif (defined $mirror[$id]{method}{'archive-ftp'}) {
				my $rest = $longest{'archive-ftp'} - length($mirror[$id]{method}{'archive-ftp'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'archive-ftp'}, '';
			} else {
				$tmp = "%-$longest{'archive-ftp'}s";
				printf $tmp, " ";
			}
			$tmp = "%-$longest{'archive-http'}s";
			if (defined $mirror[$id]{method}{'archive-http'} && $html) {
				my $rest = $longest{'archive-http'} - length($mirror[$id]{method}{'archive-http'});
				$tmp = "<a href=\"%s\">%s</a>%${rest}s";
				printf $tmp, "http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}",$mirror[$id]{method}{'archive-http'}, '';
			} elsif (defined $mirror[$id]{method}{'archive-http'}) {
				my $rest = $longest{'archive-http'} - length($mirror[$id]{method}{'archive-http'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'archive-http'}, '';
			} else {
				$tmp = "%-$longest{'archive-http'}s";
				printf $tmp, " ";
			}
          		if (exists $mirror[$id]{'archive-architecture'}) {
				print join(" ", sort @{$mirror[$id]{'archive-architecture'}});
			}
			else {
				print "all";
			}
			print "\n";
		}
	}
	print "</small></pre>" if $html;
}


sub intro {
	print "<h1 align=\"center\">" if $html;
	print "                 " if (!$html);
	print "Debian worldwide mirror sites";
	print "</h1>" if $html;
	print "\n                        -----------------------------\n" if (!$html);
	print "\n";

	print "<p>" if $html;
	print "Debian is distributed (";
	print $html ? "<em>mirrored</em>" : "mirrored";
	print ") on hundreds of\n";
	print <<END;
servers on the Internet. Using a nearby server will probably speed up your
download, and also reduce the load on our central servers and on the
Internet as a whole.

END
	print "<p>" if $html;
	print <<END;
Debian mirrors can be primary and secondary. The definitions are as follows:

END
	if ($html) {
          print <<END;
  <blockquote>
  A <strong>primary mirror</strong> site has good bandwidth, is available 24 hours a day,
  and has an easy to remember name of the form ftp.&lt;country&gt;.debian.org.
  <br>
END
	} else {
	  print <<END;
  A primary mirror site has good bandwidth, is available 24 hours a day,
  and has an easy to remember name of the form ftp.<country>.debian.org.
END
	}
	print <<END;
  Additionally, most of them are updated automatically after updates to the
  Debian archive. The Debian archive on those sites is normally available
  using both FTP and HTTP protocols.

END
	print "  </blockquote>\n" if $html;
	if ($html) {
          print <<END;
  <blockquote>
  A <strong>secondary mirror</strong> site may have restrictions on what they mirror (due to
END
	} else {
	  print <<END;
  A secondary mirror site may have restrictions on what they mirror (due to
END
	}
	print <<END;
  space restrictions). Just because a site is secondary doesn't necessarily
  mean it'll be any slower or less up to date than a primary site.

END
	print "  </blockquote>\n" if $html;
	print "<p>" if $html;
	print <<END;
Use the site closest to you for the fastest downloads possible whether it is
END
	if ($html) {
          print "
a primary or secondary site. The program
<a href=\"http://packages.debian.org/stable/net/netselect\">
<em>netselect</em></a> can be used to\n";
	} else {
	  print "a primary or secondary site. The program `netselect' can be used to\n";
	}
	print <<END;
determine the site with the least latency; use a download program such as
END
	if ($html) {
          print "
<a href=\"http://packages.debian.org/stable/web/wget\">
<em>wget</em></a> or
<a href=\"http://packages.debian.org/stable/net/rsync\">
<em>rsync</em></a> for determining the site with the most throughput.\n";
	} else {
	  print "`wget' or `rsync' for determining the site with the most throughput.\n";
	}
	print <<END;
Note that geographic proximity often isn't the most important factor for
determining which machine will serve you best.

END
	print "<p>" if $html;
	print "The authoritative copy of the following list can always be found at:\n";
	print "<a href=\"http://www.debian.org/mirror/list\">" if $html;
	print "                      http://www.debian.org/mirror/list";
	print "</a>.<br>" if $html;
	print "\n";

	print <<END;
If you know of any mirrors that are missing from this list,
please have the site maintainer fill out the form at:
END
	print "<a href=\"http://www.debian.org/mirror/submit\">" if $html;
	print "                     http://www.debian.org/mirror/submit";
	print "</a>.<br>" if $html;
	print "\n";

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

<h2 align="center">Primary Debian mirror sites</h2>

<table border="0" align="center">
<tr>
  <th>Country</th>
  <th>Site</th>
  <th><b>Debian&nbsp;archive</b></th>
  <th><b>Architectures</b></th>
</tr>
<tr><td colspan="5"><hr></td></tr>
END
  } else {
    print <<END;


                         Primary Debian mirror sites
                         ---------------------------

 Country         Site                  Debian archive  Architectures
 ---------------------------------------------------------------------------
END
  }
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
      if ($mirror[$id]{site} =~ /^(?:ftp|http)\d?(?:\.wa)?\...\.debian.org$/) {
        (my $countryplain = $country) =~ s/^.. //;

	next unless exists $mirror[$id]{method}{'archive-http'};
	my $arches="all";
	if (exists $mirror[$id]{'archive-architecture'}) {
		$arches=join(" ", sort @{$mirror[$id]{'archive-architecture'}});
	}
	
	if ($html) {
	  $countryplain =~ s/ /&nbsp;/;
	  print <<END;
<tr>
  <td width="25%">$countryplain</td>
  <td width="25%" align="center"><code>$mirror[$id]{site}</code></td>
  <td width="25%"><a href="http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}">$mirror[$id]{method}{'archive-http'}</a></td>
  <td width="25%">$arches</td>
END

          print <<END;
</tr>
END
        } else {
          printf " %-14s  %-20s  %-14s  %s\n", $countryplain, $mirror[$id]{site}, $mirror[$id]{method}{'archive-http'}, $arches;
# $countryplain	-   $site		$mirror[$id]{method}{'archive-ftp'}	$mirror[$id]{method}{'nonus-ftp'}
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
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
      if ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian.org$/) {
        (my $countrycode = $country) =~ s/^(..).*/$1/;
	print <<END;
<tr>
  <td valign="top"><${countrycode}c></td>
  <td valign="top" align="center"><a href="http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}">$mirror[$id]{site}</a></td>
  <td>
END
	if ($mirror[$id]{site} eq "ftp.us.debian.org") {
	  die "$mirror[$id]{site} has no includes\n" unless exists $mirror[$id]{includes}; # must be an error
	  my $numsubsites = @{ $mirror[$id]{includes} };
	  my $snum = 0;
	  foreach my $subsite (@{ $mirror[$id]{includes} }) {
	    # XXX Note this is a little bit wrong; if there is more than one id
	    # for a subsite, it just takes the first one. This problem
	    # could occur if a subsite begins mirroring some other arch,
	    # like amd64.
	    my $subsite_id;
	    foreach my $mid (0..$#mirror) {
		if ($mirror[$mid]{site} eq $subsite) {
			$subsite_id=$mid;
			last;
		}
	    }	    
	    die "$subsite has no sponsor\n" unless defined $subsite_id; # must be an error

	    my $numsponsors = @{ $mirror[$subsite_id]{sponsor} };
	    my $num = 0;
            my ($sponsorname, $sponsorurl);
	    foreach my $sponsor (@{ $mirror[$subsite_id]{sponsor} }) {
	      if ($sponsor =~ /^(.+) (http:.*)$/) {
	        $sponsorname = $1;
	        $sponsorurl = $2;
	      }
	      $sponsorname =~ s/&(\s+)/&amp;$1/g;
	      print "<a href=\"$sponsorurl\">$sponsorname</a>";
	      $num++;
	      print ", " unless ($num >= $numsponsors);
	    }
	    $snum++;
	    print ", " unless ($snum >= $numsubsites);
	  }
	} else {
	  die "$mirror[$id]{site} has no sponsor\n" unless exists $mirror[$id]{sponsor}; # must be an error
	  my $numsponsors = @{ $mirror[$id]{sponsor} };
	  my $num = 0;
          my ($sponsorname, $sponsorurl);
	  foreach my $sponsor (@{ $mirror[$id]{sponsor} }) {
	    if ($sponsor =~ /^(.+) (http:.*)$/) {
	      $sponsorname = $1;
	      $sponsorurl = $2;
	    }
	    $sponsorname =~ s/&(\s+)/&amp;$1/g;
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
sub mirror_sponsors {
  return unless $html;
  print <<END;
<tr><td colspan="3"><hr></td></tr>
END
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
      if ((defined $mirror[$id]{method}{'archive-ftp'} ||
           defined $mirror[$id]{method}{'archive-http'} ||
           defined $mirror[$id]{method}{'nonus-ftp'} ||
           defined $mirror[$id]{method}{'nonus-http'}) &&
           exists $mirror[$id]{sponsor}) {
        (my $countrycode = $country) =~ s/^(..).*/$1/;
	print <<END;
<tr>
  <td valign="top">${countrycode} <${countrycode}c></td>
  <td valign="top" align="center">$mirror[$id]{site}</td>
  <td>
END
	if ($mirror[$id]{site} ne "ftp.us.debian.org") {
	  my $numsponsors = @{ $mirror[$id]{sponsor} };
	  my $num = 0;
	  my ($sponsorname, $sponsorurl);
	  foreach my $sponsor (@{ $mirror[$id]{sponsor} }) {
	    if ($sponsor =~ /^(.+) (http:.*)$/) {
	      $sponsorname = $1;
	      $sponsorurl = $2;
	      $sponsorname =~ s/&(\s+)/&amp;$1/g;
	      print "<a href=\"$sponsorurl\">$sponsorname</a>";
	    }
	    else {
	      $sponsorname = $sponsor;
	      print $sponsor;
	    }
	    $num++;
	    print ",\n" unless ($num >= $numsponsors);
	  }
          print "\n";
	}
        print <<END;
  </td>
</tr>
END
      }
    }
  }
}

# meant to be output into a file which is then included into a .wml file
# and processed by WML
sub cdimage_mirrors {
  my $which = shift;
  return unless $html;
  print "#use wml::debian::languages\n\n<perl>\nmy \@cdmirrors = (\n";
  foreach my $country (keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
      (my $countrycode = $country) =~ s/^(..) .*/$1/;
      if ($which eq "httpftp") {
        if (defined $mirror[$id]{method}{'cdimage-ftp'} ||
            defined $mirror[$id]{method}{'cdimage-http'}) {
          print "  '<${countrycode}c>: $mirror[$id]{site}:";
          if (defined $mirror[$id]{method}{'cdimage-ftp'}) {
            print qq( <a href="ftp://$mirror[$id]{site}$mirror[$id]{method}{'cdimage-ftp'}">FTP</a>);
          }
          if (defined $mirror[$id]{method}{'cdimage-http'}) {
            print qq( <a href="http://$mirror[$id]{site}$mirror[$id]{method}{'cdimage-http'}">HTTP</a>);
          }
          print "',\n";
        }
      } elsif ($which eq "rsync") {
        if (defined $mirror[$id]{method}{'cdimage-rsync'}) {
          print qq(  '<${countrycode}c>: $mirror[$id]{site}: <font color="#6b1300">rsync $mirror[$id]{site}\:\:$mirror[$id]{method}{'cdimage-rsync'}</font>',\n);
END
        }
      }
    }
  }
  print ");\n\n";

  # Write some code to sort the list alphabetically (the ordering is
  # language-dependent)
  print <<'EOM';
print "<ul>\n";
foreach $line (sort langcmp @cdmirrors)
{
  print "<li>$line</li>\n";
}
print "</ul>\n";
</perl>
EOM
}

sub header {
	my $nonus = shift;
	$nonus = "" unless $nonus;
	print <<END;
<html>

<head>
  <title>Debian ${nonus}worldwide mirror sites</title>
</head>

<body>
END
}

sub trailer {
	print "</body>\n</html>\n";
}


sub access_methods {
	print <<END;
<h1 align="center">Debian worldwide mirror sites</h1>

<p>This is a <strong>complete</strong> list of mirrors of Debian. For each
site, the different types of material available are listed, along with the
access method for each type.

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
(See <a href="http://www.debian.org/mirror/push_mirroring">the page about push
mirroring</a> for details on that.)
END

	print <<END;

<p>The authoritative copy of the following list can always be found at:
<a href="http://www.debian.org/mirror/list-full">
http://www.debian.org/mirror/list-full</a>.
<br>
Everything else you want to know about Debian mirrors:
<a href="http://www.debian.org/mirror/">http://www.debian.org/mirror/</a>.
<br>
END
}

sub full_listing {
	if ($html) {
		print "\n<hr noshade size=\"1\">\n";
		print "<p>Jump directly to a country on the list:<br>\n";
		my $counter = 1;
		foreach my $country (sort keys %countries) {
			(my $XY = $country) =~ s/^([[:upper:]]+) .+$/$1/;
			(my $con = $country) =~ s/^[[:upper:]]+ (.+)$/$1/;
			print " [<a href=\"#$XY\">$con</a>]";
			print "<br>" unless ($counter++ % 6);
	        }
		print "\n<hr noshade size=\"1\">\n";
	}
	print "<pre>\n" if ($html);
	foreach my $country (sort keys %countries) {
		if ($html) {
			(my $XY = $country) =~ s/^([[:upper:]]+) .+$/$1/;
			print "\n<strong><a name=\"$XY\">$country</a></strong>\n";
		}
		else {
			print "\n$country\n";
		}
		my $i = length($country);
		print "-" while ($i--); # underline
		print "\n";
		# first list the official sites
		foreach my $id (@{ $countries{$country} }) {
			next unless ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/);
			print "Site: $mirror[$id]{site}";
			if (exists $mirror[$id]{'aliases'}) {
				print ", ".join(", ", @{ $mirror[$id]{'aliases'} });
			}
			print "\n";
			die "undefined type for $mirror[$id]{site}!\n" unless defined $mirror[$id]{'type'};
			print "Type: $mirror[$id]{'type'}\n";
			foreach my $method ( sort keys %{ $mirror[$id]{method} } ) {
				my $display = $method;
				$display =~ s/archive-/Packages /;
				$display =~ s/nonus-/Non-US packages /;
				$display =~ s/security-/Security updates /;
				$display =~ s/www-/WWW pages /;
				$display =~ s/cdimage-/CD Images /;
				$display =~ s/jigdo-/Jigdo files /;
				$display =~ s/old-/Old releases /;
				$display =~ s/ftp/over FTP/;
				$display =~ s/http/over HTTP/;
				$display =~ s/nfs/over NFS/;
				$display =~ s/rsync/over rsync/;
				if ($method =~ /http/) {
					print $display.":	<a href=\"http://$mirror[$id]{site}$mirror[$id]{method}{$method}\">$mirror[$id]{method}{$method}</a>\n";
				}
				elsif ($method =~ /ftp/) {
					print $display.":	<a href=\"ftp://$mirror[$id]{site}$mirror[$id]{method}{$method}\">$mirror[$id]{method}{$method}</a>\n";
				}
				else {
					print $display.":	".$mirror[$id]{method}{$method}."\n";
				}
			}
			if (exists $mirror[$id]{'archive-architecture'}) {
				print "Archive Architectures: ".join(" ", sort @{$mirror[$id]{'archive-architecture'}})."\n";
			}
			if (exists $mirror[$id]{'comment'}) {
				print "Comment: ".$mirror[$id]{comment}."\n";
			}
			print "\n";
		}
		# then list the unofficial sites
		foreach my $id (@{ $countries{$country} }) {
			next if ($mirror[$id]{site} =~ /^(saens|gluck|raff|ftp\d?(?:\.wa)?\...)\.debian\.org$/);
			print "Site: $mirror[$id]{site}";
			if (exists $mirror[$id]{'aliases'}) {
				print ", ".join(", ", @{ $mirror[$id]{'aliases'} });
			}
			print "\n";
			die "undefined type for $mirror[$id]{site}!\n" unless defined $mirror[$id]{'type'};
			print "Type: $mirror[$id]{'type'}\n";
			foreach my $method ( sort keys %{ $mirror[$id]{method} } ) {
				my $display = $method;
				$display =~ s/archive-/Packages /;
				$display =~ s/nonus-/Non-US packages /;
				$display =~ s/security-/Security updates /;
				$display =~ s/www-/WWW pages /;
				$display =~ s/cdimage-/CD Images /;
				$display =~ s/jigdo-/Jigdo files /;
				$display =~ s/old-/Old releases /;
				$display =~ s/ftp/over FTP/;
				$display =~ s/http/over HTTP/;
				$display =~ s/nfs/over NFS/;
				$display =~ s/rsync/over rsync/;
				if ($method =~ /http/) {
					print $display.":	<a href=\"http://$mirror[$id]{site}$mirror[$id]{method}{$method}\">$mirror[$id]{method}{$method}</a>\n";
				}
				elsif ($method =~ /ftp/) {
					print $display.":	<a href=\"ftp://$mirror[$id]{site}$mirror[$id]{method}{$method}\">$mirror[$id]{method}{$method}</a>\n";
				}
				else {
					print $display.":	".$mirror[$id]{method}{$method}."\n";
				}
			}
			if (exists $mirror[$id]{'archive-architecture'}) {
				print "Archive Architectures: ".join(" ", sort @{$mirror[$id]{'archive-architecture'}})."\n";
			}
			if (exists $mirror[$id]{'comment'}) {
				print "Comment: ".$mirror[$id]{comment}."\n";
			}
			print "\n";
		}
	}
	print "</pre>\n" if ($html);
}

sub nonus_mirrors {
  if ($html) {
	print "<h1 align=\"center\">Debian non-US packages</h1>\n\n";
  } else {
	print <<END;

                           Debian non-US packages
                           ----------------------

END
  }
	print "<p>" if $html;
	print <<END;
Prior to the release of Debian 3.1, United States laws placed restrictions on
the export of certain defense articles, which, unfortunately, included some
types of cryptographic software. PGP and SSH, among others, fell into this
category.  It was legal however, to import such software into the US.

END
	print "<p>" if $html;
	print <<END;
To prevent anyone from taking unnecessary legal risks, some Debian
packages were only available from a site in Leiden, The Netherlands, until 
the release of Debian 3.1, which incorporates this software thanks to
changes in United States law.

You should not need the non-US archive unless you are using a version of
Debian from before Debian 3.1.

Available access methods are:
END
	print "<blockquote>\n" if $html;
	print "<a href=\"ftp://non-us.debian.org/debian-non-US/\">" if $html;
	print <<END;
	ftp://non-us.debian.org/debian-non-US/
END
	print "</a><br>" if $html;
	print "<a href=\"http://non-us.debian.org/debian-non-US/\">" if $html;
	print <<END;
	http://non-us.debian.org/debian-non-US/
END
	print "</a><br>" if $html;
	print <<END;
	rsync://non-us.debian.org/debian-non-US/  (limited)

END
	print "</blockquote>\n" if $html;
	print "<p>" if $html;
	print <<END;
To use these packages with APT, you can add the following lines to your
sources.list file:

END
	print "<pre>" if $html;
	print <<END;
  deb http://non-us.debian.org/debian-non-US stable/non-US main contrib non-free
  deb-src http://non-us.debian.org/debian-non-US stable/non-US main contrib non-free
END
	print "</pre>" if $html;
	print <<END;

Read sources.list(5) on your Debian system for more information.

END
  if ($html) {
	print "<h2 align=\"center\">Debian non-US mirror sites</h2>\n";
  } else {
	print <<END;
                         Debian non-US mirror sites
                         --------------------------

END
  }
	print "<p>" if $html;
	print <<END;
Mirrors of non-us.debian.org are normally located outside of the US.
If they are located within the US they should be registered with the
US government.

END

	print "<p>" if $html;
	print <<END;
The authoritative copy of the following mirror list can always be found at:
END
	print "<a href=\"http://www.debian.org/mirror/list-non-US\">" if $html;
	print <<END;
                  http://www.debian.org/mirror/list-non-US
END
	print "</a>" if $html;

	print "<p>" if $html;
	print <<END;

Everything else you want to know about Debian mirrors:
END
	print "<a href=\"http://www.debian.org/mirror/\">" if $html;
	print <<END;
                        http://www.debian.org/mirror/
END
	print "</a>" if $html;

	my $nonuscount = 0;
	foreach my $country (sort keys %countries) {
	  my $hasmirrors = 0;
	  foreach my $m_id (@{ $countries{$country} }) {
	    $hasmirrors++ if (defined $mirror[$m_id]{method}{'nonus-ftp'} || defined $mirror[$m_id]{method}{'nonus-http'});
	  }
	  my $countryplain;
	  ($countryplain = $country) =~ s/^.. //;
	  if ($hasmirrors) {
	    print "\n";
	    print $html ? "<h3>$countryplain</h3>" : "$countryplain:";
	    print "\n";
	  } else {
	    next;
	  }
	  # first list the official sites
	  foreach my $m_id (@{ $countries{$country} }) {
	    next unless ($mirror[$m_id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/);
	    if (defined $mirror[$m_id]{method}{'nonus-ftp'}) {
	      print "<a href=\"ftp://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-ftp'}\">" if $html;
	      print "  ftp://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-ftp'}";
	      print "</a><br>\n" if $html;
	      if (defined $mirror[$m_id]{method}{'nonus-http'}) {
	        print "\n    ";
	        print "<a href=\"http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}\">" if $html;
	        print "http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}";
	        print "</a>\n" if $html;
	      }
	      print "\n\n";
	      print "<p>" if $html;
	      $nonuscount++;
	    } elsif (defined $mirror[$m_id]{method}{'nonus-http'}) {
	      print "  ";
	      print "<a href=\"http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}\">" if $html;
	      print "http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}";
	      print "</a>\n" if $html;
	      print "\n\n";
	      print "<p>" if $html;
	      $nonuscount++;
	    }
	  }
	  # then list the unofficial sites
	  foreach my $m_id (@{ $countries{$country} }) {
	    next if ($mirror[$m_id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/);
	    if (defined $mirror[$m_id]{method}{'nonus-ftp'}) {
	      print "<a href=\"ftp://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-ftp'}\">" if $html;
	      print "  ftp://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-ftp'}";
	      print "</a><br>\n" if $html;
	      if (defined $mirror[$m_id]{method}{'nonus-http'}) {
	        print "\n    ";
	        print "<a href=\"http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}\">" if $html;
	        print "http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}";
	        print "</a>\n" if $html;
	      }
	      print "\n\n";
	      print "<p>" if $html;
	      $nonuscount++;
	    } elsif (defined $mirror[$m_id]{method}{'nonus-http'}) {
	      print "  ";
	      print "<a href=\"http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}\">" if $html;
	      print "http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}";
	      print "</a>\n" if $html;
	      print "\n\n";
	      print "<p>" if $html;
	      $nonuscount++;
	    }
	  }
	}

  if ($html) {
	print <<END;
<hr>
<table border="0" width="100%"><tr>
  <td align="left"><small>Last modified: $last_modify</small></td>
  <td align="right"><small>Number of sites listed: $nonuscount</small></td>
</tr></table>
END
  } else {
	print <<END;

-------------------------------------------------------------------------------
Last modified: $last_modify             Number of sites listed: $nonuscount
END
  }
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
$mirror_source = 'Mirrors.masterlist' if (! defined $mirror_source);

if (defined $help) {
	print <<END;
Usage: $0 [mt|--type type] [-m|--mirror mirror_list_source]

`mirror_list_source\' is usually the Mirrors.masterlist file
`type\' can be one of:
	html			(the default)
	text
	apt
	fullmethods
	nonus
	nonushtml
	officialsponsors
	sponsors
	cdimages-httpftp
	cdimages-rsync
END
	exit;
}

open SRC, "<$mirror_source" or
  die "Error: problem opening mirror source file, $mirror_source\n"
     ."Use the -m option?\n";

my $current = '';
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

# Remove filtered mirrors.
my @filtered;
foreach my $id (0..$#mirror) {
	if ($mirror[$id]{filtered}) {
		push @filtered, $id;
	}
}
foreach my $id (reverse @filtered) { # reverse order so indexes are valid
	splice(@mirror, $id, 1);
}

# Get country info for remaining mirrors.
foreach my $id (0..$#mirror) {
	if (exists $mirror[$id]{country}) {
		push @{ $countries{$mirror[$id]{country}} }, $id;
	}
}
	
# count the number of mirrors
$count = @mirror;

my @stat = stat($mirror_source);
$last_modify = gmtime($stat[9]);
# print "$last_modify<br>";

if ($output_type eq 'html') {
	$html=1;
	header();
	intro();
	primary_mirrors();
	secondary_mirrors();
	footer_stuff();
	trailer();
}
elsif ($output_type eq 'text') {
	$html=0;
	intro();
	primary_mirrors();
	secondary_mirrors();
	footer_stuff();
}
elsif ($output_type eq 'apt') {
	header();
	print "<pre>\n";
	aptlines();
	print "</pre>\n";
	trailer();
}
elsif ($output_type eq 'fullmethods') {
	$html=1;
	header();
	access_methods();
	full_listing();
	footer_stuff();
	trailer();
}
elsif ($output_type eq 'nonus') {
	$html = 0;
	nonus_mirrors();
}
elsif ($output_type eq 'nonushtml') {
	header("non-US ");
	$html = 1;
	nonus_mirrors();
	trailer();
}
elsif ($output_type eq 'officialsponsors') {
	$html=1;
	primary_mirror_sponsors();
}
elsif ($output_type eq 'sponsors') {
	$html=1;
	mirror_sponsors();
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
