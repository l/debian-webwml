#!/usr/bin/perl -w

require 5.001;
use strict;

my (@languages, @parts, $file, $filename, $lang, $path, $pid);

if (!@ARGV) {
   print "Usage: new_translation.pl <file1> <file2>...\n";
   print "\tThis will update every version of <file?> so that they\n";
   print "\tknow about the new translation. Each <file?> should be\n";
   print "\tthe path to a .wml file (without the language directory).\n";
   exit 1;
}

opendir(DIR, ".") || die "can't open directory $!";
@languages = grep { /^\w+$/ && -d $_ } readdir(DIR);
closedir DIR;
# print @languages;

foreach $file (@ARGV) {
   foreach $lang (@languages) {
      if ($lang eq "CVS") { next; }
      @parts = split ?\/?,$file;
      $filename = pop(@parts);
      $path = join('/', @parts);
      if ( -f "$lang/$file" ) {
			if ($path eq '') {
         	print "running 'wml -q $lang/$filename'\n";
			}
			else {
         	print "running 'wml -q $lang/$path/$filename'\n";
			}
         $pid = fork;
         if ($pid) { # parent
            # do nothing
         }
         else {      # child
            chdir "$lang/$path" && system("wml", "-q", $filename);
            exit 0;
         }
         waitpid($pid,0);
      }
      else {
			if ($path eq '') {
         	print "$lang/$file doesn't exist\n";
			}
			else {
         	print "$lang/$path/$file doesn't exist\n";
			}
      }
   }
}
