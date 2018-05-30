#!/usr/bin/perl

##  Copyright (C) 2008  Bas Zoetekouw <bas@debian.org>
##
##  This program is free software; you can redistribute it and/or modify it
##  under the terms of version 2 of the GNU General Public License as published
##  by the Free Software Foundation.

=head1 NAME

Local::VCS_CVS - generic wrapper around version control systems -- CVS version

=head1 SYNOPSIS

 use Local::VCS_CVS;
 use Data::Dumper;

 my $VCS = Local::VCS->new();
 my %info = $VCS->path_info( '.', recursive => 1, verbose => 1 );
 print Dumper($info{'foo.wml'});

 my %info2 = svn_file_info( 'foo.wml' );
 print Dumper(\%info2);

=head1 DESCRIPTION

This module retrieves CVS info (such as revision of latest change, date
of latest change, author, etc) for checked-out object in a working directory.

=head1 METHODS

=over 4

=cut

package Local::VCS_CVS;

use 5.008;

use Local::Cvsinfo;
use File::Basename;
use File::Spec::Functions qw( rel2abs splitdir catfile rootdir catdir );
use File::stat;
use Carp;
use Fcntl qw/ SEEK_SET /; 
use Data::Dumper;
use Date::Parse;
use POSIX qw/ WIFEXITED /;

use strict;
use warnings;

BEGIN {
	use base qw( Exporter );

	our $VERSION = "1.14";
	our @EXPORT_OK = qw( 
			     &new
	                   );
	our %EXPORT_TAGS = ( 'all' => [@EXPORT_OK] );
}


=item new

This is the constructor.

   my $VCS = Local::VCS->new();

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {
		CACHE    => {},
        };
        bless ($self, $class);
        return $self;
}

sub cache_file {
    my $self = shift;
    my $file = shift;
    
    if ($self->{CACHE}{"$file"}) {
	print "$file is already cached...\n";
	return;
    }
    print "Adding $file to cache\n";
    $self->{CACHE}{"$file"} = 1;
    return;
}

sub cache_repo {
    my $self = shift;    
    # Does nothing here...
}    

# handling debugging
my $DEBUG = 0;
sub _debug
{
	my @text = @_;
	return unless $DEBUG;
	print STDERR "=> ", @text, "\n";
	return;
}

# return the type of the specified file
sub _typeoffile;


=item cmp_rev

Compare two revision strings for a given file

Takes the file path and two revision strings as arguments, and 
returns 1 if the first one is newer, 
-1 if the second one is newer, 
0 if they are equal
=cut
sub cmp_rev
{
	my $self = shift;
	my $file = shift || ""; # unused here
	my $a = shift || '0';
	my $b = shift || '0';

	my @a = split( /\./, $a );
	my @b = split( /\./, $b );

	# compare the two revision string term by term
	my $i = 0;
	while (1)
	{
		# first check if there are terms left in both revisions
		if ( $i > $#a and $i>$#b ) { return 0 };
		if ( $i > $#a ) { return -1 };
		if ( $i > $#b ) { return  1 };

		# then check this term
		if ( $a[$i] < $b[$i] ) { return -1; }
		if ( $a[$i] > $b[$i] ) { return  1; }

		# terms are equal, look at the next one

		$i++;
	}

	# should never be reached
	croak "Internal error: this should never be executed";
}

=item count_changes

Return the number of changes to particular file between two revisions

The first argument is a name of a file.
The second and third argument specify the revision range

Example use:

   my $num1 = svn_count_changes( 'foo.c', 'r42', 'r70' );
   my $num2 = svn_count_changes( 'foo.c', 'r42', 'HEAD' );

=cut

sub count_changes
{
	my $self = shift;
	my $file = shift  or  return undef;
	my $rev1 = shift || '1.1';
	my $rev2 = shift || 'HEAD';

	$rev1 = '1.1'  if $rev1 eq 'n/a';

	# find the version number of HEAD, if it was specified
	if ( $rev2 eq 'HEAD' )
	{
		my %info = $self->file_info( $file );
		return -1  if  not %info;
		$rev2 = $info{'cmt_rev'};
	}

	# for CVS, this is pretty easy: we simply compare the two version numbers
	# note: we don't support branches (aren't used in the webwml repo anyway)
	my @rev1 = split( /\./, $rev1 );
	my @rev2 = split( /\./, $rev2 );

	croak "non-similar revision numbers `$rev1' and `$rev2' (different branches?)"
		if ( scalar @rev1 != scalar @rev2 );

	# check that all but the last components of the version numbers match
	# i.e., we can compare 2.0.1 and 2.0.17, but not 1.0.2 and 2.0.17
	while ( @rev1 > 1 )
	{
		croak "non-similar revision numbers (different branches?)"
			unless  shift @rev1 == shift @rev2;
	}

	return $rev2[0] - $rev1[0];
}


=item path_info

Return CVS information and status about a tree of files.

The first argument is a name of a file or directory, and subsequent arguments
form a hash of named options (see below).

The function returns a hash, which for each filename contains
Subversion status information:

  'type'       => type of the file ('d' directory, 'f' regular file, etc)
  'cmt_rev'    => revision in which latest change was made to this file
  'cmt_date'   => date on which latest change to this file was committed

Optional remaining arguments are a hash array with options:

   recursive:  if set to a true value (and the specified file is a directory),
               recurse into subdirectories
   match_pat:  only files/dirs that match this pattern are processed
   skip_pat:   files/dirs that match this pattern are skipped

Example uses:

   my %info1 = $path_info( 'src' );
   my %info2 = $readinfo( 'src', recursive => 1 );
   my %info3 = $readinfo( 'src', recursive => 1, match_pat => '\.c$' );

=cut

# todo: verbose

sub path_info
{
	my $self = shift;
	my ($dir,%options) = @_;

	croak("No file or directory specified") unless $dir;
	_debug "Called with $dir";

	my $recurse   = $options{recursive} || $options{recurse} || 0;
	my $match_pat = $options{match_pat} || undef;
	my $skip_pat  = $options{skip_pat}  || undef;

	_debug "Recurse is $recurse";
	_debug "Match pattern is '$match_pat'" if defined $match_pat;
	_debug "Skip pattern is  '$skip_pat'"  if defined $skip_pat;

	# $cvs->readinfo expects a matchfile input;  if nothing is specified, we
	# pass a pattern that matches everything
	$match_pat ||= '.'; 

	$dir = rel2abs( $dir );

	# use Local::Cvsinfo to do the actual work in CVS
	my $cvs = Local::Cvsinfo->new();
	$cvs->readinfo( $dir, recursive => $recurse, matchfile => [$match_pat] );
	my $files = $cvs->files;

	# construct a nice hash from the data we received from Cvsinfo
	my %data;
	for my $file (keys %{$cvs->{FILES}})
	{
		# we return relative paths, so strip off the dir name
		my $file_rel = $file;
		$file_rel =~ s{^$dir/?}{};

		# skip files that match the skip pattern
		next if  $skip_pat  and  $file_rel =~ m{$skip_pat};

		$data{$file_rel} = {
			'cmt_rev'  => $cvs->{FILES}->{$file}->{'REV'},
			'cmt_date' => str2time( $cvs->{FILES}->{$file}->{'DATE'} ),
			'type'     => _typeoffile $file,
		};
	}

	return %data;
}

=item file_info

Return VCS information and status about a single file

The single argument is a name of a file.

The function returns a hash, which contains VCS status information for
the specified file:

  'type'       => type of the file ('d' directory, 'f' regular file, etc)
  'cmt_rev'    => revision in which latest change was made to this file
  'cmt_date'   => date on which latest change to this file was committed

Example use:

   my %info = $file_info( 'foo.wml' );

=cut

sub file_info
{
	my $self = shift;
	my $file = shift or carp("No file specified");
	my %options = @_;

	my $quiet = $options{quiet} || undef;

	my ($basename,$dirname) = fileparse( rel2abs $file );

	# note: for some weird reason, the file is returned as '.'
	my %info = $self->path_info( $dirname, 'recursive' => 0 );

	if ( not ( exists $info{$basename} and $info{$basename} ) )
	{
		carp("No info found about `$file' (does the file exist?)") if ( ! $quiet );
		return;
	}

	return %{ $info{$basename} };
}

=item get_log

Return the log info about a specified file

The first argument is a name of a checked-out file.
The (optional) second and third argument specify the starting and end revision
of the log entries

Example use:

   my @log_entries = get_log( 'foo.wml' );

=cut

sub get_log
{
	my $self = shift;
	my $file = shift  or  return;
	my $rev1 = shift || '0';
	my $rev2 = shift || '';

	my @logdata;

	# set the record separator for cvs log output
	local $/ = "\n----------------------------\n";

	my $command = sprintf( 'cvs log -r%s:%s %s', $rev1, $rev2, $file );
	open( my $cvs, '-|', $command ) 
		or croak("Couldn't run `$command': $!");

	# skip the first record (gives genral meta-info)
	<$cvs>;

	# read the consequetive records
	while ( my $record = <$cvs> )
	{
		#print "==> $record\n";

		# the first two lines of a record contains metadata that looks like this:
		# revision 1.4
		# date: 2008-09-18 16:21:31 +0200;  author: bas;  state: Exp;  lines: +212 -105;  commitid: aGcNZ0HjJeSEfgjt;
		
		# first split off the first line
		my ($metadata1,$metadata2,$logmessage) = split( /\n/, $record, 3 );

		my ($revision)     = $metadata1 =~ m{^revision (.+)};
		my ($date,$author) = $metadata2 =~ m{^date: (.*?);  author: (.*?);  state: };

		croak( "Couldn't parse output of `$command'" ) 
			unless  $revision and $date and $author;

		# convert date to unixtime
		$date = str2time( $date );

		# last line of the log message is still the record separator
		$logmessage =~ s{\n[^\n]+\n$}{}ms;

		push @logdata, {
			'rev'     => $revision,
			'date'    => $date,
			'author'  => $author,
			'message' => $logmessage,
		};
	}
	close( $cvs );

	return reverse @logdata;
}

=item get_diff

Returns a hash of (filename,diff) pairs containing the unified diff between two version of a (number of) files.

The first argument is a name of a checked-out file.  The second and third
argument specify the starting and end revision of the log entries.  If the
third argument is not specified, the current (possibly modified) version is
used.  If the second argument is also not specified, the current (possibly
modified) version is diffed against the latest checked in version.

Example use:

   my %diffs = get_diff( 'foo.wml', '1.4', '1.17' );
   my %diffs = get_diff( 'bla.wml', '1.8' );
   my %diffs = get_diff( 'bas.wml' );

=cut

sub get_diff
{
	my $self = shift;
	my $file = shift  or  return;
	my $rev1 = shift;
	my $rev2 = shift;

	# hash to store the output
	my %data;

	my $command = sprintf( 'cvs -q diff %s %s -u %s 2> /dev/null', 
		defined $rev1 ? "-r$rev1" : '', 
		defined $rev2 ? "-r$rev2" : '', 
		$file );

	# set the record separator for cvs diff output
	local $/ = "\n" . ('=' x 67) . "\n";

#	print "$command\n";
	open( my $cvs, '-|', $command ) 
		or croak("Couldn't run `$command': $!");

	# the first "record" is bogusl
	<$cvs>;

	# read the consequetive records
	while ( my $record = <$cvs> )
	{
		# remove the record separator from the end of the record
		$record =~ s{ $/ \n? \Z }{}msx;

		# remove the "Index:" line from the end of the record
#		$record =~ s{ ^Index: [^\n]+ \n+ \Z }{}msx;

		# remove the first three lines
		$record =~ s{ \A (?: .*? \n ){3} }{}msx;

#		# get the file name
#		if ( not $record =~ m{ \A --- \s+ ([^\t]+) \t }msx )
#		{
#			croak("Parse error in output of `$command'");
#		}
#		my $file = $1;

		$data{$file} = $record;
	}
	close( $cvs );

	return %data;
}


# returns the respository
sub _get_repository
{
	open( my $fd, '<', 'CVS/Repository' )
		or croak("Couldn't open `CVS/Repository': $!");
	my $repo = <$fd>;
	close( $fd );

	chomp $repo;
	return $repo;
}

=item get_file

Return a particular revision of a file

The first argument is a name of a file.
The second argument is the revision.

This function retrieves the specified revision fo the file from the repository
and returns it (without writing anything in the current checked-out tree)

Example use:

   my $text = get_file( 'foo.c', '1.12' );

=cut

sub get_file
{
	my $self = shift;
	my $file = shift or croak("No file specified");
	my $rev  = shift or croak("No revision specified");

	croak( "No such file: $file" ) unless -f $file;

	#TODO: what happens if we're not in the root webwml dir?

	my $command = sprintf( 'cvs -q checkout -p -r%s %s/%s', 
		$rev, _get_repository, $file );
	

	local $/ = ('=' x 67) . "\n";

	my $text;
	open ( my $cvs, '-|', $command ) 
		or croak("Error while executing `$command': $!");
	while ( my $line = <$cvs> )
	{
		$text .= $line;
	}
	close( $cvs );
	croak("Error while executing `$command': $!") unless WIFEXITED($?);

	# return the file
	return $text;
}

=item get_oldest_revision

Return the version of the oldest version of a file

The first argument is a name of a file.

This function finds the oldest revision of a file that is known in the
repository and returns it.

Example use:

   my $rev = get_oldest_revision( 'foo.c');

=cut

sub get_oldest_revision
{
	my $self = shift;
	my $file = shift or croak("No file specified");

	croak( "No such file: $file" ) unless -f $file;

	return '1.1'; # earliest possible revision of any file, easy!
}

=item next_revision

Given a file path and a current revision of that file, move backwards
or forwards through the commit history and return a related revision.

Takes three arguments: the file path, the start revision and an
integer to specify which direction to move *and* how far. A negative
number specifies backwards in history, a positive number specifies
forwards.

Example use:

   my $rev = next_revision( 'foo.c', '72f6700577c79e6d284fbeac44366f6aa357d56d', -1);

Returns the requested revision if it exists, otherwise *undef*

=cut
sub next_revision
{
	# For the file we're looking at, we can easily generate an
	# array (list) of all the commit hashes. Then we can see where
	# in that list the specified revision lies.
	#
	# FIXME: Only deals with simple moves backwards/forwards along the trunk

	my $self = shift;
	my $file = shift or return undef;
	my $rev1 = shift or return undef;
	my $move = shift or return undef;

	my $newrev = $rev1;
	$newrev =~ s/(\d+)$/($1 + $move)/e;
	return $newrev;
}

=item get_topdir

Return the top dir of the webwml repository

The first argument is a name of a checked-out file or directory.
If it is not specified, by default the current directory is used.

Example use:

   my $dir = get_topdir( 'foo.c' );

=cut

sub get_topdir
{
	my $self = shift;
	my $file = shift || '.';

	my $cvs = Local::Cvsinfo->new();
	$cvs->readinfo( $file );
	my $root = $cvs->topdir()
		or croak ("Unable to determine top-level directory");

	# TODO: add some check that this really is the top level dir

	return $root;
}





######################################
## internal functions
######################################


# return the type of the input argument (file, dir, symlink, etc)
sub _typeoffile
{
	my $file = shift  or  return;

	stat $file  or  croak("Couldn't stat file `$file'");

	return 'f'  if ( -f _ );
	return 'd'  if ( -d _ );
	return 'l'  if ( -l _ );
	return 'S'  if ( -S _ );
	return 'p'  if ( -p _ );
	return 'b'  if ( -b _ );
	return 'c'  if ( -c _ );

	return '';
}


=back

=head1 AUTHOR

Copyright (C) 2008  Bas Zoetekouw <bas@debian.org>

This program is free software; you can redistribute it and/or modify it under
the terms of version2 of the GNU General Public License as published by the
Free Software Foundation.

=cut

42;


# stuff below is an old Subversion implementation that we probably won't use
# ignore for now, I will get rid of it as the rewrite progresses
# -- Bas.
__END__
