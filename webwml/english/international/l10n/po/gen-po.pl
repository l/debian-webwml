#! /usr/bin/perl -w

use lib '../../../../Perl';
use Webwml::L10n::Db;

my $data = Webwml::L10n::Db->new();
$data->read('../data/unstable.ftp-master');
$data->read('../data/unstable.non-US');

my $root = 'http://ftp-master.debian.org/~barbier/l10n/material/po/unstable/';
my $rootnonus = 'http://nonus.debian.org/~barbier/l10n/material/po/unstable/';

my $langfile = '../data/langs';

my @main = ();
my @contrib = ();
my @nonfree = ();

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


-d 'gen' || mkdir 'gen', 0775;

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

get_stats('main', \@main);
get_stats('contrib', \@contrib);
get_stats('non-free', \@nonfree);

sub get_stats {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang);

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
                        $incl{$lang} .= "<tr><td>".$pkg."</td>".
                              "<td>".percent_stat($stat)."</td>".
                              "<td>".show_stat($stat)."</td><td><a href=\"";
                        $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root);
                        $incl{$lang} .= $data->pooldir($pkg)."/$link.gz\">$pofile</a></td>".
                              "</tr>\n";
                }
                foreach $lang (@langs) {
                        my $l = uc($lang);
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= "<li>".$pkg."\n";
                }
        }
        foreach $lang (@langs) {
                next unless defined $incl{uc $lang};
                open (PO, "> gen/$section-$lang.inc")
                        || die "Unable to write $section-$lang.inc";
                print PO $incl{uc $lang};
                close (PO);
        }
        foreach $lang (@langs) {
                next unless defined $excl{uc $lang};
                open (PO, "> gen/$section-$lang.exc")
                        || die "Unable to write $section-$lang.exc";
                print PO "<ul>\n".$excl{uc $lang}."</ul>\n";
                close (PO);
        }
        open (PO, "> gen/$section.exc")
                || die "Unable to write $section.exc";
        print PO "<ul>\n".$none."</ul>\n" if $none ne '';
        close (PO);
}

sub show_stat {
        my $stat = shift;
        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                return "$1 t; $2 f; $3 u;";
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

