#!/usr/bin/perl -w

# Params
my ($file, $destdir) = @ARGV;
die "$file is not a file" unless -f $file;
die "$destdir is not a dir" unless -d $destdir;

# Create destname
$filename = $file;
$filename =~ s(.*/)();
$dest = $destdir . '/' . $filename;

# Move file
print "moving $file -> $dest\n";
rename $file, "$dest"
	or die "Cannot move $file to $dest: $!\n";

# CVS magic
print "cvs rm $file\n";
system("/usr/bin/cvs rm $file");
print "cvs add $dest\n";
system("/usr/bin/cvs add $dest");

# Change translation-check
$srccheck = $file;
$srccheck =~ s((^.*/)[^/]+$)($1);
$srccheck .= 'translation-check';
print "rewriting $srccheck\n";
open OLDCHECK, '<', $srccheck
	or die "Cannot read $srccheck: $!\n";
open OLDCHECKOUT, '>', $srccheck . '.new'
	or die "Cannot write $srccheck.new: $!\n";
while (<OLDCHECK>)
{
	print OLDCHECKOUT
		unless /$filename/o;
}
close OLDCHECK;
unlink $srccheck
	or die "Cannot delete $srccheck: $!\n";
rename $srccheck . '.new', $srccheck
	or die "Cannot rename new $srccheck: $!\n";

$dstcheck = $destdir . '/translation-check';
print "rewriting $dstcheck\n";
open NEWCHECK, '>>', $dstcheck
	or die "Cannot append $dstcheck: $!\n";
print NEWCHECK $filename, "\t1.1\n";
close NEWCHECK;
