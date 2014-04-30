#!/usr/bin/perl

# (c) 2011 David Prévot <taffit@debian.org>
#
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This script prepares a mail template for the regular user ping.

# TODO:
# Pick the name and email address from $DEBFULLNAME and $DEBEMAIL.
# Make the script work even from another directory.

use strict;
use warnings;

# User file read in FILE
die ("Usage: ./ping.pl {com,edu,gov,org}/<file>.wml [ <mail>.eml ]") if !defined $ARGV[0] ;
my $file = "$ARGV[0]" ;
open(FILE,"$file") or die("Can't open $file $!");

my $fullname = $file;
$fullname =~ s/\.wml$//;
my $name = $fullname;
$name =~ s/^.*\///;

# Email file written in EML
if (!defined($ARGV[1])){
	open(EML,">$name.eml") or die("Can't open $name.eml $!");}
else{
	open(EML,">$ARGV[1]") or die("Can't open $ARGV[1] $!");}

my ($address,$url,$text);
while (<FILE>){
	chomp;
	if ($_=~s/^# From: //){
		$address = $_;}
	elsif ($_=~s/^.*<define-tag pagetitle>(.*)<\/define-tag>/$1/){
		$text = "> $_\n";}
	elsif ($_=~s/^.*<define-tag webpage>(.*)<\/define-tag>/$1/){
		$url = $_;}
	elsif ($_=~s/<p>//){
		$text .= "> $_\n";}
	elsif ($_!~m/^#/ and $_!~m/^$/ and $_!~m/^<\/p>$/){
		$text .= "> $_\n";}
}
close(FILE);

my $mail = "To: $address\n";

$mail .= <<'EOT';
From: =?UTF-8?B?RGF2aWQgUHLDqXZvdA==?= <taffit@debian.org>
Reply-To: webmaster@debian.org
CC: webmaster@debian.org
Subject: Are you still using Debian?
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

Some time ago, you provided a description [1] of how your organization
uses Debian.

EOT

$mail .= "   1: https://www.debian.org/users/$fullname\n\n";
$mail .= $text;

$mail .= <<'EOT';

If you are still using Debian, you may wish to update these data, with
a paragraph or two describing how your organization uses Debian. Try
to include details such as the number of workstations/servers, the
software they run (no need to specify version), and why you chose
Debian over the competition.


Could you please provide us the name of your organization in the form
of “division, organization, city/town (optional), country”?


EOT

if (defined($url)){
	$mail .= <<'EOT';
Is the home page link [2] still correct?
========
The home page link [2] is now redirected [3], could you please provide
an updated one, or confirm that the last link [3] is correct?
<<<<<<<<

EOT
	$mail .= "   2: $url";
}
else{
	$mail .= "You may also wish to provide a home page link if you have one."
}

$mail .= <<'EOT';



Thanks in advance for you answer.

Regards

David, for the Debian website
EOT

printf(EML $mail);
close(EML);
