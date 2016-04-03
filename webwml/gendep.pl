#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0];

open my $fh, '<', $file or die "couldn't open file $file: $!\n";
my @templates;
my @locales;
while( my $line = <$fh> ){
    if( $line =~ /^#use wml::debian::(\S+)/ ){
	next if $1 eq 'openrecode';
	push @templates, $1;
    }elsif( $line =~ /bind-gettext-domain\s+domain="(\S+)"/ ){
	push @locales, $1;
    }
}
close $fh or warn "couldn't close file $file: $!\n";

if( @templates || @locales ){
    print "X$file: ";
    print join(' ', map{ s|::|/|g; '$(TEMPLDIR)/'.$_.'.wml' } @templates) if @templates;
    print ' ' if @templates && @locales;
    print join(' ', map{ '$(callXlocale,'.$_.')' } @locales) if @locales;
    print "\n";
}
