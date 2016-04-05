#!/usr/bin/perl
#
# parse-dla.pl
#
# Copyright © 2016 Frank Lichtenheld
# Based on parse-advisories.pl: 
# Copyright (C) 2001 Josip Rodin
# Copyright (c) 2002,3 Josip Rodin, Martin Schulze
# Licensed under the GNU General Public License version 2.

use strict;
use warnings;

use File::Path qw(remove_tree make_path);

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
my %shortmoy = ( en => [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ]
);

open my $fh, '<', $adv or die "couldn't open advisory file $adv: $!\n";
my ($dla, $date, $package, @dbids, $moreinfo, $year);
my ($nl, $mi, $headersnearingend);
foreach my $l (<$fh>) {
  if ($l =~ /Subject.*:.*\[(DLA[- ]\d+-\d+)\]/) {
    $dla = $1;
  }
  if ($l =~ /Date.*:.*\s(\d+)\s+(\w+)\s+(\d+)/) {
      my $month = $2; my $day = $1; $year = $3;
      my $i = 0;
      while ($i < 12) {
	  if ($month eq $longmoy{en}[$i]) {
	      $month = $i + 1;
	      $date = "$year-$month-$day";
	      $i = 12;
	  }
	  elsif ($month eq $shortmoy{en}[$i]) {
	      $month = $i + 1; 
	      $date = "$year-$month-$day";
	      $i = 12;
	  }
	  $i++
      }
  }
  if ($l =~ /Package(?:s)*\s*: (.+)\s*/) {
    $package = $1;
  }
  if ($l =~ /^(Debian Bug\(?s?\)?)\s*: (.+)/i) {
      for my $id (split (/,? /, $2)) {
	  push @dbids, "Bug#".$id if ($id ne "none");
      }
  }
  if ($l =~ /^(CVE (names?|id\(?s?\)?|references?)?|CERT advisor(y|ies))\s*: (.+)/i) {
    push @dbids, join (" ", split (/,? /, $4));
  }
  if ($l =~ /^\s+((?:CVE-\d+-\d+[ ]*)+)$/i) {
    push @dbids, join (" ", split (/,? /, $1));
  }
  if ($l =~ /^\s+((?:VU#\d+[ ]*)+)$/i) {
    push @dbids, join (" ", split (/,? /, $1));
  }
  if ($l =~ /^Bugtraq Ids?\s*: (.+)/i) {
      for my $id (split (/,? /, $1)) {
	  push @dbids, "BID".$id;
      }
  }
  last if ($l =~ /Learn more about the/i);
  last if ($l =~ /Thanks to.+for proof read/i);
  last if ($l =~ /Regards,/i);
  last if ($l =~ /^-- /);
  last if ($l =~ /^Ben Hutchings/);
  last if ($l =~ /^Support Debian LTS:/);
  last if ($l =~ /^-----BEGIN PGP SIGNATURE/);
  last if ($l =~ /^Attachment: /);
  #$mi = 0 if ($l =~ /^(wget url|Obtaining updates|Upgrade Instructions)/i);
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
  $headersnearingend++ if ($l =~ /Package(?:s)*\s*:/);
  if ($headersnearingend && $l =~ /^\s*$/) {
    $mi++;
    $headersnearingend = 0;
  }

}
close $fh;


$moreinfo =~ s/(- )?-+\n//g;
$moreinfo =~ s/\n\n$/\n/s;
$moreinfo =~ s/\n<p>\n$//;
$moreinfo =~ s/\n<p>note\:/<p><b>Note<\/b>:/ig;
$moreinfo =~ s/(\s)"(\w[\w\.,'\(\)\s]*?\w)"([\:\.',\(\)\s])/$1<q>$2<\/q>$3/g;
$moreinfo =~ s/(\s)'(\w[\w\.,\(\)\s]*?\w)'([\:\.,\(\)\s])/$1<q>$2<\/q>$3/g;
$moreinfo =~ s|\n+(<p>(CAN\|CVE)-\d+-\d+[\:]*)\s?(\s*)(\S+)|\n\n$1\n$3$4|g;
$moreinfo =~ s/\n\n/<\/p>\n\n/sg;
$moreinfo =~ s|\n<p>((CAN\|CVE)-\d+-\d+[^\n]*)</p>\n|\n<li>$1\n|g;
$moreinfo =~ s|\n<p>((CAN\|CVE)-\d+-\d+[^\n]*)\n|\n<li>$1\n<p>\n|g;
$moreinfo =~ s|((CAN\|CVE)-\d+-\d+)|<a href="https://security-tracker.debian.org/tracker/$1">$1</a>|g;
$moreinfo =~ s|</p>\n\n<p>\n<p>(\w* \w* stable)|</p></li>\n\n</ul>\n\n<p>$1|; 
$moreinfo =~ s|<p>(\s+)|$1<p>|g;
$moreinfo =~ s|<p><p>|<p>|g;
$moreinfo =~ s|</p>\n\n<li>|</p></li>\n\n<li>|g;
$moreinfo =~ s|</li>\n\n<li>|\n\n<ul>\n\n<li>|;
$moreinfo =~ s|(\s+)(http://[^\s<>{}\\^\[\]\"\'\`]+)|$1<a href="$2">$2</a>|g;

if (($moreinfo =~ /<ul>\n\n<li>/) && ($moreinfo !~ /<\/li>\n\n<\/ul>/)){
   $moreinfo =~ s{</p>\n\n<p>((\w+ \w+ \w* ?(old ?stable|stable|testing))|Th[eo]se)}{</p></li>\n\n</ul>\n\n<p>$1}; }
chomp ($moreinfo);

my ($wml, $data, $pagetitle);
if (defined($package) && $dla =~ /DLA[- ](\d+)-(\d+)/ ) {
    my $dla_number=$1;
    my $dla_revision=$2;
    $wml = "$year/dla-$dla_number.wml";
    $data = "$year/dla-$dla_number.data";
    $pagetitle = "DLA-$dla_number-$dla_revision $package";
} elsif (! defined $package){
    die "Could not parse advisory filename '$adv'. Package information missing\n";
} else {
    die "Could not parse advisory filename '$adv'. DLA name missing\n";
}
$data = $wml = "-" if ($debug);

if (!(-d $year)){
  die "directory $year does not exist!\n";
}

&make_data;
&make_wml;
print "double check the content of $wml and $data, and eventually fix it before commit them.\n";

sub make_data{
  if (-f $data){
    print "$data already exists!\n";
    return;
  }
  open DATA, ">", "$data";
  print DATA "<define-tag pagetitle>$pagetitle</define-tag>\n";
  print DATA "<define-tag report_date>$date</define-tag>\n";
  print DATA "<define-tag secrefs>@dbids</define-tag>\n" if @dbids;
  print DATA "<define-tag packages>$package</define-tag>\n";
  print DATA "<define-tag isvulnerable>yes</define-tag>\n";
  print DATA "<define-tag fixed>yes</define-tag>\n";
  print DATA "<define-tag fixed-section>no</define-tag>\n"; # Kaare, 2011-01-24: Line added because the "fixed in" section is no longer available
  print DATA "\n#use wml::debian::security\n\n";
  close DATA;
}

sub make_wml{
  if (-f $wml){
    print "$wml already exists!\n";
    return;
  }
  open WML, ">", "$wml";
  print WML "<define-tag description>LTS security update</define-tag>\n";
  print WML "<define-tag moreinfo>$moreinfo</p>\n</define-tag>\n";
  print WML "\n# do not modify the following line\n";
  print WML "#include \"\$(ENGLISHDIR)/security/$data\"\n";
  printf WML "# %sId: \$\n", "\$";
  close WML;
}

