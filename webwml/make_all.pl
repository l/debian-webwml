#!/usr/bin/perl -w

# Usage: new_translation.pl <file1> <file2>...

# 	This will update every version of <file?>, each of which should be
#	the path to a .wml file (without the language directory).

# Note: this script old functionality is replaced by touch_old_files.pl

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

my $relhtmlbase = "../debian.org/";

foreach $file (@ARGV) {
  $file =~ s,^english/,,;
  my $level = 0;
  my $destfile = "";
  my @parts = split '/', $file;
  my $dir = pop @parts;
  my $path = join '/', @parts;
# system ("mkdir -p $relhtmlbase$path");
  while ($dir) { $destfile .= "../"; $dir = pop @parts; }
  $destfile .= $relhtmlbase . $file;
  foreach $lang (@languages) {
      next if ($lang eq "CVS");
      if ( -f "$lang/$file" ) {
         $pid = fork;
         if ($pid) { # parent
            # do nothing
         }
         else {      # child
	    $destfile =~ s/.wml$/.$langs{$lang}.html/;
            print "Making the " . ucfirst $lang . " copy:\n";
            system("make -C $lang/$path $destfile") == 0 or die "$!\n";
            exit 0;
         }
         waitpid($pid,0);
      }
      else {
         print "The file isn't translated into " . ucfirst $lang . ".\n";
      }
  }
}
