use strict;
use warnings;

require( 'util.pl' );

sub package_index_walker {
	my $pkg = shift;
	my $env = shift;
	my ( $str, $sect_str, $txt_str );

	progress() if $env->{opts}{progress};
	my $name = $pkg->get_name;

	if ( $pkg->is_virtual ) {
	    $sect_str = "<dt><a href=\"$name\">".
		"$name</a></dt>";
	    $env->{si}->{virtual} .= $sect_str;
	    return;
	}

	my %versions = $pkg->get_arch_versions( $env->{archs} );
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

	my $short_desc_orig = $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} );
	my $short_desc_txt = conv_desc( $env->{lang}, $short_desc_orig );
	my $short_desc = conv_desc( $env->{lang}, encode_entities( $short_desc_orig, "<>&\"" ) );

	my ( $version, $section, $priority, $essential, $archive, $subdist );
	$version = ($pkg->get_version_list)[0];
	$section = $sections{max_unique};
	$priority = $priorities{max_unique} || "";
	$essential = $essential{max_unique} || "";
	$archive = $archives{max_unique}
	    if exists $archives{max_unique};
	$subdist = $subdists{max_unique}
	    if exists $subdists{max_unique};

	my ( @v_str, $v_str );
	if ( scalar keys %{$versions{unique}} == 1 ) {
	    $v_str = "($version)";
	} else {
	    foreach ( version_sort( keys %{$versions{unique}} ) ) {
		push @v_str, "$_ [".join( ", ", @{$versions{v2a}->{$_}} )."]";
	    }
	    $v_str = "(".join( ", ", @v_str ).")";
	}

	$sect_str = "<dt><a href=\"$name\">".
	    "$name</a> $v_str";
	$str = "<dt><a href=\"$section/$name\">".
	    "$name</a> $v_str";
	$txt_str = "$name $v_str";
	if ( $archive && ( $archive ne 'main' ) ) {
	    $str .=  " [<font color=\"red\">$archive</font>]\n";
	    $sect_str .=  " [<font color=\"red\">$archive</font>]\n";
	    $txt_str .= " [$archive]";
	}
	if ( $subdist ) {
	    $str .=  " [<font color=\"red\">$subdist</font>]\n";
	    $sect_str .=  " [<font color=\"red\">$subdist</font>]\n";
	    $txt_str .=  " [$subdist]";
	}
	$str .= "</dt>\n     <dd>$short_desc</dd>\n";
	$sect_str .= "</dt>\n     <dd>$short_desc</dd>\n";
	$txt_str .= " $short_desc_txt\n";
	${$env->{all_package}} .= $str;
	${$env->{all_pkg_txt}} .= $txt_str;
	$env->{si}->{$section} .= $sect_str if $section;
	$env->{pi}->{$priority} .= $str if $priority;
	${$env->{ei}} .= $str if $essential =~ /yes/i;
    }

sub src_package_index_walker {
    my $pkg = shift;
    my $env = shift;
 
    progress() if $env->{opts}{progress};
    my $name = $pkg->get_name;
    
    my ( $version, $v_pkg, $archive, $subdist, $str );
    $version = ($pkg->get_version_list)[0];
    $v_pkg = $pkg->get_version( $version );
    $archive = $v_pkg->{archive};
    $subdist = $v_pkg->{subdistribution};

    $str = "<dt><a href=\"$name\">".
	"$name</a> $version";
    if ( $archive && ( $archive ne 'main' ) ) {
	$str .=  " [<font color=\"red\">$archive</font>]\n";
    }
    if ( $subdist ) {
	$str .=  " [<font color=\"red\">$subdist</font>]\n";
    }
    ${$env->{source_index}} .= $str;
}

1;
