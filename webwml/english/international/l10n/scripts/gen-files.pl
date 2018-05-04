#! /usr/bin/perl -w

use strict;
use File::Path;
use Getopt::Long;

use lib ($0 =~ m|(.*)/|, $1 or ".") ."/../../../../Perl";

use Debian::L10n::Db ('%LanguageList');

use vars qw($opt_h $opt_d $opt_l $opt_s $opt_D $opt_P $opt_T $opt_L $opt_M);

sub usage {
        print "Usage:  gen-files.pl [--dist=DIST] [--l10ndir=DIR] [--sort=FILE] [--po] [--podebconf] [--langs] [--po4a]\n";
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
        L|langs
        M|po4a
        ))) {
        usage(1);
}
usage(0) if $opt_h;

my $data = Debian::L10n::Db->new();
$data->read("$opt_l/data/$opt_d");
my $date = $data->get_date();
my %popcon = ();
if ($opt_s ne '' && -r $opt_s && open (POPCON, "< $opt_s")) {
        #  This file is in the same format as
        #    https://popcon.debian.org/source/by_inst
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

my $root = 'https://i18n.debian.org/material/';

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
        if ($section =~ m#^contrib/#) {
                push (@contrib, $pkg);
        } elsif ($section =~ m#^non-free/#) {
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
        # BREAK PERMITTED HERE (U+0082) is allowed in HTML 4.01. 
        # but the "tidy" tool that we use complains about them,
        # so we just remove those characters for now, until better solution
        # see Bug #820119
        $name =~ s/(?:&#0*130;|&#x0*82;|\N{U+0082})//ig;
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

sub linklist {
	my ($typo, $pkg, $lang, $trufile, %status_db) = @_;
	my $add = "";
	if (    $status_db{$lang}->has_package($pkg)
	    and $status_db{$lang}->has_status($pkg)) {
		foreach my $statusline (@{$status_db{$lang}->status($pkg)}) {
			my ($type, $file, $date, $status, $translator, $list, $url, $bug_nb) = @{$statusline};
			my $bug_link = (defined $bug_nb) ? "<a href=\"https://bugs.debian.org/$bug_nb\">$bug_nb</a>" : "";
			if ($type eq $typo and ($pkg ne 'manpages-fr-extra' or $file eq $trufile)) {
				# Only keep the last status (most recent)
				# Assume there is only one $typo file
				# unless $pkg is manpages-fr-extra
				$date =~ s/\s*\+0000$//;
				$list =~ /^(\d\d\d\d)-(\d\d)-(\d\d\d\d\d)$/;
				$add = "<a href=\"https://lists.debian.org/debian-l10n-$LanguageList{$lang}/$1/debian-l10n-$LanguageList{$lang}-$1$2/msg$3.html\">$status</a>";
				$add = "<td>$add</td><td>$translator</td><td>$date</td><td>$bug_link</td>";
			}
		}
	}
	return $add;
}

sub get_stats {
        my ($type, $section, $packages) = @_;
        my ($pkg, $line, $lang, %list);
	my $typo = ($type eq 'po-debconf') ? 'podebconf' : $type;

        my %done  = ();
        my %todo  = ();
	my %todol = ();
        my %excl  = ();
	my %ref   = ();
        my $none  = '';
        my $orig  = '';

	# The following are only useful for po-debconf
	my $maint;
	my %error = ();
	my %excl_pending  = ();
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

	my @langs;
	@langs = @p4_langs if ($type eq 'po4a');
	@langs = @po_langs if ($type eq 'po');
	@langs = @pd_langs if ($type eq 'po-debconf');

        $total{$section} = 0;
        foreach $pkg (sort pkgsort @{$packages}) {
		my $has='has_'.$typo;
                unless ($data->$has($pkg)) {
                        $none .= "<li>".$pkg."</li>\n";
                        next;
                }
		next if ($type eq 'po' and defined $skip_po{$pkg});
                my $list = {};
                foreach (@langs) {
                        $list{uc $_}  = 0;
                }

		# avoid deprecated characters in anchors
		my $pkgid = $pkg;
		$pkgid =~ s/\+/plus/;
		$pkgid =~ s/^\d/p_$&/;

		if ($type eq 'po-debconf' and $data->has_errors($pkg)) {
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
		my $curtotal = 0;
                foreach $line (@{$data->$typo($pkg)}) {
                        my ($file, $lang, $stat, $link, $translator, $team) = @{$line};

			$file =~ s#^debian/(po/)?## if $type eq 'po-debconf';
                        $link =~ s/:/\%3a/g;
                        $link =~ s/#/\%23/g;
			$link =~ s/ /\%20/g;
                        $translator = transform_translator($translator);
                        $team = transform_team($team);
                        if ($lang eq '_') {
                                if ($stat =~ m/(\d+)u/) {
                                        $total{$section} += $1;
					$curtotal = $1;
                                }
				if (($file eq 'templates.pot') or ($type ne 'po-debconf')) {
	                                $addorig .= " [<a href=\"".$root.'po'.
					"/$opt_d/".$data->pooldir($pkg).
                                        "/$link.gz\">$file</a>]";
				}
                                next;
                        }
                        $lang = uc($lang) || 'UNKNOWN';
                        $list{$lang} = 1;
		        my $str= '';
                        $str .= "<tr style=\"background-color: ".
                              get_color(percent_stat($stat)).
                              "\"><td>";

			if ($stat =~ m/(\d+)t/) {
				$score{$lang} += $1;
			}
		      if ($type eq 'po-debconf'){
			if (defined $podebconf_errors_by_language->{$pkg}->{global}) {
				$str .= "<a href=\"errors-by-pkg#P$pkg\">!</a>&nbsp;";
			} elsif (defined $podebconf_errors_by_language->{$pkg}->{$lang}) {
				$str .= "<a href=\"errors-by-pkg#P$pkg\">!</a>&nbsp;";
			} else {
				$str .= "&nbsp;&nbsp;";
			}
		      }

		        $str .= (percent_stat($stat) eq "100%" ? $pkg : "<a href=\"https://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>");
		        $str .= "</td><td>".show_stat($stat)."</td><td><a ";
			if (! $ref{"$lang:$pkg"}){
				$str .= "name=\"$pkgid\" ";
				$ref{"$lang:$pkg"} = 1;
			}
		       	$str .= "href=\"";
                        $str .= $root . "po/$opt_d/";
                        $str .= $data->pooldir($pkg)."/$link.gz\">$file</a></td>";
		        $str .= "<td>$translator</td>";
			if (percent_stat($stat) eq "100%") {
				$str .= "<td>$team</td>" if ($type ne 'po-debconf');
				$str .= "</tr>\n";
				if ($type eq 'po-debconf'
				    and (defined $podebconf_errors_by_language->{$pkg}->{global}
				      or defined $podebconf_errors_by_language->{$pkg}->{$lang})) {
					$error{$lang} = ($error{$lang}  || '') . $str; # avoid warning when concatening
				} else {
					$done{$lang} = ($done{$lang} || '') . $str;
				}
			} else {
				my $add = "";
				if (defined $status_db{$lang} and (($type eq 'po-debconf') or ($team eq "debian-l10n-$LanguageList{$lang} at lists dot debian dot org"))) {
					$add = linklist($typo, $pkg, $lang, $file, %status_db);
					unless (length $add) {
						$add .= "<td></td><td></td><td></td><td></td>";
					}
					$str .= $add;
					$todol{$lang} = ($todol{$lang} || '') . $str . "</tr>\n" if ($type ne 'po-debconf') ;

				}
				else {
					$str .= "<td>$team</td>" if ($type ne 'po-debconf');
				}
				$todo{$lang} = ($todo{$lang} || '') . $str . "</tr>\n" if ($type eq 'po-debconf' or !length $add);
			}
                }
                $orig .= "<li><a name=\"$pkgid\" href=\"https://bugs.debian.org/cgi-bin/pkgreport.cgi?which=src&amp;data=$pkg\">$pkg</a>$addorig</li>\n"
                        if $addorig;
                foreach $lang (@langs) {
                        my $l = uc($lang) || 'UNKNOWN';
                        next if $list{$l};
			my $str;
		      if ($type eq 'po-debconf'){
			if (defined $podebconf_errors_by_language->{$pkg}->{global}) {
				$str .= " (<a href=\"errors-by-pkg#P$pkg\">!</a>)";
			} elsif (defined $podebconf_errors_by_language->{$pkg}->{$lang}) {
				$str .= " (<a href=\"errors-by-pkg#P$pkg\">!</a>)";
			}
		      }
			$str .= ($curtotal eq '0') ? $pkg : "<a href=\"pot#$pkgid\">$pkg</a>";
			my $add = "";
			if (defined $status_db{$l}) {
				$add = linklist($typo, $pkg, $l, '', %status_db);
				if (length $add) {
					$str  = "&nbsp;&nbsp;$str" if $type eq 'po-debconf';
					$str  = "<td>$str</td><td>";
					$str .= "0\% (0t;0f;".$curtotal."u)" if ($curtotal ne '0');
					$str .= "</td><td></td><td></td>".$add;
				}
			}
			if (length $add) {
				$excl_pending{$l} = ($excl_pending{$l} || '') . "<tr style=\"background-color: #ccc\">$str</tr>\n";
			} else {
				$excl{$l}  = ($excl{$l} || '') . $str;
				$excl{$l} .= "&nbsp;($curtotal)" if ($curtotal ne '0');
				$excl{$l} .= ", ";
			}
                }
        }
      if ($type eq 'po-debconf'){
	foreach $lang (@langs) {
		next unless defined $error{uc $lang};
		open (GEN, "> $opt_l/$type/gen/$section-$lang.ok")
			|| die "Unable to write into $opt_l/$type/gen/$section-$lang.ok";
		print GEN $error{uc $lang};
		close (GEN);
	}
      }
        foreach $lang (@langs) {
                next unless defined $done{uc $lang};
                open (GEN, ">> $opt_l/$type/gen/$section-$lang.ok")
                        || die "Unable to write into $opt_l/$type/gen/$section-$lang.ok";
                print GEN $done{uc $lang};
                close (GEN);
        }
        foreach $lang (@langs) {
                next unless defined $todo{uc $lang} or ($type eq 'po-debconf' and defined $excl_pending{uc $lang});
                open (GEN, "> $opt_l/$type/gen/$section-$lang.todo")
                        || die "Unable to write into $opt_l/$type/gen/$section-$lang.todo";
                print GEN $todo{uc $lang} if defined $todo{uc $lang};
		print GEN $excl_pending{uc $lang} if $type eq 'po-debconf' and defined $excl_pending{uc $lang};
                close (GEN);
        }
	foreach $lang (@langs) {
		next unless defined $todol{uc $lang} or ($type ne 'po-debconf' and defined $excl_pending{uc $lang});
		open (GEN, "> $opt_l/$type/gen/$section-$lang.todol")
			|| die "Unable to write into $opt_l/$type/gen/$section-$lang.todol";
		print GEN $todol{uc $lang} if defined $todol{uc $lang};
		print GEN $excl_pending{uc $lang} if $type ne 'po-debconf' and defined $excl_pending{uc $lang};
		close (GEN);
	}
        foreach $lang (@langs) {
                next unless defined $excl{uc $lang};
                $excl{uc $lang} =~ s/, $//s;
                open (GEN, "> $opt_l/$type/gen/$section-$lang.exc")
                        || die "Unable to write into $opt_l/$type/gen/$section-$lang.exc";
                print GEN "<p>\n".$excl{uc $lang}."</p>\n";
                close (GEN);
        }
      if ($type ne 'po-debconf'){
        open (GEN, "> $opt_l/$type/gen/$section.exc")
                || die "Unable to write into $opt_l/$type/gen/$section.exc";
        print GEN "<ul>\n".$none."</ul>\n" if $none ne '';
        close (GEN);
      }
        open (GEN, "> $opt_l/$type/gen/$section.orig")
                || die "Unable to write into $opt_l/$type/gen/$section.orig";
        print GEN "<ul>\n".$orig."</ul>\n" if $orig ne '';
        close (GEN);
      if ($type eq 'po-debconf'){
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
}

sub process {
	my ($type) = @_;
	my $typo = ($type eq 'po-debconf' ? 'podebconf' : $type);
        -d "$opt_l/$type/gen" || File::Path::mkpath("$opt_l/$type/gen", 0, 0775);

	my @langs;                      
	@langs = @p4_langs if ($type eq 'po4a');
	@langs = @po_langs if ($type eq 'po');
	@langs = @pd_langs if ($type eq 'po-debconf');

        foreach (@langs) {
                $score{uc $_} = 0;
        }

        get_stats($type, 'main', \@main);
        get_stats($type, 'contrib', \@contrib);
        get_stats($type, 'non-free', \@nonfree);

	# Rule out languages with no string translated
	# Only useful for po: lots of empty files there
      if ($type eq 'po'){
	my @langs_notempty;
	foreach (@langs) {
		if ($score{uc $_} != 0) {
			push @langs_notempty,$_;
		}
		else {
			unlink("$opt_l/$type/gen/main-$_.exc")
				|| warn ("Unable to delete main-$_.exc - $!\n");
			unlink("$opt_l/$type/gen/contrib-$_.exc")
				|| warn ("Unable to delete contrib-$_.exc - $!\n");
			unlink("$opt_l/$type/gen/non-free-$_.exc")
				|| warn ("Unable to delete non-free-$_.exc - $!\n");
		}
	}
	# @po_langs must be updated since it's used in write_langs
	@po_langs = @langs_notempty;
	@langs = @langs_notempty;
      }

        open (GEN, "> $opt_l/$type/gen/rank.inc")
                || die "Unable to write into $opt_l/$type/gen/rank.inc";
        print GEN "<ul>\n";
	my $str_total = $total{main}+$total{contrib}+$total{'non-free'};
        foreach my $lang (sort {$score{uc $b} <=> $score{uc $a}} @langs) {
                print GEN "<li><strong><a href=\"$lang\">$lang</a> ".$score{uc $lang}.
                          " (".podebconf_stats_ranking($score{uc $lang}, $str_total),
                          "\%)</strong> &ndash;\n";
                print GEN "<language-name $lang /></li>\n";
        }
        print GEN "</ul>\n";
        close (GEN);
	# the following is only used for po-debconf
      if ($type eq 'po-debconf'){
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
      }
        open (GEN, "> $opt_l/$type/gen/total")
                || die "Unable to write into $opt_l/$type/gen/total";
        print GEN "<define-tag $typo-total-strings>$str_total</define-tag>\n";
        close (GEN);
        open (GEN, "> $opt_l/$type/gen/stats")
                || die "Unable to write into $opt_l/$type/gen/stats";
        foreach my $lang (@langs) {
	            print GEN "$lang:".$score{uc $lang}."\n" if defined ($score{uc $lang});
	        }
        close (GEN);
}

sub podebconf_stats_ranking {
        my $this = shift;
        my $total = shift;
        return 0 if $total == 0;
        return sprintf "\%d", 100 * $this / $total;
}

sub process_langs {
        my $langs = {
                po              => {},
                po4a            => {},
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
        @pd_langs = keys %{$langs->{podebconf}};
	@al_langs = keys %{$langs->{all}};
}

sub write_langs {
        open (GEN, "> $langfile")
                || die "Unable to write into $langfile";
	print GEN 'all: '	. join(' ', sort @al_langs) . "\n";
	print GEN 'po: '	. join(' ', sort @po_langs) . "\n";
	print GEN 'po4a: '	. join(' ', sort @p4_langs) . "\n";
	print GEN 'podebconf: '	. join(' ', sort @pd_langs) . "\n";
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
process('po4a')     if $opt_M;
process('po')       if $opt_P;
process('po-debconf') if $opt_D;
write_langs()       if $opt_L;
1;
