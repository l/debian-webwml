#!/usr/bin/perl

## Copyright (C) 2018  Steve McIntyre <93sam@debian.org>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of version 2 of the GNU General Public License as published
## by the Free Software Foundation.

=head1 NAME

Local::VCS_git - generic wrapper around version control systems -- git version

=head1 SYNOPSIS

 use Local::VCS_git;
 use Data::Dumper;

 my $VCS = Local::VCS->new();
 my %info = $VCS->path_info( '.', recursive => 1, verbose => 1 );
 print Dumper($info{'foo.wml'});

=head1 DESCRIPTION

This module retrieves git info (such as revision of latest change, date
of latest change, author, etc) for checked-out object in a working directory.

=head1 METHODS

=over 4

=cut

package Local::VCS_git;

use 5.008;

use File::Basename;
use File::Find;
use File::Spec::Functions qw( rel2abs splitdir catfile rootdir catdir );
use File::stat;
use Carp;
use Fcntl qw/ SEEK_SET /; 
use Data::Dumper;
use Date::Parse;
use POSIX qw/ WIFEXITED /;
use List::MoreUtils 'first_index'; 
use Cwd qw(cwd);
use Time::HiRes qw/gettimeofday/;
use Data::Dumper;

use strict;
use warnings;

BEGIN {
	use base qw( Exporter );

	our $VERSION = "1.13";
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
		REPO_CACHED => 0,
        };
        bless ($self, $class);
        return $self;
}

# handling debugging
my $DEBUG = 0;

sub _get_time()
{
    my @tm;
    my $text;
    my ($seconds, $microseconds) = gettimeofday;

    @tm = gmtime();
    $text = sprintf("%4d-%02d-%02d %02d:%02d:%02d.%6d UTC",
                    (1900 + $tm[5]),(1 + $tm[4]),$tm[3],$tm[2],$tm[1],$tm[0], $microseconds);
    return $text;
}

sub _debug
{
	my @text = @_;
	return unless $DEBUG;
	my $timestamp = _get_time();
	print STDERR "=> ", $timestamp, " ", @text, "\n";
	return;
}

sub _add_cache_entry {
    my $self = shift;
    my $file = shift;
    my %entry;
    $entry{'cmt_date'} = shift;
    $entry{'cmt_rev'} = shift;
    my $tmp;
    my @list;
    if ($self->{CACHE}{"$file"}) {
	$tmp = $self->{CACHE}{"$file"};
	@list = @$tmp;
    }
    push(@list, \%entry);
    $self->{CACHE}{"$file"} = \@list;
}

sub cache_file {
    my $self = shift;
    my $file = shift;
    
    _debug "cache_file($file)";
    if ($self->{CACHE}{"$file"}) {
#	print "$file is already cached...\n";
	_debug "cache_file($file) returning early";
	return;
    }
#    print "Adding $file to cache\n";
    my (@commits);
    open (GITLOG, "git log -p -m --first-parent --name-only --numstat --format=format:\"%H %ct\" -- $file |") or die "Can't fork git log: $!\n";
    my ($cmt_date, $cmt_rev);
    while (my $line = <GITLOG>) {
	chomp $line;
	if ($line =~ m/^([[:xdigit:]]+) (\d+)$/) {
	    $cmt_rev = $1;
	    $cmt_date = $2;
	    next;
	} elsif ($line =~ m{^$file$}) {
	    $self->_add_cache_entry($file, $cmt_date, $cmt_rev);
	}
    }
    close GITLOG;
    _debug "cache_file($file) done";
    return;
}

sub cache_repo {
    my $self = shift;    

    _debug "cache_repo()";
    # If we've already read the commit history into our cache, return
    # immediately
    if ($self->{REPO_CACHED}) {
	_debug "cache_repo() returning early";
	return;
    }

    # If not, clear the cache and rebuild from scratch. We might havs
    # some files cached individually, and that would confuse things
    # now.
    $self->{CACHE} = {};

    # Store the current directory so we can return there
    my $start_dir = cwd;
    my $topdir = $self->get_topdir();
    chdir ($topdir) or die "Can't chdir to $topdir: $!\n";    

    my (@commits);
    my $count = 0;
    open (GITLOG, "git log -p -m --first-parent --name-only --numstat --format=format:\"%H %ct\" |") or die "Can't fork git log: $!\n";
    my ($cmt_date, $cmt_rev);
    while (my $line = <GITLOG>) {
	chomp $line;
	if ($line =~ m/^([[:xdigit:]]+) (\d+)$/) {
	    $cmt_rev = $1;
	    $cmt_date = $2;
	    next;
	} elsif ($line =~ m{^(\S+)$}) {
	    my $file = $1;
	    $self->_add_cache_entry($file, $cmt_date, $cmt_rev);
	    $count++;
	}
    }
    close GITLOG;
    chdir ($start_dir);
    $self->{REPO_CACHED} = 1;    
#    print Dumper($self->{CACHE});
    my $tmp = $self->{CACHE};
    my $num_files = scalar(keys %$tmp);
    _debug "cache_repo() done, $count file commits, $num_files files";
}    

# Internal helper function - grab a list of all the commits to a given
# file
sub _grab_commits
{    
    my $self = shift;
    my $file = shift or return undef;
    $self->cache_file($file);
    my $tmp = $self->{CACHE}{"$file"};
    if (defined $tmp) {
	my @commits = @$tmp;
#    print Dumper(@commits);
	return @commits;
    }
    return undef;
}

=item cmp_rev

Compare two revision strings for a given file.

Takes the file path and two revision strings as arguments, and 
returns 1 if the first one is newer, 
-1 if the second one is newer, 
0 if they are equal

=cut
sub cmp_rev
{
	# For the file we're looking at, we can easily generate an
	# array (list) of all the commit hashes. Then we can see where
	# in that list the specified revisions lie (from newest to
	# oldest) - that's what we're going to compare.

	my $self = shift;
	my $file = shift or return undef;
	my $rev1 = shift or return undef;
	my $rev2 = shift or return undef;

	my @commits = $self->_grab_commits($file);
#	print Dumper(@commits);
	my $pos1 = -1;
	my $pos2 = -1;
	my $count = 0;
	foreach my $tmp(@commits) {
	    my %entry = %$tmp;
	    if ($entry{'cmt_rev'} =~ /\Q$rev1\E/) {
		$pos1 = $count;
	    }
	    if ($entry{'cmt_rev'} =~ /\Q$rev2\E/) {
		$pos2 = $count;
	    }
	    if ($pos1 != -1 and $pos2 != -1) {
		last;
	    }
	    $count++;
	}
	if ($pos1 == -1) {
	    # Not found
	    print "ERROR: commit $rev1 not found in revisions of $file\n";
	    return undef;
	}
	if ($pos2 == -1) {
	    # Not found
	    print "ERROR: commit $rev2 not found in revisions of $file\n";
	    return undef;
	}
	if ($pos1 == $pos2) {
	    return 0;
	} elsif ($pos1 < $pos2) {
	    return 1;
	} else {
	    return -1;
	}

	# should never be reached
	croak "Internal error: this should never be executed";
}

=item count_changes

Return the number of changes to particular file between two revisions

The first argument is a name of a file.
The second and third argument specify the revision range

Example use:

   my $num1 = count_changes( 'foo.c', 'r42', 'r70' );
   my $num2 = count_changes( 'foo.c', 'r42', 'HEAD' );
   
=cut

sub count_changes
{
	# FIXME: not sure if we need to handle the issue of wrong $rev1/$rev2 here
	#        or the caller function will care.
	#        Not sure if this function makes sense in a git context, either,
	#        but just in case
    
	my $self = shift;
	my $file = shift  or  return undef;
	my $rev1 = shift || '';
	my $rev2 = shift || '';

	if ($rev1 =~ m/^\Q$rev2\E$/) { # same revisions
	    return 0;
	}

	my @commits = $self->_grab_commits($file);

	# If unset, go for the last revision
	if (length($rev2) == 0) {
	    $rev2 = $commits[$#commits];
	}

	my $pos1 = -1;
	my $pos2 = -1;
	my $count = 0;
	foreach my $tmp(@commits) {
	    my %entry = %$tmp;
	    if ($entry{'cmt_rev'} =~ /\Q$rev1\E/) {
		$pos1 = $count;
	    }
	    if ($entry{'cmt_rev'} =~ /\Q$rev2\E/) {
		$pos2 = $count;
	    }
	    if ($pos1 != -1 and $pos2 != -1) {
		last;
	    }
	    $count++;
	}
	if ($pos1 == -1) {
	    # Not found
	    print "ERROR: commit $rev1 not found in revisions of $file\n";
	    return undef;
	}
	if ($pos2 == -1) {
	    # Not found
	    print "ERROR: commit $rev2 not found in revisions of $file\n";
	    return undef;
	}
	return $pos2 - $pos1;
}

# return the type of the input argument (file, dir, symlink, etc)
sub _typeoffile
{
	my $file = shift  or  return;

	stat $file  or  return 'f'; # File is not here now; assume it
				    # was a file!

	return 'f'  if ( -f _ );
	return 'd'  if ( -d _ );
	return 'l'  if ( -l _ );
	return 'S'  if ( -S _ );
	return 'p'  if ( -p _ );
	return 'b'  if ( -b _ );
	return 'c'  if ( -c _ );

	return '';
}

=item path_info

Return git information and status about a tree of files.

The first argument is a name of a file or directory, and subsequent arguments
form a hash of named options (see below).

The function returns a hash, which for each filename contains
git status information:

  'type'       => type of the file ('d' directory, 'f' regular file, etc)
  'cmt_rev'    => revision in which latest change was made to this file
  'cmt_date'   => date on which latest change to this file was committed

Optional remaining arguments are a hash array with options:

   recursive:  if set to a true value (and the specified file is a directory),
               recurse into subdirectories
   match_pat:  only files/dirs that match this pattern are processed
   skip_pat:   files/dirs that match this pattern are skipped

Example uses:

   my %info1 = $VCS->path_info( 'src' );
   my %info2 = $VCS->path_info( 'src', recursive => 1 );
   my %info3 = $VCS->path_info( 'src', recursive => 1, match_pat => '\.c$' );

=cut

# todo: verbose

sub path_info
{
	# Two parts:
	#
	# (1)  Build a hash of all the files we want to know about
	#
	# (2a) Ask git about all the files it has, and pull out
	#      information for ones in the hash from (1)
	#
	# OR
	# 
	# (2b) Grab that information from our cache of all the commit data,
	#      if we have already been told to generate that cache.
	#      *Don't* generate that cache automatically - for just a few
	#      files it's quicker to just look up the data directly. If the
	#      user is going to do a lot of lookups, let them populate the
	#      cache up-front themselves if performance matters.
	#
	# This may not sound very quick, but it's much better than asking git
	# about all the details individually!

	my $self = shift;
	my ($dir,%options) = @_;
	my %files_wanted;

	croak("No file or directory specified") unless $dir;
	_debug "path_info ($dir)";

	my $recurse   = $options{recursive} || $options{recurse} || 0;
	my $match_pat = $options{match_pat} || undef;
	my $skip_pat  = $options{skip_pat}  || undef;

	_debug "Recurse is $recurse";
	_debug "Match pattern is '$match_pat'" if defined $match_pat;
	_debug "Skip pattern is  '$skip_pat'"  if defined $skip_pat;

	if ($recurse) {
	    find( sub { $files_wanted{$File::Find::name} = 1 if -f and
			    (!defined $match_pat or m/$match_pat/) and
			    (!defined $skip_pat or not ($File::Find::name =~ m/$skip_pat/))}, $dir );
	} else {
	    find( sub { $files_wanted{$File::Find::name} = 1 if -f and
			    ($File::Find::dir eq $dir) and
			    (!defined $match_pat or m/$match_pat/) and
			    (!defined $skip_pat or not ($File::Find::name =~ m/$skip_pat/))}, $dir );
	}

	# Calling "git log" for each file individually is hatefully
	# slow. Better option: call it once with appropriate options
	# for the directory we're targeting, and parse the
	# output. Gross, but it works.

	my %pathinfo;

	# Do we have the repo commit history cached?
	if ($self->{REPO_CACHED}) {
		# We do, use it! (2b above)
		foreach my $file (keys %files_wanted) {
		    my @commits = $self->_grab_commits($file);
		    if (@commits) {
			my $outfile = $file;
			$outfile =~ s,^$dir/,,;
			# Grab the data we want from the first entry in the
			# commits list, i.e. the most recent commit.
			$pathinfo{$outfile}{'type'} = _typeoffile("$file");
			$pathinfo{$outfile}{'cmt_date'} = $commits[0]{'cmt_date'};
			$pathinfo{$outfile}{'cmt_rev'} = $commits[0]{'cmt_rev'};
		    } else {
			_debug "Ignoring file $file";
		    }
		}
	} else {
	    # We don't, so we need to talk to git. (2a above)
	    open (GITLOG, "git log -p -m --first-parent --name-only --numstat --format=format:\"%H %ct\" $dir|")
		or die "Failed to fork git log: $!\n";
	    my $cmt_date;
	    my $cmt_rev;
	    my $file;
	    while (my $line = <GITLOG>) {
		chomp $line;
		if ($line =~ m/^([[:xdigit:]]+) (\d+)$/) {
		    $cmt_rev = $1;
		    $cmt_date = $2;
		    next;
		} elsif ($line =~ m{^$dir/(\S+)$}) {
		    $file = $1;
		    # Only store information if:
		    # We want this file, and
		    # We don't have data for it yet (i.e. only show
		    # the most recent version of a file)
		    if ($files_wanted{"$dir/$file"} and not defined $pathinfo{$file}) {
			$pathinfo{$file}{'type'} = _typeoffile("$dir/$file");
			$pathinfo{$file}{'cmt_date'} = $cmt_date;
			$pathinfo{$file}{'cmt_rev'} = $cmt_rev;
		    }
		}   
	    }
	    close GITLOG;
	}
	_debug "path_info ($dir) returning";
	return %pathinfo;	
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

   my %info = $VCS->file_info( 'foo.wml' );

=cut

sub file_info
{
	my $self = shift;
	my $file = shift or carp("No file specified");
	my %options = @_;
	my $quiet = $options{quiet} || undef;
	my %pathinfo;
	my @commits = $self->_grab_commits($file);
	if (@commits) {
	    # Grab the data we want from the first entry in the
	    # commits list, i.e. the most recent commit.
	    $pathinfo{'type'} = _typeoffile("$file");
	    $pathinfo{'cmt_date'} = $commits[0]{'cmt_date'};
	    $pathinfo{'cmt_rev'} = $commits[0]{'cmt_rev'};
	}

	return %pathinfo;	
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
	my $rev1 = shift || '';
	my $rev2 = shift || '';
	my @logdata;
	my $command;	
	if ($rev1 eq '' and $rev2 eq '') {
	    $command = sprintf( 'git log --date=unix %s', $file );
	} elsif ($rev2 eq '') {
	    $command = sprintf( 'git log --date=unix %s^..%s %s', $rev1, $rev1, $file );
	} elsif ($rev1 eq '') {
	    $command = sprintf( 'git log --date=unix ..%s %s', $rev2, $file );
	} else {
	    $command = sprintf( 'git log --date=unix %s..%s %s', $rev1, $rev2, $file );
	}		

	_debug "get_log: running $command";

	open( my $git, '-|', $command ) 
		or croak("Couldn't run `$command': $!");

	my $revision;
	my $author;
	my $date;
	my $message;
	my $first_record_done = 0;

	# read and parse the log records
	while ( my $line = <$git> )
	{
	    # the first 3 lines of a record contain metadata that looks like this:
	    # commit abcdefg435768938de
	    # Author: Jane Doe <email@example.com>
	    # Date:   1504881409

	    if ($line =~ m{^commit (.+)}) {
		# Second and subsequent record, push a result
		if ($first_record_done) {
		    _debug "pushing a record (rev $revision)";
		    push @logdata, {
			'rev'     => $revision,
		        'author'  => $author,
			'date'    => $date,
			'message' => $message,
		    };
		    $message = "";
		}
		$first_record_done = 1;
		$revision = $1;
	    } elsif ($line =~ m{^Author: (.+)}) {
		$author = $1;
	    } elsif ($line =~ m{^Date: (.+)}) {
		$date = $1;
	    } else {
		# Lose leading whitespace, but retain blank lines
		if ($line =~ m{\S}) {
		    $line =~ s{^\s+}{};
		}
		$message .= $line;
	    }

	}
	close( $git );

	if ($first_record_done) {
	    #	_debug "pushing last record (rev $revision)";
	    # Last record, push a result
	    push @logdata, {
		'rev'     => $revision,
		 'author'  => $author,
		 'date'    => $date,
		 'message' => $message,
	    };
	    return reverse @logdata;
	}
	return undef;
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

	my $command = sprintf( 'git diff %s %s -u %s 2> /dev/null', 
		defined $rev1 ? "$rev1" : '', 
		defined $rev2 ? "$rev2" : '', 
		$file );

#	print "$command\n";

	open( my $git, '-|', $command ) 
		or croak("Couldn't run `$command': $!");

	# read the consecutive records
	while ( my $record = <$git> )
	{
		# remove the record separator from the end of the record
#		$record =~ s{ $/ \n? \Z }{}msx;

		# remove the "index" line from the beginning of the record
#		$record =~ s{ ^index [^\n] }{}msx;

		# remove the first 2 lines
		$record =~ s{^diff\s+--git.*}{}msx;
		$record =~ s{^index\s+.*}{}msx;

		$data{$file} .= $record;
	}
	close( $git );

	return %data;
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


	my $command = sprintf( 'git show %s:%s', 
		$rev, $file );

	my $text;
	open ( my $git, '-|', $command ) 
		or croak("Error while executing `$command': $!");
	while ( my $line = <$git> )
	{
		$text .= $line;
	}
	close( $git );
	croak("Error while executing `$command': $!") unless WIFEXITED($?);
	
	# return the file
	return $text;
}

=item get_oldest_revision

Return the version of the oldest version of a file

The first argument is a name of a file.

This function finds the oldest revision of a file that is known in the repository and returns it.

Example use:

   my $rev = get_oldest_revision( 'foo.c');

=cut

sub get_oldest_revision
{
	my $self = shift;
	my $file = shift or croak("No file specified");

	croak( "No such file: $file" ) unless -f $file;

	my @commits = $self->_grab_commits($file);
	if (@commits) {
	    # Simply return the last revision in our list
	    return $commits[$#commits]{'cmt_rev'};
	}
	# Should hopefully never get here!
	croak(" Could not find any revisions for $file");
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

	my $self = shift;
	my $file = shift or return undef;
	my $rev1 = shift or return undef;
	my $move = shift or return undef;

	my @commits = $self->_grab_commits($file);
#	print Dumper(@commits);
	my $pos1 = -1;
	my $pos2 = -1;
	my $count = 0;
	my %entry;
	foreach my $tmp(@commits) {
	    %entry = %$tmp;
	    if ($entry{'cmt_rev'} =~ /\Q$rev1\E/) {
		$pos1 = $count;
	    }
	    if ($pos1 != -1) {
		last;
	    }
	    $count++;
	}

	if ($pos1 == -1) {
	    # Can't find the specified revision
	    return undef;
	}

	# API specifies -ve as older, but out list is sorted the other
	# way...
	$pos2 = $pos1 - $move;

	if ($pos2 < 0 or $pos2 >= $#commits) {
	    # Out of range when looking for the new revision
	    return undef;
	}

	return $commits[$pos2]{'cmt_rev'};
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

	# Are we in topdir? Easy!
	if (-d ".git") {
	    return ".";
	}

	# Otherwise, walk up the tree until we find a .git or hit the
	# root directory
	my $dir = "..";
	my ($root_dev, $root_ino) = stat("/");

	while (1 == 1) {
	    if (-d "$dir/.git") {
		return "$dir";
	    }
	    my ($dev, $ino) = stat("$dir");
	    if ($root_dev == $dev and $root_ino == $ino) {
		croak ("Unable to determine top-level directory");
	    }
	    $dir = "../$dir";
	}
}

=back

=head1 AUTHOR

Copyright (C) 2018  Steve McIntyre <93sam@debian.org>

This program is free software; you can redistribute it and/or modify
it under the terms of version 2 of the GNU General Public License as
published by the Free Software Foundation.

=cut

42;


__END__


