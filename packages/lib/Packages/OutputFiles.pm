#
# Packages::OutputFiles
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
package Packages::OutputFiles;

use strict;
use warnings;

use Compress::Zlib;
use Data::Dumper;
use Digest::MD5;
use Fcntl;
use File::Basename;
use File::Path;

my $debug = 0;

sub init {
    my $classname = shift;
    my $self = {};
    bless( $self, $classname );

    $self->{files} = {};

    return $self;
}


sub file_exists {
    my ( $self, $file ) = @_;

    if ( -f $file ) {
	$self->{files}{$file}{time} ||= 0;
	$self->{files}{$file}{md5} ||= '';
	print "D: $file [".gmtime($self->{files}{$file}{time})."] [$self->{files}{$file}{md5}] exists\n" if $debug;
	return 1;
    }
    return 0;
}

sub update_file {
    my ( $self, $filename, $text ) = @_;

    my $dirname = dirname $filename;
    unless ( -d $dirname ) {
	mkpath $dirname;
    }
    
    my $now_time = _time_stamp();
    if ( $self->file_is_changed( $filename, $text ) ) {

	$self->{files}{$filename}{md5} = Digest::MD5::md5_hex( $text );
	$self->{files}{$filename}{time} = time();
	sysopen( my $fh, $filename,
		 O_WRONLY | O_TRUNC | O_CREAT, 0664) 
	    || die "Can\'t open file $filename: $!";
	$text =~ s/LAST_MODIFIED_DATE/$now_time/;
	print $fh $text;
	close $fh or warn "Couldn\'t close file $filename: $!\n";
    } else { # only update timestamp of last update
	$self->{files}{$filename}{time} = time();
    }
}

sub update_gz_file {
    my ( $self, $filename, $text ) = @_;

    my $dirname = dirname $filename;
    unless ( -d $dirname ) {
	mkpath $dirname;
    }
    
    my $now_time = _time_stamp();
    if ( $self->file_is_changed( $filename, $text ) ) {

	$self->{files}{$filename}{md5} = Digest::MD5::md5_hex( $text );
	$self->{files}{$filename}{time} = time();
	sysopen( my $fh, $filename,
		 O_WRONLY | O_TRUNC | O_CREAT, 0664) 
	    || die "Can\'t open file $filename: $!";
	my $gz = gzopen( $fh, "wb" )
	    or die "Can't open gzfile $filename: $!";
	$text =~ s/LAST_MODIFIED_DATE/$now_time/;
	$gz->gzwrite( $text )
	    or die "Error while writing $filename: ".$gz->gzerror();
	$gz->gzclose();
    } else { # only update timestamp of last update
	$self->{files}{$filename}{time} = time();
    }
}

sub delete_file {
    my ( $self, $filename ) = @_;

    if ( $self->file_exists( $filename ) ) {
	print "D: delete $filename\n" if $debug;
	delete $self->{files}{$filename};
	unlink $filename or warn "Couldn't delete $filename\n";
    }
}

sub file_is_changed {
    my ( $self, $file, $text ) = @_;
    
    my $md5string = Digest::MD5::md5_hex( $text );
    if ( $self->file_exists( $file )
	 && ( $self->{files}{$file}{md5} eq $md5string ) ) {
	return 0;
    } else {
	if ( $self->file_exists( $file ) ) {
	    print "D: $file [".gmtime($self->{files}{$file}{time})."] [$self->{files}{$file}{md5}] is changed [$md5string]\n" if $debug;
	} else {
	    print "D: $file is new [$md5string]\n" if $debug;
	}
	return 1;
    }
}

sub load_file_list {
    my ( $self, $listfile ) = @_;
    if ( open LF, "<", $listfile ) {
	$self->{listfile} = $listfile;
	foreach ( <LF> ) {
	    chomp;
	    next unless m/(\d+)\s+(\w+)\s+(.+)/;
	    my ( $timestamp, $md5sum, $file ) = ( $1, $2, $3 );
	    $self->{files}{$file} = { md5 => $md5sum, time => $timestamp };
	}
	close LF;
#	print Dumper( $self );
    } else {
	return 0;
    }
    return 1;
}

sub write_file_list {
    my ( $self, $listfile ) = @_;
    $listfile ||= $self->{listfile};
    sysopen LF, $listfile, O_WRONLY | O_TRUNC | O_CREAT, 0664 
	or do {
	    warn "Can\'t open $listfile: $!";
	    return;
	};
    foreach ( keys %{$self->{files}} ) {
	print LF "$self->{files}{$_}{time} $self->{files}{$_}{md5} $_\n";
    }
    close LF;
}

sub _time_stamp {
    my ($sec,$min,$hour,$mday,undef,$year) = gmtime();
    my $time_str = gmtime();
    my ($wday, $month) = ($time_str =~ /^(\w{3})\s+(\w+)/);

    $year += 1900;
    $time_str = sprintf( "$wday, $mday $month $year %02d:%02d:%02d +0000", 
			 $hour, $min, $sec );

    return $time_str;
}

sub each {
    my $self = shift;

    my ($file, $data) = each %{$self->{files}};

    return $file;
}

sub get_timestamp {
    my ( $self, $file ) = @_;


    return $self->{files}{$file}{time};
}

sub get_md5sum {
    my ( $self, $file ) = @_;

    return $self->{files}{$file}{md5};
}

1;
