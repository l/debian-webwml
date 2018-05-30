#!/usr/bin/perl -w

# Quick test harness for the VCS helper modules

use strict;
use Getopt::Long;
use Data::Dumper;
use Digest::MD5 'md5_hex';

# These modules reside under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
use Local::Cvsinfo;
use Local::VCS;
use Webwml::TransCheck;
use Webwml::Langs;

my $file = "english/CD/faq/index.wml";
my $rev1;
my $rev2;
my $rev3;
my $rev4;
if (-d "CVS") { 
    # Known working revs
    $rev1 = "1.138";
    $rev2 = "1.137";
    $rev3 = "1.136";
    # And one that doesn't exist
    $rev4 = "2.57768";
} else {
    # Known working revs
    $rev1 = "da8b98a6a6cb82188f7b0fd6204d083ad292dea4";
    $rev2 = "4d758459f82173693d9a754fe57b2680b415da3c";
    $rev3 = "f759936a7330f7e7309322658381d1277e6c922c";
    # And one that doesn't exist
    $rev4 = "5653875687436536574367564356874365783465";
}    
my $ret;

my $VCS = Local::VCS->new();
print "Initialising VCS cache for performance\n";
$VCS->cache_file($file);
$VCS->cache_file($file);
$VCS->cache_repo();
$VCS->cache_repo();
print " ... done!\n";

########
# Startup check - we depend on there being a change in $file above,
# for diff outputs to actually show something. Check if diff shows
# anything, and abort if not.
my %test_diff = $VCS->get_diff($file);
if (!$test_diff{$file}) {
    print "Need a diff to work with. Run the following and try again:\n";
    print "\n";
    print "echo foo >> $file\n";
    print "\n";
    die "ABORT\n";
}

########
# main
#
# Quickly check all the functionality we know about:
#  $VCS->cmp_rev
#  $VCS->count_changes
#  $VCS->path_info
#  $VCS->file_info
#  $VCS->get_log
#  $VCS->get_diff
#  $VCS->get_file
#  $VCS->get_oldest_revision 
#  $VCS->get_topdir 
##########################################################

##########################################################
print "#############################\n";
print "VCS->cmp_rev:::\n";
$ret = $VCS->cmp_rev($file, , ,);
if (!defined $ret) {
    $ret = "<undef>";
}
print "1. (no revs specified) returned $ret\n";
$ret = $VCS->cmp_rev("english/CD/faq/index.wml", $rev1, $rev1);
if (!defined $ret) {
    $ret = "<undef>";
}
print "2. (equal revs) returned $ret\n";
$ret = $VCS->cmp_rev("english/CD/faq/index.wml", $rev1, $rev2);
if (!defined $ret) {
    $ret = "<undef>";
}
print "3. (new, old) returned $ret\n";
$ret = $VCS->cmp_rev("english/CD/faq/index.wml", $rev2, $rev1);
if (!defined $ret) {
    $ret = "<undef>";
}
print "4. (old, new) returned $ret\n";

##########################################################
print "#############################\n";
print "VCS->count_changes:::\n";
$ret = $VCS->count_changes("english/CD/faq/index.wml", , ,);
if (!defined $ret) {
    $ret = "<undef>";
}
print "1. (no revs specified) returned $ret\n";
$ret = $VCS->count_changes("english/CD/faq/index.wml", $rev1, $rev1);
if (!defined $ret) {
    $ret = "<undef>";
}
print "2. (equal revs) returned $ret\n";
$ret = $VCS->count_changes("english/CD/faq/index.wml", $rev1, $rev2);
if (!defined $ret) {
    $ret = "<undef>";
}
print "3. (new, old) returned $ret\n";
$ret = $VCS->count_changes("english/CD/faq/index.wml", $rev2, $rev1);
if (!defined $ret) {
    $ret = "<undef>";
}
print "4. (old, new) returned $ret\n";

##########################################################
my $srcdir = "english/MailingLists/desc";
print "#############################\n";
print "VCS->path_info on $srcdir :::\n";
my %revision_info = $VCS->path_info($srcdir, 'recursive' => 1);
my $i = 0;
foreach my $file (keys %revision_info) {
    print "$i: file $file:\n";
    print "    type: $revision_info{$file}{'type'}\n";
    print "    cmt_date: $revision_info{$file}{'cmt_date'}\n";
    print "    cmt_rev: $revision_info{$file}{'cmt_rev'}\n";
    $i++;
    if ($i > 2) {
	last;
    }
}
%revision_info = $VCS->path_info($srcdir, 'recursive' => 0);
$i = 0;
foreach my $file (keys %revision_info) {
    print "$i: file $file:\n";
    print "    type: $revision_info{$file}{'type'}\n";
    print "    cmt_date: $revision_info{$file}{'cmt_date'}\n";
    print "    cmt_rev: $revision_info{$file}{'cmt_rev'}\n";
    $i++;
    if ($i > 2) {
	last;
    }
}

##########################################################
print "#############################\n";
print "VCS->file_info on $file :::\n";
%revision_info = $VCS->file_info($file);
print "file $file:\n";
print "    type: $revision_info{'type'}\n";
print "    cmt_date: $revision_info{'cmt_date'}\n";
print "    cmt_rev: $revision_info{'cmt_rev'}\n";

sub print_log_info {
    my $file = shift;
    my $counter = shift;
    my $info = shift;
    my %tmp = %$info;
    print "$counter: file $file:\n";
    print "    rev: $tmp{'rev'}\n";
    print "    date: $tmp{'date'}\n";
    print "    author: $tmp{'author'}\n";
    print "    message: $tmp{'message'}\n";
}

##########################################################
print "#############################\n";
print "VCS->get_log on $file :::\n";
my @log_info;
my $num_logs;
print "1. full range of VCS->get_log on file $file :::\n";
@log_info = $VCS->get_log($file);
if (@log_info and defined($log_info[0])) {
    $num_logs = scalar(@log_info);
    print "   returns $num_logs log entries\n";
    $i = 0;
    foreach my $log (@log_info) {
	print_log_info($file, $i, $log);
	$i++;
	if ($i > 4) {
	    last;
	}
    }
} else {
    print "   returns no data\n";
}
print "2. single rev of VCS->get_log on $file :::\n";
@log_info = $VCS->get_log($file, $rev1);
if (@log_info and defined($log_info[0])) {
    $num_logs = scalar(@log_info);
    print "   returns $num_logs log entries\n";
    $i = 0;
    foreach my $log (@log_info) {
	print_log_info($file, $i, $log);
	$i++;
	if ($i > 4) {
	    last;
	}
    }
} else {
    print "   returns no data\n";
}
print "3. single rev of VCS->get_log on $file :::\n";
@log_info = $VCS->get_log($file, , $rev1);
if (@log_info and defined($log_info[0])) {
    $num_logs = scalar(@log_info);
    print "   returns $num_logs log entries\n";
    $i = 0;
    foreach my $log (@log_info) {
	print_log_info($file, $i, $log);
	$i++;
	if ($i > 4) {
	    last;
	}
    }
} else {
    print "   returns no data\n";
}
print "4. two revs of VCS->get_log on $file :::\n";
@log_info = $VCS->get_log($file, $rev3,$rev1);
if (@log_info and defined($log_info[0])) {
    $num_logs = scalar(@log_info);
    print "   returns $num_logs log entries\n";
    $i = 0;
    foreach my $log (@log_info) {
	print_log_info($file, $i, $log);
	$i++;
	if ($i > 4) {
	    last;
	}
    }
} else {
    print "   returns no data\n";
}
print "5. two revs reversed of VCS->get_log on $file :::\n";
@log_info = $VCS->get_log($file, $rev1,$rev3);
if (@log_info and defined($log_info[0])) {
    $num_logs = scalar(@log_info);
    print "   returns $num_logs log entries\n";
    $i = 0;
    foreach my $log (@log_info) {
	print_log_info($file, $i, $log);
	$i++;
	if ($i > 4) {
	    last;
	}
    }
} else {
    print "   returns no data\n";
}
@log_info = $VCS->get_log($file, $rev1,$rev3);
print "6. two revs if VCS->get_log on file, one non-existent on $file :::\n";
if (@log_info and defined($log_info[0])) {
    $num_logs = scalar(@log_info);
    print "   returns $num_logs log entries\n";
    $i = 0;
    foreach my $log (@log_info) {
	print_log_info($file, $i, $log);
	$i++;
	if ($i > 4) {
	    last;
	}
    }
} else {
    print "   returns no data\n";
}

##########################################################
print "#############################\n";
print "VCS->get_diff on $file :::\n";
my %diffs = $VCS->get_diff($file, $rev2, $rev1);
print "1. diff with two revs on $file:\n";
print "file: $file\n";
print "$diffs{$file}\n";
%diffs = $VCS->get_diff($file, $rev2);
print "2. diff with one older rev on $file:\n";
print "file: $file\n";
print "$diffs{$file}\n";
%diffs = $VCS->get_diff($file);
print "3. diff with no revs on $file:\n";
print "file: $file\n";
print "$diffs{$file}\n";

##########################################################
print "#############################\n";
print "VCS->get_file on $file :::\n";
$ret = $VCS->get_file($file, $rev2);
print "first 120 chars:\n";
print "#############################\n";
print substr $ret, 0, 120;
print "\n";
print "#############################\n";
my $digest = md5_hex($ret);
print "md5 = $digest\n";
if ($digest !~ /^\Q11cbcdde3c0121caaed105435adbf902\E$/) {
    print "FAIL: didn't get the expected checksum\n";
}

##########################################################
print "#############################\n";
print "VCS->get_oldest_revision on $file :::\n";
$ret = $VCS->get_oldest_revision($file);
print "Got \"$ret\"\n";

##########################################################
print "#############################\n";
print "VCS->next_revision (-1) on $file :::\n";
$ret = $VCS->next_revision($file, $rev1, -1);
print "Got \"$ret\", expecting \"$rev2\"\n";
if ($ret !~ m/$rev2/) {
    print "   FAIL\n";
}
print "VCS->next_revision (1) on $file :::\n";
$ret = $VCS->next_revision($file, $rev2, 1);
print "Got \"$ret\", expecting \"$rev1\"\n";
if ($ret !~ m/$rev1/) {
    print "   FAIL\n";
}

##########################################################
print "#############################\n";
print "VCS->get_topdir in topdir:::\n";
$ret = $VCS->get_topdir();
print "topdir is $ret\n";

chdir("english");
print "VCS->get_topdir in english:::\n";
$ret = $VCS->get_topdir();
print "topdir is $ret\n";

chdir("CD");
print "VCS->get_topdir in english/CD:::\n";
$ret = $VCS->get_topdir();
print "topdir is $ret\n";
