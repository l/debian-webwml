#!/usr/bin/perl -wT
#
# download.pl -- CGI interface for downloading files on packages.debian.org
#
# Copyright (C) 1998 (?) James Treacy
# Copyright (C) 2001 Josip Rodin
# Copyright (C) 2004 Frank Lichtenheld
#
# Licensed under the GPL or something.

require 5.001;
use strict;
use CGI ();

use lib "../lib";

use Packages::HTML ();

my ($input,   # The CGI data
    $file, $filen, $md5sum, @file_components, $type, $arch, $dist);

use constant OLDSTABLE_IS_ARCHIVED => 0;

# TODO: find a way to get the U.S. mirror list from a more authoritive
# location automatically. might not be overly smart to automatize it
# completely, since I hand pick sites that are up-to-date, fast, and
# have HTTP on a reasonably short URL
#   -- Joy

# hint:
# grep-dctrl -F Site,Alias -e '(udel|bigfoot|kernel|internap|cerias|lcs.mit|progeny)' Mirrors.masterlist | timestamps/archive_mirror_check.py
my @north_american_sites = (
	"http.us.debian.org/debian",
	"ftp.egr.msu.edu/debian",
	"mirrors.kernel.org/debian",
	"debian.lcs.mit.edu/debian",
	"debian.oregonstate.edu/debian",
	);
my @european_sites = (
	"ftp.de.debian.org/debian",
	"ftp.at.debian.org/debian",
	"ftp.ch.debian.org/debian",
	"ftp.cz.debian.org/debian",
	"ftp.dk.debian.org/debian",
	"ftp.ee.debian.org/debian",
	"ftp.es.debian.org/debian",
	"ftp.fi.debian.org/debian",
	"ftp.fr.debian.org/debian",
	"ftp.hr.debian.org/debian",
	"ftp.hu.debian.org/debian",
	"ftp.ie.debian.org/debian",
	"ftp.is.debian.org/debian",
	"ftp.it.debian.org/debian",
	"ftp.nl.debian.org/debian",
	"ftp.no.debian.org/debian",
	"ftp.pl.debian.org/debian",
	"ftp.si.debian.org/debian",
	"ftp.se.debian.org/debian",
	"ftp.tr.debian.org/debian",
	"ftp.uk.debian.org/debian",
	);
my @south_american_sites = (
	"ftp.br.debian.org/debian",
	"ftp.cl.debian.org/debian",
	);
my @australian_sites = (
	"ftp.au.debian.org/debian",
	"ftp.wa.au.debian.org/debian",
	"ftp.nz.debian.org/debian",
	);
my @asian_sites = (
	"ftp.jp.debian.org/debian",
	"ftp2.jp.debian.org/debian",
	"ftp.kr.debian.org/debian",
	"ftp.tw.debian.org/debian",
	"debian.linux.org.tw/debian",
	"linux.cdpa.nsysu.edu.tw/debian",
	); 

my @volatile_european_sites = (
        "volatile.debian.net/debian-volatile",
        "ftp2.de.debian.org/debian-volatile",
        "ftp.sk.debian.org/debian-volatile",
			       );
my @amd64_european_sites = (
        "amd64.debian.net/debian",
        "ftp.de.debian.org/debian-amd64/debian",
        "bach.hpc2n.umu.se/debian-amd64/debian",
        "bytekeeper.as28747.net/debian-amd64/debian",
	"mirror.switch.ch/debian-amd64/debian",
        "ftp.nl.debian.org/debian-amd64/debian",
			    );
my @amd64_asian_sites = (
        "hanzubon.jp/debian-amd64/debian",
			 );
my @amd64_north_american_sites = (
        "mirror.espri.arizona.edu/debian-amd64/debian",
				  );
my @kfreebsd_north_american_sites = (
	"www.gtlib.gatech.edu/pub/gnuab/debian",
				     );
my @kfreebsd_european_sites = (
        # master site, aka ftp.gnuab.org
        "kfreebsd-gnu.debian.net/debian",
        "ftp.easynet.be/ftp/gnuab/debian",
	"ftp.de.debian.org/debian-kfreebsd",
			       );
my @nonus_north_american_sites = (
#	"ftp.ca.debian.org/debian-non-US",
	"debian.yorku.ca/debian/non-US",
	"mirror.direct.ca/linux/debian-non-US",
	);
my @nonus_european_sites = (
	"non-us.debian.org/debian-non-US",
	"ftp.de.debian.org/debian-non-US",
	"ftp.at.debian.org/debian-non-US",
	"ftp.bg.debian.org/debian-non-US",
	"ftp.cz.debian.org/debian-non-US",
	"ftp.fi.debian.org/debian-non-US",
	"ftp.fr.debian.org/debian-non-US",
	"ftp.hr.debian.org/debian-non-US",
	"ftp.hu.debian.org/debian-non-US",
	"ftp.ie.debian.org/debian-non-US",
	"ftp.is.debian.org/debian-non-US",
	"ftp.it.debian.org/debian-non-US",
	"ftp.nl.debian.org/debian-non-US",
	"ftp.no.debian.org/debian-non-US",
	"ftp.pl.debian.org/debian/non-US",
	"ftp.si.debian.org/debian-non-US",
	"ftp.es.debian.org/debian-non-US",
	"ftp.se.debian.org/debian-non-US",
	"ftp.tr.debian.org/debian-non-US",
	"ftp.uk.debian.org/debian/non-US",
	);
my @nonus_australian_sites = (
	"ftp.au.debian.org/debian-non-US",
	"ftp.wa.au.debian.org/debian-non-US",
	"ftp.nz.debian.org/debian-non-US",
	);
my @nonus_asian_sites = (
	"ftp.jp.debian.org/debian-non-US",
#	"ftp.kr.debian.org/debian-non-US",
	"linux.csie.nctu.edu.tw/debian-non-US",
	"debian.linux.org.tw/debian-non-US",
	"linux.cdpa.nsysu.edu.tw/debian-non-US",
	);
my @nonus_south_american_sites = (
	"ftp.br.debian.org/debian-non-US",
	"ftp.cl.debian.org/debian-non-US",
	);

my @old_european_sites = (
	"ftp.de.debian.org/debian-archive",
	"ftp.nl.debian.org/debian-archive",
	"ftp.ch.debian.org/debian-archive",
	);

my @old_north_american_sites = (
	"archive.debian.org",
	"ftp3.nrc.ca/debian-archive",
	);

# list of architectures
my %arches = (
        i386    => 'Intel x86',
        m68k    => 'Motorola 680x0',
        sparc   => 'SPARC',
        alpha   => 'Alpha',
        powerpc => 'PowerPC',
        arm     => 'ARM',
        hppa    => 'HP PA-RISC',
        ia64    => 'Intel IA-64',
        mips    => 'MIPS',
        mipsel  => 'MIPS (DEC)',
        s390    => 'IBM S/390',
	"hurd-i386" => 'Hurd (i386)',
	amd64   => 'AMD64',
	armel   => 'EABI ARM',
	"kfreebsd-amd64" => 'GNU/kFreeBSD (amd64)',
	"kfreebsd-i386" => 'GNU/kFreeBSD (i386)'
);

my $urlbase = "http://www.debian.org";

$ENV{PATH} = "/bin:/usr/bin";
# Read in all the variables set by the form
$input = new CGI;

print $input->header;

# If you want, just print out a list of all of the variables.
# print $input->dump;
# exit;

$file = $input->param('file');
param_error( "file" ) unless defined $file;
# Make file fit in a regexp
param_invalid ("file") if  $file !~ m!^[\w%.:+~_/-]+$!;
@file_components = split('/', $file);
$filen = pop(@file_components);

$dist = $input->param('dist');

$md5sum = $input->param('md5sum');
param_error( "md5sum" ) unless defined $md5sum;
# Make md5sum fit in a regexp
param_invalid ("md5sum") if  $md5sum !~ /^[0-9a-f]{32}$/;

$type = $input->param('type');
param_error( "type" ) unless defined $type;
# Make type fit in a regexp
param_invalid ("type") if  $type !~ /^(main|nonus|security|unofficial|volatile)$/;

$arch = $input->param('arch');
param_error( "arch" ) unless defined $arch;
# Make arch fit in a regexp
param_invalid ("arch") if  $arch !~ /^[\w\-]+$/;
# And also check that it is in the list of supported archs
param_invalid ("arch") if  ($arch ne 'all') && ! defined ($arches{$arch});


my $arch_string = $arch ne 'all' ? "on $arches{$arch} machines" : "";

print Packages::HTML::header( title => "Package Download Selection", lang => "en",
	      print_title_above => 1 );

print "<h2>Download Page for <kbd>$filen</kbd> $arch_string</h2>\n".
    "<p>You can download the requested file from the <tt>";
my $dir;
foreach $dir (@file_components) { print "$dir/"; };
print "</tt> subdirectory at";
print $type ne 'security' ? " any of these sites:" : ":";
print "</p>\n";

if ($type eq 'security') {

	print <<END;
<ul>
  <li><a href="http://security.debian.org/debian-security/$file">security.debian.org/debian-security</a></li>
</ul>

<p>Debian security updates are currently officially distributed only via
security.debian.org.</p>
END

} elsif (($type eq 'unofficial') and ($arch eq 'amd64')) {

    print_links( "North America", $file, @amd64_north_american_sites );
    print_links( "Europe", $file, @amd64_european_sites );
#    print_links( "Australia and New Zealand", $file,
#		 @nonus_australian_sites );
    print_links( "Asia", $file, @amd64_asian_sites );
#    print_links( "South America", $file, @nonus_south_american_sites );

	print <<END;
  <p>Note that the sarge release (current stable) for AMD64 is not
  officialy included in the Debian archive, but the AMD64 porter
  group keeps their archive in sync with the official archive as
  close as possible. See the
  <a href="http://www.debian.org/ports/amd64/">AMD64 ports page</a> for
  current information.</p>
END

} elsif ($arch =~ /^(kfreebsd|armel)/) {

    print_links( "North America", $file, @kfreebsd_north_american_sites );
    print_links( "Europe", $file, @kfreebsd_european_sites );
#    print_links( "Australia and New Zealand", $file,
#		 @nonus_australian_sites );
#    print_links( "Asia", $file, @amd64_asian_sites );
#    print_links( "South America", $file, @nonus_south_american_sites );

	print <<END;
  <p>Note that GNU/kFreeBSD is not officialy included in the Debian archive
  yet, but the GNU/kFreeBSD porter group keeps their archive in sync with
  the official archive as close as possible. See the
  <a href="http://www.debian.org/ports/kfreebsd-gnu/">GNU/kFreeBSD ports page</a> for
  current information.</p>
END

} elsif ($type eq 'nonus') {

    print_links( "North America", $file, @nonus_north_american_sites );
    print_links( "Europe", $file, @nonus_european_sites );
    print_links( "Australia and New Zealand", $file,
		 @nonus_australian_sites );
    print_links( "Asia", $file, @nonus_asian_sites );
    print_links( "South America", $file, @nonus_south_american_sites );

    print <<END;
<p>If none of the above sites are fast enough for you, please see our
<a href="http://www.debian.org/mirror/list-non-US">complete mirror list</a>.</p>
END

} elsif (OLDSTABLE_IS_ARCHIVED and ($dist eq 'oldstable')) {

    print_links( "North America", $file, @old_north_american_sites );
    print_links( "Europe", $file, @old_european_sites );

    print <<END;
<p>If none of the above sites are fast enough for you, please see our
<a href="http://www.debian.org/distrib/archive">complete mirror list</a>.</p>
END

} elsif ($type eq 'volatile') {

#    print_links( "North America", $file, @nonus_north_american_sites );
    print_links( "Europe", $file, @volatile_european_sites );
#    print_links( "Australia and New Zealand", $file,
#		 @nonus_australian_sites );
#    print_links( "Asia", $file, @nonus_asian_sites );
#    print_links( "South America", $file, @nonus_south_american_sites );

    print <<END;
<p>If none of the above sites are fast enough for you, please see our
<a href="http://volatile.debian.net/mirrors.html">complete mirror list</a>.</p>
END

} elsif ($type eq 'main') {

    print '<div class="cardleft">';
    print_links( "North America", $file, @north_american_sites );
    print_links( "South America", $file, @south_american_sites );
    print '</div><div class="cardright">';
    print_links( "Europe", $file, @european_sites );
    print '</div><div class="cardleft">';
    print_links( "Australia and New Zealand", $file, @australian_sites );
    print '</div><div class="cardright">';
    print_links( "Asia", $file, @asian_sites );
    print '</div>';

    print <<END;
<p style="clear:both">If none of the above sites are fast enough for you, please see our
<a href="http://www.debian.org/mirror/list">complete mirror list</a>.</p>
END
}

print <<END;
<p>Note that in some browsers you will need to tell your browser you want
the file saved to a file. For example, in Netscape or Mozilla, you should
hold the Shift key when you click on the URL.</p>
END

print "<p>The MD5sum for <tt>$filen</tt> is <strong>$md5sum</strong></p>\n"
    if $md5sum;

# compute modification date
my $delta_time = -M $0;
my $mod_time = $^T - ($delta_time * 86400);
my $time_str = gmtime($mod_time)." +0000";

my $trailer = Packages::HTML::trailer( ".." );
$trailer =~ s/LAST_MODIFIED_DATE/$time_str/;
print $trailer;

exit;

sub print_links {
    my ( $title, $file, @servers ) = @_;

    print "<p><em>$title</em></p>";
    print "<ul>";
    foreach (@servers) {
	print "<li><a href=\"http://$_/$file\">$_</a></li>\n";
	# print "<li><a href=\"ftp://$_/$file\">$_</a></li>\n";
    }
    print "</ul>";

}

sub param_error {
    my $param = shift;

    print "<p>Internal error: Required parameter \"$param\" is missing.</p>\n";
    print "<p>If the problem persists, please inform $ENV{SERVER_ADMIN}.</p>\n";
    exit;
}

sub param_invalid {
    my $param = shift;

    print "<p>Error: Required parameter \"$param\" does not have a valid content.</p>\n";
    print "<p>If the problem persists, please inform $ENV{SERVER_ADMIN}.</p>\n";
    exit;
}

