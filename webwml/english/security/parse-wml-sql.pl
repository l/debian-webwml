#!/usr/bin/perl
# Extracts the data file and creates SQL calls to insert into
# a database
#
# TODO add tag
# moreinfo and description to the database
#

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


parsedirs (".", "data", 2);


# Data
printdsas();
# References
printrefs();

exit 0;

sub printdsas {
	foreach $dsa ( keys %dsaref) {
		print "INSERT INTO DSA (\"dsaid\") VALUES ('$dsa');\n";
		print "UPDATE DSA SET ";
		foreach $key (keys %{$dsaref{$dsa}} ) {
			print "\"$key\"='$dsaref{$dsa}{$key}', " if ( $key ne "secrefs" ) ;
		}
		print " \"dsaid\"='$dsa' ";
		print "WHERE \"dsaid\"='$dsa';\n";
	}
	return 0;
}

sub printreferences {
	my ($dsa) = @_;
	print "Printing references for $dsa\n" if $opt_v;
	foreach $ref ( split(' ', $dsaref{$dsa}{'secrefs'}) ) {
		my $query="INSERT INTO ";
		if ( $ref =~ /((CVE|CAN)-[\d-]+)/i )  {
			$query .= "cvedsa (\"cve\", \"dsaid\") ";
			$query .= "VALUES ('$ref','$dsa');\n";
		}
		if ( $ref =~ /BID(\d+)/i ) {
			$query .= "biddsa (\"bid\", \"dsaid\") ";
			$query .= "VALUES ('$1','$dsa');\n";
		}
		if ( $ref =~ /CA-[\d-]+/i ) {
			$query .= "certcadsa (\"caid\", \"dsaid\") ";
			$query .= "VALUES ('$ref','$dsa');\n";
		}
		if ( $ref =~ /VU\#([\d-]+)/i ) {
			$query .= "certvudsa (\"vuid\", \"dsaid\") ";
			$query .= "VALUES ('$1','$dsa');\n";
		}
		# Since we don't support some references like  Bug#XXXXX
		# exclude them
		print $query if $query ne "INSERT INTO ";
	}
	return 0;
}

sub printrefs {
	foreach $dsa ( keys %dsaref) {
		printreferences($dsa);
	}
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
	}
#	$dsaref{$dsa}{'location'}=$file;
#	$dsaref{$dsa}{'location'} =~ s/.data$//;
#	$dsaref{$dsa}{'location'} =~ s/^.\///;
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

