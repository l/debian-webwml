#!/usr/bin/perl

# $Id$
# (c) 1999 Randolph Chung. Licensed under the GPL. <tausq@debian.org>

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

if ($proto eq "http" || !($query->param('username')) || !($query->param('password'))) {
  print "Location: https://$ENV{SERVER_NAME}/$config{webloginurl}\n\n";
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
  # HACK HACK HACK
  # Check for md5 password, and update as necessary
  $mesg = $ldap->search(base   => $config{basedn}, 
                        filter => "(uid=$username)");
  $mesg->code && &Util::HTMLError($mesg->error);
  my $entries = $mesg->as_struct;
  my $dn = (keys %$entries)[0];
  my $oldpassword = $entries->{$dn}->{userpassword}->[0];
  if ($oldpassword !~ /^{crypt}\$1\$/) {
    # Update their password to md5
    open (LOG, ">>$config{weblogfile}");
    print LOG scalar(localtime);
    print LOG ": Updating MD5 password for $dn\n";
    close LOG;
    my $newpassword = '{crypt}'.crypt($password, &Util::CreateCryptSalt(1));
    &Util::LDAPUpdate($ldap, $dn, 'userPassword', $newpassword);
  }
  ## END HACK HACK HACK
  
  my $cryptid = &Util::SavePasswordToFile($username, $password, $cipher);

  if ($query->param('update')) {
    my $url = "$proto://$ENV{SERVER_NAME}/$config{webupdateurl}?id=$username&authtoken=$cryptid,$hrkey&editdn=";
    $url .= uri_escape("uid=$username,$config{basedn}", "\x00-\x40\x7f-\xff");
    print "Location: $url\n\n";
  } else {
    my $url = "$proto://$ENV{SERVER_NAME}/$config{websearchurl}?id=$username&authtoken=$cryptid,$hrkey";
    print "Location: $url\n\n";
  }

  $ldap->unbind;
} else {
  print "Content-type: text/html\n\n";
  print "<html><body><h1>Not authenticated</h1></body></html>\n";
}

