require 5.006;

use strict;
use warnings;

use POSIX;
use HTML::Entities;
use Data::Dumper;
# $Data::Dumper::Maxdepth = 3;
use URI::Escape;

use Packages::OutputFiles;
use Packages::HTML;
use Packages::I18N::Locale;
use Deb::Versions;

require( 'sections.pl' );
require( 'priorities.pl' );
require( 'print_deps.pl' );
require( 'index_pages.pl' );
require( 'util.pl' );

my $CHANGELOG_URL = '/changelogs';
my $COPYRIGHT_URL = '/changelogs';
my $FILELIST_URL = '/cgi-bin/search_contents.pl?searchmode=filelist&amp;word=';
my $SEARCH_URL = '/cgi-bin/search_packages.pl?searchon=names&amp;version=all&amp;exact=1&amp;keywords=';
my $SRC_SEARCH_URL = '/cgi-bin/search_packages.pl?searchon=sourcenames&amp;version=all&amp;exact=1&amp;keywords=';
my $BUG_URL = 'http://bugs.debian.org/';
my $SRC_BUG_URL = 'http://bugs.debian.org/src:';
my $QA_URL = 'http://packages.qa.debian.org/';
my $DL_URL = '/cgi-bin/download.pl';
my $POLICY_URL = 'http://www.debian.org/doc/debian-policy/';
my $DDPO_URL = 'http://qa.debian.org/developer.php?login=';

my $files;

my $p_counter = 0;
sub progress {
    print "\r".$p_counter++;
}

sub walk_db_packages ($\&;$) {
    my $db = shift;
    my $func = shift;
    my $env = shift;

    my @pkg_list = $db->get_sorted_list();

    foreach (@pkg_list) {
	my $p = $db->get_pkg( $_ );
	&$func( $p, $env );
    }
}

sub walk_db_src_packages ($\&;$) {
    my $db = shift;
    my $func = shift;
    my $env = shift;

    my @src_pkg_list = $db->get_sorted_srclist();

    foreach (@src_pkg_list) {
	my $p = $db->get_src_pkg( $_ );
	&$func( $p, $env );
    }
}


sub print_virt_pack {
    my ( $pkg, $env ) = @_;

    my $name = $pkg->get_name;

    my $package_page = header( title => $name, lang => $env->{lang},
			       desc => gettext( "virtual package" ),
			       keywords => "$env->{distribution}, virtual, virtual, virtual, size:0 virtual" );
    $package_page .= "[&nbsp;".gettext( "Distribution:" )." <a title=\"".gettext( "Overview over this distribution" )."\" href=\"../\">$env->{distribution}</a>&nbsp;]\n";
    $package_page .= "[&nbsp;".gettext( "Section:" )." <a title=\"".gettext( "All packages in this section" )."\" href=\"../virtual/\">virtual</a>&nbsp;]\n";

    $package_page .= sprintf( "<h1>".gettext( "Virtual Package: %s" )."</h1>", 
			      $name );

    $package_page .= "<p>".gettext( "This is a <em>virtual package</em>. See the <a href=\"$POLICY_URL\">Debian policy</a> for a <a href=\"${POLICY_URL}ch-binary.html#s-virtual_pkg\">definition of virtual packages</a>." )."</p>\n";

    $package_page .= sprintf( "<h2>".gettext( "Packages providing %s:" )."</h2>",
			      $name );
    $package_page .= "<dl>\n";
    foreach my $p ( keys %{$pkg->{rr}{provides}} ) {
	my $p_pkg = $env->{db}->get_pkg( $p );

	if ( $p_pkg ) {
	    my %sections = $p_pkg->get_arch_fields( 'section',
						    $env->{archs} );
	    my $section = $sections{max_unique};
	    my %desc_md5s = $p_pkg->get_arch_fields( 'description-md5', 
						     $env->{archs} );
	    my $short_desc = conv_desc( $env->{lang}, encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" ) );
	    $package_page .= "<dt><a href=\"../$section/$p\">$p</a></dt>\n".
		"\t<dd>$short_desc</dd>\n";
	} else { die "$p"; } #FIXME
    }
    $package_page .= "</dl>\n";
    $package_page .= trailer( '../..' );
    
    #
    # write file
    #
    my $dirname = "$env->{dest_dir}/virtual";
    my $filename = "$dirname/$name.$env->{lang}.html";
    $files->update_file( $filename, $package_page );
}

sub package_pages_walker {
	my ( $pkg, $env ) = @_;

	my $name = $pkg->get_name;

	if ( $pkg->is_virtual ) { 
	    if ( $env->{lang} eq 'en' ) {
		print_virt_pack( @_ ); 
	    }
	    return;
	}
	
	my @all_archs = ( @{$env->{archs}}, 'all' );

	#
	# get information
	#
	my %versions = $pkg->get_arch_versions( $env->{archs} );
	my $version = (version_sort( keys %{$versions{unique}} ))[0];

	my %desc_md5s = $pkg->get_arch_fields( 'description-md5', 
					       $env->{archs} );
	my %sections = $pkg->get_arch_fields( 'section', 
					      $env->{archs} );
	my %priorities = $pkg->get_arch_fields( 'priority', 
						$env->{archs} );
	my %essential = $pkg->get_arch_fields( 'essential', 
					       $env->{archs} );
	my %archives = $pkg->get_arch_fields( 'archive', 
					      $env->{archs} );
	my %subdists = $pkg->get_arch_fields( 'subdistribution', 
					      $env->{archs} );
	my %maintainers = $pkg->get_arch_fields( 'maintainer',
						 $env->{archs} );
	my %sources = $pkg->get_arch_fields( 'source',
					     $env->{archs} );
	my %filenames = $pkg->get_arch_fields( 'filename',
					       $env->{archs} );
	my %file_md5s = $pkg->get_arch_fields( 'md5sum',
					       $env->{archs} );
	my %file_sizes = $pkg->get_arch_fields( 'size',
						$env->{archs} );
	my %inst_sizes = $pkg->get_arch_fields( 'installed-size',
						$env->{archs} );
	my ( $section, $archive, $priority, $essential,
	     $sourcepackage, $src_version, $subdist, $maintainer );
	$section = $sections{max_unique};
	$priority = $priorities{max_unique} || "";
	$essential = $essential{max_unique} || "";

	my $dirname = "$env->{dest_dir}/$section";
	my $filename = "$dirname/$name.$env->{lang}.html";

	unless (( $env->{lang} eq 'en' ) 
		|| $env->{db}->is_translated( $name, $version,
					      ${$versions{v2a}->{$version}}[0],
					      $env->{lang} )) {
	    $files->delete_file( $filename ) if $files->file_exists( $filename );
	    return;
	}
	progress() if $env->{opts}{progress};

	$maintainer = $pkg->get_newest( 'maintainer' );
	$maintainer = $maintainers{max_unique} if $maintainer eq 'CONFLICT';
	$sourcepackage = $pkg->get_newest( 'source' );
	$sourcepackage = $sources{max_unique} if $sourcepackage eq 'CONFLICT';

	my $src_version_given_in_control = 0;
	if ( $sourcepackage =~ s/\s*\((.*)\)\s*$//o ) {
	    $src_version = $1;
	    $src_version_given_in_control = 1;
	} else {
	    $src_version = $version;
	}
	my $src_pkg = $env->{db}->get_src_pkg( $sourcepackage );
	if ( $src_pkg && !exists $src_pkg->{versions}->{$src_version} ) {
	    $src_version = ($src_pkg->get_version_list)[0];
	    $src_version_given_in_control = 0;
	}

	$archive = $archives{max_unique}
	    if exists $archives{max_unique};
	$subdist = $subdists{max_unique}
	    if exists $subdists{max_unique};

	#
	# process version
	#
	my ( @v_str, $v_str_arch, $v_str, $unique_version );
#	foreach ( ( $pkg->get_version_list ) ) {
	if ( scalar keys %{$versions{unique}} == 1 ) {
	    $v_str = "$version";
	    $unique_version = 1;
	} else {
	    foreach ( version_sort( keys %{$versions{unique}} ) ) {
		push @v_str, "$_ [".join( ", ", @{$versions{v2a}->{$_}} )."]";
	    }
	    $v_str_arch = join( ", ", @v_str );
	    $v_str = join( ", ",  version_sort( keys %{$versions{unique}} ) );
	}

	#
	# process maintainer and uploaders
	#
	my ( $maint_name, $maint_email ) = split_name_mail( $maintainer );
	my @uploaders;
	if ($src_pkg && exists $src_pkg->{versions}{$src_version}{uploaders}) {
	    @uploaders = split( /\s*,\s*/, 
				$src_pkg->{versions}{$src_version}{uploaders} );
	    foreach (@uploaders) {
		$_ = [ split_name_mail( $_ ) ];
	    }
	}

	#
	# process description
	#
	my $short_desc = encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" );
	my $long_desc = encode_entities( $env->{db}->get_long_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" );
	
	$long_desc =~ s,((ftp|http|https)://[\S~-]+?/?)((\&gt\;)?[)]?[']?[.\,]?(\s|$)),<a href=\"$1\">$1</a>$3,go; # syntax highlighting -> '];
	$long_desc =~ s/\A //o;
	$long_desc =~ s/\n /\n/sgo;
	$long_desc =~ s/\n.\n/\n<p>\n/go;
	$long_desc =~ s/(((\n|\A) [^\n]*)+)/\n<pre>$1\n<\/pre>/sgo;

	$long_desc = conv_desc( $env->{lang}, $long_desc );
	$short_desc = conv_desc( $env->{lang}, $short_desc );

	#
	# begin output
	#
	my $subdist_kw = $subdist || $env->{distribution};
	my $archive_kw = $archive || 'main';
	my $size_kw = exists $file_sizes{a2f}->{i386} ? $file_sizes{a2f}->{i386} : $file_sizes{max_unique};
	$size_kw = floor(($size_kw/102.4)+0.5)/10;
	my $package_page = header( title => $name, lang => $env->{lang},
				   desc => $short_desc,
				   keywords => "$env->{distribution}, $subdist_kw, $archive, $section, size:$size_kw $version" );
	$package_page .= "[&nbsp;".gettext( "Distribution:" )." <a title=\"".gettext( "Overview over this distribution" )."\" href=\"../\">$env->{distribution}</a>&nbsp;]\n";
	$package_page .= "[&nbsp;".gettext( "Section:" )." <a title=\"".gettext( "All packages in this section" )."\" href=\"../$section/\">$section</a>&nbsp;]\n";

	$package_page .= sprintf( "<h1>".gettext( "Package: %s (%s)" ),
				  $name, $v_str );

	my ( $is_security, $is_nonus ) = ( 0, 0 );
	if ( $subdist ) {
	    $package_page .=  " [<font color=\"red\">$subdist</font>]\n";
	    # a package can be in subdist "non-US/security"
	    # then both $is_nonus and $is_security are true
	    if ($subdist =~ /non-US/o) {
		$is_nonus = 1;
	    }
	    if ($subdist =~ /security/o) {
		$is_security = 1;
	    }
	}
	if ( $archive && ( $archive ne 'main' ) ) {
	    $package_page .=  " [<font color=\"red\">$archive</font>]\n";
	}
	$package_page .= "</h1>\n";

	$package_page .= "<h2>".gettext( "Versions:" )." $v_str_arch</h2>\n" 
	    unless $unique_version;

	if ($env->{distribution} eq "experimental") {
	    $package_page .= "<h2 style=\"color: red\">".
		gettext( "Experimental package")."</h2>\n<p>".
		gettext( "Warning: This package is from the <font color=\"red\">experimental</font> distribution. That means it is likely unstable or buggy, and it may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk.")."</p><p>".
		gettext( "Users of experimental packages are encouraged to contact the package maintainers directly in case of problems." )."</p>";
	}
	if ($archive eq "debian-installer") {
	    $package_page .= "<h2 style=\"color: red\">".
		gettext( "debian-installer udeb package")."</h2>\n<p>".
		gettext( "Warning: This package is intended for the use in building <a href=\"http://www.debian.org/devel/debian-installer\">debian-installer</a> images only. Do not install it on a normal Debian system." )."</p>";
	}
	$package_page .= "<h2><em>$short_desc</em></h2>\n";

	$package_page .= "<p style=\"text-align: justify\">$long_desc</p>\n";

	#
	# display dependencies
	#
	my $dep_list = print_deps( $env, $pkg, \%versions, 'depends' );
	$dep_list .= print_deps( $env, $pkg, \%versions, 'recommends' );
	$dep_list .= print_deps( $env, $pkg, \%versions, 'suggests' );

	if ( $dep_list ) {
	    $package_page .= sprintf( "\n<h2>".gettext( "Other packages related to %s:" )."</h2>\n", $name );
	    if ($env->{distribution} eq "experimental") {
		$package_page .= "<p>".gettext( "Note that the \"<font color=\"red\">experimental</font>\" distribution is not self-contained; missing dependencies are likely found in the \"<a href=\"../../unstable/\">unstable</a>\" distribution." )."</p>";
	    }

	    $package_page .= "<center><table border=\"1\"><tr>\n";
	    $package_page .= "<td><font size=\"-1\"><img src=\"../../Pics/dep.gif\" ALT=\"[req]\" WIDTH=\"16\" HEIGHT=\"16\">= ".gettext( 'depends' )."</font>".
		"<td><font size=\"-1\"><img src=\"../../Pics/rec.gif\" ALT=\"[rec]\" WIDTH=\"16\" HEIGHT=\"16\">= ".gettext( 'recommended' )."</font>".
		"<td><font size=\"-1\"><img src=\"../../Pics/sug.gif\" ALT=\"[sug]\" WIDTH=\"16\" HEIGHT=\"16\">= ".gettext( 'suggested' )."</font>";
	    $package_page .= "</table></center>\n";
	    $package_page .= "<table cellspacing=\"0\" cellpadding=\"2\">";
	    $package_page .= $dep_list;
	    $package_page .= "</table>";
	}

	#
	# Download package
	#
	my $encodedpack = uri_escape( $name );
	$package_page .= sprintf( "<h2>".gettext( "Download %s\n" )."</h2>",
				  $name ) ;
	$package_page .= "<table border=\"0\" summary=\"\">\n";
	$package_page .= "\n<tr><td></td>\n";
	foreach my $a ( @all_archs ) {
	    if ( exists $versions{a2v}->{$a} ) {
		$package_page .=  "<td align=\"center\" valign=\"top\"><form action=\"$DL_URL\" method=\"post\">\n";
		$package_page .=  "<input type=\"hidden\" name=\"file\" value=\"$filenames{a2f}->{$a}\">\n";
		$package_page .=  "<input type=\"hidden\" name=\"md5sum\" value=\"$file_md5s{a2f}->{$a}\">\n";
		$package_page .=  "<input type=\"hidden\" name=\"arch\" value=\"$a\">\n";
                # there was at least one package with two
                # different source packages on different
                # arches where one had a security update
                # and the other one not
		if ($subdists{a2f}{$a}
                    && ($subdists{a2f}{$a} =~ /security/o) ) {
		    $package_page .=  "<input type=\"hidden\" name=\"type\" value=\"security\">\n";
		} elsif ($is_nonus) {
		    $package_page .=  "<input type=\"hidden\" name=\"type\" value=\"nonus\">\n";
		} else {
		    $package_page .=  "<input type=\"hidden\" name=\"type\" value=\"main\">\n";
		}
		$package_page .=  "<input type=\"submit\" value=\" $a \">\n";
		if ( $env->{distribution} ne "experimental" ) {
		    $package_page .= "<br>".sprintf( "<small>[<a href=\"%s\">".gettext( "list of files" )."</a></small>]\n", "$FILELIST_URL$encodedpack&amp;version=$env->{distribution}&amp;arch=$a", $name );
		}
		$package_page .= "</form>\n";
		$package_page .= "</td>\n";
	    }
	}
	$package_page .= "</tr><tr>\n";
	$package_page .= "<th><small>".gettext( "Size:" )."</small></th>";
	foreach my $a ( @all_archs ) {
	    if ( exists $versions{a2v}->{$a} ) {
		my $size = floor(($file_sizes{a2f}->{$a}/102.4)+0.5)/10;
		$package_page .=  "<td align=\"center\" valign=\"top\"><small>$size</small></td>";
	    }
	}
	$package_page .= "</tr><tr>\n";
	$package_page .= "<th><small>".gettext( "Installed size:" )."</small></th>";
	foreach my $a ( @all_archs ) {
	    if ( exists $versions{a2v}->{$a} ) {
		my $inst_size = $inst_sizes{a2f}->{$a};
		$package_page .=  "<td align=\"center\" valign=\"top\"><small>$inst_size</small></td>";
	    }
	}
	$package_page .= "</tr></table>\n";
	$package_page .= "<p>".gettext ( "Size is measured in kBytes." )."</p>\n";


	#
	# more information
	#
	$package_page .= sprintf( "<h2>".gettext( "More information on %s" )."</h2>", $name );
	
	$package_page .= sprintf( "<small>".gettext( "Check for <a href=\"%s\">bug reports</a> about %s." )."</small><br>\n", $BUG_URL.$name, $name );
	
	#
	# Source package download
	#
	$package_page .= "<small>".gettext( "Source Package:" );
	$package_page .= " <a href=\"../source/$sourcepackage\">$sourcepackage</a>, ".gettext( "Download" ).":\n";

	my @source_files;
	if ( $src_pkg ) {
	    my $sf = $src_pkg->{versions}->{$src_version}->{files};
	    my $source_dir = $src_pkg->{versions}->{$src_version}->{directory};
	    $sf =~ s/\A\s*//o; # remove leading spaces
	    @source_files = split( /\n\s*/, $sf );
	    foreach( @source_files ) {
		my ($src_file_md5, $src_file_size, $src_file_name) = split( /\s+/, $_ );
		if ($is_security) {
		    $package_page .= "<a href=\"$env->{opts}->{security_site}/$source_dir/$src_file_name\">[";
		} elsif ($is_nonus) {
		    $package_page .= "<a href=\"$env->{opts}->{nonus_site}/$source_dir/$src_file_name\">[";
		} else {
		    $package_page .= "<a href=\"$env->{opts}->{debian_site}/$source_dir/$src_file_name\">[";
		}
		if (/dsc$/) {
		    $package_page .= "dsc";
		} else {
		    $package_page .= $src_file_name;
		}
		$package_page .= "]</a>\n";
	    }
	    $package_page .= sprintf( gettext( " (These sources are for version %s)\n" ), $src_version )
		if ($src_version ne $version) && !$src_version_given_in_control;
	} else {
	    $package_page .= gettext( "Not found" );
	    warn "W: no sources found for $name\n" if $env->{opts}{verbose};
	}
	$package_page .= "</small>\n";

	#
	# Changelog and copyright
	#
	if ( $src_pkg && ($env->{distribution} ne 'experimental')) {
	    my $source_dir = $src_pkg->{versions}->{$src_version}->{directory};
	    (my $src_basename = $src_version) =~ s,^\d+:,,; # strip epoche
	    $src_basename = "${sourcepackage}_$src_basename";
	    $source_dir =~ s,pool/updates,pool,o;
	    $source_dir =~ s,pool/non-US,pool,o;
	    $package_page .= "<br><small>".sprintf( gettext( "View the <a href=\"%s\">Debian changelog</a>" ), "$CHANGELOG_URL/$source_dir/$src_basename/changelog" )."</small><br>\n";
	    $package_page .= "<small>".sprintf( gettext( "View the <a href=\"%s\">copyright file</a>" ), "$COPYRIGHT_URL/$source_dir/$src_basename/$name.copyright" )."</small><br>\n";
	}

	#
	# Maintainer and PTS
	#
	$maint_name =~ s/\s+$//o;
	unless (@uploaders) {
	    $package_page .= sprintf( "<p><small>".
				      gettext( "%s is responsible for this Debian package." ).
				      "</small>\n", 
				      "<a href=\"mailto:$maint_email\">$maint_name</a>" 
				      );
	} else {
	    my $up_str = "<a href=\"mailto:$maint_email\">$maint_name</a> ";
	    my @uploaders_str;
	    foreach (@uploaders) {
		push @uploaders_str, "<a href=\"mailto:$_->[1]\">$_->[0]</a>";
	    }
	    my $last_up = pop @uploaders_str;
	    $up_str .= ", ".join ", ", @uploaders_str if @uploaders_str;
	    $up_str .= sprintf( gettext( " and %s are responsible for this Debian package." ), $last_up );
	    $package_page .= "<p><small>$up_str</small>\n";
	}

	$package_page .= sprintf( "<small>".gettext( "See the <a href=\"%s\">developer information for %s</a>." )."</small>\n", $QA_URL.$sourcepackage, $name );
	
	$package_page .= sprintf( "<p><small>".gettext( "Search for <a href=\"%s\">other versions of %s</a>" )."</small>\n", $SEARCH_URL.$encodedpack, $name );

	#
	# Trailer
	#
	my @tr_langs = ();
	foreach my $l (@{$env->{all_langs}}) {
	    next if $l eq $env->{lang};
	    push @tr_langs, $l if ( $l eq 'en' ) 
		|| $env->{db}->is_translated( $name, $version, 
					      ${$versions{v2a}->{$version}}[0],
					      $l );
	}
	$package_page .= trailer( '../..', $name, $env->{lang}, @tr_langs );
	
	#
	# write file
	#
	$files->update_file( $filename, $package_page );

	#
	# create data sheet
	#
	if ($env->{lang} eq 'en') {

	    my $data_sheet = header( title => "$name -- Data sheet",
				     lang => "en",
				     desc => $short_desc,
				     keywords => "$env->{distribution}, $subdist_kw, $archive, $section, size:$size_kw $version" );	    
	    $data_sheet .= "<div align=\"center\"><h1>$name";
	    if ( $subdist ) {
		$data_sheet .=  " [<font color=\"red\">$subdist</font>]\n";
	    }
	    if ( $archive && ( $archive ne 'main' ) ) {
		$data_sheet .=  " [<font color=\"red\">$archive</font>]\n";
	    }
	    $data_sheet .= "</h1></div>\n";

	    $data_sheet .= "<table><tbody>";
	    $data_sheet .= "<tr><td>".gettext( "Version" ).":</td>\n".
		"<td>$v_str</td></tr>";
	    $data_sheet .= "<tr><td>".gettext( "Maintainer" ).":</td>\n"
		."<td><a href=\"$DDPO_URL".uri_escape($maint_email)."\">$maint_name</a></td></tr>";
	    if (@uploaders) {
		$data_sheet .= "<tr><td>".gettext( "Uploaders" ).":</td>\n";
		my @uploaders_str;
		foreach (@uploaders) {
		    push @uploaders_str, "<a href=\"$DDPO_URL".uri_escape($_->[1])."\">$_->[0]</a>";
		}
		$data_sheet .= "<td>".join( ", ", @uploaders_str )."</td></tr>";
	    }	    
	    $data_sheet .= "<tr><td>".gettext( "Section" ).":</td>\n".
		"<td><a href=\"../$section/\">$section</a></td></tr>";
	    $data_sheet .= "<tr><td>".gettext( "Priority" ).":</td>\n".
		"<td><a href=\"../$priority\">$priority</a></td></tr>";
	    $data_sheet .= "<tr><td>".gettext( "Essential" ).":</td>\n".
		"<td><a href=\"../essential\">".gettext("yes")."</a></td></tr>"
		if $essential && ( $essential =~ /yes/i );
	    $data_sheet .= "<tr><td>".gettext( "Source package" ).":</td>\n"
		."<td><a href=\"../source/$sourcepackage\">$sourcepackage</a></td></tr>";
	    $data_sheet .= print_deps_ds( $env, $pkg, \%versions, 'Depends' );
	    $data_sheet .= print_deps_ds( $env, $pkg, \%versions, 'Recommends' );
	    $data_sheet .= print_deps_ds( $env, $pkg, \%versions, 'Suggests' );
	    $data_sheet .= print_deps_ds( $env, $pkg, \%versions, 'Enhances' );
	    $data_sheet .= print_deps_ds( $env, $pkg, \%versions, 'Conflicts' );
	    $data_sheet .= print_deps_ds( $env, $pkg, \%versions, 'Provides' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Depends' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Recommends' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Suggests' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Enhances' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Provides' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Conflicts' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Build-Depends' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Build-Depends-Indep' );
	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Build-Conflicts' );

#	    if ( $name eq 'libc6' ) {
#		use Data::Dumper;
#		print STDERR Dumper( $pkg );
#	    }

	    $data_sheet .= "</tbody></table>";
	    
	    $data_sheet .= trailer( '../..', $name );

	    my $ds_filename = "$dirname/ds_$name.$env->{lang}.html";
	    #
	    # write file
	    #
	    $files->update_file( $ds_filename, $data_sheet );
	}
    }

sub src_package_pages_walker {
    my ( $pkg, $env ) = @_;
    
    my $name = $pkg->get_name;
    
    #
    # get information
    #
    my @versions = $pkg->get_version_list();
    my $v_str = $versions[0];
    my $v_pkg = $pkg->get_version( $v_str );
    
    my $subdist = $v_pkg->{subdistribution};
    my $archive = $v_pkg->{archive};
    
    my $binaries = $v_pkg->{binary};

    my $dirname = "$env->{dest_dir}/source";
    my $filename = "$dirname/$name.html";
    
    progress() if $env->{opts}{progress};
    
    #
    # process maintainer and uploaders
    #
    my ( $maint_name, $maint_email ) = split_name_mail( $v_pkg->{maintainer} );
    my @uploaders;
    if (exists $v_pkg->{uploaders}) {
	@uploaders = split( /\s*,\s*/, 
			    $v_pkg->{uploaders} );
	foreach (@uploaders) {
	    $_ = [ split_name_mail( $_ ) ];
	}
    }

    #
    # begin output
    #
    my $subdist_kw = $subdist || $env->{distribution};
    my $archive_kw = $archive || 'main';
    
    my $package_page = header( title => $name, lang => 'en',
			       keywords => "$env->{distribution}, $subdist_kw, $archive, $v_str" );
    $package_page .= "[&nbsp;".gettext( "Distribution:" )." <a title=\"".gettext( "Overview over this distribution" )."\" href=\"../\">$env->{distribution}</a>&nbsp;]\n";
#	$package_page .= "[&nbsp;".gettext( "Section:" )." <a title=\"".gettext( "All packages in this section" )."\" href=\"../$section/\">$section</a>&nbsp;]\n";
    
    $package_page .= sprintf( "<h1>".gettext( "Source package: %s (%s)" ),
			      $name, $v_str );
    
    my ( $is_security, $is_nonus ) = ( 0, 0 );
    if ( $subdist ) {
	$package_page .=  " [<font color=\"red\">$subdist</font>]\n";
	# a package can be in subdist "non-US/security"
	# then both $is_nonus and $is_security are true
	if ($subdist =~ /non-US/o) {
	    $is_nonus = 1;
	}
	if ($subdist =~ /security/o) {
	    $is_security = 1;
	}
    }
    if ( $archive && ( $archive ne 'main' ) ) {
	$package_page .=  " [<font color=\"red\">$archive</font>]\n";
    }
    $package_page .= "</h1>\n";

    if ($env->{distribution} eq "experimental") {
	$package_page .= "<h2 style=\"color: red\">".
	    gettext( "Experimental package")."</h2>\n<p>".
	    gettext( "Warning: This package is from the <font color=\"red\">experimental</font> distribution. That means it is likely unstable or buggy, and it may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk.")."</p><p>".
	    gettext( "Users of experimental packages are encouraged to contact the package maintainers directly in case of problems." )."</p>";
    }
    if ($archive eq "debian-installer") {
	$package_page .= "<h2 style=\"color: red\">".
	    gettext( "debian-installer udeb package")."</h2>\n<p>".
	    gettext( "Warning: This package is intended for the use in building <a href=\"http://www.debian.org/devel/debian-installer\">debian-installer</a> images only. Do not install it on a normal Debian system." )."</p>";
    }

    my @bin_list;
    foreach my $bp ( sort { $a->[0][0] cmp $b->[0][0] } @$binaries ) {
	my $p_name = $bp->[0][0];
	my $p = $env->{db}->get_pkg( $p_name );
	if ($p) {
	    # there are actually packages that list packages
	    # in their Binary field that are never built but
	    # exist as virtual packages -- no commment...
	    if ($p->is_virtual) {
		push @bin_list, "<tr><td><a href=\"../virtual/$p_name\">$p_name</a></td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;".gettext("Virtual package")."</td></tr>";
	    } else {
		my %sections = $p->get_arch_fields( 'section',
						    $env->{archs} );
		my $section = $sections{max_unique} || "";
		my %desc_md5s = $p->get_arch_fields( 'description-md5', 
						     $env->{archs} );
		my $short_desc = conv_desc( $env->{lang}, encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" ) );
		push @bin_list, "<tr><td><a href=\"../$section/$p_name\">$p_name</a></td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc</td></tr>";
	    }
	}
    }
    if (@bin_list) {
	$package_page .= gettext( "The following binary packages are build from this source package:" );
	$package_page .= "<table cellspacing=\"0\" cellpadding=\"2\">";
	$package_page .= join "\n", @bin_list;
	$package_page .= "</table>";
    }

    #
    # display dependencies
    #
    my $dep_list = print_src_deps( $env, $pkg, $v_str, 'build-depends' );
    $dep_list .= print_src_deps( $env, $pkg, $v_str, 'build-depends-indep' );

    if ( $dep_list ) {
	$package_page .= sprintf( "\n<h2>".gettext( "Other packages related to %s:" )."</h2>\n", $name );
	if ($env->{distribution} eq "experimental") {
	    $package_page .= "<p>".gettext( "Note that the \"<font color=\"red\">experimental</font>\" distribution is not self-contained; missing dependencies are likely found in the \"<a href=\"../../unstable/\">unstable</a>\" distribution." )."</p>";
	}

	$package_page .= "<center><table border=\"1\"><tr>\n";
	$package_page .= "<td><font size=\"-1\"><img src=\"../../Pics/dep.gif\" ALT=\"[req]\" WIDTH=\"16\" HEIGHT=\"16\">= ".gettext( 'build-depends' )."</font>".
	    "<td><font size=\"-1\"><img src=\"../../Pics/rec.gif\" ALT=\"[rec]\" WIDTH=\"16\" HEIGHT=\"16\">= ".gettext( 'build-depends-indep' )."</font>";
	$package_page .= "</table></center>\n";
	$package_page .= "<table cellspacing=\"0\" cellpadding=\"2\">";
	$package_page .= $dep_list;
	$package_page .= "</table>";
    }

    #
    # Source package download
    #
    my $encodedpack = uri_escape( $name );
    $package_page .= sprintf( "<h2>".gettext( "Download %s" )."</h2>\n",
			      $name ) ;
    
    my $sf = $v_pkg->{files};
    my $source_dir = $v_pkg->{directory};
    $sf =~ s/\A\s*//o; # remove leading spaces
    my @source_files = split( /\n\s*/, $sf );
    $package_page .= sprintf( "<table cellspacing=\"0\" cellpadding=\"2\">\n"
			      ."<tr><th>%s</th><th>%s</th><th>%s</th>",
			      gettext("File"),
			      gettext("Size (in kB)"),
			      gettext("md5sum") );
    foreach( @source_files ) {
	my ($src_file_md5, $src_file_size, $src_file_name) = split( /\s+/, $_ );
	my $src_url = "$env->{opts}{debian_site}/$source_dir/$src_file_name";
	if ($is_security) {
	    $src_url = "$env->{opts}{security_site}/$source_dir/$src_file_name";
	} elsif ($is_nonus) {
	    $src_url = "$env->{opts}{nonus_site}/$source_dir/$src_file_name";
	}
	
	$package_page .= "<tr><td><a href=\"$src_url\">$src_file_name</a></td>\n"
	    ."<td align=\"right\">".(floor(($src_file_size/102.4)+0.5)/10)."</td>\n"
	    ."<td>$src_file_md5</td></tr>";
    }
    $package_page .= "</table>\n";

    #
    # more information
    #
    $package_page .= sprintf( "<h2>".gettext( "More information on %s" )."</h2>", $name );
    
    $package_page .= sprintf( "<small>".gettext( "Check for <a href=\"%s\">bug reports</a> about %s" )."</small><br>\n", $SRC_BUG_URL.$name, $name );
    
    #
    # Changelog and copyright
    #
    if ( $env->{distribution} ne 'experimental' ) {
	my $source_dir = $v_pkg->{directory};
	(my $src_basename = $v_str) =~ s,^\d+:,,; # strip epoche
	$src_basename = "${name}_$src_basename";
	$source_dir =~ s,pool/updates,pool,o;
	$source_dir =~ s,pool/non-US,pool,o;
	$package_page .= "<br><small>".sprintf( gettext( "View the <a href=\"%s\">Debian changelog</a>" ), "$CHANGELOG_URL/$source_dir/$src_basename/changelog" )."</small><br>\n";
	$package_page .= "<small>".sprintf( gettext( "View the <a href=\"%s\">copyright file</a>" ), "$CHANGELOG_URL/$source_dir/$src_basename/copyright" )."</small><br>\n";
    }
    
    #
    # Maintainer and PTS
    #
    $maint_name =~ s/\s+$//o;
    unless (@uploaders) {
	$package_page .= sprintf( "<p><small>".
				  gettext( "%s is responsible for this Debian package." ).
				  "</small>\n", 
				  "<a href=\"mailto:$maint_email\">$maint_name</a>" 
				  );
    } else {
	my $up_str = "<a href=\"mailto:$maint_email\">$maint_name</a> ";
	foreach (@uploaders) {
	    $_ = "<a href=\"mailto:$_->[1]\">$_->[0]</a>";
	}
	my $last_up = pop @uploaders;
	$up_str .= ", ".join ", ", @uploaders if @uploaders;
	$up_str .= sprintf( gettext( " and %s are responsible for this Debian package." ), $last_up );
	$package_page .= "<p><small>$up_str</small>\n";
    }

    $package_page .= sprintf( "<small>".gettext( "See the <a href=\"%s\">developer information for %s</a>." )."</small>\n", $QA_URL.$name, $name );
    
    $package_page .= sprintf( "<p><small>".gettext( "Search for <a href=\"%s\">other versions of %s</a>" )."</small>\n", $SRC_SEARCH_URL.$encodedpack, $name );

    #
    # Trailer
    #
    $package_page .= trailer( '../..', $name, 'en' );
	
    #
    # write file
    #
    $files->update_file( $filename, $package_page );
}

sub write_pages {
	my ( $db, $opts, $dist, $archs, $langs ) = @_;

	$db->lock;
	$db->build_cache( @$archs );
	my $dest_dir = $opts->{html_root};
	$files = Packages::OutputFiles->init;
	$files->load_file_list( $opts->{md5file} );
	unless ( @$langs ) {
	    $langs = [ "en" ];
	}
	unless ( $opts->{quiet} ) {
	    print "=" x 10 . "\n";
	    print "writing package pages for distribution $dist\n";
	}
	my $num_descs = $db->get_stats_val( 'num_descriptions' );
	my %sections = create_sections();
	my %priorities = create_priorities();
	foreach my $l ( @$langs ) {
	    my $locale = get_locale($l);
	    print "processing language $l (locale $locale)\n" unless $opts->{quiet};
	    setlocale ( LC_ALL, $locale )
		or do { warn "W: could not set locale, using default\n" unless $opts->{quiet};
			setlocale( LC_ALL, get_locale() ) 
			    or do {
				# Do not skip this so the pages can benefit from DDTP at least
			    	warn "W: could not set locale, using C\n" unless $opts->{quiet};
				setlocale( LC_ALL, "C" );
			};
		    };
	    print "writing distribution indices\n" unless $opts->{quiet};
	    $p_counter = 0;
	    write_all_package( $db, \%sections, \%priorities, $archs, 
			       $dest_dir, $dist, $l, $opts, $langs );
	    print "\n" if $opts->{progress};
	    print "writing pages for individual packages\n" unless $opts->{quiet};
	    $p_counter = 0;
	    walk_db_packages( $db, &package_pages_walker,
			      { db => $db, lang => $l,
				all_langs => $langs,
				dest_dir => $dest_dir,
				distribution => $dist,
				archs => $archs,
				opts => $opts } );
	    print "\n" if $opts->{progress};
	    if ($l eq 'en') {
		print "writing source package index\n" unless $opts->{quiet};
		$p_counter = 0;
		write_src_index( $db, $dest_dir, $dist, $l, $opts, $langs );
		print "\n" if $opts->{progress};
		
		print "writing pages for individual source packages\n" unless $opts->{quiet};
		$p_counter = 0;
		walk_db_src_packages( $db, &src_package_pages_walker,
				      { db => $db,
					dest_dir => $dest_dir,
					distribution => $dist,
					opts => $opts } );
		print "\n" if $opts->{progress};
	    }
	}
	
	$files->write_file_list( $opts->{md5file} );
    }

sub write_all_package {
	my ( $db, $sections, $priorities, $archs, $dest_dir, 
	     $distro, $lang, $opts, $langs ) = @_;

	my %si = ();
	my %pi = ();
	my $ei = "";
	my $experimental_note = "<p>".gettext( "Warning: The <font color=\"red\">experimental</font> distribution contains software that is likely unstable or buggy and may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk." )."</p>\n";
	my $installer_note = "<p>".gettext( "Warning: These packages are intended for the use in building <a href=\"http://www.debian.org/devel/debian-installer/\">debian-installer</a> images only. Do not install them on a normal Debian system.")."</p>";

	foreach ( keys %$sections ) {
	    my $title = sprintf( gettext ( "Software Packages in \"%s\", %s section" ), 
				 $distro, $_ );
	    $si{$_} = header( title => $title, lang => $lang,
			      print_title_below => 1 );
	    if ($distro eq "experimental") {
		$si{$_} .= $experimental_note;
	    }
	    if ($_ eq 'debian-installer') {
		$si{$_} .= $installer_note;
	    }
	    $si{$_} .= "<dl>\n";
	}

	my @priorities = sorted_priorities();
	foreach ( @priorities ) {
	    my $priority_header;
	    foreach my $hp ( @priorities ) {
		if ( $hp ne $_ ) {
		    $priority_header .= "[<a href=\"$hp\">$hp</a>]&nbsp;";
		} else {
		    $priority_header .= "[$hp]&nbsp;";
		}
	    }
	    my $title = sprintf( gettext ( "Software Packages in \"%s\", priority %s" ), 
				 $distro, $_ );
	    $pi{$_} = header( title => $title, lang => $lang );
	    $pi{$_} .= "$priority_header\n";
	    $pi{$_} .= "<h1>$title</h1>\n";
	    if ($distro eq "experimental") {
		$pi{$_} .= $experimental_note;
	    }
	    $pi{$_} .= "<dl>\n";
	}
	if ($distro ne 'experimental') {
            # no index of essential packages for experimental
	    my $title = sprintf( gettext ( "Software Packages in \"%s\", essential packages" ), 
				 $distro );
	    $ei .= header( title => $title, lang => $lang,
			   print_title_below => 1 );
	    $ei .= "<dl>\n";
	}

	my $all_title = sprintf( gettext( "All Debian Packages in \"%s\"" ),
				 $distro );
	my $all_package = header( title => $all_title, lang => $lang,
				  print_title_below => 1 );
	if ($distro eq "experimental") {
	    $all_package .= $experimental_note;
	}
	$all_package .= "<dl>\n";

	my $all_pkg_txt = sprintf( gettext( "All Debian Packages in \"%s\"" )."\n\n", $distro );
	$all_pkg_txt .=  gettext( "Last Modified: " ). "LAST_MODIFIED_DATE\n".
	    gettext( "Copyright (c) 1997-2003 SPI;\nSee <URL:http://www.debian.org/license> for the license terms.\n\n" );

	walk_db_packages( $db, &package_index_walker, 
			  { all_package => \$all_package, db => $db,
			    all_pkg_txt => \$all_pkg_txt, opts => $opts,
			    lang => $lang, si => \%si, pi => \%pi,
			    ei => \$ei, archs => $archs } );

	foreach ( keys %$sections ) {
	    $si{$_} .= "</dl>\n";
	    $si{$_} .= trailer( '..', 'index', $lang, @$langs );
	    my $dirname = "$dest_dir/$_";
	    my $filename = "$dirname/index.$lang.html";
	    $files->update_file( $filename, $si{$_} );
	}
	foreach ( keys %$priorities ) {
	    $pi{$_} .= "</dl>\n";
	    $pi{$_} .= trailer( '..', $_, $lang, @$langs );
	    my $dirname = "$dest_dir";
	    my $filename = "$dirname/$_.$lang.html";
	    $files->update_file( $filename, $pi{$_} );
	}
	if ($distro ne 'experimental') {
	    $ei .= "</dl>\n";
	    $ei .= trailer( '..', 'essential', $lang, @$langs );
	    my $dirname = "$dest_dir";
	    my $filename = "$dirname/essential.$lang.html";
	    $files->update_file( $filename, $ei );
	}
	
	$all_package .= "</dl>\n";
	$all_package .= trailer( '..', 'allpackages', $lang, @$langs );

	my $filename = "$dest_dir/allpackages.$lang.html";
	$files->update_file( $filename, $all_package );
	$filename = "$dest_dir/allpackages.$lang.txt.gz";
	$files->update_gz_file( $filename, $all_pkg_txt );
}

sub write_src_index {
    my ( $db, $dest_dir, $distro, $lang, $opts, $langs ) = @_;
    
    my $source_index;
    my $experimental_note = "<p>".gettext( "Warning: The <font color=\"red\">experimental</font> distribution contains software that is likely unstable or buggy and may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk." )."</p>\n";
    
    my $title = sprintf( gettext ( "Source Packages in \"%s\"" ), 
			 $distro, $_ );
    $source_index = header( title => $title, lang => $lang,
			    print_title_below => 1 );
    if ($distro eq "experimental") {
	$source_index .= $experimental_note;
    }
    $source_index .= "<dl>\n";
    
    walk_db_src_packages( $db, &src_package_index_walker, 
			  { source_index => \$source_index, db => $db,
			    opts => $opts, lang => $lang } );

    $source_index .= "</dl>\n";
    $source_index .= trailer( '..', 'index', $lang, @$langs );
    my $dirname = "$dest_dir/source";
    my $filename = "$dirname/index.$lang.html";
    $files->update_file( $filename, $source_index );
}

1;
