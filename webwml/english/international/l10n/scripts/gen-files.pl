#! /usr/bin/perl -w

use strict;
use File::Path;
use Getopt::Long;

use lib ($0 =~ m|(.*)/|, $1 or ".") ."/../../../../Perl";

use Webwml::L10n::Db;

use vars qw($opt_h $opt_l $opt_D $opt_P $opt_T $opt_L);

sub usage {
        print "Usage:  gen-files.pl [--l10ndir=DIR] [--po] [--templates] [--podebconf] [--langs]\n";
        exit($_[0]);
}

$opt_h = $opt_D = $opt_P = $opt_T = $opt_L = 0;
$opt_l = '.';

Getopt::Long::Configure("no_ignore_case");
if (not Getopt::Long::GetOptions(qw(
        h|help
        l|l10ndir=s
        D|podebconf
        P|po
        T|templates
        L|langs
        ))) {
        usage(1);
}
usage(0) if $opt_h;

my $data = Webwml::L10n::Db->new();
$data->read("$opt_l/data/unstable.ftp-master");
my $date1 = $data->get_date();
$data->read("$opt_l/data/unstable.non-US");
my $date2 = $data->get_date();
my $date = ($date1 lt $date2 ? $date1 : $date2);

my $root = 'http://ftp-master.debian.org/~barbier/l10n/material/';
my $rootnonus = 'http://nonus.debian.org/~barbier/l10n/material/';

my $langfile = $opt_l.'/data/langs';
#   These packages use a RFC1766 naming convention for language codes
#   which makes output page look ugly.  Do not display them until a
#   better solution is found
#   This list is defined in list-languages.pl and gen-files.pl
my %skip_po = (
        abiword         => 1,
        squirrelmail    => 1,
        #   Horde related packages
        horde2          => 1,
        imp3            => 1,
        kronolith       => 1,
        mnemo           => 1,
        nag             => 1,
        'sork-passwd'   => 1,
        turba           => 1,
);
my @po_langs = ();
my @pd_langs = ();
my @td_langs = ();

my @main    = ();
my @contrib = ();
my @nonfree = ();
my %score = ();
my %total = ();
my $tmpl_errors_maint = {};

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

        my %incl  = ();
        my %excl  = ();
        my $none  = '';
        foreach $pkg (sort @{$packages}) {
                if ($data->upstream($pkg) eq 'dbs') {
                        $none .= "<li>".$pkg." (*)</li>\n";
                        next;
                }
                unless ($data->has_po($pkg)) {
                        $none .= "<li>".$pkg."</li>\n";
                        next;
                }
                next if defined $skip_po{$pkg};
                my $list = {};
                foreach (@po_langs) {
                        $list{uc $_}  = 0;
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
                              "<td>".show_stat($stat)."</td><td><a href=\"";
                        $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "po/unstable/";
                        $incl{$lang} .= $data->pooldir($pkg)."/$link.gz\">$pofile</a></td>".
                              "</tr>\n";
                        if ($stat =~ m/(\d+)t/) {
                                $score{$lang} += $1;
                        }
                }
                foreach $lang (@po_langs) {
                        my $l = uc($lang) || 'UNKNOWN';
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= $pkg.", ";
                }
        }
        foreach $lang (@po_langs) {
                next unless defined $incl{uc $lang};
                open (GEN, "> $opt_l/po/gen/$section-$lang.inc")
                        || die "Unable to write into $opt_l/po/gen/$section-$lang.inc";
                print GEN $incl{uc $lang};
                close (GEN);
        }
        foreach $lang (@po_langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> $opt_l/po/gen/$section-$lang.exc")
                        || die "Unable to write into $opt_l/po/gen/$section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."</p>\n";
                close (GEN);
        }
        open (GEN, "> $opt_l/po/gen/$section.exc")
                || die "Unable to write into $opt_l/po/gen/$section.exc";
        print GEN "<ul>\n".$none."</ul>\n" if $none ne '';
        close (GEN);
}

sub process_po {
        -d "$opt_l/po/gen" || File::Path::mkpath("$opt_l/po/gen", 0, 0775);

        foreach (@po_langs) {
                $score{uc $_} = 0;
        }

        get_stats_po('main', \@main);
        get_stats_po('contrib', \@contrib);
        get_stats_po('non-free', \@nonfree);

        open (GEN, "> $opt_l/po/gen/rank.inc")
                || die "Unable to write into $opt_l/po/gen/rank.inc";
        print GEN "<dl>\n";
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @po_langs) {
                print GEN "<dt><a href=\"$lang\">$lang</a> ".$score{uc $lang}."</dt>\n";
                print GEN "<dd><language-name $lang /></dd>\n";
        }
        print GEN "</dl>\n";
        close (GEN);
}

sub get_stats_templates {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, $maint, %list);

        my %incl = ();
        my %excl = ();
        my $none = '';
        my $tmpl_errors = {};
        foreach $pkg (sort @{$packages}) {
                unless ($data->has_templates($pkg)) {
                        $none .= "<li>".$pkg."</li>\n";
                        next;
                }
                my $list = {};
                foreach (@td_langs) {
                        $list{uc $_} = 0;
                }
                my ($template, $lang, $stat, $link_trans, $link_orig) = ();
                my @untranslated = ();
                foreach $line (@{$data->templates($pkg)}) {
                        ($template, $lang, $stat, $link_trans, $link_orig) = @{$line};
                        $link_orig ||= '';
                        $link_trans =~ s/:/\%3a/g;
                        $link_orig  =~ s/:/\%3a/g;
                        if ($lang eq '_') {
                                push(@untranslated, $link_trans);
                                next;
                        }

                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
                        $incl{$lang}  = '' unless defined($incl{$lang});
                        $incl{$lang} .= "<tr bgcolor=\"".
                              get_color(percent_stat($stat)).
                              "\"><td>".$pkg."</td>".
                              "<td>".show_stat($stat)."</td><td><a href=\"";
                        $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "templates/unstable/";
                        $incl{$lang} .= $data->pooldir($pkg)."/$link_trans.gz\">$template</a></td><td>";
                        if ($link_orig ne '') {
                                $incl{$lang} .= "<a href=\"";
                                $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "templates/unstable/";
                                $incl{$lang} .= $data->pooldir($pkg)."/$link_orig.gz\">templates</a>";
                        }
                        $incl{$lang} .= "</td></tr>\n";
                        if ($stat =~ m/(\d+)t/) {
                                $score{$lang} += $1;
                        }
                }
                #   Ensure $ftemp is defined
                my $ftemp = shift @untranslated || $link_trans;
                foreach $lang (@td_langs) {
                        my $l = uc($lang);
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= "<a href=\"".($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root)."templates/unstable/".$data->pooldir($pkg)."/".$ftemp.".gz\">".$pkg."</a>";
                        my $count = 1;
                        foreach (@untranslated) {
                                $count ++;
                                $excl{$l} .= "<a href=\"".($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root)."templates/unstable/".$data->pooldir($pkg)."/".$_.".gz\">[".$count."]</a>";
                        }
                        $excl{$l} .= ", ";
                }
                if ($data->has_errors($pkg)) {
                        $tmpl_errors->{$pkg} = { noorig => [], master => [], fuzzy => [], mismatch => [], };
                        my $found = 0;
                        foreach (@{$data->errors($pkg)}) {
                                next unless s/debconf: //;
                                if (m/([^:]+):(\d+): original-fields-removed-in-translated-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{noorig}}, "$1:$2");
                                        $found = 1;
                                } elsif (m/([^:]+):(\d+): translated-fields-in-master-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{master}}, "$1:$2");
                                        $found = 1;
                                } elsif (m/([^:]+):(\d+): fuzzy-fields-in-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{fuzzy}}, "$1:$2");
                                        $found = 1;
                                } elsif (m/([^:]+):(\d+): lang-mismatch-in-translated-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{mismatch}}, "$1:$2");
                                        $found = 1;
                                }
                        }
                        delete $tmpl_errors->{$pkg} unless $found;
                }
        }
        foreach $lang (@td_langs) {
                next unless defined $incl{uc $lang};
                open (GEN, "> $opt_l/templates/gen/$section-$lang.inc")
                        || die "Unable to write into $opt_l/templates/gen/$section-$lang.inc";
                print GEN $incl{uc $lang};
                close (GEN);
        }
        foreach $lang (@td_langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> $opt_l/templates/gen/$section-$lang.exc")
                        || die "Unable to write into $opt_l/templates/gen/$section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."</p>\n";
                close (GEN);
        }
        open (GEN, "> $opt_l/templates/gen/$section.exc")
                || die "Unable to write into $opt_l/templates/gen/$section.exc";
        print GEN "<ul>\n".$none."</ul>\n" if $none ne '';
        close (GEN);
        open (GEN, "> $opt_l/templates/gen/errors-by-pkg.$section.inc");
        foreach $pkg (sort keys %$tmpl_errors) {
                $maint = $data->maintainer($pkg);
                $maint =~ s/\s*<.*>//;
                $maint =~ s/&/&amp;/g;
                print GEN "<li><a name=\"P$pkg\">$pkg</a> ".$data->version($pkg)." [$maint]\n";
                my $errors_pkg = "<ul>\n";
                if (@{$tmpl_errors->{$pkg}->{master}}) {
                        $errors_pkg .= "<li><a href=\"errors#master\">translated-fields-in-master-templates</a><br>\n".${$tmpl_errors->{$pkg}->{master}}[0]."</li>\n";
                }
                if (@{$tmpl_errors->{$pkg}->{noorig}}) {
                        $errors_pkg .= "<li><a href=\"errors#noorig\">original-fields-removed-in-translated-templates</a><br>\n";
                        foreach (@{$tmpl_errors->{$pkg}->{noorig}}) {
                                $errors_pkg .= "$_<br>\n";
                        }
                        $errors_pkg .= "</li>\n";
                }
                if (@{$tmpl_errors->{$pkg}->{fuzzy}}) {
                        $errors_pkg .= "<li><a href=\"errors#fuzzy\">fuzzy-fields-in-templates</a><br>\n";
                        foreach (@{$tmpl_errors->{$pkg}->{fuzzy}}) {
                                $errors_pkg .= "$_<br>\n";
                        }
                        $errors_pkg .= "</li>\n";
                }
                if (@{$tmpl_errors->{$pkg}->{mismatch}}) {
                        $errors_pkg .= "<li><a href=\"errors#mismatch\">lang-mismatch-in-translated-templates</a><br>\n";
                        foreach (@{$tmpl_errors->{$pkg}->{mismatch}}) {
                                $errors_pkg .= "$_<br>\n";
                        }
                        $errors_pkg .= "</li>\n";
                }
                $errors_pkg .= "</ul>\n";
                print GEN $errors_pkg;
                $tmpl_errors_maint->{$maint} = {} unless defined($tmpl_errors_maint->{$maint});
                $tmpl_errors_maint->{$maint}->{$pkg} = "$pkg ".$data->version($pkg)."\n".$errors_pkg;
        }
        close (GEN);
}

sub process_templates {
        -d "$opt_l/templates/gen" || File::Path::mkpath("$opt_l/templates/gen", 0, 0775);

        foreach (@td_langs) {
                $score{uc $_} = 0;
        }

        get_stats_templates('main', \@main);
        get_stats_templates('contrib', \@contrib);
        get_stats_templates('non-free', \@nonfree);

        open (GEN, "> $opt_l/templates/gen/rank.inc")
                || die "Unable to write into $opt_l/templates/gen/rank.inc";
        print GEN "<dl>\n";
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @td_langs) {
                print GEN "<dt><a href=\"$lang\">$lang</a> ".$score{uc $lang}."</dt>\n";
                print GEN "<dd><language-name $lang /></dd>\n";
        }
        print GEN "</dl>\n";
        close (GEN);
        open (GEN, "> $opt_l/templates/gen/errors-by-maint.inc");
        foreach my $maint (sort keys %$tmpl_errors_maint) {
                my $anchor_maint = lc $maint;
                $anchor_maint =~ s/[^a-z0-9]/_/g;
                $anchor_maint =~ s/&/&amp;/g;
                print GEN "<li><a name=\"M$anchor_maint\">$maint</a>\n<ul>";
                foreach my $pkg (sort keys %{$tmpl_errors_maint->{$maint}}) {
                        print GEN "<li>".$tmpl_errors_maint->{$maint}->{$pkg}."</li>\n";
                }
                print GEN "</ul></li>\n";
        }
        close (GEN);
}

sub get_stats_podebconf {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, %list);

        $total{$section} = 0;
        my %incl  = ();
        my %excl  = ();
        my $orig  = '';
        foreach $pkg (sort @{$packages}) {
                next unless $data->has_podebconf($pkg);

                my $list = {};
                foreach (@pd_langs) {
                        $list{uc $_}  = 0;
                }
                my $addorig = '';
                foreach $line (@{$data->podebconf($pkg)}) {
                        my ($pofile, $lang, $stat, $link) = @{$line};
                        last unless $lang eq '_';

                        $pofile =~ s#^debian/##;
                        $link =~ s/:/\%3a/g;
                        $addorig .= " [<a href=\"".
                                ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root).
                                ($pofile eq 'templates.pot' ? 'po' : 'templates').
                                '/unstable/'.$data->pooldir($pkg).
                                "/$link.gz\">$pofile</a>]";
                }
                $orig .= "<li><a name=\"$pkg\">$pkg</a>$addorig</li>\n"
                        if $addorig;

                my $addtotal = 0;
                foreach $line (@{$data->podebconf($pkg)}) {
                        my ($pofile, $lang, $stat, $link) = @{$line};
                        next if $lang eq '_';

                        $pofile =~ s#^debian/po/##;
                        $link =~ s/:/\%3a/g;
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
                        $incl{$lang}  = '' unless defined($incl{$lang});
                        $incl{$lang} .= "<tr bgcolor=\"".
                              get_color(percent_stat($stat)).
                              "\"><td>".$pkg."</td>".
                              "<td>".show_stat($stat)."</td><td><a href=\"";
                        $incl{$lang} .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "po/unstable/";
                        $incl{$lang} .= $data->pooldir($pkg)."/$link.gz\">$pofile</a></td>".
                              "</tr>\n";
                        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                                $score{$lang} += $1;
                                $addtotal = $1 + $2 + $3
                                        if $1 + $2 + $3 > 0;
                        }
                }
                $total{$section} += $addtotal;

                foreach $lang (@pd_langs) {
                        my $l = uc($lang) || 'UNKNOWN';
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= "<a href=\"pot#$pkg\">$pkg</a>, ";
                }
        }
        foreach $lang (@pd_langs) {
                next unless defined $incl{uc $lang};
                open (GEN, "> $opt_l/po-debconf/gen/$section-$lang.inc")
                        || die "Unable to write into $opt_l/po-debconf/gen/$section-$lang.inc";
                print GEN $incl{uc $lang};
                close (GEN);
        }
        foreach $lang (@pd_langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> $opt_l/po-debconf/gen/$section-$lang.exc")
                        || die "Unable to write into $opt_l/po-debconf/gen/$section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."</p>\n";
                close (GEN);
        }
        open (GEN, "> $opt_l/po-debconf/gen/$section.orig")
                || die "Unable to write into $opt_l/po-debconf/gen/$section.orig";
        print GEN "<ul>\n".$orig."</ul>\n" if $orig ne '';
        close (GEN);
}

sub podebconf_stats_ranking {
        my $this = shift;
        my $total = shift;
        return 0 if $total == 0;
        return sprintf "\%d", 100 * $this / $total;
}

sub process_podebconf {
        -d "$opt_l/po-debconf/gen" || File::Path::mkpath("$opt_l/po-debconf/gen", 0, 0775);

        foreach (@pd_langs) {
                $score{uc $_} = 0;
        }

        get_stats_podebconf('main', \@main);
        get_stats_podebconf('contrib', \@contrib);
        get_stats_podebconf('non-free', \@nonfree);

        open (GEN, "> $opt_l/po-debconf/gen/rank.inc")
                || die "Unable to write into $opt_l/po-debconf/gen/rank.inc";
        print GEN "<dl>\n";
        my $str_total = $total{main}+$total{contrib}+$total{'non-free'};
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @pd_langs) {
                print GEN "<dt><a href=\"$lang\">$lang</a> ".$score{uc $lang}.
                        " (".podebconf_stats_ranking($score{uc $lang}, $str_total),
                        "\%)</dt>\n";
                print GEN "<dd><language-name $lang /></dd>\n";
        }
        print GEN "</dl>\n";
        open (GEN, "> $opt_l/po-debconf/gen/total")
                || die "Unable to write into $opt_l/po-debconf/gen/total";
        print GEN "<define-tag podebconf-total-strings>".
                ($total{main}+$total{contrib}+$total{'non-free'}).
                "</define-tag>\n";
        close (GEN);
}

sub process_langs {
        my $store = shift;

        my $langs = {
                po              => {},
                templates       => {},
                podebconf       => {},
                all             => {},
        };

        my ($pkg, $line, $file, $lang);
        foreach $pkg ($data->list_packages()) {
                if ($data->has_po($pkg) && !defined($skip_po{$pkg})) {
                        foreach $line (@{$data->po($pkg)}) {
                                ($file, $lang) = @{$line};
                                next unless $lang ne '';
                                $langs->{po}->{$lang}  = 1;
                                $langs->{all}->{$lang} = 1;
                        }
                }
                if ($data->has_templates($pkg)) {
                        foreach $line (@{$data->templates($pkg)}) {
                                ($file, $lang) = @{$line};
                                next unless $lang ne '' && $lang ne '_';
                                $langs->{templates}->{$lang} = 1;
                                $langs->{all}->{$lang} = 1;
                        }
                }
                if ($data->has_podebconf($pkg)) {
                        foreach $line (@{$data->podebconf($pkg)}) {
                                ($file, $lang) = @{$line};
                                next unless $lang ne '' && $lang ne '_';
                                $langs->{podebconf}->{$lang} = 1;
                                $langs->{all}->{$lang} = 1;
                        }
                }
        }
        @po_langs = keys %{$langs->{po}};
        @td_langs = keys %{$langs->{templates}};
        @pd_langs = keys %{$langs->{podebconf}};
        return unless $store;

        open (GEN, "> $opt_l/data/langs")
                || die "Unable to write into $opt_l/data/langs";
        foreach my $material (sort keys %$langs) {
                print GEN "$material: ";
                print GEN join(" ", sort keys %{$langs->{$material}});
                print GEN "\n";
        }
        close (GEN);
}

sub show_stat {
        my $stat = shift;
        my $ret = percent_stat($stat) || return '';
        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                $ret .= " ($1t;$2f;$3u)";
        } else {
                $ret .= " ($stat)";
        }
        return $ret;
}
sub percent_stat {
        my $stat = shift;
        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                return '' if ($1+$2+$3 == 0);  # there must be an error!
                return sprintf "%3d%%", (100*$1/($1+$2+$3));
        }
        return '';
}
sub get_color {
        my $percent = shift;
        $percent =~ s/\%$// or return "#ff0000";
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

open (GEN, "> $opt_l/date.gen")
        || die "Unable to write into $opt_l/date.gen";
print GEN <<"EOT";
#  File automatically generated.  Do not edit!

\#use wml::debian::ctime

<p>
<show-data-date "<:= spokendate('$date') :>" />
<warn-data-outdated/>
</p>
EOT
close (GEN);

process_langs($opt_L);
process_po()        if $opt_P;
process_templates() if $opt_T;
process_podebconf() if $opt_D;

1;
