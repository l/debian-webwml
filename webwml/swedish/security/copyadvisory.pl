#!/usr/bin/perl

$date = @ARGV[0];

unless ($date)
{
	print "Usage: $0 advisorydate\n\n";
	print "Copies the advisory from the English directory to the local one and adds\n";
	print "the  translation  string\n";
	exit;
}

$year = substr($date, 0, 4);
$srcdir = "../../english/security/$year";
$srcfile= "$srcdir/$date.wml";
$cvsfile= "$srcdir/CVS/Entries";
$dstdir = "./$year";
$dstfile= "$dstdir/$date.wml";

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
	if (m[^/$date\.wml/([0-9]*\.[0-9])*/]o)
	{
		$revision = $1;
	}
}

close CVS;

print "Could not get revision number\n" unless $revision;

$insertedrevision = 0;

while (<SRC>)
{
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
