#!/usr/bin/perl

# (c) 1999 Debian and Randolph Chung. Licensed under the GPL. <tausq@debian.org>

use lib '.';
use strict vars;
#use Apache::Registry;
use CGI;
use Util;
use Net::LDAP qw(:all);

my %config = &Util::ReadConfigFile;
my $proto = ($ENV{HTTPS} ? "https" : "http");

my $query = new CGI;
my $id = $query->param('id');
my $authtoken = $query->param('authtoken');
&Util::ClearAuthToken($authtoken);
my $doneurl = $query->param('done') || "$config{websearchurl}";

&Util::ClearAuthToken($authtoken);

print "Location: $proto://$ENV{SERVER_NAME}/$doneurl\n\n";
