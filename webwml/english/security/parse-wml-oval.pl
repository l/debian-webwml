#!/usr/bin/perl
# Extracts the data file and creates OVAL queries to
# be used with the OVAL query interpreter
# (see http://oval.mitre.org)
#
# (c) 2004 Javier Fernandez-Sanguino
# Licensed under the GNU General Public License version 2.

# Format of data files is:
#<define-tag pagetitle>DSA-###-# PACKAGE</define-tag>
#<define-tag report_date>yyyy-mm-dd</define-tag>
#<define-tag secrefs>CAN|CVE-XXXX-XXXX</define-tag>
#<define-tag packages>PACKAGE</define-tag>
#<define-tag isvulnerable>yes|no</define-tag>
#<define-tag fixed>yes|no</define-tag>


use Getopt::Std;
use Time::gmtime;
use IO::File;
use Date::Parse;

# Stdin options
# -v verbose
getopts('hv');
if ( $opt_h ) {
# Help!
	print "usage: $0 [-vh]\n";
	print "\t-v\tverbose mode\n";
	print "\t-h\tthis help\n";
	exit 0;
}

# Configure this
$debian_version = "3.0";

parsedirs (".", "data", 2);


# Data
printdsas();

exit 0;

sub printdsas {
	foreach $dsa ( keys %dsaref) {

	# XML entries
	print "<definition id=\"OVAL-DSA-$dsa\">\n";
	print "\t<affected family=\"debian\">\n";
	print "\t\t<debian:platform>Debian GNU/Linux $debian_version</debian:platform>\n";
	print "\t\t<product>$dsaref{$dsa}{'package'}</product>\n";
        print "\t</affected>\n";
	# Print CVE entries
	foreach $ref ( split(' ', $dsaref{$dsa}{'secrefs'}) ) {
		if ( $ref =~ /((CVE|CAN)-[\d-]+)/i )  {
                        print "\t<cveid status=\"$1\">$2</cveid>\n";
		}
	}
	# TODO: this could be extracted from the wml file....
	print "\t<description>TODO</description>\n";
	print "\t<status>INTERIM</status>\n\t<version>0</version>\n";
	print "\t<criteria>\n";
        print "\t\t<software operation=\"AND\">\n";
	print "\t\t<criterion test_ref=\"rrt-XXX\" comment=\"Debian $debian_version is installed\"/>\n";
	# Now, since we have multiple architectures.. go into a loop
	# Notice this code is assuming all the architectures are using
	# the same binary package versions which might not necessarily
	# be true...
	if  ( defined ( $dsaref{$dsa}{'architectures'} ) ) {
        print "\t\t<software operation=\"OR\">\n";
	@architecturelist = split(' ',$dsaref{$dsa}{'architectures'});
	while ( my $architecture = pop @architecturelist ) {
		print "\t\t\t\t<criterion test_ref=\"rut-XXX\" comment=\"$architecture architecture\" />\n";
	}
        print "\t\t</software>\n";
	}
	# Now, since we have multiple binary packages.. go into a loop
        print "\t\t<software operation=\"OR\">\n";
	@packagelist = split(' ',$dsaref{$dsa}{'bpackages'});
	@versionlist = split(' ',$dsaref{$dsa}{'versions'});
	while ( $bpackage = pop @packagelist ) {
		my $version = pop @versionlist;
		print "\t\t\t\t<criterion test_ref=\"rvt-XXX\" comment=\"$bpackage version &lt; $version\" />\n ";
	}
        print "\t\t</software>\n";
        print "\t</software>\n";
	print "\t<configuration> TODO </configuration>\n";
	print "\t</criteria>\n";
	print "</definition>\n";
	}
	return 0;
}


sub parsefile {
	my ($file,$filename) = @_ ;
# The filename gives us the DSA we are parsing
	if ( $filename =~ /dsa\-(\d+)/ || $filename =~ /(\d+\w+)/ ) {
		$dsa=$1;
	} else {
		print STDERR "File $file does not look like a proper DSA, not checking\n" if $opt_v;
		return 1;
	}
	print STDERR "Parsing DSA $dsa from file $file\n" if $opt_v;

	open (DATAFILE , $file) || die ("Cannot read $file: $!");
	while ($line=<DATAFILE>) {
		chomp $line;
#		print STDERR "Reading $line\n" if $opt_v;
		if ( $line =~ /report_date\>([\d\-\/]+)\<\/define-tag/ )  {
			my $dsadate=$1;
			# Just in case...
			$dsadate =~ s/\-(\d)\-/-0$1-/;
			$dsadate =~ s/\-(\d)$/-0$1/;
			$dsaref{$dsa}{'date'}=$dsadate ;
		}
		if ( $line =~ /secrefs\>(.*?)\<\/define-tag/ ) {
			$dsaref{$dsa}{'secrefs'}=$1 ;
			print STDERR "Extracted security references: $dsaref{$dsa}{'secrefs'}\n" if $opt_v;
		}
		$dsaref{$dsa}{'package'}=$1 if ( $line =~ /packages\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'vulnerable'}=$1 if ( $line =~ /isvulnerable\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'fixed'}=$1 if ( $line =~ /fixed\>(.*?)\<\/define-tag/ ) ;
		# Binary packages are pushed into an array
		# Those are prepended by fileurls
		# NOTE: Packages do _not_ include epochs (that should be
		# fixed)
		if ( defined($dsaref{$dsa}{'package'}) &&
			$line =~ /fileurl [\w:\/\.]+\Q$dsaref{$dsa}{'package'}\E\/(.*?)\.deb/ ) {
			($binary, $version, $architecture ) = split (/_/,$1);
			# Only add a binary package if there is no one
			# yet like it
			if ( ! defined ($dsaref{$dsa}{'bpackages'}) ) {
				$dsaref{$dsa}{'bpackages'} = $binary;
				$dsaref{$dsa}{'versions'} = $version;
			} elsif ( $binary !~ /\Q$dsaref{$dsa}{'bpackages'}\E/ ) {
				$dsaref{$dsa}{'bpackages'} = $dsaref{$dsa}{'bpackages'}." ".$binary;
				$dsaref{$dsa}{'versions'} = $dsaref{$dsa}{'versions'}." ".$version;
			}
			# Similarly for arquitectures
			if ( ! defined ($dsaref{$dsa}{'architectures'}) ) {
				$dsaref{$dsa}{'architectures'} = $architecture;
			} elsif ( $dsaref{$dsa}{'architectures'} !~ /\Q$architecture\E/ ) {
				$dsaref{$dsa}{'architectures'} = $dsaref{$dsa}{'architectures'} . " " .  $architecture;
			}
		}
	}
	close DATAFILE;
	return 0;
}

sub parsedirs {
	my ($directory, $postfix, $depth) = @_ ;
	my $dir = new IO::File;
	if ( $depth == 0 ) {
		print STDERR "Maximum depth reached ($depth) at $directory\n" if $opt_v;
		return 0;
	}
	opendir ($dir , $directory) || die ("Cannot read $directory: $!");
	while ( my $file = readdir ($dir) ) {
		print STDERR "Checking $file (for $postfix at $depth)\n" if $opt_v;
		if ( -d "${directory}/${file}"  and ! -l "${directory}/${file}" && $file !~ /^\./ ) {
			print STDERR "Entering directory ${directory}/${file}\n" if $opt_v;
			parsedirs ( "${directory}/${file}", $postfix, $depth - 1 );
		} 
		if ( -r "${directory}/${file}" && $file =~ /$postfix/ && $file !~ /^[\.\#]/ ) {
			parsefile($directory."/".$file,$file);
		}
	} # of the while
	closedir $dir;
	return 0;
}

