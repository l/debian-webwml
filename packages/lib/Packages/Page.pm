#
# Packages::Page
# $Id$
#
# Copyright 2004 Frank Lichtenheld <frank@lichtenheld.de>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 Class Methods

=over 4

=cut

package Packages::Page;

use strict;
use warnings;

use Storable;
use POSIX;

use Deb::Versions;
use Packages::Util;

our $VERSION = 0.1;
our $RCS_VERSION = '$Revision$';

our $SUBSUITE_DEFAULT = '';
our $SECTION_DEFAULT = 'main';
our $SUBSECTION_DEFAULT = 'unknown';
our $PRIORITY_DEFAULT = 'optional';
our $ESSENTIAL_DEFAULT = 'no';
our $MAINTAINER_DEFAULT = 'unknown <unknown@email.invalid>';

# ===============
# | Constructor |
# ===============

=pod

=item C<new>

Creates a new Packages::Page object. You can optionally specify
the package name as parameter.

=cut

sub new {
    my $classname = shift;
    my $name = shift || '';
    my $config = shift || {};

    my $self = {};
    bless( $self, $classname );

    $self->{package} = $name;
    $self->{config} = $config;

    return $self;
}

=pod

=item C<copy>

Return (using L<Storable> modul) a copy of the Page object.

=cut

sub copy {
    my $self = shift;

    my $ret = Storable::dclone( $self );
    return bless( $ret, ref $self );
}

=pod

=item C<set_data>

FIXME

=cut

sub set_data {
    my ( $self, $db, $pkg ) = @_;

    my @archs = $self->architectures;
    _assert( scalar @archs, "architectures not set" );
    _assert( $db, "DB not given" );
    _assert( $pkg, "Pkg not given" );
    _assert( !$pkg->is_virtual, "Pkg is virtual" );

    #
    # get information
    #
    my $name        = $pkg->get_name;
    _assert( $name eq $self->{package}, "package name doesn't match" );

    my %versions    = $pkg->get_arch_versions( \@archs );
    my $version     = (version_sort( keys %{$versions{unique}} ))[0];
    
    my %desc_md5s   = $pkg->get_arch_fields( 'description-md5', 
					     \@archs );
    my %subsections = $pkg->get_arch_fields( 'section', 
					     \@archs );
    my %priorities  = $pkg->get_arch_fields( 'priority', 
					     \@archs );
    my %essential   = $pkg->get_arch_fields( 'essential', 
					     \@archs );
    my %sections    = $pkg->get_arch_fields( 'archive', 
					     \@archs );
    my %subsuites   = $pkg->get_arch_fields( 'subdistribution', 
					     \@archs );
    my %maintainers = $pkg->get_arch_fields( 'maintainer',
					     \@archs );
    my %sources     = $pkg->get_arch_fields( 'source',
					     \@archs );
    my %filenames   = $pkg->get_arch_fields( 'filename',
					     \@archs );
    my %file_md5s   = $pkg->get_arch_fields( 'md5sum',
					     \@archs );
    my %file_sizes  = $pkg->get_arch_fields( 'size',
					     \@archs );
    my %inst_sizes  = $pkg->get_arch_fields( 'installed-size',
					     \@archs );
    my ( $section, $subsection, $priority, $essential, $desc_md5,
	 $sourcepackage, $src_version, $subsuite, $maintainer,
	 $source_directory, @source_files, @v_str, @uploaders,
	 @depends, @recommends, @suggests, @enhances, @conflicts, @provides,
	 %sizes_deb, %sizes_inst, $v_str, $v_str_arch );

    $subsuite   = $subsuites{max_unique}   || $SUBSUITE_DEFAULT;
    $section    = $sections{max_unique}    || $SECTION_DEFAULT;
    $subsection = $subsections{max_unique} || $SUBSECTION_DEFAULT;
    $priority   = $priorities{max_unique}  || $PRIORITY_DEFAULT;
    $essential  = $essential{max_unique}   || $ESSENTIAL_DEFAULT;
    $desc_md5   = $desc_md5s{max_unique};

    $maintainer      = $pkg->get_newest( 'maintainer' );
    $maintainer      = $maintainers{max_unique} if $maintainer eq 'CONFLICT';
    $maintainer    ||= $MAINTAINER_DEFAULT;

    $sourcepackage   = $pkg->get_newest( 'source' );
    $sourcepackage   = $sources{max_unique} if $sourcepackage eq 'CONFLICT';
    $sourcepackage ||= $name;

    if ( $sourcepackage =~ s/\s*\((.*)\)\s*$//o ) {
	$src_version = $1;
    } else {
	$src_version = $version;
    }
    my $src_pkg = $db->get_src_pkg( $sourcepackage );
    if ( $src_pkg && !exists $src_pkg->{versions}{$src_version} ) {
	$src_version = ($src_pkg->get_version_list)[0];
    }
    if ( $src_pkg ) {
	my $src_files = $src_pkg->{versions}{$src_version}{files};
	$source_directory = $src_pkg->{versions}{$src_version}{directory};
	$src_files =~ s/\A\s*//o; # remove leading spaces
	foreach my $sf ( split( /\n\s*/, $src_files ) ) {
	    # md5, size, name
	    push @source_files, [ split( /\s+/, $sf) ];
	}
    }

    #
    # process version
    #
    my @versions = keys %{$versions{unique}};
    if ( scalar @versions == 1 ) {
	@v_str = ( [ $version, undef ] );
	$v_str = $version;
	$v_str_arch = $version;
    } else {
	my @v_str_arch;
	foreach ( @versions ) {
	    push @v_str, [ $_, $versions{v2a}{$_} ];
	    push @v_str_arch, "$_ [".join(', ', @{$versions{v2a}{$_}})."]";
	}
	$v_str_arch = join( ", ", @v_str_arch );
	$v_str = join( ", ",  version_sort( keys %{$versions{unique}} ) );
    }

    #
    # process maintainer and uploaders
    #
    push @uploaders, [ split_name_mail( $maintainer ) ];
    if ($src_pkg && exists $src_pkg->{versions}{$src_version}{uploaders}) {
	my @up_tmp = split( /\s*,\s*/, 
			    $src_pkg->{versions}{$src_version}{uploaders} );
	foreach my $up (@up_tmp) {
	    if ($up ne $maintainer) { # weed out duplicates
		push @uploaders, [ split_name_mail( $up ) ];
	    }
	}
    }
    
    my ( $is_security, $is_nonus ) = ( 0, 0 );
    if ( $subsuite ) {
	# a package can be in subsuite "non-US/security"
	# then both $is_nonus and $is_security are true
	$is_nonus = ($subsuite =~ /non-US/o);
	$is_security = ($subsuite =~ /security/o);
    }

    foreach my $arch (keys %{$inst_sizes{a2f}}) {
	$sizes_inst{$arch} = $inst_sizes{a2f}{$arch};
    }
    foreach my $arch (keys %{$file_sizes{a2f}}) {
	$sizes_deb{$arch} = floor(($file_sizes{a2f}{$arch}/102.4)+0.5)/10;
    }

    @depends    = $self->_make_deps( $db, $pkg, \%versions, 'depends' );
    @recommends = $self->_make_deps( $db, $pkg, \%versions, 'recommends' );
    @suggests   = $self->_make_deps( $db, $pkg, \%versions, 'suggests' );
    @enhances   = $self->_make_deps( $db, $pkg, \%versions, 'enhances' );
    @conflicts  = $self->_make_deps( $db, $pkg, \%versions, 'conflicts' );
    @provides   = $self->_make_deps( $db, $pkg, \%versions, 'provides' );

    $self->{data} = {
	version       => $version,
	v_str         => \@v_str,
	v_str_simple  => $v_str,
	v_str_arch    => $v_str_arch,
	subsuite      => $subsuite,
	section       => $section,
	subsection    => $subsection,
	priority      => $priority,
	essential     => $essential,

	desc_md5      => $desc_md5,
	
	uploaders     => \@uploaders,

	sizes_inst    => \%sizes_inst,
	sizes_deb     => \%sizes_deb,
	
	src_name      => $sourcepackage,
	src_version   => $src_version,
	src_directory => $source_directory,
	src_files     => \@source_files,
	
	depends       => \@depends,
	recommends    => \@recommends,
	suggests      => \@suggests,

	is_security   => $is_security,
	is_nonus      => $is_nonus,
    };
    return $self->{data};
}

=pod

=item C<architectures>

FIXME

=cut

sub architectures {
    my $self = shift;
    $self->{config}{architectures} = [ @_ ] if @_;
    $self->{config}{architectures} ||= [];
    return @{$self->{config}{architectures}};
}

sub _make_deps {
    my ( $self, $db, $pkg, $versions, $type) = @_;
    my @all_archs = ( $self->architectures, 'all' );
    my ( %dep_pkgs, %arch_deps );
    foreach my $a ( @all_archs ) {
	next unless ( exists $versions->{a2v}{$a}
		      && exists $pkg->{versions}{$versions->{a2v}{$a}}{$a}{$type} );
	my @a_deps = @{$pkg->{versions}{$versions->{a2v}{$a}}{$a}{$type}};
	foreach my $d ( @a_deps ) { # splitted by ,
	    my ( @dep_str, $dep_str );
	    foreach ( @$d ) { # splitted by |
		$_->[1] ||= ""; $_->[2] ||= "";
		push @dep_str, "$_->[0]($_->[1]$_->[2])";
	    }
	    $dep_str = join( "|", @dep_str );
	    $dep_pkgs{$dep_str} = $d;
	    $arch_deps{$a}{$dep_str}++;
	}
    }
    @all_archs = sort keys %arch_deps;
#    print Dumper( \%dep_pkgs, \%arch_deps );
    
    my @deps;
    if ( %dep_pkgs ) {
	my $old_pkgs = '';
	my $is_old_pkgs = 0;
	foreach my $dp ( sort keys %dep_pkgs ) {
	    my @dp_alts = @{$dep_pkgs{$dp}};
	    my ( @pkgs, $pkgs );
	    foreach (@dp_alts) { push @pkgs, $_->[0]; }
	    $pkgs = "@pkgs";

	    unless ( $is_old_pkgs = ($pkgs eq $old_pkgs) ) {
		$old_pkgs = $pkgs;
	    }
	    
	    my ($arch_neg, $arch_str) = _compute_arch_str ( $dp, $versions,
							    \%arch_deps,
							    \@all_archs );

	    my @res_pkgs; my $pkg_ix = 0;
	    foreach my $p_name ( @pkgs ) {
		if ( $pkg_ix > 0 ) { $arch_str = ""; }
		
		my $pkg_version = "";
		$pkg_version = "$dep_pkgs{$dp}[$pkg_ix][1] $dep_pkgs{$dp}[$pkg_ix][2]"
		    if $dep_pkgs{$dp}[$pkg_ix][1];

		if ( my $p = $db->get_pkg( $p_name ) ) {
		    my $subsection;
		    if ($p->is_virtual) {
			$subsection = "virtual";
		    } else {
			my %subsections = $p->get_arch_fields( 'section',
							       $self->architectures );
			$subsection = $subsections{max_unique} ||
			    $SUBSECTION_DEFAULT;
		    }

		    push @res_pkgs, [ $p_name, $pkg_version, $arch_neg,
				      $arch_str, $subsection, 1 ];
		} elsif ( $is_old_pkgs ) {
		    push @res_pkgs, [ $p_name, $pkg_version, $arch_neg,
				      $arch_str, undef, 0 ]; #why handled I one this special?
		} else {
		    push @res_pkgs, [ $p_name, $pkg_version, $arch_neg,
				      $arch_str, undef, 0 ];
		}
		$pkg_ix++;
	    }
	    push @deps, [ $is_old_pkgs, @res_pkgs ];
	}
    }
    return @deps;
}

sub _compute_arch_str {
    my ( $dp, $versions, $arch_deps, $all_archs, $is_src_dep ) = @_;

#FIXME
#    if ($is_src_dep) {
#	return _compute_src_arch_str( @_ );
#    }

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
    my $arch_neg = 0;
    if ( @dependend_archs == @$all_archs ) {
	$arch_str = "";
    } else {
	if ( @dependend_archs > (@$all_archs/2) ) {
	    $arch_neg = 1;
	    $arch_str = join( ", ", @not_dependend_archs);
	} else {
	    $arch_str = join( ", ", @dependend_archs);
	}
    }
    return my @ret = ( $arch_neg, $arch_str );
}


1;

__END__

=head1 BUGS

=head1 COPYRIGHT

Copyright 2004 Frank Lichtenheld <frank@lichtenheld.de>

This file is distributed under the terms of the GNU Public
License, Version 2. See the source code for more details.

=head1 SEE ALSO

Packages::DB, Packages::Pkg
