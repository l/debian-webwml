#!/usr/bin/perl

# This script enables the creation of copies of the www site
# in only two languages. Default language (see $DEFAULT)
# and provided language (-p switch) giving preference to
# the later.

# (c) Javier Fernández-Sanguino Peña <jfs@debian.org>
# Distributed under the GNU GPL License (see http://www.gnu.org/gpl)

# It fixes all the href links in the current directory
# and all under it depending on the files that exist.
# Current options
# -p (obliged): tells which preferred language to use
# -v (optional): activates verbose output


# In order to retrieve Debian's website try something
# like:
# (for Spanish users)
# 1.- wget -o debian.log -m -k http://www.es.debian.org
# 2.- (go to the dir created by wget, in our case www.es.debian.org)
# 3.- perl intcopy.pl -p es
#
# NOTES:
# 1.- Customize the URL and -p option to fix  for your closest mirror and
# language
# 2.- after doing this you can remove all other languages
# besides yours (anyone care to give an easy bash line here?)
# 3.- afterwards check all URL (try checkbot) and send any bugs regarding
# bad fixed links to me.



# TODO:
# 1.- It currently does not understand # in links and fixes
# them incorrectly


use Getopt::Std;
use IO::File;
use Cwd;
use File::Copy;

use strict;
use warnings;

my %opts;
getopts('vp:d:', \%opts);

my $POST         = $opts{'p'};
my $DEFAULT      = "en"; #Default language is english (en)
my $INVALID_DIRS = '^\.|\.\.|CVS|\.svn|.git$';

my $current_dir = $opts{'d'} || getcwd;
my $verbose     = $opts{'v'};

fixDirectory($current_dir);

exit 0;


sub fixDirectory
{
	my ($directory) = @_;
	my $dir = new IO::File;
	opendir ($dir, $directory) || die ("I cannot read $directory: $!\n");
	while ( my $file = readdir ($dir) )
	{
		next  if  $file eq '.' or $file eq '..';

		warn "Checking $file\n" if $verbose;

		if ( -d "${directory}/${file}" and not -l "${directory}/${file}" )
		{
			if ( $file =~ /$INVALID_DIRS/ )
			{
				warn "Not a valid dir: $file \n" if $verbose;
			}
			else
			{
				fixDirectory ("${directory}/${file}");
			}
		}
		else
		{
			fix_html_file (${directory},"${directory}/${file}") if $file =~ /.html?$/ ;
		}
	} # del while
} #de la subrutina


sub fix_html_file
{
	# This is a html file
	my ($directory,$file) = @_;

	warn "Opening the file $file.\n" if $verbose;

	open (FICHERO, "<${file}") or die ("Cannot open ${file} : $!\n");
	open (NEWFICHERO, ">${file}.bak") or die ("I cannot create a backup of ${file} : $!\n");

	while ( my $line =<FICHERO>)
	{
		chomp $line;

		# Here we must check:
		# 1.- the href ends in .$post.html and $POST  = $post and if not
		# cancel the href (remove the tag)
		# 2.- if the href does not end in $post.html and $POST.html exists
		# make it point there
		# 3.- if the href does not end in $post.html and $POST.html does not
		# exist then link to .en.html (english version)

		my $newline = "";
		my $endofline = "";

		while ( $line =~ m/A HREF=\"(.*?)\"/gi )
		{
			my $old_ref = $1;
			my $new_ref = $old_ref;
			$newline = $newline.$`;
			$endofline = $';

			if ( islocalreference($old_ref) )
			{
				warn "Checking reference $old_ref\n" if $verbose;
				if ( $old_ref =~ /\/$/ )
				{
					# This is a directory... check if the file exists
					warn "Fixing directory reference $old_ref\n" if $verbose;

					if ( -f "${directory}/${old_ref}/index.$POST.html" )
					{
						$new_ref = $old_ref."index.".$POST.".html";
					}
					if ( $new_ref eq $old_ref
					     and  -f "${directory}/${old_ref}/index.$DEFAULT.html" )
					{
						$new_ref = $old_ref."index.".$DEFAULT.".html";
					}
					if ( $new_ref eq $old_ref and -f "${directory}/${old_ref}/index.html" )
					{
						$new_ref = $old_ref."index.html";
					}
				}
				elsif ( $old_ref =~ /(.*?)\.(.*?)\.html$/ )
				{
					# This one uses does *not* use content negotiation...
					warn "Fixing HTML reference $old_ref\n" if $verbose;

					my $base = $1;
					my $ending = $2;

					if ( -f "${directory}/${base}.$POST.html" )
					{
						$new_ref = $base.".".$POST.".html";
					}
					if ( $new_ref eq $old_ref && -f "${directory}/${base}.$DEFAULT.html" )
					{
						$new_ref = $base.".".$DEFAULT.".html";
					}
				}
				elsif ( $old_ref !~ /([\w-]+)\.([\w-]+)$/ ) {
					warn "Fixing Content Negotiation reference $old_ref\n" if $verbose;

					# This one uses *does* use content negotiation...
					# Check as above but also move around files
					if ( -f "${directory}/${old_ref}.$POST.html" )
					{
						$new_ref = $old_ref.".".$POST.".html";
					}
					if ( "$new_ref eq $old_ref && -f ${directory}/${old_ref}.$DEFAULT.html" )
					{
						$new_ref = $old_ref.".".$DEFAULT.".html";
					}
					if ( "$new_ref eq $old_ref && -f ${directory}/${old_ref}.html" )
					{
						$new_ref = $old_ref.".html"
					}
					if ( "$new_ref eq $old_ref && -f ${directory}/${old_ref}" )
					{
						$new_ref = $old_ref.".html";
					}
				}
			}

			# After checking if $old_ref =/= $new_ref then substitute
			$newline .= qq{A HREF="$new_ref"};
			if ( $verbose and $new_ref ne $old_ref)
			{
				warn "Fixed reference $old_ref to $new_ref\n";
			}
		}
		$newline .= $endofline;
		$newline = $line if $newline eq "";

		warn "Changing $line to $newline\n" if $verbose;
		print NEWFICHERO $newline;
		print NEWFICHERO "\n";
	}
	close FICHERO;
	close NEWFICHERO;

	unlink $file;
	move("$file.bak", $file) 
		or die("Couldn't move `$file.bak' to `$file': $!\n");
}

# Checks if a reference points to a local resource,
# i.e. it is not in (http|ftp|gopher):// form
sub islocalreference
{
	my ($reference) = @_;
	if ($reference !~ /:\/\// )
	{
		warn "Local reference: $reference\n" if $verbose;
		return 1;
	}
	return;
}

__END__

