#!/usr/bin/perl
# Generates debian weekly news in text format, suitable for mailing to
# debian-news, of the current issue that is on the web site. Or, if you
# pass an url as the first parameter, will use the issue there instead.
my $url=shift || 'http://debian.org/News/weekly/current/issue/';

my $divider=("-" x 75). "\n";

# Start skipping lines, because the page dump begins with some garbage.
my $skip=1;
# This keeps track of how many links have been skipped over, so the rest
# can be fixed up.
my $skippedlinks=0;
# The highest numbered link that was seen (not skipped).
my $highlink=0;

open (IN, "lynx -dump $url |");
while (<IN>) {
	# We exit this loop once we hit the first divider bar,
	# which indicates the end of the newsletter proper.
	last if /____________/;

	s/^\s\s\s//; # kill lynx's indent.

	unless ($skip) {
		# Fix up links.
		s/\[(\d+)\]/$highlink=$1; "[".($1 - $skippedlinks)."]"/eg;
		print $_;
	}
	else {
		$skippedlinks++ while m/\[\d+\]/g;
	}

	# See if it's time to stop skipping.
	if ($skip && /^\s+Debian Weekly News - /) {
		# Title found, stop skipping. But first, print the header.
		s/^\s*//;
		print $divider,
		      "Debian Weekly News\n",
		      "http://www.debian.org/News/weekly/current/issue/\n",
		      $_,
		      $divider;

		$skip=0;
	}
}

# Once we get here, all that remains is some junk, some links we should
# print, and more junk. So scan forward to the links, and print them.
while (<IN>) {
	last if m/^\s\s\sVisible links/;
}
print "\n", $divider, "References\n";
while (<IN>) {
	s/^\s+//; # kill lynx's indent.
	if (/^(\d+)/) {
		# Don't print the links we skipped earlier.
		if ($1 > $skippedlinks && $1 <= $highlink) {
			# Print line, fixing link number.
			s/^(\d+)/$1 - $skippedlinks/e;
			print "  $_";
		}
	}
	else {
		# End of links.
		close IN;
	}
}
