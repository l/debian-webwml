#!/usr/bin/perl -w
# testvendors.pl - My evil vendor testing script
# You will need wget for this baby to work.
# Is the script evil or the vendors? Let the script decide
# Written by Craig Small <csmall@debian.org> 
# Copyright 2000 SPI Inc, released under the GPL if anyone would bother with it
#
# TODO
# - Vendors should be required to include a specific tag in the 'Debian'
#   webpages so that the script can easily detect if the page 
#   (deburl) points to the proper place. For the time being, the
#   script just looks for 'Debian' (case-insensitive) in the page

my $dir = '/etc/ssl/ca-global';
my $capath = -d $dir ? "--ca-directory=$dir" : '';

sub sanitize (@)
{
# Sanitize characters in the URL with their encoded entities
    my ($url) = @_;
    $url =~ s/&amp;/&/g;
    $url =~ s/'/%27/g;
    $url =~ s/ /%20/g;
    $url =~ s/!/%21/g;
    return $url;
}
sub test_vendor(@)
{
    ($name, $url, $deburl,$email) = @_;
    
    if ($name eq "") {
        print "E: No vendor name, is something borked?\n";
        return;
    }
    if ($email eq "") {
        print "E: Vendor \"$name\" doesn't have an email address!\n";
    }
    if ($url eq "") {
        print "E: Vendor \"$name\" <$email> doesn't have a webpage!\n";
    } else {
        print "N: Checking $url\n";
        my $turl = sanitize($url);
        $vendpage = `wget $capath -t 1 -O/dev/null '$turl' 2>&1`;
        if ($vendpage =~ /: Host not found./)
        {
            print "E: Vendor \"$name\" <$email> cannot look up web page $url\n";
        } elsif ($vendpage =~ /ERROR 404: Not Found./)
        {
            print "E: Vendor \"$name\" <$email> $url page not found (404)\n";
        }
    }
    if ($deburl eq "") {
        print "W: Vendor \"$name\" <$email> doesn't have a Debian webpage.\n";
    } else {
        print "N: Checking $deburl\n";
        my $turl = sanitize($deburl);
        $vendpage = `wget $capath -t 1 -O- '$turl' 2>&1`;
        if ($vendpage =~ /: Host not found./)
        {
            print "E: Vendor \"$name\" <$email> cannot look up web page $deburl\n";
        } elsif ($vendpage =~ /ERROR 404: Not Found./)
        {
            print "E: Vendor \"$name\" <$email> $deburl page not found (404)\n";
        } elsif ( $vendpage !~ /[Dd][Ee][Bb][Ii][Aa][Nn]/) 
        {
            print "E: Vendor \"$name\" <$email> $deburl doesn't mention Debian\n";
        }
    }

}

sub usage
{
    print "Usage $0 [-dh] <filename>\n";
    exit 1;
}

our($opt_d, $opt_h);
my $debug = 0;
use Getopt::Std;
getopts('dh');

usage() if $opt_h;
$debug = 1 if defined($opt_d);
print STDERR "DEBUG: Enabling debug mode ($debug)\n" if $debug;
$|=1 if $debug;

my $filename;
$filename = $ARGV[0];
if ( $opt_h or ! defined($filename) or $filename eq "")
{
    print STDERR "ERROR: Missing filename argument\n";
    usage();
}
print STDERR "DEBUG: Reading $filename\n" if $debug;
open IN, $filename or die "Cannot open $filename : $!";

$invendor = 0;
$vendorname = "";
$vendorurl = "";
$vendordeburl = "";
$vendoremail = "";
my $numline = 0;
while ($line = <IN>) {
        chomp $line;
        $numline++;
        print STDERR "DEBUG: Reading line $numline\n" if $debug > 1;

        next if $line =~ /^\#/ ; # Skip comments

        if ($line =~ /^\s*<vendor name="([^>]+)"/) {
            $vendorname = $1;
            $invendor = 1;
            print STDERR "DEBUG: Found vendor $vendorname ($filename: $numline)\n" if $debug;
        }
     if ($invendor) {  # We are in a vendor entry
        if ($line =~ /^[\t ]*url="([^>]+)"/) {
            $vendorurl = $1;
            print STDERR "DEBUG: Found URL $vendorurl ($filename: $numline)\n" if $debug;
        }
        if ($line =~ /^[\t ]*deburl="([^>]+)"/) {
            $vendordeb = $1;
            print STDERR "DEBUG: Found Debian URL $vendordeb ($filename: $numline)\n" if $debug;
        }
        if ($line =~ /^[\t ]*contacturl="mailto:([^>]+)"/) {
            $vendoremail = $1;
            print STDERR "DEBUG: Found email $vendoremail ($filename: $numline)\n" if $debug;
        }
        if ($line =~ /\/>/) {
            print STDERR "DEBUG: Testing vendor vendorname ($filename: $numline)\n" if $debug;
            test_vendor($vendorname, $vendorurl, $vendordeb,$vendoremail);
            $vendorname = "";
            $vendorurl = "";
            $vendordeburl = "";
            $vendoremail = "";
            $invendor = 0;
        }
        if ($line =~ /<country/ ){
          die "Unexpected closing of vendor tag in line $numline";
        }

    }
}

