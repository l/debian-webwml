#!/usr/bin/perl
#  Copyright 2000 Javier Fernández-Sanguino Peña <jfs@computer.org>
#  Copyright 1998-2000 Christophe Le Bars <clebars@debian.org>
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
no strict "refs";

use vars qw(
	$CVSWEB $TRANSWEB
	$translations
	$types $root $from $to $from_abr $to_abr
	@status %tag $debug
	);

# Read config file
do 'ltcp.conf';

# $t : current document record
# $k : current document key
# $f : current document field

$types = {
        'Web' => {
                'name'          => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$k.en.html" },
                'url'           => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "http://www.debian.org/$k.en.html" },
                'cvs_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml" },
                'source_url'    => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/webwml/$from/$k.wml?cvsroot=webwml&rev=$t->{'revision'}" },
                'translation_name'      => sub {
my($t, $k, $f) = @_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} : "$k.$to_abr.html" },
                'translation_url'       => sub {
my($t, $k, $f) = @_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} : "http://www.debian.org/$k.$to_abr.html" },
                'translation_cvs_url'   => sub {
my($t, $k, $f) = @_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} : "$CVSWEB/webwml/$to/$k.wml?cvsroot=webwml" },
                'translation_source_url'=> sub {
my($t, $k, $f) = @_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} : "$CVSWEB/webwml/$to/$k.wml?cvsroot=webwml&rev=$t->{'translation_revision'}" },
                'translation_source_name'=> sub {
my($t, $k, $f) = @_; return ($t->{$f} || !$t->{'translation_revision'}) ? $t->{$f} : "$k.wml" },
                'diff'          => sub {
my($t, $k, $f) = @_; return (!$t->{$f} || !$t->{'translation_revision'}) ? undef : "$CVSWEB/webwml/$from/$k.wml$t->{$f}" },
                'lines'         => sub {
my($t, $k, $f) = @_; my $file = $root."/".$from."/".$k.".wml"; my $line_string=`wc -l $file`; $line_string=~s/\Q$file\E//; return $line_string;},
},

        'DDP' => {
                'url'           => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "http://www.debian.org/doc/manuals/$k/" },
                'cvs_url'       => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/ddp/manuals.sgml/$k/?cvsroot=debian-doc" },
                'source_url'    => sub {
my($t, $k, $f) = @_; return $t->{$f} ? $t->{$f} : "$CVSWEB/ddp/manuals.sgml/$k/$k.sgml?cvsroot=debian-doc" },
                'translation_url'       => sub {
my($t, $k, $f) = @_; return ($t->{$f} || $t->{'status'} == 0 || $t->{'status'} == 1 || $t->{'status'} == 2 || $t->{'status'} == 8) ? $t->{$f} : "#" },
                'translation_source_name'       => sub {
my($t, $k, $f)=@_; return $t->{$f} ? $t->{$f} : "$k.fr.sgml" },
                'translation_source_url'        => sub {
my($t, $k, $f)=@_; return ($t->{$f} || $t->{'status'} == 0 || $t->{'status'} == 1 || $t->{'status'} == 2 || $t->{'status'} == 8) ? $t->{$f} : "$CVSWEB/ddp/manuals.sgml/$k/$k.fr.sgml?cvsroot=debian-doc" },
        },
};


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
			print STDERR "(update_db_CVS) Checking $k\n" if $debug;
			if ($translations->{$k} or -e "${to_path}$f") {
				if (!defined($translations->{$k}->{'type'})) {
					$translations->{$k}->{'type'} = 'Web';
					print STDERR "(update_db_CVS) Type not known (setting it to default)\n" if $debug;
				}
				if (!defined($translations->{$k}->{'status'})) {
					$translations->{$k}->{'status'} = 8 ;
					print STDERR "(update_db_CVS) Status not known (setting it to default)\n" if $debug;
				}
				$translations->{$k}->{'revision'} = $from_d->{$f};
				print STDERR "(update_db_CVS) set original version to $from_d->{$f}\n" if $debug;
				$translations->{$k}->{'translation_revision'} = $to_d->{$f} if ($to_d->{$f});
				print STDERR "(update_db_CVS) set translation version to $to_d->{$f}\n" if ($debug && $to_d->{$f});
				check_file($k, "${to_path}$f", $from_d->{$f});
			} else {
				$translations->{$k}->{'type'} = 'Web';
				$translations->{$k}->{'status'} = 1;
				$translations->{$k}->{'revision'} = $from_d->{$f};
				print STDERR "(update_db_CVS) Warning : not in the database\n" if $debug;
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
		print STDERR "(check_file) Missing $name\n" if $debug;
		return;
	}
	open(F, $name) || die $!;
	while(<F>) {
		if (/\s+translation_maintainer=\"(.*)?\"\s+/oi) {
			$translations->{$k}->{'translation_maintainer'} = [ $1 ];
			print STDERR "(check_file) found translation_maintainer $1 in WML vars\n" if $debug;
		}
		if (/<!--\s*translation\s+(.*)?\s*-->\s*$/oi || /\s+translation=\"([\d\.]+)?\"\s+/oi) {
			$oldr = $1;
			$translations->{$k}->{'base_revision'} = $oldr;
			print STDERR "(check_file) found base_revision $oldr in WML vars\n" if $debug;
			if ($oldr eq $revision) {
				close(F);
				$translations->{$k}->{'status'} = 4 if ($translations->{$k}->{'status'} == 8);
				print STDERR "(check_file) set status to 4\n" if ($debug && $translations->{$k}->{'status'} == 8);
				close(F);
				return;
			}
			last;
		}
	}
	close(F);
	$translations->{$k}->{'status'} = 5 if ($translations->{$k}->{'status'} == 8);
	print STDERR "(check_file) set status to 5\n" if ($debug && $translations->{$k}->{'status'} == 8);
	$translations->{$k}->{'diff'} = "?cvsroot=webwml&r1=$oldr&r2=$revision";
	print STDERR "(check_file) set diff args\n" if $debug;
}


sub update_db_format {
# Goes through the database and adds all the information
# not included there but easy to extract
	my ($k, $t);

	while (($k, $t) = each %$translations) {
	
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
 	print "<B><I>$t->{'translation_name'}</I> $t->{'translation_sub_name'}</B>";
	print "$tag{'no url'}" if !$t->{'translation_url'};
	print "</A>" if $t->{'translation_url'};
#	print "<BLOCKQUOTE>";
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
	print "<BR><A HREF=\"$t->{'diff'}\">$tag{'diff'}</A>" if ($t->{'diff'});
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

# This is for debugging purposes
# Turn this on to be able to run this program standalone
#do 'doccurrent_status.pl';
#update_db_CVS();
#update_db_format();
#dump_html(3);
