#!/usr/bin/perl
#  Copyright 1998-1999 Christophe Le Bars <clebars@debian.org>
#  Copyright 1998 Paolo Molaro <lupus@debian.org> for update_db load_entries check_file
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

use strict;

use vars qw($translations $root $from $to $key $translation $translator $line);

do 'translations-bd.pl';

$root = '../..';
$from = 'english';
$to = 'french';

sub update_db {

	my $filename = '\.wml$';

	my @from= split(/\n/, `find $root/$from/ -name Entries -print`);

	foreach (@from) {
		my ($from_path, $to_path, $from_d, $to_d);
		$from_path = $_;
		$to_path = $_;
		$to_path =~ s#/$from/#/$to/#o;
		my $from_d = load_entries($from_path,$filename);
		my $to_d = load_entries($to_path,$filename);
		$from_path =~ s#CVS/Entries$##;
		$to_path =~ s#CVS/Entries$##;
		foreach my $f (keys %$from_d) {
			my $key = $from_path . $f;
			$key =~ s#^$root/$from/##;
			$key =~ s#\.wml$##;
			if ($translations->{$key}) {
				$translations->{$key}->{'version'} = $from_d->{$f};
				$translations->{$key}->{'translation_revision'} = $to_d->{$f} if ($to_d->{$f});
				check_file($key, "${to_path}$f", $from_d->{$f});
			} else {
				#print "\tWarning : $key undef\n";
			}
		}
}

}


sub dump_html {

        my ($status, $ddp) = @_;

while (($key, $translation) = each %$translations) {
	
	next if ($translation->{'status'} ne $status);
	next if ($ddp eq 'yes' && $translation->{'type'} ne 'DDP');

	if ($translation->{'type'} eq 'DDP' && $key) {
		$translation->{'url'} = 
			'http://www.debian.org/~elphick/manuals.html/'
			. $key . '/'
			if (!$translation->{'url'});
		$translation->{'cvs_url'} = 
			'http://www.debian.org/cgi-bin/cvsweb/debian-doc/ddp/manuals.sgml/'
			. $key . '/' . $key . '.sgml'
			if (!$translation->{'cvs_url'});
		if ($translation->{'status'} ne 'non-disponible'
			&& $translation->{'status'} ne 'à traduire'
			&& $translation->{'status'} ne 'en cours de traduction') {
			$translation->{'translation_url'} = 
				'http://www.debian.org/~clebars/f2dp/docs/'
				. $key . '.fr.html/'
				if (!$translation->{'translation_url'});
			$translation->{'translation_cvs_url'} = 
				'http://www.debian.org/~clebars/f2dp/docs/'
				. $key . '.fr.sgml'
				if (!$translation->{'translation_cvs_url'});
		}
	}

	if ($translation->{'type'} eq 'Web' && $key) {

		$translation->{'name'} = $key . '.en.html'
			if (!$translation->{'name'});
		$translation->{'url'} = 
			'http://www.debian.org/'
			. $key . '.en.html'
			if (!$translation->{'url'});
		 $translation->{'cvs_url'} = 
			'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/'
			. $key . '.wml'
			if (!$translation->{'cvs_url'});
		 $translation->{'source_url'} = 
			'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/'
			. $key . '.wml'
			. '?rev=' . $translation->{'version'}
			if (!$translation->{'source_url'} && $translation->{'version'});
		if ($translation->{'status'} ne 'à traduire' && $translation->{'status'} ne 'en cours de traduction') {
			$translation->{'translation_name'} = $key . '.fr.html'
				if (!$translation->{'translation_name'});
			$translation->{'translation_url'} = 
				'http://www.debian.org/'
				. $key . '.fr.html'
				if (!$translation->{'translation_url'});
			$translation->{'translation_cvs_url'} = 
				'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/french/'
				. $key . '.wml'
				if (!$translation->{'translation_cvs_url'} && $translation->{'translation_revision'});
			$translation->{'translation_source_url'} = 
				'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/french/'
				. $key . '.wml'
				. '?rev=' . $translation->{'translation_revision'}
				if (!$translation->{'translation_source_url'} && $translation->{'translation_revision'});
			$translation->{'diff'} = 
				'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/'
				. $key . '.wml'
				. $translation->{'diff'}
				if ($translation->{'diff'});
		}
	}

	$translation->{'translation_name'} = $translation->{'name'} . ' (original)'
		if (!$translation->{'translation_name'});
	$translation->{'translation_url'} = $translation->{'url'}
		if (!$translation->{'translation_url'});

        print(STDOUT <<__EOHTML__);
	<LI>
        <A HREF="$translation->{'translation_url'}">
        <B><I>$translation->{'translation_name'}</I> $translation->{'translation_sub_name'}</B></A>
__EOHTML__
	print "<BLOCKQUOTE>";
	my $translation_source_name = $translation->{'translation_cvs_url'};
	$translation_source_name =~ s/.*\/([^\/]+)$/$1/;
	print "<BR>Source : <A HREF=\"$translation->{'translation_source_url'}\">$translation_source_name</A>"
		if ($translation->{'translation_source_url'} && $ddp ne 'yes');
	print " (<A HREF=\"$translation->{'translation_cvs_url'}\">Page CVS</A>)"
		if ($translation->{'translation_cvs_url'} && $ddp ne 'yes');
	print "<BR>URL de développement de la traduction : <A HREF=\"$translation->{'translation_dev_url'}\">$translation->{'translation_dev_url'}</A>"
		if ($translation->{'translation_dev_url'} && $ddp ne 'yes');
	if ($translation->{'translation_maintainer'}) {
		print "<BR>Responsable(s) de la traduction : " ;
		$line = '';
		foreach $translator (@{$translation->{'translation_maintainer'}}) {
			$translator =~ /([^\<]+)\s\<(.*)\>/;
			$line .= " <A HREF=\"mailto:$2\"><I>$1</I></A> et";
		}
		$line =~ s/et$//;
		print $line;
	}

	print("<BR>Status : $translation->{'status'}");
	print(" depuis le $translation->{'since'}") if ($translation->{'since'});
	print "<BR>Version de la traduction : $translation->{'translation_revision'}" if ($translation->{'translation_revision'});
	print "<BR>Version du document original sur laquelle se base la traduction : $translation->{'translation_version'}" if ($translation->{'translation_version'});
	print "<BR>Différence entre la version traduite et la dernière : <A HREF=\"$translation->{'diff'}\">fichier diff CVS</A>" if ($translation->{'diff'});
	print "<BR>Disponible dans le paquet $translation->{'translation_package'}" if ($translation->{'translation_package'});
	if ($translation->{'translation_name'} !~ /original/) {
	        print(STDOUT <<__EOHTML__);
		<BR>
       		 Document original : 
		<A HREF="$translation->{'url'}">
		<I>$translation->{'name'}</I> $translation->{'sub_name'}</A>
__EOHTML__
	}

	print " ( version $translation->{'version'} ) " if ($translation->{'version'});
	print " ( inclus dans le paquet $translation->{'package'} ) " if ($translation->{'package'});
	print " ( <A HREF=\"$translation->{'source_url'}\">source</A> ) " if ($translation->{'source_url'} && $translation->{'source_url'} ne '?' && $ddp ne 'yes');
	print " ( <A HREF=\"$translation->{'cvs_url'}\">page CVS</A> ) " if ($translation->{'cvs_url'} && $translation->{'cvs_url'} ne '?' && $ddp ne 'yes');
	print "</BLOCKQUOTE><P>&nbsp;";

}

}

sub load_entries {
	my ($name) = shift;
	my ($filename) = shift;
	my (%data);
	open(F, $name) || return;
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

sub check_file {
	my ($key, $name, $revision) = @_;
	my ($oldr, $oldname);
	unless (-r $name) {
		#print "Missing $name\n";
		return;
	}
	open(F, $name) || die $!;
	while(<F>) {
		if (/<!--\s*translation\s+(.*)?\s*-->\s*$/oi) {
			$oldr = $1;
			$translations->{$key}->{'translation_version'} = $oldr;
			if ($oldr eq $revision) {
				close(F);
				return;
			}
			last;
		}
	}
	close(F);
	$translations->{$key}->{'status'} = 'à reviser';
	$translations->{$key}->{'diff'} = "?r1=$oldr&r2=$revision";
}

#update_db();
#dump_html('à relire');
