#!/usr/bin/perl -w
#
# This script creates ICS (Internet Calendar, RFC 2445) files for the Debian
# events, using the WML source files as input.
#
# Run this script with the name of the .wml input file and .ics output file
# names as parameters to create the .ics file

# Originally written 2002-12-29 by Peter Karlsson <peterk@debian.org>
# © Copyright 2002 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use Time::Local;
use integer;
use POSIX;

# Check parameters
if ($#ARGV != 1)
{
	die "Usage: $0 input.wml output.lang.ics\n";
}

($wmlfile, $icsfile) = @ARGV;

# Gather data
open INP, $wmlfile or die "Cannot read $wmlfile: $!\n";

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

# Kill off HTML code
$coord =~ s/<[^>]+>//g;
$intro =~ s/<[^>]+>//g;

# Collapse excessive spacing
$intro =~ s/\s{2,}/ /g;

# Add backslashes in front of commas in the descriptive texts
$intro =~ s/,/\\,/g;
$pagetitle =~ s/,/\\,/g;
$where =~ s/([,;])/\\$1/g;

# Convert dates into correct representation
$startstring = sprintf("%04d%02d%02dT000000", split(/-/, $startdate));
$endstring   = sprintf("%04d%02d%02dT235959", split(/-/, $enddate));

# Figure out the language and  encoding of the text, by recursing upwards
# until we find a .wmlrc file
$encoding = '';
$language = '';
$wmlrcdir = '.';
while (! -e $wmlrcdir . '/.wmlrc')
{
	$wmlrcdir .= '/..';
	die "Unable to find .wmlrc file\n" if $wmlrcdir eq '';
}
open WMLRC, $wmlrcdir . '/.wmlrc'
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

# Construct the canonic URL to this file
$filebase = $wmlfile;
$filebase =~ s(^.*/([^/]+)$)($1);
$filebase =~ s(^([^/].*)\.wml)($1);
$url = 'http://www.debian.org/events/' . $year . '/' . $filebase . '.' .
       $language . '.ics';

# Write output
$charsetlanguage = ';CHARSET=' . $encoding . ';LANGUAGE=' . $language;

open ICS, '>' . $icsfile or die "Cannot create $icsfile: $!\n";
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
&calline(ICS, 'CONTACT:' . $coord) unless $coord eq 'none';
&calline(ICS, 'CLASS:PUBLIC');
&calline(ICS, 'CATEGORIES:CONFERENCE');
&calline(ICS, 'X-EPOCAGENDAENTRYTYPE:EVENT'); # My Revo+ adds this on export
&calline(ICS, 'DTSTART:'. $startstring);
&calline(ICS, 'DTEND:' . $endstring);
&calline(ICS, 'TRANSP:TRANSPARENT'); # Can be argued
&calline(ICS, 'LOCATION' . $charsetlanguage . ':' . $where);
&calline(ICS, 'LAST-MODIFIED:' . POSIX::strftime('%Y%m%dT%H%M%SZ', gmtime($mtime)));
&calline(ICS, 'END:VEVENT');
&calline(ICS, 'END:VCALENDAR');
close ICS;

exit 0;

# Print a calendar line, chopping it up at 75 characters if necessary
sub calline
{
	my ($handle, $line) = @_;
	while (length $line > 74)
	{
		$len = 74;
		-- $len while substr($line, $len, 1) eq '\\';
		print $handle substr($line, 0, $len), "\r\n ";
		$line = substr($line, $len);
	}
	print $handle $line, "\r\n";
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
