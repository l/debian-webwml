#!/usr/bin/perl
# Extracts the data file and makes a CVE cross-reference


# Format of data files is:
#<define-tag pagetitle>DSA-###-# PACKAGE</define-tag>
#<define-tag report_date>yyyy-mm-dd</define-tag>
#<define-tag secrefs>CAN|CVE-XXXX-XXXX</define-tag>
#<define-tag packages>PACKAGE</define-tag>
#<define-tag isvulnerable>yes|no</define-tag>
#<define-tag fixed>yes|no</define-tag>


use Getopt::Std;
use IO::File;
# Stdin options
# -v verbose
getopts('v');

#printHeader();
parsedirs (".", "data", 2);

# We just print for the time being only CVE references
printcverefs();

# But we could also print all the keys like this:
# printallkeys();

#printFooter ();

exit 0;

sub printallkeys {
	foreach $dsa (sort(keys %dsaref)) {
		print "$dsa:\t";
		foreach $key (keys %{$dsaref{$dsa}} ) {
			print "$dsaref{$dsa}{$key}\t";
		}
		print "\n";
	}
	return 0;
}

sub printcverefs {

	print "DSA\tCVE|CAN\n";
	foreach $dsa (sort(keys %dsaref)) {
		my (@references) = split(' ', $dsaref{$dsa}{'secrefs'});
		my $cveexists=0;
		my $cverefs="";
		foreach $ref ( pop (@references) ) {
			if ( $ref =~ /^CVE|CAN/  ) {
				$cverefs .= "$ref\t" ;
				$cveexists=1;
			}
		}
		print "DSA-$dsa\t".$cverefs."\n" if $cveexists;
	}
}

sub parsefile {
	my ($file) = @_ ;
	print STDERR "Parsing DSA file $file\n" if $opt_v;
# The filename gives us the DSA we are parsing
	if ( $file =~ /dsa\-(\d+)/ ) {
		$dsa=$1;
	} else {
		print STDERR "File $file does not look like a proper DSA, not checking\n" if $opt_v;
		return 1;
	}

	open (DATAFILE , $file) || die ("Cannot read $file: $!");
	while ($line=<DATAFILE>) {
		chomp $line;
		print STDERR "Reading $line\n" if $opt_v;
		$dsaref{$dsa}{'date'}=$1 if ( $line =~ /report_date\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'secrefs'}=$1 if ( $line =~ /secrefs\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'packages'}=$1 if ( $line =~ /packages\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'vulnerable'}=$1 if ( $line =~ /isvulnerable\>(.*?)\<\/define-tag/ ) ;
		$dsaref{$dsa}{'fixed'}=$1 if ( $line =~ /fixed\>(.*?)\<\/define-tag/ ) ;
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
			parsefile($directory."/".$file);
		}
	} # of the while
	closedir $dir;
	return 0;
}


