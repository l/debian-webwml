package Packages::HTML;

use strict;
use warnings;

use URI::Escape;
use HTML::Entities;

use Packages::Util;
use Packages::I18N::Locale;
use Packages::I18N::Languages;
use Packages::I18N::LanguageNames;
use Generated::Strings qw( gettext dgettext );

our @ISA = qw( Exporter );
our @EXPORT = qw( header title trailer file_changed time_stamp
		  read_md5_hash write_md5_hash simple_menu
		  ds_begin ds_item ds_end note title marker pdesc
		  pdeplegend pkg_list pmoreinfo );

our $HOME = "http://www.ubuntulinux.org";
our $CONTACT_MAIL = 'frank@lichtenheld.de';
our $WEBMASTER_MAIL = 'frank@lichtenheld.de';
our $SEARCH_PAGE = "http://packages.ubuntu.com/";
our $CGI_ROOT = "/cgi-bin/";
our $CN_HELP_URL = "http://www.debian.org/intro/cn";
our $CHANGELOG_URL = 'http://changelogs.ubuntu.com/changelogs';
our $COPYRIGHT_URL = 'http://changelogs.ubuntu.com/changelogs';
our $SEARCH_URL = '/cgi-bin/search_packages.pl?searchon=names&amp;version=all&amp;exact=1&amp;keywords=';
our $SRC_SEARCH_URL = '/cgi-bin/search_packages.pl?searchon=sourcenames&amp;version=all&amp;exact=1&amp;keywords=';
our $LAUNCHPAD_URL = 'https://launchpad.net/distros/ubuntu/+source/';
our $QA_URL = 'http://packages.qa.debian.org/';
our $BUILD_LOG_URL = 'http://people.ubuntu.com/~lamont/buildLogs';
our $TEST_BUILD_LOG_URL = 'http://people.ubuntu.com/~lamont/buildLogs/Test';


my %img_trans = ( pt_BR => "pt", pt_PT => "pt", sv_SE => "sv" );

sub img {
    my ( $root, $url, $src, $alt, %attr ) = @_; 
    my @attr;

    foreach my $a ( keys %attr ) {
	push @attr, "$a=\"$attr{$a}\"";
    }

    return "<a href=\"$root$url\"><img src=\"$root$src\" alt=\"$alt\" @attr></a>";
}

sub simple_menu {
    my $str = '<p id="extranav">';
    foreach my $entry (@_) {
	$str .= "[&nbsp;$entry->[0] <a title=\"$entry->[1]\" href=\"$entry->[2]\">$entry->[3]</a>&nbsp;]\n";
    }
    $str .= '</p>';
    return $str;
}

sub title {
    return "<h1>$_[0]</h1>\n";
}

sub marker {
    return "[<span class=\"pred\">$_[0]</span>]";
}

sub note {
    my ( $title, $note ) = @_;
    my $str = "";

    if ($note) {
	$str .= "<h2 class=\"pred\">$title</h2>";
    } else {
	$note = $title;
    }
    $str .= "<p>$note</p>";
    return $str;
}

sub pdesc {
    my ( $short_desc, $long_desc ) = @_;
    my $str = "";

    $str .= "<div id=\"pdesc\">\n";
    $str .= "<h2>$short_desc</h2>\n";

    $str .= "<p>$long_desc\n";
    $str .= "</div> <!-- end pdesc -->\n";

    return $str;
}

sub pdeplegend {
    my $str = "<table border=\"1\" summary=\"legend\"><tr>\n";

    foreach my $entry (@_) {
	$str .= "<td><img src=\"../../Pics/$entry->[0].gif\" alt=\"[$entry->[0]]\" width=\"16\" height=\"16\">= $entry->[1]</td>";
    }

    $str .= "\n</tr></table>\n";
    return $str;
}

sub pkg_list {
    my ( $pkgs, $lang, $env ) = @_;

    my $str = "";
    foreach my $p ( @$pkgs ) {
	my $p_pkg = $env->{db}->get_pkg( $p );

	if ( $p_pkg ) {
	    if ($p_pkg->is_virtual) {
		$str .= "<dt><a href=\"../virtual/$p\">$p</a></dt>\n".
		    "\t<dd>".gettext("Virtual package")."</dd>\n";
	    } else {
		my %subsections = $p_pkg->get_arch_fields( 'section',
							   $env->{archs} );
		my $subsection = $subsections{max_unique} || 'unknown';
		my %desc_md5s = $p_pkg->get_arch_fields( 'description-md5', 
							 $env->{archs} );
		my $short_desc = conv_desc( $lang,
					    encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $lang ), "<>&\"" ) );
		$str .= "<dt><a href=\"../$subsection/$p\">$p</a></dt>\n".
		    "\t<dd>$short_desc</dd>\n";
	    }
	} else {
	    $str .= "<dt>$p</dt>\n\t<dd>".gettext("Not available")."</dd>\n";
	}
    }
    if ($str) {
	$str = "<dl>$str</dl>\n";
    }

    return $str;
}

sub pmoreinfo {
    my %info = @_;
    
    my $name = $info{name} or return;
    my $env = $info{env} or return;
    my $d = $info{data} or return;
    my $is_source = $info{is_source};

    my $str = "<div id=\"pmoreinfo\">";
    $str .= sprintf( "<h2>".gettext( "More Information on %s" )."</h2>",
		     $name );
	
    
    if ($info{bugreports} || $info{sourcedownload} || $info{changesandcopy} || $info{buildlogs}) {
    	$str .= "<p>\n";
    }
    
    if ($info{bugreports}) {
    	my $url_name = $name;
	my $bug_url = $LAUNCHPAD_URL;
	$url_name = "$name/+bugs";
	$url_name = "$d->{src_name}/+bugs" unless $is_source;
	$str .= sprintf( gettext( "Check for <a href=\"%s\">Bug Reports</a> about %s." )."<br>\n",
			 $bug_url.$url_name, $name );
    }
	
    if ($info{sourcedownload}) {
	$str .= gettext( "Source Package:" );
	$str .= " <a href=\"../source/$d->{src_name}\">$d->{src_name}</a>, ".
	    gettext( "Download" ).":\n";

	unless ($d->{src_files}) {
	    $str .= gettext( "Not found" );
	} else {
	    foreach( @{$d->{src_files}} ) {
		my ($src_file_md5, $src_file_size, $src_file_name) = @$_;
		if ($d->{is_security}) {
		    $str .= "<a href=\"$env->{opts}{security_site}/$d->{src_directory}/$src_file_name\">[";
		} elsif ($d->{is_volatile}) {
		    $str .= "<a href=\"$env->{opts}{volatile_site}/$d->{src_directory}/$src_file_name\">[";
		} elsif ($d->{is_nonus}) {
		    $str .= "<a href=\"$env->{opts}{nonus_site}/$d->{src_directory}/$src_file_name\">[";
		} else {
		    $str .= "<a href=\"$env->{opts}{debian_site}/$d->{src_directory}/$src_file_name\">[";
		}
		if ($src_file_name =~ /dsc$/) {
		    $str .= "dsc";
		} else {
		    $str .= $src_file_name;
		}
		$str .= "]</a>\n";
	    }
	}
#	    $package_page .= sprintf( gettext( " (These sources are for version %s)\n" ), $src_version )
#		if ($src_version ne $version) && !$src_version_given_in_control;
    }

    if ($info{changesandcopy}) {
	if ( $d->{src_directory} ) {
	    my $src_dir = $d->{src_directory};
	    (my $src_basename = $d->{src_version}) =~ s,^\d+:,,; # strip epoche
	    $src_basename = "$d->{src_name}_$src_basename";
	    $src_dir =~ s,pool/updates,pool,o;
	    $src_dir =~ s,pool/non-US,pool,o;
	    $str .= "\n<br>".sprintf( gettext( "View the <a href=\"%s\">Debian changelog</a>" ),
				    "$CHANGELOG_URL/$src_dir/$src_basename/changelog" )."<br>\n";
	    my $copyright_url = "$COPYRIGHT_URL/$src_dir/$src_basename/";
	    $copyright_url .= ( $is_source ? 'copyright' : "$name.copyright" );

	    $str .= sprintf( gettext( "View the <a href=\"%s\">copyright file</a>" ),
			     $copyright_url )."</p>";
	}
    }

    if ($info{buildlogs}) {
    	my $fl;
	if ($d->{src_name} =~ /^lib/o) {
    		$fl = substr $d->{src_name}, 0, 4;
	} else {
		$fl = substr $d->{src_name}, 0, 1;
	}

	$str .= "\n<br>".gettext( "Build Logs:" )." <a href=\"$BUILD_LOG_URL/$fl/$d->{src_name}/$d->{src_version}/\">$env->{distribution}</a> <a href=\"$TEST_BUILD_LOG_URL/$fl/$d->{src_name}/$d->{src_version}/\">$env->{distribution} (".gettext("regression test").")</a>";
    }

    if ($info{bugreports} || $info{sourcedownload} || $info{changesandcopy} || $info{buildlogs}) {
    	$str .= "\n</p>\n";
    }

    if ($info{maintainers}) {
	my @uploaders = @{$d->{uploaders}};
	foreach (@uploaders) {
	    $_->[0] = encode_entities( $_->[0], '&<>' );
	}
	my ($maint_name, $maint_mail ) = @{shift @uploaders}; 
	unless (@uploaders) {
	    $str .= "<p>\n".sprintf( gettext( "%s is responsible for this Debian package." ).
				     "\n",
				     "<a href=\"mailto:$maint_mail\">$maint_name</a>" 
				     );
	} else {
	    my $up_str = "<a href=\"mailto:$maint_mail\">$maint_name</a>";
	    my @uploaders_str;
	    foreach (@uploaders) {
		push @uploaders_str, "<a href=\"mailto:$_->[1]\">$_->[0]</a>";
	    }
	    my $last_up = pop @uploaders_str;
	    $up_str .= ", ".join ", ", @uploaders_str if @uploaders_str;
	    $up_str .= sprintf( gettext( " and %s are responsible for this Debian package." ), $last_up );
	    $str .= "<p>\n$up_str ";
	}

	$str .= sprintf( gettext( "See the <a href=\"%s\">developer information for %s</a>." )."</p>", $QA_URL.$d->{src_name}, $name );
    }

    if ($info{search}) {
	my $encodedname = uri_escape( $name );
	my $search_url = $is_source ? $SRC_SEARCH_URL : $SEARCH_URL;
	$str .= "<p>".sprintf( gettext( "Search for <a href=\"%s\">other versions of %s</a>" ), $search_url.$encodedname, $name )."</p>\n";
    }

    $str .= "</div> <!-- end pmoreinfo -->\n";
    return $str;
}

my $ds_begin = '<dl>';
my $ds_item_desc  = '<dt>';
my $ds_item = ':</dt><dd>';
my $ds_item_end = '</dd>';
my $ds_end = '</dl>';
#	    my $ds_begin = '<table><tbody>';
#	    my $ds_item_desc  = '<tr><td>';
#	    my $ds_item = '</td><td>';
#	    my $ds_item_end = '</td></tr>';
#	    my $ds_end = '</tbody></table>';

sub ds_begin {
    return $ds_begin;
}
sub ds_item {
    return "$ds_item_desc$_[0]$ds_item$_[1]$ds_item_end\n";
}
sub ds_end {
    return $ds_end;
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
    my $meta = $params{meta} || '';

    if ($params{print_title_above}) {
 	$title_in_header = "<h1>$title_in_header</h1>";
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
<form method="GET" action="$CGI_ROOT/search_packages.pl">
<div id="hpacketsearch">
<input type="hidden" name="version" value="$values{version}">
<input type="hidden" name="subword" value="$values{subword}">
<input type="hidden" name="exact" value="$values{exact}">
<input type="hidden" name="arch" value="$values{arch}">
<input type="hidden" name="releases" value="$values{releases}">
<input type="hidden" name="case" value="$values{case}">
<input type="text" size="30" name="keywords" value="$values{keywords}" id="kw">
<input type="submit" value="Search">
<span style="font-size: 60%"><a href="$SEARCH_PAGE#search_packages">Full options</a></span>
<div style="font-size: 80%">
<input type="radio" name="searchon" value="names" id="onlynames" $checked_searchon{names}>
<label for="onlynames">Package names</label>&nbsp;&nbsp;
<input type="radio" name="searchon" value="all" id="descs" $checked_searchon{all}>
<label for="descs">Descriptions</label>
<input type="radio" name="searchon" value="sourcenames" id="src" $checked_searchon{sourcenames}>
<label for="src">Source package names</label>
</div>
</div> <!-- end hpacketsearch -->
</form>
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
<form method="GET" action="$CGI_ROOT/search_contents.pl">
<div id="hpacketsearch">
<input type="hidden" name="version" value="$values{version}" />
<input type="hidden" name="arch" value="$values{arch}" />
<input type="hidden" name="case" value="$values{case}" />
<input type="text" size="30" name="word" id="keyword" value="$values{keyword}">&nbsp;
<input type="submit" value="Search">
<span style="font-size: 60%"><a href="$SEARCH_PAGE#search_contents">Full options</a></span>
<div style="font-size: 80%">Display:
<input type=radio name="searchmode" value="searchfiles" id="searchfiles" $checked_searchmode{searchfiles}>
<label for="searchfiles">files</label>
<input type=radio name="searchmode" value="searchfilesanddirs" id="searchfilesanddirs" $checked_searchmode{searchfilesanddirs}>
<label for="searchfilesanddirs">files &amp; directories</label>
<input type=radio name="searchmode" value="searchword" id="searchword" $checked_searchmode{searchword}>
<label for="searchword">subword matching</label>
<input type=radio name="searchmode" value="filelist" id="filelist" $checked_searchmode{filelist}>
<label for="filelist">content list</label>
</div>
</div> <!-- end hpacketsearch -->
</form>
MENU
;
    }

    my $keywords = $params{keywords} || '';
    my $KEYWORDS_LINE = "<meta name=\"Keywords\" content=\"debian, $keywords $title_keywords\">";
    
    my $LANG = $params{lang};
    my $img_lang = $img_trans{$LANG} || $LANG;
    my $charset = get_charset($LANG);
    my $txt = <<HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="$LANG">
<head>
<title>Ubuntu -- $title_tag</title>
<link rev="made" href="mailto:$WEBMASTER_MAIL">
<meta http-equiv="Content-Type" content="text/html; charset=$charset">
<meta name="Author" content="Frank Lichtenheld, $WEBMASTER_MAIL">
$KEYWORDS_LINE
$DESC_LINE
$meta
<link href="/debian.css" rel="stylesheet" type="text/css" media="all">
<link href="/ubuntu/ubuntu.css" rel="stylesheet" type="text/css" media="all">
<link href="/ubuntu/masthead.css" rel="stylesheet" type="text/css" media="all">
</head>
<body>
    <div id="pageWrapper">
      <div id="mastWrapper">
        <div id="masthead">
          <a class="imageLink"
             href="http://www.ubuntulinux.org">&nbsp;</a>

          <a class="hiddenStructure"
             href="http://www.ubuntulinux.org/#documentContent">Skip
             to content</a>

           <div id="search">
	   $search_in_header
	   </div>
             
     <!-- masthead content begin -->
    <h5 class="hiddenStructure">Sections</h5>    
    <div id="nav">
      <ul>        
HEAD
;

    my $current = 'home';
    foreach my $dist (qw(dapper-backports dapper edgy-backports edgy feisty-backports feisty gutsy-backports gutsy)) {
	if ($KEYWORDS_LINE =~ /\Q$dist\E/) {
	    $current = $dist;
	    last;
	}
    }
    #TODO: what with backports?
    foreach my $tab (qw(home dapper edgy feisty gutsy)) {
	my $url = $tab eq 'home' ? '' : "$tab/";
	my $id = $tab eq $current ? 'current' : 'plain';
	$txt .= "<li id=\"$id\"><a href=\"/$url\">".ucfirst($tab)."</a></li>";
    }

$txt .= <<ENDNAV;        
      </ul>
    </div> <!-- nav -->
    <!-- masthead content end -->
    </div> <!-- masthead -->
   </div>  <!-- mastWrapper -->

<div class="visualClear"></div>
ENDNAV
;
    $txt .= <<BEGINCONTENT;
<div id="contentColumn">
<div class="inside">
<div id="content" class="">
<div class="documentContent" id="region-content">
BEGINCONTENT
;
    if ($params{print_title_above}) {
	$txt .= "<h1 class=\"documentFirstHeading\">$page_title</h1>\n";
    }
    if ($params{print_title_below}) {
	$txt .= "<h1 class=\"documentFirstHeading\">$page_title</h1>\n";
    }

    return $txt;
}

sub trailer {
    my ($ROOT, $NAME, $LANG, @USED_LANGS) = @_;
    my $txt = "</div></div></div></div> <!-- end inner -->\n<div class=\"clear mozclear\"></div><div id=\"prefooter\">\n";
    my $langs = languages( $NAME, $LANG, @USED_LANGS );
    my $bl_class = $langs ? ' class="bordertop"' : "";
    $txt .=
	$langs.
	"\n<hr class=\"hidecss\">\n" .
	"<p$bl_class>".
	sprintf( gettext( "Back to: <a href=\"%s/\">Ubuntu homepage</a> || <a href=\"%s/\">Packages search page</a>" ), $HOME, $ROOT ).
	"</p></div>\n<hr class=\"hidecss\">\n".
	'<div id="footWrapper">'.
	'<div id="footer" class="inside">'.
	'<p>'.
	sprintf( gettext( "To report a problem with the web site, e-mail <a href=\"mailto:%s\">%s</a>. For other support information, see the Ubuntu <a href=\"%s/support\">support page</a>." ), $CONTACT_MAIL, $CONTACT_MAIL, $HOME).
	"</p>\n".
	"<p>". gettext( "Last Modified: " ). "LAST_MODIFIED_DATE".
	"<br>\n".
#	sprintf( gettext( "Copyright &copy; 1997-2005 <a href=\"http://www.spi-inc.org\">SPI</a>; See <a href=\"%s/license\">license terms</a>." ), "$HOME/" )."<br>\n".
#	gettext( "Debian is a registered trademark of Software in the Public Interest, Inc." ).
	gettext( "Ubuntu is a registered trademark of Canonical Ltd." ).
	"</div> <!-- end footer -->".
	"</div> <!-- end footWrapper -->\n".
	"</div> <!-- end pageWrapper -->\n".
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
	$str .= sprintf( gettext( "How to set <a href=\"%s\">the default document language</a></p>" ), $CN_HELP_URL );
	$str .= "\n<!--/UdmComment-->\n";
    }
    
    return $str;
}

1;
