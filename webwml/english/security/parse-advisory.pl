#!/usr/bin/perl
# this script parses files in pandora:/org/security.debian.org/advisories/DSA/
# and makes wmls out of them

# made by Joy, 2001.

my $adv = $ARGV[0];

# i'm lame, so shoot me
my %longmoy = (	en => [ 
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December' ]
);

open ADV, $adv;
foreach $l (<ADV>) {
  if ($l =~ /^Debian Security Advisory (DSA-\d+-\d+)/) {
    $dsa = $1;
  }
  if ($l =~ /^(\w+) (\d+), (\d+)/) {
    $month = $1; $day = $2; $year = $3;
    for ($i = 0; $i < 12; $i++) {
      if ($month eq $longmoy{en}[$i]) {
        $date = "$year-$i-$day";
      }
    }
  }
  if ($l =~ /^Package        : (.+)/) {
    $package = $1;
  }
  if ($l =~ /^Problem type   : (.+)/) {
    $desc = $1;
  }
  $mi = 0 if ($l =~ /^wget url/);
  $moreinfo .= $l if ($mi);
  $mi++ if ($l =~ /^Debian-specific:/);

  $f++ if ($l =~ /^  Source archives:/);
  $f = 0 if ($l =~ /^  These (files|packages) will be moved/);
  $files .= $l if ($f);
}
close ADV;

$files =~ s/      MD5 checksum: \w{32}\n//sg;
$files =~ s/  Source archives:/<dt>Source:/sg;
$files =~ s/  Architecture/<dt>Architecture/sg;
$files =~ s/  ([\w ]+) architecture:/<dt>$1:/sg;
$files =~ s/    (http:\S+)/  <dd><fileurl $1>/sg;

($pagetitle = $dsa) =~ s/dsa/DSA/;
$pagetitle =~ s/\./ /;

if ($adv =~ /(dsa-\d+)-\d+\./) {
  $wml = "$1.wml";
}
die "$wml already exists\!" if (-f $wml);
open WML, ">$wml";
print WML "<define-tag pagetitle>$pagetitle</define-tag>\n";
print WML "<define-tag report_date>$date</define-tag>\n";
print WML "<define-tag packages>$package</define-tag>\n";
print WML "<define-tag description>$desc</define-tag>\n";
print WML "<define-tag isvulnerable>yes</define-tag>\n";
print WML "<define-tag fixed>yes</define-tag>\n";
print WML "<define-tag moreinfo>$moreinfo</define-tag>\n";
print WML "\n#use wml::debian::security\n\n";
print WML "<h3>Debian GNU/Linux 2.2 (`potato')</h3>\n\n";
print WML "<dl>\n$files</dl>\n";
close WML;
