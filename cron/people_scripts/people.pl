#!/usr/bin/perl -w
require 5.001;
#use strict;

# people.pl -- generate http://www.debian.org/devel/people
# Copyright (C) 1998, ... James Treacy
# Copyright (C) 2000-2002 Josip Rodin

# the global variables!

my ($firstname, $lastname, $email, $pname);
my (%People, @nameslist, , $names, $file);
my @special_maintainer = (
	"Debian QA Group",
	"Debian Install System Team",
	"Debian Policy List",
	"Debian GCC maintainers",
	"Debian GNUstep maintainers",
	"GNU Hurd Maintainers",
	"GNU Libc Maintainers",
	"Apache maintainers",
	"Debbugs developers",
	"Dpkg Development",
	"teTeX maintainers",
	"APT Development Team",
	"Progeny Debian Packaging Team",
	"Dynamic DNS Tools and Services",
);


# put the auxilliary functions first to shut up perl >= 5.6

sub print_maintainer {
	my ($names) = @_;
	print "<dt><strong><a name=\"$lastname\">$lastname</a>";
	if ($lastname ne "Wookey") {
		if ($firstname) { print ", $firstname"; }
	}
	print "</strong> ";
	if ($People{$names}{email} ne "") {
		print "&nbsp;<a href=\"mailto:$People{$names}{email}\">&lt;$People{$names}{email}&gt;</a>\n";
	}
	if (defined $People{$names}{homepage}) {
		print "(<a href=\"$People{$names}{homepage}\">home page</a>)\n";
	}
	if (defined $People{$names}{main}) {
		print_package_list("main", sort @{$People{$names}{main}});
	}
	if (defined $People{$names}{contrib}) {
		print_package_list("contrib", sort @{$People{$names}{contrib}});
	}
	if (defined $People{$names}{nonfree}) {
		print_package_list("non-free", sort @{$People{$names}{nonfree}});
	}
	if (defined $People{$names}{nonusmain}) {
		print_package_list("non-us/main", sort @{$People{$names}{nonusmain}});
	}
	if (defined $People{$names}{nonuscontrib}) {
		print_package_list("non-us/contrib", sort @{$People{$names}{nonuscontrib}});
	}
	if (defined $People{$names}{nonusnonfree}) {
		print_package_list("non-us/non-free", sort @{$People{$names}{nonusnonfree}});
	}
}

sub print_package_list {
   my ($distribution,@packages) = @_;
   my (@list, $prev);
   $prev = "";
   foreach (@packages) {
      if ($_ ne $prev) {
         push @list, $_;
      }
      $prev = $_;
   }
   print "<dd><strong>$distribution:</strong> &nbsp;&nbsp;";
   print join(", ", @list);
   print "\n";
}

sub process_package_file {
	my ($filename,$distribution) = @_;
	my ($temp, $member, $name, $nname);

	open (PKG, $filename) or return;
	while (<PKG>) {
		if (/^$/) {
			process_package($distribution);
			$package_info = "";
		}
		else {
			$package_info .= $_;
		}
	}
}

sub process_package {
	my ($distribution) = @_;
	chop $package_info;
	@package_pieces = split(/\n\b/, $package_info);
	foreach (@package_pieces) {
		if (/^Package:\s+(.+)$/o) {
			$pack =$1;
		}
		elsif (/^maintainer:\s+(.+)$/io) {
			$maintainer = $1;
		}
	}
	if (!defined $package{$pack}) {
		$package{$pack}{distribution} = $distribution;
		$package{$pack}{maintainer} = $maintainer;
	}
}

sub canonical_names {
	PACK: foreach $pack (keys %package) {
		$maintainer = $package{$pack}{maintainer};
		$maintainer =~ s/&/&amp;/g;

		# Take care of the special cases first
		foreach (@special_maintainer) {
			if ($maintainer =~ /($_).*<(.+)>\s*/) {
				$lastname = "$1"; $firstname = ""; $email = $2;
				$package{$pack}{lastname} = $lastname;
				$package{$pack}{firstname} = $firstname;
				$package{$pack}{email} = $email;
				next PACK;
			}
		}
# Take care of the annoying cases and exceptions and overrides and stuff
		if ($maintainer =~ /Debian Quality Assurance.*<(.+)>/) {
			$lastname = 'Debian QA Group'; $firstname = ''; $email = $1;
		}
		if ($maintainer =~ /Boot Floppies Team <(.+)>/) {
			$lastname = 'Debian Install System Team'; $firstname = ''; $email = $1;
		}
		elsif ($maintainer =~ /Javier Fernandez-Sanguino Pen~a\s+<(.+)>/o) {
			$lastname = 'Fernandez-Sanguino Pe&ntilde;a'; $firstname = 'Javier'; $email = $1;
		}
		elsif ($maintainer =~ /KELEMEN Peter <(.+)>/io) {
			$lastname = 'Kelemen'; $firstname = 'Peter'; $email = $1;
		}
		elsif ($maintainer =~ /J\.H\.M\.? Dassen \(Ray\) <(.+)>/o) {
			$lastname = 'Dassen'; $firstname = 'Ray J.H.M.'; $email = $1;
		}
		elsif ($maintainer =~ /David (A. )?van Leeuwen <(.+)>/) {
			$lastname = 'van Leeuwen'; $firstname = 'David'; $email = $2;
		}
		elsif ($maintainer =~ /Mark W. Eichin <(.+)>/) {
			$lastname = 'Eichin'; $firstname = 'Mark'; $email = $1;
		}
		elsif ($maintainer =~ /Kam Tik <(.+)>/) {
			$lastname = 'Kam' ; $firstname = 'Tik' ; $email = $1;
		}
		elsif ($maintainer =~ /Yu Guanghui <(.+)>/) {
			$lastname = 'Yu' ; $firstname = 'Guanghui' ; $email = $1;
		}
		elsif ($maintainer =~ /zhaoway <(.+)>/) {
			$lastname = 'Way' ; $firstname = 'Zhao' ; $email = $1;
		}
		elsif ($maintainer =~ /Gustavo Noronha Silva <(.+)>/) {
			$lastname = 'Noronha Silva' ; $firstname = 'Gustavo' ; $email = $1;
		}
		elsif ($maintainer =~ /An Thi-Nguyen Le <(.+)>/) {
			$lastname = 'Le' ; $firstname = 'An Thi-Nguyen' ; $email = $1;
		}
		elsif ($maintainer =~ /C.M. Connelly <(.+)>/) {
			$lastname = 'Connelly' ; $firstname = 'Claire' ; $email = $1;
		}
		elsif ($maintainer =~ /Thomas Bushnell, BSG <(.+)>/) {
			$lastname = 'Bushnell' ; $firstname = 'Thomas' ; $email = $1;
		}
		elsif ($maintainer =~ /Javier Viñuales Gutiérrez <(.+)>/) {
			$lastname = 'Viñuales Gutiérrez' ; $firstname = 'Javier' ; $email = $1;
		}
		elsif ($maintainer =~ /Viral <(.+)>/) {
			$lastname = 'Shah' ; $firstname = 'Viral' ; $email = $1;
		}
		elsif ($maintainer =~ /David Martínez Moreno <(.+)>/) {
			$lastname = 'Martínez' ; $firstname = 'David' ; $email = $1;
		}
		elsif ($maintainer =~ /Eduardo Trápani <(.+)>/) {
			$lastname = 'Trapani' ; $firstname = 'Eduardo' ; $email = $1;
		}
		elsif ($maintainer =~ /Masamichi Goudge M.D. <(.+)>/) {
			$lastname = 'Goudge' ; $firstname = 'Masamichi' ; $email = $1;
		}
		elsif ($maintainer =~ /Jochen Röhrig <(.+)>/) {
			$lastname = 'Röhrig' ; $firstname = 'Jochen' ; $email = $1;
		}
		elsif ($maintainer =~ /Pedro Zorzenon Neto <(.+)>/) {
			$lastname = 'Zorzenon Neto' ; $firstname = 'Pedro' ; $email = $1;
		}
		elsif ($maintainer =~ /Wookey <(.+)>/) {
			$lastname = 'Wookey' ; $firstname = '' ; $email = $1;
		}
		elsif ($maintainer =~ /Ramakrishnan M <(.+)>/) {
			$lastname = 'Muthukrishnan' ; $firstname = 'Ramakrishnan' ; $email = $1;
		}
		elsif ($maintainer =~ /Amaya Rodrigo Sastre <(.+)>/) {
			$lastname = 'Rodrigo Sastre' ; $firstname = 'Amaya' ; $email = $1;
		}
		elsif ($maintainer =~ /Felix Kröger <(.+)>/) {
			$lastname = 'Kröger' ; $firstname = 'Felix' ; $email = $1;
		}
		elsif ($maintainer =~ /Vanicat Rémi <(.+)>/) {
			$lastname = 'Vanicat' ; $firstname = 'Rémi' ; $email = $1;
		}
		elsif ($maintainer =~ /Martin Sjögren <(.+)>/) {
			$lastname = 'Sjögren' ; $firstname = 'Martin' ; $email = $1;
		}
		elsif ($maintainer =~ /Esteban Manchado Velázquez <(.+)>/) {
			$lastname = 'Manchado Velázquez' ; $firstname = 'Esteban' ; $email = $1;
		}
		elsif ($maintainer =~ /Jose Carlos Garcia Sogo <(.+)>/) {
			$lastname = 'Garcia Sogo' ; $firstname = 'Jose Carlos'; $email = $1;
		}
		elsif ($maintainer =~ /Martin Würtele <(.+)>/) {
			$lastname = 'Würtele' ; $firstname = 'Martin'; $email = $1;
		}
		elsif ($maintainer =~ /Dagfinn Ilmari Mannsåker <(.+)>/) {
			$lastname = 'Ilmari Manns&aring;ker' ; $firstname = 'Dagfinn'; $email = $1;
		}
		elsif ($maintainer =~ /Luca - De Whiskey's - De Vitis <(.+)>/) {
			$lastname = 'De Vitis' ; $firstname = 'Luca'; $email = $1;
		}
		elsif ($maintainer =~ /Chris(topher)? L\.? Cheney <(.+)>/) {
			$lastname = 'Cheney'; $firstname = 'Christopher L.'; $email = $2;
		}
		elsif ($maintainer =~ /OHASHI Akira <(.+)>/) {
			$lastname = 'Ohashi'; $firstname = 'Akira'; $email = $1;
		}
		elsif ($maintainer =~ /GOTO Masanori <(.+)>/) {
			$lastname = 'Goto'; $firstname = 'Masanori'; $email = $1;
		}
		elsif ($maintainer =~ /SZALAY Attila <(.+)>/) {
			$lastname = 'Szalay'; $firstname = 'Attila'; $email = $1;
		}
		elsif ($maintainer =~ /Sylvain LE GALL <(.+)>/) {
			$lastname = 'Le Gall'; $firstname = 'Sylvain'; $email = $1;
		}
		elsif ($maintainer =~ /RISKO Gergely <(.+)>/) {
			$lastname = 'Risko'; $firstname = 'Gergely'; $email = $1;
		}
		elsif ($maintainer =~ /PASZTOR Gyorgy <(.+)>/) {
			$lastname = 'Pasztor'; $firstname = 'Gyorgy'; $email = $1;
		}
		elsif ($maintainer =~ /Atsushi KAMOSHIDA <(.+)>/) {
			$lastname = 'Kamoshida'; $firstname = 'Atsushi'; $email = $1;
		}
		elsif ($maintainer =~ /Takao KAWAMURA <(.+)>/) {
			$lastname = 'Kawamura'; $firstname = 'Takao'; $email = $1;
		}
		elsif ($maintainer =~ /Takuo KITAME <(.+)>/) {
			$lastname = 'Kitame'; $firstname = 'Takuo'; $email = $1;
		}
		elsif ($maintainer =~ /Atsuhito KOHDA <(.+)>/) {
			$lastname = 'Kohda'; $firstname = 'Atsuhito'; $email = $1;
		}
		elsif ($maintainer =~ /SEKIDO Koichi <(.+)>/) {
			$lastname = 'Sekido'; $firstname = 'Koichi'; $email = $1;
		}
		elsif ($maintainer =~ /Tomohiro KUBOTA <(.+)>/) {
			$lastname = 'Kubota'; $firstname = 'Tomohiro'; $email = $1;
		}
		elsif ($maintainer =~ /A Lee <(.+)>/) {
			$lastname = 'Lee'; $firstname = 'Ho-seok'; $email = $1;
		}
		elsif ($maintainer =~ /Julien LEMOINE <(.+)>/) {
			$lastname = 'Lemoine'; $firstname = 'Julien'; $email = $1;
		}
		elsif ($maintainer =~ /OHURA Makoto <(.+)>/) {
			$lastname = 'Ohura'; $firstname = 'Makoto'; $email = $1;
		}
		elsif ($maintainer =~ /A Menucc1? <(.+)>/) {
			$lastname = 'Menucci'; $firstname = 'Andrea'; $email = $1;
		}
		elsif ($maintainer =~ /Abraham vd Merwe <(.+)>/) {
			$lastname = 'van der Merwe'; $firstname = 'Abraham'; $email = $1;
		}
		elsif ($maintainer =~ /ISHIKAWA Mutsumi <(.+)>/) {
			$lastname = 'Ishikawa'; $firstname = 'Mutsumi'; $email = $1;
		}
		elsif ($maintainer =~ /Shuichi OONO <(.+)>/) {
			$lastname = 'Oono'; $firstname = 'Shuichi'; $email = $1;
		}
		elsif ($maintainer =~ /Susumu OSAWA <(.+)>/) {
			$lastname = 'Osawa'; $firstname = 'Susumu'; $email = $1;
		}
		elsif ($maintainer =~ /Goedson Teixeira Paixao <(.+)>/) {
			$lastname = 'Teixeira Paixao'; $firstname = 'Goedson'; $email = $1;
		}
		elsif ($maintainer =~ /MJ Ray <(.+)>/) {
			$lastname = 'Ray'; $firstname = 'Mark'; $email = $1;
		}
		elsif ($maintainer =~ /Manuel Estrada Sainz <(.+)>/) {
			$lastname = 'Estrada Sainz'; $firstname = 'Manuel'; $email = $1;
		}
		elsif ($maintainer =~ /Manuel Estrada Sainz <(.+)>/) {
			$lastname = 'Estrada Sainz'; $firstname = 'Manuel'; $email = $1;
		}
		elsif ($maintainer =~ /NOSHIRO Shigeo <(.+)>/) {
			$lastname = 'Noshiro'; $firstname = 'Shigeo'; $email = $1;
		}
		elsif ($maintainer =~ /Roberto Suarez Soto <(.+)>/) {
			$lastname = 'Suarez Soto'; $firstname = 'Roberto'; $email = $1;
		}
		elsif ($maintainer =~ /JP Sugarbroad <(.+)>/) {
			$lastname = 'Sugarbroad'; $firstname = 'Jean-Philippe'; $email = $1;
		}
		elsif ($maintainer =~ /Tamas SZERB <(.+)>/) {
			$lastname = 'Szerb'; $firstname = 'Tamas'; $email = $1;
		}
		elsif ($maintainer =~ /Akira TAGOH <(.+)>/) {
			$lastname = 'Tagoh'; $firstname = 'Akira'; $email = $1;
		}
		elsif ($maintainer =~ /NOKUBI Takatsugu <(.+)>/) {
			$lastname = 'Nokubi'; $firstname = 'Takatsugu'; $email = $1;
		}
		elsif ($maintainer =~ /UNO Takeshi <(.+)>/) {
			$lastname = 'Uno'; $firstname = 'Takeshi'; $email = $1;
		}
		elsif ($maintainer =~ /Fumitoshi UKAI <(.+)>/) {
			$lastname = 'Ukai'; $firstname = 'Fumitoshi'; $email = $1;
		}
		elsif ($maintainer =~ /ARAKI Yasuhiro <(.+)>/) {
			$lastname = 'Araki'; $firstname = 'Yasuhiro'; $email = $1;
		}
		elsif ($maintainer =~ /Taku YASUI <(.+)>/) {
			$lastname = 'Yasui'; $firstname = 'Taku'; $email = $1;
		}

#
# The following should handle almost everyone
#
# the latest insane regexp courtesy of Matt Kraai
		elsif ($maintainer =~ /"?(.+?)\s+(([vV][ao]n )?(da |der? |Di |Le |Dal )?[\w~'-]+),?\s*([IV]*|Jr\.?)"?(\s+\(.*\))?\s+<(.+)>\s*/o) {
			($firstname,$lastname,$email) = ($1,$2,$7);
		}
		# elsif ($maintainer =~ /"?([\w~'-]+?)\s+(.*?)\s*(([vV]an |Di |de |Le )?[\w~'-]+),?\s*[IV]*"?\s+<(.+)>\s*/o) {
		#	($firstname,$middlename,$lastname,$email) = ($1,$2,$3,$5);
# 		elsif ($maintainer =~ /"?(.+?)\s+(([vV][ao]n )?(da |de |Di |Le )?[\w~'-]+),?\s*([IV]*|Jr\.?)"?\s+<(.+)>\s*/o) {
# 			($firstname,$lastname,$email) = ($1,$2,$6);
# 		}
# 		# Only a single word is given for the name, or something
# 		elsif ($maintainer =~ /(.+)?\s+<(.+)>/o) {
# 			$whatever = $1;
# 			$email = $2;
# 			# Check if there's one of those stupid STUPID S T U P I D comments within the name
# 			if ($whatever =~ /"?(.+?)\s+(([vV][ao]n )?(da |de |Di |Le )?[\w~'-]+),?\s*([IV]*|Jr\.?)"?.*\((.*)\)/o) {
# 				($firstname,$lastname) = ($1,$2);
# #				warn "discarded a comment in $whatever\n";
# 			} else {
# 				print "$1 <$2>\n";
# 				die "Unknown maintainer format \$1 = $1 and \$2 = $2";
# 				# send mail to webmaster@debian.org
# 			}
# 		}
		# Only an email address is given
		elsif ($maintainer =~ /(.+)*/o) {
			$_ = $1;
			print "$_ X\n";
			die "Unknown maintainer format:\n$_\n";
			# send mail to webmaster@debian.org
			# cron/weekly script has been fixed to annoy joy about these errors
		}

		$package{$pack}{lastname} = $lastname;
		$package{$pack}{firstname} = $firstname;
		$package{$pack}{email} = $email;
	}
}


# some old, obsolete code:

# # Add this package onto the list
# #    if (/^Maintainer: /) {
# #       $People{"$lastname:$firstname"}{email} = $email;
# #       push @{ $People{"$lastname:$firstname"}{$distribution} }, $pname;
#        #$temp = $#{ $People{"$lastname:$firstname"}{$distribution} };
# #print "temp=$temp, lastname=$lastname, firstname=$firstname, email=$email, dist=$distribution, dist=$distribution, pname=$pname\n";
# #print @{ $People{"$lastname:$firstname"}{$distribution} }."\n";
#        #if ($temp == -1) {
#        #   push @{ $People{"$lastname:$firstname"}{$distribution} }, $pname;
#        #}
#        #else {
#        #   $member=0;
#        #   foreach (@{ $People{"$lastname:$firstname"}{$distribution} }) {
#        #      if ($_ eq $pname) {
#        #         $member = 1;
#        #         last;
#        #      }
#        #   }
#        #   if ($member == 0) {
#        #      push @{ $People{"$lastname:$firstname"}{$distribution} }, $pname;
#        #   }
#        #}
# #    }
# # }
# #}

sub create_maintainer_list {
	foreach $pack (keys %package) {
		$distribution = $package{$pack}{distribution};
		$lastname = $package{$pack}{lastname};
		$firstname = $package{$pack}{firstname};
		$email = $package{$pack}{email};

		if (!exists $People{"$lastname:$firstname"}) {
			@namelist = keys %People;
			@prev_name = grep (/$lastname:$firstname/i, @namelist);
			if (@prev_name) {
				$prev_name = $prev_name[0];
				# printf STDERR "found $prev_name ($lastname:$firstname) when ingnoring capitalization\n";
				($lastname, $firstname) = $prev_name =~ /(.*):(.*)/;
			}
		}

		if ((!exists $People{"$lastname:$firstname"}{email}) or ($email =~ /debian/)) {
			$People{"$lastname:$firstname"}{email} = $email;
		}
		push( @{$People{"$lastname:$firstname"}{$distribution}}, $pack );

	}
}


sub duplicate_check {
}


sub process_homepages {
  my $filename = @_;

  my (%uid, %page, $name);

  # get the stuff from the LDAP database
  # option -B required on potato, -P 2 -x on woody
  foreach (`ldapsearch -P 2 -x -h db.debian.org -b dc=debian,dc=org uid=\* cn mn sn labeledurl`) {
    chop; $line = $_;
    if ($line =~ /^(dn: )?uid=(.+),.+$/) { $name = $2; }
    elsif ($line =~ /^cn(=|: )(.+)$/) { $ldap_cn = $2; }
    elsif ($line =~ /^mn(=|: )(.+)$/) { next; }
    elsif ($line =~ /^sn(=|: )(.+)$/) { $ldap_sn = $2; }
    elsif ($line =~ /^(\w+):: (.+)$/) {
      use MIME::Base64;
      my $namepart = $1;
      my $worddata = decode_base64($2);
      if ($namepart eq "cn") { $ldap_cn = $worddata; }
      elsif ($namepart eq "sn") { $ldap_sn = $worddata; }
      elsif ($namepart ne "mn") {
        die "something went wrong, a non-name field is BASE64 encoded";
      }
#      warn "had to decode: $worddata\n";
    }
    elsif ($line =~ /^labeledurl(=|: )(.+)$/) {
	$homepageurl = $2;
	$homepageurl =~ s,^www,http://www,;
	# warn $ldap_cn." ".$ldap_sn." ".$homepageurl."\n";
	$has_package = 0;
	foreach $person (keys %People) {
		if ($person =~ /(.*):(.*)/) {
			($firstname,$lastname) = ($2,$1);
			# the following looks wierd, but you really do need to check first
			# names both ways
			if ($lastname =~ /^$ldap_sn$/i and ($firstname =~ /$ldap_cn/i or $ldap_cn =~ /$firstname/i)) {
				# warn $person." ".$ldap_sn." ".$homepageurl."\n";
				$People{$person}{homepage} = $homepageurl;
				$has_package = 1;
				last;
			}
		}
	}
	if (!$has_package) {
		# for some reason, the debbugs user is in the LDAP database, and we don't need it
		next if ($ldap_cn eq "Debian BTS");

		# they don't seem to have any packages, but add them anyway
		$People{"$ldap_sn:$ldap_cn"}{email} = "";
		$People{"$ldap_sn:$ldap_cn"}{homepage} = $homepageurl;
		# warn "Adding $ldap_cn $ldap_sn even though they don't have any packages\n";
	}
    }
    elsif ($line eq "" or $line =~ /^((version|search|result):|#)/) { next; }
    else { die "Error: unknown format on line $.:\n$_\n"; }
  }

}

# and now, the script body itself.

# go through Packages files one at a time
while ($file = shift @ARGV) {
    if ($file =~ m,main.*non-US,) {
        process_package_file($file, 'nonusmain');
    }
    elsif ($file =~ m,contrib.*non-US,) {
        process_package_file($file, 'nonuscontrib');
    }
    elsif ($file =~ m,non-free.*non-US,) {
        process_package_file($file, 'nonusnonfree');
    }
    elsif ($file =~ m,main,) {
        process_package_file($file, 'main');
    }
    elsif ($file =~ m,contrib,) {
        process_package_file($file, 'contrib');
    }
    elsif ($file =~ m,non-free,) {
        process_package_file($file, 'nonfree');
    }
    else {
        die "can't determine distribution from file name: $file";
    }
}

# Split up the names (to first and last). There is some massaging to try to
# avoid the same person appearing under two (slightly different) names
canonical_names();

create_maintainer_list();

process_homepages();

duplicate_check();

print "<dl>\n";
foreach (@special_maintainer) {
	$names = $_.":";
	$lastname = $_; $firstname = "";
	if (exists $People{$names}) {
		print_maintainer($names);
		delete $People{$names};
	}
}
print "</dl>\n";

# print out the package listings by maintainer
print "<dl>\n";
@nameslist = sort { lc($a) cmp lc($b) } keys %People;
foreach $names (@nameslist) {
	($lastname,$firstname) = split(/:/, $names);
	#print "$lastname : $firstname\n";
	if (!defined $People{$names}{email}) {
		printf STDERR "$names has no email address\n";
		$People{$names}{email} = "";
	}

	print_maintainer($names);
}
print "</dl>\n";
