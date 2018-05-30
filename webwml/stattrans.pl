#! /usr/bin/perl

#   webwml-stattrans - Debian web site translation statistics
#   Copyright (c) 2001  Martin Schulze <joey@debian.org> and others

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.

use POSIX qw(strftime);
use Getopt::Std;

#    These modules reside under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
#use Local::Cvsinfo;
use Local::VCS ':all';
use Webwml::Langs;
use Webwml::TransCheck;
use Webwml::TransIgnore;
use Debian::L10n::Db ('%LanguageList');
use Net::Domain qw(hostfqdn);
use Data::Dumper;
use JSON;

$| = 1;

$opt_h = "/srv/www.debian.org/webwml/english/devel/website/stats";
$opt_w = "/srv/www.debian.org/webwml";
$opt_p = "*.(wml|src)";
$opt_t = '<stats_title>';
$opt_v = 0;
$opt_d = "u";
$opt_l = undef;
$opt_b = ""; # Base URL, if not debian.org
# path of web stats JSON data
$opt_f = "/srv/www.debian.org/webwml/stats.json";
getopts('h:w:b:p:t:vd:l:f:') || die;
#  Replace filename globbing by Perl regexps
$opt_p =~ s/\./\\./g;
$opt_p =~ s/\?/./g;
$opt_p =~ s/\*/.*/g;
$opt_p =~ s/$/\$/g;
%config = (
	   'htmldir' => $opt_h,
	   'wmldir'  => $opt_w,
	   'wmlpat'  => $opt_p,
	   'title'   => $opt_t,
	   'verbose' => $opt_v,
	   'difftype'=> $opt_d,
           'hit_file'=> $opt_f,
	   );

my $VCSHOST = "salsa";
my $VCSBASE = "https://salsa.debian.org/webmaster-team/webwml/test_webwml_cvs2git";
if (-d "$config{'wmldir'}/CVS") {
    $VCSHOST = "alioth";
    $VCSBASE = "https://anonscm.debian.org/viewvc/webwml/webwml";
}

my $l = Webwml::Langs->new($opt_w);
my %langs = $l->name_iso();
my $VCS = Local::VCS->new();
$VCS->cache_repo();

my $transignore = Webwml::TransIgnore->new($opt_w);

chdir($config{'wmldir'}) or die "Can't chdir to $config{'wmldir'}: $!\n";

#my $cvs = Local::Cvsinfo->new();
#$cvs->options(
#        recursive => 1,
#        matchfile => [ $config{'wmlpat'} ],
#        skipdir   => [ "template" ],
#);
#$cvs->readinfo("$config{'wmldir'}/english");
my %rev_info = $VCS->path_info("english",
			     'recursive' => 1,
			     'match_pat' => $config{'wmlpat'},
			     'skip_pat'  => "(template|/devel/website/stats/)");
my $cnt = scalar(keys %rev_info);
#print "found $cnt english files using wmlpat $config{'wmlpat'}\n";
foreach (@{$transignore->global()}) {
#        $cvs->removefile("$config{'wmldir'}/english/$_");
	delete $rev_info{"english/$_"};
}

#print "found $cnt english files\n";

#y $altcvs = Local::Cvsinfo->new();
#altcvs->options(
#       recursive => 1,
#       matchfile => [ $config{'wmlpat'} ],
#       skipdir   => [ "template" ],
#;

$max_versions = 5;
$min_versions = 1;

$date = strftime "%a %b %e %H:%M:%S %Y %z", localtime;

my %original;
my %transversion;
my %version;
my %files;
my %sizes;

print "Loading the coordination status databases\n" if ($config{verbose});
my %status_db = ();
opendir (DATADIR, "english/international/l10n/data")
	or die "Cannot open directory english/international/l10n/data: $!\n";
foreach (readdir (DATADIR)) {
	# Only check the status files
	next unless ($_ =~ m/^status\.(.*)$/);
	my $l = $1;
	next if (!defined $LanguageList{uc $l});
	if (-r "english/international/l10n/data/status.$l") {
		$status_db{$LanguageList{uc $l}} = Debian::L10n::Db->new();
		$status_db{$LanguageList{uc $l}}->read("english/international/l10n/data/status.$l", 0);
	}
}
closedir (DATADIR);

sub linklist {
	my ($file, $lang) = @_;
	my $add = "";
	if ($status_db{$lang}->has_package('www.debian.org')
	and $status_db{$lang}->has_status('www.debian.org')) {
		foreach my $statusline (@{$status_db{$lang}->status('www.debian.org')}) {
			my ($type, $statfile, $date, $status, $translator, $list, $url, $bug_nb) = @{$statusline};
			if ($file eq $statfile) {
				$date =~ s/\s*\+0000$//;
				$list =~ /^(\d\d\d\d)-(\d\d)-(\d\d\d\d\d)$/;
				$add = "<a href=\"https://lists.debian.org/debian-l10n-$lang/$1/debian-l10n-$lang-$1$2/msg$3.html\">$status</a>";
				$add = "<td>$add</td><td>$translator</td><td>$date</td>";
			}
		}
	}
	$add = '<td></td><td></td><td></td>' if (!length $add);
	return $add;
}

# Count wml files in given directory
#
sub getwmlfiles
{
    my $lang = shift;
    my $dir = "$lang";
#    my $cutfrom = length ($config{'wmldir'})+length($lang)+2;
    my $count = 0;
    my $size = 0;
    my $is_english = ($lang eq "english")?1:0;
    my ( $file, $v );
    my @listfiles;
    my %altrev_info;

    if (! -d "$dir") {
      print "$0: can't find $dir! Skipping ...\n";
      return;
    }
    if ($is_english) {
#        @listfiles = @{$cvs->files()};
        @listfiles = sort keys(%rev_info);
    } else {
	%altrev_info = $VCS->path_info($dir,
				       'recursive' => 1,
				       'match_pat' => $config{'wmlpat'},
				       'skip_pat'  => "template");
        @listfiles = sort keys(%altrev_info);
#        $altcvs->reset();
#        $altcvs->readinfo($dir);
#        @listfiles = @{$altcvs->files()};
    }
#    print "cutfrom is $cutfrom\n";
#    print "Looking at @listfiles\n";
#    open (LIST, ">$config{'htmldir'}/$lang.list")
#	|| die "Can't open $config{'htmldir'}/$lang.list";
    foreach my $file (@listfiles) {
#	print LIST "$file\n";
#	$file = substr ($f, $cutfrom);
#	print "looking at $file\n";
	next if $transignore->is_global($file);
	$files{$file} = 1;
	$wmlfiles{$lang} .= " " . $file;
	my $transcheck = Webwml::TransCheck->new("$dir/$file");
	if ($transcheck->revision()) {
	    $transversion{"$lang/$file"} = $transcheck->revision();
	    $original{"$lang/$file"} ||= $transcheck->original();
	}
	if ($is_english) {
	    #$version{"$lang/$file"} = $cvs->revision($f);
	    $version{"$lang/$file"} = $rev_info{"$file"}{'cmt_rev'};
	} else {
	    $version{"$lang/$file"} = $altrev_info{"$file"}{'cmt_rev'};
#	    $version{"$lang/$file"} = $altcvs->revision($f);
	    if (!$transcheck->revision()) {
	        $transcheckenglish = Webwml::TransCheck->new("english/$file");
		if (!$transcheckenglish->revision() and (-e "english/$file")) {
		    $transversion{"$lang/$file"} = $VCS->get_oldest_revision("english/$file");
		    $original{"$lang/$file"} = "english";
		} else {
		    $original{"english/$file"} = $lang;
		    $transversion{"english/$file"} = $VCS->get_oldest_revision("$lang/$file");
		}
	    }
	}
	if ($transcheck->maintainer()) {
	    # Escape HTML special characters to make the resulting page valid.
	    # This is needed for maintainers who use their e-mail address
	    # within angle brackets.
	    my %_escape_table = (
		'&' => '&amp;', '>' => '&gt;', '<' => '&lt;',
		q{"} => '&quot;', q{'} => '&#39;',
		q{`} => '&#96;', '{' => '&#123;',
		'}' => '&#125;'
	    );
	    $maintainer{"$lang/$file"} = $transcheck->maintainer();
	    $maintainer{"$lang/$file"} =~ s/([&><"'`{}])/$_escape_table{$1}/ge;
	}
	$count++;
	$sizes{$file} = (stat "".($original{"english/$file"}||"english")."/".$file)[7];
	$size += $sizes{$file};
    }
#    close LIST;
    $wmlfiles{$lang} .= " ";
    $wml{$lang} = $count;
    $wml_s{$lang} = $size;
    if ($config{verbose}) {
	print "  $lang: $count wml files, $size bytes\n";
    }
}

sub get_color
{
    my $percent = shift;

    if ($percent < 50) {
    	return sprintf ("#FF%02x00", (255/50) * $percent);
    } else {
	return sprintf ("#%02xFF00", (255/50) * (100 - $percent));
    }
}

sub check_translation
{
    my ($translation, $version, $file, $orig_file) = @_;

    my ( @version_numbers, $major_number, $last_number );
#    print "  check_translation: looking at translation $translation, english version $version, file $file, orig_file $orig_file\n";

    if ( $version && $translation ) {
	# Here we compare the original version with the translated one and print
	# a note for the user if their first or last numbers are too far apart
	# From translation-check.wml
	my $version_diff = $VCS->count_changes($orig_file, $version, $translation);
	if (!defined $version_diff) {
	    print "check_translation: error from count_changes for orig_file $orig_file, file $file\n";
	} else {
	    if ($version_diff < 0) {
		return '<gettext domain="stats">Wrong translation version</gettext>';
	    } elsif ( $version_diff >= $max_versions ) {
		return '<gettext domain="stats">This translation is too out of date</gettext>';		
	    } elsif ( $version_diff >= $min_versions ) {
		return '<gettext domain="stats">The original is newer than this translation</gettext>';
	    }
	}
    } elsif ( !$version && $translation) {
	return '<gettext domain="stats">The original no longer exists</gettext>';
    }
    return "";
}

print "Collecting data:\n" if ($config{'verbose'});
if ($opt_l) {
  getwmlfiles ($opt_l);
  getwmlfiles ('english');
} else {
  foreach $lang (sort keys %langs) {
    getwmlfiles ($lang);
  }
}
print "\n" if ($config{'verbose'});

my @search_in;
if ($opt_l) {
  @search_in = ( 'english', $opt_l );
} else {
  @search_in = sort keys %langs;
}

# Compute stats about gettext files
print "Computing statistics in gettext files... " if ($config{'verbose'});
my ( %po_translated, %po_fuzzy, %po_untranslated, %po_total );
my ( %percent_po_t, %percent_po_u, %percent_po_f );
foreach $lang (@search_in) {
    next if $lang eq 'english';
    $po_translated{"total"}{$lang} = $po_fuzzy{"total"}{$lang} = $po_untranslated{"total"}{$lang} = 0;
    $percent_po_t{'total'}{$lang} = 0;
    $percent_po_f{'total'}{$lang} = 0;
    $percent_po_u{'total'}{$lang} = 100;
    if (! -d "$lang/po") {
      print "$0: can't find $lang/po! Skipping ...\n";
      next;
    }
    my @status = qx,LC_ALL=C make -C $lang/po stats 2>&1,;
    foreach $line (@status) {
        chomp $line;
        next if($line =~ /make: (Enter|Leav)ing directory/);
        ($domain = $line) =~ s/\..*//;
        $po_translated{$domain}{$lang} = ($line =~ /(\d+) translated/ ? $1 : "0");
        $po_fuzzy{$domain}{$lang} = ($line =~ /(\d+) fuzzy/ ? $1 : "0");
        $po_untranslated{$domain}{$lang} = ($line =~ /(\d+) untranslated/ ? $1 : "0");

        $po_total{$domain} = $po_translated{$domain}{$lang} + $po_fuzzy{$domain}{$lang} + $po_untranslated{$domain}{$lang};

        $po_translated{"total"}{$lang} += $po_translated{$domain}{$lang};
	$po_fuzzy{"total"}{$lang} += $po_fuzzy{$domain}{$lang};
	$po_untranslated{"total"}{$lang} += $po_untranslated{$domain}{$lang};

        if ($po_total{$domain} > 0) {
            $percent_po_t{$domain}{$lang} = int ($po_translated{$domain}{$lang}/$po_total{$domain} * 100 + .5);
            $percent_po_f{$domain}{$lang} = int ($po_fuzzy{$domain}{$lang}/$po_total{$domain} * 100 + .5);
            $percent_po_u{$domain}{$lang} = int ($po_untranslated{$domain}{$lang}/$po_total{$domain} * 100 + .5);
        } else {
            $percent_po_t{$domain}{$lang} = 0;
            $percent_po_f{$domain}{$lang} = 0;
            $percent_po_u{$domain}{$lang} = 0; # or 100 if po/ doesn't exist
        }
    }
    $po_total{"total"} = $po_translated{"total"}{$lang} + $po_fuzzy{"total"}{$lang} + $po_untranslated{"total"}{$lang};

    if ($po_total{'total'} > 0) {
	$percent_po_t{'total'}{$lang} = int ($po_translated{'total'}{$lang}/$po_total{'total'} * 100 + .5);
	$percent_po_f{'total'}{$lang} = int ($po_fuzzy{'total'}{$lang}/$po_total{'total'} * 100 + .5);
	$percent_po_u{'total'}{$lang} = int ($po_untranslated{'total'}{$lang}/$po_total{'total'} * 100 + .5);
    }
}
print "done.\n" if ($config{'verbose'});

# =============== Create HTML files ===============
mkdir ($config{'htmldir'}, 02775) if (! -d $config{'htmldir'});

# Read website hit statistics, if available
my %hits;
my $file_sorter = sub($$) { $_[0] cmp $_[1] };
if ($config{'hit_file'}) {
    printf("Retrieving hit data from [%s].\n", $config{'hit_file'}) if ($config{'verbose'});
    open( my $fh, '<', $config{'hit_file'} );
    local $/;
    my $json = <$fh>;
    close $fh;
    if ($json) {
        my $perl = JSON::from_json($json, {utf8 => 1});
        foreach my $e (@{$perl}) {
            my ($count, $url) = @$e;
            last if $count < 3; # URLS with 2 or 1 hits are most likely mistakes; let's not waste RAM on them
            $hits{substr($url, 1)} = $count;
        }
    }
    if (%hits) {
        $file_sorter = sub($$) {
            my ($a, $b) = @_;
            $a =~ s/\.wml$//o;
            $b =~ s/\.wml$//o;
            $hits{$b} <=> $hits{$a}
        };
    } else {
        print "Tables will be sorted alphabetically.\n" if ($config{'verbose'});
    }
} else {
    print "No hit file specified. Tables will be sorted alphabetically.\n" if ($config{'verbose'});
}

my @filenames = sort $file_sorter keys %files;
my $nfiles = scalar @filenames;
$nsize += $sizes{$_} foreach (@filenames);

# 'u' == 'unidiff', 'h' == 'colored diff'
my $firstdifftype;
my $seconddifftype;
if ($config{'difftype'} eq 'u') {
    $firstdifftype = 'u';
    $seconddifftype = 'h';
} else {
    $firstdifftype = 'h';
    $seconddifftype = 'u';
}

sub vcs_log_url {
    my ($path) = @_;

    if ($VCSHOST == "alioth") {
	return "$VCSBASE/$path";
    } elsif ($VCSHOST == "salsa") {
	return "$VCSBASE/commits/master/$path";
    } else {
	die "Unknown/unsupported VCSHOST $VCSHOST - ABORT\n";
    }
}

sub vcs_diff_url {
    my ( $path, $r1, $r2, $diff_format ) = @_;

    if ($VCSHOST == "alioth") {
	return "$VCSBASE/$path/?r1=$r1&amp;r2=$r2&amp;diff_format=$diff_format";
    } elsif ($VCSHOST == "salsa") {
	return "$VCSBASE/BROKEN_DIFF_SUPPORT_FIXME/$path";
    } else {
	die "Unknown/unsupported VCSHOST $VCSHOST - ABORT\n";
    }
}

sub vcs_view_url {
    my ($path) = @_;

    if ($VCSHOST == "alioth") {
	return "$VCSBASE/$path?view=markup";
    } elsif ($VCSHOST == "salsa") {
	return "$VCSBASE/blob/master/$path";
    } else {
	die "Unknown/unsupported VCSHOST $VCSHOST - ABORT\n";
    }
}

sub vcs_raw_url {
    my ($path) = @_;

    if ($VCSHOST == "alioth") {
	return "$VCSBASE/$path?view=co";
    } elsif ($VCSHOST == "salsa") {
	return "$VCSBASE/raw/master/$path";
    } else {
	die "Unknown/unsupported VCSHOST $VCSHOST - ABORT\n";
    }
}

print "Creating files: " if ($config{'verbose'});
foreach $lang (@search_in) {
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
        print "$l.wml " if ($config{'verbose'});
        $t_body = $u_body = $ui_body = $un_body = $uu_body = $o_body = "";
        $translated{$lang} = $outdated{$lang} = $untranslated{$lang} = 0;

        # get stats about files
        foreach $file (@filenames) {
            next if ($file eq "");
            (my $base = $file) =~ s/\.wml$//;
            my $hits = exists $hits{$base} ? $hits{$base}.' <gettext domain="stats">hits</gettext>' : '<gettext domain="stats">hit count N/A</gettext>';
	    my $todo = '<td></td><td></td><td></td>';
	    $todo = linklist($file, $lang) if defined $status_db{$lang};
	    # Translated pages or already WIP in translation list
            if ((index ($wmlfiles{$lang}, " $file ") >= 0) or (($todo ne '<td></td><td></td><td></td>') and ($transversion{"$lang/$file"} ne $version{"$orig/$file"}))) {
                $translated{$lang}++;
		$translated_s{$lang} += $sizes{$file};
                $orig = $original{"$lang/$file"} || "english";
                # Outdated translations
                $msg = check_translation ($transversion{"$lang/$file"}, $version{"$orig/$file"}, "$lang/$file", "$orig/$file");
                if (length ($msg) or (($todo ne '<td></td><td></td><td></td>') and ($transversion{"$lang/$file"} ne $version{"$orig/$file"}))) {
                    $o_body .= "<tr>";
                    if (($file !~ /\.wml$/)
                        || ($file eq "devel/wnpp/wnpp.wml")) {
                        $o_body .= sprintf "<td>%s</td>", $file;
                    } else {
                        $o_body .= sprintf "<td><a title=\"%s\" href=\"$opt_b/%s\">%s</a></td>", $hits, $base, $base;
                    }
		    my $stattd = sprintf '<td style=\'font-family: monospace\' title=\'<gettext domain="stats">Click to fetch diffstat data</gettext>\' onClick="setDiffstat(\'%s\', \'%s\', \'%s\', this)">+/-</td>', $file, $transversion{"$lang/$file"}, $version{"$orig/$file"};
		    my $statspan = sprintf '(<span style=\'font-family: monospace\' title=\'<gettext domain="stats">Click to fetch diffstat data</gettext>\' onClick="setDiffstat(\'%s\', \'%s\', \'%s\', this)">+/-</span>)', $file, $transversion{"$lang/$file"}, $version{"$orig/$file"};
		  if (!defined $status_db{$lang}) {
                    $o_body .= sprintf "<td>%s</td>", $msg;
                    $o_body .= $stattd;
	          }
		    if ($msg eq '<gettext domain="stats">Wrong translation version</gettext>' || $msg eq '<gettext domain="stats">The original no longer exists</gettext>') {
		      if (defined $status_db{$lang}) {
			$o_body .= sprintf "<td>%d (%.2f&nbsp;&permil;)</td>", $sizes{$file}, $sizes{$file}/$nsize * 1000;
		      } else {
		        $o_body .= "<td></td><td></td>";
		      }
		    } else {
		      if (defined $status_db{$lang}) {
                       if ($transversion{"$lang/$file"} ne ''){
			$o_body .= sprintf '<td><a title=\'<gettext domain="stats">Unified diff</gettext>\' href="%s">%s&nbsp;→&nbsp;%s</a> ',
				vcs_diff_url( "$orig/$file", $transversion{"$lang/$file"}, $version{"$orig/$file"}, 'u' ),
				$transversion{"$lang/$file"}, $version{"$orig/$file"};
			$o_body .= sprintf '<a title=\'<gettext domain="stats">Colored diff</gettext>\' href="%s">%s&nbsp;→&nbsp;%s</a> ',
				vcs_diff_url( "$orig/$file", $transversion{"$lang/$file"}, $version{"$orig/$file"}, 'h' ),
				$transversion{"$lang/$file"}, $version{"$orig/$file"};
			$o_body .= "$statspan</td>";
		       } else {
			$o_body .= sprintf "<td>%d (%.2f&nbsp;&permil;)</td>", $sizes{$file}, $sizes{$file}/$nsize * 1000;
		       }
		      } else {
		        $o_body .= sprintf "<td><a href=\"%s\">%s\&nbsp;->\&nbsp;%s</a></td>",
					   vcs_diff_url( "$orig/$file", $transversion{"$lang/$file"}, $version{"$orig/$file"}, $firstdifftype ),
					   $transversion{"$lang/$file"}, $version{"$orig/$file"};
		        $o_body .= sprintf "<td><a href=\"%s\">%s\&nbsp;->\&nbsp;%s</a></td>",
					   vcs_diff_url( "$orig/$file", $transversion{"$lang/$file"}, $version{"$orig/$file"}, $seconddifftype ),
					   $transversion{"$lang/$file"}, $version{"$orig/$file"};
		      }
		    }
		    $o_body .= sprintf "<td><a title=\"%s\" href=\"%s#rev%s\">[L]</a></td>", $msg, vcs_log_url("$orig/$file"), $version{"$orig/$file"};
                    $o_body .= sprintf "<td><a href=\"%s\">[V]</a>\&nbsp;", vcs_view_url("$lang/$file");
                    $o_body .= sprintf "<a href=\"%s\">[F]</a></td>", vcs_raw_url("$lang/$file");
                    $o_body .= sprintf "<td align=center>%s</td>", $maintainer{"$lang/$file"} || "";
		    $o_body .= $todo if (defined $status_db{$lang});
                    $o_body .= "</tr>\n";
                    $outdated{$lang}++;
		    $outdated_s{$lang} += $sizes{$file};
                # Up-to-date translations
                } else {
                    if (($file !~ /\.wml$/)
                        || ($file eq "devel/wnpp/wnpp.wml")) {
                        $t_body .= sprintf "<li>%s</li>\n", $file;
                    } else {
                        $t_body .= sprintf "<li><a title=\"%s\" href=\"$opt_b/%s.%s.html\">%s</a></li>\n", $hits, $base, $l, $base;
                    }
                }
            }
            # Untranslated pages
            else {
	        my $u_tmp;
                if (($file !~ /\.wml$/)
                    || ($file eq "devel/wnpp/wnpp.wml")) {
                    $u_tmp = sprintf "<tr><td>%s</td><td>&nbsp;</td></tr>\n", $file;
                } else {
                    $u_tmp = sprintf "<tr><td><a title=\"%s\" href=\"$opt_b/%s\">%s&nbsp;&nbsp;(%s)</a></td><td align=\"right\">%d</td><td>(%.2f&nbsp;&permil;)</td></tr>\n", $hits, $base, $base, $version{"$orig/$file"}, $sizes{$file}, $sizes{$file}/$nsize * 1000;
                }
		if (($file =~ /international\//) &&
		    ($file !~ /international\/index.wml$/) &&
		    ($file !~ /international\/l10n\//)) {
		    $ui_body .=$u_tmp;
		} elsif ((($file =~ /(News|events|security|vote)\/[0-9]{4}\//) &&
		          ($file !~ /index.wml$/)) ||
		         ($file =~ /(News\/weekly\/[0-9]{4}\/|security\/undated)/)) {
		    $un_body .= $u_tmp;
		} elsif (($file =~ /(consultants|users\/(com|edu|gov|org))\//) &&
		         ($file !~ /index.wml$/)) {
		    $uu_body .=$u_tmp;
		} else {
		    $u_body .= $u_tmp;
		}
                $untranslated{$lang}++;
		$untranslated_s{$lang} += $sizes{$file};
            }
        }


        # this is where we discard the files that the translation directory contains
        # but which don't exist in the English directory
        #   print "extra files: ".$wml{$lang}-$translated{$lang}."\n";
        $wml{$lang} = $translated{$lang};
	$wml_s{$lang} = $translated_s{$lang};
        $translated{$lang} = $translated{$lang} - $outdated{$lang};
	$translated_s{$lang} = $translated_s{$lang} - $outdated_s{$lang};

        if ($nfiles > 0) {
            $percent_a{$lang} = $wml{$lang}/$nfiles * 100;
        } else {
            $percent_a{$lang} = 0;
        }
        if ($nsize > 0) {
            $percent_as{$lang} = $wml_s{$lang}/$nsize * 100;
        } else {
	    $percent_as{$lang} = 0;
        }
        if ($wml{$lang} > 0) {
            $percent_t{$lang} = $translated{$lang}/$wml{$lang} * 100;
        } else {
            $percent_t{$lang} = 0;
        }
        if ($wml_s{$lang} > 0) {
            $percent_ts{$lang} = $translated_s{$lang}/$wml_s{$lang} * 100;
        } else {
	    $percent_ts{$lang} = 0;
        }
        $percent_o{$lang} = 100 - $percent_t{$lang};
	$percent_os{$lang} = 100 - $percent_ts{$lang};
        $percent_u{$lang} = 100 - $percent_a{$lang};
	$percent_us{$lang} = 100 - $percent_as{$lang};

        if (open (HTML, ">$config{'htmldir'}/$l.wml")) {
	    printf HTML "#use wml::debian::template title=\"<:=\$trans{\$CUR_ISO_LANG}{%s}:>\"\n", $lang;
	    print HTML "#use wml::debian::toc\n";
        printf HTML qq|<define-tag transstatslink><a href="%s">webwml-stattrans</a></define-tag>\n|,
            vcs_view_url('stattrans.pl');
        print HTML "<define-tag createdwith><address>\n";
        print HTML '<gettext domain="stats">Created with <transstatslink></gettext>';
        print HTML "</address></define-tag>\n";
            print HTML "<script src=\"diffstat.js\" type=\"text/javascript\"></script>\n\n";
            $color = get_color ($percent_a{$lang});

            printf HTML '<table summary="<gettext domain="stats">Translation summary for</gettext> <:=$trans{$CUR_ISO_LANG}{'.$lang.'} :>" style="background-color: %s; width: 100%; font-weight: bold; margin: 0; text-align: center;">'."\n", $color;
            print HTML "<colgroup span=\"4\" width=\"25%\"></colgroup>\n";

            print HTML '<tr><th><gettext domain="stats">Translated</gettext></th><th><gettext domain="stats">Up to date</gettext></th><th><gettext domain="stats">Outdated</gettext></th><th><gettext domain="stats">Not translated</gettext></th></tr>'."\n<tr>\n";
            printf HTML '<td>%d <gettext domain="stats">files</gettext> (%.1f%%)</td>', $wml{$lang}, $percent_a{$lang};
            printf HTML '<td>%d <gettext domain="stats">files</gettext> (%.1f%%)</td>', $translated{$lang}, $percent_t{$lang};
            printf HTML '<td>%d <gettext domain="stats">files</gettext> (%.1f%%)</td>', $outdated{$lang}, $percent_o{$lang};
            printf HTML '<td>%d <gettext domain="stats">files</gettext> (%.1f%%)</td>', $untranslated{$lang}, $percent_u{$lang};
            print HTML "</tr>\n";
	    print HTML "<tr>\n";
	    printf HTML '<td>%d <gettext domain="stats">bytes</gettext> (%.1f%%)</td>', $wml_s{$lang}, $percent_as{$lang};
	    printf HTML '<td>%d <gettext domain="stats">bytes</gettext> (%.1f%%)</td>', $translated_s{$lang}, $percent_ts{$lang};
	    printf HTML '<td>%d <gettext domain="stats">bytes</gettext> (%.1f%%)</td>', $outdated_s{$lang}, $percent_os{$lang};
	    printf HTML '<td>%d <gettext domain="stats">bytes</gettext> (%.1f%%)</td>', $nsize-$wml_s{$lang}, $percent_us{$lang};
	    print HTML "</tr>\n";
            print HTML "</table>\n";

            # Make the table of content
	    print HTML "<toc-display/>\n";
            if (%hits) {
                print HTML '<p><gettext domain="stats">Note: the lists of pages are sorted by popularity. Hover over the page name to see the number of hits.</gettext>';
                print HTML "</p>\n";
            }

            # outputs the content
            if ($o_body) {
                print HTML '<toc-add-entry name="outdated"><gettext domain="stats">Outdated translations</gettext></toc-add-entry>'."\n";
                print HTML "<table summary=\"Outdated translations\" border=0 cellpadding=1 cellspacing=1>\n";
                print HTML '<tr><th><gettext domain="stats">File</gettext></th>'."\n";
	      if (defined $status_db{$lang}) {
		print HTML '<th><gettext domain="stats">Diff</gettext></th>';
	      } else {
		print HTML '<th><gettext domain="stats">Comment</gettext></th>'."\n";
		print HTML '<th><gettext domain="stats">Diffstat</gettext></th>'."\n";
                if ($opt_d eq "u") { print HTML '<th><gettext domain="stats">Unified diff</gettext></th><th><gettext domain="stats">Colored diff</gettext></th>'; }
                elsif ($opt_d eq "h") { print HTML '<th><gettext domain="stats">Colored diff</gettext></th><th><gettext domain="stats">Unified diff</gettext></th>'; }
                else { print HTML '<th><gettext domain="stats">Diff</gettext></th>'; }
	      }
                print HTML '<th><gettext domain="stats">Log</gettext></th>';
                print HTML '<th><gettext domain="stats">Translation</gettext></th>';
                print HTML '<th><gettext domain="stats">Maintainer</gettext></th>';
	      if (defined $status_db{$lang}) {
		print HTML '<th><gettext domain="stats">Status</gettext></th>';
		print HTML '<th><gettext domain="stats">Translator</gettext></th>';
		print HTML '<th><gettext domain="stats">Date</gettext></th>';
	      }
                print HTML "</tr>\n";
                print HTML $o_body;
                print HTML "</table>\n";
            }
            if ($u_body) {
                print HTML '<toc-add-entry name="untranslated"><gettext domain="stats">General pages not translated</gettext></toc-add-entry>'."\n";
                print HTML '<table summary="<gettext domain="stats">Untranslated general pages</gettext>">'."\n";
                print HTML $u_body;
                print HTML "</table>\n";
            }
            if ($un_body) {
                print HTML '<toc-add-entry name="untranslated-news"><gettext domain="stats">News items not translated</gettext></toc-add-entry>'."\n";
                print HTML '<table summary="<gettext domain="stats">Untranslated news items</gettext>">'."\n";
                print HTML $un_body;
                print HTML "</table>\n";
            }
            if ($uu_body) {
                print HTML '<toc-add-entry name="untranslated-user"><gettext domain="stats">Consultant/user pages not translated</gettext></toc-add-entry>'."\n";
                print HTML '<table summary="<gettext domain="stats">Untranslated consultant/user pages</gettext>">'."\n";
                print HTML $uu_body;
                print HTML "</table>\n";
            }
            if ($ui_body) {
                print HTML '<toc-add-entry name="untranslated-l10n"><gettext domain="stats">International pages not translated</gettext></toc-add-entry>'."\n";
                print HTML '<table summary="<gettext domain="stats">Untranslated international pages</gettext>">'."\n";
                print HTML $ui_body;
                print HTML "</table>\n";
            }
            if ($t_body) {
                print HTML '<toc-add-entry name="uptodate"><gettext domain="stats">Translated pages (up-to-date)</gettext></toc-add-entry>'."\n";
                print HTML "<ul class=\"discless\">\n";
                print HTML $t_body;
                print HTML "</ul>\n";
            }
            # outputs the gettext stats
            if ($lang ne 'english') {
                print HTML '<toc-add-entry name="gettext"><gettext domain="stats">Translated templates (PO files)</gettext></toc-add-entry>'."\n";
                print HTML '<table summary="<gettext domain="stats">PO Translation Statistics</gettext>" width="100%">'."\n";
		print HTML '<tr><th><gettext domain="stats">File</gettext></th>'."\n";
		print HTML '<th><gettext domain="stats">Up to date</gettext></th>'."\n";
		print HTML '<th><gettext domain="stats">Fuzzy</gettext></th>'."\n";
		print HTML '<th><gettext domain="stats">Untranslated</gettext></th>'."\n";
		print HTML '<th><gettext domain="stats">Total</gettext></th></tr>'."\n";
                foreach my $domain (sort keys %po_total) {
                    next if $domain eq 'total';
                    print HTML "<tr>";

                    $color_t = get_color ($percent_po_t{$domain}{$lang});
                    $color_f = get_color (100 - $percent_po_f{$domain}{$lang});
                    $color_u = get_color (100 - $percent_po_u{$domain}{$lang});

                    print HTML "<td>$domain.$langs{$lang}.po</td>";
                    printf HTML "<td style=\"background-color: %s\" align=right>%d (%s%%)</td>", $color_t, $po_translated{$domain}{$lang},   $percent_po_t{$domain}{$lang};
                    printf HTML "<td style=\"background-color: %s\" align=right>%d (%s%%)</td>", $color_f, $po_fuzzy{$domain}{$lang},        $percent_po_f{$domain}{$lang};
                    printf HTML "<td style=\"background-color: %s\" align=right>%d (%s%%)</td>", $color_u, $po_untranslated{$domain}{$lang}, $percent_po_u{$domain}{$lang};
                    printf HTML "<td align=right>%d</td>", $po_total{$domain};
                    print HTML "</tr>\n";
                }
                print HTML "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n";
		print HTML '<tr><th><gettext domain="stats">Total:</gettext></th>';
                $color_t = get_color ($percent_po_t{'total'}{$lang});
                $color_f = get_color (100 - $percent_po_f{'total'}{$lang});
                $color_u = get_color (100 - $percent_po_u{'total'}{$lang});
                printf HTML "<td style=\"background-color: %s\" align=right>%d (%d%%)</td>", $color_t, $po_translated{'total'}{$lang}, $percent_po_t{'total'}{$lang};
                printf HTML "<td style=\"background-color: %s\" align=right>%d (%d%%)</td>", $color_f, $po_fuzzy{'total'}{$lang}, $percent_po_f{'total'}{$lang};
                printf HTML "<td style=\"background-color: %s\" align=right>%d (%d%%)</td>", $color_u, $po_untranslated{'total'}{$lang}, $percent_po_u{'total'}{$lang};
                printf HTML "<td align=right>%d</td>", $po_total{'total'};
                print HTML "</tr>\n";
                print HTML "</table>\n";
            }

            print HTML "<createdwith/>\n";
            close (HTML);
        } else {
            print "Can't open $config{'htmldir'}/$l.wml\n";
        }
    }
}
print "\n" if ($config{'verbose'});

# =============== Creating index.html ===============
print "Creating index.wml... " if ($config{'verbose'});

open (HTMLI, ">$config{'htmldir'}/index.wml")
    || die "Can't open $config{'htmldir'}/index.wml";

print HTMLI "#use wml::debian::stats_tags\n";
printf HTMLI "#use wml::debian::template title=\"%s\"\n\n", $config{'title'};
printf HTMLI qq|<define-tag transstatslink><a href="%s">webwml-stattrans</a></define-tag>\n|,
       vcs_view_url('stattrans.pl');
print HTMLI "<define-tag createdwith><address>\n";
print HTMLI '<gettext domain="stats">Created with <transstatslink></gettext>';
print HTMLI "</address></define-tag>\n";
print HTMLI '<h2><gettext domain="stats">Translated web pages</gettext></h2>'."\n";
printf HTMLI "<p><stats_pages %d></p>\n",($wml{'english'}+$untranslated{'english'});

print HTMLI '<table summary="<gettext domain="stats">Translation Statistics by Page Count</gettext>" class="stattrans">'."\n";
print HTMLI "<colgroup width=\"20%\">\n";
print HTMLI "<col>\n";
print HTMLI "</colgroup>";
print HTMLI "<colgroup width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "<col width=\"10%\">\n";
print HTMLI "</colgroup>";
print HTMLI "<thead>";
print HTMLI '<tr><th><gettext domain="stats">Language</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Translations</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Up to date</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Outdated</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Not translated</gettext></th></tr>'."\n";
print HTMLI "</thead>";
print HTMLI "<tbody>";
foreach $lang (@search_in) {
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
        $color_a = get_color ($percent_a{$lang});
        $color_t = get_color ($percent_t{$lang});
        $color_o = get_color (100 - $percent_o{$lang});
        $color_u = get_color (100 - $percent_u{$lang});

        print HTMLI "<tr>";
        printf HTMLI "<th><a href=\"%s\"><:=\$trans{\$CUR_ISO_LANG}{%s} :></a> (%s)</th>", $l, $lang, $l;
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_a, $wml{$lang},          $percent_a{$lang};
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_t, $translated{$lang},   $percent_t{$lang};
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_o, $outdated{$lang},     $percent_o{$lang};
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_u, $untranslated{$lang}, $percent_u{$lang};
        print HTMLI "</tr>\n";
    }
}
print HTMLI "</tbody>";
print HTMLI "</table>\n";

print HTMLI '<h2><gettext domain="stats">Translated web pages (by size)</gettext></h2>'."\n";
printf HTMLI "<p><stats_bytes %d></p>\n",($wml_s{'english'}+$untranslated_s{'english'});

print HTMLI '<table summary="<gettext domain="stats">Translation Statistics by Page Size</gettext>" class="stattrans">'."\n";
print HTMLI "<colgroup span=\"1\">\n";
print HTMLI "<col width=\"20%\">\n";
print HTMLI "</colgroup>";
print HTMLI "<colgroup span=\"8\">\n";
print HTMLI "<col width=\"13%\">\n";
print HTMLI "<col width=\"7%\">\n";
print HTMLI "<col width=\"13%\">\n";
print HTMLI "<col width=\"7%\">\n";
print HTMLI "<col width=\"13%\">\n";
print HTMLI "<col width=\"7%\">\n";
print HTMLI "<col width=\"13%\">\n";
print HTMLI "<col width=\"7%\">\n";
print HTMLI "</colgroup>";
print HTMLI "<thead>";
print HTMLI '<tr><th><gettext domain="stats">Language</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Translations</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Up to date</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Outdated</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Not translated</gettext></th></tr>'."\n";
print HTMLI "</thead>";
print HTMLI "<tbody>";

foreach $lang (@search_in) {
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
	$color_a = get_color ($percent_a{$lang});
	$color_t = get_color ($percent_t{$lang});
	$color_o = get_color (100 - $percent_o{$lang});
	$color_u = get_color (100 - $percent_u{$lang});

	print HTMLI "<tr>";
	printf HTMLI "<th><a href=\"%s\"><:=\$trans{\$CUR_ISO_LANG}{%s} :></a> (%s)</th>", $l, $lang, $l;
	printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_a, $wml_s{$lang},                   $percent_as{$lang};
	printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_t, $translated_s{$lang},            $percent_ts{$lang};
	printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_o, $outdated_s{$lang},              $percent_os{$lang};
	printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%.1f%%)</td>", $color_u, $wml_s{"english"}+$untranslated_s{'english'}-$wml_s{$lang}, $percent_us{$lang};
	print HTMLI "</tr>\n";
    }
}
print HTMLI "</tbody>";
print HTMLI "</table>\n";

print HTMLI '<h2><gettext domain="stats">Translated templates (PO files)</gettext></h2>'."\n";
printf HTMLI "<p><stats_strings %d></p>\n",$po_total{'total'};

print HTMLI '<table summary="<gettext domain="stats">PO Translation Statistics</gettext>" class="stattrans">'."\n";
print HTMLI "<colgroup span=\"1\"width=\"28%\">\n";
print HTMLI "</colgroup>";
print HTMLI "<colgroup span=\"6\" width=\"12%\">\n";
print HTMLI "<col width=\"12%\">\n";
print HTMLI "<col width=\"12%\">\n";
print HTMLI "<col width=\"12%\">\n";
print HTMLI "<col width=\"12%\">\n";
print HTMLI "<col width=\"12%\">\n";
print HTMLI "<col width=\"12%\">\n";
print HTMLI "</colgroup>";
print HTMLI "<thead>";
print HTMLI '<tr><th><gettext domain="stats">Language</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Up to date</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Fuzzy</gettext></th>'."\n";
print HTMLI '<th colspan="2"><gettext domain="stats">Not translated</gettext></th></tr>'."\n";
print HTMLI "</thead>";
print HTMLI "<tbody>";
foreach $lang (@search_in) {
    next if $lang eq 'english';
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
        print HTMLI "<tr>";
        printf HTMLI "<th><a href=\"%s#gettext\"><:=\$trans{\$CUR_ISO_LANG}{%s} :></a> (%s)</th>", $l, $lang, $l;
        $color_t = get_color ($percent_po_t{'total'}{$lang});
        $color_f = get_color (100 - $percent_po_f{'total'}{$lang});
        $color_u = get_color (100 - $percent_po_u{'total'}{$lang});
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%d%%)</td>", $color_t, $po_translated{'total'}{$lang},   $percent_po_t{'total'}{$lang};
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%d%%)</td>", $color_f, $po_fuzzy{'total'}{$lang},        $percent_po_f{'total'}{$lang};
        printf HTMLI "<td style=\"background-color: %s\">%d</td><td>(%d%%)</td>", $color_u, $po_untranslated{'total'}{$lang}, $percent_po_u{'total'}{$lang};
        print HTMLI "</tr>\n";
    }
}

print HTMLI "</tbody>";
print HTMLI "</table>\n";

print HTMLI "<createdwith/>\n";
close (HTMLI);

print "done.\n" if ($config{'verbose'});

# Note:
#   Translated pages on ll.html may be higher than in index.html.
#   This is due to the fact that some english pages were removed.

# printf "%s\n", join ("\n", keys %version);
# printf "%s - %s\n", $version{'german/devel/index'}, $version{'english/devel/index'};
