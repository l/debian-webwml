package Packages::HTML;

use strict;
use warnings;

use Locale::gettext;
use Digest::MD5;
use Fcntl;

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
    my ($TITLE, $PACKTOP, $ROOT, $LANG, $DESC, $KEYWORDS) = @_;
    my $DESC_LINE;
    if (defined $DESC) {
	$DESC_LINE = "<meta name=\"Description\" content=\"$DESC\">";
    }
    else {
	$DESC_LINE = '';
    }
    if (!defined $KEYWORDS) {
	$KEYWORDS = '';
    }
    my $KEYWORDS_LINE = "<meta name=\"Keywords\" content=\"debian, $KEYWORDS $TITLE\">";
    
    my $img_lang = $img_trans{$LANG} || $LANG;
    my $charset = get_charset($LANG);
    my $txt = <<HEAD;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html lang="$LANG">
<head>
<title>Debian GNU/Linux -- $TITLE</title>
<link rev="made" href="mailto:webmaster\@debian.org">
<meta http-equiv="Content-Type" content="text/html; charset=$charset">
<meta name="Author" content="Debian Webmaster, webmaster\@debian.org">
$KEYWORDS_LINE
$DESC_LINE
</head>
<body text="#000000" bgcolor="#FFFFFF" link="#0000FF" vlink="#800080" alink="#FF0000">
<table border="0" cellpadding="3" cellspacing="0" align="center" summary="">
<tr>
<td>
<a href="$HOME/"><img src="$HOME/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="" width="50" height="61"></a>
HEAD
;

    $txt .= img( "$HOME/", "", "Pics/debian.jpg", gettext( "Debian Project" ),
		 width => 179, height => 61 );
    $txt .= <<NAVBEGIN;
</td>
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

# if there is no fifth parameter, this must be some sort of an index page
# so we can add a heading with the title
    if (!defined $DESC) {
	$txt .= "<h1>$TITLE</h1>\n\n";
    }

    return $txt;
}

sub trailer {
    my ($ROOT, $NAME, $LANG, @USED_LANGS) = @_;
    my $txt = languages( $NAME, $LANG, @USED_LANGS );
    $txt .=
	"\n\n<hr noshade width=\"100%\" size=\"1\">" .
	sprintf( gettext( "Back to: <a href=\"%s/\">Debian Project homepage</a> || <a href=\"%s/\">Packages search page</a>" ), $HOME, $ROOT ).
	"<hr noshade width=\"100%\" size=\"1\">".
	"<small>".
	sprintf( gettext( "See the Debian <a href=\"%s/contact\">contact page</a> for information on contacting us." ), $HOME ).
	"</small>".
	"<p><small>". gettext( "Last Modified: " ). "LAST_MODIFIED_DATE".
	"<br>".
	sprintf( gettext( "Copyright &copy; 1997-2003 <a href=\"http://www.spi-inc.org\">SPI</a>; See <a href=\"%s/license\">license terms</a>." ), "$HOME/" )."<br>".
	gettext( "Debian is a registered trademark of Software in the Public Interest, Inc." ).
	"</small>".
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

sub file_changed {
    my ($md5s, $file, $text) = @_;
    
    my $md5string = Digest::MD5::md5_hex( $text );
    if ( exists $md5s->{$file} 
	 && ($md5s->{$file} eq $md5string) 
	 && (-f $file)) {
	return 0;
    }
    else {
	$md5s->{$file} = $md5string;
	return 1;
    }
}

sub read_md5_hash {
    my $md5file = shift;
    my %md5s;
    if (open(MD5H, "<", $md5file)) {
	foreach(<MD5H>) {
	    chomp;
	    next unless /(\w+)\s*(.+)/;
	    $md5s{$2} = $1;
	}
	close MD5H;
    }
    else {
	# ok if open does not work. Every file will be re-generated and
	# the file will be generated later.
    }
    return \%md5s;
}

sub write_md5_hash {
    my ( $md5file, $md5s ) = @_;
    sysopen(MD5H, $md5file, O_WRONLY | O_TRUNC | O_CREAT, 0664) 
	|| warn "Can\'t open $md5file: $!";
    foreach ( keys %$md5s ) {
	print MD5H "$md5s->{$_} $_\n";
    }
    close MD5H;
}

sub time_stamp {
    my ($sec,$min,$hour,$mday,undef,$year) = gmtime();
    my $time_str = gmtime();
    my ($wday, $month) = ($time_str =~ /^(\w{3})\s+(\w+)/);

    $year += 1900;
    $time_str = sprintf( "$wday, $mday $month $year %02d:%02d:%02d +0000", 
			 $hour, $min, $sec );

    return $time_str;
}


1;
