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
    $body =~ s/&/&amp;/g;
    $body =~ s/</&lt;/g;
    $body =~ s/>/&gt;/g;

    $rss->add_item (title       => $headline,
		    description => $body,
		    link        => $url.'#'.$count,
		    );
}

my $rss = new XML::RSS (version => '1.0', encoding => charset);

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
if (open (F, $current . '/index.wml')) {
    while (<F>) {
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
		&& $headline ne "Mises à jour de sécurité"		# French
		&& $headline ne "¡i¦w¥þ§ó·s¡j"				# Chinese
		&& $headline ne "Aggiornamenti per la sicurezza"	# Italian
		&& $headline ne "Atualizaçoes de Segurança"		# Portuguese
		&& $headline ne "Aktualisierungen zur Systemsicherheit"	# German
		&& $headline ne "ã‚»ã‚­ãƒ¥ãƒªãƒ†ã‚£ä¸Šã®æ›´æ–°ã€‚"		# Japanese in UTF-8
		) {

		if (!$headline) {
		    rdf_add ($rss, $count++, 'Debian Weekly News '.$current, $body) if ($count == 0);
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
