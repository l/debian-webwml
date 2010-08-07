#!/usr/bin/perl
#  Copyright 2000 Javier Fernández-Sanguino Peña <jfs@debian.org>
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
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# --------------------------------------------------------------------------

use strict;

#
# $DEBIAN_CVS must be defined
#

use vars qw($translations %translations_status $types $root $from $to $from_abr $to_abr $CVSWEB $DDPWEB $TRANSWEB @status %tag $debug);

# $t : current document record
# $k : current document key
# $f : current document field


# Read the database status
do 'current_status.pl';


# Global variables
$root = '../../..'; #This should be take from the Makefile
$from = 'english';
$to = 'spanish'; # And this would be better used in the command line
$from_abr = 'en';
$to_abr = 'es' ;
$CVSWEB = 'http://cvs.debian.org/webwml' ; 
$DDPWEB = 'http://www.debian.org/~elphick/manuals.html' ;
# The place were translation documents are kept while working on them
$TRANSWEB = 'http://www.debian.org/international/spanish/translations';
#$TRANSWEB = 'http://www.debian.org/~clebars/f2dp/docs/'

# This matrix has all the values for the $status
# This way we do not have to put it in the %translation database
$status[0]= 'no disponible';
$status[1]= 'no traducido';
$status[2]= 'en fase de traducción';
$status[3]= 'pendiente de revisión';
$status[4]= 'traducción al día';
$status[5]= 'necesita actualización';
$status[6]= 'en fase de revisión';
$status[7]= 'obsoleto';
$status[8]= 'desconocido';

# We cannot do this with tags!
# Wml goes through pass2 before perl substituion in pass3, either make
# the file outside of wml and parse it afterwards or do it this way
$tag{'Source'}= 'fuente';
$tag{'CVSpage'}='página CVS';
$tag{'devel-url'}='URL de desarrollo de la traducción';
$tag{'translation_maintainer'}='Responsable de la traducción';
$tag{'status'}='Estado';
$tag{'translation_revision'}='Revisión de la traducción';
$tag{'since'}='desde';
$tag{'base_revision'}='Versión del documento sobre el que se basa la traducción';
$tag{'diff'}='Diferencias entre la versión traducida y la actual';
$tag{'diff-file'}='Fichero con las diferencias';
$tag{'available'}='Disponible en el paquete';
$tag{'originaldoc'}='Documento original';
$tag{'revision'}='versión';
$tag{'included'}='incluido en el paquete';
$tag{'lines'}='Número de líneas en el documento';


# In english
#               'not-available' - 0
#               'not translated' - 1
#               'being translated' - 2
#               'needs revision' - 3
#               'translation updated', - 4
#               'needs check' - 5
#               'being revised' -  6
#               'obsolete' - 7
#               'unknown' - 8


# Turn this to '1' for debugging purposes
$debug=0;
#$debug=1;


$types = {

'Web' => {
	'name'			=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"$k.en.html" },
	'url'			=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"http://www.debian.org/$k.en.html" },
	'cvs_url'		=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"$CVSWEB/$from/$k.wml?cvsroot=webwml" },
	'source_url'		=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"$CVSWEB/$from/$k.wml?rev=$t->{'revision'}&cvsroot=webwml" },
	'translation_name'	=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"$k.$to_abr.html" },
	'translation_url'	=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"http://www.debian.org/$k.$to_abr.html" },
	'translation_cvs_url'	=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"$CVSWEB/$to/$k.wml?cvsroot=webwml" },
	'translation_source_url'=> sub {my($t, $k, $f)=@_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} :
					"$CVSWEB/$to/$k.wml?rev=$t->{'translation_revision'}&cvsroot=webwml" },
	'diff'			=> sub {my($t, $k, $f)=@_; return (!$t->{$f} || !$t->{'translation_revision'}) ? undef :
					"$CVSWEB/$from/$k.wml$t->{$f}" },
	'lines'			=> sub {my($t, $k, $f)=@_; my $file= $root."/".$from."/".$k.".wml"; my $line_string=`wc -l $file`; $line_string=~s/\Q$file\E//; return $line_string;},

},

'DDP' => {
	'url'			=> sub {my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} :
					"$DDPWEB/$k/" },
},

};

sub merge_db {
# Merges the $translation and the %translation_status database
	my $key;
	foreach $key (keys %{ $translations }) {
	        my $current;
       		print STDERR "(merge_db) Merging key $key\n" if $debug;
       		foreach $current (keys  %{ $translations_status{$key} } ) {
       			print STDERR "(merge_db) Adding information $current into $key\n" if $debug;
	       		 $translations->{$key}->{$current}=$translations_status{$key}{$current};
        	}
	}
}


sub update_db_CVS {
# Goes to the root directory and checks all the wml files CVS controlled
# in order to say if they are up to date or not

	my $filename = '\.wml$';

	print STDERR "(update_db_CVS) Checking $root/$from for Entries\n" if $debug;
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
			print STDERR "(update_db_CVS) Checking $f (original in ${to_path}$f\n" if $debug;
			if ($translations->{$k} or -e "${to_path}$f") {
			# This check should be made by revision number

				if (!$translations->{$k}->{'status'}) {
					$translations->{$k}->{'status'} = 1 ;
					$translations->{$k}->{'type'} = 'Web';
					print STDERR "(update_db_CVS) Status not known for $k (setting it to default)\n" if $debug;
				}
				$translations->{$k}->{'revision'} = $from_d->{$f};
				$translations->{$k}->{'translation_revision'} = $to_d->{$f} if ($to_d->{$f});
				$translations->{$k}->{'status'} = 4 if ($translations->{$k}->{'translation_revision'} == $translations->{$k}->{'revision'});
				check_file($k, "${to_path}$f", $from_d->{$f});
			} else {
				$translations->{$k}->{'type'} = 'Web';
				$translations->{$k}->{'status'} = 8;
				$translations->{$k}->{'revision'} = $from_d->{$f};
				print STDERR "(update_db_CVS) Warning : $k is not in the database\n" if $debug;
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
		print "(check_file) Missing $name\n" if $debug;
		return;
	}
	open(F, $name) || die $!;
	while(<F>) {
		if (/<!--\s*translation\s+(.*)?\s*-->\s*$/oi ) {
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
	$translations->{$k}->{'status'} = 5;
	$translations->{$k}->{'diff'} = "?r1=$oldr&r2=$revision&cvsroot=webwml";
}


sub update_db_format {
# Goes through the database and adds all the information
# not included there but easy to extract
	my ($k, $t);

while (($k, $t) = each %$translations) {
	
	if (uc $t->{'type'} eq 'DDP' && $k) {
		if ($t->{'status'} != 0
			&& $t->{'status'} != 1
			&& $t->{'status'} != 2) {
			$t->{'translation_url'} = 
				$TRANSWEB . $k . $to_abr.'.html/'
				if (!$t->{'translation_url'});
			$t->{'translation_cvs_url'} = 
				$TRANSWEB . $k . $to_abr. '.sgml'
				if (!$t->{'translation_cvs_url'});
		}
	}

	next unless ($k);

	foreach my $f (keys %{$types->{$t->{'type'}}}) {
		$t->{$f} = &{$types->{$t->{'type'}}->{$f}}($t, $k, $f);
	} 

	if ($k eq 'international/French') {
		my $f;

		foreach $f ('name', 'sub_name', 'revision', 'url', 'cvs_url', 'source_url', 'package') {
			my $tmp = $t->{$f};
			$t->{$f} = $t->{'translation_'.$f};
			$t->{'translation_'.$f} = $tmp;
		}
		
		$t->{'diff'} = '';
		$t->{'base_revision'} = '';
		my $file = "$root/$from/international/".ucfirst($to).".wml";
		check_file($k, $file , $t->{'revision'});
		$t->{'diff'} = "$CVSWEB/$to/$k.wml$t->{$f}".$t->{'diff'} if ($t->{'diff'});
	}
}
}

#TODO: the html should be wml and should use tags instead of 
# using the information directly

sub dump_html {

        my ($status, $type) = @_;
	my ($k, $t);

foreach $k (sort keys %$translations) {
	$t = $translations->{$k} ;

	print STDERR "(dump_html) Dumping $k, $t\n" if $debug;
	if ($debug) {
		foreach my $l (sort keys %$t) {
			print STDERR "\t$l -> $t->{$l}\n";
		}
	}

	next if ($t->{'status'} ne $status and $status != -1);
	next if ($type ne "" and uc $t->{'type'} ne uc $type);

	print "<LI>";

	$t->{'translation_name'} = $t->{'name'} . ' (original)'
		if (!$t->{'translation_name'});
	$t->{'translation_url'} = $t->{'url'}
		if (!$t->{'translation_url'});

        print "<A HREF=\"$t->{'translation_url'}\">" if $t->{'translation_url'};
        print "(No se dispone de enlace)" if !$t->{'translation_url'};

	print "<B><I>$t->{'translation_name'}</I> $t->{'translation_sub_name'}</B>";
	print "</A>" if $t->{'translation_url'};
#	print "<BLOCKQUOTE>";
	my $translation_source_name = $t->{'translation_cvs_url'};
	$translation_source_name =~ s/.*\/([^\/]+)$/$1/;
	print "<BR>$tag{'Source'} : <A HREF=\"$t->{'translation_source_url'}\">$t->{'translation_source_name'}</A>"
		if ($t->{'translation_source_url'} && uc $type ne 'DDP');
	print " (<A HREF=\"$t->{'translation_cvs_url'}\">$tag{'CVSpage'}</A>)"
		if ($t->{'translation_cvs_url'} && uc $type ne 'DDP');
	print "<BR>$tag{'devel-url'} : <A HREF=\"$t->{'translation_dev_url'}\">$t->{'translation_dev_url'}</A>"
		if ($t->{'translation_dev_url'} && uc $type ne 'DDP');
	if ($t->{'translation_maintainer'}) {
		print "<BR>$tag{'translation_maintainer'} : " ;
		my $line = '';
		my $translator;
		foreach $translator (@{$t->{'translation_maintainer'}}) {
			$translator =~ /([^\<]+)\s\<(.*)\>/;
			$line .= " <A HREF=\"mailto:$2\"><I>$1</I></A> et";
		}
		$line =~ s/et$//;
		print $line;
	}

	# If we used tags we would do this:
	#print("<BR><status> : $status[$t->{'status'}]");
	#print(" <since> $t->{'since'}") if ($t->{'since'});
	#print "<BR><translation_revision>: $t->{'translation_revision'}" if ($t->{'translation_revision'});
	#print "<BR><base_revision> : $t->{'base_revision'}" if ($t->{'base_revision'});
	#print "<BR><diff>: <A HREF=\"$t->{'diff'}\"><diff-file></A>" if ($t->{'diff'});
	#print "<BR><available> $t->{'translation_package'}" if ($t->{'translation_package'});
	#if ($t->{'translation_name'} !~ /original/) {
	#        print(STDOUT <<__EOHTML__);
	#	<BR>
       	#	 <originaldoc> : 
	#	<A HREF="$t->{'url'}">
	#	<I>$t->{'name'}</I> $t->{'sub_name'}</A>
#__EOHTML__
#	}
	#print " ( <revision> $t->{'revision'} ) " if ($t->{'revision'});
	#print " ( <included> $t->{'package'} ) " if ($t->{'package'});
	#print " ( <A HREF=\"$t->{'source_url'}\"><source></A> ) " if ($t->{'source_url'} && $t->{'source_url'} ne '?' && uc $type ne "DDP");
	#print " ( <A HREF=\"$t->{'cvs_url'}\"><CVSpage'></A> ) " if ($t->{'cvs_url'} && $t->{'cvs_url'} ne '?' && uc $type ne "DDP");
	# Since we cannot use tags (perl pass is after tag change)
	# we use a hash array (%tag) for the text
	
	print("<BR>$tag{'status'} : $status[$t->{'status'}]");
	print(" $tag{'since'} $t->{'since'}") if ($t->{'since'});
	print "<BR>$tag{'translation_revision'}: $t->{'translation_revision'}" if ($t->{'translation_revision'});
	print "<BR>$tag{'base_revision'} : $t->{'base_revision'}" if ($t->{'base_revision'});
	print "<BR>$tag{'diff'}: <A HREF=\"$t->{'diff'}\">$tag{'diff'}</A>" if ($t->{'diff'});
	print "<BR>$tag{'available'} <A HREF=\"http://packages.debian.org/$t->{'translation_package'}\">$t->{'translation_package'}</A>" if ($t->{'translation_package'});
	if ($t->{'translation_name'} !~ /original/) {
	print "<BR>$tag{'originaldoc'} : <A HREF=\"$t->{'url'}\"> <I>$t->{'name'}</I> $t->{'sub_name'}</A>";
	}

	print " ( $tag{'revision'} $t->{'revision'} ) " if ($t->{'revision'});
	print " ( $tag{'included'} <A HREF=\"http://packages.debian.org/$t->{'package'}\">$t->{'package'}</A> ) " if ($t->{'package'});
	print " ( <A HREF=\"$t->{'source_url'}\">$tag{'Source'}</A> ) " if ($t->{'source_url'} && $t->{'source_url'} ne '?'); # Why this? && uc $type ne "DDP");
	print " ( <A HREF=\"$t->{'cvs_url'}\">$tag{'CVSpage'}</A> ) " if ($t->{'cvs_url'} && $t->{'cvs_url'} ne '?'); # Why this?  && uc $type ne "DDP");
	print "<BR>$tag{'lines'} : $t->{'lines'} " if ($t->{'lines'});

#	print "</BLOCKQUOTE>"
	print "<P>&nbsp;\n";
} # of the foreach

}

merge_db();


# This is for debugging purposes
# Turn this on to be able to run this program standalone
#update_db_CVS();
#update_db_format();
#dump_html(-1,"web");
