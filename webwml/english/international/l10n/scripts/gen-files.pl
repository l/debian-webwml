#! /usr/bin/perl -w

use strict;
use File::Path;
use Getopt::Long;

use lib ($0 =~ m|(.*)/|, $1 or ".") ."/../../../../Perl";

use Webwml::L10n::Db;

use vars qw($opt_h $opt_l $opt_P $opt_T $opt_L);

sub usage {
        print "Usage:  gen-files.pl [--l10ndir=DIR] [--po] [--templates] [--langs]\n";
        exit($_[0]);
}

$opt_h = $opt_P = $opt_T = $opt_L = 0;
$opt_l = '.';

if (not Getopt::Long::GetOptions(qw(
        h|help
        l|l10ndir=s
        P|po
        T|templates
        L|langs
        ))) {
        usage(1);
}
usage(0) if $opt_h;

my $data = Webwml::L10n::Db->new();
$data->read("$opt_l/data/unstable.ftp-master");
$data->read("$opt_l/data/unstable.non-US");

my $root = 'http://ftp-master.debian.org/~barbier/l10n/material/';
my $rootnonus = 'http://nonus.debian.org/~barbier/l10n/material/';

my $langfile = $opt_l.'/data/langs';

my @langs = ();
open(LANGS, "< $langfile") || die "Unable to read $langfile";
while (<LANGS>) {
        if (s/^po:\s+//) {
                @langs = split(' ', $_);
                last;
        }
}
close(LANGS);
die "No langs found in $langfile" unless @langs;

my @main    = ();
my @contrib = ();
my @nonfree = ();

foreach my $pkg ($data->list_packages()) {
        #   Populate arrays
        my $section = $data->section($pkg);
        if ($section =~ m#^(non-us/)?contrib/#) {
                push (@contrib, $pkg);
        } elsif ($section =~ m#^(non-us/)?non-free/#) {
                push (@nonfree, $pkg);
        } else {
                push (@main, $pkg);
        }
}

sub get_stats_po {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, %list);

        my %incl = ();
        my %excl = ();
        my $none = '';
        foreach $pkg (sort @{$packages}) {
                if ($data->upstream($pkg) eq 'dbs') {
                        $none .= "<li>".$pkg." (*)\n";
                        next;
                }
                unless ($data->has_po($pkg)) {
                        $none .= "<li>".$pkg."\n";
                        next;
                }
                my $list = {};
                foreach (@langs) {
                        $list{uc $_} = 0;
                }
                foreach $line (@{$data->po($pkg)}) {
                        my ($pofile, $lang, $stat, $link) = @{$line};
                        $link =~ s/:/\%3a/g;
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
                        $incl{$lang}  = '' unless defined($incl{$lang});
                        $incl{$lang} .= "<tr bgcolor=\"".
                              get_color(percent_stat($stat)).
                              "\"><td>".$pkg."</td>".
                              "<td>".percent_stat($stat).
                              " (".show_stat($stat).")</td><td><a href=\"";
                        $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "po/unstable/";
                        $incl{$lang} .= $data->pooldir($pkg)."/$link.gz\">$pofile</a></td>".
                              "</tr>\n";
                }
                foreach $lang (@langs) {
                        my $l = uc($lang);
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= $pkg.", ";
                }
        }
        foreach $lang (@langs) {
                next unless defined $incl{uc $lang};
                open (GEN, "> $opt_l/po/gen/$section-$lang.inc")
                        || die "Unable to write $section-$lang.inc";
                print GEN $incl{uc $lang};
                close (GEN);
        }
        foreach $lang (@langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> $opt_l/po/gen/$section-$lang.exc")
                        || die "Unable to write $section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."\n";
                close (GEN);
        }
        open (GEN, "> $opt_l/po/gen/$section.exc")
                || die "Unable to write $section.exc";
        print GEN "<ul>\n".$none."</ul>\n" if $none ne '';
        close (GEN);
}

sub process_po {
        -d "$opt_l/po/gen" || File::Path::mkpath("$opt_l/po/gen", 0, 0775);

        get_stats_po('main', \@main);
        get_stats_po('contrib', \@contrib);
        get_stats_po('non-free', \@nonfree);
}

sub get_stats_templates {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, %list);

        my %incl = ();
        my %excl = ();
        my $none = '';
        foreach $pkg (sort @{$packages}) {
                if ($data->upstream($pkg) eq 'dbs') {
                        $none .= "<li>".$pkg." (*)\n";
                        next;
                }
                unless ($data->has_templates($pkg)) {
                        $none .= "<li>".$pkg."\n";
                        next;
                }
                my $list = {};
                foreach (@langs) {
                        $list{uc $_} = 0;
                }
                foreach $line (@{$data->templates($pkg)}) {
                        my ($template, $lang, $stat, $link_trans, $link_orig) = @{$line};
                        $link_orig ||= '';

                        $link_trans =~ s/:/\%3a/g;
                        $link_orig  =~ s/:/\%3a/g;
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
                        $incl{$lang}  = '' unless defined($incl{$lang});
                        $incl{$lang} .= "<tr bgcolor=\"".
                              get_color(percent_stat($stat)).
                              "\"><td>".$pkg."</td>".
                              "<td>".percent_stat($stat).
                              " (".show_stat($stat).")</td><td><a href=\"";
                        $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "templates/unstable/";
                        $incl{$lang} .= $data->pooldir($pkg)."/$link_trans.gz\">$template</a></td><td>";
                        if ($link_orig ne '') {
                                $incl{$lang} .= "<a href=\"";
                                $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root);
                                $incl{$lang} .= $data->pooldir($pkg)."/$link_orig.gz\">templates</a>";
                        }
                        $incl{$lang} .= "</td></tr>\n";
                }
                foreach $lang (@langs) {
                        my $l = uc($lang);
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= $pkg.", ";
                }
        }
        foreach $lang (@langs) {
                next unless defined $incl{uc $lang};
                open (GEN, "> gen/$section-$lang.inc")
                        || die "Unable to write $section-$lang.inc";
                print GEN $incl{uc $lang};
                close (GEN);
        }
        foreach $lang (@langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> gen/$section-$lang.exc")
                        || die "Unable to write $section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."</p>\n";
                close (GEN);
        }
        open (GEN, "> gen/$section.exc")
                || die "Unable to write $section.exc";
        print GEN "<ul>\n".$none."</ul>\n" if $none ne '';
        close (GEN);
}

sub process_templates {
        -d "$opt_l/templates/gen" || File::Path::mkpath("$opt_l/templates/gen", 0, 0775);

        get_stats_templates('main', \@main);
        get_stats_templates('contrib', \@contrib);
        get_stats_templates('non-free', \@nonfree);
}

sub process_langs {
        my $langs = {
                po              => {},
                templates       => {},
                all             => {},
        };

        my ($pkg, $line, $file, $lang);
        foreach $pkg ($data->list_packages()) {
                if ($data->has_po($pkg)) {
                        foreach $line (@{$data->po($pkg)}) {
                                ($file, $lang) = @{$line};
                                $langs->{po}->{$lang}  = 1;
                                $langs->{all}->{$lang} = 1;
                        }
                }
                if ($data->has_templates($pkg)) {
                        foreach $line (@{$data->templates($pkg)}) {
                                ($file, $lang) = @{$line};
                                $langs->{templates}->{$lang} = 1;
                                $langs->{all}->{$lang} = 1;
                        }
                }
        }
        
        open (GEN, "> $opt_l/data/langs")
                || die "Unable to write data/langs";
        foreach my $material (sort keys %$langs) {
                print GEN "$material: ";
                print GEN join(" ", sort keys %{$langs->{$material}});
                print GEN "\n";
        }
        close (GEN);
}

sub show_stat {
        my $stat = shift;
        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                return "$1t;$2f;$3u";
        } else {
                return $stat;
        }
}
sub percent_stat {
        my $stat = shift;
        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                return "100\%" if ($1+$2+$3 == 0);
                return sprintf "%3d%%", (100*$1/($1+$2+$3));
        } else {
                return 'NaN';
        }
}
sub get_color {
        my $percent = shift;
        $percent =~ s/\%// or return "#ff0000";
        my $nbcol = 8;
        my $level = sprintf ("%d", $percent * $nbcol / 101);
        if ($level < $nbcol / 2) {
                return sprintf ("#ff%02x00",
                        $level * 511 / ($nbcol - 1));
        } else {
                return sprintf ("#%02xff00",
                        ($nbcol - 1 - $level) * 511 / ($nbcol - 1));
                        #($nbcol - 1 - $level) * 255 / ($nbcol - 1),
        }
}

process_po()        if $opt_P;
process_templates() if $opt_T;
process_langs()     if $opt_L;
1;
