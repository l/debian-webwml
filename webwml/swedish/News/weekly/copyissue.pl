#!/usr/bin/perl -w

# This script copies a DWN issue as given on the command line to the
# translation named in copypage.conf, translates a few strings,
# adds the translation-check header to it. It will also create the
# destination directory if necessary.

# Written in 2000-2008 by Peter Krefting <peter@softwolves.pp.se>
# © Copyright 2000-2008 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

# Externals
use Getopt::Std;
use vars qw($opt_s);

# Get command line
if (getopts('s:'))
{
	($year, $issue) = @ARGV;
}

# Check usage.
unless ($year && $issue)
{
	print "Usage: $0 [-s sourcefile] year issue\n\n";
	print "Copies the issue from the English directory to the local one and adds\n";
	print "the translation-check header\n";
	exit;
}

# Create needed file and directory names
$srcdir = "../../../english/News/weekly/$year/$issue";
$srcfile= "$srcdir/index.wml";
$srcfile= $opt_s if $opt_s;
$cvsfile= "$srcdir/CVS/Entries";
$yeardir= "./$year";
$dstdir = "./$year/$issue";
$dstfile= "$dstdir/index.wml";

# Sanity checks
die "Directory $srcdir does not exist\n" unless $opt_s || -d $srcdir;
die "File $srcfile does not exist\n"     unless -e $srcfile;
die "File $dstfile already exists\n"     if     -e $dstfile;
mkdir $yeardir, 0755                     unless -d $yeardir;
mkdir $dstdir, 0755                      unless -d $dstdir;

# Retrieve the CVS version number
if ($opt_s)
{
	$revision = '1.0';
}
else
{
	open CVS, $cvsfile
		or die "Could not read $cvsfile ($!)\n";

	while (<CVS>)
	{
		if (m[^/index\.wml/([0-9]*\.[0-9]*)/]o)
		{
			$revision = $1;
		}
	}

	close CVS;
}

# Open the files
open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

unless ($revision)
{
	print "Could not get revision number\n";
	$revision = '1.1';
}

# Copy the file, translate date and some other stuff, and insert the
# revision number
$insertedrevision = 0;

while (<SRC>)
{
	next if /\$Id/i;

	if ($_ eq "<b>Welcome</b> to Debian Weekly News, a newsletter for the Debian developer\n")
	{
		# Translate intro
		$next = <SRC>;
		if ($next eq "community.\n")
		{
			$_ = "<b>Välkommen</b> till Debian Weekly News, ett nyhetsbrev för Debianutvecklare.\n";
		}
		else
		{
			$_ .= $next;
		}
	}
	elsif ($_ eq "<b>Welcome</b> to Debian Weekly News, a newsletter for the Debian community.\n")
	{
		# Translate intro
		$_ = "<b>Välkommen</b> till Debian Weekly News, ett nyhetsbrev för Debianfolk.\n";
	}
	elsif ($_ eq "<p><strong>New or Noteworthy Packages.</strong> The following new or\n")
	{
		# Translate new files intro
		$next = <SRC>;
		if ($next eq "updated packages were added to the Debian archive since our last\n")
		{
			$next2 = <SRC>;
			if ($next2 eq "issue.</p>\n")
			{
				$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
				$_ .= "Följande paket har lagts till Debianarkivet sedan förra utgåvan.</p>\n";
			}
			else
			{
				$next .= $next2;
				$_ .= $next;
			}
		}
		elsif ($next eq "updated packages were updated or added to the Debian archive recently.</p>\n")
		{
			$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
			$_ .= "Följande nya eller uppdaterade paket har nyligen lagts till\n";
			$_ .= "Debianarkivet.</p>\n";
		}
		else
		{
			$_ .= $next;
		}
	}
	elsif ($_ eq "<p><strong>New or Noteworthy Packages.</strong> The following packages were\n")
	{
		# Translate new files intro; type B
		$next = <SRC>;
		if ($next eq "added to the Debian archive recently.</p>\n")
		{
			$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
			$_ .= "Följande paket har nyligen lagts till Debianarkivet.</p>\n";
		}
		elsif ($next eq "added to the Debian archive recently or contain important updates.</p>\n")
		{
			$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
			$_ .= "Följande paket har nyligen lagts till Debianarkivet eller innehåller\n";
			$_ .= "viktiga uppdateringar.</p>\n"
		}
        elsif ($next eq "added to the unstable Debian archive recently or contain important updates.</p>\n")
        {
			$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
			$_ .= "Följande paket har nyligen lagts till det instabila Debianarkivet eller innehåller\n";
			$_ .= "viktiga uppdateringar.</p>\n";
        }
        elsif ($next eq "added to the unstable Debian archive <a\n")
        {
        	$_ .= $next;
        	$next = <SRC>;
        	if ($next eq "href=\"http://packages.debian.org/unstable/newpkg_main\">recently</a> or contain\n")
        	{
        		$_ .= $next;
        		$next = <SRC>;
        		if ($next eq "important updates.</p>\n")
        		{
					$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
					$_ .= "Följande paket har\n";
					$_ .= "<a href=\"http://packages.debian.org/unstable/newpkg_main\">nyligen</a>\n";
					$_ .= "lagts till det instabila Debianarkivet eller innehåller viktiga uppdateringar.\n";
					$_ .= "</p>\n";
				}
				else
				{
					$_ .= $next;
				}
			}
			else
			{
				$_ .= $next;
			}
        }
		else
		{
			$_ .= $next;
		}
	}
	elsif ($_ eq "<p><strong>New or Noteworthy Packages.</strong> The following\n")
	{
		# Translate new files intro; type C;
		$next = <SRC>;
		if ($next eq "packages were added to the unstable Debian archive recently or contain\n")
		{
			$next2 = <SRC>;
			if ($next2 eq "important updates.</p>\n")
			{
				$_ =  "<p><strong>Nya eller anmärkningsvärda paket.</strong>\n";
				$_ .= "Följande paket har nyligen lagts till det instabila Debianarkivet eller innehåller\n";
				$_ .= "viktiga uppdateringar.</p>\n";
			}
			else
			{
				$_ .= $next;
				$_ .= $next2;
			}
		}
		else
		{
			$_ .= $next;
		}
	}
	elsif ($_ eq "<p><strong>Security Updates.</strong> You know the drill, make sure\n" ||
	       $_ eq "<p><strong>Security Updates.</strong> You know the drill, please make sure\n" ||
	       $_ eq "<p><strong>Security Updates.</strong> You know the drill.  Please make sure\n")
	{
		# Translate security intro
		$next = <SRC>;
		if ($next eq "you update your systems if you have one of these packages installed.</p>\n" ||
		    $next eq "that you update your systems if you have any of these packages installed.</p>\n")
		{
			$_ =  "<p><strong>Säkerhetsuppdateringar.</strong>\n";
			$_ .= "Ni kan rutinen, se till att uppdatera era system om ni har något av\n";
			$_ .= "dessa paket installerade.</p>\n";
		}
		elsif ($next eq "that you update your systems if you have this package installed.</p>\n")
		{
			$_ =  "<p><strong>Säkerhetsuppdatering.</strong>\n";
			$_ .= "Ni kan rutinen, se till att uppdatera era system om ni har detta paket\n";
			$_ .= "installerat.</p>\n";
		}
		else
		{
			$_ .= $next;
		}
	}

	s/(\s+)--(\s+)/$1&ndash;$2/g;
	s/>Bug#([0-9])/>rapport $1/g;
	s/Request of QA/Efter fråga från QA/;
	s/Request of [mM]aintainer/Efter fråga från ansvariga/;
	s/orphaned for more than/övergivet i mer än/;
	s/has never been part of a stable release/har aldrig ingått i en stabil utgåva/;

	unless ($insertedrevision || /^#/)
	{
		print DST qq'#use wml::debian::translation-check translation="$revision"\n';
		$insertedrevision = 1;
	}

	if (/wml::debian::weeklynews::footer/)
	{
		chomp;
		$_ .= qq' translator="Peter Krefting"\n';
	}
	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
