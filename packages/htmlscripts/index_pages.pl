use strict;
use warnings;

use Packages::Util;

sub package_index_walker {
    my $pkg = shift;
    my $env = shift;
    my ( $str, $sect_str, $txt_str );
    
    progress() if $env->{opts}{progress};
    my $name = $pkg->get_name;
    
    if ( $pkg->is_virtual ) {
	$sect_str = "<dt><a href=\"$name\">".
	    "$name</a></dt>\n";
	$env->{si}{en}{virtual} .= $sect_str;
	return;
    }
    
    my $page = new Packages::Page( $name, { architectures => $env->{archs} } );
    my $d = $page->set_data( $env->{db}, $pkg );
    
    my %desc_md5s = $pkg->get_arch_fields( 'description-md5', 
					   $env->{archs} );
    
    foreach my $lang (@{$env->{langs}}) {
	my $short_desc_orig = $env->{db}->get_short_desc( $desc_md5s{max_unique}, $lang );
	my $short_desc_txt = conv_desc( $lang, $short_desc_orig );
	my $short_desc = conv_desc( $lang, encode_entities( $short_desc_orig, "<>&\"" ) );
	
	$sect_str = "<dt><a href=\"$name\">".
	    "$name</a> ($d->{v_str_arch})";
	$str      = "<dt><a href=\"$d->{subsection}/$name\">".
	    "$name</a> ($d->{v_str_arch})";
	$txt_str  = "$name ($d->{v_str_arch})";
	if ( $d->{section} ne 'main' ) {
	    $str      .=  " ".marker( $d->{section} );
	    $sect_str .=  " ".marker( $d->{section} );
	    $txt_str  .= " [$d->{section}]";
	}
	if ( $d->{subsuite} ) {
	    $str .=  " ".marker( $d->{subsuite} );
	    $sect_str .=  " ".marker( $d->{subsuite} );
	    $txt_str .=  " [$d->{subsuite}]";
	}
	$str      .= "</dt>\n     <dd>$short_desc</dd>\n";
	$sect_str .= "</dt>\n     <dd>$short_desc</dd>\n";
	$txt_str  .= " $short_desc_txt\n";
	$env->{all_package}{$lang} .= $str;
	$env->{all_pkg_txt}{$lang} .= $txt_str;
	$env->{si}{$lang}{$d->{subsection}} .= $sect_str;
	$env->{pi}{$lang}{$d->{priority}} .= $str;
	$env->{ei}{$lang} .= $str if $d->{essential} =~ /yes/i;
    }
}

sub src_package_index_walker {
    my $pkg = shift;
    my $env = shift;
 
    progress() if $env->{opts}{progress};
    my $name = $pkg->get_name;
    
    my ( $version, $v_pkg, $section, $subsuite, $str );
    $version = ($pkg->get_version_list)[0];
    $v_pkg = $pkg->get_version( $version );
    $section = $v_pkg->{archive};
    $subsuite = $v_pkg->{subdistribution};

    $str = "<dt><a href=\"$name\">".
	"$name</a> ($version)";
    if ( $section && ( $section ne 'main' ) ) {
	$str .=  " ".marker( $section );;
    }
    if ( $subsuite ) {
	$str .=  " ".marker( $subsuite );
    }
    ${$env->{source_index}} .= $str;
}

1;
