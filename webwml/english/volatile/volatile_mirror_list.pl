#!/usr/bin/perl -w
#
# mirror_list.pl -- generate various Debian-volatile mirror lists
# 
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000-2002 Josip Rodin
# 
# Changed for debian-volatile by Francesco Paolo Lovergine, 2005 
#

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
	elsif ($line =~ /^Volatile-architecture:\s*(.+)\s*$/i && length $1) { 
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
			$mirror[$count-1]{'volatile-architecture'}=\@arches;
		}
	}
	elsif ($line=~ /^((Volatile)-(\w*)):\s*(.*)\s*$/i) {
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
			if ($mirror[$id]{'volatile-architecture'}) {
				$archcomm=" # ".join(" ", sort @{$mirror[$id]{'volatile-architecture'}})."\n";
			}
			if (defined $mirror[$id]{method}{'volatile-ftp'}) {
				print "deb ftp://$mirror[$id]{site}$mirror[$id]{method}{'volatile-ftp'} stable/volatile main$archcomm\n";
			}
			if (defined $mirror[$id]{method}{'volatile-http'}) {
				print "deb http://$mirror[$id]{site}$mirror[$id]{method}{'volatile-http'} stable/volatile main$archcomm\n";
			}
			if (defined $mirror[$id]{method}{'volatile-rsync'}) {
				print "deb rsync://$mirror[$id]{site}$mirror[$id]{method}{'volatile-rsync'} stable/volatile main$archcomm\n";
			}
			print "\n";
		}
	}
}


sub secondary_mirrors {
	# TODO clean up the html to match the primary list and make the
	# text version not have such long lines.
	if ($html) {
		print "<h2 class=\"center\">";
	} else {
		print "\n\n                   ";
	}
	print "Mirrors of the Debian-volatile archive";
	if ($html) {
		print "</h2>\n";
	} else {
		print "\n                   ---------------------------------------\n\n";
	}
	my $tmp = "%-$longest{site}s%-$longest{'volatile-ftp'}s%-$longest{'volatile-http'}s%-$longest{'volatile-rsync'}s%s\n";
	if ($html) {
		print "<table class=\"volatile\"summary=\"Mirrors sorted by Country\">\n";
		print "<colgroup span=\"5\">\n</colgroup>\n";
		print "<thead><tr><th>HOST NAME</th><th>FTP</th><th>
		HTTP</th><th>RSYNC</th><th>ARCHITECTURES</th></tr></thead>\n<tbody>";
	} else {
		printf $tmp, "HOST NAME", " FTP", " HTTP", " RSYNC" ,"  ARCHITECTURES";
		printf $tmp, "---------", " ---", " ----", " -----" ,"  -------------";
	}
	foreach my $country (sort keys %countries) {
		my $hasmirrors = 0;
		foreach my $id (@{ $countries{$country} }) {
		  $hasmirrors++ if (defined $mirror[$id]{method}{'volatile-ftp'} || 
				    defined $mirror[$id]{method}{'volatile-http'} || 
				    defined $mirror[$id]{method}{'volatile-rsync'});
		}
		if ($hasmirrors) {
		  print "\n";
		  print $html ? "<tr class=\"country\"><th colspan=\"5\">$country</th></tr>" : "$country";
		  print "\n";
		} else {
		  next;
		}
		if (!$html) {
			my $i = length($country);
			print "-" while ($i--); # underline
			print "\n";
		}
		# first list the official sites
		foreach my $id (@{ $countries{$country} }) {
			next unless ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/);
			if ($html) {
				print "<tr><th>$mirror[$id]{site}</th>";
			} else {
				$tmp = "%-$longest{site}s ";
				printf $tmp, $mirror[$id]{site};
			}
			if (defined $mirror[$id]{method}{'volatile-ftp'} && $html) {
				print "<td><a href=\"ftp://$mirror[$id]{site}$mirror[$id]{method}{'volatile-ftp'}\">";
				print "$mirror[$id]{method}{'volatile-ftp'}";
				print "</a></td>\n";
			} elsif (defined $mirror[$id]{method}{'volatile-ftp'}) {
				my $rest = $longest{'volatile-ftp'} - length($mirror[$id]{method}{'volatile-ftp'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'volatile-ftp'}, '';
			} elsif ($html) {
				print "<td> </td>\n";
			} else {
				$tmp = "%-$longest{'volatile-ftp'}s";
				printf $tmp, " ";
			}
			$tmp = "%-$longest{'volatile-http'}s";
			if (defined $mirror[$id]{method}{'volatile-http'} && $html) {
				print "<td><a href=\"http://$mirror[$id]{site}$mirror[$id]{method}{'volatile-http'}\">";
				print "$mirror[$id]{method}{'volatile-http'}";
				print "</a></td>\n";
			} elsif (defined $mirror[$id]{method}{'volatile-http'}) {
				my $rest = $longest{'volatile-http'} - length($mirror[$id]{method}{'volatile-http'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'volatile-http'}, '';
			} elsif ($html) {
				print "<td> </td>\n";
			} else {
				$tmp = "%-$longest{'volatile-http'}s";
				printf $tmp, " ";
			}
			$tmp = "%-$longest{'volatile-rsync'}s";
			if (defined $mirror[$id]{method}{'volatile-rsync'} && $html) {
				print "<td><a href=\"rsync://$mirror[$id]{site}/$mirror[$id]{method}{'volatile-rsync'}\">";
				print "$mirror[$id]{method}{'volatile-rsync'}";
				print "</a></td>\n";
			} elsif (defined $mirror[$id]{method}{'volatile-rsync'}) {
				my $rest = $longest{'volatile-rsync'} - length($mirror[$id]{method}{'volatile-rsync'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'volatile-rsync'}, '';
			} elsif ($html) {
				print "<td> </td>\n";
			} else {
				$tmp = "%-$longest{'volatile-rsync'}s";
				printf $tmp, " ";
			}
			print "<td>" if ($html);
          		if (exists $mirror[$id]{'volatile-architecture'}) {
				print join(" ", sort @{$mirror[$id]{'volatile-architecture'}});
			}
			else {
				print " all";
			}
			print "</td>\n</tr>" if ($html);
			print "\n";
		}
		# then list the unofficial sites
		foreach my $id (@{ $countries{$country} }) {
			next if ($mirror[$id]{site} =~ /^(saens|gluck|raff|ftp\d?(?:\.wa)?\...)\.debian\.org$/);
			next unless (defined $mirror[$id]{method}{'volatile-ftp'} || defined $mirror[$id]{method}{'volatile-http'} || defined $mirror[$id]{method}{'volatile-rsync'});
			if ($html) {
				print "<tr><th>$mirror[$id]{site}</th>";
			} else {
				$tmp = "%-$longest{site}s ";
				printf $tmp, $mirror[$id]{site};
			}
			if (defined $mirror[$id]{method}{'volatile-ftp'} && $html) {
				print "<td><a href=\"ftp://$mirror[$id]{site}$mirror[$id]{method}{'volatile-ftp'}\">";
				print "$mirror[$id]{method}{'volatile-ftp'}";
				print "</a></td>\n";
				my $rest = $longest{'volatile-ftp'} - length($mirror[$id]{method}{'volatile-ftp'});
			} elsif (defined $mirror[$id]{method}{'volatile-ftp'}) {
				my $rest = $longest{'volatile-ftp'} - length($mirror[$id]{method}{'volatile-ftp'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'volatile-ftp'}, '';
			} elsif ($html) {
				print "<td> </td>\n";
			} else {
				$tmp = "%-$longest{'volatile-ftp'}s";
				printf $tmp, " ";
			}
			$tmp = "%-$longest{'volatile-http'}s";
			if (defined $mirror[$id]{method}{'volatile-http'} && $html) {
				print "<td><a href=\"http://$mirror[$id]{site}$mirror[$id]{method}{'volatile-http'}\">";
				print "$mirror[$id]{method}{'volatile-http'}";
				print "</a></td>\n";

			} elsif (defined $mirror[$id]{method}{'volatile-http'}) {
				my $rest = $longest{'volatile-http'} - length($mirror[$id]{method}{'volatile-http'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'volatile-http'}, '';
			} elsif ($html) {
				print "<td> </td>\n";
			} else {
				$tmp = "%-$longest{'volatile-http'}s";
				printf $tmp, " ";
			}
			if (defined $mirror[$id]{method}{'volatile-rsync'} && $html) {
				print "<td><a href=\"rsync://$mirror[$id]{site}/$mirror[$id]{method}{'volatile-rsync'}\">";
				print "$mirror[$id]{method}{'volatile-rsync'}";
				print "</a></td>\n";
			} elsif (defined $mirror[$id]{method}{'volatile-rsync'}) {
				my $rest = $longest{'volatile-rsync'} - length($mirror[$id]{method}{'volatile-rsync'});
				$tmp = "%s%${rest}s";
				printf $tmp, $mirror[$id]{method}{'volatile-rsync'}, '';
			} elsif ($html) {
				print "<td> </td>\n";
			} else {
				$tmp = "%-$longest{'volatile-rsync'}s";
				printf $tmp, " ";
			}
          		print "<td>" if ($html);
			if (exists $mirror[$id]{'volatile-architecture'}) {
				print join(" ", sort @{$mirror[$id]{'volatile-architecture'}});
			} else {
				print " all";
			}
			print "</td>\n</tr>\n" if ($html);
			print "\n";
		}
	}
	print "</tbody>\n</table>\n" if $html;
}


sub intro {
	print "<h1 align=\"center\">" if $html;
	print "                 " if (!$html);
	print "Debian-volatile worldwide mirror sites";
	print "</h1>" if $html;
	print "\n                        -----------------------------\n" if (!$html);
	print "\n";

	print "<p>" if $html;
	print "Debian-volatile is distributed (";
	print $html ? "<em>mirrored</em>" : "mirrored";
	print ") on several\n";
	print <<END;
servers on the Internet. Using a nearby server will probably speed up your
download, and also reduce the load on our central servers and on the
Internet as a whole.

END
	print "<p>" if $html;
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
	print "The authoritative copy of the following list can be found at:\n";
	print "<a href=\"http://www.debian.org/volatile/volatile-mirrors.en.html\">" if $html;
	print "                      http://www.debian.org/volatile/volatile-mirrors.en.html";
	print "</a>.<br>" if $html;
	print "\n";

	print <<END;
If you know of any mirrors that are missing from this list,
please have the site maintainer fill out the form at:
END
	print "<a href=\"http://www.debian.org/volatile/submit\">" if $html;
	print "                     the submit page";
	print "</a>.<br>" if $html;
	print "\n";

	print <<END;
Everything else you want to know about Debian-volatile:
END
	print "<a href=\"http://www.debian.org/volatile/\">" if $html;
	print "                        volatile users' home";
	print "</a>.<br>" if $html;
	print "\n";
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
      if ((defined $mirror[$id]{method}{'volatile-ftp'} ||
           defined $mirror[$id]{method}{'volatile-http'} ) &&
           exists $mirror[$id]{sponsor}) {
        (my $countrycode = $country) =~ s/^(..).*/$1/;
	print <<END;
<tr>
  <td>${countrycode} <${countrycode}c></td>
  <td>$mirror[$id]{site}</td>
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
          print qq(  '<${countrycode}c>: $mirror[$id]{site}: <span class="cdrsync">rsync $mirror[$id]{site}\:\:$mirror[$id]{method}{'cdimage-rsync'}</span>',\n);
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

sub access_methods {
	print <<END;
<h1 align="center">Debian-volatile worldwide mirror sites</h1>

<p>This is a <strong>complete</strong> list of mirrors of Debian-volatile. For each
site, the different types of material available are listed, along with the
access method for each type.

<p>The following things are mirrored:
<dl>
<dt><strong>Packages</strong>
	<dd>The Debian-volatile package pool.
<dt><strong>Non-US packages</strong>
	<dd>A pool for Debian-volatile packages that can't be distributed in the US
	due to software patents or use of encryption.
<dt><strong>CD Images</strong>
	<dd>Official Debian-volatile CD Images. See
	<a href="http://www.debian.org/CD/">http://www.debian.org/CD/</a> for details.
<dt><strong>WWW pages</strong>
	<dd>The Debian-volatile web pages.
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
Everything else you want to know about Debian-volatile mirrors:
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
			$mirror[$id]{'type'} ||= 'leaf';
			# die "undefined type for $mirror[$id]{site}!\n" unless defined $mirror[$id]{'type'};
			print "Type: $mirror[$id]{'type'}\n";
			foreach my $method ( sort keys %{ $mirror[$id]{method} } ) {
				my $display = $method;
				$display =~ s/volatile-/Packages /;
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
			if (exists $mirror[$id]{'volatile-architecture'}) {
				print "Archive Architectures: ".join(" ", sort @{$mirror[$id]{'volatile-architecture'}})."\n";
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
			$mirror[$id]{'type'} ||= 'leaf';
			# die "undefined type for $mirror[$id]{site}!\n" unless defined $mirror[$id]{'type'};
			print "Type: $mirror[$id]{'type'}\n";
			foreach my $method ( sort keys %{ $mirror[$id]{method} } ) {
				my $display = $method;
				$display =~ s/volatile-/Packages /;
				$display =~ s/ftp/over FTP/;
				$display =~ s/http/over HTTP/;
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
			if (exists $mirror[$id]{'volatile-architecture'}) {
				print "Archive Architectures: ".join(" ", sort @{$mirror[$id]{'volatile-architecture'}})."\n";
			}
			if (exists $mirror[$id]{'comment'}) {
				print "Comment: ".$mirror[$id]{comment}."\n";
			}
			print "\n";
		}
	}
	print "</pre>\n" if ($html);
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
#	intro();
#	primary_mirrors();
	secondary_mirrors();
	footer_stuff();
}
elsif ($output_type eq 'text') {
	$html=0;
	intro();
#	primary_mirrors();
	secondary_mirrors();
	footer_stuff();
}
elsif ($output_type eq 'apt') {
	print "<pre>\n";
	aptlines();
	print "</pre>\n";
}
elsif ($output_type eq 'fullmethods') {
	$html=1;
	access_methods();
	full_listing();
	footer_stuff();
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
