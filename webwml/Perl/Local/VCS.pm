##  Wrapper around the various Local::VCS_* modules
##
##  Copyright (C) 2008  Bas Zoetekouw <bas@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of version 2 of the GNU General Public License as
##  published by the Free Software Foundation.

package Local::VCS;

use Carp;
use Exporter;

use strict;
use warnings;

our @ISA = qw(Exporter);

# this is the import routine that is called when this  is "used" by a program
# We implement it ourselves here to export the symbols from the
# correct module to the main program
sub import
{
	# the first argument is "Local::VCS";
	# shift it away, we'll specify it manually below
	shift @_;

	# import the symbols from the module we need...
	if ( -d 'CVS' )
	{
		require Local::VCS_CVS;
		Local::VCS_CVS->export_to_level(1, 'Local::VCS_CVS', @_);
	}
	# fall back to git
	else
	{
		require Local::VCS_git;
		Local::VCS_git->export_to_level(1, 'Local::VCS_git', @_);
	}
}

sub new
{
	if ( -d 'CVS' )
	{
		require Local::VCS_CVS;
		return Local::VCS_CVS->new(@_);
	}
	# fall back to git
	else
	{
		require Local::VCS_git;
		return Local::VCS_git->new(@_);
	}
}    

42;
