#!/usr/bin/perl -w

# This is GPL'ed code, copyright 1998 Paolo Molaro <lupus@debian.org>.

# Little utility to keep track of translations in the debian CVS repo.
# Invoke as check_trans.pl [-v] [-d] [-s subtree] [language] 
# from the webwml directory, eg:
# $ check_trans.pl -v italian
# You may also check only some subtrees as in:
# $ check_trans.pl -s devel italian

# Option:
# 	-v	enable verbose mode
#	-d	output diff 

# Translators need to embed in the files they translate a comment
# in its own line with the revision of the file they translated such as:
# #use wml::debian::translation-check translation="revision"
# (Old form <!--translation revision--> works too.)
# The revision can be obtained from the CVS/Entries files or from
# the command "cvs status filename".

# TODO: 
# need to quote dirnames?
# use a file to bind a file to a translator?

use Getopt::Std;
use IO::Handle;

$opt_d = 0;
$opt_s = '';
$opt_p = undef;
getopts('vds:p:');

warn "Checking subtree $opt_s only\n" if $opt_v;

# include only files matching $filename
$filename = $opt_p || '(\.wml$)|(\.html$)';

# get configuration
if (open CONF, "<language.conf")
{
	$defaultlanguage = <CONF>;
	chomp $defaultlanguage;
	close CONF;
}
else
{
	$defaultlanguage = 'italian';
}

$from = 'english';
$to = shift || $defaultlanguage;

$from = "$from/$opt_s";
$to = "$to/$opt_s";

@en= split(/\n/, `find $from -name Entries -print`);

foreach (@en) {
	next if $_ =~ "template/debian";
	my ($path, $tpath, $d);
	$path = $_;
	$path =~ s#CVS/Entries$##;
	$tpath = $path;
	$tpath =~ s/^$from/$to/o;
	$d = load_entries($_);
	$ignore = load_ignorelist($tpath);
	foreach $f (keys %$d) {
		check_file("${tpath}$f", $d->{$f}) unless $$ignore{"${tpath}$f"};
	}
}

sub load_entries {
	my ($name) = shift;
	my (%data);
	warn "Loading $name\n" if $opt_v;
	open(F, $name) || die $!;
	while(<F>) {
		next unless m#^/#;
		if ( m#^/([^/]+)/([^/]+)/# ) {
			my($name, $rev) =($1, $2);
			$data{$name} = $rev if $name =~ /$filename/o;
		}
	}
	close (F);
	return \%data;
}

sub load_ignorelist {
	my ($dir) = shift;
	my (%data);
	open(F, "${dir}.transignore") || return \%data;
	warn "Loading ${dir}.transignore\n" if $opt_v;
	while(<F>) {
		chomp;
		$data{"$dir$_"} = 1;
	}
	close (F);
	return \%data;
}

sub check_file {
	my ($name, $revision) = @_;
	my ($oldr, $oldname);
	warn "Checking $name\n" if $opt_v;
	unless (-r $name) {
		print "Missing $name\n";
		return;
	}
	open(F, $name) || die $!;
	while(<F>) {
		if (/translation(\s+|=")([.0-9]*)("|\s*-->)\s*$/oi) {
			warn "Found revision $2\n" if $opt_v;
			$oldr = $2;
			if ($oldr eq $revision) {
				close(F);
				return;
			}
			last;
		}
	}
	close(F);
	if ($opt_d) {
		$oldr ||= '1.1';
		$oldname = $name;
		$oldname =~ s/^$to/$from/;
		STDOUT->flush;
		system("cvs -z3 diff -u -r '$oldr' -r '$revision' '$oldname'");
		STDOUT->flush;
	} else {
		print "NeedToUpdate $name to version $revision\n";
	}
}

