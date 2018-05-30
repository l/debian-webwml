#!/usr/bin/perl

# This is a toy to compute the karma of translators in the Debian web site

# It use information about translation revisions please see
# https://www.debian.org/devel/website/uptodate
# it also need informations about the maintainer. Just add
#   maintainer="Name"
# at the end of the wml::debian::translation-check template invocation

# This is GPL'ed code.
# Copyright 2002 Martin Quinson <martin.quinson@ens-lyon.fr>.
# Copyright 2008 Bas Zoetekouw <bas@debian.org>.

# Invocation:
#   karma.pl [language]
# list of languages in webwml:
#    english esperanto french japanese german arabic catalan bulgarian
#    chinese croatian czech danish dutch farsi finnish greek hungarian
#    indonesian italian korean lithuanian norwegian romanian russian
#    slovene spanish swedish turkish

use File::Basename;
use File::Spec::Functions;
use FindBin;

# These modules reside under webwml/Perl
use lib "$FindBin::Bin/Perl";
use Local::VCS;
use Local::WmlDiffTrans;
use Webwml::TransCheck;
use Webwml::TransIgnore;

use strict;
use warnings;

$| = 1;

# where to compute the Karma
my %Karma;

# include only files matching $filename
my $MATCH = '(\.wml$)|(\.html$)';
my $SKIP  = '^template/';

# parse command line;
die("Please specify a language to examine\n")  if not @ARGV;
my @DIRS = @ARGV;
foreach my $d (@DIRS)
{
	$d =~ s{ /$ }{}x;
	die("Language `$d' not found.\n")  unless -d $d;
}

print "Reading data...";

my $lang_from = 'english';
my $VCS = Local::VCS->new();
my %info_from = $VCS->path_info( $lang_from, 
	match_pat => $MATCH, 
	skip_pat  => $SKIP,
	recursive => 1, 
	verbose   => 1 
);

print "\n";

foreach my $subdir (@DIRS)
{
	print "Examining $subdir...\n";

	# find language from path
	my ($lang_to) = $subdir =~ m{ ^ ([^/]+) }x;
	die("No language found") unless $lang_to;

	# remove the language from the subdir
	$subdir =~ s{ ^ $lang_to /? }{}x;


	# TODO: transignore

	# fetch a list of all (translated) files in this subdir
	my %info_to = $VCS->path_info( catfile($lang_to,$subdir), 
		match_pat => $MATCH, 
		skip_pat  => $SKIP,
		recursive => 1, 
		verbose   => 1 
	);

	foreach my $file ( sort keys %info_to )
	{
		my $path      = $subdir ? catfile( $subdir, $file ) : $file;
		my $path_to   = catfile( $lang_to,   $path );
		my $path_from = catfile( $lang_from, $path );

		# NOTE: all keys in %info_from are relative to $WEBWML/english
		#       all keys in $info_to   are relative to $WEBWML/$lang_to/$subdir
		# so, use ONLY $info_from{$path} and ONLY $info_to{$file} 

		#print "  ==> $file : $path : $path_to : $path_from\n";

		# check if the english file exists 
		# (if not, the $path_to isn't a translation, so skip it )
		next unless exists $info_from{$path};

		# check if the translated file exists (if not, you've found a bug)
		die("No such file `$path_to'")   unless exists $info_to{$file};

		# check if the file is in a transignore
		my $dir = dirname($path_to);
		my $transignore = new Webwml::TransIgnore->new($dir) or die;
		if ( $transignore->is_local($path_to) or $transignore->is_global($path_to) )
		{
			#print "Ignoring $path_to\n";
			next;
		}

		my $rev_from  = $info_from{$path}->{'cmt_rev'}  or  die;;

		check_file( \%Karma, $lang_to, $path_to, $path_from, $rev_from );
	}
}

foreach my $translator (sort {$Karma{$b} <=> $Karma{$a}} keys %Karma) 
{
	printf "%s has a web karma of %s\n", $translator, $Karma{$translator};
}

exit 0;


sub check_file 
{
	my $karma      = shift or die;
	my $language   = shift or die;
	my $file_trans = shift or die;
	my $file_orig  = shift or die;
	my $revision   = shift or die;

	return unless (-r $file_trans); # file_trans does not exists

	my $transcheck = Webwml::TransCheck->new($file_trans);
	my $oldr = $transcheck->revision() || 0;

	my $translator = $transcheck->maintainer() || 'ANONYMOUS';
	my $original   = $transcheck->original();

	return if $original; # if not, we'll loose karma if this page is badly translated

	$translator = ucfirst($language) . " " . $translator;
	$translator =~ s/^\s+ |\s+$//;

	# calculate the number of revision the original english file has has
	my $numrev = $VCS->count_changes( $file_trans, undef, $revision );
	# calculate the age of the translated file
	my $age    = $VCS->count_changes( $file_orig,  $oldr, $revision );

	$karma->{$translator} += $numrev; # page translated. GOOD
	$karma->{$translator} -= $numrev*$age/4; #out of date page; Bad
}

__END__

sub check_file {
my ($name, $revision,$translator) = @_;
my ($oldr, $oldname, $original);
my $docname = $name;
$docname =~ s#^$lang_to/##;
$docname =~ s#\.wml$##;
return unless (-r $name); # file does not exists

my $transcheck = Webwml::TransCheck->new($name);
$oldr = $transcheck->revision() || 0;
if (!$oldr && ($name =~ m#$lang_to/international/$lang_to#i)) {
#   This document is original, check for
#   english/international/$lang_to...
$name =~ s{^$to}{$from};
$transcheck = Webwml::TransCheck->new($name);
$oldr       = $transcheck->revision() || 0;
}
$translator = $transcheck->maintainer();
$original   = $transcheck->original();
$translator = "anonymous" unless $translator; # translator not found
$translator = ucfirst($to)." ".$translator;

$translator =~ s/^\s+//;
$translator =~ s/\s+$//;
$karma{$translator}=0 unless defined($karma{$translator});
$translator =~ s/^\s+//;
$translator =~ s/\s+$//;

return if $original; # if not, we'll loose karma if this page is badly translated
(my $numrev)  = $revision =~ m/^1\.(\d+)$/; $numrev ||= "0";
(my $numoldr) = $oldr =~ m/^1\.(\d+)$/; $numoldr ||= "0";
my $age=$numrev - $numoldr;
#	print "$translator: ";
#	if ($age > 0) {
#	    print "NeedToUpdate $name from version 1.$numoldr to version 1.$numrev\n";
#	} else {
#	    print "Uptodate $name\n";
#	}
$karma{$translator} += $numrev; # page translated. GOOD
$karma{$translator} -= $numrev*$age/4; #out of date page; Bad
}

foreach my $translator (sort {$karma{$b} <=> $karma{$a}} keys %karma) {
print "$translator has a web karma of ".$karma{$translator}.".\n";
}
