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
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

use POSIX qw(strftime);
use Getopt::Std;

#    These modules reside under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
use Local::Cvsinfo;
use Webwml::Langs;
use Webwml::TransCheck;
use Webwml::TransIgnore;

$| = 1;

$opt_h = "/org/www.debian.org/www/devel/website/stats";
$opt_w = "/org/www.debian.org/webwml";
$opt_p = "*.(wml|src)";
$opt_t = "Debian web site translation statistics";
$opt_v = 0;
$opt_d = "u";
$opt_l = undef;
getopts('h:w:p:t:vd:l:') || die;
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
	   );

my $l = Webwml::Langs->new($opt_w);
my %langs = $l->name_iso();

my $transignore = Webwml::TransIgnore->new($opt_w);

my $cvs = Local::Cvsinfo->new();
$cvs->options(
        recursive => 1,
        matchfile => [ $config{'wmlpat'} ],
        skipdir   => [ "template" ],
);
$cvs->readinfo("$config{'wmldir'}/english");
foreach (@{$transignore->global()}) {
        $cvs->removefile("$config{'wmldir'}/english/$_");
}

my $altcvs = Local::Cvsinfo->new();
$altcvs->options(
        recursive => 1,
        matchfile => [ $config{'wmlpat'} ],
        skipdir   => [ "template" ],
);

$max_versions = 5;
$min_versions = 1;

$border_head = "<table width=\"95%\" align=\"center\" border=0 cellpadding=0 cellspacing=0><tr bgcolor=\"#000000\"><td>"
              ."<table width=\"100%\" border=0 cellpadding=0 cellspacing=1><tr bgcolor=\"#ffffff\"><td>";
$border_foot = "</td></tr></table></td></tr></table>";


$date = strftime "%a %b %e %H:%M:%S %Y %z", localtime;

my %original;
my %transversion;
my %version;
my %files;

# Count wml files in given directory
#
sub getwmlfiles
{
    my $lang = shift;
    my $dir = "$config{'wmldir'}/$lang";
    my $cutfrom = length ($config{'wmldir'})+length($lang)+2;
    my $count = 0;
    my $is_english = ($lang eq "english")?1:0;
    my ( $file, $v );
    my @listfiles;

    print "$lang " if ($config{verbose});
    die "$0: can't find $dir!\n" if (! -d "$dir");
    if ($is_english) {
        @listfiles = @{$cvs->files()};
    } else {
        $altcvs->reset();
        $altcvs->readinfo($dir);
        @listfiles = @{$altcvs->files()};
    }
    foreach my $f (@listfiles) {
	$file = substr ($f, $cutfrom);
	next if $transignore->is_global($file);
	$files{$file} = 1;
	$wmlfiles{$lang} .= " " . $file;
	my $transcheck = Webwml::TransCheck->new("$dir/$file");
	if ($transcheck->revision()) {
	    $transversion{"$lang/$file"} = $transcheck->revision();
	    $original{"$lang/$file"} ||= $transcheck->original();
	}
	if ($is_english) {
	    $version{"$lang/$file"} = $cvs->revision($f);
	} else {
	    $version{"$lang/$file"} = $altcvs->revision($f);
	    if (!$transcheck->revision()) {
	        $transcheckenglish = Webwml::TransCheck->new("english/$file");
		if (!$transcheckenglish->revision() and (-e "english/$file")) {
		    $transversion{"$lang/$file"} = "1.1";
		    $original{"$lang/$file"} = "english";
		} else {
		    $original{"english/$file"} = $lang;
		    $transversion{"english/$file"} ||= "1.1";
		}
	    }
	}
	if ($transcheck->maintainer()) {
	    $maintainer{"$lang/$file"} = $transcheck->maintainer();
	}
	$count++;
    }
    $wmlfiles{$lang} .= " ";
    $wml{$lang} = $count;
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
    my ($translation, $version, $file) = @_;
    my ( @version_numbers, $major_number, $last_number );
    my ( @translation_numbers, $major_translated_number, $last_translated_number );

    if ( $version && $translation ) {
	@version_numbers = split /\./,$version;
	$major_number = $version_numbers[0];
	$last_number = pop @version_numbers;
	die "Invalid CVS revision for $file: $version\n"
	    unless ($major_number =~ /\d+/ && $last_number =~ /\d+/);

	@translation_numbers = split /\./,$translation;
	$major_translated_number = $translation_numbers[0];
	$last_translated_number = pop @translation_numbers;
	die "Invalid translation revision for $file: $translation\n"
	    unless ($major_translated_number =~ /\d+/ && $last_translated_number =~ /\d+/);

	# Here we compare the original version with the translated one and print
	# a note for the user if their first or last numbers are too far apart
	# From translation-check.wml

	if ( $major_number != $major_translated_number ) {
	    return "This translation is too out of date";
	} elsif ( $last_number - $last_translated_number < 0 ) {
	    return "Wrong translation version";
	} elsif ( $last_number - $last_translated_number >= $max_versions ) {
	    return "This translation is too out of date";
	} elsif ( $last_number - $last_translated_number >= $min_versions ) {
	    return "The original is newer than this translation";
	}
    } elsif ( !$version && $translation) {
	return "The original no longer exists";
    }
    return "";
}

print "Collecting data in: " if ($config{'verbose'});
if ($opt_l) {
  getwmlfiles ($opt_l);
  getwmlfiles ('english');
} else {
  foreach $lang (keys %langs) {
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
    my @status = qx,LC_ALL=C make -C $opt_w/$lang/po stats 2>&1 1>/dev/null,;
    foreach $line (@status) {
        chomp $line;
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
            $percent_po_u{$domain}{$lang} = 0;
        }
    }
    $po_total{"total"} = $po_translated{"total"}{$lang} + $po_fuzzy{"total"}{$lang} + $po_untranslated{"total"}{$lang};
    
    if ($po_total{'total'} > 0) {
	$percent_po_t{'total'}{$lang} = int ($po_translated{'total'}{$lang}/$po_total{'total'} * 100 + .5);
	$percent_po_f{'total'}{$lang} = int ($po_fuzzy{'total'}{$lang}/$po_total{'total'} * 100 + .5);
	$percent_po_u{'total'}{$lang} = int ($po_untranslated{'total'}{$lang}/$po_total{'total'} * 100 + .5);
    } else {
	$percent_po_t{'total'}{$lang} = 0;
	$percent_po_f{'total'}{$lang} = 0;
	$percent_po_u{'total'}{$lang} = 0;
    }
}
print "done.\n" if ($config{'verbose'});

# =============== Create HTML files ===============
mkdir ($config{'htmldir'}, 02775) if (! -d $config{'htmldir'});

my @filenames = sort keys %files;
my $nfiles = scalar @filenames;

print "Creating files: " if ($config{'verbose'});
foreach $lang (@search_in) {
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
        print "$l.html " if ($config{'verbose'});

        $t_body = $u_body = $o_body = "";
        $translated{$lang} = $outdated{$lang} = $untranslated{$lang} = 0;

        # get stats about files
        foreach $file (@filenames) {
            next if ($file eq "");
            # Translated pages
            if (index ($wmlfiles{$lang}, " $file ") >= 0) {
                $translated{$lang}++;
                $orig = $original{"$lang/$file"} || "english";
                # Outdated translations
                $msg = check_translation ($transversion{"$lang/$file"}, $version{"$orig/$file"}, "$lang/$file");
                if (length ($msg)) {
                    $o_body .= "<tr>";
                    if (($file !~ /\.wml$/) 
                        || ($file eq "devel/wnpp/wnpp.wml")) {
                        $o_body .= sprintf "<td>%s</td>", $file;
                    } else {
                        (my $base = $file) =~ s/\.wml$//;
                        $o_body .= sprintf "<td><a href=\"/%s.%s.html\">%s</a></td>", $base, $l, $base;
                    }
                    $o_body .= sprintf "<td>%s</td>", $transversion{"$lang/$file"};
                    $o_body .= sprintf "<td>%s</td>", $version{"$orig/$file"};
                    $o_body .= sprintf "<td>%s</td>", $msg;
		    if ($msg eq "Wrong translation version" || $msg eq "The original no longer exists") {
		        $o_body .= "<td></td><td></td>";
		    } else {
		        $o_body .= sprintf "<td>&nbsp;&nbsp;<a href=\"http://cvs.debian.org/webwml/$orig/%s.diff\?r1=%s\&amp;r2=%s\&amp;cvsroot=webwml\&amp;diff_format=%s\">%s -> %s</a></td>", $file, $transversion{"$lang/$file"}, $version{"$orig/$file"}, $config{'difftype'}, $transversion{"$lang/$file"}, $version{"$orig/$file"};
                        $o_body .= sprintf "<td><a href=\"http://cvs.debian.org/webwml/$orig/%s?cvsroot=webwml#rev%s\">[L]</a></td>", $file, $version{"$orig/$file"};
		    }
                    $o_body .= sprintf "<td align=center>%s</td>", $maintainer{"$lang/$file"} || "";
                    $o_body .= "</tr>\n";
                    $outdated{$lang}++;
                # Up-to-date translations
                } else {
                    if (($file !~ /\.wml$/) 
                        || ($file eq "devel/wnpp/wnpp.wml")) {
                        $t_body .= sprintf "%s<br>\n", $file;
                    } else {
                        (my $base = $file) =~ s/\.wml$//;
                        $t_body .= sprintf "<a href=\"/%s.%s.html\">%s</a><br>\n", $base, $l, $base;
                    }
                }
            }
            # Untranslated pages
            else {
                if (($file !~ /\.wml$/)
                    || ($file eq "devel/wnpp/wnpp.wml")) {
                    $u_body .= sprintf "%s<br>\n", $file;
                } else {
                    (my $base = $file) =~ s/\.wml$//;
                    $u_body .= sprintf "<a href=\"/%s\">%s</a><br>\n", $base, $base;
                }
                $untranslated{$lang}++;
            }
        }
        
        
        # this is where we discard the files that the translation directory contains
        # but which don't exist in the English directory
        #   print "extra files: ".$wml{$lang}-$translated{$lang}."\n";
        $wml{$lang} = $translated{$lang};
        $translated{$lang} = $translated{$lang} - $outdated{$lang};
    
        if ($nfiles > 0) {
            $percent_a{$lang} = int ($wml{$lang}/$nfiles * 100 + .5);
        } else {
            $percent_a{$lang} = 0;
        }
        if ($wml{$lang} > 0) {
            $percent_t{$lang} = int ($translated{$lang}/$wml{$lang} * 100 + .5);
        } else {
            $percent_t{$lang} = 0;
        }
        $percent_o{$lang} = 100 - $percent_t{$lang};
        $percent_u{$lang} = 100 - $percent_a{$lang};
    
        if (open (HTML, ">$config{'htmldir'}/$l.html")) {
            printf HTML "<html><head><title>%s: %s</title></head><body bgcolor=\"#ffffff\">\n", $config{'title'}, ucfirst $lang;
    
            $color = get_color ($percent_a{$lang});
    
            print HTML "<a name=\"top\"></a>\n";
            printf HTML "<table width=\"100%%\" cellpadding=2 cellspacing=0 bgcolor=\"%s\">\n", $color;
    
            printf HTML "<tr><td colspan=4><h1 align=\"center\">%s: %s</h1></td></tr>", $config{'title'}, ucfirst $lang;
    
            print HTML "<tr>\n";
            printf HTML "<td align=\"center\" width=\"25%%\"><b>%d files (%d%%) translated</b></td>", $wml{$lang}, $percent_a{$lang};
            printf HTML "<td align=\"center\" width=\"25%%\"><b>%d files (%d%%) up to date</b></td>", $translated{$lang}, $percent_t{$lang};
            printf HTML "<td align=\"center\" width=\"25%%\"><b>%d files (%d%%) outdated</b></td>", $outdated{$lang}, $percent_o{$lang};
            printf HTML "<td align=\"center\" width=\"25%%\"><b>%d files (%d%%) not translated</b></td>", $untranslated{$lang}, $percent_u{$lang};
            print HTML "</tr>\n";
            print HTML "</table>\n";
    
            # Make the table of content
            print HTML "<h3>Table of Contents</h3>\n";
            print HTML "<p><a href=\"./\">Back to index of languages</a></p>\n";
            print HTML "<br /><a href=\"../\">Working on the website</a>\n";
            if ($o_body) {
                print HTML "<br /><a href=\"#outdated\">Outdated translations</a>\n";
            }
            if ($u_body) {
                print HTML "<br /><a href=\"#untranslated\">Pages not translated</a>\n";
            }
            if ($t_body) {
                print HTML "<br /><a href=\"#uptodate\">Translations up to date</a>\n";
            }
            if ($lang ne 'english') {
                print HTML "<br /><a href=\"#gettext\">Translations of templates (gettext files)</a>\n";
            }
            print HTML "</p>\n";
            
            # outputs the content
            if ($o_body) {
                print HTML "<h3><a name='outdated'>Outdated translations</a>: <a href='#top'>(top)</a></h3>\n";
                print HTML "<table border=0 cellpadding=1 cellspacing=1>\n";
                print HTML "<tr><th>File</th><th>Translated</th><th>Origin</th><th>Comment</th>";
                if ($opt_d eq "u") { print HTML "<th>Unified diff</th>"; }
                elsif ($opt_d eq "h") { print HTML "<th>Colored diff</th>"; }
                else { print HTML "<th>Diff</th>"; }
                print HTML "<th>Log</th>";
                print HTML "<th>Maintainer</th>";
                print HTML "</tr>\n";
                print HTML $o_body;
                print HTML "</table>\n";
            }
            if ($u_body) {
                print HTML "<h3><a name='untranslated'>Pages not translated</a>: <a href='#top'>(top)</a></h3>\n";
                print HTML $u_body;
            }
            if ($t_body) {
                print HTML "<h3><a name='uptodate'>Translations up to date</a>: <a href='#top'>(top)</a></h3>\n";
                print HTML $t_body;
            }
            # outputs the gettext stats
            if ($lang ne 'english') {
                print HTML "<h3><a name='gettext'>Translations of templates (gettext files)</a>: <a href='#top'>(top)</a></h3>\n";
    #            print HTML $border_head;
                print HTML "<table width=\"100%\" border=0>\n";
                print HTML "<tr><th>File</th><th>Up to date</th><th>Fuzzy</th><th>Untranslated</th><th>Total</th></tr>\n";
                foreach my $domain (sort keys %po_total) {
                    next if $domain eq 'total';
                    print HTML "<tr>";
                    
                    $color_t = get_color ($percent_po_t{$domain}{$lang});
                    $color_f = get_color (100 - $percent_po_f{$domain}{$lang});
                    $color_u = get_color (100 - $percent_po_u{$domain}{$lang});
                    
                    print HTML "<td>$domain.$langs{$lang}.po</td>";
                    printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_t, $po_translated{$domain}{$lang}, $percent_po_t{$domain}{$lang};
                    printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_f, $po_fuzzy{$domain}{$lang}, $percent_po_f{$domain}{$lang};
                    printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_u, $po_untranslated{$domain}{$lang}, $percent_po_u{$domain}{$lang};
                    printf HTML "<td align=right>%d</td>", $po_total{$domain};
                    print HTML "</tr>\n";
                }
                print HTML "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><th>Total:</th>";
                $color_t = get_color ($percent_po_t{'total'}{$lang});
                $color_f = get_color (100 - $percent_po_f{'total'}{$lang});
                $color_u = get_color (100 - $percent_po_u{'total'}{$lang});
                printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_t, $po_translated{'total'}{$lang}, $percent_po_t{'total'}{$lang};
                printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_f, $po_fuzzy{'total'}{$lang}, $percent_po_f{'total'}{$lang};
                printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_u, $po_untranslated{'total'}{$lang}, $percent_po_u{'total'}{$lang};
                printf HTML "<td align=right>%d</td>", $po_total{'total'};
                print HTML "</tr>\n";
            }
            print HTML "</table>\n";
            
            # outputs footer
            print HTML "<hr><address>Compiled at $date</address>\n";
            print HTML "</body></html>";
            close (HTML);
        }
    }
}
print "\n" if ($config{'verbose'});

# =============== Creating index.html ===============
print "Creating index.html... " if ($config{'verbose'});

open (HTML, ">$config{'htmldir'}/index.html")
    || die "Can't open $config{'htmldir'}/index.html";

printf HTML "<html>\n<head><title>%s</title></head>\n<body bgcolor=\"#ffffff\">\n", $config{'title'};
printf HTML "<h1 align=\"center\">%s</h1>\n", $config{'title'};

print HTML "<h2>Translated web pages</h2>\n";
printf HTML "<p>There are %d pages to translate.</p>\n",($wml{'english'}+$untranslated{'english'});

print HTML $border_head;
print HTML "<table width=\"100%\" border=0 bgcolor=\"#cdc9c9\">\n";
print HTML "<tr><th>Language</th><th colspan=\"2\">Translations</th><th colspan=\"2\">Up to date</th><th colspan=\"2\">Outdated</th><th colspan=\"2\">Not translated</th></tr>\n";
foreach $lang (@search_in) {
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
        $color_a = get_color ($percent_a{$lang});
        $color_t = get_color ($percent_t{$lang});
        $color_o = get_color (100 - $percent_o{$lang});
        $color_u = get_color (100 - $percent_u{$lang});

        print HTML "<tr>";
        printf HTML "<td><a href=\"%s.html\">%s</a> (%s)</td>", $l, ucfirst $lang, $l;
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_a, $wml{$lang}, $percent_a{$lang};
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_t, $translated{$lang}, $percent_t{$lang};
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_o, $outdated{$lang}, $percent_o{$lang};
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_u, $untranslated{$lang}, $percent_u{$lang};
        print HTML "</tr>\n";
    }
}
print HTML "</table>\n";
print HTML $border_foot;

print HTML "<h2>Translated templates (gettext files)</h2>\n";
printf HTML "<p>There are %d strings to translate.</p>\n",$po_total{'total'};
print HTML $border_head;
print HTML "<table width=\"100%\" border=0 bgcolor=\"#cdc9c9\">\n";
print HTML "<tr><th>Language</th><th colspan=\"2\">Up to date</th><th colspan=\"2\">Fuzzy</th><th colspan=\"2\">Not translated</th></tr>\n";
foreach $lang (@search_in) {
    next if $lang eq 'english';
    my @processed_langs = ($langs{$lang});
    @processed_langs = ("zh-cn", "zh-tw") if $langs{$lang} eq "zh";
    foreach $l (@processed_langs) {
        print HTML "<tr>";
        printf HTML "<td><a href=\"%s.html#gettext\">%s</a> (%s)</td>", $l, ucfirst $lang, $l;
        $color_t = get_color ($percent_po_t{'total'}{$lang});
        $color_f = get_color (100 - $percent_po_f{'total'}{$lang});
        $color_u = get_color (100 - $percent_po_u{'total'}{$lang});
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_t, $po_translated{'total'}{$lang}, $percent_po_t{'total'}{$lang};
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_f, $po_fuzzy{'total'}{$lang}, $percent_po_f{'total'}{$lang};
        printf HTML "<td bgcolor=\"%s\" align=right>%d</td><td>(%d%%)</td>", $color_u, $po_untranslated{'total'}{$lang}, $percent_po_u{'total'}{$lang};
        print HTML "</tr>\n";
    }
}

print HTML "</table>\n";
print HTML $border_foot;

print HTML "<p><hr noshade size=1 width=\"100%\">\n";
print HTML "<p>Created with <a href=\"http://cvs.debian.org/webwml/stattrans.pl?cvsroot=webwml\">webwml-stattrans</a> at $date\n";
print HTML "</body></html>\n";
close (HTML);

print "done.\n" if ($config{'verbose'});

# Note:
#   Translated pages on ll.html may be higher than in index.html.
#   This is due to the fact that some english pages were removed.

# printf "%s\n", join ("\n", keys %version);
# printf "%s - %s\n", $version{'german/devel/index'}, $version{'english/devel/index'};
