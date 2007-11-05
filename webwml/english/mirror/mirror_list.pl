#!/usr/bin/perl -w
#
# mirror_list.pl -- generate various Debian mirror lists
# Copyright (C) 1998 James Treacy
# Copyright (C) 2000-2002, 2007 Josip Rodin
# Copyright (C) 2005 Joey Hess

use strict;
require 5.001;

my @filter_arches=qw(); # Architectures not to list.

use Getopt::Long;
my ($mirror_source, $output_type, $help);
my %opthash = (
  "mirror|m=s" => \$mirror_source,
  "type|t=s" => \$output_type,
  "help|h!" => \$help,
  );
Getopt::Long::config('no_getopt_compat', 'no_auto_abbrev');
GetOptions(%opthash) or die "error parsing options";

$output_type = 'html' if (! defined $output_type);
$mirror_source = 'Mirrors.masterlist' if (! defined $mirror_source);

my $last_modify = gmtime((stat($mirror_source))[9]);

my (@mirror, %countries, %countries_sorted, %countries_sponsors, %longest);
my ($count, $nonuscount, $volatilecount, $cdimagecount);

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
  elsif ($line =~ /^([\w-]+-upstream):\s*(.+)\s*$/s) {
    $field = lc $1;
    # no need for this private data in the $mirror hash
    if ($field !~ /^x-/) {
      $mirror[$count-1]{$field} = $2;
    }
  }
  elsif ($line=~ /^((Archive|NonUS|Security|WWW|CDimage|Jigdo|Old|Volatile)-(\w*)):\s*(.*)\s*$/i) {
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
    # no need for this private data in the $mirror hash
    if ($field !~ /^x-/) {
      $mirror[$count-1]{$field} = $2;
      if (!defined($longest{$field}) || length($2) > $longest{$field}) {
        $longest{$field} = length($2);
      }
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
  # TODO make the text version not have such long lines.
  my $format = shift;
  die "must get format for secondary_mirrors()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');
  my $wml = 1 if ($format eq 'wml');

  my $formatstring;
  
  if ($html || $text) {
    print "<h2 align=\"center\">" if $html;
    print "\n\n                   " if $text;
    print "Secondary mirrors of the Debian archive";
    print "\n                   ---------------------------------------\n\n" if $text;
    print "</h2>\n\n" if $html;
    if ($html) {
      print <<END;
<table border="0" align="center">
<tr>
  <th>Host name</th>
  <th>FTP</th>
  <th>HTTP</th>
  <th>Architectures</th>
</tr>
END
    } else {
      my $formatstring = "%-$longest{site}s %-$longest{'archive-ftp'}s %-$longest{'archive-http'}s %s\n";
      printf $formatstring, "HOST NAME", "FTP", "HTTP", "ARCHITECTURES";
      printf $formatstring, "---------", "---", "----", "-------------";
    }
  } elsif ($wml) {
    print "<perl>\n";
  }
  foreach my $country (sort keys %countries) {
    my ($countryplain, $countrycode);
    if ($country =~ /^(..) (.+)$/) {
      $countryplain = $2;
      $countrycode = $1;
    }
    my $hasmirrors = 0;
    foreach my $id (@{ $countries{$country} }) {
      $hasmirrors++ if (defined $mirror[$id]{method}{'archive-ftp'} || defined $mirror[$id]{method}{'archive-http'});
    }
    if ($hasmirrors) {
      print "\n";
      if ($html) {
        print "<tr><td colspan=4><hr size=1></td></tr>\n";
        print "<tr><td colspan=4><big><strong>$country</strong></big></td></tr>\n";
      } elsif ($text) {
        print "$country";
      }
      print "\n";
    } else {
      next;
    }
    my $i = length($country);
    if ($text) {
      print "-" while ($i--); # underline
      print "\n";
    }
    foreach my $id (@{ $countries_sorted{$country} }) {
      next unless (defined $mirror[$id]{method}{'archive-ftp'} || defined $mirror[$id]{method}{'archive-http'});
      my $aliaslist;
      if (exists $mirror[$id]{'aliases'}) {
        if (exists $mirror[$id]{includes}) {
          $aliaslist .= "  (";
          my @tmparray = @{$mirror[$id]{includes}};
          my $notalldone = $#tmparray + 1;
          foreach my $subsite (@{ $mirror[$id]{includes} }) {
            # this is basically a sanity check
            my $subsite_id;
            foreach my $mid (0 .. $#mirror) {
              if ($mirror[$mid]{site} eq $subsite) {
                $subsite_id = $mid;
                last;
              }
            }
            die $subsite ." included in " . $mirror[$id]{site} . " does not exist\n" unless defined $subsite_id; # must be an error
            # this prints the canonical name of the included site rather than its reference - should be in sync, but might actually vary
            $aliaslist .= $mirror[$subsite_id]{site};
            $notalldone--;
            $aliaslist .= ", " if ($notalldone);
          }
          $aliaslist .= ")";
        } else {
          # we want to display aliases in the main list for official mirrors
          # but for others, it's just clutter, so skip them
          next unless ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/);
          my $truename = @{$mirror[$id]{'aliases'}}[0];
          if ($truename =~ /^ftp.+\.debian\.org$/) {
            $truename = @{$mirror[$id]{'aliases'}}[1];
          }
          $aliaslist .= "  (" . $truename . ")";
        }
      }
      if ($html) {
        print "<tr>\n";
        print "<td valign=top>$mirror[$id]{site}";
        print "<br>$aliaslist" if ($aliaslist);
        print "</td>\n";
      } elsif ($text) {
        my $formatstring = "%-$longest{site}s ";
        printf $formatstring, $mirror[$id]{site};
      }
      if (defined $mirror[$id]{method}{'archive-ftp'}) {
        my $rest = $longest{'archive-ftp'} - length($mirror[$id]{method}{'archive-ftp'});
        if ($html) {
          print <<END;
<td valign=top><a href="ftp://$mirror[$id]{site}$mirror[$id]{method}{'archive-ftp'}">$mirror[$id]{method}{'archive-ftp'}</a></td>
END
        } elsif ($text) {
          my $formatstring = "%s%${rest}s";
          printf $formatstring, $mirror[$id]{method}{'archive-ftp'}, '';
        } elsif ($wml) {
          print <<EOF;
  push \@{ \$secondaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
        "<a href=\\\"ftp://$mirror[$id]{site}$mirror[$id]{method}{'archive-ftp'}\\\">$mirror[$id]{method}{'archive-ftp'}</a>";
EOF
        }
      } else {
        if ($html) {
          print "<td></td>\n";
        } elsif ($text) {
          my $formatstring = "%-$longest{'archive-ftp'}s";
          printf $formatstring, " ";
        } elsif ($wml) {
          print <<EOF;
  push \@{ \$secondaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
        "";
EOF
        }
      }
      if (defined $mirror[$id]{method}{'archive-http'}) {
        my $rest = $longest{'archive-http'} - length($mirror[$id]{method}{'archive-http'});
        if ($html) {
          print <<END;
<td valign=top><a href="http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}">$mirror[$id]{method}{'archive-http'}</a></td>
END
        } elsif ($text) {
          my $formatstring = "%s%${rest}s";
          printf $formatstring, $mirror[$id]{method}{'archive-http'}, '';
        } elsif ($wml) {
          print <<EOF;
  push \@{ \$secondaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
        "<a href=\\\"http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}\\\">$mirror[$id]{method}{'archive-http'}</a>";
EOF
        }
      } else {
        if ($html) {
          print "<td></td>\n";
        } elsif ($text) {
          my $formatstring = "%-$longest{'archive-http'}s";
          printf $formatstring, " ";
        } elsif ($wml) {
          print <<EOF;
  push \@{ \$secondaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
        "";
EOF
        }
      }
      my $archlistsorted = join(" ", sort @{$mirror[$id]{'archive-architecture'}});
      if ($html) {
        print "<td valign=top><small><small>$archlistsorted</small></small></td>\n";
      } elsif ($text) {
        print $archlistsorted;
        print "\n";
      } elsif ($wml) {
        print <<EOF;
  push \@{ \$secondaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
        "$archlistsorted";
EOF
      }
      if ($aliaslist) {
        if ($text) {
          print $aliaslist . "\n";
        } elsif ($wml) {
          print <<EOF;
  push \@{ \$secondaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
        "$aliaslist";
EOF
        }
      }
      if ($html) {
        print "</tr>\n";
      }
    }
  }
  if ($wml) {
    # in our WML templates there is a langcmp comparison method,
    # which sorts alphabetically depending on the language
    print <<EOF;
my \%sawcountry = {};
foreach my \$country (sort langcmp keys \%secondaries) {
  unless (\$sawcountry{\$country}) {
    print <<EOM;
<tr><td colspan="4"><hr size="1"></td></tr>
<tr><td colspan="4"><big><strong>\$country</strong></big></td></tr>
EOM
  }
  \$sawcountry{\$country} = 1;
  sub officialfirst {
    (\$b =~ /^ftp\\d?(?:\\.wa)?\\...\\.debian\\.org\$/) <=> (\$a =~ /^ftp\\d?(?:\\.wa)?\\...\\.debian\\.org\$/)
    ||
    \$a cmp \$b;
  }
  foreach my \$countrysite (sort officialfirst keys \%{\$secondaries{\$country}}) {
    my \@elems = \@{\$secondaries{\$country}{\$countrysite}};
    print <<EOM;
<tr>
  <td valign="top"><code>\$countrysite</code>
EOM
    if (\$elems[3]) {
      my \$extraname = \$elems[3];
      \$extraname =~ s%  %\&nbsp\;\&nbsp\;%;
      print <<EOM;
<br>
<code>\$extraname</code>
EOM
    }
    print <<EOM;
  </td>
  <td valign="top">\$elems[0]</td>
  <td valign="top">\$elems[1]</td>
  <td valign="top"><small><small>\$elems[2]</small></small></td>
</tr>
EOM
  }
}
</perl>
EOF
  }
  print "</table>\n" if ($html);
}


sub intro {
  my $format = shift;
  die "must get format for intro()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');

  print "<h1 align=\"center\">" if $html;
  print "                        " if $text;
  print "Debian worldwide mirror sites";
  print "</h1>" if $html;
  print "\n                        -----------------------------\n" if $text;
  print "\n";

  print "<p>" if $html;
  print "Debian is distributed (";
  print $html ? "<em>mirrored</em>" : "mirrored";
  print ") on hundreds of servers on the Internet.\n";
  print <<END;
Using a nearby server will probably speed up your download, and also
reduce the load on our central servers and on the Internet as a whole.

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
  They are all automatically updated whenever there are updates to
  the Debian archive.

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
  my $format = shift;
  die "must get format for primary_mirrors()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');
  my $wml = 1 if ($format eq 'wml');

  my %primaries = ();
  if ($html) {
    print <<END;

<h2 align="center">Primary Debian mirror sites</h2>

<table border="0" align="center">
<tr>
  <th>Country</th>
  <th>Site</th>
  <th>Architectures</th>
</tr>
END
  } elsif ($text) {
    print <<END;


                         Primary Debian mirror sites
                         ---------------------------

 Country         Site                  Debian archive  Architectures
 ---------------------------------------------------------------------------
END
  } elsif ($wml) {
    print <<END;
<perl>
END
  }
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
      next unless ($mirror[$id]{site} =~ /^(?:ftp|http)\d?(?:\.wa)?\...\.debian.org$/);
      my ($countryplain, $countrycode);
      if ($country =~ /^(..) (.+)$/) {
        $countryplain = $2;
        $countrycode = $1;
      }

      unless (exists $mirror[$id]{method}{'archive-http'}) {
        die "official mirror " . $mirror[$id]{site} . " does not have archive-http?!";
      }

      my $arches = join(" ", sort @{$mirror[$id]{'archive-architecture'}});

      if ($html || $wml) {
        $countryplain =~ s/ /&nbsp;/;
      }
      if ($html) {
        print <<END;
<tr>
  <td>$countryplain</td>
  <td><a href="http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}">$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}</a></td>
  <td><small><small>$arches</small></small></td>
</tr>
END
      } elsif ($text) {
        printf " %-14s  %-20s  %-14s  %s\n", $countryplain, $mirror[$id]{site}, $mirror[$id]{method}{'archive-http'}, $arches;
      } elsif ($wml) {
        # this creates a hash of with keys like <DEc>
        # later this gets expanded by WML into forms like
        # Germany or Deutschland
        # the next-level key is the site name, because countries
        # can have more than one site
        print <<EOF;
  push \@{ \$primaries{"<${countrycode}c>"}{"$mirror[$id]{site}"} },
    (
      "$mirror[$id]{method}{'archive-http'}",
      "$arches",
    );
EOF
      }
    }
  }
  if ($wml) {
    # in our WML templates there is a langcmp comparison method,
    # which sorts alphabetically depending on the language
    print <<EOF;
foreach my \$country (sort langcmp keys \%primaries) {
  foreach my \$countrysite (sort keys \%{\$primaries{\$country}}) {
    my \@elems = \@{\$primaries{\$country}{\$countrysite}};
    print <<EOM;
<tr>
  <td>\$country</td>
  <td><a href="http://\$countrysite\$elems[0]">\$countrysite\$elems[0]</a></td>
  <td><small><small>\$elems[1]</small></small></td>
</tr>
EOM
  }
}
</perl>
EOF
  }
  print "</table>\n" if ($html);
}

# meant to be output into a file which is then included into a .wml file
# and processed by WML
sub primary_mirror_sponsors {
  print <<END;
<tr><td colspan="3"><hr></td></tr>
END
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
      next unless ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian.org$/);
      (my $countrycode = $country) =~ s/^(..).*/$1/;
      print <<END;
<tr>
  <td><${countrycode}c></td>
  <td><a href="http://$mirror[$id]{site}$mirror[$id]{method}{'archive-http'}">$mirror[$id]{site}</a></td>
  <td>
END
      if (exists $mirror[$id]{includes}) {
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
          die "can't find $subsite, wtf?!" unless defined $subsite_id; # must be an error
          die "can't find sponsor for $subsite, wtf?!" unless defined $mirror[$subsite_id]{sponsor}; # must be an error

          my $numsponsors = @{ $mirror[$subsite_id]{sponsor} };
          my $num = 0;
          my ($sponsorname, $sponsorurl);
          foreach my $sponsor (@{ $mirror[$subsite_id]{sponsor} }) {
            if ($sponsor =~ /^(.+) (http:.*)$/) {
              $sponsorname = $1;
              $sponsorurl = $2;
            } else {
              die "can't find sponsor URL for sponsor $sponsor of $subsite";
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
                } else {
            die "can't find sponsor URL for sponsor $sponsor of $mirror[$id]{site}";
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
  print "</table>\n";
}

# meant to be output into a file which is then included into a .wml file
# and processed by WML
sub mirror_sponsors {
  print <<END;
<tr><td colspan="3"><hr></td></tr>
END
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries_sponsors{$country} }) {
      (my $countrycode = $country) =~ s/^(..).*/$1/;
      print <<END;
<tr>
  <td>${countrycode} <${countrycode}c></td>
  <td>$mirror[$id]{site}</td>
  <td>
END
      # sites which have Includes don't have to have Sponsor, the included ones
      # have it; and those are looped over separately anyway, so no need to repeat
      next if (exists $mirror[$id]{includes});
      my $numsponsors = @{ $mirror[$id]{sponsor} };
      my $num = 0;
      my ($sponsorname, $sponsorurl);
      foreach my $sponsor (@{ $mirror[$id]{sponsor} }) {
        if ($sponsor =~ /^(.+) (http:.*)$/) {
          $sponsorname = $1;
          $sponsorurl = $2;
              } else {
          die "can't find sponsor URL for sponsor $sponsor of $mirror[$id]{site}";
        }
        $sponsorname =~ s/&(\s+)/&amp;$1/g;
        print "<a href=\"$sponsorurl\">$sponsorname</a>";
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

# meant to be output into a file which is then included into a .wml file
# and processed by WML
sub cdimage_mirrors {
  my $which = shift;
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


# this is likely obsolete
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
<dt><strong>CD Images</strong>
  <dd>Official Debian CD Images. See
  <a href="http://www.debian.org/CD/">http://www.debian.org/CD/</a> for details.
<dt><strong>Old releases</strong>
  <dd>The archive of old released versions of Debian.<br>
  Some of the old releases also included the so-called debian-non-US
  archive, with sections for Debian packages that could not be
  distributed in the US due to software patents or use of encryption.
  The debian-non-US updates were discontinued with Debian 3.1.
<dt><strong>Volatile packages</strong>
  <dd>Packages from the debian-volatile project. See
  <a href="http://www.debian.org/volatile/">http://www.debian.org/volatile/</a> for details.
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
  my $format = shift;
  die "must get format for full_listing()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');
  my $wml = 1 if ($format eq 'wml');

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
    print "<pre>\n";
  }
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
    foreach my $id (@{ $countries_sorted{$country} }) {
      print "Site: $mirror[$id]{site}";
      if (exists $mirror[$id]{'aliases'}) {
        print ", ".join(", ", @{ $mirror[$id]{'aliases'} });
      }
      print "\n";
      warn "undefined type for $mirror[$id]{site}!\n" unless defined $mirror[$id]{'type'};
      $mirror[$id]{'type'} ||= 'leaf';
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
        $display =~ s/volatile-/Volatile packages /;
        $display =~ s/ftp/over FTP/;
        $display =~ s/http/over HTTP/;
        $display =~ s/nfs/over NFS/;
        $display =~ s/rsync/over rsync/;
        if ($method =~ /http/) {
          print $display.":  <a href=\"http://$mirror[$id]{site}$mirror[$id]{method}{$method}\">$mirror[$id]{method}{$method}</a>\n";
        }
        elsif ($method =~ /ftp/) {
          print $display.":  <a href=\"ftp://$mirror[$id]{site}$mirror[$id]{method}{$method}\">$mirror[$id]{method}{$method}</a>\n";
        }
        else {
          print $display.":  ".$mirror[$id]{method}{$method}."\n";
        }
      }
      if (exists $mirror[$id]{'archive-architecture'}) {
        print "Includes architectures: ".join(" ", sort @{$mirror[$id]{'archive-architecture'}})."\n";
      }
      if (exists $mirror[$id]{'ipv6'}) {
        if ($mirror[$id]{ipv6} ne 'no') {
          print "IPv6: ".$mirror[$id]{ipv6}."\n";
        }
      }
      if (exists $mirror[$id]{'comment'}) {
        print "Comment: ".$mirror[$id]{comment}."\n";
      }
      print "\n";
    }
  }
  print "</pre>\n" if ($html);
}

sub nonus_intro {
  my $format = shift;
  die "must get format for nonus_intro()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');

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
END
  print "<p>" if $html;
  print <<END;
You should not need the non-US archive unless you are using a version of
Debian from before Debian 3.1.
END
  print "<p>" if $html;
  print <<END;
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
}

sub nonus_mirrors {
  my $format = shift;
  die "must get format for nonus_mirrors()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');
  my $wml = 1 if ($format eq 'wml');

  foreach my $country (sort keys %countries) {
    my $hasmirrors = 0;
    foreach my $m_id (@{ $countries{$country} }) {
      $hasmirrors++ if (defined $mirror[$m_id]{method}{'nonus-ftp'} || defined $mirror[$m_id]{method}{'nonus-http'});
    }
    my ($countryplain, $countrycode);
    if ($country =~ /^(..) (.+)$/) {
      $countryplain = $2;
      $countrycode = $1;
    }
    if ($hasmirrors) {
      print "\n";
      if ($html) {
        print "<h3>$countryplain</h3>";
      } elsif ($text) {
        print "$countryplain:";
      } elsif ($wml) {
        print "<h3><${countrycode}c></h3>";
      }
      print "\n";
    } else {
      next;
    }
    foreach my $m_id (@{ $countries_sorted{$country} }) {
      if (defined $mirror[$m_id]{method}{'nonus-ftp'}) {
        print "<a href=\"ftp://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-ftp'}\">" if ($html || $wml);
        print "  ftp://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-ftp'}";
        print "</a><br>\n" if ($html || $wml);
        if (defined $mirror[$m_id]{method}{'nonus-http'}) {
          print "\n    ";
          print "<a href=\"http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}\">" if ($html || $wml);
          print "http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}";
          print "</a>\n" if ($html || $wml);
        }
        print "\n\n";
        print "<p>" if ($html || $wml);
      } elsif (defined $mirror[$m_id]{method}{'nonus-http'}) {
        print "  ";
        print "<a href=\"http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}\">" if ($html || $wml);
        print "http://$mirror[$m_id]{site}$mirror[$m_id]{method}{'nonus-http'}";
        print "</a>\n" if ($html || $wml);
        print "\n\n";
        print "<p>" if ($html || $wml);
      }
    }
  }
}

sub nonus_short() {
  foreach my $country (sort keys %countries) {
    my $hasmirrors = 0;
    my %countries_nonus;
    foreach my $m_id (@{ $countries{$country} }) {
      if ( defined($mirror[$m_id]{method}{'nonus-ftp'}) or
           defined($mirror[$m_id]{method}{'nonus-http'}) or
           defined($mirror[$m_id]{method}{'nonus-rsync'}) ) {
        $hasmirrors++;
        push @{ $countries_nonus{$country} }, $m_id;
      }
    }
    next unless ($hasmirrors);
    my $countrycode; my $countryplain;
    if ($country =~ /^(\w\w) (.+)$/) {
      $countrycode = $1;
      $countryplain = $2;
    }
    foreach my $m_id (@{ $countries_nonus{$country} }) {
      print "<li><".$countrycode."c>: " . $mirror[$m_id]{site} . ": ";
      print "<a href=\"http://". $mirror[$m_id]{site} . $mirror[$m_id]{method}{'nonus-http'} ."\">HTTP</a> "
        if (defined $mirror[$m_id]{method}{'nonus-http'});
      print "<a href=\"ftp://". $mirror[$m_id]{site} . $mirror[$m_id]{method}{'nonus-ftp'} ."\">FTP</a> "
        if (defined $mirror[$m_id]{method}{'nonus-ftp'});
      print "rsync&nbsp;". $mirror[$m_id]{site} . "::" . $mirror[$m_id]{method}{'nonus-rsync'}
        if (defined $mirror[$m_id]{method}{'nonus-rsync'});
      print "</li>\n";
    }
  }
}

sub footer_stuff($$) {
  my $format = shift;
  die "must get format for footer_stuff()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');
  my $wml = 1 if ($format eq 'wml');

  my $whichcount = shift;
  die "must get count for footer_stuff()" unless $whichcount;

  if ($html || $wml) {
    print <<END;
<hr>
<table border="0" width="100%"><tr>
  <td align="left"><small>Last modified: $last_modify</small></td>
  <td align="right"><small>Number of sites listed: $whichcount</small></td>
</tr></table>
END
  } elsif ($text) {
    print "\n";
    print "-" x 79 . "\n";
# expecting $last_modify like: Mon Jan  1 00:00:00 0000 - 24 characters wide
# expecting $whichcount to be less than 1k :)
    printf "%-14s %-24s %-11s %-23s %-3d\n",
           'Last modified:', $last_modify, '', 'Number of sites listed:', $whichcount;
  }
}

# fork of secondary_mirrors
# Changed for debian-volatile by Francesco Paolo Lovergine, 2005 
sub volatile_mirrors {
  # TODO make the text version not have such long lines.
  my $format = shift;
  die "must get format for volatile_mirrors()" unless $format;
  my $html = 1 if ($format eq 'html');
  my $text = 1 if ($format eq 'text');
  my $wml = 1 if ($format eq 'wml');

  # temporary, hopefully, until this whole thing is merged somewhere
  $html = 1 if $wml;

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
  my $formatstring = "%-$longest{site}s%-$longest{'volatile-ftp'}s%-$longest{'volatile-http'}s%-$longest{'volatile-rsync'}s%s\n";
  if ($html) {
    print "<table class=\"volatile\"summary=\"Mirrors sorted by Country\">\n";
    print "<colgroup span=\"5\">\n</colgroup>\n";
    print "<thead><tr><th>HOST NAME</th><th>FTP</th><th>HTTP</th><th>RSYNC</th><th>ARCHITECTURES</th></tr></thead>\n<tbody>";
  } else {
    printf $formatstring, "HOST NAME", " FTP", " HTTP", " RSYNC" ,"  ARCHITECTURES";
    printf $formatstring, "---------", " ---", " ----", " -----" ,"  -------------";
  }
  foreach my $country (sort keys %countries) {
    my $hasmirrors = 0;
    my %has_volatile;
    foreach my $id (@{ $countries{$country} }) {
      if (defined $mirror[$id]{method}{'volatile-ftp'} || 
          defined $mirror[$id]{method}{'volatile-http'} || 
          defined $mirror[$id]{method}{'volatile-rsync'}) {
            $hasmirrors++;
            $has_volatile{$id} = 1;
      }
    }
    if ($hasmirrors) {
      print "\n";
      print $html ? "<tr class=\"country\"><th colspan=\"5\">$country</th></tr>" : "$country";
      print "\n";
    } else {
      next;
    }
    if ($text) {
      my $i = length($country);
      print "-" while ($i--); # underline
      print "\n";
    }
    foreach my $id (@{ $countries_sorted{$country} }) {
      next unless $has_volatile{$id};
      if ($html) {
        print "<tr><th>$mirror[$id]{site}</th>";
      } else {
        $formatstring = "%-$longest{site}s ";
        printf $formatstring, $mirror[$id]{site};
      }
      if (defined $mirror[$id]{method}{'volatile-ftp'}) {
        if ($html) {
          print "<td><a href=\"ftp://$mirror[$id]{site}$mirror[$id]{method}{'volatile-ftp'}\">";
          print "$mirror[$id]{method}{'volatile-ftp'}";
          print "</a></td>\n";
        } else {
          my $rest = $longest{'volatile-ftp'} - length($mirror[$id]{method}{'volatile-ftp'});
          $formatstring = "%s%${rest}s";
          printf $formatstring, $mirror[$id]{method}{'volatile-ftp'}, '';
        }
      } else {
        if ($html) {
          print "<td> </td>\n";
        } else {
          $formatstring = "%-$longest{'volatile-ftp'}s";
          printf $formatstring, " ";
        }
      }
      $formatstring = "%-$longest{'volatile-http'}s";
      if (defined $mirror[$id]{method}{'volatile-http'}) {
        if ($html) {
          print "<td><a href=\"http://$mirror[$id]{site}$mirror[$id]{method}{'volatile-http'}\">";
          print "$mirror[$id]{method}{'volatile-http'}";
          print "</a></td>\n";
        } else {
          my $rest = $longest{'volatile-http'} - length($mirror[$id]{method}{'volatile-http'});
          $formatstring = "%s%${rest}s";
          printf $formatstring, $mirror[$id]{method}{'volatile-http'}, '';
        }
      } else {
        if ($html) {
          print "<td> </td>\n";
        } else {
          $formatstring = "%-$longest{'volatile-http'}s";
          printf $formatstring, " ";
        }
      }
      $formatstring = "%-$longest{'volatile-rsync'}s";
      if (defined $mirror[$id]{method}{'volatile-rsync'}) {
        if ($html) {
          print "<td><a href=\"rsync://$mirror[$id]{site}/$mirror[$id]{method}{'volatile-rsync'}\">";
          print "$mirror[$id]{method}{'volatile-rsync'}";
          print "</a></td>\n";
        } else {
          my $rest = $longest{'volatile-rsync'} - length($mirror[$id]{method}{'volatile-rsync'});
          $formatstring = "%s%${rest}s";
          printf $formatstring, $mirror[$id]{method}{'volatile-rsync'}, '';
        }
      } else {
        if ($html) {
          print "<td> </td>\n";
        } else {
          $formatstring = "%-$longest{'volatile-rsync'}s";
          printf $formatstring, " ";
        }
      }
      print "<td>" if ($html);
              if (exists $mirror[$id]{'volatile-architecture'}) {
        print join(" ", sort @{$mirror[$id]{'volatile-architecture'}});
      } else {
        print " all";
      }
      print "</td>\n</tr>" if ($html);
      print "\n";
    }
  }
  print "</tbody>\n</table>\n" if $html;
}


sub mirror_tree_by_origin {
  my %origins;
  foreach my $country (sort keys %countries) {
    foreach my $id (sort @{ $countries{$country} }) {
#      if ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian.org$/) {
      if (exists $mirror[$id]{method}{'archive-http'} or exists $mirror[$id]{method}{'archive-ftp'}) {
        my $tfm = $mirror[$id]{method}{'archive-http'} || $mirror[$id]{method}{'archive-ftp'};
        my $tf = "http://" . $mirror[$id]{site} . $tfm . "project/trace/";
        my $mf;
        if (exists $mirror[$id]{includes}) {
          my $numsubsites = @{ $mirror[$id]{includes} };
          my $snum = 0;
          foreach my $subsite (@{ $mirror[$id]{includes} }) {
            $tf = "http://" . $subsite . $mirror[$id]{method}{'archive-http'} . "project/trace/";
            $mf = exists $mirror[$id]{'archive-upstream'} ? $mirror[$id]{'archive-upstream'} : "ftp-master.debian.org";
            my @mfs = split(',\s*', $mf);
            foreach my $mfss (@mfs) {
              $origins{$mfss}{$subsite} = $tf;
            }
          }
        } else {
          my $mfdefault = $mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian.org$/ ? "ftp-master.debian.org" : "unknown-origin";
          $mf = exists $mirror[$id]{'archive-upstream'} ? $mirror[$id]{'archive-upstream'} : $mfdefault;
          my @mfs = split(',\s*', $mf);
          foreach my $mfss (@mfs) {
            $origins{$mfss}{ $mirror[$id]{site} } = $tf;
          }
        }
      }
    }
  }

  $origins{ 'ftp-master.debian.org' }{ 'syncproxy.eu.debian.org' } = 1;
  $origins{ 'ftp-master.debian.org' }{ 'syncproxy.wna.debian.org' } = 1;

  print "<h2>Mirrors sorted by origin</h2>\n";
  print "<ul>\n";
  print "<li>ftp-master.debian.org</li>";

  sub crawl_origins($%) {
    my $top = shift;
    my %origins = shift;
#      print "<pre>";
#      use Data::Dumper;
#      print Dumper(%origins);
#      print "</pre>";
    print "<ul>\n";
    my @tocheck = ();
    foreach my $o (keys %origins) {
      if ($o ne $top) {
        push @tocheck, $o;
      } else {
        
      }
    }
    my $o; # FIXME
      if ($o ne $top) {
        print "<p>recursing with $o, " . join(",", keys %{$origins{$o}}) . "\n";
#        crawl_origins($o, keys %{$origins{$o}}) unless ($o eq $top);
      } else {
        foreach my $oo (keys %{$origins{$o}}) {
          print "<li>$oo";
          print " (<a href=\"$origins{$o}{$oo}\">p/t</a>)"
        }
      }
    print "</ul>\n";
  }

  crawl_origins('ftp-master.debian.org', %origins);

if (0) {
  print "<ul>\n";
  print "<li>syncproxy.eu.debian.org</li>";
  print "<ul>\n";
  foreach my $o (keys %{$origins{'syncproxy.eu.debian.org'}}) {
    print "<li>$o";
    print " (<a href=\"". $origins{'syncproxy.eu.debian.org'}{$o} ."\">p/t</a>)";
    print "<ul>\n";
    foreach my $oo (keys %{$origins{$o}}) {
      print "<li>$oo";
      print " (<a href=\"$origins{$o}{$oo}\">p/t</a>)";
      delete $origins{$o}{$oo};
    }
    print "</ul>\n";
    delete $origins{'syncproxy.eu.debian.org'}{$o};
  }
  print "</ul>\n";
  print "<li>syncproxy.wna.debian.org</li>";
  print "<ul>\n";
  foreach my $o (keys %{$origins{'syncproxy.wna.debian.org'}}) {
    print "<li>$o";
    print " (<a href=\"". $origins{'syncproxy.wna.debian.org'}{$o} ."\">p/t</a>)";
    print "<ul>\n";
    foreach my $oo (keys %{$origins{$o}}) {
      print "<li>$oo";
      print " (<a href=\"$origins{$o}{$oo}\">p/t</a>)";
      delete $origins{$o}{$oo};
    }
    print "</ul>\n";
    delete $origins{'syncproxy.wna.debian.org'}{$o};
  }
  print "</ul>\n";
  foreach my $o (keys %{$origins{'ftp-master.debian.org'}}) {
    next if ($o =~ /^syncproxy.(eu|wna).debian.org$/);
    print "<li>$o";
    print " (<a href=\"". $origins{'ftp-master.debian.org'}{$o} ."\">p/t</a>)";
    print "<ul>\n";
    foreach my $oo (keys %{$origins{$o}}) {
      print "<li>$oo";
      print " (<a href=\"$origins{$o}{$oo}\">p/t</a>)";
      delete $origins{$o}{$oo};
    }
    print "</ul>\n";
    delete $origins{'ftp-master.debian.org'}{$o};
  }
  print "<pre>";
  use Data::Dumper;
  print Dumper(%origins);
  print "</pre>";
  print "<li>unknown-origin</li>";
  foreach my $o (keys %origins) {
    print "<ul>\n";
    foreach my $oo (keys %{$origins{$o}}) {
      print "<li>$oo";
      print " (<a href=\"$origins{$o}{$oo}\">p/t</a>)"
    }
    print "</ul>\n";
  }
  print "<ul>\n";
  print "</ul>\n";
  print "</ul>\n";

} # if (0)

}

######### Begin main routine ###########################

if (defined $help) {
  print_help();
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
  } elsif (/^$/) {
    process_line($current);
    $current = '';
    next;
  } elsif (/^\s+(.*)$/) { # add line to current entry
    $current .= "\n$1";
  } elsif (/^[\w-]+:\s/) {
    if ($current ne "") { # need to process previous line
      process_line($current);
    }
    $current = $_;
  } else {
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

# count the number of mirrors
# the masterlist parser's $count included the filtered sites
$count = @mirror;

foreach my $id (0..$#mirror) {
  $nonuscount++ if (defined $mirror[$id]{method}{'nonus-ftp'} || defined $mirror[$id]{method}{'nonus-http'});
  $volatilecount++ if (defined $mirror[$id]{method}{'volatile-ftp'} || defined $mirror[$id]{method}{'volatile-http'});
}

# Create arrays of countries, with their mirrors.
foreach my $id (0..$#mirror) {
  if (exists $mirror[$id]{country}) {
    push @{ $countries{$mirror[$id]{country}} }, $id;
    if (exists $mirror[$id]{sponsor}) {
      push @{ $countries_sponsors{$mirror[$id]{country}} }, $id;
# optionally do this...
#      if ((defined $mirror[$id]{method}{'archive-ftp'} ||
#           defined $mirror[$id]{method}{'archive-http'} ||
#           defined $mirror[$id]{method}{'nonus-ftp'} ||
#           defined $mirror[$id]{method}{'nonus-http'} ||
#           defined $mirror[$id]{method}{'cdimage-ftp'} ||
#           defined $mirror[$id]{method}{'cdimage-http'} ||
#           defined $mirror[$id]{method}{'volatile-ftp'} ||
#           defined $mirror[$id]{method}{'volatile-http'} ||
#  ...
# but this would be fairly tedious and hardcoded, for no apparent reason
# because we use this in mirror_sponsors() which doesn't really care
    }
  } else {
    warn "found a mirror without a country, wtf? " . $mirror[$id]{site};
  }
}

# Sort the country info arrays to first list the official sites,
# then the unofficial sites, but exclude special Debian sites
foreach my $country (sort keys %countries) {
  my %countries_sorted_o; my %countries_sorted_u;
  foreach my $id (@{ $countries{$country} }) {
    if ($mirror[$id]{site} =~ /^ftp\d?(?:\.wa)?\...\.debian\.org$/) {
      push @{ $countries_sorted_o{$country} }, $id;
    } elsif ($mirror[$id]{site} !~ /^(ftp-master|www-master|ftp)\.debian\.org$/) {
      push @{ $countries_sorted_u{$country} }, $id;
    }
  }
  # merge the reordered lists into %countries_sorted
  # (there's got to be a cleaner way to do this, but hey)
  foreach my $id (@{ $countries_sorted_o{$country} }) {
    push @{ $countries_sorted{$country} }, $id;
  }
  undef %countries_sorted_o;
  foreach my $id (@{ $countries_sorted_u{$country} }) {
    push @{ $countries_sorted{$country} }, $id;
  }
  undef %countries_sorted_u;
}

if ($output_type eq 'html') {
  header();
  intro('html');
  primary_mirrors('html');
  secondary_mirrors('html');
  footer_stuff('html', $count);
  trailer();
} elsif ($output_type eq 'text') {
  intro('text');
  primary_mirrors('text');
  secondary_mirrors('text');
  footer_stuff('text', $count);
} elsif ($output_type eq 'wml-primary') {
  primary_mirrors('wml');
} elsif ($output_type eq 'wml-secondary') {
  secondary_mirrors('wml');
} elsif ($output_type eq 'wml-footer') {
  footer_stuff('wml', $count);
} elsif ($output_type eq 'apt') {
  header();
  print "<pre>\n";
  aptlines();
  print "</pre>\n";
  trailer();
} elsif ($output_type eq 'fullmethods') { # this is likely obsolete
  header();
  access_methods();
  full_listing('html');
  footer_stuff('html', $count);
  trailer();
} elsif ($output_type eq 'wml-full') {
  full_listing('wml');
  footer_stuff('wml', $count);
} elsif ($output_type eq 'nonus') {
  nonus_intro('text');
  nonus_mirrors('text');
  footer_stuff('text', $nonuscount);
} elsif ($output_type eq 'nonushtml') {
  header("non-US ");
  nonus_intro('html');
  nonus_mirrors('html');
  footer_stuff('html', $nonuscount);
  trailer();
} elsif ($output_type eq 'nonusshort') {
  nonus_short();
} elsif ($output_type eq 'wml-nonus') {
  nonus_mirrors('wml');
  footer_stuff('wml', $nonuscount);
} elsif ($output_type eq 'officialsponsors') {
  primary_mirror_sponsors();
} elsif ($output_type eq 'sponsors') {
  mirror_sponsors();
} elsif ($output_type eq 'cdimages-httpftp') {
  cdimage_mirrors("httpftp");
} elsif ($output_type eq 'cdimages-rsync') {
  cdimage_mirrors("rsync");
} elsif ($output_type eq 'volatile-wml') {
  volatile_mirrors('wml');
  footer_stuff('wml', $volatilecount);
} elsif ($output_type eq 'origins') {
  mirror_tree_by_origin();
} else {
  die "Error: unknown output type requested, $output_type\n";
}

sub print_help {
  print <<END;
Usage: $0 [mt|--type type] [-m|--mirror mirror_list_source]

`mirror_list_source\' is usually the Mirrors.masterlist file
`type\' can be one of:
    html      (the default)
    text
    wml-primary
    wml-secondary
    wml-footer
    apt
    fullmethods
    nonus
    nonushtml
    nonusshort
    officialsponsors
    sponsors
    cdimages-httpftp
    cdimages-rsync
    volatile-html
END
}
