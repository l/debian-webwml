# -*- perl -*-x
package Util;

use strict;
use Date::Manip qw(ParseDate);

my $blocksize = 8; # A blowfish block is 8 bytes
my $configfile = "/etc/userdir-ldap/userdir-ldap.conf";
#my $configfile = "/home/randolph/html/debian/perl/userdir-ldap.conf";

my %config = &ReadConfigFile;

my $hascryptix = 1;
eval 'use Crypt::Blowfish';
if ($@) {
  $hascryptix = undef;
}

sub CreateKey {
  my $keysize = shift;
  my $input;
  open (F, "</dev/urandom") || die &HTMLError("No /dev/urandom found!");
  read(F, $input, $keysize); # key length is 8 bytes
  close F;
  
  return $input;
}

sub CreateCryptSalt {
  # this can create either a DES type salt or a MD5 salt
  my $md5 = shift; # do we want a MD5 salt?
  my $validstr = './0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  my @valid = split(//,$validstr);
  my ($in, $out);
  
  my $cryptsaltlen = ($md5 ? 8 : 2);
  
  open (F, "</dev/urandom") || die &HTMLError("No /dev/urandom found!");
  foreach (1..$cryptsaltlen) {
    read(F, $in, 1);
    $out .= $valid[ord($in) % ($#valid + 1)];
  }
  close F;
  return ($md5 ? "\$1\$$out\$" : $out);
}

sub Encrypt { 
  # blowfish only encrypts things in blocks of 8 bytes, so we
  # need a custom routine that handles longer strings....
  my $cipher = shift;
  my $input = shift;
  my ($pos, $output);

  # prepend a length byte */
  $input = chr(length($input)).$input;
  $input .= "\001" x ($blocksize - (length($input) % $blocksize)) if (length($input % $blocksize));

  for ($pos = 0; $pos < length($input); $pos += $blocksize) {    
    $output .= unpack("H16", $cipher->encrypt(substr($input, $pos, $blocksize))) if ($hascryptix);
  }
  return $output;
}

sub Decrypt {
  # like encrypt, needs to deal with big blocks. Note that we assume
  # trailing spaces are unimportant.
  my $cipher = shift;
  my $input = shift;
  my ($pos, $portion, $output, $len);
  
  ((length($input) % $blocksize) == 0) || &HTMLError("Password corrupted"); # should always be true...

  for ($pos = 0; $pos < length($input); $pos += $blocksize*2) {
    $portion = pack("H16", substr($input, $pos, $blocksize*2));
    $output .= $cipher->decrypt($portion) if ($hascryptix);
  }
  
  # check length byte, discard junk
  $len = substr($output, 0, 1);
  $output = substr($output, 1, ord($len));
  return $output;
}

sub SavePasswordToFile {
  my $userid = shift;
  my $password = shift;
  my $cipher = shift;

  my $cryptuser = crypt($userid, &CreateCryptSalt);
  my $secret = Encrypt($cipher, $password);
  $cryptuser =~ y/\//_/; # translate slashes to underscores...
  
  my $fn = "$config{authtokenpath}/$cryptuser";
  open (F, ">$fn") || &HTMLError("$fn: $!");
  print F "$secret\n";
  print F time."\n";
  close F;
  chmod 0600, $fn;
  return $cryptuser;
}

sub ReadPasswordFromFile {
  my $userid = shift;
  my $cipher = shift;
  my $passwd;
  my $time;
  
  $userid =~ y/\//_/; # translate slashes to underscores...

  # if we couldn't read the password file, assume user is unauthenticated. is this ok?
  open (F, "<$config{authtokenpath}/$userid") || return undef; 
  chomp($passwd = <F>);
  chomp($time = <F>);
  close F; 

  # check to make sure we read something
  return undef if (!$passwd || !$time);
  
  # check to make sure the time is positive, and that the auth token
  # has not expired
  my $tdiff = (time - $time);
  &HTMLError("Your authentication token has expired. Please <a href=\"$config{webloginhtml}\">relogin</a>") if (($tdiff < 0) || ($tdiff > $config{authexpires}));
  
  return Decrypt($cipher, $passwd);
}

sub CheckAuthToken {
  my ($id, $hrkey) = split(/,/, shift, 2);
  return undef if (!$id || !$hrkey);
  my $key = pack("H".(length($hrkey)), $hrkey);
  my $cipher = new Crypt::Blowfish $key;
  my $r = ReadPasswordFromFile($id, $cipher);
  if ($r) {
    UpdateAuthToken("$id,$hrkey", $r);
  } else {    
    ClearAuthToken("$id,$hrkey")
  }
  return $r;
}

sub ClearAuthToken {
  my ($id, $hrkey) = split(/,/, shift, 2);
  $id =~ y/\//_/; # switch / to _
  unlink "$config{authtokenpath}/$id" || &HTMLError("Error removing authtoken: $!");
}

sub UpdateAuthToken {
  my ($id, $hrkey) = split(/,/, shift, 2);
  my $password = shift;
  my $key = pack("H".(length($hrkey)), $hrkey);
  $id =~ y/\//_/; # switch / to _
  my $cipher = new Crypt::Blowfish $key;
  my $secret = Encrypt($cipher, $password);
  
  my $fn = "$config{authtokenpath}/$id";
  open (F, ">$fn") || &HTMLError("$fn: $!");
  print F "$secret\n";
  print F time."\n";
  close F;
  chmod 0600, "$fn" || &HTMLError("$fn: $!");
  return 1;
}

sub FormatFingerPrint {
  my $in = shift;
  my $out;
  
  if (length($in) == 32) {
    foreach (0..15) {
      $out .= substr($in, $_*2, 2)." ";
      $out .= "&nbsp;" if ($_ == 7);
    }      
  } else {
    foreach (0..int(length($in)/2)) {
      $out .= substr($in, $_*4, 4)." ";
    }      
  }
  return $out;
}

sub FetchKey {
  my $fingerprint = shift;
  my ($out, $keyringparam) = undef;
  
  foreach (split(/:/, $config{keyrings})) {
    $keyringparam .= "--keyring $_ ";
  }
  
  $fingerprint =~ s/\s//g;
  $fingerprint = "0x".$fingerprint;

  $/ = undef; # just suck it up ....
  open(FP, "$config{gpg} --no-options --no-default-keyring $keyringparam --check-sigs --fingerprint $fingerprint|");
  $out = <FP>;
  close FP;
  open(FP, "$config{gpg} --no-options --no-default-keyring $keyringparam --export -a $fingerprint|");
  $out .= <FP>;
  close FP;
  $/ = "\n";
  
  return $out;
}

sub FormatTimestamp {
  my $in = shift;
  $in =~ /^(....)(..)(..)(..)(..)(..)/;
  
  return sprintf("%04d/%02d/%02d %02d:%02d:%02d UTC", $1,$2,$3,$4,$5,$6);
}

sub FormatLastSeen {
# Format:
# [Tue, 11 Jan 2000 02:37:18] "Joey Hess <joeyh@debian.org>" "<debian-boot@lists.debian.org> archive/latest/7130" "<20000110181924.H19910@kitenet.net>"
# [Mon, 10 Jan 2000 21:48:19] "9E1E 1052 F8BB A351  0606 5527 50BB 2974 2D59 A7D2" "<debian-devel-changes@lists.debian.org> archive/latest/58632" "<20000110200506.13257.qmail@master.debian.org>"
  my $lastseenpgp = shift;
  my $lastseenfrom = shift;
  my ($d1, $d2, $lastseen);

  return "<b>No activity detected</b>" if (!$lastseenpgp && !$lastseenfrom);
  $lastseen = $lastseenfrom if (!$lastseenpgp);

  if ($lastseenfrom && $lastseenpgp) {
    ($d1) = ($lastseenpgp =~ /^\[(.+?)\]/); $d1 = ParseDate($d1);  
    ($d2) = ($lastseenfrom =~ /^\[(.+?)\]/); $d2 = ParseDate($d2);
    $lastseen = (($d1 gt $d2) ? $lastseenpgp : $lastseenfrom);
  }

  my ($date,$user,$list,$msgid) = ($lastseen =~ /^\[(.+?)\]\s+"(.+?)"\s+"(?:<(.+?)>.*?|\-)"\s+"<(.+?)>"/);
  $list = "on $list" if ($list);
  return "$date $list<br>&nbsp;Message ID: $msgid";
}

sub LookupCountry {
  my $in = shift;
  my ($abbrev, $country);
  open (F, $config{countrylist}) || return uc($in);
  while (<F>) {
    chomp;
    ($abbrev, $country) = split(/\s+/, $_, 2);
    if ($abbrev eq $in) {
      close F;
      return $country;
    }
  }
  close F;
  return uc($in);
}

####################
# Some HTML Routines

my $htmlhdrsent = 0;

sub HTMLSendHeader {
  print "Content-type: text/html\n\n" if (!$htmlhdrsent);
  $htmlhdrsent = 1;
}

sub HTMLPrint {
  &HTMLSendHeader if (!$htmlhdrsent);
  print shift;
}

sub HTMLError {
  HTMLPrint(shift);
  die "\n";
}

sub CheckLatLong {
  my ($lat, $long) = @_;

  $lat =~ s/[^-+\.\d]//g; $long =~ s/[^-+\.\d]//g;
  
  if (($lat =~ /^(\-|\+?)\d+(\.\d+)?/) && ($long =~ /^(\-|\+?)\d+(\.\d+)?/)) {
    return ($lat, $long);
  } else {
    return ("", "");
  }
}

sub FixParams {
  my $query = shift;
  my $key;
  my @names = $query->param;

  foreach $key (@names) { # web security is a joke ... <sigh>
    $_ = $query->param($key);
    s/&/&amp;/g; 
    s/[<\x8B]/&lt;/g;
    s/[>\x9B]/&gt;/g;

    $query->param($key, $_);
  }
}   

  
sub LDAPUpdate {
  my $ldap = shift;
  my $dn = shift;
  my $attr = shift;
  my $val = shift;
  my $mesg;
  
  if (!$val) {
    $mesg = $ldap->modify($dn, delete => { $attr => [] });
  } else {
    $val = [ $val ] if (!ref($val));
    $mesg = $ldap->modify($dn, replace => { $attr => $val });
    $mesg->code && &Util::HTMLError("error updating $attr: ".$mesg->error);
  }
}

###################
# Config file stuff
sub ReadConfigFile {
  # reads a config file and results a hashref with the results
  my (%config, $attr, $setting);
  open (F, "<$configfile") || &HTMLError("Cannot open $configfile: $!");
  while (<F>) {
    chomp;
    if ((!/^\s*#/) && ($_ ne "")) {
      # Chop off any trailing comments
      s/#.*//;
      ($attr, $setting) = split(/=/, $_, 2);
      $setting =~ s/"//g; #"
      $setting =~ s/;$//;
      $attr =~ s/^\s+//; $attr =~ s/\s+$//;
      $setting =~ s/^\s+//; $setting =~ s/\s+$//;      
      $config{$attr} = $setting;
    }
  }
  close F;
  return %config;
}

1;
