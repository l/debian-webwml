#
# Packages::DB
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

Packages::DB - handle Debian package information

=head1 SYNOPSIS

    use Packages::DB;

    my $db = Packages::DB->init();
    $db->read_file( "Packages" );

    print $db->get_stats;

=head1 DESCRIPTION

=head2 Class Methods

=over 4

=cut

package Packages::DB;

use strict;
use warnings;

use Packages::Pkg;
use Packages::SrcPkg;

use Digest::MD5;
use Parse::DebControl;
use Data::Dumper;
use MLDBM qw( DB_File Storable );
use Fcntl;

our $VERSION = 0.1;
our $RCS_VERSION = '$Revision$';

=pod

=item C<init>

Accepts a hash ref as parameter in which you can give some options 
Supported options:

=over 4

=item C<storage>

If set to 'memory', Packages::DB will store all data in memory.
This can be a huge amount! When you load the complete unstable
distribution with all architectures, expect 600 MB of memory usage.

The default is to use the MLDBM module to store the data in a DB_File.
This can be much slower, but uses only 60 MB of memory in the example
mentioned above.

=item C<dbfile> and C<srcdbfile>

If you use the MLDBM method for storing the data, you can specify
here the used filenames for storing the data about packages and
source packages. Defaults to 'dbfile' and 'srcdbfile' in the working
directory.

=item C<verbose>

If this has a true value, messages are printed.

=item C<debug>

Even more verbose.

=back

=cut

sub init {
    my $classname = shift;
    my $config = shift || {};
    my $self = {};
    bless( $self, $classname );

    $config->{verbose} = 1 if $config->{debug};

    my ( %db, %srcdb );
    unless ( lc($config->{storage}) eq 'memory' ) {
	my $fname = $config->{dbfile} || 'dbfile'; 
	my $sfname = $config->{srcdbfile} || 'srcdbfile'; 
	tie %db, 'MLDBM', $fname, O_CREAT|O_RDWR, 0640 
	    or die "E: tie with file $fname failed: $!";
	tie %srcdb, 'MLDBM', $sfname, O_CREAT|O_RDWR, 0640 
	    or die "E: tie with file $sfname failed: $!";
    }
    $self->{db} = \%db;
    $self->{srcdb} = \%srcdb;
    $self->{config} = $config;

    return $self;
}

=pod

=item C<read_file>

Parse a file with Packages::Parser and read it in with merge_in().
Gets two parameters, the filename and some metadata about the
readed Packages file as second. For details see the documentation
for merge_in().

=cut

sub read_file {
    my $self = shift;
    my $file = shift;
    my $dbdata = shift || {};
    
    print "D: read_file: read in file $file\n" if $self->{config}{debug};
    my $parser = Parse::DebControl->new();
    my $data;
    if ($self->{config}{debug}) {
    	$parser->DEBUG();
    }

    unless ( -r $file ) {
	warn "\nW: read_file: file $file doesn't exist\n"
	    if $self->{config}{verbose};
	return;
    }
    unless ( -z _ ) {
	unless ( $data = $parser->parse_file( $file, 
					      { discardCase => 1,
						verbMultiLine => 1 } ) ) {
	    warn "\nW: read_file: parser failed for file $file\n"
		if $self->{config}{verbose};
	    return;
	}
    } else {
	warn "\nW: init: file $file is empty\n" 
	    if $self->{config}{verbose};
    }

    $self->merge_in( $data, $dbdata );
}

=pod

=item C<lock>, C<unlock>, C<is_locked>

The DB can be locked. This means that all functions will refuse
to change something at the data. This is mostly useful in conjunction
with build_cache() to make sure that your program doesn't try to change
any values afterwards.

All three functions get no parameters. And I think you can guess the
return value of is_locked() ?

=cut

sub lock {
    my $self = shift;

    print "D: lock db, " if $self->{config}->{debug};
    $self->{locked} = 1;
    print "packages, "  if $self->{config}->{debug};
    foreach my $p ( keys %{$self->{db}} ) {
	my $pkg = $self->{db}->{$p};
	$pkg->lock;
	$self->{db}->{$p} = $pkg;
    }
    print "source packages\n"  if $self->{config}->{debug};
    foreach my $sp ( keys %{$self->{srcdb}} ) {
	my $pkg = $self->{srcdb}->{$sp};
	$pkg->lock;
	$self->{srcdb}->{$sp} = $pkg;
    }
}

sub unlock {
    my $self = shift;

    print "D: unlock db, " if $self->{config}->{debug};
    $self->{locked} = 0;
    print "packages, " if $self->{config}->{debug};
    foreach my $p ( values %{$self->{db}} ) {
	$p->unlock;
    }
    print "source packages" if $self->{config}->{debug};
    foreach my $sp ( values %{$self->{srcdb}} ) {
	$sp->unlock;
    }
    print ".\n" if $self->{config}->{debug};
}

sub is_locked {
    my $self = shift;

    return $self->{locked};
}

=pod

=item C<build_cache>

This builds a cache with the results of the mostly used acess functions,
notably get_arch_fields().

I<WARNING:> At the moment, this functions destroys the normal
package data to save memory space. You can not add more data
later. This is not configurable. I don't decided yet if this
is a bug or a feature.

=cut

sub build_cache {
    my $self = shift;

    print "BUILD CACHE\n" if $self->{config}->{verbose};
    my $maxnum = keys %{$self->{db}};
    my $num = 0;
    foreach my $p ( keys %{$self->{db}} ) {
	print "\r$num/$maxnum" if $self->{config}->{verbose};
	my $pkg = $self->{db}->{$p};
	$pkg->build_cache( @_ );
	$self->{db}->{$p} = $pkg;
	$num++;
    }
    print "\n" if $self->{config}->{verbose};;
    $maxnum = keys %{$self->{srcdb}};
    $num = 0;
    foreach my $sp ( keys %{$self->{srcdb}} ) {
	print "\r$num/$maxnum" if $self->{config}->{verbose};
	my $srcpkg = $self->{srcdb}->{$sp};
	$srcpkg->build_cache( @_ );
	$self->{srcdb}->{$sp} = $srcpkg;
	$num++;
    }
    print "\n" if $self->{config}->{verbose};
}

=pod

=item C<pkg_exists> and C<src_pkg_exists>

Self explanatory.

=cut

sub pkg_exists {
    my ( $self, $pkg ) = @_;
    
    return (exists($self->{db}{$pkg}) && defined($self->{db}{$pkg}));
}

sub src_pkg_exists {
    my ( $self, $pkg ) = @_;
    
    return (exists($self->{srcdb}{$pkg}) && defined($self->{srcdb}{$pkg}));
}


=pod

=item C<new_pkg> and C<new_src_pkg>

Gets the package name as only parameter. Constructs a new
package with C<Packages::(Src)Pkg-E<gt>new( I<pkgname> )> if it
doesn't already exists. Does nothing if it does. It returns true
if the package was constructed, false otherwise.

Dies if the the object is locked.

=cut

sub new_pkg {
    my ( $self, $pkg ) = @_;

    if ( $self->is_locked ) {
	die "E: new_pkg: db is locked";
    }

    unless ( $self->pkg_exists( $pkg ) ) {
	$self->{db}->{$pkg} = Packages::Pkg->new( $pkg );
	return 1;
    }
    return 0;
}

sub new_src_pkg {
    my ( $self, $pkg ) = @_;

    if ( $self->is_locked ) {
	die "E: new_src_pkg: db is locked";
    }

    unless ( $self->src_pkg_exists( $pkg ) ) {
	$self->{srcdb}->{$pkg} = Packages::SrcPkg->new( $pkg );
	return 1;
    }
    return 0;
}

=pod

=item C<rm_pkg>

Removes a package.

Dies if the object is locked.

=cut

sub rm_pkg {
    my $self = shift;
    my $pkg = shift;

    if ( $self->is_locked ) {
	die "E: rm_pkg: db is locked";
    }

    delete $self->{db}->{$pkg};
}

=pod

=item C<each_pkg>

Returns the same as a each call on a hash with the package
names as keys and the Packages::Pkg objects as values.

See perlfunc.

=cut

sub each_pkg {
    my $self = shift;
    
    return each %{$self->{db}};
}

=pod

=item C<get_pkg> and C<get_src_pkg>

Gets the package name as parameter.
Returns the corresponding Packages::(Src)Pkg object and an
undefined value if no package with this name exists.

=cut

sub get_pkg {
    my ( $self, $pkg ) = @_;

    return exists( $self->{db}->{$pkg} ) ? $self->{db}->{$pkg} : undef;
}


sub get_src_pkg {
    my $self = shift;
    my $pkg = shift;

    return exists( $self->{srcdb}->{$pkg} ) ? $self->{srcdb}->{$pkg} : undef;
}

=pod

=item C<get_sorted_list>

Returns a list with all package names, sorted with the default sorting
sheme of the sort function.

See perlfunc.

=cut

sub get_sorted_list {
    my $self = shift;

    return sort keys %{$self->{db}};
}

=pod

=item C<get_sorted_srclist>

Returns a list with all source package names, sorted with the default sorting
sheme of the sort function.

See perlfunc.

=cut

sub get_sorted_srclist {
    my $self = shift;

    return sort keys %{$self->{srcdb}};
}

=pod

=item C<is_translated>

Parameters: package name, package version, architecture, and language
Returns true if a translation of the package description exists.
All parameters are mandatory.

=cut

sub is_translated {
    my ( $self, $pkg_name, $v_str, $arch, $lang ) = @_;

    my $pkg = $self->get_pkg( $pkg_name );
    return exists $self->{desc}->{$pkg->{versions}->{$v_str}->{$arch}->{'description-md5'}}->{"description-".lc( $lang )};
}

=pod 

=item C<get_desc>, C<get_short_desc>, C<get_long_desc>

There are two possible calling methods
With package name, version, architecture, and language
or only with description's md5sum and language

get_desc() returns the whole description, get_short_desc()
only the first line, get_long_desc() all but the first line.

Returns an undefined value in case of error.

=cut

sub get_desc {
    my ( $self, $pkg_name, $pkg, $md5, $v_str, $arch, $lang );
    if ( @_ == 5 ) {
	( $self, $pkg_name, $v_str, $arch, $lang ) = @_;
	$pkg = $self->get_pkg( $pkg_name );
	return undef unless $pkg;
	$md5 = $pkg->{versions}->{$v_str}->{$arch}->{'description-md5'};
    } elsif ( @_ == 3 ) {
	( $self, $md5, $lang ) = @_;
    } else {
	warn; #DEBUG
	return undef;
    }
    
    return undef unless $md5;

    my $desc;
    if ( $lang && ( $lang ne 'en' ) 
	 && exists( $self->{desc}->{$md5}->{"description-".lc( $lang )} ) ) {
	$desc = $self->{desc}->{$md5}->{"description-".lc( $lang )};
    } else {
	$desc = $self->{desc}->{$md5}->{description};
    }
    return $desc;
}

sub get_short_desc {
    my $self = shift;
    my $desc = $self->get_desc( @_ );
    my $short_desc;
    if ($desc) {
	( $short_desc ) = ( $desc =~ /^(.*?)$/m );
    }
    return $short_desc;
}

sub get_long_desc {
    my $self = shift;
    my $desc = $self->get_desc( @_ );
    if ($desc) {
	$desc =~ s/^.*?$//m;
    }
    return $desc;
}

=pod

=item C<merge_in>

Merges in data into the database.
Gets a array of hash refs as first parameter and some
meta data in a hash ref as second parameter. In the meta
data you should specify at least the distribution (e.g. 'stable'),
 the archive section (e.g. 'main') and the type of the data you're
merging ('binary' [default], 'source' or 'trans').

    merge_in( $data, { distribution => 'stable', archive => 'main' }

You can also specify a 'subdistribution', allowed values are
'security', 'volatile' and 'non-US'.

Dies if object is locked.

I<WARNING:> At the moment, this would not give the expected
results after a call to either build_cache() or calculate_depends().
But merge_in won't warn you about this problem but issue some more
or less cryptic error messages. To be fixed...

=cut

sub merge_in {
    my $self = shift;
    my $data = shift;
    my $db_data = shift;
    
    if ( $self->is_locked ) {
	die "E: merge_in: db is locked";
    }

    $db_data->{type} ||= 'binary';

    if ( ref($data) eq 'ARRAY' ) {
	print "MERGE_IN: ".scalar @$data." ENTRIES\n" 
	    if $self->{config}->{verbose};
      PKG:
	foreach my $entry ( @$data ) {
	    foreach ( qw( distribution subdistribution archive ) ) {
		$entry->{$_} = $db_data->{$_}; 
	    }
	    unless ( exists $entry->{package} ) {
		warn "W: merge_in: key package is missing\n"
		    if $self->{config}{verbose};
		next PKG;
	    }
	    my $new_pkg = 0;
	    my $success = 0;
	    if ( $db_data->{type} eq "source" ) {
		$new_pkg = $self->new_src_pkg( $entry->{package} );
		my $tmp_pkg = $self->{srcdb}->{$entry->{package}};
		
		$success = $tmp_pkg->add_version( $entry );
		$self->{srcdb}->{$entry->{package}} = $tmp_pkg;
	    } elsif ( $db_data->{type} eq "trans" ) {
		unless ( exists $entry->{'description-md5'} ) {
		    warn "W: missing description-md5 for translation"
			. " of package $entry->{package}\n"
			if $self->{config}{verbose};
		    next PKG;
		}
		my $e_self = $self->{desc}->{$entry->{'description-md5'}};
	      KEYS:
		foreach my $k ( keys %$entry ) {
		    if ( $k =~ /description-(?!md5)/o ) {
			$e_self->{$k} = $entry->{$k};
			$success = 1;
			push @{$e_self->{'package'}}, $entry->{'package'};
			last KEYS;
		    }
		}
	    } else {
		$new_pkg = $self->new_pkg( $entry->{package} );
		my $tmp_pkg = $self->{db}->{$entry->{package}};

		$success = $tmp_pkg->add_version( $entry );
		$self->{db}->{$entry->{package}} = $tmp_pkg;
	    }

	    if ( $success ) {
		if ( exists $entry->{provides} ) {
		    chomp $entry->{provides};
		    foreach my $p ( split /\s*,\s*/o, $entry->{provides} ) {
			$self->new_pkg( $p );
			my $tmp_pkg = $self->{db}->{$p}; 
			$tmp_pkg->add_reverse_rel( "provides", $entry->{package}, $entry->{version}, $entry->{architecture} );
			$self->{db}->{$p} = $tmp_pkg;
		    }
		}
		if ( exists $entry->{enhances} ) {
		    chomp $entry->{enhances};
		    if ($entry->{enhances} =~ /\|/) {
			warn "W: `|' in Enhances field for $entry->{package}\n"
			    if $self->{config}{verbose};
		    } else {
			foreach my $p ( split /\s*,\s*/, $entry->{enhances} ) {
			    my $wv = ( $p =~ s/\s*\((.*)\)\s*//o );
			    $self->new_pkg( $p );
			    my $tmp_pkg = $self->{db}->{$p}; 
			    $tmp_pkg->add_reverse_rel( "enhances", $entry->{package}, $entry->{version}, $entry->{architecture},
						       $wv ? $1 : undef );
			    $self->{db}->{$p} = $tmp_pkg;
			}
		    }
		}
		if ( exists $entry->{description} ) {
		    unless ( exists $entry->{'description-md5'} ) {
			$entry->{'description-md5'} =
			    Digest::MD5::md5_hex( $entry->{description} );
		    }
		    $self->{desc}->{$entry->{'description-md5'}}->{description} =
			$entry->{description};
		}
	    } else {
		$self->rm_pkg( $entry->{package} ) if $new_pkg;
	    }
	} # foreach my $entry ( @$data )
    $self->calculate_depends() unless $db_data->{noDepends};
    } # if ( ref($data) eq 'ARRAY' )
} # sub merge_in

=pod

=item C<calculate_depends>

This transforms the string of the dependency fields of all
packages and src packages from strings to more easily
usable array of arrays (format not yet documented).

I<WARNING:> At the moment, this functions destroys the normal
package data to save memory space. You can not add more data
later. This is not configurable.

=cut

sub calculate_depends {
    my $self = shift;

    print "CALCULATE DEPENDS\n" if $self->{config}->{verbose};
    my $max_num = keys %{$self->{db}};
    my $num = 0;
    foreach my $p ( keys %{$self->{db}} ) {
	my $pkg = $self->{db}->{$p};
	print "\r$num/$max_num" if $self->{config}->{verbose};
	foreach my $v ( values %{$pkg->{versions}} ) {
	    foreach my $a ( values %$v ) {
		if (exists $a->{"pre-depends"}) {
		    if ($a->{depends}) {
			$a->{depends} .= ", $a->{'pre-depends'}";
		    } else {
			$a->{depends} = $a->{'pre-depends'};
		    }
		}
		foreach ( qw( depends pre-depends recommends 
			      suggests conflicts enhances 
			      provides ) ) {
		    $a->{$_} = $self->process_dep_list( $_, $p, $a->{version}, $a->{architecture}, $a->{$_} )
			if exists $a->{$_};
		}
	    }
	}
	$self->{db}->{$p} = $pkg;
	$num++;
    }
    $max_num = keys %{$self->{srcdb}};
    $num = 0;
    print "\n" if $self->{config}->{verbose};
    foreach my $sp ( keys %{$self->{srcdb}} ) {
	my $srcpkg = $self->{srcdb}->{$sp};
	print "\r$num/$max_num" if $self->{config}->{verbose};
	foreach my $v ( values %{$srcpkg->{versions}} ) {
	    foreach ( qw( build-depends build-depends-indep 
			  build-conflicts build-conflicts-indep 
			  binary ) ) {
		$v->{$_} = $self->process_dep_list( $_, $sp, $v->{version}, 'source', $v->{$_} )
		    if exists $v->{$_};
	    }
	}
	$self->{srcdb}->{$sp} = $srcpkg;
	$num++;
    }
    print "\n" if $self->{config}->{verbose};
}

# internal function
sub not_member {
    my ($pack, @list) = @_;
    foreach(@list) {
	if ($_->[0] eq $pack) {
	    return 0;
	}
    }
    return 1;
}

# internal function
sub process_dep_list {
    my ( $self, $rel, $pkg, $version, $arch, $dep_list ) = @_;

    return $dep_list if ref $dep_list;
#
# inspired by the old htmlscripts/dependencies.pl
#
    my $res = [];
    foreach(split(/\s*,\s*/, $dep_list)) {
	next if $_ eq ''; # ignore empty depends due to superfluous commas
	my @final_dep_list = ();
	foreach my $given_dep (split(/\s*\|\s*/)) {
	    chomp( $given_dep );
	    my $given_dep_strip = $given_dep;
	    my ( $dep_op, $dep_ver, $dep_archs, $dep_archs_rr );
	    {
		$given_dep_strip =~ s/\s*\(\s*(=|>=|<=|<<|>>|>|<)\s*(.*)\)\s*//o;
		( $dep_op, $dep_ver ) = ( $1 || "", $2 || "");
		if ( $dep_op eq '>' ) {
		    $dep_op = '>>';
		    warn "W: package $pkg still uses old style versioning (>) when referencing $given_dep_strip\n"
			if $self->{config}{verbose};
		} elsif ( $dep_op eq '<' ) {
		    $dep_op = '<<';
		    warn "W: package $pkg still uses old style versioning (<) when referencing $given_dep_strip\n"
			if $self->{config}{verbose};
		}
	    }
	    {
		$given_dep_strip =~ s/\s*\[\s*(.*)\]\s*//o;
		$dep_archs = $1 || "";
		$dep_archs_rr = $dep_archs || "all";
	    }
	    if ( exists $self->{db}{$given_dep_strip} ) {
#		my $p = $self->{db}{$given_dep_strip};
		if ( not_member($given_dep_strip, @final_dep_list) ) {
		    push(@final_dep_list, [ $given_dep_strip, 
					    $dep_op, $dep_ver, $dep_archs ] );
#		    $p->add_reverse_rel( $rel, $pkg, $version,
#					 ($arch eq 'source') ? $dep_archs_rr : $arch,
#					 "$dep_op $dep_ver" );
#		    $self->{db}{$given_dep_strip} = $p;
		}
	    } else {
		push(@final_dep_list, [ $given_dep_strip, $dep_op, 
					$dep_ver, $dep_archs, "(NOT AVAILABLE)" ] );
#		warn "W:$pkg:$rel on $given_dep_strip unsatifiable\n"
#		    if $self->{config}{verbose}
#		&& ( ( $rel =~ /depends/o )
#		     || ( $rel eq 'recommends' ) );
	    }
	}
	push @$res, [ @final_dep_list ];
    }
    return $res;
}

=pod

=item C<get_stats_val>

Returns some statistic values about the database. You must
give the name of the value as parameter. Some values can require
a second parameter.

Supported values are:

=over 4

=item C<num_translated>

You must give the name of the language as second parameter.
Returns the number of translated descriptions in this language.

=item C<num_descriptions>

Number of unqiue descriptions in the database. Note that this can
differ when the Packages and Translations files have different
creation times.

=cut

sub get_stats_val {
    my ( $self, $req_val, $req_detail ) = @_;
    my $res_val = 0;

    if ( $req_val eq 'num_translated' ) {
	foreach my $d ( values %{$self->{desc}} ) {
	    $req_detail = lc $req_detail;
	    if ( exists( $d->{"description-$req_detail"} ) ) {
		$res_val++;
	    }
	}
    } elsif ( $req_val eq 'num_descriptions' ) {
	$res_val = keys %{$self->{desc}};
    }

    return $res_val;
}

=pod

=item C<get_stats>

Some debugging information. Returns a string with some data
about the database. Likely to change (or to disappear).

=cut

sub get_stats {
    my $self = shift;

    my $virt = 0;
    my $enh = 0;
    my $pkg = keys %{$self->{db}};
    my $ver = 0;
    my $descs = keys %{$self->{desc}};
    my $trans = 0;
    my $orig = 0;
    foreach my $p ( keys %{$self->{db}} ) {
	if ( ! exists $self->{db}->{$p}->{versions} 
	     || ! scalar keys %{$self->{db}->{$p}->{versions}} ) {
	    if ( exists $self->{db}->{$p}->{provided_by} ) {
		$virt++;
	    } elsif ( exists $self->{db}->{$p}->{enhanced_by} ) {
		$enh++;
	    } else {
		warn "W: get_stats: something seems wrong with"
		    . " package $p\n"
		    . "====================\n"
		    . Dumper( $self->{db}->{$p} );
	    }
	    next;
	}
#	foreach my $v ( values %{$self->{db}->{$p}->{versions}} ) {
#	    if ( ! $v->{archs}->{source}->{files} ) {
#		print Dumper( $self->{db}->{$p} );
#		exit;
#	    }
#	}
	$ver += keys %{$self->{db}->{$p}->{versions}};
    }
    foreach my $d ( values %{$self->{desc}} ) {
	if ( exists $d->{description} ) {
	    $orig++;
	}
	foreach my $k ( keys %$d ) {
	    if ( $k =~ /^description-/o ) {
		$trans++;
	    }
	}
    }

    return
	"Packages                :\t $pkg\n" . 
	"Virtual Packages        :\t $virt\n" .
	"Packages only in Enh.   :\t $enh\n" .
	"Versions                :\t $ver\n" .
	"Description keys        :\t $descs\n" .
	"English Descriptions    :\t $orig (".($descs-$orig)." missing)\n" .
	"Translated Descriptions :\t $trans\n" ;

}

1;
__END__

=head1 BUGS

=over 4

=item *

Problems with reusability (See comments to merge_in(), build_cache() and
calculate_depends()).

=item *

This is a alpha release. Expect interface changes.

=item *

The 'verbose' output is not loggable because of excessive use
of carriage return characters.

=back 

=head1 COPYRIGHT

Copyright 2003, 2004 Frank Lichtenheld <frank@lichtenheld.de>

This file is distributed under the terms of the GNU Public
License, Version 2. See the source code for more details.

=head1 SEE ALSO

perlfunc, Packages::Pkg, Packages::SrcPkg
