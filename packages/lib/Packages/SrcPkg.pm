package Packages::SrcPkg;

use strict;
use warnings;

use Packages::Pkg;
use Data::Dumper;
our @ISA = qw( Packages::Pkg );

our $VERSION = 0.01;

sub add_version {
    my ( $self, $data ) = @_;

    if ( $self->is_locked ) {
	$self->_error( "add_version: db is locked" );
	return 0;
    }

    # copy the data as we want to modify it
    $data = Storable::dclone( $data );
    my $name = $self->get_name;
    
    # check required field
    my $field_checks = { 'package' => $name ? qr/\Q$name\E/ : '' ,
		      architecture => '', 
		      version => '',
		      distribution => '', 
#		      'standards-version' => '',
		      binary => '', 
		      files => '',
		  };
    unless ( $self->_check_fields( $data, $field_checks ) ) {
	$self->_error( "add_src_version:$name: field check failed" );
	return 0;
    }

    unless ( $self->_preprocess_section( $data ) ) {
	return 0;
    }

    my $overwrt = 0;
    if ( exists $self->{versions}->{$data->{version}} ) {
	$overwrt = 1;
    } else {
	$self->{versions}->{$data->{version}} = {};
    }
    my $v_self = $self->{versions}->{$data->{version}};
    #delete $data->{version};

    if ( $overwrt ) {
	if ( ref $v_self->{distribution} ) {
	    $v_self->{distribution}->{$data->{distribution}}++;
	    delete $data->{distribution};
	} elsif ( $v_self->{distribution} 
		  ne $data->{distribution} ) {
	    $v_self->{distribution} = { $v_self->{distribution} => 1,
					$data->{distribution} => 1 };
	    delete $data->{distribution};
	}
	foreach my $k ( keys %$data ) {
	    if ( ( ! exists ( $v_self->{$k} ) )
		 || ( ! $v_self->{$k} )
		 || ( $v_self->{$k} ne $data->{$k} ) ) {
		my $oldval = $v_self->{$k} ? $v_self->{$k} : ""; # supress warning
		$self->_debug( "add_version:$name: replacing $k\n"
			       . "\t$oldval => $data->{$k}" );
		$v_self->{$k} = $data->{$k};
	    }
	}
    } else {
	%$v_self = %$data;
    }

    return 1;
}

sub is_virtual {
    return 0;
}

sub build_cache {
    return;
}

sub get_arch_versions {
    die "invalid operation";
}
sub get_arch_fields {
    die "invalid operation";
}
sub add_reverse_rel {
    die "invalid operation";
}
