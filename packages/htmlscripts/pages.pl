require 5.006;

use strict;
use warnings;

use POSIX;
use HTML::Entities;
use Compress::Zlib;
use Data::Dumper;
use URI::Escape;
use Text::Iconv;
Text::Iconv->raise_error(0); # do not throw exeptions

use Packages::HTML;
use Packages::I18N::Locale;
use Deb::Versions;

require( 'sections.pl' );

my $CHANGELOG_URL = 'http://people.debian.org/~noel/changelogs';
my $CHANGELOG_UPSTREAM_URL = 'http://packages.debian.org/cgi-bin/get-changelog-upstream?package=';
my $COPYRIGHT_URL = 'http://people.debian.org/~noel/changelogs';
my $FILELIST_URL = 'http://packages.debian.org/cgi-bin/search_contents.pl?searchmode=filelist&amp;word=';
my $SEARCH_URL = 'http://packages.debian.org/cgi-bin/search_packages.pl?searchon=names&amp;keywords=';
my $BUG_URL = 'http://bugs.debian.org/';
my $QA_URL = 'http://packages.qa.debian.org/';
my $DL_URL = 'http://packages.debian.org/cgi-bin/download.pl';
my $POLICY_URL = 'http://www.debian.org/doc/debian-policy/';

my %md5s;
my %converters = (
		 "UTF-82ISO-8859-1" => Text::Iconv->new("UTF-8", "ISO-8859-1"),
		 "UTF-82ISO-8859-2" => Text::Iconv->new("UTF-8", "ISO-8859-2"),
		 "UTF-82KOI8-U" => Text::Iconv->new("UTF-8", "KOI8-U"),
		 );

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

sub package_index_walker {
	my $pkg = shift;
	my $env = shift;
	my ( $str, $txt_str );

	progress() if $env->{opts}{progress};
	my $name = $pkg->get_name;

	if ( $pkg->is_virtual ) { return; }

	my %versions = $pkg->get_arch_versions( $env->{archs} );
	my %desc_md5s = $pkg->get_arch_fields( 'description-md5', 
					       $env->{archs} );
	my %sections = $pkg->get_arch_fields( 'section', 
					      $env->{archs} );
	my %archives = $pkg->get_arch_fields( 'archive', 
					      $env->{archs} );
	my %subdists = $pkg->get_arch_fields( 'subdistribution', 
					      $env->{archs} );

	my $txt_desc = $env->{db}->get_short_desc( $desc_md5s{max_unique}, 
						   $env->{lang} );
	my $desc = encode_entities( $txt_desc, "<>&\"" );

	my ( $version, $section, $archive, $subdist );
	$version = ($pkg->get_version_list)[0];
	$section = $sections{max_unique};
	$archive = $archives{max_unique}
	    if exists $archives{max_unique};
	$subdist = $subdists{max_unique} 
	    if exists $subdists{max_unique};

	my ( @v_str, $v_str );
#	foreach ( ( $pkg->get_version_list ) ) {
	if ( scalar keys %{$versions{unique}} == 1 ) {
	    $v_str = "($version)";
	} else {
	    foreach ( version_sort( keys %{$versions{unique}} ) ) {
		push @v_str, "$_ [".join( ", ", @{$versions{v2a}->{$_}} )."]";
	    }
	    $v_str = "(".join( ", ", @v_str ).")";
	}


	$str = "<dt><a href=\"$name\">".
	    "$name</a> $v_str";
	$txt_str = "$name $v_str";
	if ( $archive && ( $archive ne 'main' ) ) {
	    $str .=  " [<font color=\"red\">$archive</font>]\n";
	    $txt_str .= " [$archive]";
	}
	if ( $subdist ) {
	    $str .=  " [<font color=\"red\">$subdist</font>]\n";
	    $txt_str .=  " [$subdist]";
	}
	$str .= "</dt>\n     <dd>$desc</dd>\n";
	$txt_str .= " $txt_desc\n";
	${$env->{all_package}} .= $str;
	${$env->{all_pkg_txt}} .= $txt_str;
	$env->{si}->{$section} .= $str if $section;
    }

sub print_virt_pack {
    my ( $pkg, $env ) = @_;

    my $name = $pkg->get_name;

    my $package_page = header( $name, '../..', '../..', 
			       $env->{lang}, gettext( "virtual package" ),
			       "$env->{distribution}, virtual, virtual, virtual, size:0 virtual" );
    $package_page .= sprintf( gettext( "<h1>Virtual Package: %s</h1>" ), 
			      $name );

    $package_page .= gettext( "<p>This is a <em>virtual package</em>. See the <a href=\"$POLICY_URL\">Debian policy</a> for a <a href=\"${POLICY_URL}ch-binary.html#s-virtual_pkg\">definition of virtual packages</a>.</p>\n" );

    $package_page .= sprintf( gettext( "<h2>Packages providing %s:</h2>" ),
			      $name );
    $package_page .= "<dl>\n";
    foreach my $p ( @{$pkg->{provided_by}} ) {
	my $p_pkg = $env->{db}->get_pkg( $p );

	if ( $p_pkg ) {
	    my %sections = $p_pkg->get_arch_fields( 'section',
						    $env->{archs} );
	    my $section = $sections{max_unique};
	    my %desc_md5s = $p_pkg->get_arch_fields( 'description-md5', 
						     $env->{archs} );
	    my $short_desc = encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" );
	    $package_page .= "<dt><a href=\"../$section/$p\">$p</a></dt>\n".
		"\t<dd>$short_desc</dd>\n";
	} else { die "$p"; } #FIXME
    }
    $package_page .= "</dl>\n";
    $package_page .= trailer( '../..' );
    
    my $dirname = "$env->{dest_dir}/virtual";
    unless ( -d $dirname ) {
	mkdir $dirname or die "Can\'t create dir $dirname: $!";
    }
    
    #
    # write file
    #
    my $now_time = time_stamp();
    my $filename = "$dirname/$name.$env->{lang}.html";
    if ( file_changed( \%md5s, $filename, $package_page ) ) {
	sysopen(FILEH_VPACK, $filename, 
		O_WRONLY | O_TRUNC | O_CREAT, 0664) 
	    || die "Can\'t open file $filename: $!";
	$package_page =~ s/LAST_MODIFIED_DATE/$now_time/;
	print FILEH_VPACK $package_page;
	close FILEH_VPACK;
    }
}

sub split_name_mail {
    my $string = shift;
    my ( $name, $email );
    if ($string =~ /(.*)\s*<(.*)>/o) {
	$name =  $1;
	$email = $2;
    } elsif ($string =~ /^[\w.-]*@[\w.-]*$/o) {
	$name =  $string;
	$email = $string;
    } else {
	$name = gettext( 'package has bad maintainer field' );
	$email = '';
    }
    return ($name, $email);
}

sub package_pages_walker {
	my ( $pkg, $env ) = @_;

	my $name = $pkg->get_name;
	my $fl = substr $name, 0, 1;
	my $sl = substr $name, 0, 2;

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
	return unless (( $env->{lang} eq 'en' ) 
		       || $env->{db}->is_translated( $name, $version,
						     ${$versions{v2a}->{$version}}[0],
						     $env->{lang} ));
	progress() if $env->{opts}{progress};

	my %desc_md5s = $pkg->get_arch_fields( 'description-md5', 
					       $env->{archs} );
	my %sections = $pkg->get_arch_fields( 'section', 
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
	my ( $section, $archive, 
	     $sourcepackage, $src_version, $subdist, $maintainer );
	$section = $sections{max_unique};
	$maintainer = $maintainers{max_unique};
	$sourcepackage = $sources{max_unique};
	if ( $sourcepackage =~ s/\s*\((.*)\)\s*$//o ) {
	    $src_version = $1;
	} else {
	    $src_version = $version;
	}
	my $src_pkg = $env->{db}->get_src_pkg( $sourcepackage );
	if ( $src_pkg && !exists $src_pkg->{versions}->{$src_version} ) {
	    $src_version = ($src_pkg->get_version_list)[0];
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
	
	# we assume that all descriptions are in UTF-8 and convert them
	# if necessary
	my $cs = get_charset($env->{lang});
	if (($cs ne "UTF-8")
	    && exists $converters{"UTF-82$cs"}) {
	    my $ld_tmp = $converters{"UTF-82$cs"}->convert($long_desc);
	    my $sd_tmp = $converters{"UTF-82$cs"}->convert($short_desc);
	    if ($ld_tmp && $sd_tmp) {
		$long_desc = $ld_tmp;
		$short_desc = $sd_tmp;
	    } else {
		if ($env->{opts}{verbose}) {
		    warn "W: $name: error while converting description\n"; 
		}
		if ($env->{opts}{debug}) {
		    warn "$short_desc\n$long_desc\n";
		}
	    }
	}

	#
	# begin output
	#
	my $subdist_kw = $subdist || $env->{distribution};
	my $archive_kw = $archive || 'main';
	my $size_kw = exists $file_sizes{a2f}->{i386} ? $file_sizes{a2f}->{i386} : $file_sizes{max_unique};
	$size_kw = floor(($size_kw/102.4)+0.5)/10;
	my $package_page = header( $name, '../../..', '../../..', 
				   $env->{lang}, $short_desc,
				   "$env->{distribution}, $subdist_kw, $archive, $section, size:$size_kw $version" );
	$package_page .= "[&nbsp;".gettext( "Distribution:" )." <a title=\"".gettext( "Overview over this distribution" )."\" href=\"../../\">$env->{distribution}</a>&nbsp;]\n";
	$package_page .= "[&nbsp;".gettext( "Section:" )." <a title=\"".gettext( "All packages in this section" )."\" href=\"../../$section\">$section</a>&nbsp;]\n";

	$package_page .= sprintf( gettext( "<h1>Package: %s (%s)" ),
				  $name, $v_str );
	if ( $subdist ) {
	    $package_page .=  " [<font color=\"red\">$subdist</font>]\n";
	}
	if ( $archive && ( $archive ne 'main' ) ) {
	    $package_page .=  " [<font color=\"red\">$archive</font>]\n";
	}
	$package_page .= "</h1>\n";

	$package_page .= "<h2>".gettext( "Versions:" )." $v_str_arch</h2>\n" 
	    unless $unique_version;

	if ($env->{distribution} eq "experimental") {
	    $package_page .= gettext( "<h2 style=\"color: red\">Experimental package</h2>\n".
				      "<p>Warning: This package is from the <font color=\"red\">experimental</font> distribution. That means it is likely unstable or buggy, and it may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk.</p>".
				      "<p>Users of experimental packages are encouraged to contact the package maintainers directly in case of problems.</p>" );
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
	    $package_page .= sprintf( gettext( "\n<h2>Other packages related to %s:</h2>\n" ), $name );
	    if ($env->{distribution} eq "experimental") {
		$package_page .= gettext( "<p>Note that the \"<font color=\"red\">experimental</font>\" distribution is not self-contained; missing dependencies are likely found in the \"<a href=\"../../../unstable\">unstable</a>\" distribution.</p>" );
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
	$package_page .= sprintf( gettext( "<h2>Download %s</h2>\n" ),
				  $name ) ;
	$package_page .= "<table border=\"0\" summary=\"\">\n";
	$package_page .= "\n<tr><td></td>\n";
	foreach my $a ( @all_archs ) {
	    if ( exists $versions{a2v}->{$a} ) {
		$package_page .=  "<td align=\"center\" valign=\"top\"><form action=\"$DL_URL\" method=\"post\">\n";
		$package_page .=  "<input type=\"hidden\" name=\"file\" value=\"$filenames{a2f}->{$a}\">\n";
		$package_page .=  "<input type=\"hidden\" name=\"md5sum\" value=\"$file_md5s{a2f}->{$a}\">\n";
		$package_page .=  "<input type=\"hidden\" name=\"arch\" value=\"$a\">\n";
		if ($env->{distribution} =~ /non-us/o) {
		    $package_page .=  "<input type=\"hidden\" name=\"type\" value=\"nonus\">\n";
		} elsif ($env->{distribution} =~ /updates/o) {
		    $package_page .=  "<input type=\"hidden\" name=\"type\" value=\"security\">\n";
		} else {
		    $package_page .=  "<input type=\"hidden\" name=\"type\" value=\"main\">\n";
		}
		$package_page .=  "<input type=\"submit\" value=\" $a \">\n";
		if ( $env->{distribution} ne "experimental" ) {
		    $package_page .= "<br>".sprintf( gettext( "<small>[<a href=\"%s\">list of files</a></small>]\n" ), "$FILELIST_URL$encodedpack&amp;version=$env->{distribution}&amp;arch=$a", $name );
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
		$package_page .=  "<td align=\"center\" valign=\"top\"><small>$size kBytes</small></td>";
	    }
	}
	$package_page .= "</tr><tr>\n";
	$package_page .= "<th><small>".gettext( "Installed size:" )."</small></th>";
	foreach my $a ( @all_archs ) {
	    if ( exists $versions{a2v}->{$a} ) {
		my $inst_size = $inst_sizes{a2f}->{$a};
		$package_page .=  "<td align=\"center\" valign=\"top\"><small>$inst_size kBytes</small></td>";
	    }
	}
	$package_page .= "</tr></table>\n";

	#
	# more information
	#
	$package_page .= sprintf( gettext( "<h2>More information on %s</h2>" ), $name );
	
	$package_page .= sprintf( gettext( "<small>Check for <a href=\"%s\">bug reports</a> about %s</small><br>\n" ), $BUG_URL.$name, $name );
	
	#
	# Source package download
	#
	$package_page .= gettext( "<small>Source Code:\n" );

	if ( $src_pkg ) {
	    my $sf = $src_pkg->{versions}->{$src_version}->{files};
	    my $source_dir = $src_pkg->{versions}->{$src_version}->{directory};
	    $sf =~ s/\A\s*//o; # remove leading spaces
	    my @source_files = split( /\n\s*/, $sf );
	    foreach( @source_files ) {
		my ($src_file_md5, $src_file_size, $src_file_name) = split( /\s+/, $_ );
		if ( $subdist && ( $subdist =~ /non-US/o ) ) {
		    $package_page .= "<a href=\"$env->{opts}->{nonus_site}/$source_dir/$src_file_name\">[";
		} elsif ( $subdist && ( $subdist =~ /updates/o ) ) {
		    $package_page .= "<a href=\"$env->{opts}->{security_site}/$source_dir/$src_file_name\">[";
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
	    $package_page .= sprintf( gettext( " (These sources are for version %s)\n" ), $src_version ) if $src_version ne $version;
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
	    $source_dir =~ s,pool/updates,pool,o;
	    $source_dir =~ s,pool/non-US,pool,o;
	    $package_page .= "<br><small>".sprintf( gettext( "View the <a href=\"%s\">Debian changelog</a>" ), "$CHANGELOG_URL/$source_dir/${sourcepackage}_$src_version/changelog" )."</small><br>\n";
	    $package_page .= "<small>".sprintf( gettext( "View the <a href=\"%s\">copyright file</a>" ), "$CHANGELOG_URL/$source_dir/${sourcepackage}_$src_version/copyright" )."</small><br>\n";
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

	$package_page .= sprintf( gettext( "<small>See the <a href=\"%s\">developer information for %s</a>.</small>\n" ), $QA_URL.$sourcepackage, $name );
	
	$package_page .= sprintf( gettext( "<p><small>Search for <a href=\"%s\">other versions of %s</a></small>\n" ), $SEARCH_URL.$encodedpack, $name );

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
	$package_page .= trailer( '../../..', $name, $env->{lang}, @tr_langs );
	
	#
	# write file
	#
	my $dirname = "$env->{dest_dir}";
	unless ( -d $dirname ) {
	    mkdir $dirname or die "Can\'t create dir $dirname: $!";
	}
	$dirname .= "/$section";
	unless ( -d $dirname ) {
	    mkdir $dirname or die "Can\'t create dir $dirname: $!";
	}
	
	my $now_time = time_stamp();
	my $filename = "$dirname/$name.$env->{lang}.html";
	if ( file_changed( \%md5s, $filename, $package_page ) ) {
	    sysopen(FILEH_PACK, $filename, 
		    O_WRONLY | O_TRUNC | O_CREAT, 0664) 
		|| die "Can\'t open file $filename: $!";
	    $package_page =~ s/LAST_MODIFIED_DATE/$now_time/;
	    print FILEH_PACK $package_page;
	    close FILEH_PACK;
	}
    }

sub write_pages {
	my ( $db, $opts, $dist, $archs, $langs ) = @_;

	$db->lock;
	$db->build_cache( @$archs );
	my $dest_dir = $opts->{html_root};
	%md5s = %{ read_md5_hash( $opts->{md5file} ) };
	unless ( @$langs ) {
	    $langs = [ "en" ];
	}
	unless ( $opts->{quiet} ) {
	    print "=" x 10 . "\n";
	    print "writing package pages for distribution $dist\n";
	}
	my $num_descs = $db->get_stats_val( 'num_descriptions' );
	my %sections = create_sections();
	foreach my $l ( @$langs ) {
	    my $locale = get_locale($l);
	    print "processing language $l (locale $locale)\n" unless $opts->{quiet};
	    setlocale ( LC_ALL, $locale )
		or do { warn "W: could not set locale, using default\n" unless $opts->{quiet};
			setlocale( LC_ALL, get_locale() ) 
			    or do {
				# Don't skip this so the pages can benefit from DDTP at least
			    	warn "W: could not set locale, using C\n" unless $opts->{quiet};
				setlocale( LC_ALL, "C" );
			};
		    };
	    print "writing distribution indices\n" unless $opts->{quiet};
	    $p_counter = 0;
	    write_all_package( $db, \%sections, $archs, 
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
	}
	write_md5_hash( $opts->{md5file} );
}

sub write_all_package {
	my ( $db, $sections, $archs, $dest_dir, 
	     $distro, $lang, $opts, $langs ) = @_;

	my %si = ();
	my $experimental_note = gettext( "<p>Warning: The <font color=\"red\">experimental</font> distribution contains software that is likely unstable or buggy and may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk.</p>\n" );

	foreach ( keys %$sections ) {
	    my $title = sprintf( gettext ( "Software Packages in &ldquo;%s&rdquo;, %s section" ), 
				 $distro, $_ );
	    $si{$_} = header( $title, '..', '..', $lang );
	    if ($distro eq "experimental") {
		$si{$_} .= $experimental_note;
	    }
	    $si{$_} .= "<dl>\n";
	}

	my $all_title = sprintf( gettext( "All Debian Packages in &ldquo;%s&rdquo;" ),
				 $distro );
	my $all_package = header( $all_title, '..', '..', $lang );
	if ($distro eq "experimental") {
	    $all_package .= $experimental_note;
	}
	$all_package .= "<dl>\n";

	my $all_pkg_txt = sprintf( gettext( "All Debian Packages in \"%s\"\n\n" ), $distro );
	$all_pkg_txt .=  gettext( "Last Modified: " ). "LAST_MODIFIED_DATE\n".
	    gettext( "Copyright (c) 1997-2003 SPI;\nSee <URL:http://www.debian.org/license> for the license terms.\n\n" );

	walk_db_packages( $db, &package_index_walker, 
			  { all_package => \$all_package, db => $db,
			    all_pkg_txt => \$all_pkg_txt, opts => $opts,
			    lang => $lang, si => \%si, archs => $archs } );

	foreach ( keys %$sections ) {
	    $si{$_} .= "</dl>\n";
	    $si{$_} .= trailer( '..', $_, $lang, @$langs );
	    my $dirname = "$dest_dir/$_";
	    unless ( -d $dirname ) {
		mkdir $dirname or die "Can\'t create dir $dirname: $!";
	    }
	    my $filename = "$dirname/index.$lang.html";
	    if( file_changed( \%md5s, $filename, $si{$_} )) {
		sysopen(FILEH, $filename, 
			O_WRONLY | O_TRUNC | O_CREAT, 0664) 
		    || die "Can\'t open file $filename: $!";
		my $now_time = time_stamp();
		$si{$_} =~ s/LAST_MODIFIED_DATE/$now_time/;
		print FILEH $si{$_};
		close FILEH;
	    }
	}
	
	$all_package .= "</dl>\n";
	$all_package .= trailer( '..', 'allpackages', $lang, @$langs );

	my $filename = "$dest_dir/allpackages.$lang.html";
	if( file_changed( \%md5s, $filename, $all_package )) {
	    sysopen(FILEH, $filename, 
		    O_WRONLY | O_TRUNC | O_CREAT, 0664) 
		|| die "Can\'t open file $filename: $!";
	    my $now_time = time_stamp();
	    $all_package =~ s/LAST_MODIFIED_DATE/$now_time/;
	    print FILEH $all_package;
	    close FILEH;
	}
	$filename = "$dest_dir/allpackages.$lang.txt.gz";
	if( file_changed( \%md5s, $filename, $all_pkg_txt )) {
	    sysopen( my $fh, $filename, 
		    O_WRONLY | O_TRUNC | O_CREAT, 0664) 
		|| die "Can\'t open file $filename: $!";
	    my $gz = gzopen( $fh, "wb" )
		or die "Can't open gzfile $filename: $!";
	    my $now_time = time_stamp();
	    $all_pkg_txt =~ s/LAST_MODIFIED_DATE/$now_time/;
	    $gz->gzwrite( $all_pkg_txt )
		or die "Error while writing $filename: ".$gz->gzerror();
	    $gz->gzclose();
	    close $fh;
	}
}

sub print_deps {
    my ( $env, $pkg, $versions, $type) = @_;
    my $res = "";
    my @all_archs = ( @{$env->{archs}}, 'all' );
    my %dep_type = ('depends' => 'dep', 'recommends' => 'rec', 
		    'suggests' => 'sug');
    my ( %dep_pkgs, %arch_deps );
    foreach my $a ( @all_archs ) {
	next unless ( exists $versions->{a2v}->{$a}
		      && exists $pkg->{versions}->{$versions->{a2v}->{$a}}->{$a}->{$type} );
	my @a_deps = @{$pkg->{versions}->{$versions->{a2v}->{$a}}->{$a}->{$type}};
	foreach my $d ( @a_deps ) {
	    my ( @dep_str, $dep_str );
	    foreach ( @$d ) {
		$_->[1] ||= ""; $_->[2] ||= "";
		push @dep_str, "$_->[0]($_->[1]$_->[2])";
	    }
	    $dep_str = join( "|", @dep_str );
	    $dep_pkgs{$dep_str}++;
	    $arch_deps{$a}->{$dep_str} = $d;
	}
    }
    @all_archs = sort keys %arch_deps;
#    print Dumper( \%dep_pkgs, \%arch_deps );
    
    if ( %dep_pkgs ) {
#	$res .= "<h4>$type</h4>\n";
	my $old_dp = "";
	my $is_old_dp = 0;
	foreach my $dp ( sort keys %dep_pkgs ) {
	    my $dp_v = $dp;
	    $dp_v =~ s/\(.*?\)//g;
	    my @pkgs = split /\|/, $dp;

	    if ( $dp_v eq $old_dp ) {
		$res .= "<tr><td></td><td>";
		$is_old_dp = 1;
		foreach ( @pkgs ) {
		    s/\(.*\)$//o;
		}
	    } else {
		$old_dp = $dp_v;
		$is_old_dp = 0;
	    
		$res .= "<tr><td width=\"20\" valign=\"top\"><img src=\"../../Pics/$dep_type{$type}.gif\"". 
		    " alt=\"[$dep_type{$type}]\" width=\"16\" height=\"16\"></td><td>";
	    }
	    

	    my ( @dependend_archs, @not_dependend_archs );
	    my $arch_str;
	    foreach my $a ( @all_archs ) {
		if ( exists( $versions->{a2v}->{$a} )
		     && exists( $arch_deps{$a} ) ) {
		    if ( exists $arch_deps{$a}->{$dp} ) {
			push @dependend_archs, $a;
		    } else {
			push @not_dependend_archs, $a;
		    }
		}
	    }
	    if ( @dependend_archs == @all_archs ) {
		$arch_str = "";
	    } else {
		if ( @dependend_archs > (@all_archs/2) ) {
		    $arch_str = " [".gettext( "not" )." ".join( ", ", @not_dependend_archs)."]";
		} else {
		    $arch_str = " [".join( ", ", @dependend_archs)."]";
		}
	    }

	    my @res_pkgs; my $pkg_ix = 0;
	    foreach my $p_name ( @pkgs ) {
#	    warn "before: $p_name\n";
		$p_name =~ s/\(.*\)$//o;
#	    warn "after: $p_name\n";
		
		if ( $pkg_ix > 0 ) { $arch_str = ""; }
		
		my $fl = substr $p_name, 0, 1;
		my $sl = substr $p_name, 0, 2;
		my $p = $env->{db}->get_pkg( $p_name );

		my $pkg_version = "";
		foreach my $a ( @all_archs ) {
		    if ( exists( $arch_deps{$a}->{$dp} )
			 && $arch_deps{$a}->{$dp}->[$pkg_ix]->[1] ) {
			$pkg_version = "(".encode_entities( $arch_deps{$a}->{$dp}->[$pkg_ix]->[1] ).
			    " $arch_deps{$a}->{$dp}->[$pkg_ix]->[2])";
			last;
		    }
		}

		if ( $p ) {
		    if ( $is_old_dp ) {
			push @res_pkgs, "<a href=\"../../$fl/$sl/$p_name\">$p_name</a> $pkg_version$arch_str";
		    } elsif ( $p->is_virtual ) {
			my $short_desc = gettext( "Virtual package" );
			push @res_pkgs, "<a href=\"../../$fl/$sl/$p_name\">$p_name</a> $pkg_version$arch_str</td></tr><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		    } else {
			my %desc_md5s = $p->get_arch_fields( 'description-md5', 
							     $env->{archs} );
			my $short_desc = encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" );
			push @res_pkgs, "<a href=\"../../$fl/$sl/$p_name\">$p_name</a> $pkg_version$arch_str</td></tr><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		    }
		} elsif ( $is_old_dp ) {
		    push @res_pkgs, "$p_name $pkg_version$arch_str";
		} else {
		    my $short_desc = gettext( "Package not available" );
		    push @res_pkgs, "$p_name $pkg_version$arch_str</td></tr><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		}
		$pkg_ix++;
#	    warn "$short_desc\n";
	    }
	    $res .= "<table><tr><td>".join( "</td></tr><tr><td> ".gettext( " or " )." ", @res_pkgs )."</td></tr></table>";
	    $res .= "</td>";
	    
	}
    }
    
    return $res;
}

1;
