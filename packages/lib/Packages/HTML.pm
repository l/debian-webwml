package Packages::HTML;

use strict;
use warnings;

use Locale::gettext;

use Packages::I18N::Locale;
use Packages::I18N::Languages;
use Packages::I18N::LanguageNames;

our @ISA = qw( Exporter );
our @EXPORT = qw( header trailer file_changed time_stamp
		  read_md5_hash write_md5_hash );

our $HOME = "http://www.debian.org";
our $CN_HELP_URL = "${HOME}/intro/cn";

my %img_trans = ( pt_BR => "pt", pt_PT => "pt", sv_SE => "sv" );

sub img {
    my ( $root, $url, $src, $alt, %attr ) = @_; 
    my @attr;

    foreach my $a ( keys %attr ) {
	push @attr, "$a=\"$attr{$a}\"";
    }

    return "<a href=\"$root$url\"><img src=\"$root$src\" border=\"0\" alt=\"$alt\" @attr></a>";
}

sub header {
    my (%params) = @_;

    my $DESC_LINE;
    if (defined $params{desc}) {
	$DESC_LINE = "<meta name=\"Description\" content=\"$params{desc}\">";
    }
    else {
	$DESC_LINE = '';
    }

    my $title_keywords = $params{title_keywords} || $params{title} || '';
    my $title_tag = $params{title_tag} || $params{title} || '';
    my $title_in_header = $params{page_title} || $params{title} || '';
    my $page_title = $params{page_title} || $params{title} || '';

    if ($params{print_title_above}) {
 	$title_in_header = "<h1 align=\"center\">$title_in_header</h1>";
    } else {
 	$title_in_header = '';
    }

    my $search_in_header = '';
    $params{print_search_field} ||= "";
    if ($params{print_search_field} eq 'packages') {
	my %values = %{$params{search_field_values}};
	my %checked_searchon = ( names => "",
				 all => "",
				 sourcenames => "", );
	$checked_searchon{$values{searchon}} = "checked=\"checked\"";
	$search_in_header = <<MENU;
<div id="hpacketsearch">
<form method="GET" action="http://packages.debian.org/cgi-bin/search_packages.pl">
<input type="hidden" name="version" value="$values{version}" />
<input type="hidden" name="subword" value="$values{subword}" />
<input type="hidden" name="exact" value="$values{exact}" />
<input type="hidden" name="arch" value="$values{arch}" />
<input type="hidden" name="releases" value="$values{releases}" />
<input type="hidden" name="case" value="$values{case}" />
<input type="text" size="30" name="keywords" value="$values{keywords}" id="kw" />
<input type="submit" value="Search">
<span style="font-size: 60%"><a href="http://packages.debian.org/#search_packages">Full options</a></span>
<br>
<div style="font-size: 80%">Search on:
<input type="radio" name="searchon" value="names" id="onlynames" $checked_searchon{names}>
<label for="onlynames">Package names only</label>&nbsp;&nbsp;
<input type="radio" name="searchon" value="all" id="descs" $checked_searchon{all}>
<label for="descs">Descriptions</label>
<br>
<input type="radio" name="searchon" value="sourcenames" id="src" $checked_searchon{sourcenames}>
<label for="src">Source package names</label>
</div>
</form>
</div> <!-- end hpacketsearch -->
MENU
;
    } elsif ($params{print_search_field} eq 'contents') {
	my %values = %{$params{search_field_values}};
	my %checked_searchmode = ( searchfiles => "",
				   searchfilesanddirs => "",
				   searchword => "",
				   filelist => "", );
	$checked_searchmode{$values{searchmode}} = "checked=\"checked\"";
	$search_in_header = <<MENU;
<div id="hpacketsearch">
<form method="GET" action="http://packages.debian.org/cgi-bin/search_contents.pl">
<input type="hidden" name="version" value="$values{version}" />
<input type="hidden" name="arch" value="$values{arch}" />
<input type="hidden" name="case" value="$values{case}" />
<input type="text" size="30" name="word" id="keyword" value="$values{keyword}">&nbsp;
<input type="submit" value="Search">
<span style="font-size: 60%"><a href="http://packages.debian.org/#search_contents">Full options</a></span>
<br>
<div style="font-size: 80%">Display:
<input type=radio name="searchmode" value="searchfiles" id="searchfiles" $checked_searchmode{searchfiles}>
<label for="searchfiles">files</label>
<input type=radio name="searchmode" value="searchfilesanddirs" id="searchfilesanddirs" $checked_searchmode{searchfilesanddirs}>
<label for="searchfilesanddirs">files &amp; directories</label>
<br>
<input type=radio name="searchmode" value="searchword" id="searchword" $checked_searchmode{searchword}>
<label for="searchword">subword matching</label>
<input type=radio name="searchmode" value="filelist" id="filelist" $checked_searchmode{filelist}>
<label for="filelist">content list</label>
</div>
</form>
</div> <!-- end hpacketsearch -->
MENU
;
    }

    my $keywords = $params{keywords} || '';
    my $KEYWORDS_LINE = "<meta name=\"Keywords\" content=\"debian, $keywords $title_keywords\">";
    
    my $LANG = $params{lang};
    my $img_lang = $img_trans{$LANG} || $LANG;
    my $charset = get_charset($LANG);
    my $txt = <<HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="$LANG">
<head>
<title>Debian -- $title_tag</title>
<link rev="made" href="mailto:webmaster\@debian.org">
<meta http-equiv="Content-Type" content="text/html; charset=$charset">
<meta name="Author" content="Debian Webmaster, webmaster\@debian.org">
$KEYWORDS_LINE
$DESC_LINE
<link href="$HOME/debian.css" rel="stylesheet" type="text/css">
</head>
<body>
<div id="header">
   <div id="upperheader">
   <div id="logo">
  <a href="$HOME/"><img src="$HOME/logos/openlogo-nd-50.png" alt="" /></a>
HEAD
;

    $txt .= img( "$HOME/", "", "Pics/debian.png", gettext( "Debian Project" ),
		 width => 179, height => 61 );
    $txt .= <<HEADEND;

</div> <!-- end logo -->
HEADEND
;

    $txt .= <<NAVBEGIN;
$search_in_header
</div> <!-- end upperheader -->
<div id="navbar">
<p class="navpara">
NAVBEGIN
;
# $title_in_header

$txt .= " " . img( "$HOME/", "intro/about", "Pics/about.$img_lang.gif",
		 gettext( "About&nbsp;Debian" ), 
		 ) . "\n ";
    $txt .= img( "$HOME/", "News/", "Pics/news.$img_lang.gif",
		 gettext( "News" ), 
		 ) . "\n ";
    $txt .= img( "$HOME/", "distrib/", "Pics/getting.$img_lang.gif",
		 gettext( "Getting&nbsp;Debian" ), 
		 ) . "\n ";
    $txt .= img( "$HOME/", "support", "Pics/support.$img_lang.gif",
		 gettext( "Support" ), 
		 ) . "\n ";
    $txt .= img( "$HOME/", "devel/", "Pics/devel.$img_lang.gif",
		 gettext( "Development" ), 
		 ) . "\n ";
    $txt .= img( "$HOME/", "sitemap", "Pics/sitemap.$img_lang.gif",
		 gettext( "Site map" ), 
		 ) . "\n ";
    $txt .= img( "", "http://search.debian.org/", 
		 "$HOME/Pics/search.$img_lang.gif",
		 gettext( "Search" ), 
		 ) . "\n";
    
    $txt .= <<ENDNAV;
</p>
</div> <!-- end navbar -->
</div> <!-- end header -->
ENDNAV
;
    $txt .= <<BEGINCONTENT;
<div id="outer">
<div id="inner">

BEGINCONTENT
;
    if ($params{print_title_above}) {
	$txt .= "<h1 align=\"center\">$page_title</h1>\n";
    }
    if ($params{print_title_below}) {
	$txt .= "<h1 align=\"center\">$page_title</h1>\n";
    }

    return $txt;
}

sub trailer {
    my ($ROOT, $NAME, $LANG, @USED_LANGS) = @_;
    my $txt = "</div> <!-- end inner -->\n<div id=\"footer\">\n";
    $txt .= languages( $NAME, $LANG, @USED_LANGS );
    $txt .=
	"\n\n<hr class=\"hidecss\">" .
	sprintf( gettext( "Back to: <a href=\"%s/\">Debian Project homepage</a> || <a href=\"%s/\">Packages search page</a>" ), $HOME, $ROOT ).
	"\n<hr noshade width=\"100%\" size=\"1\">\n".
	"<p><small>".
	sprintf( gettext( "To report a problem with the web site, e-mail <a href=\"mailto:debian-www\@lists.debian.org\">debian-www\@lists.debian.org</a>. For other contact information, see the Debian <a href=\"%s/contact\">contact page</a>." ), $HOME).
	"</small></p>\n".
	"<p><small>". gettext( "Last Modified: " ). "LAST_MODIFIED_DATE".
	"<br>\n".
	sprintf( gettext( "Copyright &copy; 1997-2004 <a href=\"http://www.spi-inc.org\">SPI</a>; See <a href=\"%s/license\">license terms</a>." ), "$HOME/" )."<br>\n".
	gettext( "Debian is a registered trademark of Software in the Public Interest, Inc." ).
	"</small>\n".
	"</div> <!-- end footer -->\n".
	"</div> <!-- end outer -->\n".
	"</body>\n</html>\n";

    return $txt;
}

sub languages {
    my ( $name, $lang, @used_langs ) = @_;
    
    my $str = "";
    
    if (@used_langs) {
	$str .= "<hr class=\"hidecss\">\n";
	$str .= "<!--UdmComment-->\n<p>\n";
	$str .= gettext( "This page is also available in the following languages:\n" );
	$str .= "</p><p class=\"navpara\">\n";
	
	my @printed_langs = ();
	foreach (@used_langs) {
	    next if $_ eq $lang; # Never print the current language
	    unless (get_selfname($_)) { warn "missing language $_"; next } #DEBUG
	    push @printed_langs, $_;
	}
	return "" unless scalar @printed_langs;
	# Sort on uppercase to work with languages which use lowercase initial
	# letters.
	foreach my $cur_lang (sort langcmp @printed_langs) {
	    my $tooltip = dgettext( "langs", get_language_name($cur_lang) );
	    $str .= "<a href=\"$name.$cur_lang.html\" title=\"$tooltip\" hreflang=\"$cur_lang\" lang=\"$cur_lang\" rel=\"alternate\">".get_selfname($cur_lang);
	    $str .= " (".get_transliteration($cur_lang).")" if defined get_transliteration($cur_lang);
	    $str .= "</a>\n";
	}
	$str .= "\n</p><p>\n";
	$str .= gettext( "How to set <a href=\"$CN_HELP_URL\">the default document language</a></p>" );
	$str .= "\n<!--/UdmComment-->\n";
    }
    
    return $str;
}

1;
