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
use Local::Cvsinfo;
use Webwml::TransCheck;
use Webwml::Langs;

our ($opt_h, $opt_v, $opt_n, $opt_p, @opt_l, @opt_s);

sub usage {
        print <<'EOT';
Usage: smart_change.pl [options] origfile [origfile ...]
Options:
  -h, --help         display this message
  -v, --verbose      run verbosely
  -n, --no-bump      do not bump translation-check headers
  -p, --previous     get previous CVS revision
  -l, --lang=STRING  process this language (may be used more than once)
  -s, --substitute=REGEXP
                     Perl regexp applied to source files
                     (may be used more than once)
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

#   We call constructor without argument.  It means there must be a
#   CVS/Repository file or program will abort.
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
        my ($path, $file) = ($1, $2);

        verbose("File: $argfile");
        my $cvs = Local::Cvsinfo->new();
        $cvs->options(matchfile => [ $file ]);
        $cvs->readinfo($path);
        my $origrev = $cvs->revision($argfile) || "1.0";
        if ($opt_p) {
                $origrev =~ s/(\d+)$/($1 - 1)/e;
        }
        verbose("Original revision: $origrev");

        my $nextrev = $origrev;
        $nextrev =~ s/(\d+)$/(1+$1)/e;
        verbose("Next revision: $nextrev");

        foreach my $lang (@opt_l) {
                my $transfile = $argfile;
                $transfile =~ s/^english/$lang/ || next;
                next unless -f $transfile;
                verbose("Now checking $transfile");

                # Parse the translated file
                my $transcheck = Webwml::TransCheck->new($transfile);
                next unless $transcheck->revision() || $lang eq 'english';
                my $langrev = $transcheck->revision();

                my $origtext = '';
                my $transtext = '';
                open (TRANS, "< $transfile");
                while (<TRANS>) {
                        $origtext .= $_;
                        if (m/^#use wml::debian::translation-check/ && !$opt_n &&
                            ($langrev eq $origrev || $langrev eq $nextrev)) {
                                #   Also check for $nextrev in case this script
                                #   is run several times
                                s/(translation="?)($origrev|$nextrev)("?)/$1$nextrev$3/;
                                verbose("Bump version number to $nextrev");
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
