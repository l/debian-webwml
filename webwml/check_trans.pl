#!/usr/bin/perl -w

# This is a little utility designed to keep track of translations
# in the Debian web site CVS repository.

# For information about translation revisions please see
# http://www.debian.org/devel/website/uptodate

# This is GPL'ed code, copyright 1998 Paolo Molaro <lupus@debian.org>
# Copyright 2000 Martin Quinson <mquinson@ens-lyon.fr>

# Invocation:
#   check_trans.pl [-vqdlM] [-p pattern] [-s subtree]
#                  [-m email] [-g] [-n N]
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
#	-d		output CVS diffs
#	-l		output CVS log messages
#	-p <pattern>	include only files matching <pattern>,
# 			default is *.html|*.wml
#	-s <subtree>	check only that subtree
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
#  o You will need two databases:
#     - one in which to see which translator maintains which file
#       it must be named "./$langto/international/$langto/current_status.pl"
#       (where $langto equals "french", "italian" or so)
#       See webwml/french/international/french/current_status.pl" for example.
#     - one in which to get info about translators and the frequency at
#       which they want to get mails. It must be named
#       webwml/$langto/international/$langto/translator.db.pl
#       Please refer to the French one for more info.
#  o You must also have the perl module called "MIME::Lite",
#    install the package libmime-lite-perl or get it from CPAN

#  USAGE:
#   - If you give the "-g" option, all mails are sent to the default addressee
#     (i.e. the one given as value to the -m option), without respect to their
#     normal addressee. It is useful if you want to run it for yourself,
#     and for debugging.
#     Without that option, it sends real mails to real addresses.
#     MAKE SURE THE ADDRESSEES REALLY WANT TO GET THESE MAILS

use Getopt::Std;
use IO::Handle;
# Well, uncommenting the next line implies to define the opt_blah with 'our'
# in perl 5.6, which is not a valid keyword in older version. So, we can't
# use strict for now, which is, IMHO, a bad thing. -- Martin
# Let's wait for perl 5.6 to be in wider use
#use strict;

# TODO:
# get the revisions from $lang/intl/$lang so diffing works
# need to quote dirnames?
# use a file to bind a file to a translator?

# from db
my $translations_status;
my $translators;# the ref resulting of require
my %translators;# the real hash

# misc
my @en; #english files
my $showlog; # boolean
my $maintainer = "mquinson\@ens-lyon.fr"; # the default e-mail to bitch at :-)
my $ignorables = "/sitemap.wml "
		."/MailingLists/subscribe.wml "
		."/MailingLists/unsubscribe.wml "
		."/international/l10n/data/countries.wml "
		."/international/l10n/scripts/l10nheader.wml "
		; # $ignorables must end with a space!

# options
$opt_d = 0;
$opt_s = '';
$opt_p = undef;
$opt_l = 0;
$opt_g = 0; 
$opt_m = undef;
$opt_n = 5; # an invalid default
$opt_M = 0;
$opt_v = 0;
$opt_q = 0;
$opt_Q = 0;

unless (getopts('vgdqQm:s:p:ln:M'))
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

#my $langfrom = $from;

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

@en= split(/\n/, `find $from -name Entries -print`);

$showlog = $opt_l;

init_mails();
foreach (@en) {
	next if $_ =~ "template/debian";
	my ($path, $tpath, $d);
	$path = $_;
	$path =~ s,CVS/Entries$,,;
	$tpath = $path;
	$tpath =~ s/^$from/$to/o;
	my %d = %{load_entries($_)};
	my $ignore = load_ignorelist($tpath);
	foreach my $f (keys %{$d{"rev"}}) {
	    check_file("${tpath}$f", 
		       $d{"rev"}->{$f},
		       get_translators_from_db("$tpath$f"))
		unless $$ignore{"${tpath}$f"};
	}
}

send_mails();

if ($opt_M)
{
	@makefile= split(/\n/, `find $from -name Makefile -print`);
	foreach $makefile (@makefile) {
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
	      "to $langto of the Debian web site.\n".
	      "\n".
	      "I sent you what I think you want. (i.e. what is in my DB).\n".
	      " That is to say:\n";
	foreach my $n (qw(summary logs diff file)) {
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
              "    - the file you translated (to avoid to download it before to work)\n".
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
	foreach my $part (qw (file logs diff)) { 
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
		print "Well, detoured to $maintainer\n";
		$translators{$name}{"msg"}->send;
	    }
#	    $translators{$name}{"msg"}->print_header;
	    $translators{$name}{"msg"}->send;
	} else {
	    print "didn't send mail to $name: nothing to say to him\n";
	}   
    }	
}

sub load_entries {
	my ($name) = shift;
	my (%data);
	warn "Loading $name\n" if $opt_v;
	open(F, $name) || die $!;
	while(<F>) {
		next unless m,^/,;
		if ( m,^/([^/]+)/([^/]+)/, ) {
			my($name, $rev) =($1, $2);
			$data{"rev"}->{$name} = $rev if $name =~ /$filename/o;
		}
	}
	close (F);
	return \%data;
}

sub load_ignorelist {
	my ($dir) = shift;
	my (%data);
	open(F, "${dir}.transignore") || return \%data;
	warn "Loading ${dir}.transignore\n" if $opt_v;
	while(<F>) {
		chomp;
		$data{"$dir$_"} = 1;
	}
	close (F);
	return \%data;
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
    my $cmd = shift;
    $name =~ s,<.*?>,,;
    $name =~ s,^ *(.*?) *$,$1,;
#    print "add_sub_part($name)(part=$part)($subpart):";
    if (verify_send($name,$part)) {
#	print "YES\n";
	$translators{$name}{"part_$part"}{$subpart}.=`$cmd`;
	$translators{$name}{"send"}=1;
#	return;
    }
#    print "no\n";
}
	


sub check_file {
	my ($name, $revision, $translator) = @_;
	my ($oldr, $oldname, $original);
	warn "Checking $name, English revision $revision\n" if $opt_v;
	unless (-r $name) {
		($iname = $name) =~ s/$to//;
		if (index($ignorables, "$iname ") < 0) {
		  unless (($opt_q) || ($opt_Q)) {
  		     print "Missing $name version $revision\n";
		     add_part("list","missing","Missing $name version $revision\n");
		  }
		} else {
		  warn "Ignored $name\n" if $opt_v;
		}
		return;
	}
	open(F, $name) || die $!;
	while(<F>) {
		if (/wml::debian::translation-check/) {
			if (/translation="([^"]+)"/) {
				$oldr = $1;
				warn "Found translation for $oldr\n" if $opt_v;
			}
			if (/maintainer="([^"]+)"/) {
				$translator = $1;
				warn "Translated by $translator\n" if $opt_v;
			}
			if (/original="([^"]+)"/) {
				$original = $1;
				warn "Original is $original\n" if $opt_v;
			}
			last;
		}
		# the following old style cases should be removed eventually
		if (/translation\s+([.0-9]*)\s*-->/i) {
			$oldr = $1;
			warn "Found translation for $oldr\n" if $opt_v;
		}
		if (/Translat(.*?): (.*)$/i) {
		    $translator=$2 if ($translator eq "");
		    warn "Translated by $translator\n" if $opt_v;
		}
		last if (($oldr) && ($translator));
	}
	close(F);

	if ((!$oldr) && ($name =~ /$langto\/international\/$langto/)) {
	    ($ename = $name) =~ s/$to/$from/;
	    open FE, $ename || die $!;
	    while (<FE>) {
		if (/wml::debian::translation-check/) {
		    if (/translation="([^"]+)"/) {
			$oldr = $1;
			warn "Found translation for $1\n" if $opt_v;
		    }
		    if (/original="([^"]+)"/) {
			$original = $1;
			warn "Original is $1\n" if $opt_v;
		    }
		    last;
		}
	    }
	    close FE;
	}

	return if (defined($oldr) && ($oldr eq $revision));

        $translator =~ s/^\s*(.*?)\s*/$1/;

	my $str;
	if (!$oldr) {
	  $oldr = '1.1';
	  $str = "Unknown status of $name (revision should be $revision)";
	} elsif ($oldr >> $revision) {
	  $str = "Broken revision number $oldr for $name, it should be $revision";
	} else {
	  $str = "NeedToUpdate $name from version $oldr to version $revision";
	}
	$str .= " (maintainer: $translator)" if $translator;
	if ($str) {
	  $str .= "\n";
	  print $str unless ($opt_Q);
	}

	$oldname = $name;
	$oldname =~ s/^$to/$from/;

	my @logrev = split(/\./, $oldr);
	$logrev[$#logrev] ++;
	my $logoldr = join('.', @logrev);

	if ($opt_m) {
	    $translator = "list" if ($translator eq "");
	    add_part($translator,"summary",$str);
	    add_sub_part($translator,"diff",$name,
			 "cvs -z3 diff -u -r'$oldr' -r '$revision' '$oldname'");
	    add_sub_part($translator,"logs",$name,
			 "cvs -z3 log -r'$logoldr:$revision' '$oldname'");
	    add_sub_part($translator,"file",$name,
			 "cat $name");
	}
	    
	if ($opt_d) {
		STDOUT->flush;
		$cvsline = "cvs -z3 log -r'$logoldr:$revision' '$oldname'";
		warn "Running $cvsline\n" if (($opt_v) && ($showlog));
		system($cvsline) if $showlog;
		STDOUT->flush if $showlog;
		$cvsline = "cvs -z3 diff -u -r '$oldr' -r '$revision' '$oldname'";
		warn "Running $cvsline\n" if $opt_v;
		system($cvsline);
		STDOUT->flush;
	} 
}
