#!/usr/bin/perl

($year, $issue) = @ARGV;

unless ($year && $issue)
{
	print "Usage: $0 year issue\n\n";
	print "Copies the issue from the English directory to the local one and adds\n";
	print "the  translation  string\n";
	exit;
}

$srcdir = "../../../english/News/weekly/$year/$issue";
$srcfile= "$srcdir/index.wml";
$cvsfile= "$srcdir/CVS/Entries";
$dstdir = "./$year/$issue";
$dstfile= "$dstdir/index.wml";

die "Directory $srdir does not exist\n" unless -d $srcdir;
die "File $srcfile does not exist\n"    unless -e $srcfile;
mkdir $dstdir, 0755                     unless -d $dstdir;

open CVS, $cvsfile
	or die "Could not read $cvsfile ($!)\n";

open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

while (<CVS>)
{
	if (m[^/index\.wml/([0-9]*\.[0-9])*/]o)
	{
		$revision = $1;
	}
}

close CVS;

print "Could not get revision number\n" unless $revision;

$insertedrevision = 0;

while (<SRC>)
{
	if (/PAGENAME="([A-Za-z]*) ([0-9]*)[a-z]*, ([0-9]*)"/)
	{
		$date = "$2 $1 $3";
		$date =~ s/January/januari/;
		$date =~ s/February/februari/;
		$date =~ s/March/mars/;
		$date =~ s/April/april/;
		$date =~ s/May/maj/;
		$date =~ s/June/juni/;
		$date =~ s/July/juli/;
		$date =~ s/August/augusti/;
		$date =~ s/September/september/;
		$date =~ s/October/oktober/;
		$date =~ s/November/november/;
		$date =~ s/December/december/;

		s/PAGENAME=".*" SUMMARY/PAGENAME="$date" SUMMARY/;
	}

	unless ($insertedrevision || /^#/)
	{
		print DST "# <!--translation $revision-->\n";
		$insertedrevision = 1;
	}
	print DST $_;
}

close SRC;
close DST;

print "Copying done, remember to edit $dstfile\n";
