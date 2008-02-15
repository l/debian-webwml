#!/usr/bin/perl
#
# Checks mirror sites to see if they carry a specified architecture.
# Usage: check_arch.pl arch mirrorlist
# Outputs a list of the mirrors that do carry that arch, based on their
# Release files.

my $arch=shift;
$|=1;

my $site;
while (<>) {
	chomp;
	if (/^Site:\s+(.*)/) {
		$site=$1;
	}
	elsif (/^Archive-http:\s+(.*)/) {
		check($site, "http", $1);
	}
	elsif (/^Archive-ftp:\s+(.*)/) {
		check($site, "ftp", $1);
	}
}

sub check {
	my $site=shift;
	my $proto=shift;
	my $dir=shift;
	my $url="$proto://$site$dir/dists/unstable/main/binary-$arch/Release";
	print "$site ($proto)\t";
	open (WGET, "wget -q -O- '$url' |");
	my $found=0;
	while (<WGET>) {
		chomp;
		if (/^Architecture: $arch$/) {
			$found=1;
		}
	}
	if ($found) {
		print "has $arch\n";
	}
	elsif (!close WGET && !$found) {
		print STDERR "download error for $url\n";
	}
	else {
		print "missing $arch\n";
	}
}
