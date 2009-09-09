#!/usr/bin/perl -w
# arch_size.pl -- html output of archive size per architecture
# Copyright (C) Simon Paillard Nov 2008

use strict;
use LWP::UserAgent;

# Parameters
my $inputfile="http://ftp-master.debian.org/~joerg/arch-space";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $inputfile);
my $res = $ua->request($req);

## Check the outcome of the response
$res->is_success or die 'Input file cannot be fetched';

my $arch_space = $res->content;

my $total ;

my $space;

for my $line (split("\n",$arch_space)) {
	if ($line =~ /^([\w-]+)\s*\|(\d+)\s*$/) {
		my $size = $2/1000000000;
		$total += $2 ;
		$space->{$1}=$size;
	}
	if ($line =~ /^(\d+)$/) {
		my $size = $1/1000000000;
		$total += $1 ;
		$space->{'source'}=$size;
	}
}

printf "<tr><td>source</td>\t<td>%.0f</td></tr>\n", $space->{"source"};

foreach my $key (sort keys %$space) {
	printf "<tr><td>$key</td>\t<td>%.0f</td></tr>\n", $space->{$key} unless ($key eq "source");
}

$total /= 1000000000 ;
printf "<tr><td>Total</td>\t<td>%.0f</td></tr>\n", $total ;
