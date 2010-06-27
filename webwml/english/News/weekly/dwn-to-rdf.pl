#! /usr/bin/perl

# dwn-to-rdf - Convert the current DWN issue into an RDF file
# Copyright (c) 2006  Martin Schulze <joey@infodrom.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

# Caveat: In order to filter out security updates language maintainers
#         need to add a condition at $headline ne "..." below.

use strict;
use warnings;

use XML::RSS;
use Encode qw(decode_utf8);

if (!exists ($ENV{ENGLISHSRCDIR}) ||
    !exists ($ENV{CUR_DIR}) ||
    !exists ($ENV{LANGUAGE})) {
    printf "One of ENGLISHSRCDIR, CUR_DIR or LANGUAGE not exported.\n";
    exit (1);
}

#
# Extract the charset from $LANGUAGEDIR/.wmlrc
#
sub charset
{
    my $charset = 'iso-8859-1 xxx';

    if (open (F, "../../.wmlrc")) {
	while (<F>) {
	    $charset = $1 if (/^-D CHARSET=(.*)$/);
	    $charset = $1 if (/^-D CHARSET_WML=(.*)$/); # proper charset if exists
	}
	close (F);
    }
    return $charset;
}

#
# Extract the current issue
#
sub current_issue
{
    if (open (F, $ENV{ENGLISHSRCDIR}.'/'.$ENV{CUR_DIR}.'/CURRENT-ISSUE-IS')) {
	chomp ($_ = <F>);
	close (F);
    }
    return $_;
}

#
# Extract the release date
#
sub pubdate
{
    my $issue = shift;
    my $pubdate;

    if (open (F, $ENV{ENGLISHSRCDIR}.'/'.$ENV{CUR_DIR}.'/'.$issue.'/index.wml')) {
	while (!$pubdate && ($_ = <F>)) {
	    if (/PUBDATE="([^\"]*)"/) {
		$pubdate = $1;
	    }
	}	
	close (F);
    }
    $pubdate = "1970-01-01" if ($pubdate !~ /\d{4}-\d{2}-\d{2}/);
    return $pubdate;
}

my $current = current_issue;
my $pubdate = pubdate ($current) . "T00:00:00Z";
my $rdf = 'dwn.' . $ENV{LANGUAGE} . '.rdf';
my $url = 'http://www.debian.org/News/project/' . $current . '/index.' . $ENV{LANGUAGE} . '.html';

sub rdf_add
{
    my $rss = shift;
    my $count = shift;
    my $headline = shift;
    my $body = shift;

    $body =~ s~\$\(HOME\)~http://www.debian.org~g;
    $body =~ s/\\\n//g;

    # Conversion for the content
    if ($ENV{LANGUAGE} eq 'fr') {
      $headline =~ s/<q>/��/g;
      $headline =~ s/<\/q>/��/g;
      $body =~ s/<q>/��/g;
      $body =~ s/<\/q>/��/g;
    } elsif ($ENV{LANGUAGE} eq 'it') {
      $headline =~ s/<q>/�/g;
      $headline =~ s/<\/q>/�/g;
      $body =~ s/<q>/�/g;
      $body =~ s/<\/q>/�/g;
    } elsif ($ENV{LANGUAGE} eq 'de') {
      $headline =~ s/<q>/�/g;
      $headline =~ s/<\/q>/�/g;
      $body =~ s/<q>/�/g;
      $body =~ s/<\/q>/�/g;
    } else {
      $headline =~ s/<q>/"/g;
      $headline =~ s/<\/q>/"/g;
      $body =~ s/<q>/"/g;
      $body =~ s/<\/q>/"/g;
    }
    $body =~ s/&/&amp;/g;
    $body =~ s/</&lt;/g;
    $body =~ s/>/&gt;/g;

    $rss->add_item (title       => $headline,
		    description => $body,
		    link        => $url.'#'.$count,
		    );
}

my $rss = new XML::RSS (version => '1.0', encoding => charset, encode_output => 0);

$rss->channel (title          => 'Debian Project News',
	       description    => 'Debian Project News '. $current,
	       link           => $url,
	       dc             => {
		   date => $pubdate,
	       },
    );

my $count = 0;
my $headline = '';
my $body = '';
my $charset = charset;

if (open (F, $current . '/index.wml')) {
    while (<F>) {
	# prevent double utf-8 encode by XML::RSS 
	$_ = decode_utf8($_) if ($charset eq 'utf-8') ;
	if (/^<p><strong>(.*)<\/strong>(?:<br \/>)?\s*(.*)/) {
	    $headline = $1;
	    $body = $2."\n";
	    chop ($headline) if ($headline =~ /\.$/);
	} elsif (/^<p><strong>(.*)/) {
	    $headline = $1;
        } elsif (/^(.*)<\/strong>(?:<br \/>)?(.*)/) {
            $headline .= ' '.$1;
            $body = $2."\n";
            chop ($headline) if ($headline =~ /\.$/);
	} elsif (/^<h2>(.*)<\/h2>(?:<br \/>)?\s*(.*)/) {
            $headline = $1;
            $body = $2."\n";
            chop ($headline) if ($headline =~ /\.$/);
        } elsif (/^<p>(.*)/) {
            $body = $1."\n";
	} elsif (/(.*)<\/p>/) {
	    $body .= $1;

	    if ($body !~ /(newpkg_main|removals.txt|<code>wnpp-alert<\/code>|href="mailto:dwn\@debian.org")/
		&& $headline ne "Security Updates"			# English
		&& $headline ne "Mises � jour de s�curit�"		# French
		&& $headline ne "�i�w����s�j"				# Chinese
		&& $headline ne "Aggiornamenti per la sicurezza"	# Italian
		&& $headline ne "Atualiza�oes de Seguran�a"		# Portuguese
		&& $headline ne "Aktualisierungen zur Systemsicherheit"	# German
		&& $headline ne "セキュリティ上の更新。"		# Japanese in UTF-8
		) {

		if (!$headline) {
		    rdf_add ($rss, $count++, 'Debian Project News '.$current, $body) if ($count == 0);
		} else {
		    rdf_add ($rss, $count++, $headline, $body);
		}
	    }

	    $headline = $body = '';
	} elsif (length) {
	    $body .= $_;
	}
    }
    close (F);
}
# fill file

$rss->save ($rdf);
