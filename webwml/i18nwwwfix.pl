#!/usr/bin/perl -w

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

getopts('vp:d:');
$POST = $opt_p;
$DEFAULT = "en"; #Default language is english (en)
$INVALID_DIRS="^\\.|\\.\\.|CVS\$";
if (!$opt_d) {
	$current_dir=`pwd`;
} else {
	$current_dir=$opt_d;
}
chomp $current_dir;
fixDirectory ($current_dir);
exit 0;

sub fixDirectory 
{
	my ($directory) = @_;
	my $dir = new IO::File;
	opendir ($dir, $directory) || die ("I cannot read $directory: $!");
        while ( $file = readdir ($dir) )
	{
                print STDERR "Checking $file\n" if $opt_v;
                if ( -d "${directory}/${file}" and ! -l "${directory}/${file}" )
                {
                        if ( $file =~ /$INVALID_DIRS/ )
                        { print STDERR "Not a valid dir: $file \n" if $opt_v; }
                        else
                        { fixDirectory ("${directory}/${file}"); }
		}
		else
                { fix_html_file (${directory},"${directory}/${file}") if $file =~ /.html?$/ ; }
	} # del while
} #de la subrutina

sub fix_html_file
{
# This is a html file
	my ($directory,$file) = @_;
	print "Opening the file $file.\n" if $opt_v;
	open (FICHERO, "<${file}") || die ("Cannot open ${file} : $!");
	open (NEWFICHERO, ">${file}.bak") || die ("I cannot create a backup of${file} : $!");
	while ( $line =<FICHERO>) {
		chomp $line;
# Here we must check:
# 1.- the href ends in .$post.html and $POST  = $post and if not 
# cancel the href (remove the tag)
# 2.- if the href does not end in $post.html and $POST.html exists
# make it point there
# 3.- if the href does not end in $post.html and $POST.html does not
# exist then link to .en.html (english version)

		my $newline ="";
		my $endofline ="";
		while ( $line =~ m/A HREF=\"(.*?)\"/gi )
		{ 
			my $old_ref = $1;
			my $new_ref = $old_ref;
			$newline = $newline.$`;
			$endofline = $';
			if ( islocalreference($old_ref) ) {
				print "Checking reference $old_ref\n" if $opt_v;
				if ( $old_ref =~ /\/$/ ) {
				# This is a directory... check if the file exists
				print "Fixing directory reference $old_ref\n" if $opt_v;
				$new_ref = $old_ref."index.".$POST.".html" if ( -f "${directory}/${old_ref}/index.$POST.html" );
				$new_ref = $old_ref."index.".$DEFAULT.".html" if ( $new_ref eq $old_ref && -f "${directory}/${old_ref}/index.$DEFAULT.html" );
				$new_ref = $old_ref."index.html" if ( $new_ref eq $old_ref && -f "${directory}/${old_ref}/index.html" );
				}
				elsif ( $old_ref =~ /(.*?)\.(.*?)\.html$/ ) {
				# This one uses does *not* use content negotiation...
				print "Fixing HTML reference $old_ref\n" if $opt_v;
				$base = $1;
				$ending = $2;
				$new_ref = $base.".".$POST.".html" if ( -f "${directory}/${base}.$POST.html" );
				$new_ref = $base.".".$DEFAULT.".html" if ( "$new_ref eq $old_ref && -f ${directory}/${base}.$DEFAULT.html" );
				}
				elsif ( $old_ref !~ /([\w-]+)\.([\w-]+)$/ ) {
				print "Fixing Content Negotiation reference $old_ref\n" if $opt_v;
				# This one uses *does* use content negotiation...
				# Check as above but also move around files
				$new_ref = $old_ref.".".$POST.".html" if ( -f "${directory}/${old_ref}.$POST.html" );
				$new_ref = $old_ref.".".$DEFAULT.".html" if ( "$new_ref eq $old_ref && -f ${directory}/${old_ref}.$DEFAULT.html" );
				$new_ref = $old_ref.".html" if ( "$new_ref eq $old_ref && -f ${directory}/${old_ref}.html" );
				if ( "$new_ref eq $old_ref && -f ${directory}/${old_ref}" ) {
					$new_ref = $old_ref.".html";
#				`mv ${directory}/${old_ref} ${directory}/${old_ref}.html`;
				
				}
				}
	
			}
# After checking if $old_ref =/= $new_ref then substitute
			$newline .= "A HREF=\"".$new_ref."\"";
			print "Fixed reference $old_ref to $new_ref\n" if ( $opt_v && $new_ref ne $old_ref) ; 
		}
		$newline  .= $endofline;
		$newline = $line if $newline eq "";
		print "Changing $line to $newline\n" if $opt_v;
		print NEWFICHERO $newline;
		print NEWFICHERO "\n";
	}
	close FICHERO;
	close NEWFICHERO;
	unlink $file;
	`mv $file.bak $file`;
}

sub islocalreference {
# Cheks if a reference points to a local resource, 
# i.e. it is not in (http|ftp|gopher):// form
	my ($reference) = @_;
	if ($reference !~ /:\/\// ) {
		print "Local reference: $reference\n" if $opt_v;
		return 1;
	} else {
		return 0 ; }
}
