#!/usr/bin/perl

# (c) 1999 Debian and Randolph Chung. Licensed under the GPL. <tausq@debian.org>

use lib '.';
use strict vars;
#use Apache::Registry;
use CGI;
use Util;
use URI::Escape;
use Net::LDAP qw(:all);

# Global settings...
my %config = &Util::ReadConfigFile;

my $query = new CGI;
my $id = $query->param('id');
my $authtoken = $query->param('authtoken');
my $password = &Util::CheckAuthToken($authtoken);
my $dosearch = $query->param('dosearch');
my $searchdn = $query->param('searchdn');
my $ldap = undef;

my $proto = ($ENV{HTTPS} ? "https" : "http");

sub DieHandler {
  $ldap->unbind if (defined($ldap));
}

$SIG{__DIE__} = \&DieHandler;

if (!$dosearch) {
  # No action yet, send back the search form...
  print "Content-type: text/html\n\n";
  open (F, "<$config{websearchhtml}") || &Util::HTMLError($!);
  while (<F>) {
    s/~id~/$id/g;
    s/~authtoken~/$authtoken/g;    
    print;
  }
  close F;
} else {
  # Go ahead and construct the search terms
  my %searchdata = (
    cn             => { fuzzy => 'cnfuzzy', formname => 'cn' }, # First name
    mn             => { fuzzy => 'mnfuzzy', formname => 'mn' }, # Middle name
    sn             => { fuzzy => 'snfuzzy', formname => 'sn' }, # Last name
    email          => { fuzzy => 'emailfuzzy', formname => 'email' }, # email
    uid            => { fuzzy => 'uidfuzzy', formname => 'uid' }, # Login name
    ircnick        => { fuzzy => 'ircfuzzy', formname => 'ircnick' }, # IRC nickname
    keyfingerprint => { fuzzy => 'fpfuzzy', formname => 'fingerprint' }, # PGP/GPG fingerprint
    c              => { formname => 'country'}, # Country
  );

  # Do a little preprocessing - strip the spaces out of the fingerprint
  my $temp = $query->param('fingerprint');
  $temp =~ s/ //g; $query->param('fingerprint', $temp);

  # go through %searchdata and pull out all the search criteria the user
  # specified...
  my $filter = undef;
  foreach (keys(%searchdata)) {
    if ($query->param($searchdata{$_}{formname})) {    
      if ($query->param($searchdata{$_}{fuzzy})) {
        # fuzzy search
	$filter .= "($_~=".$query->param($searchdata{$_}{formname}).")";
      } else {
	$filter .= "($_=".$query->param($searchdata{$_}{formname}).")";
      }
    }
  }
  
  # Vacation is a special case
  $filter .= "(onvacation=*)" if ($query->param('vacation'));

  # AND all the search terms together
  $filter = "(&$filter)";
  
  # Read in the result template...
  my ($lineref, $dataspecref) = ParseResult($config{websearchresulthtml});

  # Now, we are ready to connect to the LDAP server.
  $ldap = Net::LDAP->new($config{ldaphost}) || &Util::HTMLError($!);
  my $auth = 0;
  my $mesg;

  if ($id && $password) {
    $mesg = $ldap->bind("uid=$id,$config{basedn}", password => $password);
    $mesg->sync;
    $auth = ($mesg->code == LDAP_SUCCESS);
  }

  if (!$auth) { # Not authenticated - either the above failed, or no password supplied
    $ldap->bind;
  }

#  &Util::HTMLPrint("Searching in $config{basedn} for $filter...\n");
  
  $mesg = $ldap->search(base   => ($searchdn ? $searchdn : $config{basedn}),
                        filter => ($searchdn ? "(uid=*)" : $filter));
  $mesg->code && &Util::HTMLError($mesg->error);

  my %outsub; # this hash will contain all the substitution tokens in the output
  $outsub{count} = $mesg->count; # Count number of requests, also ensures we're done with the search
  $outsub{auth} = $authtoken;
  $outsub{authtoken} = $authtoken; # alias
  $outsub{id} = $id;
  $outsub{searchresults} = undef;
  
  my $entries = $mesg->as_struct; # entries contain a hashref to all the search results
  my ($dn, $attr, $data); 

  # Format the output....
  foreach $dn (sort {$entries->{$a}->{sn}->[0] <=> $entries->{$b}->{sn}->[0]} keys(%$entries)) {
    $data = $entries->{$dn};

    # These are local variables.. i have enough global vars as it is... <sigh>
    my ($ufdn, $login, $name, $email, $fingerprint, $address, $latlong, $vacation, $created, $modified) = undef;
    
    $ufdn = $dn; # Net::LDAP does not have a dn2ufn function, but this is close enough :)
    
    # Assemble name, attach web page link if present.
    $name = $data->{cn}->[0]." ".$data->{mn}->[0]." ".$data->{sn}->[0];
    if (my $url = $data->{labeledurl}->[0]) {
      $name = "<a href=\"$url\">$name</a>";
    }
    
    # Add links to all email addresses
    foreach (@{$data->{emailforward}}) {
      $email .= "<br>" if ($email);
      $email .= "<a href=\"mailto:$_\">$_</a>";
    }

    # Format PGP/GPG key fingerprints
    my $fi;
    foreach (@{$data->{keyfingerprint}}) {
      $fingerprint .= "<br>" if ($fingerprint);
      $fingerprint .= sprintf("%d:- <a href=\"fetchkey.cgi?fingerprint=%s\">%s</a>", ++$fi, $_, &Util::FormatFingerPrint($_));
    }
    
    # Assemble addresses
    $address = $data->{postaladdress}->[0] || "- unlisted -";
    $address =~ s/\$/<br>/g;
    $address .= "<br>".$data->{l}->[0]."<br>".&Util::LookupCountry($data->{c}->[0])."<br>".$data->{postalcode}->[0];

    # Assemble latitude/longitude
    $latlong  = $data->{latitude}->[0] || "none";
    $latlong .= " / ";
    $latlong .= $data->{longitude}->[0] || "none";    

    # Modified/created time. TODO: maybe add is the name of the creator/modifier
    $modified = &Util::FormatTimestamp($data->{modifytimestamp}->[0]);
    $created =  &Util::FormatTimestamp($data->{createtimestamp}->[0]);

    # Link in the debian login id 
    $login = $data->{uid}->[0]."\@debian.org";
    $login = "<a href=\"mailto:$login\">$login</a>";
    
    # See if the user has a vacation message
    $vacation = $data->{onvacation}->[0];

    # OK, now generate output... (i.e. put the output into the buffer )
    $outsub{searchresults} .= '<table border=2 cellpadding=2 cellspacing=0 bgcolor="#DDDDDD" width="80%">';
    $outsub{searchresults} .= '<tr><th bgcolor="#44CCCC" colspan=2><font size=+1>'."$name</font> ";
    $outsub{searchresults} .= "($ufdn)</th></tr>\n";
    
    if ($vacation) {
      $outsub{searchresults} .= "<tr><td colspan=2 align=center><b>$vacation</b></td></tr>\n";
    }

    $outsub{searchresults} .= FormatEntry($dataspecref->{uid}, $login);
    $outsub{searchresults} .= FormatEntry($dataspecref->{ircnick}, $data->{ircnick}->[0]);
    $outsub{searchresults} .= FormatEntry($dataspecref->{loginshell}, $data->{loginshell}->[0]);
    $outsub{searchresults} .= FormatEntry($dataspecref->{fingerprint}, $fingerprint);
    
    if ($auth) {
      # Some data should only be available to authorized users...
      if ($id eq $data->{uid}->[0]) {
        $outsub{searchresults} .= FormatEntry($dataspecref->{email}, $email);
      }
      $outsub{searchresults} .= FormatEntry($dataspecref->{address}, $address);
      $outsub{searchresults} .= FormatEntry($dataspecref->{latlong}, $latlong);
      $outsub{searchresults} .= FormatEntry($dataspecref->{phone}, $data->{telephonenumber}->[0] || "- unlisted -");
      $outsub{searchresults} .= FormatEntry($dataspecref->{fax}, $data->{fascimiletelephonenumber}->[0] || "- unlisted -");
    }
    $outsub{searchresults} .= FormatEntry($dataspecref->{created}, $created);
    $outsub{searchresults} .= FormatEntry($dataspecref->{modified}, $modified);
    
    $outsub{searchresults} .= "</table>";
    
    # If this is ourselves, present a link to do mods
    if ($auth && ($id eq $data->{uid}->[0])) { #TODO: extract this string into a url for translation...
     $outsub{searchresults} .= "<a href=\"$proto://$ENV{SERVER_NAME}/$config{webupdateurl}?id=$id&authtoken=$authtoken&editdn=".uri_escape($dn, "\x00-\x40\x7f-\xff")."\">Edit my settings</a>\n";
    }
    
    $outsub{searchresults} .= "<br><br><br>\n";
  }
  
  # Finally, we can write the output... yuck...
  &Util::HTMLSendHeader;
  foreach (@$lineref) {
    if (/<\?ifauth(.+?)\?>/) {
      $_ = ($auth ? $1 : "");
    } elsif (/<\?ifnoauth(.+?)\?>/) {
      $_ = ($auth ? "" : $1);
    }
    s/~(.+?)~/$outsub{$1}/g;
    print;
  }

  $ldap->unbind;
}

sub ParseResult {
  # Reads the output html file and find out how the output should be named
  # -- this gives us a way to do translations more easily
  # Returns the contents of the template (w/o the searchresult portion) and
  # the output specification
  my $fn = shift;
  my $insec = 0;
  my @lines;
  my %hash;
  
  open (F, "<$fn") || &Util::HTMLError("$fn: $!");
  while (<F>) {
    if (!$insec) {
      if (/<\?searchresults/i) {
        $insec = 1;
	push(@lines, "~searchresults~\n"); # Leave token so we know where to put the result
      } else {
        push(@lines, $_);
      }
    } else {
      if (/searchresults\?>/i) {
        $insec = 0;
      } else {
        if (!/^\s*#/) {
	  s/^ *\(//; 
	  s/\) *$//; # remove leading/trailing () and spaces
	  chomp;
	  my ($desc, $attr) = split(/, /, $_, 2);
	  $hash{$attr} = $desc;
        }
      }
    }
  }
  close F;
  return (\@lines, \%hash);
}

sub FormatEntry {
  my ($key, $val) = @_;
  
  return "<tr><td align=right><b>$key:</b></td><td>&nbsp;$val</td></tr>\n";
}
