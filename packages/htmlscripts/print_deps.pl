use strict;
use warnings;

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
	    
	    my $arch_str = compute_arch_str ( $dp, $versions, \%arch_deps,
					      \@all_archs );

	    my @res_pkgs; my $pkg_ix = 0;
	    foreach my $p_name ( @pkgs ) {
#	    warn "before: $p_name\n";
		$p_name =~ s/\(.*\)$//o;
#	    warn "after: $p_name\n";
		
		if ( $pkg_ix > 0 ) { $arch_str = ""; }
		
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
			my $section;
			if ($p->is_virtual) {
			    $section = "virtual";
			} else {
			    my %sections = $p->get_arch_fields( 'section',
							    $env->{archs} );
			    $section = $sections{max_unique} or warn "W: no section found for package ".$p->get_name()."\n";
			}
#DEBUG
			unless(defined($section)&& defined($p_name)&& defined($pkg_version) && defined($arch_str)) {
			    print STDERR "E: $section&&$p_name&&$pkg_version&&$arch_str&&".$pkg->get_name()."\n";
			}
			push @res_pkgs, "<a href=\"../$section/$p_name\">$p_name</a> $pkg_version$arch_str";
		    } elsif ( $p->is_virtual ) {
			my $short_desc = gettext( "Virtual package" );
			push @res_pkgs, "<a href=\"../virtual/$p_name\">$p_name</a> $pkg_version$arch_str</td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		    } else {
			my %sections = $p->get_arch_fields( 'section',
							    $env->{archs} );
			my $section = $sections{max_unique};
			my %desc_md5s = $p->get_arch_fields( 'description-md5', 
							     $env->{archs} );
			my $short_desc = conv_desc( $env->{lang}, encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" ) );
			push @res_pkgs, "<a href=\"../$section/$p_name\">$p_name</a> $pkg_version$arch_str</td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		    }
		} elsif ( $is_old_dp ) {
		    push @res_pkgs, "$p_name $pkg_version$arch_str";
		} else {
		    my $short_desc = gettext( "Package not available" );
		    push @res_pkgs, "$p_name $pkg_version$arch_str</td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		}
		$pkg_ix++;
#	    warn "$short_desc\n";
	    }
	    $res .= "<table>\n<tr><td>".join( "</td></tr>\n<tr><td> ".gettext( " or " )." ", @res_pkgs )."</td></tr>\n</table>";
	    $res .= "</td>";
	    
	}
    }
    
    return $res;
}

sub print_src_deps {
    my ( $env, $pkg, $version, $type) = @_;
    my $res = "";
    my %dep_type = ('build-depends' => 'adep', 'build-depends-indep' => 'idep' );
    
    foreach my $dep ( @{$pkg->{versions}{$version}{$type}} ) {
	my @res_pkgs;
	$res .= "<tr><td width=\"20\" valign=\"top\"><img src=\"../../Pics/$dep_type{$type}.gif\"". 
	    " alt=\"[$dep_type{$type}]\" width=\"16\" height=\"16\"></td><td>";
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
		    push @res_pkgs, "<a href=\"../virtual/$p_name\">$p_name</a> $p_version$arch_str</td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		} else {
		    my %sections = $p->get_arch_fields( 'section',
							$env->{archs} );
		    my $section = $sections{max_unique};
		    my %desc_md5s = $p->get_arch_fields( 'description-md5', 
							 $env->{archs} );
		    my $short_desc = conv_desc( $env->{lang}, encode_entities( $env->{db}->get_short_desc( $desc_md5s{max_unique}, $env->{lang} ), "<>&\"" ) );
		    push @res_pkgs, "<a href=\"../$section/$p_name\">$p_name</a> $p_version$arch_str</td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
		}
	    } else {
		my $short_desc = gettext( "Package not available" );
		push @res_pkgs, "$p_name $p_version$arch_str</td></tr>\n<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$short_desc";
	    }
	}
	$res .= "<table>\n<tr><td>".join( "</td></tr>\n<tr><td> ".gettext( " or " )." ", @res_pkgs )."</td></tr>\n</table>";
	$res .= "</td>";
    }

    return $res;
}

sub print_deps_ds {
    my ( $env, $pkg, $versions, $type) = @_;
    my $res = "";
    my @all_archs = ( @{$env->{archs}}, 'all' );
    my ( %dep_pkgs, %arch_deps );
    foreach my $a ( @all_archs ) {
	next unless ( exists $versions->{a2v}{$a}
		      && exists $pkg->{versions}{$versions->{a2v}{$a}}{$a}{lc $type} );
	my @a_deps = @{$pkg->{versions}{$versions->{a2v}{$a}}{$a}{lc $type}};
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
    
    my @res;
    if ( %dep_pkgs ) {
	foreach my $dp ( sort keys %dep_pkgs ) {
	    my $dp_v = $dp;
	    $dp_v =~ s/\(.*?\)//g;
	    my @pkgs = split /\|/, $dp;

	    my $arch_str = compute_arch_str ( $dp, $versions, \%arch_deps,
					      \@all_archs );

	    my @res_pkgs; my $pkg_ix = 0;
	    foreach my $p_name ( @pkgs ) {
		$p_name =~ s/\(.*\)$//o;
		
		if ( $pkg_ix > 0 ) { $arch_str = ""; }
		
		my $pkg_version = "";
		foreach my $a ( @all_archs ) {
		    if ( exists( $arch_deps{$a}->{$dp} )
			 && $arch_deps{$a}->{$dp}->[$pkg_ix]->[1] ) {
			$pkg_version = "(".encode_entities( $arch_deps{$a}->{$dp}->[$pkg_ix]->[1] ).
			    " $arch_deps{$a}->{$dp}->[$pkg_ix]->[2])";
			last;
		    }
		}

		push @res_pkgs, compute_link( $env, $p_name )
		    ." $pkg_version$arch_str";
		$pkg_ix++;
	    }
	    push @res, join( gettext( " or " ), @res_pkgs );
	}
    }
    
    if (@res) {
	$res = "<tr><td valign=\"top\">$type:</td><td>".join( ", ", @res)."</td></tr>\n";
    }
    return $res;
}

sub print_reverse_rel_ds {
    my ( $env, $pkg, $versions, $type) = @_;
    my $res = "";
    my @res = ();
    my @all_archs = ( @{$env->{archs}}, 'all' );
    my $lc_type = lc $type;

    unless (exists $pkg->{rr}{$lc_type}) {
	return "";
    }

    my ( $save_p, $save_as ) = ( "", "" );
    my @save_vs = ();
    foreach my $r_p ( sort keys %{$pkg->{rr}{$lc_type}} ) {
	foreach my $r_v ( version_sort keys %{$pkg->{rr}{$lc_type}{$r_p}} ) {
	    my %arch_deps;
	    foreach my $r_a ( keys %{$pkg->{rr}{$lc_type}{$r_p}{$r_v}} ) {
		$arch_deps{$r_a}{$r_p} =
		    "@{$pkg->{rr}{$lc_type}{$r_p}{$r_v}{$r_a}}";
	    }
	    @all_archs = sort keys %arch_deps;
	    my $arch_str = compute_arch_str( $r_p, $versions, \%arch_deps,
					     \@all_archs );
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
	$res = "<tr><td valign=\"top\">Reverse $type:</td><td>".join( ", ", @res)."</td></tr>\n";
    }
    return $res;
}    

sub compute_arch_str {
    my ( $dp, $versions, $arch_deps, $all_archs ) = @_;

    my ( @dependend_archs, @not_dependend_archs );
    my $arch_str;
    foreach my $a ( @$all_archs ) {
	if ( exists( $versions->{a2v}{$a} )
	     && exists( $arch_deps->{$a} ) ) {
	    if ( exists $arch_deps->{$a}{$dp} ) {
		push @dependend_archs, $a;
	    } else {
		push @not_dependend_archs, $a;
	    }
	}
    }
    if ( @dependend_archs == @$all_archs ) {
	$arch_str = "";
    } else {
	if ( @dependend_archs > (@$all_archs/2) ) {
	    $arch_str = " [".gettext( "not" )." ".join( ", ", @not_dependend_archs)."]";
	} else {
	    $arch_str = " [".join( ", ", @dependend_archs)."]";
	}
    }
    return $arch_str;
}

sub compute_link {
    my ( $env, $p_name ) = @_;

    my $p = $env->{db}->get_pkg( $p_name );
    if ($p) {
	my $section;
	if ($p->is_virtual) {
	    $section = "virtual";
	} else {
	    my %sections = $p->get_arch_fields( 'section',
						$env->{archs} );
	    $section = $sections{max_unique}
	    or warn "W: no section found for package ".
		$p_name."\n";
	}
	$p_name = "<a href=\"../$section/$p_name\">$p_name</a>";
    }

    return $p_name;
}

1;
