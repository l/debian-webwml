#!/usr/bin/perl -w

use Net::LDAP;

# To find a developer use:
# ldapsearch -h db.debian.org -x -b "dc=debian,dc=org" c=XX gecos 
# where 'XX' is the country:

# - America del Suer:
# Para algunos pa<ED>ses se puede obtener una lista con:
# ldapsearch -h db.debian.org -x -b "dc=debian,dc=org" \
# "(|(c=ar)(c=co)(c=cr)(c=mx)(c=uy))" gecos

# Static configuration data:

$LDAP_HOST = "db.debian.org";
#$LDAP_HOST = "localhost:1389";
$LDAP_base = "dc=debian,dc=org";

# Enable debug (0 to disable, 1 to enable)
$debug = 0;

# Parse the devel.data file in
$DATA = "devel.data";

# Could be used to find new developers, currently unused:
#%countries = (
#    spain => 'es',
#    argentina => 'as',
#    costa_rica => 'cr',
#    mexico => 'mx',
#    colombia => 'co',
#    uruguay => 'uy',
#    venezuela => 've',
#    peru => 'pe',
#    chile => 'cl'
#);

open (DATA, "<$DATA") || die ("Could not open the data file $DATA: $!");

while ( $line = <DATA>) {
    chomp $line;
    if  ( $line =~ /<nick "(.*)">/ && $line !~ /\#/ ) {
        push @nicks_data, $1;
    }
}

# Search the nicks:
# This is one option:
# ldapsearch -x -H ldap://db.debian.org -b dc=debian,dc=org 'uid=$nick' cn
# the other one is to use ldap directly

# Either case, this will only work in debian.org machines

# Initialice LDAP

my $ldap = Net::LDAP->new ( $LDAP_HOST ) or die "$@";
print "Contacting ldap server at $LDAP_HOST\n" if $debug;

foreach $index ( 0 .. $#nicks_data ) {
   my $nick = $nicks_data[$index];
   print "Looking for $nick in $LDAP_base\n" if $debug;
   my $result = $ldap->search ( 
        base    => "$LDAP_base",
        filter  => "(uid=$nick)",
        attrs   =>  [ "cn", "c", "accountStatus" ]
        );
# CN = Common Name
# C = Country
# accountstatus : if set the developer might be inactive
   print "Search done got ".$result->count." results (code is ".$result->code." )\n" if $debug;
   if  ( $result->count > 0 )  {
# The user account is created, now, is it active?
       my @entries = $result->entries;
       my $entr;
       foreach $entr ( @entries ) {
           my $attr;
           foreach $attr ( sort $entr->attributes ) {
# skip binary we can't handle
               next if ( $attr =~ /;binary$/ );
               $value = $entr->get_value ( $attr );
               print "  $attr : ", $value ,"\n" if $debug;
               if ( $attr eq "accountStatus"  && ( $value =~ /inactive/ || $value =~ /retiring/ ) ) {
                       print "Nick $nick is no longer active ('$value').\n";
               }
           }
       }
   } else {
       print "Nick $nick does not exist\n";
   }
}


$ldap->unbind;
exit 0;

