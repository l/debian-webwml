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
    $file, $filen, $md5sum, @file_components, $type, $arch);

my @north_american_sites = qw(
	mirrors.kernel.org/ubuntu
	ftp.cs.umn.edu/pub/ubuntu
	lug.mtu.edu/ubuntu
	mirror.clarkson.edu/pub/distributions/ubuntu
	ubuntu.mirrors.tds.net/ubuntu
	www.opensourcemirrors.org/ubuntu
	ftp.ale.org/pub/mirrors/ubuntu
	ubuntu.secs.oakland.edu
	mirror.mcs.anl.gov/pub/ubuntu
	mirrors.cat.pdx.edu/ubuntu
	ubuntu.cs.utah.edu/ubuntu
	ftp.ussg.iu.edu/linux/ubuntu
	mirrors.xmission.com/ubuntu
	ftp.osuosl.org/pub/ubuntu
	mirrors.cs.wmich.edu/ubuntu
	mirror.cpsc.ucalgary.ca/mirror/ubuntu.com
	mirror.arcticnetwork.ca/pub/ubuntu/packages
	gulus.USherbrooke.ca/pub/distro/ubuntu
	);
my @european_sites = qw(
	fr.archive.ubuntu.com/ubuntu
	ge.archive.ubuntu.com/ubuntu
	nl.archive.ubuntu.com/ubuntu
	no.archive.ubuntu.com/ubuntu
	yu.archive.ubuntu.com/ubuntu
	ubuntu.inode.at/ubuntu
	ubuntu.uni-klu.ac.at/ubuntu
	gd.tuwien.ac.at/opsys/linux/ubuntu/archive
	ftp.belnet.be/pub/mirror/ubuntu.com
	ubuntu.mirrors.skynet.be/pub/ubuntu.com
	ubuntu.ipacct.com/ubuntu
	ubuntu-hr.org/ubuntu
	archive.ubuntu.cz/ubuntu
	mirrors.dk.telia.net/ubuntu
	mirrors.dotsrc.org/ubuntu
	klid.dk/homeftp/ubuntu
	ftp.estpak.ee/pub/ubuntu
	www.nic.funet.fi/pub/mirrors/archive.ubuntu.com
	mir1.ovh.net/ubuntu
	ftp.u-picardie.fr/pub/ubuntu/ubuntu
	ftp.oleane.net/pub/ubuntu
	debian.charite.de/ubuntu
	ftp.inf.tu-dresden.de/os/linux/dists/ubuntu
	www.artfiles.org/ubuntu.com/archive
	ftp.rz.tu-bs.de/pub/mirror/ubuntu-packages
	ftp.join.uni-muenster.de/pub/mirrors/ftp.ubuntu.com/ubuntu
	www.ftp.uni-erlangen.de/pub/mirrors/ubuntu
	ftp.ntua.gr/pub/linux/ubuntu
	ftp.kfki.hu/linux/ubuntu
	ubuntu.odg.cc
	ubuntu.lhi.is
	ftp.esat.net/mirrors/archive.ubuntu.com
	ftp.heanet.ie/pub/ubuntu
	ftp.linux.it/ubuntu
	na.mirror.garr.it/mirrors/ubuntu-archive
	mirrors.linux.edu.lv/ftp.ubuntu.com
	ftp.litnet.lt/pub/ubuntu
	ubuntu.synssans.nl
	ubuntulinux.mainseek.com/ubuntu
	ubuntu.task.gda.pl/ubuntu
	darkstar.ist.utl.pt/ubuntu/archive
	ubuntu.dcc.fc.up.pt
	ftp.iasi.roedu.net/mirrors/ubuntulinux.org/ubuntu
	ftp.gui.uva.es/sites/ubuntu.com/ubuntu
	ftp.acc.umu.se/mirror/ubuntu
	mirror.switch.ch/ftp/mirror/ubuntu
	www.mirrorservice.org/sites/archive.ubuntu.com/ubuntu
	www.mirror.ac.uk/mirror/archive.ubuntu.com/ubuntu
	ubuntu.blueyonder.co.uk/archive
	ubuntu.snet.uz/ubuntu
	);
my @south_american_sites = qw(
	cl.archive.ubuntu.com/ubuntu
	espelhos.edugraf.ufsc.br/ubuntu
	ubuntu.interlegis.gov.br/archive
        ubuntu.c3sl.ufpr.br/ubuntu
	ftp.ucr.ac.cr/ubuntu
	www.computacion.uni.edu.ni/iso/ubuntu
	);
my @australian_sites = qw(
	ftp.iinet.net.au/pub/ubuntu
	mirror.optus.net/ubuntu
	mirror.isp.net.au/ftp/pub/ubuntu
	www.planetmirror.com/pub/ubuntu
	ftp.filearena.net/pub/ubuntu
	mirror.pacific.net.au/linux/ubuntu
	);
my @asian_sites = qw(
	archive.ubuntu.org.cn/ubuntu
	debian.cn99.com/ubuntu
	mirror.lupaworld.com/ubuntu
	komo.vlsm.org/ubuntu
	kambing.vlsm.org/ubuntu
	ubuntu.mithril-linux.org/archives
	ubuntu.csie.ntu.edu.tw/ubuntu
	mirror.letsopen.com/os/ubuntu
	ftp.kaist.ac.kr/pub/ubuntu
	apt.ubuntu.org.tw/ubuntu
	apt.nc.hcc.edu.tw/pub/ubuntu
	mirror.in.th/ubuntu
	);
my @african_sites = qw(
	za.archive.ubuntu.com/ubuntu
	);

# list of architectures
my %arches = (
        i386    => 'Intel x86',
        powerpc => 'PowerPC',
        ia64    => 'Intel IA-64',
        mips    => 'MIPS',
        mipsel  => 'MIPS (DEC)',
        s390    => 'IBM S/390',
	"hurd-i386" => 'Hurd (i386)',
	amd64   => 'AMD64',
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

$md5sum = $input->param('md5sum');
param_error( "md5sum" ) unless defined $md5sum;
# Make md5sum fit in a regexp
param_invalid ("md5sum") if  $md5sum !~ /^\w{32}$/;

$type = $input->param('type');
param_error( "type" ) unless defined $type;
# Make type fit in a regexp
param_invalid ("type") if  $type !~ /^\w+$/;

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
  <li><a href="http://security.ubuntu.com/ubuntu/$file">security.ubuntu.com/ubuntu</a>
</ul>
END

} elsif ($type eq 'main') {

    print '<div class="cardleft">';
    print_links( "North America", $file, @north_american_sites );
    print_links( "Australia and New Zealand", $file, @australian_sites );
    print_links( "South America", $file, @south_american_sites );
    print_links( "Asia", $file, @asian_sites );
    print '</div><div class="cardright">';
    print_links( "Europe", $file, @european_sites );
    print_links( "Africa", $file, @african_sites );
    print '</div>';

	print <<END;
<p style="clear:both">If none of the above sites are fast enough for you, please see the
<a href="https://wiki.ubuntu.com/Mirrors">complete mirror list</a>.<br>
The list of mirrors used by this scripts was last synced with the mirror list
<em>Wed, 18 Oct 2006 16:39:11 +0000</em>.</p>
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

    print '<div class="mirrorList">';
    print "<p><em>$title</em></p>";
    print "<ul>";
    foreach (@servers) {
	print "<li><a href=\"http://$_/$file\">$_</a></li>\n";
	# print "<li><a href=\"ftp://$_/$file\">$_</a></li>\n";
    }
    print "</ul></div>";

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

