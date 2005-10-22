#
# Packages::Pkg
# $Id$
#
# Copyright 2003 Frank Lichtenheld <frank@lichtenheld.de>
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

Packages::Pkg - Utility class for Packages::DB to handle Debian package informations

=head1 SYNOPSIS

    use Packages::Pkg;

    my $p = Packages::Pkg->new( "apt" );

    $p->add_version( ... ) #FIXME

    print $p->get_name."\n";

=head1 DESCRIPTION

=head1 Class Methods

=over 4

=cut

package Packages::Pkg;

use strict;
use warnings;

use Digest::MD5;
use Storable;

use Deb::Versions;

our $VERSION = 0.1;
our $RCS_VERSION = '$Revision$';

# ===============
# | Constructor |
# ===============

=pod

=item C<new>

Creates a new Packages::Pkg object. You can optionally specify
the package name as parameter.

=cut

sub new {
    my $classname = shift;
    my $name = shift || '';
    my $config = shift || {};
    my $self = {};
    bless( $self, $classname );

    if ($name) {
	$self->{package} = $name;
    } else {
	$self->{package} = "";
    }

    $self->{versions} = {};
    $self->{config} = $config;

    return $self;
}

=pod

=item C<copy>

Return (using L<Storable> modul) a copy of the Pkg object.

=cut

sub copy {
    my $self = shift;

    my $ret = Storable::dclone( $self );
    return bless( $ret, ref $self );
}

=pod

=item C<lock>,C<unlock>

Locks/unlocks the object. All attempts to change a locked object
through a member function will result in an exception.

=item C<is_locked>

Returns a true value, if the object is locked and a false one
otherwise.

=cut

sub lock {
    my $self = shift;

    $self->{locked} = 1;
}

sub unlock {
    my $self = shift;

    $self->{locked} = 0;
}

sub is_locked {
    my $self = shift;

    return $self->{locked};
}

=pod

=item C<build_cache>

FIXME

=cut

sub build_cache {
    my $self = shift;
    my @archs = @_;

    push @archs, 'all'; #FIXME

    $self->{cached} = 0;
    $self->{cache}->{versions_list} = [ $self->get_version_list ];
    $self->{cache}->{arch_versions} = { $self->get_arch_versions( \@archs ) };

    foreach my $f ( qw( archive section uploaders priority essential
			size installed-size distribution subdistribution 
			maintainer source filename md5sum ) )
    {
	$self->{cache}->{"arch_$f"} = { $self->get_arch_fields( $f, \@archs, 'cache_mode' ) };
    }
    foreach my $f ( qw( description-md5 ) )
    {
	$self->{cache}->{"arch_$f"} = { $self->get_arch_fields( $f, \@archs ) };
    }
    $self->{cached} = 1;
}

=pod

=item C<add_version>

Add data for a particular version to the package object.
Expects a hash ref a parameter, with the fieldnames as keys
of the array.

=cut

sub add_version {
    my ( $self, $data ) = @_;

    if ( $self->is_locked ) {
	$self->_error( "add_version: db is locked" );
	return 0;
    }

    # copy the data as we want to modify it
    $data = Storable::dclone( $data );
    my $name = $self->get_name;

    # check required fields, if wanted
    if ( $self->{config}->{checkFields} ) {
	my $field_checks = { 'package' => $name ? qr/\Q$name\E/ : '' ,
			     'installed-size' => qr/\d+/,
			     architecture => '',
			     version => '',
			     distribution => '',
			     source => '',
			     size => qr/\d+/,
			 };
	unless ( $self->_check_fields( $data, $field_checks ) ) {
	    $self->_error( "add_version:$name: field check failed" );
	    return 0;
	}
    }

    # we do not save the description, only the md5sum
    # the db is responsible for saving the description
    if ( $data->{description} ) {
	$data->{'description-md5'} =
	    Digest::MD5::md5_hex( $data->{description} );
    } else {
    	$self->_warn( "add_version:$name: no description found\n" );
	$data->{'description-md5'} = "";
    }
    delete $data->{description};

    # ensure we have no superfluous newlines left
    # this has to be after description handling because this
    # would change the MD5 sum otherwise
    foreach (keys %$data) {
	chomp $data->{$_} if $data->{$_};
    }

    unless ( $self->_preprocess_section( $data ) ) {
	return 0;
    }

    unless ( exists $data->{source} ) {
	$data->{source} = $name;
    }

    my $old_newest = ($self->get_version_list)[0] || "";

    $self->{versions}->{$data->{version}} ||= {};
    my $v_self = $self->{versions}->{$data->{version}};

    # check if we overwrite a existing entry
    my $overwrt = 0;
    if ( $v_self ) {
	if ( exists $v_self->{$data->{architecture}} ) {
	    unless ( $data->{architecture} eq 'all' ) { #FIXME
		$self->_warn( "add_version:$name overwriting existing".
		    " version entry".
		    " for arch $data->{architecture}".
		    " version $data->{version}" );
		$overwrt = 1;
	    }
	}
    }
#   delete $data->{version};

    if ( $overwrt ) {
	my $a_self = $v_self->{$data->{architecture}};
	if ( ! defined $a_self ) {
	    die "$name\n";
	}
	if ( ref $a_self->{distribution} ) {
	    $a_self->{distribution}->{$data->{distribution}}++;
	    delete $data->{distribution};
	} elsif ( $a_self->{distribution} 
		  ne $data->{distribution} ) {
	    $a_self->{distribution} = { $a_self->{distribution} => 1,
					$data->{distribution} => 1 };
	    delete $data->{distribution};
	}
	foreach my $k ( keys %$data ) {
	    if ( ( ! exists( $a_self->{$k} ) )
		 || ( ! $a_self->{$k} )
		 || ( $a_self->{$k} ne $data->{$k} ) ) {
		my $oldval = $a_self->{$k} ? $a_self->{$k} : ""; # supress warning
#		unless( $name && $k && defined($oldval) && $data->{$k} ) {
#		    print Dumper( $data, $name, $k, $oldval );
#		    die;
#		}
		$self->_debug( "add_version:$name: replacing $k\n"
			       . "\t$oldval => $data->{$k}" );
		$a_self->{$k} = $data->{$k};
	    }
	}
    } else {
	$v_self->{$data->{architecture}} = $data;
    }

    if (($self->get_version_list)[0] ne $old_newest) {
    	$self->_update_newest;
    }

    return 1;
}

=pod

=item C<add_reverse_rel>

FIXME

=cut

sub add_reverse_rel {
    my ( $self, $rel, $pkg, $version, $arch, $constraint ) = @_;

    $constraint ||= "";

    if ( $self->is_locked ) {
	$self->_error( "add_provided_by: db is locked" );
	return 0;
    }

    $self->_debug( "add reverse rel $rel from $self->{package} to $pkg" );

    $self->{rr}{$rel} = {} unless exists $self->{rr}{$rel};
    $self->{rr}{$rel}{$pkg}{$version}{$arch} = []
	unless exists $self->{rr}{$rel}{$pkg}{$version}{$arch};
    push @{$self->{rr}{$rel}{$pkg}{$version}{$arch}}, $constraint;
}

=pod

=item C<delete_version>

FIXME

=cut

sub delete_version {
    my $self = shift;
    my $version = shift;

    if ( $self->is_locked ) {
	$self->_error( "delete_version: db is locked" );
	return 0;
    }

    return delete $self->{versions}{$version};
}

# ======================
# | Access Information |
# ======================

sub get_name {
    my $self = shift;
    return $self->{'package'};
}

sub is_virtual {
    my $self = shift;

    if ( ! %{$self->{versions}}
	 && ( exists $self->{rr}{provides}
	      || exists $self->{rr}{enhances} ) ) {
	return 1;
    }
    return 0;
}

sub each_version {
    my $self = shift;
    
    return each %{$self->{versions}};
}

sub get_version {
    my $self = shift;
    
    # version by string
    if ( @_ == 1 ) {
	if ( wantarray ) {
	    return exists $self->{versions}{$_[0]} ?
		%{$self->{versions}{$_[0]}} : undef;
	} else {
	    return exists $self->{versions}{$_[0]} ?
		$self->{versions}{$_[0]} : undef;
	}
    }
    my ( $dist, $subdist, $arch ) = @_;
    if ( !$arch ) {
	$arch = $subdist;
	$subdist = undef;
    }
    return undef if !( $dist && $arch );

    my @v_list = $self->get_version_list;
    # version by distribution and arch
    foreach ( @v_list ) {
	( my $v_self = $self->{versions}->{$_}->{$arch} || 
	    $self->{versions}->{$_}->{'all'} ) or next;
	if ( $v_self->{distribution}
	     eq $dist ) {
	    if ( ! $subdist || ( $v_self->{subdistribution}
				 eq $subdist ) ) {
		if ( wantarray ) {
		    return %{$self->{versions}{$_}};
		} else {
		    return $self->{versions}{$_};
		}
	    }
	}
    }
    return undef;
}

sub get_version_list {
    if ( $_[0]->{cached} ) {
	return @{$_[0]->{cache}->{versions_list}};
    } else {
	return version_sort( keys %{$_[0]->{versions}} );
    }
}

sub get_most_used {
    my %data;
    return undef if ! $_[0];
    %data = %{$_[0]};

    my $most_used;
    my $most_num = 0;
    foreach ( keys %data ) {
	if ( $data{$_} > $most_num ) {
	    $most_used = $_;
	    $most_num = $data{$_};
	}
    }
    return $most_used;
}

sub get_newest {
    my ( $self, $field ) = @_;

    return $self->{newest}->{$field};
}

sub get_arch_versions {
    my ( $self, $archs ) = @_;

    if ( $self->{cached} ) {
	return %{$self->{cache}{arch_versions}};
    }

    my @v_list = $self->get_version_list;
    my %versions;
  ARCH:
    foreach my $a ( ( @$archs, 'all' ) ) {
	foreach my $v ( @v_list ) {
	    if ( exists($self->{versions}{$v}{$a})
		 && !exists($versions{a2v}{$a})) {
		$versions{unique}{$v}++;
		$versions{a2v}{$a} = $v;
		push @{$versions{v2a}{$v}}, $a; 
		next ARCH;
	    }
	}
    }
    $versions{max_unique} = get_most_used( $versions{unique} )
	if %versions;

    return %versions;
}

sub get_arch_fields {
    my ( $self, $field, $archs, $cache_mode ) = @_;

    if ( $self->{cached} ) {
	return exists $self->{cache}{"arch_$field"} ?
	    %{$self->{cache}{"arch_$field"}} :
	    undef;
    }

    $cache_mode ||= 0;
    if ( $cache_mode eq 'cache_mode' ) {
	$cache_mode = 1;
    } else {
	$cache_mode = 0;
    }

    my @v_list = $self->get_version_list;
    my %fields;
  ARCH:
    foreach my $a ( ( @$archs, 'all' ) ) {
	foreach my $v ( @v_list ) {
	    if ( exists($self->{versions}{$v}{$a})
		 && !exists($fields{a2f}{$a}) ) {
		if ( defined(my $value = $self->{versions}{$v}{$a}{$field} )) {
		    $fields{unique}{$value}++;
		    $fields{a2f}{$a} = $value;
		    push @{$fields{f2a}{$value}}, $a;
		    delete $self->{versions}{$v}{$a}{$field} if $cache_mode;
		}
		next ARCH;
	    }
	}
    }
    $fields{max_unique} = get_most_used( $fields{unique} )
	if %fields;

    return %fields;
}

# ======================
# | Internal Functions |
# ======================

use Data::Dumper;

sub _check_fields {
    my ( $self, $data, $checks ) = @_;

    foreach my $k ( keys %$checks ) {
	unless ( exists $data->{$k} ) {
	    $self->_warn( "_check_fields: field $k does not exist", 
			  Dumper( $data ) );
	    return 0;
	}
	if ( $checks->{$k} && ! ( $data->{$k} =~ /^$checks->{$k}$/ )) {
	    $self->_warn( "_checks_fields: field $k does not meet"
		. " the criterion /^$checks->{$k}\$/" );
	    return 0;
	}
    }
    return 1;
}

sub _error {
    my $self = shift;
    die "E: @_\n" if $self->{config}->{dieOnError};
    warn "E: @_\n";
}

sub _warn {
    my $self = shift;
    warn "W: @_\n" if $self->{config}->{warn};
}

sub _debug {
    my $self = shift;
    print "D: @_\n" if $self->{config}->{debug};
}


sub _preprocess_section {    
    my ( $self, $data ) = @_;
    my $name = $self->get_name;

    # preprocess section
    # remove the non-free/contrib part since we
    # save it in archive
    # handle non-US security updates
    if ( exists $data->{section} ) {
	if ( $data->{section} =~ m,non-US/(.+)$,io ) {
	    unless ( $data->{subdistribution} eq 'non-US' ) {
		$self->_error( "add_version:$name:".
		    "expected value non-US for".
		    " field subdistribution".
		    " (was $data->{subdistribution})" );
		return 0;
	    }
	    unless ( $data->{archive} eq $1 ) {
		$self->_error( "add_version:$name:".
		    "expected value $1 for".
		    " field archive".
		    " (was $data->{archive})" );
		return 0;
	    }
	    $data->{section} = 'non-US';
	} elsif ( $data->{section} =~ m,(contrib|non-free)/(.+)$,io ) {
	    unless ( $data->{archive} eq $1 ) {
                $self->_error( "add_version:$name:".
		    "expected value $1 for".
                    " field archive".
                    " (was $data->{archive})" );
                return 0;
            }
	    $data->{section} = $2;
	} elsif ( $data->{subdistribution}
		  && ( $data->{subdistribution} eq 'security' )
		  && ( $data->{section} eq 'non-US' ) ) {
	    $data->{subdistribution} = 'non-US/security';
	}
    }
    if ( exists $data->{archive} ) {
	if ( $data->{archive} eq 'main/debian-installer' ) {
	    $data->{archive} = 'debian-installer';
	}
    }
    return 1;
}

sub _update_newest {
    my $self = shift;
    
    my $version = ($self->get_version_list)[0];
    $self->{newest}{version} = $version;

    my @all_archs = $self->get_used_archs;
    my %all_versions = $self->get_arch_versions(\@all_archs);
    if (!defined $all_versions{v2a}{$version}) {
    	$self->_error( "No information about the newest version ($version) available", Dumper($self));
    }
    my @archs = @{$all_versions{v2a}{$version}};

    foreach my $f ( qw( archive section uploaders
			size installed-size distribution subdistribution 
			maintainer source filename md5sum ) ) {
	my %values = ();
	foreach my $a (@archs) {
		if (exists $self->{versions}{$version}{$a}{$f}
	  	    && defined $self->{versions}{$version}{$a}{$f}) {
			$values{$self->{versions}{$version}{$a}{$f}}++;
		}
	}
	if (scalar( keys %values ) == 1) {
		$self->{newest}{$f} = (keys %values)[0];
	} elsif (scalar( keys %values ) > 1) {
		$self->{newest}{$f} = "CONFLICT";
	}
    }
}

sub get_used_archs {
	my $self = shift;

	my %archs = ();
	foreach (values %{$self->{versions}}) {
		foreach (keys %$_) {
			$archs{$_}++;
		}
	}
	return keys %archs;
}

1;

__END__

=head1 BUGS

=head1 COPYRIGHT

Copyright 2003, 2004 Frank Lichtenheld <frank@lichtenheld.de>

This file is distributed under the terms of the GNU Public
License, Version 2. See the source code for more details.

=head1 SEE ALSO

Packages::DB, Packages::SrcPkg
