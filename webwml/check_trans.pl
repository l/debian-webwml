#!/usr/bin/perl
#
#  This is a little utility designed to keep track of translations
#  in the Debian web site Subversion repository.
#
## For information about translation revisions please see
## https://www.debian.org/devel/website/uptodate
#
#  Copyright (C) 2008 Bas Zoetekouw <bas@debian.org>
#  Based on on code from:
#   Copyright (C) 1998 Paolo Molaro <lupus@debian.org>
#   Copyright (C) 1999-2003 Peter Karlsson <peterk@debian.org>
#   Copyright (C) 2000,2001 Martin Quinson <mquinson@ens-lyon.fr>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of version 2 of the GNU General Public License as
#  published by the Free Software Foundation.
#
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
#
#
#  Invocation:
#    check_trans.pl [-cdlvqQ] [-C dir] [-p pattern] [-s subtree]
#                   [-m { -n <num> | -M <email> } [-g] ]
#                   [-t outputtype]
#                   [language]
#
#  It needs to be run from the top level webwml directory.
#  If you don't specify a language on the command line, the language name
#  will be loaded from a file called language.conf, if such a file exists.
#
#  For example:
#    $ check_trans.pl -v italian
#  You may also check only some subtrees as in:
#    $ check_trans.pl -s devel italian
#
#  Options:
#       -Q            be really quiet (only show errors/warnings on stderr)
#       -q            just don't whine about missing files
#       -v            show the status of all files (verbose)
#       -V            output what we're doing (very verbose)
#       -d            output diffs
#       -l            output log messages
#       -T            output translated diffs
#       -p <pattern>  include only files matching <pattern>,
#                     default is *.src|*.wml
#       -s <subtree>  check only that subtree
#       -a            output age of translation (if older than 2 months)
#       -c            disable use of color in the output
#
#  Options useful when sending mails:
#       -m            sends mails to translation maintainers as specified in
#                     in database in $lang/international/$lang/translator.db.pl
#                     PLEASE CAREFULLY READ THE BELOW TEXT ABOUT MAKING MAILS!
#       -n <1|2|3>    send mails of priority upper or equal to 1 (monthly),
#                     2 (weekly) or 3 (daily), as specified in the translator
#                     database
#       -M <email>    instead of using the translator database, send all email
#                     the specified address.  The translator database is not
#                     used.
#       -g            instead of sending mails, dump them to the console
#                     (no mails will be sent)
#
#  GENERATING EMAILS
#   If you want to, this script send mails to the maintainer of the mails.
#   BEWARE, SOME PEOPLE DO NOT LIKE TO RECEIVE AUTOMATIC MAILS!
#
#   PREREQUISITES:
#    You will need one database:
#      - one in which to get info about translators and the frequency at
#        which they want to get mails. It must be named
#        webwml/$lang/international/$lang/translator.db.pl
#        Please refer to the French one for more info.
#
#   USAGE:
#    If you give the "-g" option, all mails are written to the console.  No
#    mails are sent out at all.  This is useful for debugging.
#    If you specify an email addres with the "-M" options, all mails are sent
#    to the specified addressee.  No mails are sent to any other addresses.  It
#    is useful if you want to run it for yourself.
#    Without either of these options, real mails will be sent to real
#    addresses.
#    MAKE SURE THE ADDRESSEES REALLY WANT TO GET THESE MAILS!

use Getopt::Std;
use File::Basename;
use File::Spec::Functions;
use Term::ANSIColor;
use Encode;
#use Data::Dumper;
use FindBin;
FindBin::again();

# These modules reside under webwml/Perl
use lib "$FindBin::Bin/Perl";
use Local::VCS ':all';
use Local::Util qw/ uniq read_file /;
use Local::WmlDiffTrans;
use Webwml::TransCheck;
use Webwml::TransIgnore;

use strict;
use warnings;


# global variable to record verbosity
my $VERBOSE  = 0;

# default files to process
my $DEFAULT_PATTERN = '(?:\.wml|\.src)$';

# status codes
use constant {
	ST_MISSING     => 1,
	ST_NEEDSUPDATE => 3,
	ST_UPTODATE    => 4,
	ST_NOTATRANSL  => 5,
	ST_BROKEN      => 6,
	ST_OBSOLETE    => 7,
	ST_UNDEFINED   => 8,
};

# how to colour each different status
my %COLOURS = (
	main::ST_MISSING     => 'magenta',
	main::ST_NEEDSUPDATE => 'blue',
	main::ST_UPTODATE    => 'green',
	main::ST_NOTATRANSL  => 'yellow',
	main::ST_BROKEN      => 'red',
	main::ST_OBSOLETE    => 'red',
	main::ST_UNDEFINED   => 'red',
	'warn'               => 'bold red',
);

# default values for sending mails
my $MY_EMAIL = q{Debian WWW translation watch <debian-www@lists.debian.org>};
my $DEFAULT_SUBJECT = q{Debian web page translations needing updates};
(my $DEFAULT_BODY = <<"EOF") =~ s/^\t//gm;
	Hi!

	This is an automatic message providing an overview of Debian webpages
	of which the translation is outdated.

	Kind regards,
	Your automatic daemon.
EOF

# these is called in "main" so need to be declared here
sub switch_var(\$\$);
sub verbose;

#=================================================
#== "main"
#==
{
	# install a signal handler to catch Ctrl-C
	$SIG{'INT'} = \&handle_INT;

	# parse the command line
	my ($language,$file_pattern,%OPT) = parse_cmdargs();

	# read the tranlator db if we need it (-n was specified)
	my %translators = $OPT{n} ? read_translators( $language ) : ();

	# this hash will be used to store the emails we want to send out
	my %emails_to_send;

	# the subdirs where the english and translated files are located
	my $english_path  = 'english';
	my $language_path = $language;

	# -s allows the user to restrict processing to a subtree
	my $subdir = $OPT{'s'} || undef;

	my $VCS = Local::VCS->new();

	# Global .transignore
	my $transignore = Webwml::TransIgnore->new($VCS->get_topdir());

	# first get a list with revision information from all files in english...
	my %english_revs = $VCS->path_info( $english_path,
		'recursive' => 1,
		'match_pat' => $file_pattern,
		'skip_pat'  => '^template/'
	);
	# ... and in the translation
	my %translation_revs = $VCS->path_info( $language_path,
		'recursive' => 1,
		'match_pat' => $file_pattern,
		'skip_pat'  => '^template/'
	);

	# construct a list with all files that either occur in english or
	# in the translation
	my @files = uniq ( keys %english_revs, keys %translation_revs );


	# now check each of the files
	foreach my $file (sort @files)
	{
		# ignore this file?
		next if $transignore->is_global( $file );
		next if $subdir and not $file =~ m{^$subdir};

		# note: $language is the name of the current language we're
		# processing, whereas $transl is the name of the language which the
		# current file is translated into (which might be english!)
		my $orig   = 'english';
		my $transl = $language;

		my $file_orig   = catfile( $orig,   $file );
		my $file_transl = catfile( $transl, $file );

		my $revinfo_orig   = $english_revs{$file};
		my $revinfo_transl = $translation_revs{$file};

		# TODO: put this in a separate function
		# first we check if the translated file has an origin other than
		# english
		if ( -e $file_transl )
		{
			my $transcheck = Webwml::TransCheck->new( $file_transl );
			my $original_lang = $transcheck->original();

			if ( $original_lang  and  $original_lang ne 'english' )
			{
				die( "Unknown original language `$original_lang' "
				    ."for `$file_transl'\n" ) unless -d $original_lang;

				verbose "`$file_transl' is translated from $original_lang";

				# now, we use the correct (non-english) original file
				$file_orig  = catfile( $original_lang, $file );

				# and find the correct revision info for this file
				$revinfo_orig = { $VCS->file_info( $file_orig ) };
			}
		}

		# TODO: put this in a separate function
		# secondly, we check if perhaps the original file is a translation
		# (such as in the case of english/international/Swedish/index.wml)
		if ( -e $file_transl and -e $file_orig )
		{
			my $transcheck    = Webwml::TransCheck->new( $file_orig );
			my $original_lang = $transcheck->original();
			my $rev           = $transcheck->revision();

			if ( $rev )
			{
				## This check is too strict: some translators like to translate
				##from other translations rather than from the original english
				##(see e.g., danish/international/Norwegian.wml)
				#if ( not $original_lang )
				#{
				#	# TODO: ideally, this would also be mailed out to the
				#	# translation team
				#	warn "`$file_orig' has a revision header but no origin language\n";
				#	next;
				#}

				if ( $original_lang   and  $original_lang eq $language )
				{
					verbose "`$file_orig' is a translation from $language";

					# switch $orig and $transl
					switch_var( $orig,         $transl         );
					switch_var( $file_orig,    $file_transl    );
					switch_var( $revinfo_orig, $revinfo_transl );
				}
			}
		}

		# skip original files (i.e., most of english)
		next if ( $file_orig eq $file_transl );

		# determine the status of the file
		my ($status,$str,$rev_transl,$maintainer,$maxdelta) = check_file(
			$VCS,
			$file,
			$orig, $transl,
			$revinfo_orig, $revinfo_transl,
		);


		######################################################################
		## Everything below is just output logic
		######################################################################

		# print info
		if (    ( $OPT{v} )
		     or ( $status == ST_MISSING  and  not $OPT{q}  )
		     or ( $status != ST_MISSING  and  $status != ST_UPTODATE
		          and  $status != ST_NOTATRANSL )
		)
		{
			print colored( "$str\n", $COLOURS{$status} );
		}

		# check age of the translation
		if ( $OPT{a} and $status == ST_NEEDSUPDATE )
		{
			my $age = int get_revision_age( $revinfo_transl );

			# only warn if the translation is older than 2 weeks
			if ( $age > 14 )
			{
				print colored( "$file is outdated by $age days\n",
					$COLOURS{warn} );
			}
		}

		# print log if requested and an update is needed
		if ( $OPT{'l'}  and  $status == ST_NEEDSUPDATE )
		{
			my $log = get_log(
				$VCS,
				$file_orig,
				$rev_transl,
				$revinfo_orig->{'cmt_rev'},
			);
			print $log;
		}

		# print diff if requested and an update is needed
		if ( $OPT{'d'}  and  $status == ST_NEEDSUPDATE )
		{
			my $diff = get_diff(
				$VCS,
				$file_orig,
				$rev_transl,
				$revinfo_orig->{'cmt_rev'},
			);
			print $diff;
		}

		# print text diff, if requested and an update is needed
		if ( $OPT{'T'}  and  $status == ST_NEEDSUPDATE )
		{
			my $diff = get_diff_txt(
				$VCS,
				$file_orig,
				$rev_transl,
				$revinfo_orig->{'cmt_rev'},
				$file_transl
			);
			print $diff;
		}


		# prepare a mail to be sent
		if ( $OPT{'m'}  and  $status != ST_UPTODATE )
		{
			# -M was specified, so all mails to there
			if ( $OPT{'M'} )
			{
				$maintainer = 'default';

				# don't send mail about untranslated files if -q was specified
				$maintainer = 'none' 
					if $status == ST_MISSING and $OPT{'q'} 
			}
			else # addresses from the database is used
			{
				# handle special case maintainer fields
				$maintainer = 'unmaintained'
					unless $maintainer and exists $translators{$maintainer};
				$maintainer = 'untranslated'
					if $status == ST_MISSING;
			}

			verbose  "Found maintainer $maintainer for this file";

			# mail to send to the maintainer
			push @{ $emails_to_send{$maintainer} }, {
				'file'           => $file,
				'status'         => $status,
				'info'           => $str,
				'last_trans_rev' => $rev_transl,
			};

			# additionally, if -n was specified, also see if we need to
			# send a mail to maxdelta
			if ( $OPT{'n'}  and  $status != ST_MISSING  and  -e $file_orig )
			{
				$maxdelta ||= $translators{maxdelta}{maxdelta} || 5;

				my $delta;
				$delta = $VCS->count_changes( $file_orig, $rev_transl, 'HEAD' );

				if ( $delta >= $maxdelta )
				{
					push @{ $emails_to_send{'maxdelta'} }, {
						'file'           => $file,
						'status'         => $status,
						'info'           => $str,
						'delta'          => $delta,
						'last_trans_rev' => $rev_transl,
					}
				}
			}

		}

	}

	send_email( $VCS, \%emails_to_send, \%translators, $language, 
		$OPT{'n'}, $OPT{'M'}, $OPT{'g'} );

	exit 0;
}
die("Never reached");


#=================================================
#== swich two variables around
#==
sub switch_var(\$\$)
{
	my $a = shift;
	my $b = shift;

	my $c = $$a;
	$$a = $$b;
	$$b = $c;
}


#=================================================
#== output verbose messages
#==
sub verbose
{
	return unless $VERBOSE;
	print @_, "\n";
}

#=================================================
#== handles INT signal
#==
sub handle_INT
{
	# reset terminal color
	print color('reset');
	die( "Interrupted by user" );
}

#=================================================
#== send out the emails
#==
sub send_email
{
	my $VCS         = shift;
	my $emails      = shift  or  die("No emails specified");
	my $translators = shift  or  die("No translators specified");
	my $lang        = shift  or  die("No language specified");
	my $priority    = shift;
	my $default_rec = shift;
	my $debug       = shift;

	foreach my $name (sort keys %$emails)
	{
		# special case
		next if $name eq 'none';

		verbose("Preparing email for $name");

		my $recipient;
		my $subject;
		my $mailbody;

		# First handle the case in whcih all mail goes to the -M address
		if ( $default_rec )
		{
			# address was already validated while parsing the command line
			$recipient = $default_rec;
			$subject   = $DEFAULT_SUBJECT;
			$mailbody  = $DEFAULT_BODY;
		}
		else # handle the case in whcih addresses are fetch from the db
		{
			# skip unconfigured users
			if ( not exists $translators->{$name}
					or  not $translators->{$name}{'email'} )
			{
				verbose( "Woops!  Can't find info for user `$name'\n" );
				next;
			}

			# check the user's email addres
			if ( not Email::Address->parse( $translators->{$name}{'email'} ) )
			{
				printf STDERR "Can't parse email address `%s' for %s!\n",
					$translators->{$name}{'email'}, $name;
				next;
			}

			# skip if the user doesn't want a summary at all
			if ( $translators->{$name}{'summary'} < $priority )
			{
				verbose( "Not sending message to $name (prio "
					. $translators->{$name}{'summary'} . " < $priority)" );
				next;
			}

			$recipient = $translators->{$name}{'email'};
			$subject   = $translators->{'default'}{'mailsubject'};

			# read body and interpret perl that's embedded there
			$mailbody = read_file_enc( $translators->{'default'}{'mailbody'} )
				or die("Can't read $translators->{'default'}{'mailbody'}");
			{
				# a bit hackish, but I want to keep the curent format of
				# the mail body files intact, for now
				# so we need to use the same old variable names as the original
				# script used
				my %translators = %{$translators};
				$mailbody =~ s{#(.*?)#}{eval $1}mge;
			}

		}

		my $msg = MIME::Lite->new(
			'From'    => $MY_EMAIL,
			'To'      => $recipient,
			'Subject' => $subject,
			'Type'    => 'multipart/mixed',
		);

		# and attach the body to the mail
		my $part = MIME::Lite->new(
			'Type' => 'text/plain',
			'Data' => encode('utf-8',$mailbody),
		);
		$part->attr( 'content-type.charset' => 'utf-8' );
		$msg->attach( $part );

		# attach part about NeedToUpdate files
		my $text = '';
		foreach my $file ( @{ $emails->{$name} } )
		{
			next unless $file->{'status'} == ST_NEEDSUPDATE;
			$text .= $file->{'info'};

			if ( exists $file->{'delta'} )
			{
				$text .= sprintf( " [out of date by %d revisions]",
					$file->{'delta'} );
			}

			$text .= "\n";
		}
		$msg->attach(
			'Type'     => 'TEXT',
			'Filename' => 'NeedToUpdate summary',
			'Data'     => $text,
		)
		if $text;

		# attach part about Missing files
		if ( not $default_rec )
		{
			$text = '';
			foreach my $file ( @{ $emails->{$name} } )
			{
				next unless $file->{'status'} == ST_MISSING;
				$text .= sprintf( "%s\n", $file->{'info'} );
			}
			$msg->attach(
				'Type'     => 'TEXT',
				'Filename' => 'Missing summary',
				'Data'     => $text,
				'Encoding' => 'quoted-printable',
			)
			if $text;
		}

		# add diffs, if requested
		if ( $default_rec  or  $priority <= $translators->{$name}{'diff'} )
		{
			foreach my $file ( @{ $emails->{$name} } )
			{
				# diffs really only make sense if there is an existing
				# translation
				next unless $file->{'status'} == ST_NEEDSUPDATE;

				my $filename = catfile( 'english', $file->{'file'} );
				my $rev      = $file->{'last_trans_rev'};
				my $diff     = get_diff( $VCS, $filename, $rev, 'HEAD' );
				$msg->attach(
					'Type'	   => 'TEXT',
					'Filename' => "$filename.diff",
					'Data'     => $diff,
					'Encoding' => 'quoted-printable',
				);
			}
		}
		else
		{
			verbose( "Not attaching diffs  (prio "
				. $translators->{$name}{'diff'} . " < $priority)" );
		}

		# add tdiffs, if requested
		if ( not $default_rec  and  $priority <= $translators->{$name}{'tdiff'} )
		{
			foreach my $file ( @{ $emails->{$name} } )
			{
				# diffs really only make sense if there is an existing
				# translation
				next unless $file->{'status'} == ST_NEEDSUPDATE;

				my $filename  = catfile( 'english', $file->{'file'} );
				my $filename2 = catfile( $lang,     $file->{'file'} );
				my $rev       = $file->{'last_trans_rev'};
				my $tdiff    =  get_diff_txt( $VCS, $filename, $rev, 'HEAD',
					$filename2 );
				$msg->attach(
					'Type'	   => 'TEXT',
					'Filename' => "$filename.tdiff",
					'Data'     => $tdiff,
					'Encoding' => 'quoted-printable',
				);
			}
		}
		else
		{
			verbose( "Not attaching tdiffs (prio "
				. $translators->{$name}{'tdiff'} . " < $priority)" )
			unless $default_rec;
		}

		# add logs, if requested
		if ( $default_rec  or  $priority <= $translators->{$name}{'logs'} )
		{
			foreach my $file ( @{ $emails->{$name} } )
			{
				# logs really only make sense if there is an existing
				# translation
				next unless $file->{'status'} == ST_NEEDSUPDATE;

				my $filename  = catfile( 'english', $file->{'file'} );
				my $rev       = $file->{'last_trans_rev'};
				my $log       = get_log( $VCS, $filename, $rev, 'HEAD' );
				my $part = MIME::Lite->new(
					'Type'     => 'TEXT',
					'Filename' => "$filename.log",
					'Data'     => $log,
					'Encoding' => 'quoted-printable',
				);
				$part->attr( 'content-type.charset' => 'utf-8' );
				$msg->attach( $part );
			}
		}
		else
		{
			verbose( "Not attaching logs   (prio "
				. $translators->{$name}{'logs'} . " < $priority)" );
		}

		# add file, if requested
		if ( not $default_rec  and  $priority <= $translators->{$name}{'file'} )
		{
			foreach my $file ( @{ $emails->{$name} } )
			{
				my $filename  = catfile( $lang, $file->{'file'} );
				my $part = MIME::Lite->new(
					'Type'	   => 'text/wml',
					'Filename' => $filename,
					'Path'     => $filename,
					'Encoding' => 'quoted-printable',
				);
				$part->attr( 'content-type.charset' => get_file_charset($filename) );
				$msg->attach( $part );

			}
		}
		else
		{
			verbose( "Not attaching files  (prio "
				. $translators->{$name}{'file'} . " < $priority)" )
				unless $default_rec;
		}



		# check if we really want to send the mail
		if ( $debug )
		{
			print color('bold yellow');
			print '*'x72, "\n";
			printf "Would send email to %s (but -g was specified):\n",
				$recipient;
			print '-'x72, "\n";
			print color('reset');

			# make sure perl doesn't do any annoying charset conversions
			binmode( \*STDOUT, ':bytes' );
			print $msg->as_string;

			print color('bold yellow');
			print '*'x72, "\n";
			print color('reset');
		}
		else
		{
			verbose "Sending email to $recipient";
			$msg->send  or  warn("Couldn't send message to $name");
		}
	}
}


#=================================================
#== return the age of the revision (in days)
#==
sub get_revision_age
{
	my $rev_info = shift;

	die("No revision info specified") unless ref $rev_info eq 'HASH';

	my $rev_timestamp = $rev_info->{'cmt_date'};
	my $age = time - $rev_timestamp;

	warn( "Timestamp is in the future!" ) if $age < 0;

	# return age in days
	return $age / ( 60*60*24 );
}



#=================================================
#== get a log
#==
sub get_log
{
	my $VCS = shift;
	my $file = shift or die("No file specified for diff");
	my $rev1 = shift;
	my $rev2 = shift;

	die("NO such file `$file'") unless -e $file;

	my @log = $VCS->get_log( $file, $rev1, $rev2 );

	# remove the first item of the log, because we only want
	# to see when changed in the (left-open) range (rev1,rev2]
	shift @log;

	# format it nicely
	my $str = '-' x 78 . "\n";
	foreach my $l (@log)
	{
		chomp $l->{'message'};

		$str .= sprintf( "%s | %s | %s\n",
			$l->{'rev'}, $l->{'author'}, scalar localtime $l->{'date'} );
		$str .= "\n";
		$str .= $l->{'message'} . "\n";
		$str .= "\n";

		$str .= '-' x 78 . "\n";

	}


	return $str;
}

#=================================================
#== get a diff
#==
sub get_diff
{
	my $VCS = shift;
	my $file = shift or die("No file specified for diff");
	my $rev1 = shift;
	my $rev2 = shift;

	die("NO such file `$file'") unless -e $file;

	my %diffs = $VCS->get_diff( $file, $rev1, $rev2 );

	# just glue all diffs together and return it as a big string
	my $difftxt = join( '', values %diffs );

	return $difftxt;
}

#=================================================
#== get a diff while trying to match html tags
#==
sub get_diff_txt
{
	my $VCS = shift;
	my $english_file = shift or die("No file specified");
	my $rev1         = shift or die("No revision specified");
	my $rev2         = shift or die("No revision specified");
	my $transl_file  = shift or die("No transl file specified");

	die("No such file $english_file") unless -e $english_file;
	die("No such file $transl_file")  unless -e $transl_file;

	# Get old revision file
	my @english_txt = split( "\n", $VCS->get_file( $english_file, $rev1 ) );

	# Get translation file
	my $transl_txt = read_file( $transl_file )
		or die("Couln't read `$transl_file': $!");
	my @transl_txt = split( "\n", $transl_txt );

	# Get diff lines
	my @diff_txt = split( "\n", get_diff( $VCS, $english_file, $rev1, $rev2 ) );

	# do the matching
	my $txt = Local::WmlDiffTrans::find_trans_parts(
		\@english_txt,
		\@transl_txt,
		\@diff_txt
	);

	return $txt;
}


#=================================================
#== show help from the top of this file
#==
sub show_help
{
	# read the help from the comments above and display it
	open( my $me, '<', $0 ) or die "Unable to display help: $!\n";

	while ( my $line = <$me> )
	{
		last        if     $line =~ m{^use};
		print "\n"  if     $line =~ m{^#$};
		next        unless $line =~ m{^# };

		$line =~ s{^#  ?}{};

		print $line;
	}

	close( $me );
}


#=================================================
#== parse command line options and read defaults
#==
sub parse_cmdargs
{
	my %OPT;
	$OPT{s} = '';

	# parse options
	if ( not getopts( 'acdghlmM:n:p:Qqs:TvV', \%OPT )  )
	{
		show_help();
		exit -1;
	}

	# show help
	if ( $OPT{h} )
	{
		show_help();
		exit 0;
	}

	# handle verbosity setting
	if ( ( $OPT{'v'} or $OPT{'V'} ) and ( $OPT{'q'} or $OPT{'Q'} ) )
	{
		die "you can't have both verbose and quiet, doh!\n";
	}
	$VERBOSE  = 1  if $OPT{'V'};
	$OPT{'v'} = 1  if $OPT{'V'};

	# handle really quiet setting
	if ( $OPT{'Q'} )
	{
		# redirect stdout to /dev/null
		close( STDOUT );
		open( STDOUT, '>', '/dev/null' )
			or die( "Can't redirect STDOUT to /dev/null: $!" );
	}

	# handle -c (disable color) setting
	if ( $OPT{'c'} )
	{
		# nice feature of Term::ANSIColor
		$ENV{'ANSI_COLORS_DISABLED'} = '1';
	}
	else
	{
		# we need flushed STDOUT putput, because otherwise the colours wills
		# blend into STDERR
		$| = 1;
	}

	# handle -s (subtree check) setting
	if ( $OPT{s})
	{
		verbose "Checking subtree $OPT{s} only\n";
	}

	# check validity of mail options
	# if -m is specified, either -n or -M must also be given
	# furthermore, the argument to -n must be 1, 2, or 3, and
	# the argument to -M must be a valid email address
	if ( $OPT{'m'} )
	{
		# load additional module we need for mail
		eval {
			require MIME::Lite;
			import MIME::Lite;
		};
		die "The module MIME::Lite could not be loaded.\n"
		   ."Please install libmime-lite-perl\n"   if $@;

		eval {
			require Email::Address;
			import Email::Address;
		};
		die "The module Email::Address could not be loaded.\n"
		   ."Please install libemail-address-perl\n"   if $@;

		# now check the options
		if ( $OPT{'n'} and $OPT{'M'} )
		{
			die "You can't specify both -n and -M\n";
		}
		elsif ( $OPT{'n'} )
		{
			die "Invalid priority `$OPT{n}'. "
			   ."Please set -n value to 1, 2 or 3.\n"
				unless $OPT{'n'} =~ m{^[123]$}
		}
		elsif ( $OPT{'M'} )
		{
			die "Invalid email address `$OPT{M}'\n"
				unless Email::Address->parse( $OPT{M} );
		}
		else
		{
			die "You specified -m (send mails), but you didn't specify "
			   ."either -n or -M, so I don't knwo where to send my mails\n";
		}

	}

	if ( $OPT{'g'} and not $OPT{'m'} )
	{
		die "Option -g (debuG mail) without -m (use mail) "
		   ."really doesn't make much sense\n";
	}

	# include only files matching $filename
	my $file_pattern = $OPT{'p'} || $DEFAULT_PATTERN;

	my $translation = shift @ARGV || '';

	# language configuration
	if ( not $translation )
	{
		if ( exists $ENV{DWWW_LANG} )
		{
			$translation = $ENV{DWWW_LANG};
		}
		elsif ( -e "language.conf" )
		{
			open( my $conf, '<', 'language.conf' )
				or die("Can't read language.conf: $!\n");
			while (<$conf>)
			{
				next if /^#/;
				chomp;
				$translation = $_;
				last;
			}
			close $conf;
		}
	}

	# Remove slash from the end
	$translation =~ s{/$}{};

	if ( $translation eq '' )
	{
		die "Language not defined in DWWW_LANG, language.conf, "
		   ."or on command line\n";
	}

	return ($translation,$file_pattern,%OPT);
}

#=================================================
#== read the translators from translator.db
#==
sub read_translators
{
	my $lang = shift or die("Internal error: no language specified");

	my %translators;

	my $db_file = catfile( $lang, 'international', $lang, 'translator.db.pl' );

	verbose "Reading translation database $db_file";

	if ( -e $db_file)
	{
		require $db_file;

		verbose "READ TRANSLATOR DB: $db_file\n";

		%translators = %{ init_translators() };

		if ( exists $translators{default} )
		{
			my @field_list = keys %{ $translators{default} };
			foreach my $user (keys %translators)
			{
				next if $user eq 'default';
				foreach my $f (@field_list)
				{
					$translators{$user}{$f} = $translators{default}{$f}
						unless exists $translators{$user}{$f};
				}
			}
		}
	} 
	else
	{
		die "File `$db_file' doesn't exist!\n"
		   ."I need my DBs to send mails.\n"
		   ."Please read the comments in the script and try again\n";
	}

	return %translators;
}

#=================================================
#== check if a single file is up to date
#== returns ($status,$message)
#== where status is one of the ST_* constants (see top of file)
#==
sub check_file
{
	my $VCS             = shift;
	my $file            = shift;
	my $orig            = shift;
	my $lang            = shift;
	my $english_rev     = shift; # might be undef
	my $translation_rev = shift; # might be undef

	die("Internal error: insufficient arguments")
		unless $file and $orig and $lang;

	# filename of english and translated files
	my $file_orig        = catfile( $orig, $file );
	my $file_translation = catfile( $lang, $file );

	# revision of the latest change in the english file
	my $orig_last_change = $english_rev ? $english_rev->{cmt_rev} : 'n/a';

	# revision of the english file that was translated
    my $transcheck = Webwml::TransCheck->new( $file_translation );
	my $translation_last_change = $transcheck->revision()   || 'n/a';
	my $translation_translator  = $transcheck->maintainer() || undef;
	my $translation_maxdelta    = $transcheck->maxdelta()   || undef;

	verbose "Checking $file_translation, $orig revision $orig_last_change";

	# status information
	my $status = undef;
	my $str    = undef;

	# at this point, there are several possibilities:
	#   1) file exists both in english and translation
	#   2) file exists only in english
	#   3) file exists only in translation
	#   4) file exists in neither original or translation: can't happen
	# we handle those cases one by one

	# 1) both files exist
	if ( -e $file_orig and -e $file_translation )
	{
		# now check if both files have correct revisions
		# again, three cases
		# 1a) original file doesn't have a revision (can't happen)
		# 1b) translated file doesn't have a revision (error in wml file)
		# 1c) revision of both files is known

		# 1a) no revision for english file
		if ( $orig_last_change eq 'n/a' )
		{
			# this can't happen: something must be wrong with this script
			die( "internal error: no revision for english file" );
		}

		# 1b) no revision on translated file: error
		elsif ( $translation_last_change eq 'n/a' )
		{
			$status = ST_UNDEFINED;
			$str = "Unknown status of $file_translation "
			      ."(revision should be $orig_last_change)";
		}

		# 1c) both files have revisions
		else
		{
			# check the revisions to see if they're up to date
			my $cmp = $VCS->cmp_rev( $file_orig, $translation_last_change,
				$orig_last_change );

			if ( $cmp == 0 ) # revisions equal
			{
				# up to date
				$str = "UpToDate $file_translation";
				$status = ST_UPTODATE;
			}
			elsif ( $cmp == -1 ) # $translation_last_change < $orig_last_change
			{
				# out of date
				$status = ST_NEEDSUPDATE;
				$str = "NeedToUpdate $file_translation from revision "
				      ."$translation_last_change to revision $orig_last_change";
			}
			else # $translation_last_change > $orig_last_change
			{
				# weirdness: translation is newer than original
				$status = ST_BROKEN;
				$str = "Broken revision number r$translation_last_change "
				."for $file_translation, it should be $orig_last_change";
			}
		}
	}

	# 2) original file exists, but translation is missing
	elsif ( -e $file_orig and not -e $file_translation )
	{
		$status = ST_MISSING;
		$str = "Missing $file_translation version $orig_last_change";
	}

	# 3) translation exists, but original is missing
	elsif ( not -e $file_orig and -e $file_translation )
	{
		# the translated file doesn't have a translation header,
		# so it probably is an original
		if ( $translation_last_change eq 'n/a' )
		{
			$status = ST_NOTATRANSL;
			$str = "NotATranslation $file_translation";
		}
		# otherwise, it has a translation header,
		# so the english file was removed
		else
		{
			$status = ST_OBSOLETE;
			$str = "Obsolete $file_translation";
		}
	}

	# neither original nor translation exists
	else
	{
		# this should never occur, because it means the function was
		# called with an invalid argument
		die( "Internal error: file not present in english nor $lang" );
	}

	# add name of translator
	$str .= " (maintainer $translation_translator)" if $translation_translator;

	return ($status,$str,$translation_last_change,
	        $translation_translator,$translation_maxdelta);
}


# get the encoding of a certain file, by looking for wmlrc
sub get_file_charset
{
	my $file = shift or croak("No file specified");

	# default charset
	my $charset = 'utf-8';

	# read the wmlrc file
	my $wmlrc_dir = dirname($file);
	while ( not -e catfile( $wmlrc_dir, '.wmlrc' ) )
	{
		$wmlrc_dir = dirname $wmlrc_dir;
		last if  length( $wmlrc_dir ) < 3
	}

	# now read the wmlrc file to find the charset
	my $wmlrc = catfile( $wmlrc_dir,'.wmlrc' );
	if ( open( my $fd, '<', $wmlrc ) )
	{
		while ( my $line = <$fd> )
		{
			next if $line =~ m{^[#%]};
			next unless $line =~ m{CHARSET=(.*?)\s*$};
			$charset = $1;
			last;
		}
		close($fd);
	}
	else
	{
		verbose "wmlrc for `$file' not found; assuming $charset charset";
	}

	return $charset;
}

sub read_file_enc
{
    my $file = shift or croak("No file specified");

	my $charset = get_file_charset( $file );

	return read_file( $file, $charset );
}

__END__
