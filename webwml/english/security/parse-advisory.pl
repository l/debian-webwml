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

use WWW::Mechanize;
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

my $curyear = (localtime())[5] + 1900;

my %arch = (
	    'alpha'   => 'Alpha',
	    'amd64'   => 'AMD64',
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
	    'armel'   => 'ARM EABI',
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
      elsif ($month eq $shortmoy{en}[$i]) {
        $month = $i + 1; 
        $date = "$year-$month-$day";
        $i = 12;
      }
      $i++
    }
  }
  if ($l =~ /^Package(?:s)*\s*: (.+)\s*/) {
    $package = $1;
  }
  if ($l =~ /^(Vulnerability)\s*: (.+)\s*/) {
    $desc = $2;
    $desc .= ' vulnerabilities' if $desc =~ /(several|multiple)\s*$/;
  }
  if ($l =~ /^(Debian Bug\(?s?\)?)\s*: (.+)/i) {
      for $id (split (/,? /, $2)) {
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
      for $id (split (/,? /, $1)) {
	  push @dbids, "BID".$id;
      }
  }
  last if ($l =~ /Further information about Debian Security Advisories.*$/i);
  last if ($l =~ /Thanks to.+for proof read/i);
  $mi = 0 if ($l =~ /^(wget url|Obtaining updates|Upgrade Instructions)/i);
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
  if ($headersnearingend && $l =~ /^\s*$/) {
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
$moreinfo =~ s|\n+(<p>(CAN\|CVE)-\d+-\d+[\:]*)\s?(\s*)(\S+)|\n\n$1\n$3$4|g;
$moreinfo =~ s/\n\n/<\/p>\n\n/sg;
$moreinfo =~ s|\n<p>((CAN\|CVE)-\d+-\d+[^\n]*)</p>\n|\n<li>$1\n|g;
$moreinfo =~ s|\n<p>((CAN\|CVE)-\d+-\d+[^\n]*)\n|\n<li>$1\n<p>\n|g;
$moreinfo =~ s|((CAN\|CVE)-\d+-\d+)|<a href="http://security-tracker.debian.org/tracker/$1">$1</a>|g;
$moreinfo =~ s|</p>\n\n<p>\n<p>(\w* \w* stable)|</p></li>\n\n</ul>\n\n<p>$1|; 
$moreinfo =~ s|<p>(\s+)|$1<p>|g;
$moreinfo =~ s|<p><p>|<p>|g;
$moreinfo =~ s|</p>\n\n<li>|</p></li>\n\n<li>|g;
$moreinfo =~ s|</li>\n\n<li>|\n\n<ul>\n\n<li>|;
$moreinfo =~ s|(\s+)(http://[^\s<>{}\\^\[\]\"\'\`]+)|$1<a href="$2">$2</a>|g;

# matrix creation start
#  in matrix lines, each item cannot have space charecter sequence in it
#     space charecter sequence (>=2) is treated as a delimiter
# $matrix_h is used as header and $matrix_f is used as footer
my $matrix_h = qq|<div class="centerdiv">\n  <table cellspacing="0" cellpadding="2">\n|;
my $matrix_f = "  </table>\n</div>\n";
$moreinfo =~ s{(<p>The following matrix[\s\S]+?</p>\n+)\s+<p>([\s\S]+?)</p>}{$1<matrix>\n&nbsp;  $2\n</matrix>}g;
$moreinfo =~ m|<matrix>\n([\s\S]+?)</matrix>|;
my $matrix = $1;
$matrix =~ s/\n\s+/\n/g;
my @matrixl = split(/\n/,$matrix);
for my $i(0 .. $#matrixl){
  $matrixl[$i] = "    <tr>\n      <td>" .
		 join("</td>\n      <td>", split(/\s{2,}/,$matrixl[$i])) .
		 "</td>\n    </tr>\n";
# 1st line, use <th>
  $matrixl[$i] =~ s/td>/th>/g if($i<1);
}
$matrix = join("", @matrixl);
$moreinfo =~ s|<matrix>\n([\s\S]+?)</matrix>|$matrix_h$matrix$matrix_f|;
# matrix end

if (($moreinfo =~ /<ul>\n\n<li>/) && ($moreinfo !~ /<\/li>\n\n<\/ul>/)){
   $moreinfo =~ s{</p>\n\n<p>((\w+ \w+ \w* ?(old ?stable|stable|testing))|Th[eo]se)}{</p></li>\n\n</ul>\n\n<p>$1}; }
chomp ($moreinfo);

$files =~ s/(- )?-+\n//g;
$files =~ s/\n\n$/\n/s;

$files =~ s/.+ updates are available for .+\n//g;

$files =~ s/(  )?    (Size\/)?MD5 checksum: (\s*\d+ )?\w{32}\n//sg;
$files =~ s/(  )?Source archives:/<dt><source \/>/sg;
$files =~ s/(  )?Architecture.independent \w+:\n/<dt><arch-indep \/>\n/sg;
$files =~ s/HP Precision architecture/HPPA architecture/gi;
$files =~ s/(?:  )?(\w+) architecture \(([\w -()\/]+)\)/<dt>$arch{$1}:/sg;
$files =~ s/(?:  )?([\w -\/]+) architecture:/<dt>$1:/sg;
$files =~ s/(?:  )?  (http:\S+)/  <dd><fileurl $1 \/>/sg;
$files =~ s,[\n]?Debian (GNU/Linux )?(\S+) (alias |\()([a-z]+)\)?,</dl>\n\n<h3>Debian $2 ($4)</h3>\n\n<dl>,sg;

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

if (defined($package) && $dsa =~ /DSA[- ](\d+)-(\d+)/ ) {
    $dsa_number=$1;
    $dsa_revision=$2;
    $wml = "$curyear/dsa-$dsa_number.wml";
    $data = "$curyear/dsa-$dsa_number.data";
    $pagetitle = "DSA-$dsa_number-$dsa_revision $package";
} else {
    die ("Could not parse advisory filename '$adv'. Must contain Package and DSA number information");
}
$data = $wml = "-" if ($debug);

if (!(-d $curyear)){
  print "directory $curyear does not exist!  Creating $curyear\n";
  make_path($curyear,{ verbose => 0, mode => 0755 }) or print "Could not create $curyear: $!\n";
}

&make_data;
&make_wml;
print "double check the content of $wml and $data, and eventually fix it before commit them.\n";
&make_index;
&make_makefile;


sub make_data{
  if (-f $data){
    print "$data already exists!\n";
    return;
  }
  $files =~ s,^</dl>\n\n,,;
  open DATA, ">", "$data";
  print DATA "<define-tag pagetitle>$pagetitle</define-tag>\n";
  print DATA "<define-tag report_date>$date</define-tag>\n";
  print DATA "<define-tag secrefs>@dbids</define-tag>\n" if @dbids;
  print DATA "<define-tag packages>$package</define-tag>\n";
  print DATA "<define-tag isvulnerable>yes</define-tag>\n";
  print DATA "<define-tag fixed>yes</define-tag>\n";
  print DATA "<define-tag fixed-section>no</define-tag>\n"; # Kaare, 2011-01-24: Line added because the "fixed in" section is no longer available
  print DATA "\n#use wml::debian::security\n\n";
  print DATA "$files\n\n</dl>\n";
  close DATA;
}

sub make_wml{
  if (-f $wml){
    print "$wml already exists!\n";
    return;
  }
  open WML, ">", "$wml";
  print WML "<define-tag description>$desc</define-tag>\n";
  print WML "<define-tag moreinfo>$moreinfo</p>\n</define-tag>\n";
  print WML "\n# do not modify the following line\n";
  print WML "#include \"\$(ENGLISHDIR)/security/$data\"\n";
  printf WML "# %sId: \$\n", "\$";
  close WML;
}

sub make_index{
  return if (-f "$curyear/index.wml");
  print "$curyear/index.wml does not exist! Creating...";
  my $ldo = '<a href="http://lists.debian.org/';
  my $dsan = 'debian-security-announce';
  my $index = "<define-tag pagetitle>Security Advisories from $curyear</define-tag>\n";
  $index .= qq|#use wml::debian::template title="<pagetitle>" GEN_TIME="yes"\n|;
  $index .= qq|#use wml::debian::recent_list\n\n|;
  $index .= qq|<:= get_recent_list ('.', '0', '\$(ENGLISHDIR)/security/$curyear', '', 'dsa-\\d+' ) :>\n\n|;
  $index .= qq|<p>You can get the latest Debian security advisories by subscribing to our\n|;
  $index .= qq|$ldo$dsan/">\\\n|;
  $index .= qq|<strong>$dsan</strong></a> mailing list.\n|;
  $index .= qq|You can also $ldo$dsan/$dsan-2013/">\\\n|;
  $index .= qq|browse the archives</a> for the list.</p>\n|;
  open INDEX, ">", "$curyear/index.wml";
  print INDEX $index;
  close INDEX;
  print "done\n";
  print "Do not forget to commit index.wml.\n";
}

sub make_makefile{
  return if (-f "$curyear/Makefile");
  print "$curyear/Makefile does not exist! Creating...";
  my $makefile = qq|# If this makefile is not generic enough to support a translation,\n|;
  $makefile .= qq|# please contact debian-www.\n\n|;
  $makefile .= qq|WMLBASE=../..\n|;
  $makefile .= qq|CUR_DIR=security/2013\n|;
  $makefile .= qq|SUBS=\n\n|;
  $makefile .= qq|GETTEXTFILES += security.mo\n\n|;
  $makefile .= qq|NOGENERICDEP := true\n|;
  $makefile .= qq|include \$(WMLBASE)/Make.lang\n\n\n|;
  $makefile .= qq|\%.\$(LANGUAGE).html: \%.wml \$(TEMPLDIR)/security.wml \\\n|;
  $makefile .= qq|  \$(ENGLISHSRCDIR)/\$(CUR_DIR)/\%.data \$(GETTEXTDEP)\n|;
  $makefile .= qq|\t\$(WML) \$(<F)\n\n|;
  $makefile .= qq|index.\$(LANGUAGE).html: index.wml \$(wildcard dsa-[0-9]*.wml) \\\n|;
  $makefile .= qq|  \$(ENGLISHSRCDIR)/\$(CUR_DIR)/dsa-[0-9]*.data \\\n|;
  $makefile .= qq|  \$(TEMPLDIR)/template.wml \$(TEMPLDIR)/recent_list.wml \$(GETTEXTDEP)\n|;
  $makefile .= qq|\t\$(WML) \$(<F)\n|;
  open MAKEFILE, ">", "$curyear/Makefile";
  print MAKEFILE $makefile;
  close MAKEFILE;
  print "done\n";
  print "Do not forget to commit Makefile.\n";
}
