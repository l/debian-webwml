use strict;
use warnings;

use HTML::Entities;

use Packages::Pkg;
use Deb::Versions;

sub dep_item {
    my ( $link, $name, $info, $desc ) = @_;
    my $post_link = '';
    if ($link) {
	$link = "<a href=\"$link\">";
	$post_link = '</a>';
    } else {
	$link = '';
    }
    if ($info) {
	$info = " $info";
    } else {
	$info = '';
    }
    if ($desc) {
	$desc = "</dt><dd>$desc</dd>";
    } else {
	$desc = '</dt>';
    }

    return "$link$name$post_link$info$desc";
} # end dep_item

sub dep_item_ds {
    my ( $link, $name, $info) = @_;
    my $post_link = '';
    if ($link) {
        $link = "<a href=\"$link\">";
        $post_link = '</a>';
    } else {
        $link = '';
    }
    if ($info) {
        $info = " $info";
    } else {
        $info = '';
    }
    return "$link$name$post_link$info";
} # end dep_item_ds


sub print_deps {
    my ( $env, $lang, $pkg, $relations, $type) = @_;
    my %dep_type = ('depends' => 'dep', 'recommends' => 'rec', 
		    'suggests' => 'sug');
    my $res = "<ul class=\"ul$dep_type{$type}\">\n";
    my $first = 1;

#    use Data::Dumper;
#    warn Dumper( \$lang, $pkg->get_name, \$type, $relations ); 

    foreach my $rel (@$relations) {
	my $is_old_pkgs = $rel->[0];
	my @res_pkgs = ();

	if ($is_old_pkgs)  {
	    $res .= "<dt>";
	} else {
	    if ($first) {
		$res .= "<li>";
		$first = 0;
	    } else {
		$res .= "</dl></li>\n<li>";
	    }
	    $res .= "<dl><dt><img class=\"hidecss\" src=\"../../Pics/$dep_type{$type}.gif\" alt=\"[$dep_type{$type}]\"> ";
	}

	foreach my $rel_alt ( @$rel ) {
	    next unless ref($rel_alt);
	    my ( $p_name, $pkg_version, $arch_neg,
		 $arch_str, $subsection, $available ) = @$rel_alt;

	    if ($arch_str) {
		if ($arch_neg) {
		    $arch_str = " [".gettext("not")." $arch_str]";
		} else {
		    $arch_str = " [$arch_str]";
		}
	    }
	    $pkg_version = "($pkg_version)" if $pkg_version;
	    
	    my $p = $env->{db}->get_pkg( $p_name );
	    if ( $p ) {
		if ( $is_old_pkgs ) {
		    push @res_pkgs, dep_item( "../$subsection/$p_name", $p_name, "$pkg_version$arch_str" );
		} elsif ( $subsection eq 'virtual' ) {
		    my $short_desc = gettext( "Virtual package" );
		    push @res_pkgs, dep_item( "../virtual/$p_name", $p_name, "$pkg_version$arch_str", $short_desc );
		} else {
		    my %desc_md5s = $p->get_arch_fields( 'description-md5', 
							 $env->{archs} );
		    my $short_desc = conv_desc( $lang, encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $lang ), "<>&\"" ) );
		    push @res_pkgs, dep_item( "../$subsection/$p_name", $p_name, "$pkg_version$arch_str", $short_desc );
		    }
	    } elsif ( $is_old_pkgs ) {
		push @res_pkgs, dep_item( undef, $p_name, "$pkg_version$arch_str" );
	    } else {
		my $short_desc = gettext( "Package not available" );
		push @res_pkgs, dep_item( undef, $p_name, "$pkg_version$arch_str", $short_desc );
	    }

	}
	
	$res .= "\n".join( "<dt>".gettext( "or" )." ", @res_pkgs )."\n";
    }
    if (@$relations) {
	$res .= "</dl></li>\n";
	$res .= "</ul>\n";
    } else {
	$res = "";
    }
    return $res;
} # end print_deps

sub print_src_deps {
    my ( $env, $lang, $pkg, $version, $type) = @_;
    my %dep_type = ('build-depends' => 'adep', 'build-depends-indep' => 'idep' );
    my $found = 0;
    my $res = "<ul class=\"ul$dep_type{$type}\">\n";
    foreach my $dep ( @{$pkg->{versions}{$version}{$type}} ) {
        $found = 1;
	my @res_pkgs;
	$res .= "<li><dl><dt><img class=\"hidecss\" src=\"../../Pics/$dep_type{$type}.gif\" alt=\"[$dep_type{$type}]\"> ";
	foreach my $or_dep ( @$dep ) {
	    my $p_name = $or_dep->[0];
	    my $p = $env->{db}->get_pkg( $p_name );
	    my $p_version = $or_dep->[1] ? "(".encode_entities( $or_dep->[1] ).
		" $or_dep->[2]) " : "";
	    my $not = gettext( "not" );
	    if ($or_dep->[3]) {
		$or_dep->[3] =~ s/\s+/, /go;
		# as either all or no archs have to be prepended with
		# exlamation marks, convert the first and delete the others
		$or_dep->[3] =~ s/!\s*/$not /o;
		$or_dep->[3] =~ s/!\s*//go;
	    }
	    my $arch_str = $or_dep->[3] ? " [$or_dep->[3]]" : "";
	    if ( $p ) {
		if ( $p->is_virtual ) {
		    my $short_desc = gettext( "Virtual package" );
		    push @res_pkgs, dep_item( "../virtual/$p_name", $p_name, "$p_version$arch_str", $short_desc );
		} else {
		    my %sections = $p->get_arch_fields( 'section',
							$env->{archs} );
		    my $section = $sections{max_unique};
		    my %desc_md5s = $p->get_arch_fields( 'description-md5', 
							 $env->{archs} );
		    my $short_desc = conv_desc( $lang, encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $lang ), "<>&\"" ) );
		    push @res_pkgs, dep_item( "../$section/$p_name", $p_name, "$p_version$arch_str", $short_desc );
		}
	    } else {
		my $short_desc = gettext( "Package not available" );
		push @res_pkgs, dep_item( undef, $p_name, "$p_version$arch_str", $short_desc );
	    }
	}
	$res .= "\n".join( "<dt>\n".gettext( "or" )." ", @res_pkgs )."</dl></li>\n";
    }
    if ($found) {
        $res .= "\n</ul>";
    } else {
        $res = "";
    }
    return $res;
} # end print_src_deps

sub print_deps_ds {
    my ( $env, $pkg, $relations, $type) = @_;
    my $res = "";
    
    use Data::Dumper;
#    warn Dumper( $type, $relations );

    my @res;
    foreach my $rel (@$relations) {
	my @res_pkgs = ();
	foreach my $rel_alt ( @$rel ) {
	    next unless ref($rel_alt);
	    my ( $p_name, $pkg_version, $arch_neg,
		 $arch_str, $subsection, $available ) = @$rel_alt;
	    
	    if ($arch_str) {
		if ($arch_neg) {
		    $arch_str = " [".gettext("not")." $arch_str]";
		} else {
		    $arch_str = " [$arch_str]";
		}
	    }
	    $pkg_version = "($pkg_version)" if $pkg_version;

	    if ($available) {
		push @res_pkgs, dep_item_ds( "../$subsection/$p_name",
					     $p_name,
					     "$pkg_version$arch_str" );
	    } else {
		push @res_pkgs, dep_item_ds( undef,
					     $p_name,
					     "$pkg_version$arch_str" );
	    }

	}
	push @res, join( " ".gettext( "or" )." ", @res_pkgs );
    }
    
    if (@res) {
        $res .= ds_item($type, join( ", ", @res));
    }
    return $res;
} # end print_deps_ds

#FIXME
sub print_reverse_rel_ds {
    my ( $env, $pkg, $versions, $type, $is_src_dep) = @_;
    my $res = "";
    my @res = ();
    my @all_archs = ( @{$env->{archs}}, 'all' );
    my $lc_type = lc $type;

    unless (exists $pkg->{rr}{$lc_type}) {
	return "";
    }

    my ( $save_p, $save_as ) = ( "", "" );
    my @save_vs = ();
    my $r_p;
    foreach $r_p ( sort keys %{$pkg->{rr}{$lc_type}} ) {
	foreach my $r_v ( version_sort keys %{$pkg->{rr}{$lc_type}{$r_p}} ) {
	    my %arch_deps;
	    foreach my $r_a ( keys %{$pkg->{rr}{$lc_type}{$r_p}{$r_v}} ) {
		$arch_deps{$r_a}{$r_p} =
		    "@{$pkg->{rr}{$lc_type}{$r_p}{$r_v}{$r_a}}";
	    }
	    @all_archs = sort keys %arch_deps;
	    my $arch_str = compute_arch_str( $r_p, $versions, \%arch_deps,
					     \@all_archs, $is_src_dep );
	    if ( ($r_p eq $save_p) && ($arch_str eq $save_as) ) {
		push @save_vs, $r_v;
	    } else {
		if ( $save_p ) {
		    $save_p = compute_link( $env, $save_p );
#		    if (@save_vs == keys %{$versions->{v2a}}) {
#			push @res, "$save_p$save_as";
#		    } else {
		    push @res, "$save_p (".
			join( ", ", version_sort @save_vs ).
			")$save_as";
#		    }
		}

		$save_p = $r_p;
		@save_vs = ( $r_v );
		$save_as = $arch_str;
	    }
	}
    }

    if (@res) {
	#FIXME: gettext
	$res = "<li>Reverse $type: ".join( ", ", @res)."</li>\n";
    }
    return $res;
} # end print_reverse_rel_ds


sub compute_src_arch_str {
    my ( $dp, $versions, $arch_deps, $all_archs ) = @_;


    my $full_arch_string = "";
    my $arch_str = "";
    foreach my $a ( @$all_archs ) {
	if ( exists( $versions->{a2v}{$a} )
	     && exists( $arch_deps->{$a} ) ) {
	    if ( exists $arch_deps->{$a}{$dp} ) {
		$full_arch_string .= $a;
	    }
	}
    }

    my ( %dep_archs, %not_dep_archs );
    my @toks = split / /, $full_arch_string;
    foreach (@toks) {
	/^all$/ && return "";

	/^!(\w+)$/ && do {
	    $not_dep_archs{$1}++;
	    next;
	};

	/^(\w+)$/ && do {
	    $dep_archs{$1}++;
	    next;
	};
    }

    foreach (keys %dep_archs) {
	if (exists $not_dep_archs{$_}) {
	    delete $not_dep_archs{$_};
	}

	$arch_str .= $_;
    }
    foreach (keys %not_dep_archs) {
	$arch_str .= "!$_";
    }

    return $arch_str;
} # end compute_src_arch_str

1;
