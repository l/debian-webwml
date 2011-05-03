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

 my %info = vcs_path_info( '.', recursive => 1, verbose => 1 );
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

	our $VERSION = sprintf "%d", q$Revision$ =~ /(\d+)/g;
	our @EXPORT_OK = qw( 
	                     &vcs_cmp_rev     &vcs_count_changes
	                     &vcs_get_topdir 
	                     &vcs_path_info   &vcs_file_info
	                     &vcs_get_log     &vcs_get_diff
	                     &vcs_get_file
	                   );
	our %EXPORT_TAGS = ( 'all' => [@EXPORT_OK] );
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


=item vcs_cmp_rev

Compare two revision strings.

Takes two revision strings as arguments, and 
returns 1 if the first one is largest, 
-1 if the second one is largest, 
0 if they are equal
=cut
sub vcs_cmp_rev
{
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

=item vcs_count_changes

Return the number of changes to particular file between two revisions

The first argument is a name of a file.
The second and third argument specify the revision range

Example use:

   my $num1 = svn_count_changes( 'foo.c', 'r42', 'r70' );
   my $num2 = svn_count_changes( 'foo.c', 'r42', 'HEAD' );

=cut

sub vcs_count_changes
{
	my $file = shift  or  return undef;
	my $rev1 = shift || '1.1';
	my $rev2 = shift || 'HEAD';

	$rev1 = '1.1'  if $rev1 eq 'n/a';

	# find the version number of HEAD, if it was specified
	if ( $rev2 eq 'HEAD' )
	{
		my %info = vcs_file_info( $file );
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


=item vcs_path_info

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

   my %info1 = $vcs_path_info( 'src' );
   my %info2 = $readinfo( 'src', recursive => 1 );
   my %info3 = $readinfo( 'src', recursive => 1, match_pat => '\.c$' );

=cut

# todo: verbose

sub vcs_path_info
{
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

=item vcs_file_info

Return VCS information and status about a single file

The single argument is a name of a file.

The function returns a hash, which contains VCS status information for
the specified file:

  'type'       => type of the file ('d' directory, 'f' regular file, etc)
  'cmt_rev'    => revision in which latest change was made to this file
  'cmt_date'   => date on which latest change to this file was committed

Example use:

   my %info = $vcs_file_info( 'foo.wml' );

=cut

sub vcs_file_info
{
	my $file = shift or carp("No file specified");
	my %options = @_;

	my $quiet = $options{quiet} || undef;

	my ($basename,$dirname) = fileparse( rel2abs $file );

	# note: for some weird reason, the file is returned as '.'
	my %info = vcs_path_info( $dirname, 'recursive' => 0 );

	if ( not ( exists $info{$basename} and $info{$basename} ) )
	{
		carp("No info found about `$file' (does the file exist?)") if ( ! $quiet );
		return;
	}

	return %{ $info{$basename} };
}

=item vcs_get_log

Return the log info about a specified file

The first argument is a name of a checked-out file.
The (optional) second and third argument specify the starting and end revision
of the log entries

Example use:

   my @log_entries = vcs_get_log( 'foo.wml' );

=cut

sub vcs_get_log
{
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

=item vcs_get_diff

Returns a hash of (filename,diff) pairs containing the unified diff between two version of a (number of) files.

The first argument is a name of a checked-out file.  The second and third
argument specify the starting and end revision of the log entries.  If the
third argument is not specified, the current (possibly modified) version is
used.  If the second argument is also not specified, the current (possibly
modified) version is diffed against the latest checked in version.

Example use:

   my %diffs = vcs_get_diff( 'foo.wml', '1.4', '1.17' );
   my %diffs = vcs_get_diff( 'bla.wml', '1.8' );
   my %diffs = vcs_get_diff( 'bas.wml' );

=cut

sub vcs_get_diff
{
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
		$record =~ s{ ^Index: [^\n]+ \n+ \Z }{}msx;

		# remove the first four lines
		$record =~ s{ \A (?: .*? \n ){4} }{}msx;

		# get the file name
		if ( not $record =~ m{ \A --- \s+ ([^\t]+) \t }msx )
		{
			croak("Parse error in output of `$command'");
		}
		my $file = $1;

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

=item vcs_get_file

Return a particular revision of a file

The first argument is a name of a file.
The second argument is the revision.

This function retrieves the specified revision fo the file from the repository
and returns it (without writing anything in the current checked-out tree)

Example use:

   my $text = vcs_get_file( 'foo.c', '1.12' );

=cut

sub vcs_get_file
{
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

=item vcs_get_topdir

Return the top dir of the webwml repository

The first argument is a name of a checked-out file or directory.
If it is not specified, by default the current directory is used.

Example use:

   my $dir = vcs_get_topdir( 'foo.c' );

=cut

sub vcs_get_topdir
{
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



=item svn_diff

Return diff for the specified file 

The first argument is a name of a file.
The second argument is the revision against which to take the diff (use undef for HEAD)
If a thrird argument is present, it signifies that hte use want a diff between
the version specified in the second agument and the one in the third argument

Example use:

   # get diff of local changes against head
   my $diff1 = $svn_diff( 'foo.c' );
   # get diff of local changes against revision 12
   my $diff2 = $svn_diff( 'foo.c', 'r12' );
   # get diff between version 11 and 12 of the file
   my $diff1 = $svn_diff( 'foo.c', 'r11', 'r12' );

=cut

sub svn_diff
{
	my $file = shift or carp("No file specified");
	my $rev1 = shift or carp("No orig revision specified");
	my $rev2 = shift or carp("No target revision specified");

	carp( "No such file: $file" ) unless -e $file;

	# intitalize SVN client
	my $ctx = SVN::Client->new();

	# create twoo filehandles for output and error streams

	# TODO: this doesn't work (bug in SVN::Client?)
	my ($out,$err);
	#open ( my $fd_out, '>', \$out ) or croak("Couldn't open \\\$out");
	#open ( my $fd_err, '>', \$err ) or croak("Couldn't open \\\$err");

	open ( my $fd_out, '+>', undef ) or croak("Couldn't open anonymous output");
	open ( my $fd_err, '+>', undef ) or croak("Couldn't open anonymous error");

	$ctx->diff( 
		[],  # options to diff (-u is default)
		$file, $rev1, # first file
		$file, $rev2, # second file
		1, # recursiveness
		1, # don't bother with ancestors
		0, # do diff deleted files
		$fd_out, # output file
		$fd_err, # error output file
	);

	# read the stuff from the files
	seek( $fd_out, 0, SEEK_SET );
	seek( $fd_err, 0, SEEK_SET );
	{ 
		local $/;
		$out = <$fd_out>;
		$err = <$fd_err>;
	}

	# done with the files
	close( $fd_out );
	close( $fd_err );

	# croak on error
	croak( $err ) if $err;

	# return the diff
	return $out;
}


=item svn_log

Return the log entries of a particular file

The first argument is a name of a file.
The (optional) second  and third argument specify the revision range

This function retrieves the log entry/entries of the specified revision(s) for
the specified file.  If only a file name is given, the entire history is
returned; if only 1 revision is specified, the log entrie of that particular
revision is returned; if two revisions are specified, all log entries in
between are returned.

Example use:

   my @log = svn_log( 'foo.c' );
   my @log = svn_log( 'foo.c', 'r42' );
   my @log = svn_log( 'foo.c', 'r42', 'r112' );
   my @log = svn_log( 'foo.c', 'r42', 'HEAD' );

=cut

my @_log_collection;

sub _log_receiver
{
	my $paths  = shift; # NOTE: not used
	my $rev    = shift;
	my $author = shift;
	my $date   = str2time( shift );
	my $msg    = shift;

	push @_log_collection, { 
		'rev'     => $rev,
		'author'  => $author,
		'date'    => $date,
		'message' => $msg,
	};

}

sub svn_log
{
	my $file = shift or carp("No file specified");
	my $rev1 = shift || '0';
	my $rev2 = shift || 'HEAD';

	carp( "No such file: $file" ) unless -e $file;

	# clear log
	@_log_collection = ();

	# intitialize SVN client
	my $ctx = SVN::Client->new();

	eval {
		$ctx->log( 
			$file,
			$rev1,
			$rev2,
			0,  # determine which files were changed on each revision?
			0,  # don't traverse history of copies?
			\&_log_receiver
		);
	};
	carp($@) if $@;


	# return a copy of the logs
	return @_log_collection;
}

=item svn_get_info

Return info about the (local) Subversion repository

The first argument is a name of a checked-out file or directory.

Example use:

   my %info = svn_info( 'foo.c' );

=cut

my %_info_data;

sub _info_receiver
{
	my( $path, $info, $pool ) = @_;

	# return if the info is already known
	return if %_info_data;

	%_info_data = (
		'url'                 => $info->URL(),
		'rev'                 => $info->rev(),
		'kind'                => $info->kind(),
		'root'                => $info->repos_root_URL(),
		'uuid'                => $info->repos_UUID(),
		'last_changed_rev'    => $info->last_changed_rev(),
		'last_changed_date'   => $info->last_changed_date(),
		'last_changed_author' => $info->last_changed_author(),
	);
};

sub svn_get_info
{
	my $file = shift or carp("No file specified");

	$file = rel2abs( $file );

	# intitialize SVN client
	my $ctx = SVN::Client->new();

	# reset the info hash
	%_info_data = ();

	eval {
		$ctx->info( 
			$file,
			undef, # no revision info, so...
			undef, # ...only use local info
			\&_info_receiver,
			0,     # no, don't recurse
		);
	};
	carp($@) if $@;

	return %_info_data;
}


=item svn_get_depth

Find how deep we are inside the repository

The first argument is a name of a checked-out file or directory.

Example use:

   my $depth = svn_get_topdir( 'foo.c' );

=cut

sub svn_get_depth
{
	my $file = shift or carp("No file specified");


	my %info = svn_get_info( $file );
	my $top  = $info{'url'};
	my $root = $info{'root'};

	# if $file really is a file (not a dir), only look at the directory part of
	# the filename
	$top = dirname( $top )  if $info{'kind'} == 1;

	# remove the root from the start of url to get a top dir
	$top =~ s{^\Q$root\E}{};
	$top =~ s{/+}{/};

	# count the number of elements in the path
	my $num = scalar splitdir( $top );

	# minus 1, because $top starts with a '/', and thus splitdir adds an empty
	# field at the beginning
	return $num - 1;
}


