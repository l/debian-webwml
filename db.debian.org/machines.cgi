#!/usr/bin/perl
# $Id$

# (c) 1999 Randolph Chung. Licensed under the GPL. <tausq@debian.org>

use lib '.';
use strict vars;
#use Apache::Registry;
use CGI;
use Util;
use Net::LDAP qw(:all);

my (%attrs, @attrorder, %summaryattrs, @summaryorder);

# This defines the description of the fields, and which fields are retrieved
%attrs = ('hostname' => 'Host name',
          'admin' => 'Admin contact',
          'architecture' => 'Architecture',
          'distribution' => 'Distribution',
	  'access' => 'Access',
	  'sponsor' => 'Sponsor',
	  'sponsor-admin' => 'Sponsor admin',
	  'location' => 'Location',
	  'machine' => 'Processor',
	  'memory' => 'Memory',
	  'disk' => 'Disk space',
	  'bandwidth' => 'Bandwidth',
	  'status' => 'Status',
	  'notes' => 'Notes',
	  'sshrsahostkey' => 'SSH host key',
	  'description' => 'Description',
	  'createtimestamp' => 'Entry created',
	  'modifytimestamp' => 'Entry modified'
	 );

# This defines what fields are displayed, and in what order
@attrorder = qw(hostname admin architecture distribution access
                sponsor sponsor-admin location machine memory
	        disk bandwidth status notes sshrsahostkey
		description createtimestamp modifytimestamp);

# ditto for summary
%summaryattrs = ('hostname' => 'Host name',
                 'host'     => 'just for a link',
                 'architecture' => 'Architecture',
		 'distribution' => 'Distribution',
		 'status' => 'Status',
		 'access' => 'Access');
		 
@summaryorder = ('hostname', 'architecture', 'distribution', 'status', 'access');		 

# Global settings...
my %config = &Util::ReadConfigFile;

my ($ldap, $mesg, $dn, $entries, $data, %output, $key, $hostlist, $hostdetails, $selected, %summary);
sub DieHandler {
  $ldap->unbind if (defined($ldap));
}

$SIG{__DIE__} = \&DieHandler;

my $query = new CGI;
my $host = lc($query->param('host'));

&Util::HTMLSendHeader;
$ldap = Net::LDAP->new($config{ldaphost}) || &Util::HTMLError($!);
$mesg;
$ldap->bind;

$mesg = $ldap->search(base  => $config{hostbasedn}, filter => 'host=*');
$mesg->code && &Util::HTMLError($mesg->error);
$entries = $mesg->as_struct;

foreach $dn (sort {$entries->{$a}->{host}->[0] cmp $entries->{$b}->{host}->[0]} keys(%$entries)) {
  $data = $entries->{$dn};

  my $thishost = $data->{host}->[0];
  $selected = "";
  
  if (lc($thishost) eq $host) {
    $output{havehostdata} = 1;

    foreach $key (keys(%attrs)) {
      $output{$key} = $data->{$key}->[0];
    }
  
    $output{hostname} = undef;
    foreach my $hostname (@{$data->{hostname}}) {
      $output{hostname} .= sprintf("%s%s", ($output{hostname} ? ', ' : ''), $hostname);
    }

    # Modified/created time. TODO: maybe add is the name of the creator/modifier
    $output{modifytimestamp} = &Util::FormatTimestamp($output{modifytimestamp});
    $output{createtimestamp}  = &Util::FormatTimestamp($output{createtimestamp});
    
    # Format email addresses
    $output{admin} = sprintf("<a href=\"mailto:%s\">%s</a>", $output{admin}, $output{admin});
    $output{'sponsor-admin'} = sprintf("<a href=\"mailto:%s\">%s</a>", $output{'sponsor-admin'}, $output{'sponsor-admin'});

    $output{sshrsahostkey} = undef;
    foreach $key (@{$data->{sshrsahostkey}}) {
      $output{sshrsahostkey} .= $key . "<br>";
    }
    
    # URL
    my ($sponsor, $url) = undef;
    $output{sponsor} = undef;
    foreach $sponsor (@{$data->{sponsor}}) {
      $sponsor =~ m#((http|ftp)://\S+)#i;
      $url = $1;
      $sponsor =~ s/$url//;
      $output{sponsor} .= "<br>" if ($output{sponsor});
      if ($url) {
        $output{sponsor} .= sprintf("<a href=\"%s\">%s</a>", $url, $sponsor);
      } else {
        $output{sponsor} .= $sponsor;
      }
    }
    
    $selected = " selected ";    
  }
  
  $hostlist .= "<option value=\"$thishost\"$selected>$thishost\n";
  
  # collect summary info
  foreach $key (keys(%summaryattrs)) {
    $summary{$thishost}{$key} = $data->{$key}->[0];
  }
  
  $summary{$thishost}{hostname} = undef;
  foreach my $hostname (@{$data->{hostname}}) {
    $summary{$thishost}{hostname} .= sprintf("%s<a href=\"machines.cgi?host=%s\">%s</a>", ($summary{$thishost}{hostname} ? '<br>' : ''), $summary{$thishost}{host}, $hostname);
  }
}
$ldap->unbind;

if ($output{havehostdata}) {
  $hostdetails = "<h1>Information about $output{hostname}</h1>\n";
  $hostdetails .= "<ul>\n";
  foreach $key (@attrorder) {
    if ($output{$key}) {
      $hostdetails .= "<li><b>$attrs{$key}:</b> $output{$key}\n";
    }
  }
  $hostdetails .= "</ul>\n";
} else {
  # display summary info
  $hostdetails = "<h1>Summary</h1>\n";
  $hostdetails .= "<table border=1 width=90%>\n<tr>";
  foreach $key (@summaryorder) {
    $hostdetails .= "<th>$summaryattrs{$key}</th>";
  }
  $hostdetails .= "</tr>\n";
  
  foreach $host (sort(keys(%summary))) {
    $hostdetails .= "<tr>";
    foreach $key (@summaryorder) {
      $hostdetails .= "<td>$summary{$host}{$key}&nbsp;</td>";
    }
    $hostdetails .= "</tr>\n";
  }
  $hostdetails .= "</table>\n";
}

# Finally, we can write the output... yuck...
open (F, "<$config{hosthtml}") || &Util::HTMLError("Cannot open host template");
while (<F>) {
  s/~hostlist~/$hostlist/;
  s/~hostdetails~/$hostdetails/;
  print;
}
close F;
