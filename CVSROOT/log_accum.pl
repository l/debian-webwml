#!/usr/bin/perl
# -*-Perl-*-
##
#
# This script, taken from the OpenBSD CVS repository.
# Modified to close Debian bugs fixed by the commits.
#
# Perl filter to handle the log messages from the checkin of files in
# a directory.  This script will group the lists of files by log
# message, and mail a single consolidated log message at the end of
# the commit.
#
# This file assumes a pre-commit checking program that leaves the
# names of the first and last commit directories in a temporary file.
#
# Contributed by David Hampton <hampton@cisco.com>
#
# hacked greatly by Greg A. Woods <woods@web.net>

# Usage: log_accum.pl [-d] [-s] [-M module] [[-m mailto] ...] [-f logfile]
#	-d		- turn on debugging
#	-m mailto	- send mail to "mailto" (multiple)
#	-M modulename	- set module name to "modulename"
#	-f logfile	- write commit messages to logfile too
#	-s		- *don't* run "cvs status -v" for each file

#
#	Configurable options
#

$MAILER	       = "/usr/sbin/sendmail";

# Constants (don't change these!)
#
$STATE_NONE    = 0;
$STATE_CHANGED = 1;
$STATE_ADDED   = 2;
$STATE_REMOVED = 3;
$STATE_LOG     = 4;

$TMP_DIR       = "/cvs/webwml/CVSROOT/tmp";
$LAST_FILE     = "$TMP_DIR/#cvs.lastdir";

$CHANGED_FILE  = "$TMP_DIR/#cvs.files.changed";
$ADDED_FILE    = "$TMP_DIR/#cvs.files.added";
$REMOVED_FILE  = "$TMP_DIR/#cvs.files.removed";
$LOG_FILE      = "$TMP_DIR/#cvs.files.log";

#
#	Subroutines
#

sub cleanup_tmpfiles {
    local @files;

    chdir("$TMP_DIR") || die("Can't chdir('$TMP_DIR')\n");
    opendir(DIR, ".");
    for my $file (readdir(DIR)) {
	if (/^(#cvs\.files\.[[:alpha:]]+\.\d+\.$id)\$/) {
	    unlink $1;
	}
    }
    closedir(DIR);
    unlink $LAST_FILE . "." . $id;
}

sub write_logfile {
    local($filename, @lines) = @_;

    open(FILE, ">$filename") || die("Cannot open log file $filename.\n");
    print FILE join("\n", @lines), "\n";
    close(FILE);
}

sub format_names {
    local($dir, @files) = @_;
    local(@lines);

    if ($dir =~ /^\.\//) {
	$dir = $';
    }
    if ($dir =~ /\/$/) {
	$dir = $`;
    }
    if ($dir eq "") {
	$dir = ".";
    }

    $format = "\t%-" . sprintf("%d", length($dir) > 15 ? length($dir) : 15) . "s%s ";

    $lines[0] = sprintf($format, $dir, ":");

    if ($debug) {
	print STDERR "format_names(): dir = ", $dir, "; files = ", join(":", @files), ".\n";
    }
    foreach $file (@files) {
	if (length($lines[$#lines]) + length($file) > 65) {
	    $lines[++$#lines] = sprintf($format, " ", " ");
	}
	$lines[$#lines] .= $file . " ";
    }

    @lines;
}

sub format_lists {
    local(@lines) = @_;
    local(@text, @files, $lastdir);

    if ($debug) {
	print STDERR "format_lists(): ", join(":", @lines), "\n";
    }
    @text = ();
    @files = ();
    $lastdir = shift @lines;	# first thing is always a directory
    if ($lastdir !~ /.*\/$/) {
	die("Damn, $lastdir doesn't look like a directory!\n");
    }
    foreach $line (@lines) {
	if ($line =~ /.*\/$/) {
	    push(@text, &format_names($lastdir, @files));
	    $lastdir = $line;
	    @files = ();
	} else {
	    push(@files, $line);
	}
    }
    push(@text, &format_names($lastdir, @files));

    @text;
}

sub accum_subject {
    local(@lines) = @_;
    local(@files, $lastdir);

    $lastdir = shift @lines;	# first thing is always a directory
    @files = ($lastdir);
    if ($lastdir !~ /.*\/$/) {
	die("Damn, $lastdir doesn't look like a directory!\n");
    }
    foreach $line (@lines) {
	if ($line =~ /.*\/$/) {
	    $lastdir = $line;
	    push(@files, $line);
	} else {
	    push(@files, $lastdir . $line);
	}
    }

    @files;
}

sub compile_subject {
    local(@files) = @_;
    local($text, @a, @b, @c, $dir, $topdir, $topsuffix);

    # find the highest common directory
    $dir = '-';
    do {
	$topdir = $dir;
	foreach $file (@files) {
	    if ($file =~ /.*\/$/) {
		if ($dir eq '-') {
		    $dir = $file;
		} else {
		    if (index($dir,$file) == 0) {
			$dir = $file;
		    } elsif (index($file,$dir) != 0) {
			@a = split /\//,$file;
			@b = split /\//,$dir;
			@c = ();
			CMP: while ($#a > 0 && $#b > 0) {
			    if ($a[0] eq $b[0]) {
				push(@c, $a[0]);
				shift @a;
				shift @b;
			    } else {
				last CMP;
			    }
			}
			$dir = join('/',@c) . '/';
		    }
		}
	    }
	}
    } until $dir eq $topdir;

    # strip out directories and the common prefix topdir.
    chop $topdir;
    $topsuffix = length($topdir) ? ('/' . $topdir) : '';
    @c = ($modulename . $topsuffix);
    foreach $file (@files) {
	if (!($file =~ /.*\/$/)) {
	    push(@c, substr($file, length($topsuffix)));
	}
    }

    # put it together and limit the length.
    $text = join(' ',@c);
    if (length($text) > 50) {
	$text = substr($text, 0, 46) . ' ...';
    }

    $text;
}

sub append_names_to_file {
    local($filename, $dir, @files) = @_;

    if (@files) {
	open(FILE, ">>$filename") || die("Cannot open file $filename.\n");
	print FILE $dir, "\n";
	print FILE join("\n", @files), "\n";
	close(FILE);
    }
}

sub read_line {
    local($line);
    local($filename) = @_;

    open(FILE, "<$filename") || die("Cannot open file $filename.\n");
    $line = <FILE>;
    close(FILE);
    chop($line);
    $line;
}

sub read_logfile {
    local(@text);
    local($filename, $leader) = @_;

    open(FILE, "<$filename");
    while (<FILE>) {
	chop;
	push(@text, $leader.$_);
    }
    close(FILE);
    @text;
}

sub build_header {
    local($header);
    local($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    $header = sprintf("CVSROOT:\t%s\nModule name:\t%s\n",
		      $cvsroot,
		      $modulename);
    if (defined($branch)) {
	$header .= sprintf("Branch: \t%s\n",
		      $branch);
    }
    $header .= sprintf("Changes by:\t%s\t%02d/%02d/%02d %02d:%02d:%02d",
		      $login,
		      $year%100, $mon+1, $mday,
		      $hour, $min, $sec);
}

sub mail_notification {
    local($name, $subject, @text) = @_;
    open MAIL, "| $MAILER -t";
# the Approved header seems to be necessary to post to -www-cvs
    print MAIL <<EOF ;
Approved: webmaster\@debian.org
From: Debian WWW CVS <webmaster\@debian.org>
To: $name
Subject: Debian WWW CVS commit by $login: $subject
Mail-Followup-To: debian-www\@lists.debian.org
Mail-Copies-To: never

EOF
    print MAIL join("\n", @text), "\n";
    close MAIL;
    if ($debug) {
	print STDERR "mail_notification(): name = ", $name, "; subject = ", $subject, ".\n";
    }
}

sub close_bugs {
	local(@text) = @_;
	my @bug_numbers;
	my $log = join("\n", @text);
	my $log_copy = $log;
	while( $log_copy =~ s/(closes:\s*(?:bug)?\#\s*\d+(?:,\s*(?:bug)?\#\s*\d+)*)//is )
	{
		my $match = $1;
		push @bug_numbers, $1 while $match =~ s/#(\d+)//;
	}
	return unless scalar @bug_numbers;

	my @bugs;
	my @done;
	foreach $bug (@bug_numbers) {
		push @bugs, "#$bug";
		push @done, "$bug-done\@bugs.debian.org";
	}
	my $bugs = join(", ", @bugs);
	my $done = join(", ", @done);

	open MAIL, "| $MAILER -t";
	print MAIL <<EOF ;
From: Debian WWW CVS <webmaster\@debian.org>
To: $done
Subject: Debian WWW CVS commit by $login fixes $bugs
Reply-To: debian-www\@lists.debian.org
Mail-Followup-To: debian-www\@lists.debian.org
Mail-Copies-To: never

This bug was closed by $login in the webwml CVS repository:

http://www.debian.org/devel/website/using_cvs

Note that it might take some time until www.debian.org has been updated.

Commit message:

$log
EOF
	close MAIL;
	if ($debug) {
		print STDERR "close_bugs(): login = ", $login, "; bugs = ", $bugs, ".\n";
	}
}

sub write_commitlog {
    local($logfile, @text) = @_;

    open(FILE, ">>$logfile");
    print FILE join("\n", @text), "\n\n";
    close(FILE);
}

#
#	Main Body
#

# Initialize basic variables
#
$debug = 0;
$id = getpgrp();	# note, you *must* use a shell which does setpgrp()
$state = $STATE_NONE;

$login = $ENV{'CVS_USER'} || getlogin || (getpwuid($<))[0] || "nobody";
#$login = $ENV{'LOGNAME'} || getlogin || (getpwuid($<))[0] || "nobody";

$cvsroot = $ENV{'CVSROOT'};
$do_status = 1;
$modulename = "";

# parse command line arguments (file list is seen as one arg)
#
@files = ();
while (@ARGV) {
    $arg = shift @ARGV;

    if ($arg eq '-d') {
	$debug = 1;
	print STDERR "Debug turned on...\n";
    } elsif ($arg eq '-m') {
	$mailto = "$mailto " . shift @ARGV;
    } elsif ($arg eq '-M') {
	$modulename = shift @ARGV;
    } elsif ($arg eq '-s') {
	$do_status = 0;
    } elsif ($arg eq '-f') {
	($commitlog) && die("Too many '-f' args\n");
	$commitlog = shift @ARGV;
    } else {
	push(@files, $arg);
    }
}
($mailto) || die("No -m mail recipient specified\n");

$ENV{PATH} = '/usr/bin:/bin';

# for now, the first "file" is the repository directory being committed,
# relative to the $CVSROOT location
#
@path = split('/', $files[0]);

# XXX there are some ugly assumptions in here about module names and
# XXX directories relative to the $CVSROOT location -- really should
# XXX read $CVSROOT/CVSROOT/modules, but that's not so easy to do, since
# XXX we have to parse it backwards.
#
if ($modulename eq "") {
    $modulename = $path[0];	# I.e. the module name == top-level dir
}
if ($commitlog ne "") {
    $commitlog = $cvsroot . "/" . $modulename . "/" . $commitlog unless ($commitlog =~ /^\//);
}
if ($#path == 0) {
    $dir = ".";
} else {
    $dir = join('/', @path[1..$#path]);
}
$dir = $dir . "/";

if ($debug) {
    print STDERR "module - ", $modulename, "\n";
    print STDERR "dir    - ", $dir, "\n";
    print STDERR "path   - ", join(":", @path), "\n";
    print STDERR "files  - ", join(":", @files), "\n";
    print STDERR "id     - ", $id, "\n";
    print STDERR "login  - ", $login, "\n";
    print STDERR "CVS_USER - ", $ENV{'CVS_USER'}, "\n";
}

# Check for a new directory first.  This appears with files set as follows:
#
#    files[0] - "path/name/newdir"
#    files[1] - "- New directory"
#
if ($files[1] eq "- New directory") {
    local(@text);

    @text = ();
    push(@text, &build_header());
    push(@text, "");
    push(@text, $files[0]);
    push(@text, "");

    while (<STDIN>) {
	chop;			# Drop the newline
	push(@text, $_);
    }

    &mail_notification($mailto, $files[0], @text);
    &close_bugs(@text);

    if ($commitlog) {
	&write_commitlog($commitlog, @text);
    }

    exit 0;
}

# Iterate over the body of the message collecting information.
#
while (<STDIN>) {
    chop;			# Drop the newline

    if (/^Modified Files/) { $state = $STATE_CHANGED; next; }
    if (/^Added Files/)    { $state = $STATE_ADDED;   next; }
    if (/^Removed Files/)  { $state = $STATE_REMOVED; next; }
    if (/^Log Message/)    { $state = $STATE_LOG;     next; }
    if (/^Revision\/Branch/) { /^[^:]+:\s*(.*)/; $branch = $+; next; }

    s/^[ \t\n]+// if ($state != $STATE_LOG);		# delete leading whitespace
    s/[ \t\n]+$//;		# delete trailing whitespace
    
    if ($state == $STATE_CHANGED) { push(@changed_files, split); }
    if ($state == $STATE_ADDED)   { push(@added_files,   split); }
    if ($state == $STATE_REMOVED) { push(@removed_files, split); }
    if ($state == $STATE_LOG)     { push(@log_lines,     $_); }
}

# Strip leading and trailing blank lines from the log message.  Also
# compress multiple blank lines in the body of the message down to a
# single blank line.
#
while ($#log_lines > -1) {
    last if ($log_lines[0] ne "");
    shift(@log_lines);
}
while ($#log_lines > -1) {
    last if ($log_lines[$#log_lines] ne "");
    pop(@log_lines);
}
for ($i = $#log_lines; $i > 0; $i--) {
    if (($log_lines[$i - 1] eq "") && ($log_lines[$i] eq "")) {
	splice(@log_lines, $i, 1);
    }
}

# Check for an import command.  This appears with files set as follows:
#
#    files[0] - "path/name"
#    files[1] - "- Imported sources"
#
if ($files[1] eq "- Imported sources") {
    local(@text);

    @text = ();
    push(@text, &build_header());
    push(@text, "");

    push(@text, "Log message:");
    while ($#log_lines > -1) {
	push (@text, "    " . $log_lines[0]);
	shift(@log_lines);
    }

    &mail_notification($mailto, "Import $file[0]", @text);
    &close_bugs(@text);

    if ($commitlog) {
	&write_commitlog($commitlog, @text);
    }

    exit 0;
}

if ($debug) {
    print STDERR "Searching for log file index...";
}
# Find an index to a log file that matches this log message
#
for ($i = 0; ; $i++) {
    local(@text);

    last if (! -e "$LOG_FILE.$i.$id"); # the next available one
    @text = &read_logfile("$LOG_FILE.$i.$id", "");
    last if ($#text == -1);	# nothing in this file, use it
    last if (join(" ", @log_lines) eq join(" ", @text)); # it's the same log message as another
}
if ($debug) {
    print STDERR " found log file at $i.$id, now writing tmp files.\n";
}

# Spit out the information gathered in this pass.
#
&append_names_to_file("$CHANGED_FILE.$i.$id", $dir, @changed_files);
&append_names_to_file("$ADDED_FILE.$i.$id",   $dir, @added_files);
&append_names_to_file("$REMOVED_FILE.$i.$id", $dir, @removed_files);
&write_logfile("$LOG_FILE.$i.$id", @log_lines);

#
#	End Of Commits!
#

# This is it.  The commits are all finished.  Lump everything together
# into a single message, fire a copy off to the mailing list, and drop
# it on the end of the Changes file.
#

#
# Produce the final compilation of the log messages
#
@text = ();
@status_txt = ();
@subject_files = ();
push(@text, &build_header());
push(@text, "");

for ($i = 0; ; $i++) {
    last if (! -e "$LOG_FILE.$i.$id"); # we're done them all!
    @lines = &read_logfile("$CHANGED_FILE.$i.$id", "");
    if ($#lines >= 0) {
	push(@text, "Modified files:");
	push(@text, &format_lists(@lines));
	push(@subject_files, &accum_subject(@lines));
    }
    @lines = &read_logfile("$ADDED_FILE.$i.$id", "");
    if ($#lines >= 0) {
	push(@text, "Added files:");
	push(@text, &format_lists(@lines));
	push(@subject_files, &accum_subject(@lines));
    }
    @lines = &read_logfile("$REMOVED_FILE.$i.$id", "");
    if ($#lines >= 0) {
	push(@text, "Removed files:");
	push(@text, &format_lists(@lines));
	push(@subject_files, &accum_subject(@lines));
    }
    if ($#text >= 0) {
	push(@text, "");
    }
    @lines = &read_logfile("$LOG_FILE.$i.$id", "\t");
    if ($#lines >= 0) {
	push(@text, "Log message:");
	push(@text, @lines);
	push(@text, "");
    }
    if ($do_status) {
	local(@changed_files);

	@changed_files = ();
	push(@changed_files, &read_logfile("$CHANGED_FILE.$i.$id", ""));
	push(@changed_files, &read_logfile("$ADDED_FILE.$i.$id", ""));
	push(@changed_files, &read_logfile("$REMOVED_FILE.$i.$id", ""));

	if ($debug) {
	    print STDERR "main: pre-sort changed_files = ", join(":", @changed_files), ".\n";
	}
	@changed_files = sort(@changed_files);
	if ($debug) {
	    print STDERR "main: post-sort changed_files = ", join(":", @changed_files), ".\n";
	}

	foreach $dofile (@changed_files) {
	    if ($dofile =~ /\/$/) {
		next;		# ignore the silly "dir" entries
	    }
	    if ($debug) {
		print STDERR "main(): doing status on $dofile\n";
	    }
	    open(STATUS, "-|") || exec 'cvs', '-n', 'status', '-v', $dofile;
	    while (<STATUS>) {
		chop;
		push(@status_txt, $_);
	    }
	}
    }
}

$subject_txt = &compile_subject(@subject_files);

# Write to the commitlog file
#
if ($commitlog) {
    &write_commitlog($commitlog, @text);
}

if ($#status_txt >= 0) {
    push(@text, @status_txt);
}

# Mailout the notification.
#
&mail_notification($mailto, $subject_txt, @text);
&close_bugs(@text);

# cleanup
#
if (! $debug) {
    &cleanup_tmpfiles();
}

exit 0;
