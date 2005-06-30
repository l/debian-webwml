#!/usr/bin/perl
#
# parse-advisory.pl
#
# this script parses files in
# security.debian.org:/org/security.debian.org/advisories/DSA/
# and makes wmls out of them
# 
# Copyright (C) 2001 Josip Rodin
# Copyright (c) 2002,3 Josip Rodin, Martin Schulze
# Licensed under the GNU General Public License version 2.

my $debug = 0;
my $adv = $ARGV[0];
if ($adv eq "-d") {
    $debug = 1;
    $adv = $ARGV[1];
}

$adv || die "you must specify a parameter (original advisory file)!\n";
die "that advisory file either ain't there or doesn't have anything in it!\n" unless -s $adv;

# i'm lame, so shoot me
my %longmoy = (	en => [ 
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December' ]
);

my $curyear = (localtime())[5] + 1900;
my $mlURL = "http://lists.debian.org/debian-security-announce/debian-security-announce-$curyear/";

my %arch = (
	    'alpha'   => 'Alpha',
	    'hppa'    => 'HP Precision',
	    'i386'    => 'Intel IA-32',
	    'ia64'    => 'Intel IA-64',
	    'm68k'    => 'Motorola 680x0',
	    'mips'    => 'Big-endian MIPS',
	    'mipsel'  => 'Little-endian MIPS',
	    's390'    => 'IBM S/390',
	    'sparc'   => 'Sun Sparc',
	    'powerpc' => 'PowerPC',
	    'arm'     => 'ARM',
	    );

open ADV, $adv;
foreach $l (<ADV>) {
  if ($l =~ /^Debian Security Advisory (DSA[- ]\d+-\d+)/) {
    $dsa = $1;
  }
  if ($l =~ /^(\w+)\s+(\d+)(\D\D)?, (\d+)/) {
    $month = $1; $day = $2; $year = $4;
    while ($i < 12) {
      if ($month eq $longmoy{en}[$i]) {
        $month = $i + 1;
        $date = "$year-$month-$day";
        $i = 12;
      }
      $i++
    }
  }
  if ($l =~ /^Package\s*: (.+)/) {
    $package = $1;
  }
  if ($l =~ /^(Problem type|Vulnerability)\s*: (.+)/) {
    $desc = $2;
    $desc .= ' vulnerabilities' if $desc =~ /(several|multiple)\s*$/;
  }
  if ($l =~ /^(Debian Bugs?)\s*: (.+)/i) {
      for $id (split (/,? /, $2)) {
	  push @dbids, "Bug#".$id;
      }
  }
  if ($l =~ /^(CVE (names?|ids?|references?)?|CERT advisor(y|ies))\s*: (.+)/i) {
    push @dbids, join (" ", split (/,? /, $4));
  }
  if ($l =~ /^Bugtraq Ids?\s*: (.+)/i) {
      for $id (split (/,? /, $1)) {
	  push @dbids, "BID".$id;
      }
  }
  $mi = 0 if ($l =~ /^(wget url|Obtaining updates|Upgrade Instructions)/);
  $moreinfo .= "<p>" if ($mi && $nl);
  $nl = 0;
  $nl = 1 if ($mi && ($l eq "\n") && $moreinfo);
  if ($mi) {
    if ($mi > 1) {
      $moreinfo .= $l;
    } else {
      $moreinfo .= "\n<p>".$l;
      $mi++;
    }
  }
  $headersnearingend++ if ($l =~ /^Debian-specific:/);
  if ($headersnearingend && $l !~ /^.{15}:.*$/) {
    $mi++;
    $headersnearingend = 0;
  }

  $f++ if ($l =~ /^Debian (GNU\/Linux.*alias|.*\(.*\)).*/);
  $f = 0 if ($l =~ /^((- )?-- |(  )?These (files|packages) will (probably )?be moved)/);
  $files .= $l if ($f);
}
close ADV;


$moreinfo =~ s/(- )?-+\n//g;
$moreinfo =~ s/\n\n$/\n/s;
$moreinfo =~ s/\n<p>\n$//;
$moreinfo =~ s/\n\n/<\/p>\n\n/sg;
$moreinfo =~ s|\n<p>(CAN-\d+-\d+[^\n]*)</p>\n|\n<li>$1\n|g;
$moreinfo =~ s|(CAN-\d+-\d+)|<a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=$1">$1</a>|g;
$moreinfo =~ s|<p>(\s+)|$1<p>|g;
chomp ($moreinfo);
$files =~ s/(- )?-+\n//g;
$files =~ s/\n\n$/\n/s;

$files =~ s/      (Size\/)?MD5 checksum: (\s*\d+ )?\w{32}\n//sg;
$files =~ s/  Source archives:/<dt><source \/>/sg;
$files =~ s/  Architecture.independent \w+:\n/<dt><arch-indep \/>\n/sg;
$files =~ s/HP Precision architecture/HPPA architecture/gi;
$files =~ s/  (\w+) architecture \(([\w -()\/]+)\)/<dt>$arch{$1}:/sg;
$files =~ s/  ([\w -\/]+) architecture:/<dt>$1:/sg;
$files =~ s/    (http:\S+)/  <dd><fileurl $1 \/>/sg;
$files =~ s,[\n]?Debian (GNU/Linux )?(\S+) (alias |\()([a-z]+)\)?,</dl>\n\n<h3>Debian GNU/Linux $2 ($4)</h3>\n\n<dl>,sg;

my @f = ();
my $ign = 0;
foreach $_ (split (/\n/, $files)) {
    if (!$ign && /was released/) {
	$ign = 1;
    } elsif ($ign && /^$/) {
	$ign = 0;
    } elsif (!$ign) {
	push (@f, $_);
    }
}
$files = join ("\n", @f);

$adv =~ /.*dsa[- ](\d+)-(\d+)\.(.*)/;
$wml = "$curyear/dsa-$1.wml";
$data = "$curyear/dsa-$1.data";
$pagetitle = "DSA-$1-$2 $3";

$data = $wml = "-" if ($debug);

die "$wml already exists!\n" if (-f $wml);
die "$data already exists!\n" if (-f $data);

$files =~ s,^</dl>\n\n,,;
open DATA, ">$data";
print DATA "<define-tag pagetitle>$pagetitle</define-tag>\n";
print DATA "<define-tag report_date>$date</define-tag>\n";
print DATA "<define-tag secrefs>@dbids</define-tag>\n" if @dbids;
print DATA "<define-tag packages>$package</define-tag>\n";
print DATA "<define-tag isvulnerable>yes</define-tag>\n";
print DATA "<define-tag fixed>yes</define-tag>\n";
print DATA "\n#use wml::debian::security\n\n";
print DATA "$files\n\n</dl>\n";
print DATA "\n<p><md5sums $mlURL /></p>\n";
close DATA;

open WML, ">$wml";
print WML "<define-tag description>$desc</define-tag>\n";
print WML "<define-tag moreinfo>$moreinfo</p>\n</define-tag>\n";
print WML "\n# do not modify the following line\n";
print WML "#include \"\$(ENGLISHDIR)/security/$data\"\n";
printf WML "# %sId: \$\n", "\$";
close WML;

print "Now edit $data and remove any English-specific stuff from it.\n";
print "\n";
print "Also, go to $mlURL\n";
print "find $dsa, then put a link to that page on the last line of $data .\n";
