#!/usr/bin/perl
# this script parses files in pandora:/org/security.debian.org/advisories/DSA/
# and makes wmls out of them

# made by Joy, 2001.

my $adv = $ARGV[0];

$adv || die "you must specify a parameter (original advisory file)!\n";
die "that advisory file either ain't there or doesn't have anything in it!\n" unless -s $adv;

# i'm lame, so shoot me
my %longmoy = (	en => [ 
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December' ]
);

my $curyear = qx "date +%Y"; chomp $curyear;
my $mlURL = "http://lists.debian.org/debian-security-announce/debian-security-announce-$curyear/";

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
  }
  if ($l =~ /^(CVE (name|id)?|CERT advisory)\s*: (.+)/i) {
    push @dbids, $3;
  }
  $mi = 0 if ($l =~ /^wget url/);
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
  if ($headersnearingend && $l !~ /^.{15}: .+$/) {
    $mi++;
    $headersnearingend = 0;
  }

  $f++ if ($l =~ /^  Source archives:/);
  $f = 0 if ($l =~ /^  These (files|packages) will (probably )?be moved/);
  $f = 0 if ($l =~ /^(- )?-- $/);
  $files .= $l if ($f);
}
close ADV;

$moreinfo =~ s/\n\n$/\n/s;
$files =~ s/\n\n$/\n/s;

$files =~ s/      (Size\/)?MD5 checksum: (\s*\d+ )?\w{32}\n//sg;
$files =~ s/  Source archives:/<dt><source>/s;
$files =~ s/  Architecture.independent.\w+:\n/<dt><arch-indep>\n/s;
$files =~ s/  (\w+) architecture \(([\w -()\/]+)\)/<dt>$1 ($2):/sg;
$files =~ s/  ([\w -]+) architecture:/<dt>$1:/sg;
$files =~ s/    (http:\S+)/  <dd><fileurl $1>/sg;

($pagetitle = $adv) =~ s/dsa/DSA/;
$pagetitle =~ s/\./ /;

if ($adv =~ /(dsa-\d+)-\d+\./) {
  $wml = "$1.wml";
}
die "$wml already exists!\n" if (-f $wml);
($data = $wml) =~ s/.wml/.data/;
die "$data already exists!\n" if (-f $data);

open DATA, ">$data";
print DATA "<define-tag pagetitle>$pagetitle</define-tag>\n";
print DATA "<define-tag report_date>$date</define-tag>\n";
print DATA "<define-tag secrefs>@dbids</define-tag>\n" if @dbids;
print DATA "<define-tag packages>$package</define-tag>\n";
print DATA "<define-tag isvulnerable>yes</define-tag>\n";
print DATA "<define-tag fixed>yes</define-tag>\n";
print DATA "\n#use wml::debian::security\n\n";
print DATA "<h3>Debian GNU/Linux 2.2 (potato)</h3>\n\n";
print DATA "<dl>\n$files</dl>\n";
print DATA "\n<p><md5sums $mlURL>\n";
close DATA;

open WML, ">$wml";
print WML "<define-tag description>$desc</define-tag>\n";
print WML "<define-tag moreinfo>$moreinfo</define-tag>\n";
print WML "\n# do not modify the following line\n";
print WML "#include \"\$(ENGLISHDIR)/security/$curyear/$data\"\n";
close WML;

print "Now edit $data and remove any English-specific stuff from it.\n";
print "\n";
print "Also, go to $mlURL\n";
print "find $dsa, then put a link to that page on the last line of $data.\n";
