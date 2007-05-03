require 5.006;

use strict;
use warnings;

use POSIX;
use HTML::Entities;
use Data::Dumper;
# $Data::Dumper::Maxdepth = 3;
use URI::Escape;

use Packages::Page;
use Packages::Util;
use Packages::OutputFiles;
use Packages::HTML;
use Packages::I18N::Locale;
use Deb::Versions;
use Generated::Strings qw( gettext );

require( 'sections.pl' );
require( 'priorities.pl' );
require( 'print_deps.pl' );
require( 'index_pages.pl' );

my $FILELIST_URL = '/cgi-bin/search_contents.pl?searchmode=filelist&amp;word=';
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

    &Generated::Strings::string_lang('en');

    my $name = $pkg->get_name;

    my $package_page = header( title => $name, lang => 'en',
			       desc => gettext( "virtual package" ),
			       keywords => "$env->{distribution}, virtual, virtual, virtual, size:0 virtual" );
    $package_page .= simple_menu( [ gettext( "Distribution:" ),
				    gettext( "Overview over this distribution" ),
				    "../",
				    $env->{distribution} ],
				  [ gettext( "Section:" ),
				    gettext( "All packages in this section" ),
				    "../virtual/",
				    'virtual' ], );

    $package_page .= title( sprintf( gettext( "Virtual Package: %s" ), 
				     $name ) );

    $package_page .= note( sprintf( gettext( "This is a <em>virtual package</em>. See the <a href=\"%s\">Debian policy</a> for a <a href=\"%sch-binary#s-virtual_pkg\">definition of virtual packages</a>." ),
				    $POLICY_URL, $POLICY_URL ) );

    $package_page .= sprintf( "<h2>".gettext( "Packages providing %s" )."</h2>",
			      $name );
    $package_page .= pkg_list( [ keys %{$pkg->{rr}{provides}} ], 'en', $env );
    $package_page .= trailer( '../..' );
    
    #
    # write file
    #
    my $dirname = "$env->{dest_dir}/virtual";
    my $filename = "$dirname/$name.en.html";
    $files->update_file( $filename, $package_page );
}

sub package_pages_walker {
    my ( $pkg, $env ) = @_;
    
    my $name = $pkg->get_name;
    
    if ( $pkg->is_virtual ) { 
	print_virt_pack( @_ ); 
	return;
    }
    
    my @all_archs = ( @{$env->{archs}}, 'all' );
    
    my $page = new Packages::Page( $name,
				   { architectures => $env->{archs} } );
    my $d = $page->set_data( $env->{db}, $pkg );
    
    my %versions = $pkg->get_arch_versions( $env->{archs} );
    my %subsuites   = $pkg->get_arch_fields( 'subdistribution', 
					     $env->{archs} );
    my %filenames   = $pkg->get_arch_fields( 'filename',
					     $env->{archs} );
    my %file_md5s   = $pkg->get_arch_fields( 'md5sum',
					     $env->{archs} );
    
    my $subsuite_kw = $d->{subsuite} || $env->{distribution};
    my $size_kw = exists $d->{sizes_deb}{i386} ? $d->{sizes_deb}{i386} : first_val($d->{sizes_deb});
    
    
    foreach my $lang (@{$env->{langs}}) {
	&Generated::Strings::string_lang($lang);
	
	my $dirname = "$env->{dest_dir}/$d->{subsection}";
	my $filename = "$dirname/$name.$lang.html";
	
	unless (( $lang eq 'en' ) 
		|| $env->{db}->is_translated( $name, $d->{version},
					      ${$versions{v2a}{$d->{version}}}[0],
					      $lang )) {
	    $files->delete_file( $filename )
		if $files->file_exists( $filename );
	    next;
	}
	progress() if $env->{opts}{progress};
	
	#
	# process description
	#
	my $short_desc = encode_entities( $env->{db}->get_short_desc( $d->{desc_md5},
								      $lang ), "<>&\"" );
	my $long_desc = encode_entities( $env->{db}->get_long_desc( $d->{desc_md5},
								    $lang ), "<>&\"" );
	
	$long_desc =~ s,((ftp|http|https)://[\S~-]+?/?)((\&gt\;)?[)]?[']?[:.\,]?(\s|$)),<a href=\"$1\">$1</a>$3,go; # syntax highlighting -> '];
	$long_desc =~ s/\A //o;
	$long_desc =~ s/\n /\n/sgo;
	$long_desc =~ s/\n.\n/\n<p>\n/go;
	$long_desc =~ s/(((\n|\A) [^\n]*)+)/\n<pre>$1\n<\/pre>/sgo;
	
	$long_desc = conv_desc( $lang, $long_desc );
	$short_desc = conv_desc( $lang, $short_desc );
	
	#
	# begin output
	#
	my $package_page = header( title => $name, lang => $lang,
				   desc => $short_desc,
				   keywords => "$env->{distribution}, $subsuite_kw, $d->{section}, $d->{subsection}, size:$size_kw $d->{version}" );
	$package_page .= simple_menu( [ gettext( "Distribution:" ),
					gettext( "Overview over this distribution" ),
					"../",
					$env->{distribution} ],
				      [ gettext( "Section:" ),
					gettext( "All packages in this section" ),
					"../$d->{subsection}/",
					$d->{subsection} ],
				      );
	
	my $title .= sprintf( gettext( "Package: %s (%s)" ), $name, $d->{v_str_simple} );
	$title .=  " ".marker( $d->{subsuite} ) if $d->{subsuite};
	$title .=  " ".marker( $d->{section} ) if $d->{section} ne 'main';
	$package_page .= title( $title );
	
	$package_page .= "<h2>".gettext( "Versions:" )." $d->{v_str_arch}</h2>\n" 
	    unless $d->{version} eq $d->{v_str_simple};
	
	if ($env->{distribution} eq "experimental") {
	    $package_page .= note( gettext( "Experimental package"),
				   gettext( "Warning: This package is from the <span class=\"pred\">experimental</span> distribution. That means it is likely unstable or buggy, and it may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk.")."</p><p>".
				   gettext( "Users of experimental packages are encouraged to contact the package maintainers directly in case of problems." )
				   );
	}
	if ($d->{section} eq "debian-installer") {
	    $package_page .= note( gettext( "debian-installer udeb package"),
				   gettext( "Warning: This package is intended for the use in building <a href=\"http://www.debian.org/devel/debian-installer\">debian-installer</a> images only. Do not install it on a normal Debian system." )
				   );
	}
	$package_page .= pdesc( $short_desc, $long_desc );
	
	#
	# display dependencies
	#
	my $dep_list = print_deps( $env, $lang, $pkg, $d->{depends},    'depends' );
	$dep_list   .= print_deps( $env, $lang, $pkg, $d->{recommends}, 'recommends' );
	$dep_list   .= print_deps( $env, $lang, $pkg, $d->{suggests},   'suggests' );
	
	if ( $dep_list ) {
	    $package_page .= "<div id=\"pdeps\">\n";
	    $package_page .= sprintf( "<h2>".gettext( "Other Packages Related to %s" )."</h2>\n", $name );
	    if ($env->{distribution} eq "experimental") {
		$package_page .= note( gettext( "Note that the \"<span class=\"pred\">experimental</span>\" distribution is not self-contained; missing dependencies are likely found in the \"<a href=\"../../unstable/\">unstable</a>\" distribution." ) );
	    }
	    
	    $package_page .= pdeplegend( [ 'dep',  gettext( 'depends' ) ],
					 [ 'rec',  gettext( 'recommends' ) ],
					 [ 'sug',  gettext( 'suggests' ) ], );
	    
	    $package_page .= $dep_list;
	    $package_page .= "</div> <!-- end pdeps -->\n";
	}
	
	#
	# Download package
	#
	my $encodedpack = uri_escape( $name );
	$package_page .= "<div id=\"pdownload\">";
	$package_page .= sprintf( "<h2>".gettext( "Download %s\n" )."</h2>",
				  $name ) ;
	$package_page .= "<table border=\"1\" summary=\"".gettext("The download table links to the download of the package and a file overview. In addition it gives information about the package size and the installed size.")."\">\n";
	$package_page .= "<caption class=\"hidecss\">".gettext("Download for all available architectures")."</caption>\n";
	$package_page .= "<tr>\n";
	$package_page .= "<th>".gettext("Architecture")."</th><th>".gettext("Files")."</th><th>".gettext( "Package Size")."</th><th>".gettext("Installed Size")."</th></tr>\n";
	foreach my $a ( @all_archs ) {
	    if ( exists $versions{a2v}{$a} ) {
	        $package_page .= "<tr>\n";
		$package_page .=  "<th><a href=\"$DL_URL?arch=$a";
		# \&amp\;file=\" method=\"post\">\n<p>";
		$package_page .=  "&amp;file=".uri_escape($filenames{a2f}->{$a});
		$package_page .=  "&amp;md5sum=$file_md5s{a2f}->{$a}";
		$package_page .=  "&amp;arch=$a";
		if ($env->{distribution} eq "oldstable") {
		$package_page .=  "&amp;dist=$env->{distribution}";
		}
		my $unofficial = '';
		if (($a =~ /^kfreebsd/) ||
			(($env->{distribution} eq "oldstable") &&
				$a eq 'amd64')) {
			$unofficial = ' '.gettext( '(unofficial port)' );
			$package_page .= "&amp;type=unofficial";
		} else {
		# there was at least one package with two
		# different source packages on different
		# archs where one had a security update
		# and the other one not
		if ($subsuites{a2f}{$a}
		    && ($subsuites{a2f}{$a} =~ /security/o) ) {
		    $package_page .=  "&amp;type=security";
		} elsif ($subsuites{a2f}{$a}
			 && ($subsuites{a2f}{$a} =~ /volatile/o) ) {
		    $package_page .=  "&amp;type=volatile";
		} elsif ($d->{is_nonus}) {
		    $package_page .=  "&amp;type=nonus";
		} else {
		    $package_page .=  "&amp;type=main";
		}}
#		my $unofficial = ($a =~ /^(amd64|kfreebsd)/) ?
#		    ' '.gettext( '(unofficial port)' ) :
#		    '';
		$package_page .=  "\">$a</a>$unofficial</th>\n";
		$package_page .= "<td>";
		if ( $env->{distribution} ne "experimental" ) {
		    $package_page .= sprintf( "[<a href=\"%s\">".gettext( "list of files" )."</a>]\n", "$FILELIST_URL$encodedpack&amp;version=$env->{distribution}&amp;arch=$a", $name );
		} else {
		    $package_page .= gettext("no current information available");
		}
		$package_page .= "</td>\n<td>";
		my $size = $d->{sizes_deb}{$a};
		$package_page .=  "$size";
		$package_page .= "</td>\n<td>";
		my $inst_size = $d->{sizes_inst}{$a};
		$package_page .=  "$inst_size";
		$package_page .= "</td>\n</tr>";
	    }
	}
	$package_page .= "</table><p>".gettext ( "Size is measured in kBytes." )."</p>\n";
	$package_page .= "</div> <!-- end pdownload -->\n";
	
	#
	# more information
	#
	$package_page .= pmoreinfo( name => $name, env => $env, data => $d,
				    bugreports => 1, sourcedownload => 1,
				    changesandcopy => 1, maintainers => 1,
				    search => 1 );
	
	#
	# Trailer
	#
	my @tr_langs = ();
	foreach my $l (@{$env->{langs}}) {
	    next if $l eq $lang;
	    push @tr_langs, $l if ( $l eq 'en' ) 
		|| $env->{db}->is_translated( $name, $d->{version}, 
					      ${$versions{v2a}{$d->{version}}}[0],
					      $l );
	}
	$package_page .= trailer( '../..', $name, $lang, @tr_langs );
	
	#
	# write file
	#
	$files->update_file( $filename, $package_page );
	
	#
	# create data sheet
	#
	if($lang eq 'en') {
	    my $data_sheet = header( title => "$name -- Data sheet",
				     lang => "en",
				     desc => $short_desc,
				     keywords => "$env->{distribution}, $subsuite_kw, $d->{section}, $d->{subsection}, size:$size_kw $d->{version}" );	    
	    
	    my $ds_title = $name;
	    if ( $d->{subsuite} ) {
		$ds_title .=  " ".marker( $d->{subsuite} );
	    }
	    if ( $d->{section} ne 'main' ) {
		$ds_title .=  " ".marker( $d->{section} );
	    }
	    $data_sheet .= title( $ds_title );

	    $data_sheet .= ds_begin;
	    $data_sheet .= ds_item(gettext( "Version" ), $d->{v_str_arch});
	    
	    my @uploaders = @{$d->{uploaders}};
	    my ( $maint_name, $maint_email ) = @{shift @uploaders};
	    $data_sheet .= ds_item(gettext( "Maintainer" ),
				   "<a href=\"$DDPO_URL".
				   uri_escape($maint_email).
				   "\">".encode_entities($maint_name, '&<>')."</a>" );
	    if (@uploaders) {
		my @uploaders_str;
		foreach (@uploaders) {
		    push @uploaders_str, "<a href=\"$DDPO_URL".uri_escape($_->[1])."\">".encode_entities($_->[0], '&<>')."</a>";
		}
		$data_sheet .= ds_item(gettext( "Uploaders" ),
				       join( ",\n ", @uploaders_str ));
	    }
	    $data_sheet .= ds_item(gettext( "Section" ),
				   "<a href=\"../$d->{subsection}/\">$d->{subsection}</a>");
	    $data_sheet .= ds_item(gettext( "Priority" ),
				   "<a href=\"../$d->{priority}\">$d->{priority}</a>");
	    $data_sheet .= ds_item(gettext( "Essential" ),
				   "<a href=\"../essential\">".
				   gettext("yes")."</a>")
		if $d->{essential} =~ /yes/i;
	    $data_sheet .= ds_item(gettext( "Source package" ),
				   "<a href=\"../source/$d->{src_name}\">$d->{src_name}</a>");
	    $data_sheet .= print_deps_ds( $env, $pkg, $d->{depends},    'Depends' );
	    $data_sheet .= print_deps_ds( $env, $pkg, $d->{recommends}, 'Recommends' );
	    $data_sheet .= print_deps_ds( $env, $pkg, $d->{suggests},   'Suggests' );
	    $data_sheet .= print_deps_ds( $env, $pkg, $d->{enhances},   'Enhances' );
	    $data_sheet .= print_deps_ds( $env, $pkg, $d->{conflicts},  'Conflicts' );
	    $data_sheet .= print_deps_ds( $env, $pkg, $d->{provides},   'Provides' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Depends' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Recommends' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Suggests' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Enhances' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Provides' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Conflicts' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Build-Depends' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Build-Depends-Indep' );
#	    $data_sheet .= print_reverse_rel_ds( $env, $pkg, \%versions, 'Build-Conflicts' );

#	    if ( $name eq 'libc6' ) {
#		use Data::Dumper;
#		print STDERR Dumper( $pkg );
#	    }

	    $data_sheet .= ds_end;
	    
	    $data_sheet .= trailer( '../..', $name );

	    my $ds_filename = "$dirname/ds_$name.$lang.html";
	    #
	    # write file
	    #
	    $files->update_file( $ds_filename, $data_sheet );
	}
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
	my @up_tmp = split( /\s*,\s*/, 
			    $v_pkg->{uploaders} );
	foreach my $up (@up_tmp) {
	    if ($up ne $v_pkg->{maintainer}) {
		push @uploaders, [ split_name_mail( $up ) ];
	    }
	}
    }

    #
    # begin output
    #
    my $subdist_kw = $subdist || $env->{distribution};
    my $archive_kw = $archive || 'main';
    
    my $package_page = header( title => $name, lang => 'en',
			       keywords => "$env->{distribution}, $subdist_kw, $archive, $v_str" );
    $package_page .= simple_menu( [ gettext( "Distribution:" ),
				    gettext( "Overview over this distribution" ),
				    "../",
				    $env->{distribution} ],
				  );

    my $title .= sprintf( gettext( "Source package: %s (%s)" ),
			  $name, $v_str );
    
    my ( $is_security, $is_nonus, $is_volatile ) = ( 0, 0, 0  );
    if ( $subdist ) {
	$title .=  " ".marker( $subdist );
	# a package can be in subdist "non-US/security"
	# then both $is_nonus and $is_security are true
	if ($subdist =~ /non-US/o) {
	    $is_nonus = 1;
	}
	if ($subdist =~ /security/o) {
	    $is_security = 1;
	}
	if ($subdist =~ /volatile/o) {
	    $is_volatile = 1;
	}
    }
    if ( $archive && ( $archive ne 'main' ) ) {
	$title .=  " ".marker( $archive );
    }
    $package_page .= title( $title );
    $package_page .= "<div id=\"pdesc\">\n";
    if ($env->{distribution} eq "experimental") {
	$package_page .= note(
			      gettext( "Experimental package"),
			      gettext( "Warning: This package is from the <span class=\"pred\">experimental</span> distribution. That means it is likely unstable or buggy, and it may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk.")."</p><p>".
			      gettext( "Users of experimental packages are encouraged to contact the package maintainers directly in case of problems." ) );
    }
    if ($archive eq "debian-installer") {
	$package_page .= note(
			      gettext( "debian-installer udeb package"),
			      gettext( "Warning: This package is intended for the use in building <a href=\"http://www.debian.org/devel/debian-installer\">debian-installer</a> images only. Do not install it on a normal Debian system." ) );
    }

    my @bin_list;
    foreach my $bp ( @$binaries ) {
	push @bin_list, $bp->[0][0];
    }

    if (@bin_list) {
	$package_page .= gettext( "The following binary packages are built from this source package:" );
	$package_page .= pkg_list( \@bin_list, 'en', $env );
    }
    $package_page .= "</div> <!-- end pdesc -->\n";

    #
    # display dependencies
    #
    my $dep_list = print_src_deps( $env, 'en', $pkg, $v_str, 'build-depends' );
    $dep_list .= print_src_deps( $env, 'en', $pkg, $v_str, 'build-depends-indep' );

    if ( $dep_list ) {
	$package_page .= "<div id=\"pdeps\">\n";
	$package_page .= sprintf( "\n<h2>".gettext( "Other Packages Related to %s" )."</h2>\n", $name );
	if ($env->{distribution} eq "experimental") {
	    $package_page .= note( gettext( "Note that the \"<span class=\"pred\">experimental</span>\" distribution is not self-contained; missing dependencies are likely found in the \"<a href=\"../../unstable/\">unstable</a>\" distribution." ) );
	}

	$package_page .= pdeplegend( [ 'adep', gettext( 'build-depends' ) ],
	                             [ 'idep', gettext( 'build-depends-indep' ) ] );
	$package_page .= $dep_list;
	$package_page .= "</div> <!-- end pdeps -->\n";
    }

    #
    # Source package download
    #
    $package_page .= "<div id=\"pdownload\">\n";
    my $encodedpack = uri_escape( $name );
    $package_page .= sprintf( "<h2>".gettext( "Download %s" )."</h2>\n",
			      $name ) ;
    
    my $sf = $v_pkg->{files};
    my $source_dir = $v_pkg->{directory};
    $sf =~ s/\A\s*//o; # remove leading spaces
    my @source_files = split( /\n\s*/, $sf );
    $package_page .= sprintf( "<table cellspacing=\"0\" cellpadding=\"2\" summary=\"Download information for the files of this source package\">\n"
			      ."<tr><th>%s</th><th>%s</th><th>%s</th>",
			      gettext("File"),
			      gettext("Size (in kB)"),
			      gettext("md5sum") );
    foreach( @source_files ) {
	my ($src_file_md5, $src_file_size, $src_file_name) = split( /\s+/, $_ );
	my $src_url = "$env->{opts}{debian_site}/$source_dir/$src_file_name";
	if ($is_security) {
	    $src_url = "$env->{opts}{security_site}/$source_dir/$src_file_name";
	} elsif ($is_volatile) {
	    $src_url = "$env->{opts}{volatile_site}/$source_dir/$src_file_name";
	} elsif ($is_nonus) {
	    $src_url = "$env->{opts}{nonus_site}/$source_dir/$src_file_name";
	}
	
	$package_page .= "<tr><td><a href=\"$src_url\">$src_file_name</a></td>\n"
	    ."<td class=\"dotalign\">".sprintf("%.1f", (floor(($src_file_size/102.4)+0.5)/10))."</td>\n"
	    ."<td>$src_file_md5</td></tr>";
    }
    $package_page .= "</table>\n";
    $package_page .= "</div> <!-- end pdownload -->\n";

    #
    # more information
    #
    unshift @uploaders, [ $maint_name, $maint_email ];
    my $data = { src_directory => $source_dir, src_name => $name,
		 src_version => $v_str, uploaders => \@uploaders };
    $package_page .= pmoreinfo( name => $name, env => $env, data => $data,
				bugreports => 1,
				changesandcopy => 1, maintainers => 1,
				search => 1, is_source => 1 );

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
	print "writing distribution indices\n" unless $opts->{quiet};
	$p_counter = 0;
	write_all_package( $db, \%sections, \%priorities, $archs, 
			   $dest_dir, $dist, $opts, $langs );
	print "\n" if $opts->{progress};

	print "writing pages for individual packages\n" unless $opts->{quiet};
	$p_counter = 0;
	walk_db_packages( $db, &package_pages_walker,
			  { db => $db, langs => $langs,
			    dest_dir => $dest_dir,
			    distribution => $dist,
			    archs => $archs,
			    opts => $opts } );
	print "\n" if $opts->{progress};
	print "writing source package index\n" unless $opts->{quiet};
	$p_counter = 0;
	write_src_index( $db, $dest_dir, $dist, 'en', $opts, $langs );
	print "\n" if $opts->{progress};
	
	print "writing pages for individual source packages\n" unless $opts->{quiet};
	$p_counter = 0;
	walk_db_src_packages( $db, &src_package_pages_walker,
			      { db => $db,
				dest_dir => $dest_dir,
				distribution => $dist,
				opts => $opts } );
	print "\n" if $opts->{progress};
	$files->write_file_list( $opts->{md5file} );
    }

sub write_all_package {
    my ( $db, $sections, $priorities, $archs, $dest_dir, 
	 $distro, $opts, $langs ) = @_;
    
    my %si_l = ();
    my %pi_l = ();
    my %ei_l = ();
    my %all_pkg_l = ();
    my %all_pkg_txt_l = ();

    # generate the list (for all languages)
    walk_db_packages( $db, &package_index_walker, 
		      { all_package => \%all_pkg_l, db => $db,
			all_pkg_txt => \%all_pkg_txt_l, opts => $opts,
			si => \%si_l, pi => \%pi_l,
			ei => \%ei_l, archs => $archs, langs => $langs } );

    # generate headers and footers and insert lists
    foreach my $lang (@$langs) {
	
	&Generated::Strings::string_lang($lang);
	
	my $experimental_note = note( gettext( "Warning: The <span class=\"pred\">experimental</span> distribution contains software that is likely unstable or buggy and may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk." ) );
	my $installer_note = note( gettext( "Warning: These packages are intended for the use in building <a href=\"http://www.debian.org/devel/debian-installer/\">debian-installer</a> images only. Do not install them on a normal Debian system.") );
	
	#
	# Sections
	#
	my %si = ();
	foreach ( keys %$sections ) {
	    next if $_ eq 'virtual' and $lang ne 'en';

	    my $title = sprintf( gettext ( "Software Packages in \"%s\", %s section" ), 
				 $distro, $_ );
	    $si{$_} = header( title => $title,
			      title_keywords => "debian, $distro, $_",
			      desc => encode_entities( $title, '"' ),
			      lang => $lang );
	    $si{$_} .= simple_menu( [ gettext( "Distribution:" ),
				      gettext( "Overview over this distribution" ),
				      "../",
				      $distro ],
				    );

	    $si{$_} .= title( $title );

	    if ($distro eq "experimental") {
		$si{$_} .= $experimental_note;
	    }
	    if ($_ eq 'debian-installer') {
		$si{$_} .= $installer_note;
	    }
	    if ($si_l{$lang}{$_}) {
		$si{$_} .= "<dl>\n";
		$si{$_} .= $si_l{$lang}{$_};
		$si{$_} .= "</dl>\n";
	    } else {
		$si{$_} .= note( gettext( "No packages in this section in this suite" ) );
	    }
	    $si{$_} .= trailer( '..', 'index', $lang, @$langs );
	    my $dirname = "$dest_dir/$_";
	    my $filename = "$dirname/index.$lang.html";
	    $files->update_file( $filename, $si{$_} );
	}

	#
	# Priorities
	#
	my %pi = ();
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
	    $pi{$_} = header( title => $title,
			      title_keywords => "debian, $distro, $_",
			      desc => encode_entities( $title, '"' ),
			      lang => $lang );
	    $pi{$_} .= simple_menu( [ gettext( "Distribution:" ),
				      gettext( "Overview over this distribution" ),
				      "./",
				      $distro ],
				    );
	    $pi{$_} .= "$priority_header\n";
	    $pi{$_} .= title( $title );
	    if ($distro eq "experimental") {
		$pi{$_} .= $experimental_note;
	    }
	    if ($pi_l{$lang}{$_}) {
		$pi{$_} .= "<dl>\n";
		$pi{$_} .= $pi_l{$lang}{$_};
		$pi{$_} .= "</dl>\n";
	    } else {
		$pi{$_} .= note( gettext( "No packages with this priority in this suite" ) );
	    }
	    $pi{$_} .= trailer( '..', $_, $lang, @$langs );
	    my $dirname = "$dest_dir";
	    my $filename = "$dirname/$_.$lang.html";
	    $files->update_file( $filename, $pi{$_} );
	}

	#
	# Essential
	#
	my $ei = "";
        # no index of essential packages for experimental
	if ($distro ne 'experimental') {
	    my $title = sprintf( gettext ( "Software Packages in \"%s\", essential packages" ), 
				 $distro );
	    $ei .= header( title => $title,
			   title_keywords => "debian, $distro, essential",
			   desc => encode_entities( $title, '"' ),
			   lang => $lang );
	    $ei .= simple_menu( [ gettext( "Distribution:" ),
				  gettext( "Overview over this distribution" ),
				  "./",
				  $distro ],
				);

	    $ei .= title( $title );
	    if ($ei_l{$lang}) {
		$ei .= "<dl>\n";
		$ei .= $ei_l{$lang};
		$ei .= "</dl>\n";
	    } else {
		$ei .= note( gettext( "No essential packages in this suite" ) );
	    }
	    $ei .= trailer( '..', 'essential', $lang, @$langs );
	    my $dirname = "$dest_dir";
	    my $filename = "$dirname/essential.$lang.html";
	    $files->update_file( $filename, $ei );
	}
	
	#
	# Complete list
	#
	my $all_title = sprintf( gettext( "All Debian Packages in \"%s\"" ),
				 $distro );
	my $all_package = header( title => $all_title,
				  title_keywords => "debian, $distro",
				  desc => encode_entities( $all_title, '"' ),
				  lang => $lang );
	$all_package .= simple_menu( [ gettext( "Distribution:" ),
				       gettext( "Overview over this distribution" ),
				       "./",
				       $distro ],
				     );
	$all_package .= title( $all_title );

	if ($distro eq "experimental") {
	    $all_package .= $experimental_note;
	}
	$all_package .= "<dl>\n";
	$all_package .= $all_pkg_l{$lang};
	$all_package .= "</dl>\n";
	$all_package .= trailer( '..', 'allpackages', $lang, @$langs );

	my $filename = "$dest_dir/allpackages.$lang.html";
	$files->update_file( $filename, $all_package );

	#
	# Complete list (txt)
	my $all_pkg_txt = sprintf( gettext( "All Debian Packages in \"%s\"" )."\n\n", $distro );
	$all_pkg_txt .=  gettext( "Last Modified: " ). "LAST_MODIFIED_DATE\n".
	    gettext( "Copyright (C) 1997-2005 SPI;\nSee <URL:http://www.debian.org/license> for the license terms.\n\n" );
	$all_pkg_txt .= $all_pkg_txt_l{$lang}; 
	
	$filename = "$dest_dir/allpackages.$lang.txt.gz";
	$files->update_gz_file( $filename, $all_pkg_txt );

    }
}

sub write_src_index {
    my ( $db, $dest_dir, $distro, $lang, $opts, $langs ) = @_;
    
    &Generated::Strings::string_lang($lang);
 
    my $source_index;
    my $experimental_note = note( gettext( "Warning: The <span class=\"pred\">experimental</span> distribution contains software that is likely unstable or buggy and may even cause data loss. If you ignore this warning and install it nevertheless, you do it on your own risk." ) );
    
    my $title = sprintf( gettext ( "Source Packages in \"%s\"" ), 
			 $distro, $_ );
    $source_index = header( title => $title,
			    title_keywords => "debian, $distro, source",
			    desc => encode_entities( $title, '"' ),
                            lang => $lang,
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
