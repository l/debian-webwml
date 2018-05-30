#!/usr/bin/perl -w

# This script perform changes in WML source files and bump version
# number when translated files are up to date.

# Known Issues:
# when there is no change to the origfile the translation="" revision is
# updated for current translations nevertheless

use strict;
use Getopt::Long;

#    These modules reside under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
use Local::VCS;
use Webwml::TransCheck;
use Webwml::Langs;

our ($opt_h, $opt_v, $opt_n, @opt_l, @opt_s);

sub usage {
        print <<'EOT';
Usage: smart_change.pl [options] origfile [origfile ...]
Options:
  -h, --help         display this message
  -v, --verbose      run verbosely
  -n, --no-bump      do not bump translation-check headers
  -l, --lang=STRING  process this language (may be used more than once)
  -s, --substitute=REGEXP
                     Perl regexp applied to source files
                     (may be used more than once)

This is a *NEW* implementation of smart_change.pl which is limited to
supporting git commit hashes. To use this:

 1. Make the changes to the original file(s), and commit
 2. Update translations
 3. Run smart_change.pl - it will pick up the changes and update
    headers in the translation files
 4. Commit the translation changes

This is more involved than previously (needing two commits), but
unavoidable...

EOT
        exit(0);
}

if (not Getopt::Long::GetOptions(qw(
                h|help
                v|verbose
                n|no-bump
                p|previous
                l|lang=s@
                s|substitute=s@
))) {
        warn "Try `$0 --help' for more information.\n";
        exit(1);
}

$opt_h && usage;
die "Invalid number of arguments\n" unless @ARGV;

sub verbose {
        print STDERR $_[0] . "\n" if $opt_v;
}

#   We call constructor without argument.
if (not @opt_l) {
        my $l = Webwml::Langs->new();
        @opt_l = $l->names();
}

my $eval_opt_s = '1';
foreach (@opt_s) {
        $eval_opt_s .= "; $_";
}
verbose("-s flags: $eval_opt_s");

my $substitute = eval "sub { \$_ = shift; $eval_opt_s; die \$@ if \$@; return \$_}";
die "Invalid -s option" if $@;

foreach my $argfile (@ARGV) {
        $argfile =~ m+^(english.*)/(.*\.(wml|src))+ or die "unknown path '$argfile'";

        verbose("File: $argfile");
        my $VCS = Local::VCS->new();
	my %file_info = $VCS->file_info($argfile);
        my $origrev = $file_info{'cmt_rev'} or die "Can't find revision information for original file $argfile\n";
        verbose("Original revision: $origrev");

        my $prevrev = $VCS->next_revision($argfile, $origrev, -1);
        verbose("Previous revision: $prevrev");

        foreach my $lang (@opt_l) {
                my $transfile = $argfile;
                $transfile =~ s/^english/$lang/ || next;
                next unless -f $transfile;
                verbose("Now checking $transfile");

                # Parse the translated file
                my $transcheck = Webwml::TransCheck->new($transfile);
                next unless $transcheck->revision() || $lang eq 'english';
                my $langrev = $transcheck->revision();

		if (defined $langrev and $langrev =~ m/^$origrev$/) {
		    print "  $transfile already claims to be a translation for $argfile rev $origrev\n";
		}

                my $origtext = '';
                my $transtext = '';
                open (TRANS, "< $transfile");
                while (<TRANS>) {
                        $origtext .= $_;
                        if (m/^#use wml::debian::translation-check/ && !$opt_n &&
                            ($langrev eq $prevrev)) {
                                s/(translation="?)($prevrev)("?)/$1$origrev$3/;
                                verbose("Bump version number to $origrev");
                        }
                        $transtext .= $_;
                }
                close (TRANS);
                $transtext = &$substitute($transtext);
                if ($origtext ne $transtext) {
                        verbose("Writing $transfile");
                        open (TRANS, "> $transfile");
                        print TRANS $transtext;
                        close (TRANS);
                }
        }
}
