#!/usr/bin/perl -w

# This is a toy to compute the karma of translators in the Debian web site
# CVS repository.

# It use information about translation revisions please see
# http://www.debian.org/devel/website/uptodate
# it also need informations about the maintainer. Just add 
#   maintainer="Name"
# at the end of the wml::debian::translation-check template invocation

# This is GPL'ed code.
# Copyright 2002 Martin Quinson <martin.quinson@ens-lyon.fr>.

# Invocation:
#   karma.pl [language]

use strict;
use Getopt::Std;
use IO::Handle;
use Date::Parse;

#    These modules reside under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
use Local::Cvsinfo;
use Local::WmlDiffTrans;
use Webwml::TransCheck;
use Webwml::TransIgnore;

#where to compute the karma
my %karma;

# include only files matching $filename
my $filename = '(\.wml$)|(\.html$)';

my $cvs = Local::Cvsinfo->new();
$cvs->options(
	recursive => 1,
	matchfile => [ $filename ],
	skipdir   => [ "template" ],
);
#   This object is used to retrieve information when original is
#   not English
my $altcvs = $cvs->new();

#   Global .transignore
my $globtrans = Webwml::TransIgnore->new(".");

my $from = 'english';

my ($to,$langto,$transignore);
while ($to=shift) {
    $to =~ s%/$%%; # Remove slash from the end
    print "Examine $to\n";

    $langto = $to;
    $langto =~ s,^([^/]*).*$,$1,;
    
    $cvs->readinfo($from);
    foreach my $path (@{$cvs->dirs()}) {
	my $tpath = $path;
	$tpath =~ s/^$from/$to/o;
	my $transignore = Webwml::TransIgnore->new($tpath);
	next unless $transignore->found();
	foreach (@{$transignore->local()}) {
		s/^$to/$from/o;
		$cvs->removefile($_);
	}
    }

    foreach (sort @{$cvs->files()}) {
	my ($path, $tpath);
	$path = $_;
	$tpath = $path;
	$tpath =~ s/^$from/$to/o;
	check_file($tpath,
		$cvs->revision($path),
		str2time($cvs->date($path)));
    }
}

sub check_file {
	my ($name, $revision,$translator) = @_;
	my ($oldr, $oldname, $original);
        my $docname = $name;
        $docname =~ s#^$langto/##;
        $docname =~ s#\.wml$##;
	return unless (-r $name); # file does not exists

	my $transcheck = Webwml::TransCheck->new($name);
	$oldr = $transcheck->revision() || 0;
	if (!$oldr && ($name =~ m#$langto/international/$langto#i)) {
		#   This document is original, check for
		#   english/international/$langto...
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
