#!/usr/bin/perl -w

# Usage: new_translation.pl <file1> <file2>...

# 	This will update every version of <file?> so that they
# 	know about the new translation. Each <file?> should be
# 	the path to a .wml file (without the language directory).

# Note: this script is replaced/obsoleted by touch_old_files.pl

require 5.001;
use strict;

my (@languages, @parts, $file, $filename, $lang, $path, $pid);

# from english/template/debian/languages.wml
# TODO: Needs to be synced frequently or fixed so it's automatic
my %langs = ( english    => "en",
#             arabic     => "ar",
              catalan    => "ca",
              danish     => "da",
              german     => "de",
              greek      => "el",
              esperanto  => "eo",
              spanish    => "es",
              finnish    => "fi",
              french     => "fr",
              croatian   => "hr",
              hungarian  => "hu",
              italian    => "it",
              japanese   => "ja",
              korean     => "ko",
              dutch      => "nl",
              norwegian  => "no",
              polish     => "pl",
              portuguese => "pt",
              romanian   => "ro",
              russian    => "ru",
              swedish    => "sv",
              turkish    => "tr",
              chinese    => "zh",
);

if (!@ARGV) {
  open SELF, "<$0" or die "Unable to display help: $!\n";
  HELP: while (<SELF>)
  {
    last HELP if (/^require/);
    s/^# ?//;
    next if /^!/;
    print;
  }
  exit;
}

opendir(DIR, ".") || die "can't open directory $!";
@languages = grep { /^\w+$/ && -d $_ } readdir(DIR);
closedir DIR;
# print @languages;

foreach $file (@ARGV) {
   foreach $lang (@languages) {
      next if ($lang eq "CVS");
      @parts = split ?\/?,$file;
      $filename = pop(@parts);
      $path = join('/', @parts);
      if ( -f "$lang/$file" ) {
         $pid = fork;
         if ($pid) { # parent
            # do nothing
         }
         else {      # child
	    $filename =~ s/.wml$/.$langs{$lang}.html/;
	    if ($path eq '') { print "running 'make -C $lang $filename'\n" }
	    else { print "running 'make -C $lang/$path $filename'\n" };
            system("make -C $lang/$path $filename") == 0 or die "$!\n";
            exit 0;
         }
         waitpid($pid,0);
      }
      else {
	 if ($path eq '') { print "$lang/$file doesn't exist\n" }
	 else { print "$lang/$path/$file doesn't exist\n" };
      }
   }
}
