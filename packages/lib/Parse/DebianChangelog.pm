#
# Parse::DebianChangelog
# $Id$
#
# Copyright 2005 Frank Lichtenheld <frank@lichtenheld.de>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

=head1 NAME

Parse::DebianChangelog - parse Debian changelogs and output them in other formats

=head1 SYNOPSIS

    use Parse::DebianChangelog;

    my $chglog = Parse::DebianChangelog->init( { infile => 'debian/changelog',
                                                 HTML => { outfile => 'changelog.html' } );
    $chglog->html_out;

    # the following is semantically equivalent
    my $chglog = Parse::DebianChangelog->init();
    $chglog->parse( { infile => 'debian/changelog' } );
    $chglog->html_out( { config => 'changelog.html' } );


=head1 DESCRIPTION

=cut

package Parse::DebianChangelog;

use strict;
use warnings;

use Fcntl qw( :flock );
use English;
use CGI qw( -no_xhtml -no_debug );
use HTML::Entities;
use URI::Escape;
use Date::Parse;

our $CLASSNAME = 'Parse::DebianChangelog';
our $VERSION = 0.1;
our $RCS_VERSION = '$Revision$';

sub init {
    my $classname = shift;
    my $config = shift || {};
    my $self = {};
    $CLASSNAME = $classname;
    bless( $self, $classname );

    $config->{verbose} = 1 if $config->{debug};
    $self->{config} = $config;

    if ($self->{config}{infile}) {
	$self->parse;
    }

    return $self;
}

sub parse {
    my ($self, $config) = @_;

    foreach my $c (keys %$config) {
	$self->{config}{$c} = $config->{$c};
    }
    my $file = $self->{config}{infile} or return undef;

    open my $fh, '<', $file or return undef;
    flock $fh, LOCK_SH or return undef;

    $self->{data} = [];

# based on /usr/lib/dpkg/parsechangelog/debian
    my $expect='first heading';
    my %entry = ();
    my $blanklines = 0;

    while (<$fh>) {
	s/\s*\n$//;
#	printf(STDERR "%-39.39s %-39.39s\n",$expect,$_);
	if (m/^(\w[-+0-9a-z.]*) \(([^\(\) \t]+)\)((\s+[-0-9a-z]+)+)\;/i) {
	    if ($expect eq 'first heading'
		|| $expect eq 'next heading or eof') {
		if (%entry) {
		    my @closes;
		    while ($entry{'Changes'} =~ /closes:\s*(?:bug)?\#?\s?\d+(?:,\s*(?:bug)?\#?\s?\d+)*/ig) {
			push(@closes, $& =~ /\#?\s?(\d+)/g);
		    }
		    $entry{'Closes'} = [ sort { $a <=> $b } @closes ];

#		    print STDERR, Dumper(%entry);
		    push @{$self->{data}}, { %entry };
		    %entry = ();
		}
		$entry{'Source'} = $1;
		$entry{'Version'} = $2;
		($entry{'Distribution'} = $3) =~ s/^\s+//;
	    } else {
		warn("$file: found start of entry where expected $expect");
	    }
	    (my $rhs = $POSTMATCH) =~ s/^\s+//;
	    my %kvdone;
	    for my $kv (split(/\s*,\s*/,$rhs)) {
		$kv =~ m/^([-0-9a-z]+)\=\s*(.*\S)$/i ||
		    warn("$file: bad key-value after \`;': \`$kv'");
		my $k = ucfirst $1;
		my $v = $2;
		$kvdone{$k}++ && warn("$file: repeated key-value $k");
		if ($k eq 'Urgency') {
		    $v =~ m/^([-0-9a-z]+)((\s+.*)?)$/i ||
			warn("$file: badly formatted urgency value, at changelog ");
		    $entry{'Urgency'} = lc($1).$2;
		} else {
		    $entry{$k} = $v;
		}
	    }
	    $expect= 'start of change data';
	    $blanklines = 0;
	} elsif (m/^\S/) {
	    warn("$file: badly formatted heading line");
	} elsif (m/^ \-\- (.*) <(.*)>  ((\w+\,\s*)?\d{1,2}\s+\w+\s+\d{4}\s+\d{1,2}:\d\d:\d\d\s+[-+]\d{4}(\s+\([^\\\(\)]\))?)$/) {
	    $expect eq 'more change data or trailer' ||
		warn("$file: found trailer where expected $expect");
	    $entry{'Maintainer'} = "$1 <$2>" unless defined($entry{'Maintainer'});
	    $entry{'Date'} = $3 unless defined($entry{'Date'});
	    $entry{'Parsed_Date'} = str2time($3) or warn "$file: couldn't parse date $3";
	    $expect = 'next heading or eof';
	} elsif (m/^ \-\-/) {
	    warn("$file: badly formatted trailer line");
	} elsif (m/^\s{2,}(\S)/) {
	    $expect eq 'start of change data'
		|| $expect eq 'more change data or trailer'
		|| warn("$file: found change data where expected $expect");
	    $entry{'Changes'} .= (" \n" x $blanklines)." $_\n";
	    if (!$entry{'Items'} || ($1 eq '*')) {
		$entry{'Items'} ||= [];
		push @{$entry{'Items'}}, "$_\n";
	    } else {
		$entry{'Items'}[-1] .= (" \n" x $blanklines)." $_\n";
	    }
	    $blanklines = 0;
	    $expect = 'more change data or trailer';
	} elsif (!m/\S/) {
	    next if $expect eq 'start of change data'
		|| $expect eq 'next heading or eof';
	    $expect eq 'more change data or trailer'
		|| warn("$file: found blank line where expected $expect");
	    $blanklines++;
	} else {
	    warn("$file: unrecognised line");
	}
    }

    if (%entry) {
	my @closes;
	while ($entry{'Changes'} =~ /closes:\s*(?:bug)?\#?\s?\d+(?:,\s*(?:bug)?\#?\s?\d+)*/ig) {
	    push(@closes, $& =~ /\#?\s?(\d+)/g);
	}
	$entry{'Closes'} = join(' ', sort { $a <=> $b } @closes);
	
	push @{$self->{data}}, \%entry;
    }
    
    $expect eq 'next heading or eof'
	|| warn "$file: found eof where expected $expect";
    close $fh or return undef;

#    use Data::Dumper;
#    print Dumper( $self );

    return $self;
}

sub html_out {
    my ($self, $config) = @_;
    
    $self->{config}{HTML} = $config if $config;
    $config = $self->{config}{HTML} || {};
    my $data = $self->{data} or return undef;

    my $outfile = $config->{outfile} or return undef;
    my $cgi = new CGI

    open my $fh, '>', $outfile or return undef;
    flock $fh, LOCK_EX or return undef;

    print $fh $cgi->start_html( -title => $config->{title}
				|| "Debian Changelog $data->[0]{Source} ($data->[0]{Version})",
				-author => $config->{author}
				|| $data->[0]{Maintainer},
				-meta=>{ keywords => $config->{keywords}
					 || "Debian Changelog $data->[0]{Source} $data->[0]{Version}",
					 generator => "$CLASSNAME (v$VERSION)" },
				-head=>[ $cgi->meta({ -http_equiv => 'Content-Type',
						      -content => 'text/html; charset=UTF-8' }),
					 $cgi->Link({-rel=>'stylesheet',
						     -href => $config->{style}
						     || 'changelogs.css',
						     -type => 'text/css',
						     -media => 'screen' }),
					 $cgi->Link({-rel=>'stylesheet',
						     -href => $config->{print_style}
						     || 'changelogs-print.css',
						     -type => 'text/css',
						     -media => 'print' }),
					 ],
				);

    print $fh $cgi->p({ -class=>'hide' },
		      $cgi->a({ -href=>'#content' },
			      'Skip to content' ));

    print $fh $cgi->ul( { -class=>'navbar' },
			$cgi->li( [
				   $cgi->a({ -href=>"http://packages.debian.org/src:$data->[0]{Source}" }, 'Package Information' ),
				   $cgi->a({ -href=>"http://packages.qa.debian.org/$data->[0]{Source}" }, 'Package Developer Information' ),
				   $cgi->a({ -href=>"http://bugs.debian.org/src:$data->[0]{Source}" }, 'Bug Information' ),
				   ] ) );

    print $fh $cgi->h1( { -class=>"document_header" },
			$config->{title}
			|| "Debian Changelog $data->[0]{Source} ($data->[0]{Version})" );

    my %navigation;
    foreach my $entry (@$data) {
	my $year = (gmtime($entry->{Parsed_Date}))[5] + 1900;
	
	$navigation{$year} ||= [];
	push @{$navigation{$year}}, $cgi->a({-href=>"#version$entry->{Version}",
					     -title=>"$entry->{Maintainer} $entry->{Date}"},
					    $entry->{Version});
    }
    print $fh $cgi->start_ul( { -class=>'outline' } );
    foreach my $y (reverse sort keys %navigation) {
	print $fh $cgi->li(
	    $cgi->a({ -href=>"#year$y" },$y).": ".
	    $cgi->ul( $cgi->li( $navigation{$y} ) ) );
    }
    print $fh $cgi->end_ul;
	
    my $last_year;
    print $fh $cgi->start_div({ -id=>'content'});
    foreach my $entry (@$data) {
	my $year = (gmtime($entry->{Parsed_Date}))[5] + 1900;
	
	if (!$last_year || ($year < $last_year)) {
	    print $fh $cgi->h2( { -class=>'year_header',
				  -id=>"year$year" }, $year );
	    $last_year = $year;
	}

	my $pkg = $cgi->a({ -href=>"http://packages.debian.org/src:".
				uri_escape($entry->{Source}),
			    -class=>'packagelink' }, 
			  $entry->{Source} );

	print $fh $cgi->h3( { -class=>'entry_header',
			      -id=>"version$entry->{Version}" },
			    "$pkg ($entry->{Version}) ".
			    $cgi->span( { -class=>$entry->{Distribution} },
					$entry->{Distribution} ).
			    "; urgency=".
			    $cgi->span( { -class=>$entry->{Urgency} },
					$entry->{Urgency} ) );
	
	my $text = encode_entities( $entry->{Changes} );
	$text=~ s|&lt;URL:([-\w\.\/:~_\@]+):([a-zA-Z0-9\'() ]+)&gt;
	         |$cgi->a({ -href=>$1 }, $2)
		 |xego;
	$text=~ s|https?:[\w/\.:\@+\-~\%\#?=&;,]+[\w/]
	         |$cgi->a({ -href=>$& }, $&)
		 |xego;
	$text=~ s|ftp:[\w/\.:\@+\-~\%\#?=&;,]+[\w/]
	         |$cgi->a({ -href=>$& }, $&)
		 |xego;
	$text=~ s|[a-zA-Z0-9_\+\-\.]+\@([a-zA-Z0-9][\w\.+\-]+\.[a-zA-Z]{2,})
	         |$cgi->a({ -href=>"http://qa.debian.org/developer.php?login=$&" }, $&)
		 |xego;
	$text=~ s|Closes:\s*(?:Bug)?\#\d+(?:\s*,\s*(?:Bug)?\#\d+)*
	         |my $tmp = $&; { no warnings;
		  $tmp =~ s@(Bug)?\#(\d+)@<a class="buglink" href="http://bugs.debian.org/$2">$1\#$2</a>@ig; }
	          "$tmp"
		 |xiego;
	$text=~ s|\B\*([a-z][a-z -]*[a-z])\*\B
	         |$cgi->em($1)
		 |xiego;
	$text=~ s|\B\*([a-z])\*\B
	         |$cgi->em($1)
		 |xiego;
	$text=~ s|\B\#([a-z][a-z -]*[a-z])\#\B
	         |$cgi->strong($1)
		 |xego;
	$text=~ s|\B\#([a-z])\#\B
	         |$cgi->strong($1)
		 |xego;
	$text=~ s|/usr/share/common-licenses/GPL(?:-2)?
	         |$cgi->a({ -href=>"http://www.gnu.org/copyleft/gpl.html" }, $&)
		 |xego;
	$text=~ s|/usr/share/common-licenses/LGPL(?:-2(?:\.1)?)?
	         |$cgi->a({ -href=>"http://www.gnu.org/copyleft/lgpl.html" }, $&)
		 |xego;
	$text=~ s|/usr/share/common-licenses/Artistic
	         |$cgi->a({ -href=>"http://www.opensource.org/licenses/artistic-license.php" }, $&)
		 |xego;
	$text=~ s|/usr/share/common-licenses/BSD
	         |$cgi->a({ -href=>"http://www.debian.org/misc/bsd.license" }, $&)
		 |xego;

	print $fh $cgi->pre($text);

	my $maint = encode_entities( $entry->{Maintainer} );
	$maint =~ s|[a-zA-Z0-9_\+\-\.]+\@([a-zA-Z0-9][\w\.+\-]+\.[a-zA-Z]{2,})
	           |$cgi->a({ -href=>"http://qa.debian.org/developer.php?login=$&" }, $&)
		   |xego;

	print $fh $cgi->p( { -class=>'trailer' }, "  -- $maint $entry->{Date}" );


    }
    print $fh $cgi->end_div; # content
    
    print $fh $cgi->div({-class=>'footer'},
			$cgi->hr({-class=>'hide'}).
			$cgi->address(
				      'Generated '.
				      gmtime().
				      ' UTC by '.
				      $cgi->tt("$CLASSNAME (v$VERSION)").
				      $cgi->br().
				      'Contact '.
				      $cgi->a({ -href=>'mailto:debian-www@lists.debian.org' },
					      'debian-www@lists.debian.org' ).
				      ' in case of problems.'
				      ) );

    print $fh $cgi->end_html;
    close $fh or return undef;

    return $self;
}
