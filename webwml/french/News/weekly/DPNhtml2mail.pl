#!/usr/bin/env perl

# Author: Jean-Edouard Babin, radius in gmail.com

# Todo
# - Debug need to be implemented/improved
# - Remove the remaining space un first <li>
# - Better \n removing

# History
# Revision 1.1 01/02/2009 03:39
# Split parse & print / Wrapping

# Revision 1.0 31/01/2009 23:35
# Initial Version

use strict;
use warnings;

use HTML::TokeParser::Simple;
use LWP::UserAgent;
use Getopt::Long;
use Text::Wrap;

$Text::Wrap::columns = 80;
my %opts;
my $data;
my @links;

my $link_index = 1;
my $footer_found = 0;
my $stories_index = 0;
my $paragraph_index = 0;


# Output to UTF-8, May be needed for some langage
# binmode(STDOUT, ":encoding(UTF-8)");

# Base config
my $default_url  = $opts{u} = 'http://debian.org/News/weekly/';
my $default_lang = $opts{l} = 'en';
                   $opts{d} = 0;

# Option parsing
GetOptions(\%opts, 'u=s', 'i=s', 'l=s', 'd');

if (!defined($opts{i})) {
	print STDERR "Usage: $0 -i issue [-l lang] [-u base_url] [-d]\n";
	print STDERR " -i issue number (i.e.: 2008/17)\n";
	print STDERR " -l langage (i.e.: fr). Default value is \"-l $default_lang\"\n";
	print STDERR " -u base_url: DPN common URL. Default value is \"-u $default_url\"\n";
	print STDERR " -d for verbose output\n";
	exit 1;
}

if ($opts{d} == 1) {
	use Data::Dumper; #useful for debug only
}

# HTML file fetching
my $ua = LWP::UserAgent->new;
$ua->agent("DPNhtml2mail");

my $req = HTTP::Request->new(GET => "$opts{u}$opts{i}/index.$opts{l}.html");
my $res = $ua->request($req);
if (! $res->is_success) {
	die "Can't fetch $opts{u}$opts{i}/index.$opts{l}.html ".$res->status_line;
}

# Start of parsing / storage
my $p = HTML::TokeParser::Simple->new(\$res->content);
my $token = $p->get_tag("h1");
$data->{header}{title} = $p->get_trimmed_text;
$data->{header}{url}   = "$opts{u}$opts{i}/";

while (my $token = $p->get_tag) {
	if ($token->is_start_tag('a')) {
		if (defined($token->[1]{'name'}) && $token->[1]{'name'} =~ /^\d+$/) {	# New story
			$paragraph_index = 0;
			$stories_index++;
			# Get story name
			$p->get_tag("h2") if ($token->[1]{'name'} != 0);
			$data->{stories}[$stories_index]{'title'} = $p->get_trimmed_text;
		} else {																# Common link
			$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= $p->get_trimmed_text . " [".$link_index."]";
			push(@{$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'links'}}, { 'index' => $link_index++, 'link' => $token->[1]{'href'} || '-' });
		}
	} elsif ($token->is_tag('q')) {
		if ($token->is_start_tag('q')) {
			$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= "« ".$p->get_trimmed_text;
		} elsif ($token->is_end_tag('q')) {
			$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= " »".$p->get_trimmed_text;
		}
	} elsif ($token->is_end_tag('p')) {
		$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= "\n\n";
		delete @links[0..$#links];
		$paragraph_index++;
		$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= $p->get_text;
	} elsif ($token->is_tag('li')) {
		if ($token->is_start_tag('li')) {
			$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= "  * ".$p->get_trimmed_text;
		} elsif ($token->is_end_tag('li')) {
			$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= "\n" . $p->get_trimmed_text;
		}
	} elsif ($token->is_start_tag('hr')) {
		last if ($footer_found);
		$p->get_tag('p');
		$p->get_tag('p');
		$p->get_token('p');
		$p->get_token('p');
		$p->get_token('p');
		$p->get_token('p');
		$footer_found = 1;
	} else {
		$data->{stories}[$stories_index]{'paragraph'}[$paragraph_index]{'text'} .= $p->get_text;
	}
}

# Start of formating / printing

my $len1 = length($data->{header}{title});
my $len2 = length($data->{header}{url});
my $len = ($len1 > $len2 ? $len1 : $len2);
print "-"x$len."\n" . $data->{header}{title}. "\n" . $data->{header}{url}."\n" ."-"x$len."\n";
print "\n";

foreach my $stories (@{$data->{stories}}) {
	print "\n" . $stories->{'title'} . "\n" . '-'x(length($stories->{'title'})). "\n" if (defined($stories->{'title'}));
	foreach my $paragraph (@{$stories->{paragraph}}) {
		$paragraph->{'text'} =~ s/(\S)\n(\S)/$1 $2/g;
		print wrap("","",$paragraph->{'text'});
		print "\n";
		foreach my $link (@{$paragraph->{'links'}}) {
			print "   $link->{'index'} : $link->{'link'}\n";
		}
	}
}
