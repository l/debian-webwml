#!/usr/bin/perl

# $Id$
# (c) 1999 Randolph Chung. Licensed under the GPL. <tausq@debian.org>

use lib '.';
use strict vars;
#use Apache::Registry;
use CGI;
use Util;
use URI::Escape;
use Net::LDAP qw(:all);

my %config = &Util::ReadConfigFile;

my $query = new CGI;
my $proto = ($ENV{HTTPS} ? "https" : "http");

my $id = $query->param('id');
my $authtoken = $query->param('authtoken');
my $password = &Util::CheckAuthToken($authtoken);
my $editdn = $query->param('editdn');

if (!($id && $password)) {
  print "Location: $proto://$ENV{SERVER_NAME}/$config{webloginurl}\n\n";
  exit;
} 

my $ldap;

sub DieHandler {
  $ldap->unbind if (defined($ldap));
}

$SIG{__DIE__} = \&DieHandler;

$ldap = Net::LDAP->new($config{ldaphost});
my $auth = 0;
my $mesg;
$mesg = $ldap->bind($editdn, password => $password);
$mesg->sync;
$auth = ($mesg->code == LDAP_SUCCESS);

if (!$auth) {
  $ldap->unbind;
  &Util::HTMLError("You have not been authenticated. Please <a href=\"https://$ENV{SERVER_NAME}/$config{webloginurl}\">Login</a>");
}

# Authenticated....
# Get our entry...
$mesg = $ldap->search(base   => $editdn,
                      filter => "uid=*");
$mesg->code && &Util::HTMLError($mesg->error);
  
my $entries = $mesg->as_struct;
if ($mesg->count != 1) {
  # complain and quit
}
  
my @dns = keys(%$entries);
my $entry = $entries->{$dns[0]};

if (!($query->param('doupdate'))) {
  # Not yet update, just fill in the form with the current values
  my %data;
  
  # Fill in %data
  # First do the easy stuff - this catches most of the cases
  foreach (keys(%$entry)) {
    $data{$_} = $entry->{$_}->[0];
  }
  
  # Now we have to fill in the rest that needs some processing...
  $data{id} = $id;
  $data{authtoken} = $authtoken;
  $data{editdn} = $editdn;
  $data{staddress} = $entry->{postaladdress}->[0];
  $data{staddress} =~ s/\$/\n/;
  $data{countryname} = &Util::LookupCountry($data{c});
  
  $data{email} = join(", ", @{$entry->{emailforward}});  

  # finally we can send output...
  my ($sub, $substr);
  &Util::HTMLSendHeader;
  open (F, "<$config{webupdatehtml}") || &Util::HTMLError($!);
  while (<F>) {
    s/~(.+?)~/$data{$1}/g;
    print;
  }
  close F;
  
} else {
  # Actually update stuff...
  my ($newpassword, $newstaddress);
  
  &Util::FixParams($query);

  if (($query->param('labeledurl')) && 
      ($query->param('labeledurl') !~ /^https?:\/\//i)) {
    &Util::HTMLError("Your homepage URL is invalid");
  }
  
  if ($query->param('newpass') && $query->param('newpassvrfy')) {
    if ($query->param('newpass') ne $query->param('newpassvrfy')) {
      # passwords don't match...
      &Util::HTMLError("The passwords you specified do not match. Please go back and try again.");
    }    
    # create a md5 crypted password
    $newpassword = '{crypt}'.crypt($query->param('newpass'), &Util::CreateCryptSalt(1));
    
    &Util::LDAPUpdate($ldap, $editdn, 'userPassword', $newpassword);
    &Util::UpdateAuthToken($authtoken, $query->param('newpass'));
  }  

  $newstaddress = $query->param('staddress');
  $newstaddress =~ s/\n/\$/m;
  
  my ($lat, $long);
  ($lat, $long) = &Util::CheckLatLong($query->param('latitude'), 
                                      $query->param('longitude'));
  
  &Util::LDAPUpdate($ldap, $editdn, 'postalAddress', $newstaddress);
  &Util::LDAPUpdate($ldap, $editdn, 'l', $query->param('l'));
  &Util::LDAPUpdate($ldap, $editdn, 'latitude', $lat);
  &Util::LDAPUpdate($ldap, $editdn, 'longitude', $long);
  &Util::LDAPUpdate($ldap, $editdn, 'c', $query->param('country'));
  &Util::LDAPUpdate($ldap, $editdn, 'postalcode', $query->param('postalcode'));
  &Util::LDAPUpdate($ldap, $editdn, 'telephoneNumber', $query->param('telephonenumber'));
  &Util::LDAPUpdate($ldap, $editdn, 'facsimileTelephoneNumber', $query->param('facsimiletelephonenumber'));
  &Util::LDAPUpdate($ldap, $editdn, 'loginShell', $query->param('loginshell'));
  &Util::LDAPUpdate($ldap, $editdn, 'emailForward', $query->param('email'));
  &Util::LDAPUpdate($ldap, $editdn, 'privatesub', $query->param('privatesub'));
  &Util::LDAPUpdate($ldap, $editdn, 'ircNick', $query->param('ircnick'));
  &Util::LDAPUpdate($ldap, $editdn, 'icquin', $query->param('icquin'));
  &Util::LDAPUpdate($ldap, $editdn, 'labeledUrl', $query->param('labeledurl'));
  &Util::LDAPUpdate($ldap, $editdn, 'onvacation', $query->param('onvacation'));

  # when we are done, reload the page with the updated details.
  my $url = "$proto://$ENV{SERVER_NAME}/$config{webupdateurl}?id=$id&authtoken=$authtoken&editdn=";
  $url .= uri_escape($editdn, "\x00-\x40\x7f-\xff");
  print "Location: $url\n\n";  
}

$ldap->unbind;

