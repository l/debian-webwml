#! /usr/bin/perl

#   webwml-stattrans - Website Translation Statistics
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
#   Foundation, Inc.,59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

use POSIX qw(strftime);

%config = (
	   'htmldir' => '/org/home/joey/public_html/webwml/', #fixme
	   #'htmldir' => '/home/users/joey/public_html/webwml/', #fixme
	   #'wmldir'  => '/home/project/Debian/CVS/webwml', #fixme
	   'wmldir'  => '/org/www.debian.org/webwml', #fixme
	   'wmlpat'  => '*.wml',
	   'title'   => 'Website Translation Statistics',
	   'verbose' => 0,
	   );

$max_versions = 5;
$min_versions = 1;

# from ../webwml/english/template/debian/languages.wml
# Needs to be synced frequently
my %langs = ( english    => "en",
              hellas     => "el",
              turkish    => "tr",
              romanian   => "ro",
              esperanto  => "eo",
              finnish    => "fi",
              portuguese => "pt",
              danish     => "da",
              french     => "fr",
              dutch      => "nl",
              german     => "de",
              italian    => "it",
              spanish    => "es",
              korean     => "ko",
              japanese   => "ja",
              croatian   => "hr",
              chinese    => "zh",
              swedish    => "sv",
              polish     => "pl",
              norwegian  => "no",
              russian    => "ru",
              hungarian  => "hu",
	      );

$border_head = "<table border=0 cellpadding=0 cellspacing=0><tr bgcolor=#000000><td>"
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
    my $cmd  = "find $config{'wmldir'}/$lang -name \"$config{'wmlpat'}\"";
    my $cutfrom = length ($config{'wmldir'})+length($lang)+2;
    my $count = 0;
    my $is_english = ($lang eq "english")?1:0;
    my $file, $v;

    return if (! -d "$config{'wmldir'}/$lang");
    open (FIND, "$cmd|") || die "Can't read from $cmd";
    while (<FIND>) {
	next if (/\/sitemap\.wml/);
	next if (/\/template\//);
	next if (/\/MailingLists\/(un)?subscribe\.wml/);
	chomp;
	$file = substr ($_, $cutfrom);
	$file =~ s/\.wml$//;
	$wmlfiles{$langs{$lang}} .= " " . $file;
	if ($is_english) {
	    $version{"$lang/$file"} = get_cvs_version ("$config{'wmldir'}/$lang", "$file.wml");
	} else {
	    $version{"$lang/$file"} = get_translation_version ("$config{'wmldir'}/$lang", "$file.wml");
	}
	$count++;
    }
    close (FIND);
    $wmlfiles{$langs{$lang}} .= " ";
    $wml{$langs{$lang}} = $count;
}	  

sub get_color
{
    my $percent = shift;
    my $per;

    if ((255 - ($percent * (255/75))) < 0) {
	return sprintf ("#%02x%02x00", 255 - ($percent * (255/100)), $percent * (255/100));
    } else {
	return sprintf ("#%02x%02x00", 255 - ($percent * (255/75)), $percent * (255/100));
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

print "Investigating english \n" if ($config{'verbose'});

getwmlfiles ('english');

foreach $l (keys %langs) {
    next if ($l eq "english");
    print "$l " if ($config{'verbose'});
    getwmlfiles ($l);    
}
print "\n" if ($config{'verbose'});

# =============== Create HTML files ===============
mkdir ($config{'htmldir'}, 0755) if (! -d $config{'htmldir'});

@sorted_english = sort (split (/ /, $wmlfiles{'en'}));

foreach $lang (sort (keys %langs)) {
    $l = $langs{$lang};
    printf "Creating %s.html...\n", $l if ($config{'verbose'});
    if (open (HTML, ">$config{'htmldir'}/$l.html")) {
	printf HTML "<html><head><title>%s: %s</title></head><body bgcolor=#ffffff>\n", $config{'title'}, $l;

	$percent = $wml{$l}/$wml{'en'} * 100;
	$color = get_color ($percent);

	printf HTML "<table width=100%% cellpadding=2 cellspacing=0 bgcolor=%s>\n", $color;

	printf HTML "<tr><td colspan=2><h1 align=center>%s: %s</h1></td></tr>", $config{'title'}, $l;

	printf HTML "<tr><td align=center width=50%%><b>%d files (%d%%) translated</b></td>", $wml{$l}, $percent;
	printf HTML "<td align=center width=50%%><b>%d files untranslated</b></td></tr></table>", $wml{'en'} - $wml{$l};

	print HTML "<p><a href=\"index.html\">Index</a><p>\n";
	print HTML "<p><a href=\"http://www.debian.org/devel/website/\">Working on the website</a><p>\n";

	$body = '';
	foreach $file (@sorted_english) {
	    next if ($file eq "");
	    $msg = check_translation ($version{"$lang/$file"}, $version{"english/$file"}, "$lang/$file");
	    if (length ($msg)) {
		$body .= sprintf ("<tr><td><a href=\"http://www.debian.org/%s.%s.html\">%s</a></td><td>%s</td><td>%s</td>"
				  ."<td>%s</td></tr>\n",
				  $file, $l, $file, $version{"$lang/$file"}, $version{"english/$file"}, $msg);
		$outdated{$lang}++;
	    }
	}
	if ($body) {
	    print HTML "<h3>Out-dated pages:</h3>";
	    print HTML "<table border=0 cellpadding=1 cellspacing=1>\n";
	    print HTML "<tr><th>File</th><th>Translated</th><th>English</th><th>Comment</th></tr>\n";
	    print HTML $body;
	    print HTML "</table>\n";
	}

	# Untranslated pages
	$body = '';
	foreach $file (@sorted_english) {
	    next if ($file eq "");
	    if (index ($wmlfiles{$l}, " $file ") < 0) {
		$body .= sprintf ("<a href=\"http://www.debian.org/%s\">%s</a><br>", $file, $file);
		$untranslated{$lang}++;
	    }
	}
	if ($body) {
	    print HTML "<h3>Untranslated pages:</h3>";
	    print HTML $body;
	}

	# Translated pages
	$body = '';
	foreach $file (@sorted_english) {
	    next if ($file eq "");
	    if (index ($wmlfiles{$l}, " $file ") >= 0) {
		$body .= sprintf ("<a href=\"http://www.debian.org/%s.%s.html\">%s</a><br>\n",
				  $file, $l, $file);
		$translated{$lang}++;
	    }
	}
	if ($body) {
	    print HTML "<h3>Translated pages:</h3>";
	    print HTML $body;
	}

	print HTML "</table>\n";
	print HTML "<hr><address>Compiled at $date</address>\n";
	print HTML "</body></html>";
	close (HTML);
    }
}

# =============== Creating index.html ===============
print "Creating index.html...\n" if ($config{'verbose'});

open (HTML, ">$config{'htmldir'}/index.html")
    || die "Can't open $config{'htmldir'}/index.html";

printf HTML "<html><head><title>%s</title></head><body bgcolor=#ffffff>\n", $config{'title'};
printf HTML "<h1>%s</h1>", $config{'title'};

print HTML $border_head;
print HTML "<table border=0 bgcolor=\"#cdc9c9\">";
print HTML "<tr><th>Language</th><th>Percent</th><th>Translated</th><th>Out-dated</th><th>Untranslated</th></tr>\n";
foreach $lang (sort (keys %langs)) {
    $l = $langs{$lang};
    $percent = $wml{$l}/$wml{'en'} * 100;
    $color = get_color ($percent);
    printf HTML "<tr bgcolor=\"%s\"><td><a href=\"%s.html\">%s</a> (%s)</td><td align=right>%d%%</td>"
	."<td align=right>%d</td><td align=right>%d</td><td align=right>%d</td></tr>\n",
	$color, $l, $lang, $l, $percent, $translated{$lang}, $outdated{$lang}, $untranslated{$lang};
}

print HTML "</tr></table>";
print HTML $border_foot;

print HTML "</table>";
print HTML "<p><a href=\"webwml-stattrans\">webwml-stattrans</a><p>\n";
print HTML "<hr><address>Compiled at $date</address>\n";
print HTML "</body></html>";
close (HTML);


# Note:
#   Translated pages on ll.html may be higher than in index.html.
#   This is due to the fact that some english pages were removed.

# printf "%s\n", join ("\n", keys %version);
# printf "%s - %s\n", $version{'german/devel/index'}, $version{'english/devel/index'};
