#!/usr/bin/perl
#  Copyright (C) 1998 Christophe Le Bars
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

use vars qw($translations $translation $translator $line);

do 'translations-bd.pl';

sub dump_html {

        my ($status, $ddp) = @_;

foreach $translation (@$translations) {
	
	next if ($translation->{'status'} ne $status);
	next if ($ddp eq 'yes' && $translation->{'type'} ne 'DDP');

	if ($translation->{'type'} eq 'DDP' && $translation->{'key'}) {
		$translation->{'url'} = 
			'http://www.debian.org/~elphick/manuals.html/'
			. $translation->{'key'} . '/'
			if (!$translation->{'url'});
		$translation->{'source_url'} = 
			'http://www.debian.org/cgi-bin/cvsweb/debian-doc/ddp/manuals.sgml/'
			. $translation->{'key'} . '/' . $translation->{'key'}
			. '.sgml'
			if (!$translation->{'source_url'});
		if ($translation->{'status'} ne 'non-disponible'
			&& $translation->{'status'} ne 'à traduire'
			&& $translation->{'status'} ne 'en cours de traduction') {
			$translation->{'translation_url'} = 
				'http://www.debian.org/~clebars/f2dp/docs/'
				. $translation->{'key'} . '.fr.html/'
				if (!$translation->{'translation_url'});
			$translation->{'translation_source_url'} = 
				'http://www.debian.org/~clebars/f2dp/docs/'
				. $translation->{'key'} . '.fr.sgml'
				if (!$translation->{'translation_source_url'});
		}
	}

	if ($translation->{'type'} eq 'Web' && $translation->{'key'}) {
		$translation->{'name'} = $translation->{'key'} . '.en.html'
			if (!$translation->{'name'});
		$translation->{'url'} = 
			'http://www.fr.debian.org/'
			. $translation->{'key'}
			. '.en.html'
			if (!$translation->{'url'});
		$translation->{'source_url'} = 
			'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/'
			. $translation->{'key'}
			. '.wml'
			if (!$translation->{'source_url'});
		if ($translation->{'status'} ne 'à traduire' && $translation->{'status'} ne 'en cours de traduction') {
			$translation->{'translation_name'} = $translation->{'key'} . '.fr.html'
				if (!$translation->{'translation_name'});
			$translation->{'translation_url'} = 
				'http://www.fr.debian.org/'
				. $translation->{'key'}
				. '.fr.html'
				if (!$translation->{'translation_url'});
			$translation->{'translation_source_url'} = 
				'http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/french/'
				. $translation->{'key'}
				. '.wml'
				if (!$translation->{'translation_source_url'});
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
	my $translation_source_url_base = $translation->{'translation_source_url'};
	$translation_source_url_base =~ s/.*\/([^\/]+)$/$1/;
	print "<BR>Source : <A HREF=\"$translation->{'translation_source_url'}\">$translation_source_url_base</A>"
		if ($translation->{'translation_source_url'} && $ddp ne 'yes');
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
	print "<BR>Version de la traduction : $translation->{'translation_version'}" if ($translation->{'translation_version'});
	print "<BR>Disponible dans le paquet $translation->{'translation_package'}" if ($translation->{'translation_package'});
	if ($translation->{'translation_name'} !~ /original/) {
	        print(STDOUT <<__EOHTML__);
		<BR>
       		 Original : 
		<A HREF="$translation->{'url'}">
		<I>$translation->{'name'}</I> $translation->{'sub_name'}</A>
__EOHTML__
	}

	print " ( version $translation->{'version'} ) " if ($translation->{'version'});
	print " ( inclus dans le paquet $translation->{'package'} ) " if ($translation->{'package'});
	print " ( <A HREF=\"$translation->{'source_url'}\">source</A> ) " if ($translation->{'source_url'} && $translation->{'source_url'} ne '?' && $ddp ne 'yes');
	print "</BLOCKQUOTE><P>&nbsp;";

}

}