#!/usr/bin/perl

use strict;
use CGI;
use Util;

# Global settings...
my %config = &Util::ReadConfigFile;

my $query = new CGI;
print "Content-type: text/plain\n\n";

my $fp = $query->param('fingerprint');

if ($fp) {
  my $key = &Util::FetchKey($fp);
  if ($key) {
    print $key;
  } else {
    print "Sorry, no key found matching fingerprint $fp\n";
  }
} else {
  print "No fingerprint given\n";
}

exit 0;

