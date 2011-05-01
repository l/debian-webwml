#! /usr/bin/perl -w

use strict;
use File::Path;
use Getopt::Long;

use lib ($0 =~ m|(.*)/|, $1 or ".") ."/../../../../Perl";

use Debian::L10n::Db;

use vars qw($opt_h $opt_d $opt_l $opt_s $opt_D $opt_P $opt_T $opt_L $opt_M);

my %LanguageList = (
	AR    => 'arabic',
	CA    => 'catalan',
	CS    => 'czech',
	DE    => 'german',
	RU    => 'russian',
# Used by the Smith project, not for translations
#	EN    => 'english',
	ES    => 'spanish',
	FR    => 'french',
# Not supported yet by the robot. Not all messages are sent ot the list
#	NL    => 'dutch',
	PT_BR => 'portuguese',
	RO    => 'romanian',
	SV    => 'swedish',
# Has not used pseudo-urls recently
#	TR    => 'turkish',
);
my %Status = (
	todo => 0,
	maj  => 1,
	itt  => 2,
	rfr  => 3,
	itr  => 4,
	lcfc => 5,
	bts  => 6,
	fix  => 7,
	done => 8,
	hold => 9,
	);

sub usage {
        print "Usage:  gen-files.pl [--dist=DIST] [--l10ndir=DIR] [--sort=FILE] [--po] [--templates] [--podebconf] [--langs] [--po4a]\n";
        exit($_[0]);
}

$opt_h = $opt_D = $opt_P = $opt_T = $opt_L = 0;
$opt_s = '';
$opt_d = 'unstable';
$opt_l = '.';

Getopt::Long::Configure("no_ignore_case");
if (not Getopt::Long::GetOptions(qw(
        h|help
        l|l10ndir=s
        d|dist=s
        s|sort=s
        D|podebconf
        P|po
        T|templates
        L|langs
        M|po4a
        ))) {
        usage(1);
}
usage(0) if $opt_h;

my $data = Debian::L10n::Db->new();
$data->read("$opt_l/data/$opt_d.gluck");
my $date1 = $data->get_date();
#$data->read("$opt_l/data/$opt_d.non-US");
#my $date2 = $data->get_date();
my $date = $date1; #   Ignore non-US for now
# my $date = ($date1 lt $date2 ? $date1 : $date2);
my %popcon = ();
if ($opt_s ne '' && -r $opt_s && open (POPCON, "< $opt_s")) {
        #  This file is in the same format as
        #    http://popcon.debian.org/source/by_inst
        while (<POPCON>) {
                next if m/^#/;
                last unless m/^(\d+)\s+(\S+)/;
                $popcon{$2} = $1;
        }
        close (POPCON);
}
sub pkgsort ($$) {
        if (!defined($popcon{$_[0]}) && !defined($popcon{$_[1]})) {
                return $_[0] cmp $_[1];
        } elsif (!defined($popcon{$_[0]})) {
                return 1;
        } elsif (!defined($popcon{$_[1]})) {
                return -1;
        } else {
                return $popcon{$_[0]} <=> $popcon{$_[1]};
        }
}

#my $root = 'http://merkel.debian.org/~barbier/l10n/material/';
#my $rootnonus = 'http://merkel.debian.org/~barbier/l10n/material/';
my $root = 'http://i18n.debian.net/material/';
my $rootnonus = $root;

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
my @p4_langs = ();
my @pd_langs = ();
my @td_langs = ();
my @al_langs = ();

my @main    = ();
my @contrib = ();
my @nonfree = ();
my %score = ();
my %total = ();
my $tmpl_errors_maint = {};
my $podebconf_errors_maint = {};

foreach my $pkg ($data->list_packages()) {
        next unless (length $pkg); # skip headers
        #   Populate arrays
        my $section = $data->section($pkg);
        unless (defined $section) {
                warn "Package without section: $pkg\n";
                next;
        }
        if ($section =~ m#^(non-us/)?contrib/#) {
                push (@contrib, $pkg);
        } elsif ($section =~ m#^(non-us/)?non-free/#) {
                push (@nonfree, $pkg);
        } else {
                push (@main, $pkg);
        }
}

sub transform_translator {
        my $name = shift or return "";
        #  Some translators forget the right angle bracket
        $name =~ s/\s*<.*//;
        $name =~ s/&(?!#)/&amp;/g;
        $name =~ s/=\?.*?\?=//g;
        $name = 'DDTP' if $name eq 'Debian Description Translation Project';
        $name = '' if $name =~ m/\@/;
        return $name;
}

sub transform_team {
        my $name = shift or return "";
        $name =~ s/.*<//;
        $name =~ s/>.*//;
        $name =~ s/@/ at /g;
        $name =~ s/\./ dot /g;
        $name =~ s/&(?!#)/&amp;/g;
        return $name;
}

sub get_stats_po4a {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, %list);

        my %done  = ();
        my %todo  = ();
        my %excl  = ();
        my $none  = '';
        my $orig  = '';

        $total{$section} = 0;
        foreach $pkg (sort pkgsort @{$packages}) {
                if ($data->upstream($pkg) eq 'dbs') {
                        $none .= "<li>".$pkg." (*)</li>\n";
                        next;
                }
                unless ($data->has_po4a($pkg)) {
                        $none .= "<li>".$pkg."</li>\n";
                        next;
                }
                my $list = {};
                foreach (@p4_langs) {
                        $list{uc $_}  = 0;
                }
                my $addorig = '';
                foreach $line (@{$data->po4a($pkg)}) {
                        my ($po4afile, $lang, $stat, $link,$translator,$team) = @{$line};
                        $link =~ s/:/\%3a/g;
                        $link =~ s/#/\%23/g;
                        $translator = transform_translator($translator);
                        $team = transform_team($team);
                        if ($lang eq '_') {
                                if ($stat =~ m/(\d+)u/) {
                                        $total{$section} += $1;
                                }
                                $addorig .= " [<a href=\"".
                                        ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root).
                                        "po/$opt_d/".$data->pooldir($pkg).
                                        "/$link.gz\">$po4afile</a>]";
                                next;
                        }
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
		        my $str= '';
                        $str .= "<tr style=\"background-color: ".
                              get_color(percent_stat($stat)).
                              "\"><td>";
		        $str .= (percent_stat($stat) eq "100%" ? $pkg : "<a href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>");
		        $str .= "</td><td>".show_stat($stat)."</td><td><a href=\"";
                        $str .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "po/$opt_d/";
                        $str .= $data->pooldir($pkg)."/$link.gz\">$po4afile</a></td>";
		        $str .= "<td>$translator</td><td>$team</td>".
                              "</tr>\n";
                        if ($stat =~ m/(\d+)t/) {
                                $score{$lang} += $1;
                        }
                        if (percent_stat($stat) eq "100%") {
                                $done{$lang} = ($done{$lang} || '') . $str; # avoid warning when concatening
                        } else {
                                $todo{$lang} = ($todo{$lang} || '') . $str;
                        }
                }
                $orig .= "<li><a name=\"$pkg\" href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>$addorig</li>\n"
                        if $addorig;
                foreach $lang (@p4_langs) {
                        my $l = uc($lang) || 'UNKNOWN';
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= $pkg.", ";
                }
        }
        foreach $lang (@p4_langs) {
                next unless defined $done{uc $lang};
                open (GEN, "> $opt_l/po4a/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/po4a/gen/$section-$lang.ok";
                print GEN $done{uc $lang};
                close (GEN);
        }
        foreach $lang (@p4_langs) {
                next unless defined $todo{uc $lang};
                open (GEN, "> $opt_l/po4a/gen/$section-$lang.todo")
                        || die "Unable to write into $opt_l/po4a/gen/$section-$lang.todo";
                print GEN $todo{uc $lang};
                close (GEN);
        }
        foreach $lang (@p4_langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> $opt_l/po4a/gen/$section-$lang.exc")
                        || die "Unable to write into $opt_l/po4a/gen/$section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."</p>\n";
                close (GEN);
        }
        open (GEN, "> $opt_l/po4a/gen/$section.exc")
                || die "Unable to write into $opt_l/po4a/gen/$section.exc";
        print GEN "<ul>\n".$none."</ul>\n" if $none ne '';
        close (GEN);
        open (GEN, "> $opt_l/po4a/gen/$section.orig")
                || die "Unable to write into $opt_l/po4a/gen/$section.orig";
        print GEN "<ul>\n".$orig."</ul>\n" if $orig ne '';
        close (GEN);
}

sub process_po4a {
        -d "$opt_l/po/gen" || File::Path::mkpath("$opt_l/po4a/gen", 0, 0775);

        foreach (@p4_langs) {
                $score{uc $_} = 0;
        }

        get_stats_po4a('main', \@main);
        get_stats_po4a('contrib', \@contrib);
        get_stats_po4a('non-free', \@nonfree);

        open (GEN, "> $opt_l/po4a/gen/rank.inc")
                || die "Unable to write into $opt_l/po4a/gen/rank.inc";
        print GEN "<ul>\n";
	my $str_total = $total{main}+$total{contrib}+$total{'non-free'};
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @p4_langs) {
                print GEN "<li><strong><a href=\"$lang\">$lang</a> ".$score{uc $lang}.
                        " (".podebconf_stats_ranking($score{uc $lang}, $str_total),
                        "\%)</strong> &ndash;\n";
                print GEN "<language-name $lang /></li>\n";
        }
        print GEN "</ul>\n";
        close (GEN);
        open (GEN, "> $opt_l/po4a/gen/total")
                || die "Unable to write into $opt_l/po4a/gen/total";
        print GEN "<define-tag po4a-total-strings>$str_total</define-tag>\n";
        close (GEN);
        open (GEN, "> $opt_l/po4a/gen/stats")
                || die "Unable to write into $opt_l/templates/gen/stats";
        foreach my $lang (@p4_langs) {
	            print GEN "$lang:".$score{uc $lang}."\n" if defined ($score{uc $lang});
	        }
        close (GEN);
}

sub get_stats_po {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, %list);

        my %done  = ();
        my %todo  = ();
        my %excl  = ();
        my $none  = '';
        my $orig  = '';

        $total{$section} = 0;
        foreach $pkg (sort pkgsort @{$packages}) {
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
                my $addorig = '';
                foreach $line (@{$data->po($pkg)}) {
                        my ($pofile, $lang, $stat, $link,$translator,$team) = @{$line};
                        $link =~ s/:/\%3a/g;
                        $link =~ s/#/\%23/g;
                        $translator = transform_translator($translator);
                        $team = transform_team($team);
                        if ($lang eq '_') {
                                if ($stat =~ m/(\d+)u/) {
                                        $total{$section} += $1;
                                }
                                $addorig .= " [<a href=\"".
                                        ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root).
                                        "po/$opt_d/".$data->pooldir($pkg).
                                        "/$link.gz\">$pofile</a>]";
                                next;
                        }
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
		        my $str= '';
                        $str .= "<tr style=\"background-color: ".
                              get_color(percent_stat($stat)).
                              "\"><td>";
		        $str .= (percent_stat($stat) eq "100%" ? $pkg : "<a href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>");
		        $str .= "</td><td>".show_stat($stat)."</td><td><a href=\"";
                        $str .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "po/$opt_d/";
                        $str .= $data->pooldir($pkg)."/$link.gz\">$pofile</a></td>";
		        $str .= "<td>$translator</td><td>$team</td>".
                              "</tr>\n";
                        if ($stat =~ m/(\d+)t/) {
                                $score{$lang} += $1;
                        }
                        if (percent_stat($stat) eq "100%") {
                                $done{$lang} = ($done{$lang} || '') . $str; # avoid warning when concatening
                        } else {
                                $todo{$lang} = ($todo{$lang} || '') . $str;
                        }
                }
                $orig .= "<li><a name=\"$pkg\" href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>$addorig</li>\n"
                        if $addorig;
                foreach $lang (@po_langs) {
                        my $l = uc($lang) || 'UNKNOWN';
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= $pkg.", ";
                }
        }
        foreach $lang (@po_langs) {
                next unless defined $done{uc $lang};
                open (GEN, "> $opt_l/po/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/po/gen/$section-$lang.ok";
                print GEN $done{uc $lang};
                close (GEN);
        }
        foreach $lang (@po_langs) {
                next unless defined $todo{uc $lang};
                open (GEN, "> $opt_l/po/gen/$section-$lang.todo")
                        || die "Unable to write into $opt_l/po/gen/$section-$lang.todo";
                print GEN $todo{uc $lang};
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
        open (GEN, "> $opt_l/po/gen/$section.orig")
                || die "Unable to write into $opt_l/po/gen/$section.orig";
        print GEN "<ul>\n".$orig."</ul>\n" if $orig ne '';
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

	# Rule out languages with no string translated
	my @po_langs_notempty;
	foreach (@po_langs) {
		if ($score{uc $_} != 0) {
			push @po_langs_notempty,$_;
		}
		else {
			unlink("$opt_l/po/gen/main-$_.exc")
				|| die ("Unable to delete main-$_.exc\n");
			unlink("$opt_l/po/gen/contrib-$_.exc")
				|| die ("Unable to delete contrib-$_.exc\n");
			unlink("$opt_l/po/gen/non-free-$_.exc")
				|| die ("Unable to delete non-free-$_.exc\n");
		}
	}
	@po_langs = @po_langs_notempty;

        open (GEN, "> $opt_l/po/gen/rank.inc")
                || die "Unable to write into $opt_l/po/gen/rank.inc";
        print GEN "<ul>\n";
	my $str_total = $total{main}+$total{contrib}+$total{'non-free'};
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @po_langs) {
                print GEN "<li><strong><a href=\"$lang\">$lang</a> ".$score{uc $lang}.
                          " (".podebconf_stats_ranking($score{uc $lang}, $str_total),
                          "\%)</strong> &ndash;\n";
                print GEN "<language-name $lang /></li>\n";
        }
        print GEN "</ul>\n";
        close (GEN);
        open (GEN, "> $opt_l/po/gen/total")
                || die "Unable to write into $opt_l/po/gen/total";
        print GEN "<define-tag po-total-strings>$str_total</define-tag>\n";
        close (GEN);
        open (GEN, "> $opt_l/po/gen/stats")
                || die "Unable to write into $opt_l/templates/gen/stats";
        foreach my $lang (@po_langs) {
	            print GEN "$lang:".$score{uc $lang}."\n" if defined ($score{uc $lang});
	        }
        close (GEN);
}

sub get_stats_templates {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, $maint, %list);

        my %done  = ();
        my %todo  = ();
        my %error  = ();
        my %excl = ();
        my $none = '';
        my $tmpl_errors = {};
	$total{$section}=0;
        foreach $pkg (sort pkgsort @{$packages}) {
                unless ($data->has_templates($pkg)) {
                        $none .= "<li>".$pkg."</li>\n";
                        next;
                }
                $tmpl_errors->{$pkg} = { podebconf => [], noorig => [], master => [], fuzzy => [], mismatch => [], };
                if ($data->has_errors($pkg)) {
                        foreach (@{$data->errors($pkg)}) {
                                next unless s/debconf: //;
                                if (m/([^:]+):(\d+): original-fields-removed-in-translated-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{noorig}}, "$1:$2");
                                } elsif (m/([^:]+):(\d+): translated-fields-in-master-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{master}}, "$1:$2");
                                } elsif (m/([^:]+):(\d+): fuzzy-fields-in-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{fuzzy}}, "$1:$2");
                                } elsif (m/([^:]+):(\d+): lang-mismatch-in-translated-templates/) {
                                        push(@{$tmpl_errors->{$pkg}->{mismatch}}, "$1:$2");
                                }
                        }
                }
                push(@{$tmpl_errors->{$pkg}->{podebconf}}, "not-using-po-debconf");
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
                        $link_trans =~ s/#/\%23/g;
                        $link_orig  =~ s/:/\%3a/g;
                        $link_orig  =~ s/#/\%23/g;
                        if ($lang eq '_') {
                                push(@untranslated, $link_trans);
			        if ($stat =~ m/(\d+)t/) {
                                        $total{$section} += $1;
                                }
                                next;
                        }

                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
		        my $str = '';
                        $str .= "<tr style=\"background-color: ".
                              get_color(percent_stat($stat)).
                              "\"><td>";
		        if (defined $tmpl_errors->{$pkg}) {
			    $str .= "<a href=\"errors-by-pkg#P$pkg\">!</a>&nbsp;";
			} else {
			    $str .= "&nbsp;&nbsp;";
			}
		        $str .= (percent_stat($stat) eq "100%" ? $pkg : "<a href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>");
                        $str .= "</td><td>".show_stat($stat)."</td><td><a href=\"";
                        $str .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "templates/$opt_d/";
                        $str .= $data->pooldir($pkg)."/$link_trans.gz\">$template</a></td><td>";
                        if ($link_orig ne '') {
                                $str .= "<a href=\"";
                                $str .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "templates/$opt_d/";
                                $str .= $data->pooldir($pkg)."/$link_orig.gz\">templates</a>";
                        }
                        $str .= "</td></tr>\n";
                        if ($stat =~ m/(\d+)t/) {
                                $score{$lang} += $1;
                        }
		    	if (percent_stat($stat) eq "100%") {
			  if (defined $tmpl_errors->{$pkg}) {
                           $error{$lang}  = '' unless defined($error{$lang});
			   $error{$lang} .= $str;
			  } else {
                           $done{$lang}  = '' unless defined($done{$lang});
			   $done{$lang} .= $str;
			  }
 			} else {
                           $todo{$lang}  = '' unless defined($todo{$lang});
			   $todo{$lang} .= $str;
			}
                }
                #   Ensure $ftemp is defined
                my $ftemp = shift @untranslated || $link_trans;
                foreach $lang (@td_langs) {
                        my $l = uc($lang);
                        next if $list{$l};
                        $excl{$l}  = '' unless defined($excl{$l});
                        $excl{$l} .= "<a href=\"".($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root)."templates/$opt_d/".$data->pooldir($pkg)."/".$ftemp.".gz\">".$pkg."</a>";
                        my $count = 1;
                        foreach (@untranslated) {
                                $count ++;
                                $excl{$l} .= "[<a href=\"".($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root)."templates/$opt_d/".$data->pooldir($pkg)."/".$_.".gz\">".$count."</a>]";
                        }
		        if (defined $tmpl_errors->{$pkg}) {
			    $excl{$l} .= " (<a href=\"errors-by-pkg#P$pkg\">!</a>)";
			}
                        $excl{$l} .= ", ";
                }
        }
        foreach $lang (@td_langs) {
                next unless defined $done{uc $lang};
                open (GEN, "> $opt_l/templates/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/templates/gen/$section-$lang.ok";
                print GEN $done{uc $lang};
                close (GEN);
        }
        foreach $lang (@td_langs) {
                next unless defined $error{uc $lang};
                open (GEN, ">> $opt_l/templates/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/templates/gen/$section-$lang.ok";
                print GEN "<tr><td colspan=3>PO files with errors</td></tr>\n";
                print GEN $error{uc $lang};
                close (GEN);
        }
        foreach $lang (@td_langs) {
                next unless defined $todo{uc $lang};
                open (GEN, "> $opt_l/templates/gen/$section-$lang.todo")
                        || die "Unable to write into $opt_l/templates/gen/$section-$lang.todo";
                print GEN $todo{uc $lang};
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
	        my $anchor_maint = lc $maint;
                $anchor_maint =~ s/[^a-z0-9]/_/g;

                print GEN "<li><a name=\"P$pkg\">$pkg</a> ".$data->version($pkg)." [<a href=\"errors-by-maint#M$anchor_maint\">$maint</a>]\n";
                my $errors_pkg = "<ul>\n";
                if (@{$tmpl_errors->{$pkg}->{podebconf}}) {
                        $errors_pkg .= "<li><a href=\"errors#podebconf\">not-using-po-debconf</a></li>\n";
                }
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
        open (GEN, "> $opt_l/templates/gen/total")
                || die "Unable to write into $opt_l/templates/gen/total";
        print GEN "<define-tag templates-total-strings>".
                ($total{main}+$total{contrib}+$total{'non-free'}).
                "</define-tag>\n";
        close (GEN);
        open (GEN, "> $opt_l/templates/gen/stats")
                || die "Unable to write into $opt_l/templates/gen/stats";
        foreach my $lang (@td_langs) {
	    print GEN "$lang:".$score{uc $lang}."\n";
	}
        close (GEN);
}

sub get_stats_podebconf {
        my ($section, $packages) = @_;
        my ($pkg, $line, $lang, $maint, %list);

        $total{$section} = 0;
        my %done  = ();
        my %error = ();
        my %todo  = ();
        my %excl_pending  = ();
        my %excl  = ();
        my $orig  = '';
	my $podebconf_errors = {};
	my $podebconf_errors_by_language = {};
	# Load the coordination status databases
        my %status_db    = ();
        opendir (DATADIR, "$opt_l/data")
                or die "Cannot open directory $opt_l/data: $!\n";
        foreach (readdir (DATADIR)) {
                # Only check the status files
                next unless ($_ =~ m/^status\.(.*)$/);
                my $l = $1;
                # status.en is not used for the English translation, but
                # for reviews
                next if ($l eq "en");

                if (-r "$opt_l/data/status.$l") {
                        $status_db{uc $l} = Debian::L10n::Db->new();
                        $status_db{uc $l}->read("$opt_l/data/status.$l", 0);
                }
        }
        closedir (DATADIR);
        foreach $pkg (sort pkgsort @{$packages}) {
                next unless $data->has_podebconf($pkg);

                my $list = {};
                foreach (@pd_langs) {
                        $list{uc $_}  = 0;
                }
		# avoid deprecated characters in anchors
		my $pkgid = $pkg;
	       	$pkgid =~ s/\+/plus/;

                if ($data->has_errors($pkg)) {
                        $podebconf_errors->{$pkg} = { charsetname => [], invalidpo => [], charset => [], missingfile => [], unknownlanguage => [], outofdatetemplate => [], outofdatepo => [] };
                        my $found = 0;
                        foreach my $error (@{$data->errors($pkg)}) {
				next unless ($error =~ /(podebconf|debian\/po\/)/);
                                if ($error =~ m/gettext: msgfmt: debian\/po\/([^.]+)\.po: warning: Charset (.*) is not a portable /) {
                                        push(@{$podebconf_errors->{$pkg}->{charsetname}}, "$1.po: $2");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{uc $1} = 1;
                                } elsif ($error =~ m/gettext: debian\/po\/([^.]+)\.po:\d+:\d+: parse error/) {
                                        push(@{$podebconf_errors->{$pkg}->{invalidpo}}, "$1.po");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{uc $1} = 1;
                                } elsif ($error =~ m/gettext: debian\/po\/([^.]+)\.po:\d+: `msgid' and `msgstr' entries/) {
                                        push(@{$podebconf_errors->{$pkg}->{invalidpo}}, "$1.po");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{uc $1} = 1;
                                } elsif ($error =~ m/gettext: debian\/po\/([^.]+)\.po:\d+:\d+: invalid multibyte sequence/) {
                                        push(@{$podebconf_errors->{$pkg}->{charset}}, "$1.po");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{uc $1} = 1;
#                                } elsif ($error =~ m/gettext: debian\/po\/([^.]+\.po): can't guess language/) {
#                                        push(@{$podebconf_errors->{$pkg}->{unknownlanguage}}, "$1");
#                                        $found = 1;
#                                        $podebconf_errors_by_language->{$pkg}->{global} = 1;
                                } elsif ($error =~ m/podebconf: file ([^ ]+) not found/) {
                                        push(@{$podebconf_errors->{$pkg}->{missingfile}}, "$1");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{global} = 1;
                                } elsif ($error =~ m/podebconf: file debian\/po\/templates\.pot not up-to-date/) {
                                        push(@{$podebconf_errors->{$pkg}->{outofdatetemplate}}, "templates.pot");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{global} = 1;
                                } elsif ($error =~ m/podebconf: file debian\/po\/([^.]+)\.po not up-to-date/) {
                                        push(@{$podebconf_errors->{$pkg}->{outofdatepo}}, "$1.po");
                                        $found = 1;
                                        $podebconf_errors_by_language->{$pkg}->{uc $1} = 1;
				}
                        }
                        delete $podebconf_errors->{$pkg} unless $found;
                }
                my $addorig = '';
                foreach $line (@{$data->podebconf($pkg)}) {
                        my ($pofile, $lang, $stat, $link) = @{$line};
                        next unless $lang eq '_';

                        $pofile =~ s#^debian/(po/)?##;
                        $link =~ s/:/\%3a/g;
                        $link =~ s/#/\%23/g;
                        $addorig .= " [<a href=\"".
                                ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root).
                                ($pofile eq 'templates.pot' ? 'po' : 'templates').
                                "/$opt_d/".$data->pooldir($pkg).
                                "/$link.gz\">$pofile</a>]";
                }
                $orig .= "<li><a name=\"$pkgid\" href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>$addorig</li>\n"
                        if $addorig;

                my $addtotal = 0;
                my $curtotal = 0;
                foreach $line (@{$data->podebconf($pkg)}) {
                        my ($pofile, $lang, $stat, $link,$translator) = @{$line};
                        if ($lang eq '_') {
                                if ($stat =~ m/(\d+)u/) {
                                        $addtotal += $1;
                                        $curtotal = $1;
                                }
                                next;
                        }
		    
                        $translator = transform_translator($translator);

                        $pofile =~ s#^debian/po/##;
                        $link =~ s/:/\%3a/g;
                        $link =~ s/#/\%23/g;
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
                        my $color = get_color(percent_stat($stat));
		        my $str = '';
                        $str .= "<tr style=\"background-color: $color\"><td>";
                        if ($stat =~ m/^(\d+)t(\d+)f(\d+)u$/) {
                                $score{$lang} += $1;
                        }
			if (defined $podebconf_errors_by_language->{$pkg}->{global}) {
			    $str .= "<a href=\"errors-by-pkg#P$pkg\">!</a>&nbsp;";
			} elsif (defined $podebconf_errors_by_language->{$pkg}->{$lang}) {
			    $str .= "<a href=\"errors-by-pkg#P$pkg\">!</a>&nbsp;";
			} else {
			    $str .= "&nbsp;&nbsp;";
			}
		        $str .= (percent_stat($stat) eq "100%" ? $pkg : "<a href=\"http://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>");
		        $str .= "</td><td>".show_stat($stat)."</td><td><a href=\"";
                        $str .= ($data->section($pkg) =~ m/non-US/ ? $rootnonus : $root) . "po/$opt_d/";
                        $str .= $data->pooldir($pkg)."/$link.gz\">$pofile</a></td>";
		        $str .= "<td>$translator</td>";
		    	if (percent_stat($stat) eq "100%") {
			  $str .= "</tr>\n";
			  if (   defined $podebconf_errors_by_language->{$pkg}->{global}
			      or defined $podebconf_errors_by_language->{$pkg}->{$lang}) {
			   $error{$lang}  = '' unless defined($error{$lang});
			   $error{$lang} .= $str;
			  } else {
                           $done{$lang}  = '' unless defined($done{$lang});
			   $done{$lang} .= $str;
			  }
 			} else {
			   if (defined $status_db{$lang}) {
			      my $add = "";
			      if (    $status_db{$lang}->has_package($pkg)
			          and $status_db{$lang}->has_status($pkg)) {
				 foreach my $statusline (@{$status_db{$lang}->status($pkg)}) {
				    my ($type, $file, $date, $status, $translator, $list, $url, $bug_nb) = @{$statusline};
				    my $bug_link = (defined $bug_nb) ? "<a href=\"http://bugs.debian.org/$bug_nb\">$bug_nb</a>" : "";
				    if ($type eq "podebconf") {
				       # Only keep the last status (most recent)
				       # Assume there is only one podebconf file
				       $date =~ s/\s*\+0000$//;
				       $list =~ /^(\d\d\d\d)-(\d\d)-(\d\d\d\d\d)$/;
				       $add = "<a href=\"http://lists.debian.org/debian-l10n-$LanguageList{$lang}/$1/debian-l10n-$LanguageList{$lang}-$1$2/msg$3.html\">$status</a>";
				       $add = "<td>$add</td><td>$translator</td><td>$date</td><td>$bug_link</td>";
				    }
				 }
			      }
			      unless (length $add) {
				   $add .= "<td></td><td></td><td></td><td></td>";
			      }
			      $str .= $add;
			   }
			   $str .= "</tr>\n";
                           $todo{$lang}  = '' unless defined($todo{$lang});
			   $todo{$lang} .= $str;
			}

                }
                $total{$section} += $addtotal;

                foreach $lang (@pd_langs) {
                        my $l = uc($lang) || 'UNKNOWN';
                        next if $list{$l};
			my $str;
			if (defined $podebconf_errors_by_language->{$pkg}->{global}) {
			    $str .= " (<a href=\"errors-by-pkg#P$pkg\">!</a>)";
			} elsif (defined $podebconf_errors_by_language->{$pkg}->{$lang}) {
			    $str .= " (<a href=\"errors-by-pkg#P$pkg\">!</a>)";
			}
                        $str .= "<a href=\"pot#$pkgid\">$pkg</a>";
			my $add = "";
			if (defined $status_db{$l}) {
			   if (    $status_db{$l}->has_package($pkg)
			       and $status_db{$l}->has_status($pkg)) {
			      foreach my $statusline (@{$status_db{$l}->status($pkg)}) {
				 my ($type, $file, $date, $status, $translator, $list, $url, $bug_nb) = @{$statusline};
				 my $bug_link = (defined $bug_nb) ? "<a href=\"http://bugs.debian.org/$bug_nb\">$bug_nb</a>" : "";
				 if ($type eq "podebconf") {
				    # Only keep the last status (most recent)
				    # Assume there is only one file with a
				    # podebconf type
				    $date =~ s/\s*\+0000$//;
				    $list =~ /^(\d\d\d\d)-(\d\d)-(\d\d\d\d\d)$/;
				    $add = "<a href=\"http://lists.debian.org/debian-l10n-$LanguageList{$l}/$1/debian-l10n-$LanguageList{$l}-$1$2/msg$3.html\">$status</a>";
				    $add = "<td>$add</td><td>$translator</td><td>$date</td><td>$bug_link</td>";
				 }
			      }
			   }
			   if (length $add) {
			      $str = "<td>$str</td><td>0\% (0t;0f;".$curtotal."u)</td><td></td><td></td>".$add;
			   }
			}
			if (length $add) {
				$excl_pending{$l}  = '' unless defined($excl_pending{$l});
				$excl_pending{$l} .= "<tr>$str</tr>\n";
			} else {
				$excl{$l}  = '' unless defined($excl{$l});
				$excl{$l} .= $str."&nbsp;($curtotal)";
				$excl{$l} .= ", ";
			}
		}
        }
        foreach $lang (@pd_langs) {
                next unless defined $todo{uc $lang} or defined $excl_pending{uc $lang};
                open (GEN, "> $opt_l/po-debconf/gen/$section-$lang.todo")
                        || die "Unable to write into $opt_l/po-debconf/gen/$section-$lang.todo";
                print GEN $todo{uc $lang} if defined $todo{uc $lang};
                print GEN $excl_pending{uc $lang} if defined $excl_pending{uc $lang};
                close (GEN);
        }
        foreach $lang (@pd_langs) {
                next unless defined $error{uc $lang};
                open (GEN, "> $opt_l/po-debconf/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/po-debconf/gen/$section-$lang.ok";
                print GEN $error{uc $lang};
                close (GEN);
        }
        foreach $lang (@pd_langs) {
                next unless defined $done{uc $lang};
                open (GEN, ">> $opt_l/po-debconf/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/po-debconf/gen/$section-$lang.ok";
                print GEN $done{uc $lang};
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
	open (GEN, "> $opt_l/po-debconf/gen/errors-by-pkg.$section.inc");
        foreach $pkg (sort keys %$podebconf_errors) {
                $maint = $data->maintainer($pkg);
                $maint =~ s/\s*<.*>//;
                $maint =~ s/&/&amp;/g;
	        my $anchor_maint = lc $maint;
                $anchor_maint =~ s/[^a-z0-9]/_/g;

                print GEN "<li><a name=\"P$pkg\">$pkg</a> ".$data->version($pkg)." [<a href=\"errors-by-maint#M$anchor_maint\">$maint</a>]\n";
                my $errors_pkg = "<ul>\n";
                if (@{$podebconf_errors->{$pkg}->{charsetname}}) {
                        $errors_pkg .= "<li><a href=\"errors#charsetname\">invalid-charset-name-in-po</a>\n";
			foreach my $error (@{$podebconf_errors->{$pkg}->{charsetname}}) {
			     $errors_pkg .= "<br>\n".$error."\n";
			}
			$errors_pkg .= "</li>\n";
                }
                if (@{$podebconf_errors->{$pkg}->{invalidpo}}) {
                        $errors_pkg .= "<li><a href=\"errors#invalidpo\">invalid-po</a><br>\n";
			foreach my $error (@{$podebconf_errors->{$pkg}->{invalidpo}}) {
			     $errors_pkg .= " $error";
			}
			$errors_pkg .= "</li>\n";
                }
                if (@{$podebconf_errors->{$pkg}->{charset}}) {
                        $errors_pkg .= "<li><a href=\"errors#charset\">wrong-charset</a><br>\n";
			foreach my $error (@{$podebconf_errors->{$pkg}->{charset}}) {
			     $errors_pkg .= " $error";
			}
			$errors_pkg .= "</li>\n";
                }
                if (@{$podebconf_errors->{$pkg}->{missingfile}}) {
                        $errors_pkg .= "<li><a href=\"errors#missingfile\">missing-file-in-POTFILES.in</a>\n";
			foreach my $error (@{$podebconf_errors->{$pkg}->{missingfile}}) {
			     $errors_pkg .= "<br>\n".$error."\n";
			}
			$errors_pkg .= "</li>\n";
                }
                if (@{$podebconf_errors->{$pkg}->{outofdatetemplate}}) {
                        $errors_pkg .= "<li><a href=\"errors#template\">not-up-to-date-templates.pot</a></li>\n";
                }
                if (@{$podebconf_errors->{$pkg}->{outofdatepo}}) {
                        $errors_pkg .= "<li><a href=\"errors#po\">not-up-to-date-po-file</a><br>\n";
			foreach my $error (@{$podebconf_errors->{$pkg}->{outofdatepo}}) {
			     $errors_pkg .= " $error";
			}
			$errors_pkg .= "</li>\n";
                }
                if (@{$podebconf_errors->{$pkg}->{unknownlanguage}}) {
                        $errors_pkg .= "<li><a href=\"errors#unknownlanguage\">unknown-language</a><br>\n";
			foreach my $error (@{$podebconf_errors->{$pkg}->{unknownlanguage}}) {
			     $errors_pkg .= " $error";
			}
			$errors_pkg .= "</li>\n";
                }
                $errors_pkg .= "</ul>\n";
                print GEN $errors_pkg;
                $podebconf_errors_maint->{$maint} = {} unless defined($podebconf_errors_maint->{$maint});
                $podebconf_errors_maint->{$maint}->{$pkg} = "$pkg ".$data->version($pkg)."\n".$errors_pkg;
        }
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
        print GEN "<ul>\n";
        my $str_total = $total{main}+$total{contrib}+$total{'non-free'};
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @pd_langs) {
                print GEN "<li><strong><a href=\"$lang\">$lang</a> ".$score{uc $lang}.
                        " (".podebconf_stats_ranking($score{uc $lang}, $str_total),
                        "\%)</strong> &ndash;\n";
                print GEN "<language-name $lang /></li>\n";
        }
        print GEN "</ul>\n";
        open (GEN, "> $opt_l/po-debconf/gen/errors-by-maint.inc");
        foreach my $maint (sort keys %$podebconf_errors_maint) {
                my $anchor_maint = lc $maint;
                $anchor_maint =~ s/[^a-z0-9]/_/g;
                $anchor_maint =~ s/&/&amp;/g;
                print GEN "<li><a name=\"M$anchor_maint\">$maint</a>\n<ul>";
                foreach my $pkg (sort keys %{$podebconf_errors_maint->{$maint}}) {
                        print GEN "<li>".$podebconf_errors_maint->{$maint}->{$pkg}."</li>\n";
                }
                print GEN "</ul></li>\n";
        }
        close (GEN);
        open (GEN, "> $opt_l/po-debconf/gen/total")
                || die "Unable to write into $opt_l/po-debconf/gen/total";
        print GEN "<define-tag podebconf-total-strings>$str_total</define-tag>\n";
        close (GEN);
        open (GEN, "> $opt_l/po-debconf/gen/stats")
                || die "Unable to write into $opt_l/po-debconf/gen/stats";
        foreach my $lang (@pd_langs) {
	            print GEN "$lang:".$score{uc $lang}."\n";
	        }
        close (GEN);
}

sub process_langs {
        my $langs = {
                po              => {},
                po4a            => {},
                templates       => {},
                podebconf       => {},
                all             => {},
        };

        my ($pkg, $line, $file, $lang);
        foreach $pkg ($data->list_packages()) {
                if ($data->has_po4a($pkg)) {
                        foreach $line (@{$data->po4a($pkg)}) {
                                ($file, $lang) = @{$line};
                                next unless $lang ne '' && $lang ne '_';
                                $langs->{po4a}->{$lang}  = 1;
                                $langs->{all}->{$lang} = 1;
                        }
                }
                if ($data->has_po($pkg) && !defined($skip_po{$pkg})) {
                        foreach $line (@{$data->po($pkg)}) {
                                ($file, $lang) = @{$line};
                                next unless $lang ne '' && $lang ne '_';
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
        @p4_langs = keys %{$langs->{po4a}};
        @po_langs = keys %{$langs->{po}};
        @td_langs = keys %{$langs->{templates}};
        @pd_langs = keys %{$langs->{podebconf}};
	@al_langs = keys %{$langs->{all}};
}

sub write_langs {
        open (GEN, "> $opt_l/data/langs")
                || die "Unable to write into $opt_l/data/langs";
	print GEN 'all: '	. join(' ', sort @al_langs) . "\n";
	print GEN 'po: '	. join(' ', sort @po_langs) . "\n";
	print GEN 'po4a: '	. join(' ', sort @p4_langs) . "\n";
	print GEN 'podebconf: '	. join(' ', sort @pd_langs) . "\n";
	print GEN 'templates: '	. join(' ', sort @td_langs) . "\n";
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

process_langs();
process_po4a()      if $opt_M;
process_po()        if $opt_P;
process_templates() if $opt_T;
process_podebconf() if $opt_D;
write_langs()       if $opt_L;
1;
