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
	"GNU Hurd Maintainers",
	"GNU Libc Maintainers",
	"Debbugs developers",
	"Dpkg Development",
	"teTeX maintainers",
	"APT Development Team",
	"Progeny Debian Packaging Team",
	"Dynamic DNS Tools and Services",
	"Debian OpenOffice Team",
	"Cdbs Hackers",
	"Popularity Contest Developers",
	"Debian XML/SGML Group",
	"Grub-Devel",
	"Debian S/390 Team",
	"Debian Firebird Group",
	"Debian Mono Group",
	"Debian Perl Group",
	"Progeny Debian Packaging Group",
	"Grub Maintainers",
	"Debian Berkeley DB Maintainers",
	"Debian SPARC 2.4 Kernel Maintainers",
	"Exim4 Maintainers",
	"Debian VoIP Team",
	"Dbus Maintainance Team",
	"Debian Firebird RDBMS Team",
	"Debian kernel team",
	"Debian logcheck Team",
	"Debian NTP Team",
	"Debian QEMU Team",
	"Debian VBA Team",
	"Debian VDR and DVB Packaging Team",
);


# put the auxilliary functions first to shut up perl >= 5.6

my %ppl_ref = ();

sub print_maintainer {
	my ($names) = @_;
	print "<dt><strong>";
	if ($People{$names}{email} =~ /\@debian.org$/) {
	   $userid = $People{$names}{email};
	   $userid =~ s/@.*//;
	   if (!$ppl_ref{lc($userid)}) {
	      print "<a name=\"$userid\"></a>";
	      $ppl_ref{lc($userid)} = 1;
	   }
        }
	if ($ppl_ref{lc($lastname)}) {
           print "$lastname";
	} else {
 	   print "<a name=\"$lastname\">$lastname</a>";
           $ppl_ref{lc($lastname)} = 1;
	}
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

sub process_source_file {
	my ($filename,$distribution) = @_;
	my ($temp, $member, $name, $nname);

	open (PKG, $filename) or return;
	while (<PKG>) {
		if (/^$/) {
			process_src_package($distribution);
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

sub process_src_package {
	my ($distribution) = @_;
	my (@packages, $maintainer, @uploaders);

	chop $package_info;
	@package_pieces = split(/\n\b/, $package_info);
	foreach (@package_pieces) {
		if (/^binary:\s+(.+)$/io) {
			@packages = split /\s*,\s*/, $1;
		}
		elsif (/^maintainer:\s+(.+)$/io) {
			$maintainer = $1;
		}
		elsif (/^uploaders:\s+(.+)$/io) {
		    # this seems ugly but works
		    # improvements welcome
		    @uploaders = split />\s*,\s*/, $1;
		    map { $_ = "$_>" if ($_ =~ /</) 
			      && ($_ !~ />/); } @uploaders;
		}
	}
	foreach my $pack (@packages) {
	    if (!defined $package{$pack}) {
		$package{$pack}{distribution} = $distribution;
		$package{$pack}{maintainer} = $maintainer;
	    }
	    $package{$pack}{uploaders} = \@uploaders if @uploaders;
	}
}

# function contributed by Tomohiro Kubota
sub from_utf8_or_iso88591_to_sgml ($) {
    my $str = shift;
    my $strsave = $str;
    if ($str !~ /[\x80-\xff]/) {
	# return ASCII string for less machine-time consumption.
	return $str;
    }
    $str =~ s/([\xf0-\xf7])([\x80-\xbf])([\x80-\xbf])([\x80-\xbf])/
	"&#" .
	((ord($1)&0x7)* 0x40000 +
	(ord($2)&0x3f)* 0x1000 +
	(ord($3)&0x3f)* 0x40 +
	(ord($4)&0x3f)) . ";"/eg;
    $str =~ s/([\xe0-\xef])([\x80-\xbf])([\x80-\xbf])/
	"&#" .
	((ord($1)&0xf)* 0x1000 +
	(ord($2)&0x3f)* 0x40 +
	(ord($3)&0x3f)) . ";"/eg;
    $str =~ s/([\xc0-\xdf])([\x80-\xbf])/
	"&#" .
	((ord($1)&0x1f)* 0x40 +
	(ord($2)&0x3f)) . ";"/eg;
    if ($str !~ /[\x80-\xff]/) {
	# $str is UTF-8 compliant, assume UTF-8.
	return $str;
    } else {
	# $str is not UTF-8 compliant, assume ISO-8859-1.
	$strsave =~ s/([\x80-\xff])/"&#".ord($1).";"/eg;
	return $strsave;
    }
}

sub process_name {
    my ($maintainer) = @_;
		$maintainer =~ s/&/&amp;/g;

    my ($lastname, $firstname, $email);

		# Take care of the special cases first
		foreach (@special_maintainer) {
			if ($maintainer =~ /($_).*<(.+)>\s*/) {
				$lastname = "$1"; $firstname = ""; $email = $2;
				return ($lastname, $firstname, $email);
			}
		}
		$maintainer = from_utf8_or_iso88591_to_sgml($maintainer);
# Take care of the annoying cases and exceptions and overrides and stuff
		if ($maintainer =~ /(Debian \S+ [Mm]aintainers).*<(.+)>/) {
			$lastname = $1; $firstname = ''; $email = $2;
		}
		elsif ($maintainer =~ /Debian Quality Assurance.*<(.+)>/) {
			$lastname = 'Debian QA Group'; $firstname = ''; $email = $1;
		}
		elsif ($maintainer =~ /Boot Floppies Team <(.+)>/) {
			$lastname = 'Debian Install System Team'; $firstname = ''; $email = $1;
		}
		elsif ($maintainer =~ /Javier Fernandez-Sanguino Pen~a\s+<(.+)>/o) {
			$lastname = 'Fernandez-Sanguino Pe&ntilde;a'; $firstname = 'Javier'; $email = $1;
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
		elsif ($maintainer =~ /Viral <(.+)>/) {
			$lastname = 'Shah' ; $firstname = 'Viral' ; $email = $1;
		}
		elsif ($maintainer =~ /Masamichi Goudge M.D. <(.+)>/) {
			$lastname = 'Goudge' ; $firstname = 'Masamichi' ; $email = $1;
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
		elsif ($maintainer =~ /Jose Carlos Garcia Sogo <(.+)>/) {
			$lastname = 'Garcia Sogo' ; $firstname = 'Jose Carlos'; $email = $1;
		}
		elsif ($maintainer =~ /Luca - De Whiskey's - De Vitis <(.+)>/) { #'
			$lastname = 'De Vitis' ; $firstname = 'Luca'; $email = $1;
		}
		elsif ($maintainer =~ /Chris(topher)? L\.? Cheney <(.+)>/) {
			$lastname = 'Cheney'; $firstname = 'Christopher L.'; $email = $2;
		}
		elsif ($maintainer =~ /Sylvain LE GALL <(.+)>/) {
			$lastname = 'Le Gall'; $firstname = 'Sylvain'; $email = $1;
		}
		elsif ($maintainer =~ /A Lee <(.+)>/) {
			$lastname = 'Lee'; $firstname = 'Ho-seok'; $email = $1;
		}
		elsif ($maintainer =~ /A Mennucc1? <(.+)>/) {
			$lastname = 'Mennucci'; $firstname = 'Andrea'; $email = $1;
		}
		elsif ($maintainer =~ /Abraham vd Merwe <(.+)>/) {
			$lastname = 'van der Merwe'; $firstname = 'Abraham'; $email = $1;
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
		elsif ($maintainer =~ /Roberto Suarez Soto <(.+)>/) {
			$lastname = 'Suarez Soto'; $firstname = 'Roberto'; $email = $1;
		}
		elsif ($maintainer =~ /JP Sugarbroad <(.+)>/) {
			$lastname = 'Sugarbroad'; $firstname = 'Jean-Philippe'; $email = $1;
		}
		elsif ($maintainer =~ /Hatta Shuzo <(.+)>/) {
			$lastname = 'Hatta'; $firstname = 'Shuzo'; $email = $1;
		}
		elsif ($maintainer =~ /Oohara Yuuma <(.+)>/) {
			$lastname = 'Oohara'; $firstname = 'Yuuma'; $email = $1;
		}
		elsif ($maintainer =~ /W\. Borgert <(.+)>/) {
			$lastname = 'Borgert'; $firstname = 'Wolfgang'; $email = $1;
		}
		elsif ($maintainer =~ /Lenart Janos <(.+)>/) {
			$lastname = 'Lenart'; $firstname = 'Janos'; $email = $1;
		}
		elsif ($maintainer =~ /Bruno Barrera C. <(.+)>/) {
			$lastname = 'Barrera C.'; $firstname = 'Bruno'; $email = $1;
		}

#
# The following should handle almost everyone
#
# the latest insane regexp courtesy of Matt Kraai
		elsif ($maintainer =~ /"?(.+?)\s+(([vV][ao]n )?(da |der? |Di |Le |Dal )?[\w~'&;#-]+),?\s*([IV]*|Jr\.?)"?(\s+\(.*\))?\s+<(.+)>\s*/o) {
			($firstname,$lastname,$email) = ($1,$2,$7);
			if (uc($firstname) eq $firstname) {
				($firstname,$lastname) = ($lastname,ucfirst(lc($firstname)));
			}
			elsif (uc($lastname) eq $lastname) {
				$lastname = ucfirst(lc($lastname));
			}
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
#			print "$_ X\n";
			warn "Unknown maintainer format:\n$_\n";
			return;
			# this error ends up being sent via cron mail
		}
    return ($lastname, $firstname, $email);
}

sub canonical_names {
	PACK: foreach $pack (keys %package) {
		$maintainer = $package{$pack}{maintainer};

		my ($lastname, $firstname, $email) = process_name($maintainer);

		next unless $lastname;

		$package{$pack}{lastname} = $lastname;
		$package{$pack}{firstname} = $firstname;
		$package{$pack}{email} = $email;

		my @uploaders;
		foreach my $uploader (@{$package{$pack}{uploaders}}) {
		    my ($ulastname, $ufirstname, $uemail) = process_name($uploader);
		    next unless $ulastname;
		    next if ($package{$pack}{lastname} eq $ulastname)
			&& ($package{$pack}{firstname} eq $ufirstname);
#		    warn "process_name: $uploader: $ulastname, $ufirstname\n";
		    push( @uploaders, { lastname => $ulastname,
				       firstname => $ufirstname,
				       email => $uemail, } )
			if $ulastname;
		}
		$package{$pack}{uploadernames} = \@uploaders if @uploaders;
	    }
      }

sub insert_maintainer {
    my ($lastname, $firstname, $email, $distribution, $pack) =@_;

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

sub create_maintainer_list {
	foreach my $pack (keys %package) {
		my $distribution = $package{$pack}{distribution};
		my $lastname = $package{$pack}{lastname} || "";
		my $firstname = $package{$pack}{firstname} || "";
		my $email = $package{$pack}{email} || "";

		insert_maintainer( $lastname, $firstname, $email,
				   $distribution, $pack );

		foreach my $uploader (@{$package{$pack}{uploadernames}}) {
		    my $ulastname = $uploader->{lastname} || "";
		    my $ufirstname = $uploader->{firstname} || "";
		    my $uemail = $uploader->{email} || "";
		    
#		    warn "uploader: $ufirstname, $ulastname, $pack\n";
		    insert_maintainer( $ulastname, $ufirstname, $uemail,
				       $distribution, 
				       "$pack\*" );
		}
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
    elsif ($line =~ /^cn(=|: )(.+)$/) { $ldap_cn = from_utf8_or_iso88591_to_sgml($2); }
    elsif ($line =~ /^mn(=|: )(.+)$/) { next; }
    elsif ($line =~ /^sn(=|: )(.+)$/) { $ldap_sn = from_utf8_or_iso88591_to_sgml($2); }
    elsif ($line =~ /^(\w+):: (.+)$/) {
      use MIME::Base64;
      my $namepart = $1;
      my $worddata = from_utf8_or_iso88591_to_sgml(decode_base64($2));
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
		my $person = "$ldap_sn:$ldap_cn";
		$People{$person}{email} = "";
		$People{$person}{homepage} = $homepageurl;
		# warn "Adding $person even though they don't have any packages\n";
	}
    }
    elsif ($line eq "" or $line =~ /^((version|search|result):|#)/) { next; }
    else { die "Error: unknown format on line $.:\n$_\n"; }
  }

}

# and now, the script body itself.

# go through Packages files one at a time
    my $section;
while ($file = shift @ARGV) {
    if ($file =~ m,main.*non-US,) {
        $section = 'nonusmain';
    }
    elsif ($file =~ m,contrib.*non-US,) {
        $section = 'nonuscontrib';
    }
    elsif ($file =~ m,non-free.*non-US,) {
        $section = 'nonusnonfree';
    }
    elsif ($file =~ m,main,) {
        $section = 'main';
    }
    elsif ($file =~ m,contrib,) {
        $section = 'contrib';
    }
    elsif ($file =~ m,non-free,) {
        $section = 'nonfree';
    }
    else {
        die "can't determine distribution from file name: $file";
    }
    if ($file =~ m,Sources,) {
	process_source_file($file, $section);
    } else {
	process_package_file($file, $section);
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

@nameslist = sort { lc($a) cmp lc($b) } keys %People;
foreach $names (@nameslist) {
	($lastname,$firstname) = split(/:/, $names);
	if ($lastname =~ /Debian \S+ [Mm]aintainers/) {
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
