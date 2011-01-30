#!/usr/bin/perl
# testvendors.pl - My evil vendor testing script
# You will need wget for this baby to work.
# Is the script evil or the vendors? Let the script decide
# Written by Craig Small <csmall@debian.org> 
# Copyright 2000 SPI Inc, released under the GPL if anyone would bother with it

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
        $vendpage = `wget -t 1 -O/dev/null $url 2>&1`;
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
        $vendpage = `wget -t 1 -O- $deburl 2>&1`;
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

$filename = $ARGV[0];
if ($filename eq "") 
{
    print "Usage $0 <filename>\n";
    exit
}
open IN, $filename or die "Cannot open $filename : $!";

$invendor = 0;
$vendorname = "";
$vendorurl = "";
$vendordeburl = "";
$vendoremail = "";
while (defined($line = <IN>)) {
    if ($invendor) {  # We are in a vendor entry
        if ($line =~ /^[\t ]*<vendor ([^>]+)>/) {
            $vendorname = $1;
        }
        if ($line =~ /^[\t ]*<URL ([^>]+)>/) {
            $vendorurl = $1;
        }
        if ($line =~ /^[\t ]*<URLdeb ([^>]+)>/) {
            $vendordeb = $1;
        }
        if ($line =~ /^[\t ]*<email ([^>]+)>/) {
            $vendoremail = $1;
        }
        if ($line =~ /^[\t ]*<\/vendorentry>/) {
            test_vendor($vendorname, $vendorurl, $vendordeb,$vendoremail);
            $invendor = 0;
            $vendorname = "";
            $vendorurl = "";
            $vendordeburl = "";
            $vendoremail = "";
        }
        if ($line =~ /^[\t ]*<vendorentry>/) {
            die "Unexpected opening vendorentry tag";
        }
    } else {
        if ($line =~ /^[\t ]*<vendorentry>/) {
            $invendor = 1;
        }
        if ($line =~ /^[\t ]*<\/vendorentry>/) {
            die "Unexpected  closing vendorentry tag";
        }
    }
}

