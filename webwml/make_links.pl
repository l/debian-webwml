#!/usr/bin/perl -w

# This script creates any missing soft links in the Debian html
# directory on master. These links are necessary so that under content
# negotiation there is a default language.
# Translators shouldn't have any need of this.

# For every <file>.html.en there needs to be a <file>.html -> <file>.html.en

$top_dir = "/debian2/web/debian.org";

check_directory($top_dir);

sub check_directory() {
	my ($curdir) = @_;
	my (@dir_list, @fil_list, @parts, $lang, $html, $name);

	print "$curdir\n";
	opendir(DIR, $curdir) or die "can't opendir $curdir: $!";
	@dir_list = grep { -d "$curdir/$_" and $_ !~ /^..?$/ and ! -l "$curdir/$_" and
			$_ ne "gnome" and $_ ne "OpenHardware" and $_ ne "OpenSource" and
			$_ ne "berlin"} readdir(DIR);
	rewinddir DIR;
	@fil_list = grep { -f "$curdir/$_" } readdir(DIR);
	foreach (@dir_list) {
		check_directory("$curdir/$_");
	}
	foreach $file (@fil_list) {
		@parts = split('\.', $file);
		$lang = pop @parts;
		$html = pop @parts;
		$name = join('.', @parts);
		if (defined($html) and $lang =~ /^en$/ and $html eq "html") {
			if ( ! -e "$curdir/$name.html") {
				symlink("$file", "$curdir/$name.html");
				print "  creating symlink to $curdir/$file\n";
			}
		}
	}
}
