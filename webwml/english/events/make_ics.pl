#!/usr/bin/perl -w
#
# This script creates ICS (Internet Calendar, RFC 2445) files for the Debian
# events, using the WML source files as input.
#
# Run this script with the name of the .wml input file and .ics output file
# names as parameters to create the .ics file

# Originally written 2002-12-29 by Peter Karlsson <peterk@debian.org>
# © Copyright 2002-2003 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

# FIXME: Handle character entities for non-iso-8859-1 pages?

# Import external code
use Time::Local;
use integer;
use POSIX;

# Check parameters
if ($#ARGV != 1)
{
	die "Usage: $0 input.wml output.lang.ics\n";
}

($wmlfile, $icsfile) = @ARGV;

# Table of entities used when decoding pages
@entities = (
	'&nbsp;', '&iexcl;', '&cent;', '&pound;', '&curren;', '&yen;',
	'&brvbar;', '&sect;', '&uml;', '&copy;', '&ordf;', '&laquo;', '&not;',
	'&shy;', '&reg;', '&macr;', '&deg;', '&plusmn;', '&sup2;', '&sup3;',
	'&acute;', '&micro;', '&para;', '&middot;', '&cedil;', '&sup1;',
	'&ordm;', '&raquo;', '&frac14;', '&frac12;', '&frac34;', '&iquest;',
	'&Agrave;', '&Aacute;', '&Acirc;', '&Atilde;', '&Auml;', '&Aring;',
	'&AElig;', '&Ccedil;', '&Egrave;', '&Eacute;', '&Ecirc;', '&Euml;',
	'&Igrave;', '&Iacute;', '&Icirc;', '&Iuml;', '&ETH;', '&Ntilde;',
	'&Ograve;', '&Oacute;', '&Ocirc;', '&Otilde;', '&Ouml;', '&times;',
	'&Oslash;', '&Ugrave;', '&Uacute;', '&Ucirc;', '&Uuml;', '&Yacute;',
	'&THORN;', '&szlig;', '&agrave;', '&aacute;', '&acirc;', '&atilde;',
	'&auml;', '&aring;', '&aelig;', '&ccedil;', '&egrave;', '&eacute;',
	'&ecirc;', '&euml;', '&igrave;', '&iacute;', '&icirc;', '&iuml;',
	'&eth;', '&ntilde;', '&ograve;', '&oacute;', '&ocirc;', '&otilde;',
	'&ouml;', '&divide;', '&oslash;', '&ugrave;', '&uacute;', '&ucirc;',
	'&uuml;', '&yacute;', '&thorn;', '&yuml;'
);

# Gather data
open INP, '<', $wmlfile or die "Cannot read $wmlfile: $!\n";

$abbr = '';
$pagetitle = '';
$where = '';
$startdate = '';
$enddate = '';
$coord = '';
$intro = '';
$year = '';

# Read header
HEADER: while (<INP>)
{
	if (/<define-tag ([^>]+)>(.*)<\/define-tag>/)
	{
		my ($tag, $data) = ($1, $2);
		$data = 'n/a' if $data eq '';
		$abbr      = $data, next HEADER if $tag eq 'abbr';
		$pagetitle = $data, next HEADER if $tag eq 'pagetitle';
		$where     = $data, next HEADER if $tag eq 'where';
		$startdate = $data, next HEADER if $tag eq 'startdate';
		$enddate   = $data, next HEADER if $tag eq 'enddate';
		$coord     = $data, next HEADER if $tag eq 'coord';
		$year      = $data, next HEADER if $tag eq 'year';
	}

	last HEADER if /<define-tag intro>/;
}

# Check for sanity
die "No event abbreviation specified\n" if $abbr eq '';
die "No page title specified\n" if $pagetitle eq '';
die "No location specified\n" if $where eq '';
die "No start date specified\n" if $startdate eq '';
die "Malformed start date: $startdate (must be YYYY-MM-DD)\n"
	if $startdate !~ /^\d{4}-\d\d-\d\d$/;
die "No ending date specified\n" if $enddate eq '';
die "Malformed ending date: $startdate (musg be YYYY-MM-DD)\n"
	if $enddate !~ /^\d{4}-\d\d-\d\d$/;
die "No coordinator string specified\n" if $coord eq '';

($year, undef) = split /-/, $startdate unless defined $year;

# Read intro
INTRO: while (<INP>)
{
	last INTRO if m(</define-tag>);			# End at end of intro
	last INTRO if /<p>/ && $intro ne '';	# End when second paragraph starts

	chomp;
	s/^\s+//; # Collapse initial whitespace
	$intro .= ' ' if $intro ne ''; # Add whitespace at the end of the string
	$intro .= $_;

	last INTRO if /<\/p>/;					# End after first paragraph
}
close INP;

# Get date of source file
(undef, undef, undef, undef, undef, undef, undef, undef,
 undef, $mtime, undef, undef, undef) = stat $wmlfile;

# Figure out the language and  encoding of the text, by recursing upwards
# until we find a .wmlrc file
$maxlevel = 5; # Upper bound on recursion
$encoding = '';
$language = '';
$wmlrcdir = '.';
while (! -e $wmlrcdir . '/.wmlrc')
{
	$wmlrcdir .= '/..';
	die "Unable to find .wmlrc file\n" if 0 == -- $maxlevel;
}
open WMLRC, '<', $wmlrcdir . '/.wmlrc'
	or die "Unable to read $wmlrcdir/.wmlrc: $!\n";
RCDATA: while (<WMLRC>)
{
	if (/^-D CHARSET=(.*)$/)
	{
		$encoding = $1;
		last RCDATA if $encoding ne '' && $language ne '';
	}
	elsif (/^-D CUR_ISO_LANG=(.*)$/)
	{
		$language = $1;
		last RCDATA if $encoding ne '' && $language ne '';
	}
}
close WMLRC;
die "Unable to find encoding in $wmlrcdir/.wmlrc\n" if $encoding eq '';
die "Unable to find language in $wmlrcdir/.wmlrc\n" if $language eq '';

# Kill off HTML code
$coord =~ s/<[^>]+>//g;
$intro =~ s/<[^>]+>//g;

# Collapse excessive spacing
$intro =~ s/\s{2,}/ /g;
$intro =~ s/^\s+//g;

# Replace some common entities
$intro =~ s/&[mn]dash;/--/g;
$intro =~ s/&[rl]dquo;/"/g;
$intro =~ s/&[rl]squo;/'/g;

# If this is an ISO 8859-1 page, decode any character entities used
# in the input to raw binary data.
if (lc($encoding) eq 'iso-8859-1')
{
	$pagetitle =~ s/(&[^#;]+;)/&decodeentity($1)/ge;
	$intro     =~ s/(&[^#;]+;)/&decodeentity($1)/ge;
	$coord     =~ s/(&[^#;]+;)/&decodeentity($1)/ge;
	$where     =~ s/(&[^#;]+;)/&decodeentity($1)/ge;
}

# Add backslashes in front of commas in the descriptive texts
$intro =~ s/,/\\,/g;
$pagetitle =~ s/,/\\,/g;
$where =~ s/([,;])/\\$1/g;

# Convert dates into correct representation
$startstring = sprintf("%04d%02d%02dT000000", split(/-/, $startdate));
$endstring   = sprintf("%04d%02d%02dT240000", split(/-/, $enddate));

# Construct the canonic URL to this file
$filebase = $wmlfile;
$filebase =~ s(^.*/([^/]+)$)($1);
$filebase =~ s(^([^/].*)\.wml)($1);
$url = 'http://www.debian.org/events/' . $year . '/' . $filebase . '.' .
       $language . '.ics';

# Write output
$charsetlanguage = ';CHARSET=' . $encoding . ';LANGUAGE=' . $language;

open ICS, '>', $icsfile or die "Cannot create $icsfile: $!\n";
binmode ICS;
&calline(ICS, 'BEGIN:VCALENDAR');
&calline(ICS, 'VERSION:2.0');
&calline(ICS, 'PRODID:-//Debian//Events//' . uc($language));
&calline(ICS, 'CALSCALE:GREGORIAN'); # Just for completeness...
&calline(ICS, 'COMMENT:Auto-generated from the Debian Events web pages');
&calline(ICS, 'BEGIN:VEVENT');
&calline(ICS, 'UID:' . $abbr . '@events.www.debian.org');
&calline(ICS, 'URL:' . $url);
&calline(ICS, 'SUMMARY' . $charsetlanguage . ':' . $pagetitle); ###
&calline(ICS, 'DESCRIPTION' . $charsetlanguage . ':' . $pagetitle . ' - ' . $intro);
&calline(ICS, 'CONTACT' . $charsetlanguage . ':' . $coord)
	unless $coord eq 'none';
&calline(ICS, 'CLASS:PUBLIC');
&calline(ICS, 'CATEGORIES:CONFERENCE');
&calline(ICS, 'X-EPOCAGENDAENTRYTYPE:EVENT'); # My Revo+ adds this on export
&calline(ICS, 'DTSTART:'. $startstring);
&calline(ICS, 'DTEND:' . $endstring);
# &calline(ICS, 'TRANSP:TRANSPARENT'); # Can be argued
&calline(ICS, 'LOCATION' . $charsetlanguage . ':' . $where);
&calline(ICS, 'LAST-MODIFIED:' . POSIX::strftime('%Y%m%dT%H%M%SZ', gmtime($mtime)));
&calline(ICS, 'END:VEVENT');
&calline(ICS, 'END:VCALENDAR');
close ICS;

exit 0;

# Print a calendar line, chopping it up at 75 characters if necessary
# Symbian devices have problems with the line splitting, they concatenate
# the lines incorrectly (not removing the initial whitespace). Thus I
# try to split at whitespace, if possible.
sub calline
{
	my ($handle, $line) = @_;
	while (length $line > 74)
	{
		$len = rindex($line,' ',75);
		$len = 74 if -1 == $len;
		-- $len while substr($line, $len, 1) eq '\\';
		print $handle substr($line, 0, $len), "\r\n ";
		$line = substr($line, $len);
	}
	print $handle $line, "\r\n";
}

# Return the ISO-8859-1 character that corresponds to the given entity
sub decodeentity
{
	my $ent = shift;
	# Start at one to avoid decoding &nbsp;
	for (my $i = 1; $i < $#entities; ++ $i)
	{
		return chr($i + 160) if $entities[$i] eq $ent;
	}
	return $ent;
}

__END__
-- Here are two sample files generated from my Revo+, for a sample event --

* Exported by Agenda:
BEGIN:VCALENDAR 
VERSION:1.0 
BEGIN:VEVENT 
X-EPOCAGENDAENTRYTYPE:EVENT 
DESCRIPTION:Debian Test Event 
UID:4 
CLASS:PUBLIC 
DCREATED:20021229T000000Z 
LAST-MODIFIED:20021229T140600Z 
DTSTART:20030101T000000Z 
DTEND:20030104T000000Z 
END:VEVENT 
END:VCALENDAR 

* Exported using vCAL:
BEGIN:VCALENDAR
PRODID:-//vCalendar for EPOC
VERSION:1.0
BEGIN:VEVENT
CATEGORIES:MISCELLANEOUS
DTSTART:20030101T000000
DTEND:20030103T000000
SUMMARY:Debian Test Event
PRIORITY:1
END:VEVENT
END:VCALENDAR

-- DebConf 3 entry as exported from my P800 --
* Note the missing whitespace at the start of continuation lines
* Note 24:00 as end date
BEGIN:VCALENDAR
VERSION:1.0
BEGIN:VEVENT
UID:89
SUMMARY:Debian Conference 3
DESCRIPTION;ENCODING=QUOTED-PRINTABLE;CHARSET=UTF-8:=
Debian=20Conference=203=20-=20Debconf=20=C3=A4r=20en=20konferens=20med,=
=20f=C3=B6r=20och=20av=20Debianutvecklare.=20Ickeutvecklare=20f=C3=A5r=20=
g=C3=A4rna=20bes=C3=B6ka,=20men=20=C3=A4r=20inte=20konferensens=20huvud=
m=C3=A5lgrupp.=20
DTSTART:20030718T000000
DTEND:20030719T240000
X-EPOCAGENDAENTRYTYPE:EVENT
CLASS:PUBLIC
LOCATION:Oslo, Norge
DCREATED:20030412T000000
LAST-MODIFIED:20030412T205100
CATEGORIES:X-CONFERENCE
PRIORITY:0
STATUS:NEEDS ACTION
END:VEVENT
END:VCALENDAR
