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

    my $logo_align = 'center';
    if ($params{print_title_above}) {
	$logo_align = 'left';
	$title_in_header = "<td align=\"right\" valign=\"middle\"><h1>$title_in_header</h1></td>";
    } else {
	$title_in_header = '';
    }

    my $search_in_header = '';
    $params{print_search_field} ||= "";
    if ($params{print_search_field} eq 'packages') {
	my %values = %{$params{search_field_values}};
	$logo_align ='left';
	my %checked_searchon = ( names => "",
				 all => "",
				 sourcenames => "", );
	$checked_searchon{$values{searchon}} = "checked=\"checked\"";
	$search_in_header = <<MENU;
<td align="left" valign="middle">
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
</td>
MENU
;
    } elsif ($params{print_search_field} eq 'contents') {
	my %values = %{$params{search_field_values}};
	$logo_align ='left';
	my %checked_searchmode = ( searchfiles => "",
				   searchfilesanddirs => "",
				   searchword => "",
				   filelist => "", );
	$checked_searchmode{$values{searchmode}} = "checked=\"checked\"";
	$search_in_header = <<MENU;
<td align="left" valign="middle">
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
</td>
MENU
;
    }

    my $keywords = $params{keywords} || '';
    my $KEYWORDS_LINE = "<meta name=\"Keywords\" content=\"debian, $keywords $title_keywords\">";
    
    my $LANG = $params{lang};
    my $img_lang = $img_trans{$LANG} || $LANG;
    my $charset = get_charset($LANG);
    my $txt = <<HEAD;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html lang="$LANG">
<head>
<title>Debian GNU/Linux -- $title_tag</title>
<link rev="made" href="mailto:webmaster\@debian.org">
<meta http-equiv="Content-Type" content="text/html; charset=$charset">
<meta name="Author" content="Debian Webmaster, webmaster\@debian.org">
$KEYWORDS_LINE
$DESC_LINE
</head>
<body text="#000000" bgcolor="#FFFFFF" link="#0000FF" vlink="#800080" alink="#FF0000">
<table border="0" cellpadding="3" cellspacing="0" align="center" width="100%" summary="">
<tr>
<td align="$logo_align" valign="middle">
<a href="$HOME/"><img src="$HOME/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="" width="50" height="61"></a>
HEAD
;

    $txt .= img( "$HOME/", "", "Pics/debian.jpg", gettext( "Debian Project" ),
		 width => 179, height => 61 );
    $txt .= <<NAVBEGIN;
</td>
$search_in_header
$title_in_header
</tr>
</table>
<table bgcolor="#DF0451" border="0" cellpadding="0" cellspacing="0" width="100%" summary="">
<tr>
<td valign="top">
<img src="$HOME/Pics/red-upperleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
<td rowspan="2" align="center">
NAVBEGIN
;

    $txt .= img( "$HOME/", "intro/about", "Pics/about.$img_lang.gif",
		 gettext( "About&nbsp;Debian" ), 
		 hspace => 4, vspace => 7 );
    $txt .= img( "$HOME/", "News/", "Pics/news.$img_lang.gif",
		 gettext( "News" ), 
		 hspace => 4, vspace => 7 );
    $txt .= img( "$HOME/", "distrib/", "Pics/getting.$img_lang.gif",
		 gettext( "Getting&nbsp;Debian" ), 
		 hspace => 4, vspace => 7 );
    $txt .= img( "$HOME/", "support", "Pics/support.$img_lang.gif",
		 gettext( "Support" ), 
		 hspace => 4, vspace => 7 );
    $txt .= img( "$HOME/", "devel/", "Pics/devel.$img_lang.gif",
		 gettext( "Development" ), 
		 hspace => 4, vspace => 7 );
    $txt .= img( "$HOME/", "sitemap", "Pics/sitemap.$img_lang.gif",
		 gettext( "Site map" ), 
		 hspace => 4, vspace => 7 );
    $txt .= img( "", "http://search.debian.org/", 
		 "$HOME/Pics/search.$img_lang.gif",
		 gettext( "Search" ), 
		 hspace => 4, vspace => 7 );
    
    $txt .= <<ENDNAV;
</td>
<td valign="top">
<img src="$HOME/Pics/red-upperright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
</tr>
<tr>
<td valign="bottom">
<img src="$HOME/Pics/red-lowerleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
</td>
<td valign="bottom">
<img src="$HOME/Pics/red-lowerright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
</td>
</tr>
</table>
ENDNAV
;

    if ($params{print_title_below}) {
	$txt .= "<h1>$page_title</h1>\n\n";
    }

    return $txt;
}

sub trailer {
    my ($ROOT, $NAME, $LANG, @USED_LANGS) = @_;
    my $txt = languages( $NAME, $LANG, @USED_LANGS );
    $txt .=
	"\n\n<hr noshade width=\"100%\" size=\"1\">" .
	sprintf( gettext( "Back to: <a href=\"%s/\">Debian Project homepage</a> || <a href=\"%s/\">Packages search page</a>" ), $HOME, $ROOT ).
	"\n<hr noshade width=\"100%\" size=\"1\">\n".
	"<small>".
	sprintf( gettext( "See the Debian <a href=\"%s/contact\">contact page</a> for information on contacting us." ), $HOME ).
	"</small>\n".
	"<p><small>". gettext( "Last Modified: " ). "LAST_MODIFIED_DATE".
	"<br>\n".
	sprintf( gettext( "Copyright &copy; 1997-2004 <a href=\"http://www.spi-inc.org\">SPI</a>; See <a href=\"%s/license\">license terms</a>." ), "$HOME/" )."<br>\n".
	gettext( "Debian is a registered trademark of Software in the Public Interest, Inc." ).
	"</small>\n".
	"</body>\n</html>\n";

    return $txt;
}

sub languages {
    my ( $name, $lang, @used_langs ) = @_;
    
    my $str = "";
    
    if (@used_langs) {
	$str .= "<hr>\n";
	$str .= "<!--UdmComment-->\n";
	$str .= gettext( "This page is also available in the following languages:\n" );
	$str .= "<br>\n";
	
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
	    $str .= "&nbsp;(".get_transliteration($cur_lang).")" if defined get_transliteration($cur_lang);
	    $str .= "</a>&nbsp;\n";
	}
	$str .= "\n<br />\n";
	$str .= gettext( "How to set <a href=\"$CN_HELP_URL\">the default document language</a>" );
	$str .= "\n<!--/UdmComment-->\n";
    }
    
    return $str;
}

1;
