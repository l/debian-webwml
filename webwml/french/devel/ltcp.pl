#!/usr/bin/perl
#  Copyright 1998-1999 Christophe Le Bars <clebars@debian.org>
#  Copyright 1998 Paolo Molaro <lupus@debian.org> for update_db_CVS load_entries check_file
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

#
# $DEBIAN_CVS must be defined
#

use vars qw($translations $types $root $from $to $translator $line);

# $t : current document record
# $k : current document key
# $f : current document field

use vars qw($t $k $f);

do 'translations-bd.pl';

$root = '../..';
$from = 'english';
$to = 'french';

$types = {

'Web' => {
	'name'			=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"$k.en.html" },
	'url'			=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"http://www.debian.org/$k.en.html" },
	'cvs_url'		=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/$k.wml" },
	'source_url'		=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/$k.wml?rev=$t->{'revision'}" },
	'translation_name'	=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"$k.fr.html" },
	'translation_url'	=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"http://www.debian.org/$k.fr.html" },
	'translation_cvs_url'	=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/french/$k.wml" },
	'translation_source_url'=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/french/$k.wml?rev=$t->{'translation_revision'}" },
	'diff'			=> sub {my($t, $k, $f)=@_; return (!$t->{$f} || !$t->{'translation_revision'}) ? undef :
					"http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/english/$k.wml$t->{$f}" },
},

'DDP' => {
	'url'			=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"http://www.debian.org/~elphick/manuals.html/$k/" },
},

};

sub update_db_CVS {

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
			my $k = $from_path . $f;
			$k =~ s#^$root/$from/##;
			$k =~ s#\.wml$##;
			if ($translations->{$k}) {
				$translations->{$k}->{'revision'} = $from_d->{$f};
				$translations->{$k}->{'translation_revision'} = $to_d->{$f} if ($to_d->{$f});
				check_file($k, "${to_path}$f", $from_d->{$f});
			} else {
				$translations->{$k}->{'type'} = 'Web';
				$translations->{$k}->{'status'} = 'à traduire';
				$translations->{$k}->{'revision'} = $from_d->{$f};
				#print "\tWarning : $k undef\n";
			}
		}
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
	my ($k, $name, $revision) = @_;
	my ($oldr, $oldname);
	unless (-r $name) {
		#print "Missing $name\n";
		return;
	}
	open(F, $name) || die $!;
	while(<F>) {
		if (/<!--\s*translation\s+(.*)?\s*-->\s*$/oi) {
			$oldr = $1;
			$translations->{$k}->{'base_revision'} = $oldr;
			if ($oldr eq $revision) {
				close(F);
				return;
			}
			last;
		}
	}
	close(F);
	$translations->{$k}->{'status'} = 'à reviser';
	$translations->{$k}->{'diff'} = "?r1=$oldr&r2=$revision";
}


sub update_db_format {

while (($k, $t) = each %$translations) {
	
	if ($t->{'type'} eq 'DDP' && $k) {
		#
		# XXX généraliser la routine CVS avant de pousser ce passage dans $types...
		#
		if ($t->{'status'} ne 'non-disponible'
			&& $t->{'status'} ne 'à traduire'
			&& $t->{'status'} ne 'en cours de traduction') {
			$t->{'translation_url'} = 
				'http://www.debian.org/~clebars/f2dp/docs/'
				. $k . '.fr.html/'
				if (!$t->{'translation_url'});
			$t->{'translation_cvs_url'} = 
				'http://www.debian.org/~clebars/f2dp/docs/'
				. $k . '.fr.sgml'
				if (!$t->{'translation_cvs_url'});
		}
	}

	next unless ($k);

	foreach my $f (keys %{$types->{$t->{'type'}}}) {
		$t->{$f} = &{$types->{$t->{'type'}}->{$f}}($t, $k, $f);
	} 

	if ($k eq 'international/French') {

		foreach my $f ('name', 'sub_name', 'revision', 'url', 'cvs_url', 'source_url', 'package') {
			my $tmp = $t->{$f};
			$t->{$f} = $t->{'translation_'.$f};
			$t->{'translation_'.$f} = $tmp;
		}
		
		$t->{'diff'} = '';
		$t->{'base_revision'} = '';
		check_file($k, "$root/$from/international/French.wml", $t->{'revision'});
		$t->{'diff'} = "http://www.debian.org/cgi-bin/cvsweb/webwml/webwml/french/$k.wml$t->{$f}".$t->{'diff'} if ($t->{'diff'});
	}
}
}


sub dump_html {

        my ($status, $ddp) = @_;

while (($k, $t) = each %$translations) {

	next if ($t->{'status'} ne $status);
	next if ($ddp eq 'yes' && $t->{'type'} ne 'DDP');

	$t->{'translation_name'} = $t->{'name'} . ' (original)'
		if (!$t->{'translation_name'});
	$t->{'translation_url'} = $t->{'url'}
		if (!$t->{'translation_url'});

        print(STDOUT <<__EOHTML__);
	<LI>
        <A HREF="$t->{'translation_url'}">
        <B><I>$t->{'translation_name'}</I> $t->{'translation_sub_name'}</B></A>
__EOHTML__
	print "<BLOCKQUOTE>";
	my $translation_source_name = $t->{'translation_cvs_url'};
	$translation_source_name =~ s/.*\/([^\/]+)$/$1/;
	print "<BR>Source : <A HREF=\"$t->{'translation_source_url'}\">$translation_source_name</A>"
		if ($t->{'translation_source_url'} && $ddp ne 'yes');
	print " (<A HREF=\"$t->{'translation_cvs_url'}\">Page CVS</A>)"
		if ($t->{'translation_cvs_url'} && $ddp ne 'yes');
	print "<BR>URL de développement de la traduction : <A HREF=\"$t->{'translation_dev_url'}\">$t->{'translation_dev_url'}</A>"
		if ($t->{'translation_dev_url'} && $ddp ne 'yes');
	if ($t->{'translation_maintainer'}) {
		print "<BR>Responsable(s) de la traduction : " ;
		$line = '';
		foreach $translator (@{$t->{'translation_maintainer'}}) {
			$translator =~ /([^\<]+)\s\<(.*)\>/;
			$line .= " <A HREF=\"mailto:$2\"><I>$1</I></A> et";
		}
		$line =~ s/et$//;
		print $line;
	}

	print("<BR>Status : $t->{'status'}");
	print(" depuis le $t->{'since'}") if ($t->{'since'});
	print "<BR>Révision de la traduction : $t->{'translation_revision'}" if ($t->{'translation_revision'});
	print "<BR>Révision du document original sur laquelle se base la traduction : $t->{'base_revision'}" if ($t->{'base_revision'});
	print "<BR>Différence entre la révision traduite et la dernière : <A HREF=\"$t->{'diff'}\">fichier diff CVS</A>" if ($t->{'diff'});
	print "<BR>Disponible dans le paquet $t->{'translation_package'}" if ($t->{'translation_package'});
	if ($t->{'translation_name'} !~ /original/) {
	        print(STDOUT <<__EOHTML__);
		<BR>
       		 Document original : 
		<A HREF="$t->{'url'}">
		<I>$t->{'name'}</I> $t->{'sub_name'}</A>
__EOHTML__
	}

	print " ( révision $t->{'revision'} ) " if ($t->{'revision'});
	print " ( inclus dans le paquet $t->{'package'} ) " if ($t->{'package'});
	print " ( <A HREF=\"$t->{'source_url'}\">source</A> ) " if ($t->{'source_url'} && $t->{'source_url'} ne '?' && $ddp ne 'yes');
	print " ( <A HREF=\"$t->{'cvs_url'}\">page CVS</A> ) " if ($t->{'cvs_url'} && $t->{'cvs_url'} ne '?' && $ddp ne 'yes');
	print "</BLOCKQUOTE><P>&nbsp;";

}
}


#update_db();
#dump_html('à relire');
