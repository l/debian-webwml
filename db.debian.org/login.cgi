#!/usr/bin/perl

# (c) 1999 Debian and Randolph Chung. Licensed under the GPL. <tausq@debian.org>

use lib '.';
use strict;
#use Apache::Registry;
use CGI;
use Util;
use URI::Escape;
use Crypt::Blowfish;
use Net::LDAP qw(:all);

my %config = &Util::ReadConfigFile;

my $query = new CGI;
my $proto = ($ENV{HTTPS} ? "https" : "http");

if (!($query->param('username')) || !($query->param('password'))) {
  print "Location: $proto://$ENV{SERVER_NAME}/$config{webloginurl}\n\n";
  exit;
}

my $key = &Util::CreateKey($config{blowfishkeylen}); # human-readable version of the key
my $hrkey = unpack("H".($config{blowfishkeylen}*2), $key);
my $cipher = new Crypt::Blowfish $key;

my $ldap = Net::LDAP->new($config{ldaphost}) || &Util::HTMLError($!);

my $username = $query->param('username');
my $password = $query->param('password');
my $binddn = "uid=$username,$config{basedn}";

my $mesg = $ldap->bind($binddn, password => $password);
$mesg->sync;

if ($mesg->code == LDAP_SUCCESS) {
  my $cryptid = &Util::SavePasswordToFile($username, $password, $cipher);

  if ($query->param('update')) {
    my $url = "$proto://$ENV{SERVER_NAME}/$config{webupdateurl}?id=$username&authtoken=$cryptid:$hrkey&editdn=";
    $url .= uri_escape("uid=$username,$config{basedn}", "\x00-\x40\x7f-\xff");
    print "Location: $url\n\n";
  } else {
    print "Location: $proto://$ENV{SERVER_NAME}/$config{websearchurl}?id=$username&authtoken=$cryptid:$hrkey\n\n";
  }

  $ldap->unbind;
} else {
  print "Content-type: text/html\n\n";
  print "<html><body><h1>Not authenticated</h1></body></html>\n";
}
