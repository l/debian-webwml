#!/usr/bin/perl -w
# arch_size.pl -- html output of archive size per architecture
# Copyright (C) Simon Paillard Nov 2008

use strict;
use LWP::UserAgent;

# Parameters
my $inputfile="http://ftp-master.debian.org/arch-space";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $inputfile);
$ua->timeout("10");
my $res = $ua->request($req);

## Check the outcome of the response
$res->is_success or die 'Input file cannot be fetched';
my $arch_space = $res->content;

my $total ;

my $space;

for my $line (split("\n",$arch_space)) {
	if ((my $arch, my $size) = split (/\s+/, $line)) {
		$space->{$arch}=$size/1000000000 ;
		$total += $size ;
}
}

open (OUTPUT, ">size.data") or die $!;
select OUTPUT;

printf "<tr><td>source</td>\t<td>%.0f</td></tr>\n", $space->{"Source"};

foreach my $key (sort keys %$space) {
	printf "<tr><td>$key</td>\t<td>%.0f</td></tr>\n", $space->{$key} unless ($key eq "Source");
}

$total /= 1000000000 ;
printf "<tr><td>Total</td>\t<td>%.0f</td></tr>\n", $total ;

close OUTPUT;
