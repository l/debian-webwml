#!/usr/bin/perl -w

# Store in Perl hashes the 639-3 and 3166 isocodes
# Store that Perl hashes in {languages,countries}.{pag,dir}

use strict;
use warnings;
use SDBM_File;

# make the build fail if isoquery is not available
`isoquery -h > /dev/null`;

my @languages=`isoquery -i 639-3`;
my (%languages,%countries);
dbmopen(%languages,'../languages',0644) or die($!);
foreach ( @languages ) {
	m/^(\w{3})\t\w\t\w\t(\w{2})?\t(\w{3})?\t(.*)$/; 
	if (defined $2)    { $languages{$2} = $4; }
	elsif (defined $3) { $languages{$3} = $4; }
	elsif (defined $1) { $languages{$1} = $4; }
}
dbmclose(%languages) or die($!);

my @countries=`isoquery -c`;
dbmopen(%countries,'../countries',0644) or die($!);
foreach ( @countries ) {
	m/^(\w{2})\t\w{3}\t\d{3}\t(.*)$/;
	if (defined $1)	{ $countries{$1} = $2; }
}
dbmclose(%countries) or die($!);
