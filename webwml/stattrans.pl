#! /usr/bin/perl

#   webwml-stattrans - Debian Web site Translation Statistics
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
$| = 1;

$opt_h = "/org/www.debian.org/debian.org/devel/website/stats";
$opt_w = "/org/www.debian.org/webwml";
$opt_p = "*.wml";
$opt_t = "Debian Web site Translation Statistics";
$opt_v = 0;
$opt_d = "u";
$opt_l = undef;
getopts('h:w:p:t:vd:l:');
%config = (
	   'htmldir' => $opt_h,
	   'wmldir'  => $opt_w,
	   'wmlpat'  => $opt_p,
	   'title'   => $opt_t,
	   'verbose' => $opt_v,
	   'diff'    => $opt_d,
	   );

$max_versions = 5;
$min_versions = 1;

# from english/template/debian/languages.wml
# TODO: Needs to be synced frequently or fixed so it's automatic
my %langs = ( english    => "en",
              arabic     => "ar",
              catalan    => "ca",
              danish     => "da",
              german     => "de",
              greek      => "el",
              esperanto  => "eo",
              spanish    => "es",
              finnish    => "fi",
              french     => "fr",
              croatian   => "hr",
              hungarian  => "hu",
              italian    => "it",
              japanese   => "ja",
              korean     => "ko",
              dutch      => "nl",
              norwegian  => "no",
              polish     => "pl",
              portuguese => "pt",
              romanian   => "ro",
              russian    => "ru",
              swedish    => "sv",
              turkish    => "tr",
              chinese    => "zh",
);

$border_head = "<table width=95% align=center border=0 cellpadding=0 cellspacing=0><tr bgcolor=#000000><td>"
              ."<table width=100% border=0 cellpadding=0 cellspacing=1><tr bgcolor=#ffffff><td>";
$border_foot = "</td></tr></table></td></tr></table>";


$date = strftime "%a %b %e %H:%M:%S %Y %z", localtime;

sub get_cvs_version
{
    my ($dir, $wmlfile) = @_;
    my $file;
    my @comp;
    my $version;

    @comp = split (/\//, "$dir/$wmlfile");
    pop @comp;
    $dir = join ("/", @comp);

    @comp = split (/\//, "$wmlfile");
    $file = pop @comp;

    if (open (CVS,"$dir/CVS/Entries")) {
	while (<CVS>) {
	    ($version) = $_ =~ m,/\Q$file\E/([\d\.]*),;
	    last if $version;
	}
    }

    return $version;
}

sub get_translation_version
{
    my ($dir, $file) = @_;
    my $checktrans;

    if (open (F, "$dir/$file")) {
	$checktrans = 0;
	while (<F>) {
	    chomp;
	    if (/^\#use wml::debian::translation-check/) {
		$checktrans = 1;
		return $1 if ($_ =~ /translation="([^\" ]+)"/);
		last;
	    }
	}
	close (F);
    }
    return "";
}

# Count wml files in given directory
#
sub getwmlfiles
{
    my $lang = shift;
    my $dir = "$config{'wmldir'}/$lang";
    my $cmd = "find $dir -name \"$config{'wmlpat'}\"";
    my $cutfrom = length ($config{'wmldir'})+length($lang)+2;
    my $count = 0;
    my $is_english = ($lang eq "english")?1:0;
    my $file, $v;

    print "$lang " if ($config{verbose});
    die "$0: can't find $dir!\n" if (! -d "$dir");
    open (FIND, "$cmd|") || die "Can't read from $cmd";
    while (<FIND>) {
 	# XXX this list of exceptions needs to be maintained XXX
	next if (/\/sitemap\.wml/);
	next if (/\/template\//);
	next if (/\/MailingLists\/(un)?subscribe\.wml/);
	next if (/\/devel\/wnpp\/wnpp\.wml/);
	next if (/\/international\/l10n\/scripts\/l10nheader\.wml/);
	chomp;
	$file = substr ($_, $cutfrom);
	$file =~ s/\.wml$//;
	$wmlfiles{$lang} .= " " . $file;
	if ($is_english) {
	    $version{"$lang/$file"} = get_cvs_version ($dir, "$file.wml");
	} else {
	    $version{"$lang/$file"} = get_translation_version ($dir, "$file.wml");
	}
	$count++;
    }
    close (FIND);
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
    my @version_numbers, $major_number, $last_number;
    my @translation_numbers, $major_translated_number, $last_translated_number;

    if ($version ne "" && $translation ne "") {
	@version_numbers = split /\./,$version;
	$major_number = @version_numbers[0];
	$last_number = pop @version_numbers;
	die "Invalid CVS revision for $file: $version\n"
	    unless ($major_number =~ /\d+/ && $last_number =~ /\d+/);

	@translation_numbers = split /\./,$translation;
	$major_translated_number = @translation_numbers[0];
	$last_translated_number = pop @translation_numbers;
	die "Invalid translation revision for $file: $translation\n"
	    unless ($major_translated_number =~ /\d+/ && $last_translated_number =~ /\d+/);

	# Here we compare the original version with the translated one and print
	# a note for the user if their first or last numbers are too far apart
	# From translation-check.wml

	if ($version eq "") {
	    return "The original no longer exists";
	} elsif ( $major_number != $major_translated_number ) {
	    return "This translation is too out of date";
	} elsif ( $last_number - $last_translated_number >= $max_versions ) {
	    return "This translation is too out of date";
	} elsif ( $last_number - $last_translated_number >= $min_versions ) {
	    return "The original is newer than this translation";
	}
    }
    return "";
}

print "Collecting data in: " if ($config{'verbose'});
if ($opt_l) {
  getwmlfiles ('english');
  getwmlfiles ($opt_l);
} else {
  getwmlfiles ('english');
  foreach $lang (keys %langs) {
    next if ($lang eq "english");
    getwmlfiles ($lang);
  }
}
print "\n" if ($config{'verbose'});

# =============== Create HTML files ===============
mkdir ($config{'htmldir'}, 02775) if (! -d $config{'htmldir'});

@sorted_english = sort (split (/ /, $wmlfiles{'english'}));

print "Creating files: " if ($config{'verbose'});
my @search_in = ();
if ($opt_l) {
  push @search_in, 'english';
  push @search_in, $opt_l;
} else {
  @search_in = sort keys %langs;
}
foreach $lang (@search_in) {
    $l = $langs{$lang};
    print "$l.html " if ($config{'verbose'});
    $l = "zh-cn" if ($l eq "zh"); # kludge

    $t_body = $u_body = $o_body = "";

    foreach $file (@sorted_english) {
        next if ($file eq "");
	# Translated pages
	if (index ($wmlfiles{$lang}, " $file ") >= 0) {
	    	$t_body .= sprintf ("<a href=\"/%s.%s.html\">%s</a><br>\n",
    			  $file, $l, $file);
    		$translated{$lang}++;
		next if ($lang eq "english");
		# Outdated translations
		$msg = check_translation ($version{"$lang/$file"}, $version{"english/$file"}, "$lang/$file");
		if (length ($msg)) {
			$o_body .= "<tr>";
		    	$o_body .= sprintf "<td><a href=\"/%s.%s.html\">%s</a></td>", $file, $l, $file;
			$o_body .= sprintf "<td>%s</td>", $version{"$lang/$file"};
			$o_body .= sprintf "<td>%s</td>", $version{"english/$file"};
			$o_body .= sprintf "<td>%s</td>", $msg;
			$o_body .= sprintf "<td>&nbsp;&nbsp;<a href=\"http://cvs.debian.org/webwml/english/%s.wml.diff\?r1=%s\&r2=%s\&cvsroot=webwml\&diff_format=%s\">%s -> %s</a></td>", $file, $version{"$lang/$file"}, $version{"english/$file"}, $config{'diff_type'}, $version{"$lang/$file"}, $version{"english/$file"};
			$o_body .= "</tr>\n";
    			$outdated{$lang}++;
		}
	}
	# Untranslated pages
	else {
	    	$u_body .= sprintf ("<a href=\"/%s\">%s</a><br>", $file, $file);
    		$untranslated{$lang}++;
	}
    }

# this is where we discard the files that the translation directory contains
# but which don't exist in the English directory
#   print "extra files: ".$wml{$lang}-$translated{$lang}."\n";
    $wml{$lang} = $translated{$lang};
    $translated{$lang} = $translated{$lang} - $outdated{$lang};

    $percent_a{$lang} = $wml{$lang}/$wml{english} * 100;
    $percent_t{$lang} = $translated{$lang}/$wml{english} * 100;
    $percent_o{$lang} = $outdated{$lang}/$wml{english} * 100;
    $percent_u{$lang} = $untranslated{$lang}/$wml{english} * 100;

    if (open (HTML, ">$config{'htmldir'}/$l.html")) {
	printf HTML "<html><head><title>%s: %s</title></head><body bgcolor=#ffffff>\n", $config{'title'}, ucfirst $lang;

	$color = get_color ($percent_a{$lang});

	printf HTML "<table width=100%% cellpadding=2 cellspacing=0 bgcolor=%s>\n", $color;

	printf HTML "<tr><td colspan=4><h1 align=center>%s: %s</h1></td></tr>", $config{'title'}, ucfirst $lang;

	print HTML "<tr>\n";
	printf HTML "<td align=center width=25%%><b>%d files (%d%%) translated</b></td>", $wml{$lang}, $percent_a{$lang};
	printf HTML "<td align=center width=25%%><b>%d files (%d%%) up to date</b></td>", $translated{$lang}, $percent_t{$lang};
	printf HTML "<td align=center width=25%%><b>%d files (%d%%) outdated</b></td>", $outdated{$lang}, $percent_o{$lang};
	printf HTML "<td align=center width=25%%><b>%d files (%d%%) not translated</b></td>", $untranslated{$lang}, $percent_u{$lang};
	print HTML "</tr>\n";
	print HTML "</table>\n";

	print HTML "<p><a href=\"./\">Index</a><p>\n";
	print HTML "<p><a href=\"../\">Working on the website</a><p>\n";

	if ($o_body) {
	    print HTML "<h3>Outdated translations:</h3>";
	    print HTML "<table border=0 cellpadding=1 cellspacing=1>\n";
	    print HTML "<tr><th>File</th><th>Translated</th><th>English</th><th>Comment</th>";
	    if ($opt_d eq "u") { print HTML "<th>Unified diff</th>"; }
	    elsif ($opt_d eq "h") { print HTML "<th>Colored diff</th>"; }
	    else { print HTML "<th>Diff</th>"; }
	    print HTML "</tr>\n";
	    print HTML $o_body;
	    print HTML "</table>\n";
	}
	if ($u_body) {
	    print HTML "<h3>Pages not translated:</h3>";
	    print HTML $u_body;
	}
	if ($t_body) {
	    print HTML "<h3>Translations up to date:</h3>";
	    print HTML $t_body;
	}

	print HTML "</table>\n";
	print HTML "<hr><address>Compiled at $date</address>\n";
	print HTML "</body></html>";
	close (HTML);
    }
}
print "\n" if ($config{'verbose'});

# =============== Creating index.html ===============
print "Creating index.html... " if ($config{'verbose'});

open (HTML, ">$config{'htmldir'}/index.html")
    || die "Can't open $config{'htmldir'}/index.html";

printf HTML "<html>\n<head><title>%s</title></head>\n<body bgcolor=#ffffff>\n", $config{'title'};
printf HTML "<h1 align=center>%s</h1>\n", $config{'title'};

print HTML $border_head;
print HTML "<table width=100% border=0 bgcolor=\"#cdc9c9\">\n";
print HTML "<tr><th>Language</th><th>Translations</th><th>Up to date</th><th>Outdated</th><th>Not translated</th></tr>\n";
foreach $lang (@search_in) {
    $l = $langs{$lang};
    $l = "zh-cn" if ($l eq "zh"); # kludge

    $color_a = get_color ($percent_a{$lang});
    $color_t = get_color ($percent_t{$lang});
    $color_o = get_color ($percent_o{$lang});
    $color_u = get_color ($percent_u{$lang});

    print HTML "<tr>";
    printf HTML "<td><a href=\"%s.html\">%s</a> (%s)</td>", $l, ucfirst $lang, $l;
    printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_a, $wml{$lang}, $percent_a{$lang};
    if ($l ne "en") {
      printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_t, $translated{$lang}, $percent_t{$lang};
      printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_o, $outdated{$lang}, $percent_o{$lang};
      printf HTML "<td bgcolor=\"%s\" align=right>%d (%d%%)</td>", $color_u, $untranslated{$lang}, $percent_u{$lang};
    } else {
      print HTML "<td bgcolor=\"#00FF00\" align=right>-</td><td bgcolor=\"#00FF00\" align=right>-</td><td bgcolor=\"#FF0000\" align=right>-</td>";
    }
    print HTML "</tr>\n",
}

print HTML "</tr></table>";
print HTML $border_foot;

print HTML "</table>\n";
print HTML "<p><hr noshade size=1 width=100%>\n";
print HTML "<p>Created with <a href=\"http://cvs.debian.org/webwml/stattrans.pl?cvsroot=webwml\">webwml-stattrans</a> at $date\n";
print HTML "</body></html>\n";
close (HTML);

print "done.\n" if ($config{'verbose'});

# Note:
#   Translated pages on ll.html may be higher than in index.html.
#   This is due to the fact that some english pages were removed.

# printf "%s\n", join ("\n", keys %version);
# printf "%s - %s\n", $version{'german/devel/index'}, $version{'english/devel/index'};
