#!/usr/bin/perl -w

# This is a little utility designed to keep track of translations
# in the Debian web site CVS repository.

# For information about translation revisions please see
# http://www.debian.org/devel/website/uptodate

# This is GPL'ed code.
# Copyright 1998 Paolo Molaro <lupus@debian.org>.
# Copyright 2000,2001 Martin Quinson <mquinson@ens-lyon.fr>.

# Invocation:
#   check_trans.pl [-vqdlM] [-C dir] [-p pattern] [-s subtree]
#                  [-m email -n N] [-g] [-t outputtype]
#                  [language]

# It needs to be run from the top level webwml directory.
# If you don't specify a language on the command line, the language name
# will be loaded from a file called language.conf, if such a file exists.

# For example:
#   $ check_trans.pl -v italian
# You may also check only some subtrees as in:
#   $ check_trans.pl -s devel italian

# Options:
# 	-v		enable verbose mode
#	-q		just don't whine about missing files
#	-Q		enable really quiet mode
#	-C <dir>	go to <dir> directory before running this script
#	-d		output CVS diffs
#	-l		output CVS log messages
#	-T		output translated diffs
#	-p <pattern>	include only files matching <pattern>,
#			default is *.html|*.wml
#	-s <subtree>	check only that subtree
#	-t <type>	choose output type  (default is `text')
#	-M		display differences for all 'Makefile's

# Options useful when sending mails:
#	-m <email>	sends mails to translation maintainers
#			PLEASE CAREFULLY READ THE BELOW TEXT ABOUT MAKING MAILS!
#			<email> is the default recipient
#			(it should be the list used for organisation,
#			e.g. debian-l10n-french@lists.debian.org)
#	-g		debuG
#	-n <1|2|3>	send mails of priority upper or equal to
#			1 (monthly), 2 (weekly) or 3 (daily)

# Making Mails
#  If you want to, this script send mails to the maintainer of the mails.
#  BEWARE, SOME PEOPLE DO NOT LIKE TO RECEIVE AUTOMATIC MAILS!

#  PREREQUISITES:
#   You will need two databases:
#     - one in which to see which translator maintains which file
#       it must be named "./$langto/international/$langto/current_status.pl"
#       (where $langto equals "french", "italian" or so)
#       See webwml/french/international/french/current_status.pl" for example.
#     - one in which to get info about translators and the frequency at
#       which they want to get mails. It must be named
#       webwml/$langto/international/$langto/translator.db.pl
#       Please refer to the French one for more info.

#  USAGE:
#   If you give the "-g" option, all mails are sent to the default addressee
#     (i.e. the one given as value to the -m option), without respect to their
#     normal addressee. It is useful if you want to run it for yourself,
#     and for debugging.
#   Without that option, it sends real mails to real addresses.
#   MAKE SURE THE ADDRESSEES REALLY WANT TO GET THESE MAILS

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

# TODO:
# get the revisions from $lang/intl/$lang so diffing works
# need to quote dirnames?
# use a file to bind a file to a translator?

# global db variables
my $translations_status;
my $translators;# the ref resulting of require
my %translators;# the real hash

# misc hardcoded things
my $maintainer = "mquinson\@ens-lyon.fr"; # the default e-mail at which to bitch :-)

# options (note: with perl 5.6, this could change to our())
use vars qw($opt_C $opt_M $opt_Q $opt_d $opt_g $opt_l $opt_m $opt_n $opt_p $opt_q $opt_s $opt_t $opt_T $opt_v);
$opt_n = 5; # an invalid default
$opt_s = '';
$opt_C = '.';
$opt_t = 'text';

unless (getopts('vgdqQC:m:s:Tt:p:ln:M'))
{
	open SELF, "<$0" or die "Unable to display help: $!\n";
	HELP: while (<SELF>)
	{
		print, next if /^$/;
		last HELP if (/^use/);
		s/^# ?//;
		next if /^!/;
		print;
	}
	exit;
}

die "you can't have both verbose and quiet, doh!\n" if (($opt_v) && ($opt_Q));

warn "Checking subtree $opt_s only\n" if (($opt_v) && ($opt_s));

# include only files matching $filename
my $filename = $opt_p || '(\.wml$)|(\.html$)';

# Go to desired directory
chdir($opt_C) || die "Cannot go to $opt_C\n";

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

# language configuration
my $defaultlanguage = 'italian';
if (open CONF, "<language.conf")
{
	$defaultlanguage = <CONF>;
	chomp $defaultlanguage;
	close CONF;
}

my $from = 'english';
my $to = shift || $defaultlanguage;
$to =~ s%/$%%; # Remove slash from the end

my $langto = $to;
$langto =~ s,^([^/]*).*$,$1,;
if (-e "./$langto/international/$langto/current_status.pl" && 
    -e "./$langto/international/$langto/translator.db.pl") {
    print "READ PAGES DB: $langto/international/$langto/current_status.pl\n"
       if $opt_v;
    push(@INC,"./$langto/international/$langto");
    require 'current_status.pl';
    print "READ TRANSLATOR DB: $langto/international/$langto/translator.db.pl\n"
       if $opt_v;
    require 'translator.db.pl';
    %translators=%{init_translators()};
} else {
    die "I need my DBs to send mails !\n Please read the comments in the script and try again\n" if $opt_m;
}

if ($opt_m) {
    unless ($opt_n =~ m,[123],) {
	die "Invalid priority. Please set -n value to 1, 2 or 3.\n".
	    "(assuming you know what you're doing)\n";
    }
}

$from = "$from/$opt_s";
$to = "$to/$opt_s";

init_mails();

print "\$translations = {\n" if $opt_t eq 'perl';

$cvs->readinfo($from);
foreach my $path (@{$cvs->dirs()}) {
	my $tpath = $path;
	$tpath =~ s/^$from/$to/o;
	my $transignore = Webwml::TransIgnore->new($tpath);
	next unless $transignore->found();
	warn "Loading $tpath/.transignore\n" if $opt_v;
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
		str2time($cvs->date($path)),
		get_translators_from_db($tpath));
}

print "}; 1;\n" if $opt_t eq 'perl';

send_mails();

if ($opt_M) {
	foreach my $makefile (split(/\n/, `find $from -name Makefile -print`)) {
		my $destination = $makefile;
		$destination =~ s/^$from/$to/o;
		if (-e $destination) {
			STDOUT->flush;
			system("diff -u $destination $makefile");
			STDOUT->flush;
		}
	}
}

sub verify_send {
    return 1 unless ($opt_m);
    # returns true whether we have to send this part to this guy
    my $name=shift;
    my $part=shift;
    $name =~ s,<.*?>,,;
    $name =~ s,^ *(.*?) *$,$1,;
    print "$name is unknown\n" unless defined($translators{$name});
#    print "pri=$opt_n ; maint_pri=${translators{$name}{$part}}\n";
    return $opt_m # if we have to send any mail
	&& defined($translators{$name})  # if this guy is known
	&& defined($translators{$name}{$part}) # we know something about the wanted frequency
	&& ($opt_n <= $translators{$name}{$part}); # check if the frequency is ok
}

sub get_translators_from_db {
    my $id=shift;
    my $res='';

    $id=~ s,^$langto/,,;
    $id=~ s/\.wml$//;
    if (defined(%{$$translations_status{$id}})
	&& defined ($$translations_status{$id}{'translation_maintainer'})) {
	foreach my $n (sort @{$$translations_status{$id}{'translation_maintainer'}}) {
	    $res .= " $n";
	}
    } else {
	$res = "";
    }
    return $res;
}

sub init_mails {
    return unless $opt_m;
    eval q{use MIME::Lite};
    foreach my $name (keys %translators) {
	return if defined $translators{$name}{"msg"};
	$translators{$name}{"msg"} = MIME::Lite->new(
	   From    => "Script watching translation state <$maintainer>",
           To      => ($opt_g ? $opt_m : $translators{$name}{"email"}),
           Subject => ($name eq "list" ?
	    "Translations for the Debian web site unmaintained" :
	    "Translations for the Debian web site maintained by $name"
            ),
           Type    => 'multipart/mixed');
	my $str= "Hello,\n".
      	      "This is an automatically generated mail sent to you\n".
	      "because you are the official translator of some pages\n".
	      "in ".ucfirst($langto)." of the Debian web site.\n".
	      "\n".
	      "I sent you what I think you want. (i.e. what is in my DB).\n".
	      " That is to say:\n";
	foreach my $n (qw(summary logs diff tdiff file)) {
	    $str.="   ".$n.": ".
	    ($translators{$name}{$n} != 0 ?
	     ($translators{$name}{$n} != 1 ?
	      ($translators{$name}{$n} != 2 ?
	       ($translators{$name}{$n} != 3 ?
		"dunno (error in DB !!)":
		"daily"):
		"weekly"):
		"monthly"):
	     "never")."\n";
	}
	if ($name eq "list") {
	    $str .= "   missing: ".($translators{$name}{"missing"} != 0 ?
	     ($translators{$name}{"missing"} != 1 ?
	      ($translators{$name}{"missing"} != 2 ?
	       ($translators{$name}{"missing"} != 3 ?
		"dunno (error in DB !!)":
		"daily"):
		"weekly"):
		"monthly"):
	     "never")."\n";
	}
	$str.="   Compression=".$translators{$name}{"compress"}."  (not implemented)\n\n";
	$str.=" You can ask to change:\n".
              "  - the frequency of these mails\n".
	      "    (never, monthly, weekly, daily)\n".
              "  - the parts you want\n".
    	      "    - The list of the work to do in a summarized form\n".
              "    - diff between the version you translated and the current one\n".
              "    - log between the version you translated and the current one\n".
              "    - the file you translated (so that you don't have to download it manually)\n".
              "  - your email address\n".
	      "  - the compression level (none, gzip or bzip2), even if I'll ignore it\n".
              "    because this feature is not implemented yet ;)\n".
	      "\n".
	      "For more information, contact your team coordinator, or\n".
	      "the maintainer of this script ($maintainer).\n".
	      "\n".
	      "Thanks, and sorry for the annoyance.\n";

        $translators{$name}{"msg"}->attach(
           Type => 'TEXT',
           Data => $str);
	$translators{$name}{"send"}=0;
    }
}

sub send_mails {
    #Makes the mails and send them
    return unless $opt_m;
    foreach my $name (sort keys %translators) {
	$translators{$name}{"msg"}->attach(
                     Type     => 'TEXT',
	             Filename => 'NeedToUpdate_summary',
		     Data     => $translators{$name}{"part_summary"})
	    if defined($translators{$name}{"part_summary"});
	$translators{$name}{"msg"}->attach(
		     Type     => 'TEXT',
	             Filename => 'Missing_summary',
		     Data     => $translators{$name}{"part_missing"})
	    if defined($translators{$name}{"part_missing"});
	foreach my $part (qw (file logs diff tdiff)) { 
	    if (defined($translators{$name}{"part_$part"})) {
		foreach my $file (sort keys %{$translators{$name}{"part_$part"}}) {
		    $translators{$name}{"msg"}->attach(
			 Type     => 'TEXT',
	                 Filename => "$file.$part",
			 Data     => $translators{$name}{"part_$part"}{$file});
		}
	    }
	}
	if ($translators{$name}{"send"}) {
	    print "send mail to $name\n";
	    if (($name =~ m,mquinson,) || ($opt_g && $opt_m eq $maintainer)) {
		print "Well, detourned to $maintainer\n";
		$translators{$name}{"msg"}->send;
	    }
#	    $translators{$name}{"msg"}->print_header;
	    $translators{$name}{"msg"}->send;
	} else {
	    print "didn't send mail to $name: nothing to say to him\n";
	}   
    }
}

sub add_part {
    my $name = shift;
    my $part = shift;
    my $txt = shift; 
    $name =~ s,<.*?>,,;
    $name =~ s,^ *(.*?) *$,$1,;
    if (verify_send($name,$part)) {
	$translators{$name}{"part_$part"}.=$txt;
	$translators{$name}{"send"}=1;
    }
}

sub add_sub_part {
    my $name = shift;
    my $part = shift;
    my $subpart=shift;
    my $txt = shift;
    $name =~ s,<.*?>,,;
    $name =~ s,^ *(.*?) *$,$1,;
#    print "add_sub_part($name)(part=$part)($subpart):$txt" if $opt_v;
    STDOUT->flush;
    if (verify_send($name,$part)) {
#	print "YES\n";
	$translators{$name}{"part_$part"}{$subpart}.= "$txt";
	$translators{$name}{"send"}=1;
    }
#    print "no\n";
}

sub get_diff_txt {
  my ($oldr, $revision, $oldname, $name) = @_;
  my $cmd;

  # Get old revision file
  $cmd = "cvs -z3 update -r $oldr -p $oldname 2>/dev/null";
#  print "!get_diff_txt: cvs -z3 update -r ".$oldr." -p ".$oldname."\n";
  my @old_rev_file_lines = qx($cmd);

  # Get translation file
  open (FILE,"$name") || die ("Can't open `$name' for read");
  my @translation_file_lines;
  while (<FILE>) {
      $translation_file_lines[scalar @translation_file_lines] = $_;
  }
  close FILE || die ("Can't close $name after reading");

  # Get diff lines
  $cmd = "cvs -z3 diff -u -r$oldr -r $revision $oldname 2>/dev/null";
#  print "get_diff_txt: $cmd: cvs -z3 diff -u -r$oldr -r $revision $oldname\n";
  my @diff_lines = qx($cmd);

  my $txt = Local::WmlDiffTrans::find_trans_parts(\@old_rev_file_lines,
						  \@translation_file_lines,
						  \@diff_lines);

  return $txt;
}

sub check_file {
	my ($name, $revision, $mtime, $translator) = @_;
	my ($oldr, $oldname, $original);
	warn "Checking $name, English revision $revision\n" if $opt_v;
        my $docname = $name;
        $docname =~ s#^$langto/##;
        $docname =~ s#\.wml$##;
	unless (-r $name) {
		(my $iname = $name) =~ s/^$to\///;
		if (!$globtrans->is_global($iname)) {
		  unless (($opt_q) || ($opt_Q)) {
                     if ($opt_t eq 'perl') {
  	               print "'$docname' => {\n\t'type' => 'Web',\n";
  	               print "\t'revision' => '$revision',\n";
  	               print "\t'mtime' => '$mtime',\n";
  	               print "\t'status' => 1,\n";
  	               print "},\n";
                     } else {
  		       print "Missing $name version $revision\n";
                     }
		     add_part("list","missing","Missing $name version $revision\n");
		  }
		} else {
		  warn "Ignored $name\n" if $opt_v;
		}
		return;
	}
	my $transcheck = Webwml::TransCheck->new($name);
	$oldr = $transcheck->revision() || 0;
	if (!$oldr && ($name =~ m#$langto/international/$langto#i)) {
		#   This document is original, check for
		#   english/international/$langto...
		$name =~ s{^$to}{$from};
		$transcheck = Webwml::TransCheck->new($name);
		$oldr       = $transcheck->revision() || 0;
	}
	$translator = $transcheck->maintainer() || "";
	$original   = $transcheck->original();
	warn "Found translation for $oldr\n" if $opt_v and $oldr;
	warn "Translated by $translator\n"   if $opt_v and $translator;
	warn "Original is $original\n"       if $opt_v and $original;
	if ($original) {
		my ($fromname, $fromdir);
		$fromname = $name;
		$fromname =~ s{^[^/]+}{$original};
		$fromdir  = $fromname;
		$fromdir  =~ s{/+[^/]+$}{};
		$altcvs->reset();
		$altcvs->readinfo($fromdir, matchfile => [$fromname]);
		$revision = $altcvs->revision($fromname);
		warn "Original is $original, revision $revision\n" if $opt_v;
	}

	$translator =~ s/^\s+//;
	$translator =~ s/\s+$//;

	my $str;
	my $status = 8;
	(my $numrev)  = $revision =~ m/^1\.(\d+)$/; $numrev ||= "0";
	(my $numoldr) = $oldr =~ m/^1\.(\d+)$/; $numoldr ||= "0";
	if (!$oldr) {
	  $oldr = '1.1';
	  $str = "Unknown status of $name (revision should be $revision)";
	} elsif ($oldr eq $revision) {
	  $status = 4;
	} elsif ($numoldr > $numrev) {
	  $str = "Broken revision number $oldr for $name, it should be $revision";
	} else {
	  $str = "NeedToUpdate $name from version $oldr to version $revision";
	  $status = 3;
	}
	$str .= " (maintainer: $translator)" if $translator;
	if ($opt_t eq 'perl') {
  	  print "'$docname' => {\n\t'type' => 'Web',\n";
  	  print "\t'revision' => '$revision',\n";
  	  print "\t'mtime' => '$mtime',\n";
  	  print "\t'base_revision' => '$oldr',\n";
  	  print "\t'translation_maintainer' => ['$translator'],\n" if $translator;
  	  print "\t'status' => $status,\n";
  	  print "},\n";
	} elsif ($str && $oldr ne $revision) {
	  $str .= "\n";
	  print $str unless ($opt_Q);
	}

	return if (defined($oldr) && ($oldr eq $revision));

	$oldname = $name;
	$oldname =~ s/^$to/$from/;

	my @logrev = split(/\./, $oldr);
	$logrev[$#logrev] ++;
	my $logoldr = join('.', @logrev);

	if ($opt_m) {
	    $translator = "list" if ($translator eq "");
	    add_part($translator,"summary",$str);
	    add_sub_part($translator,"diff",$name,
		 join("",qx(cvs -z3 diff -u -r'$oldr' -r $revision $oldname)));
	    add_sub_part($translator,"tdiff",$name,
		 get_diff_txt("$oldr","$revision","$oldname","$name"));

	    add_sub_part($translator,"logs",$name,
		 join("",qx(cvs -z3 log -r$logoldr:$revision $oldname)));
	    add_sub_part($translator,"file",$name,
		 join("",qx(cat $name)));
	}
	    
	if ($opt_d) {
		STDOUT->flush;
		my $cvsline = "cvs -z3 log -r'$logoldr:$revision' '$oldname'";
		warn "Running $cvsline\n" if (($opt_v) && ($opt_l));
		system($cvsline) if $opt_l;
		STDOUT->flush if $opt_l;
		$cvsline = "cvs -z3 diff -u -r '$oldr' -r '$revision' '$oldname'";
		warn "Running $cvsline\n" if $opt_v;
		system($cvsline);
		STDOUT->flush;
	} 

	if ($opt_T) {
	    print get_diff_txt("$oldr", "$revision", "$oldname", "$name")."\n";
	}
}
