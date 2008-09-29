#!/usr/bin/perl

package VCS;
use vars qw(@ISA);

if (-d 'CVS') {
	# CVS directory is in every subdirectory, so this is a save call
	require Local::VCS_CVS;
	@ISA = qw(Local::VCS_CVS);
} else {
	# we don't want to move up to look for a .git directory ...
	require Local::VCS_Git;
	@ISA = qw(Local::VCS_Git);
}

42;
