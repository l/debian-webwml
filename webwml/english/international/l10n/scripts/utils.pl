#!/usr/bin/perl -w

# utils.pl -- some utilities for transmonitor
# file of subs :
# - is_cat(name) : returns true if name is a catalog for catgets
# - fail : to display nice errors
# - read_data(path_to_desc_file) : reads di18n.data files

# Copyright (C) 1999 by Martin Quinson
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, you can find it on the World Wide
# Web at http://www.gnu.org/copyleft/gpl.html, or write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.

my $dpkglibdir="/usr/lib/dpkg";

# XXX we must first install liblocale-codes-perl on va.debian.org
# use Locale::Language;
# XXX include /usr/lib/perl5/Locale/Language.pm
use lib 'scripts';
use Language;
use Country;

push (@INC, $dpkglibdir);
require 'controllib.pl';

#
# sub is_lang(code) : returns true iff code is a valide code of language
#   nb: it could be of form ll_CC with CC country code
sub is_lang {
    my $code = shift;
    if ($code =~ /^(..)_(..)$/) {
	return (defined(code2language($1)) && defined(code2country($2)));
    }
    return defined code2language($code);
}

sub clear_data {
    my $dataref=shift;
    my %data = %{$dataref};
    my $pkg;
    foreach $pkg (sort keys %data) {
	@{$data{$pkg}{"warnings"}} = ();
	@{$data{$pkg}{"errors"}} = ();
	%{$data{$pkg}{"stats"}} = ();
	%{$data{$pkg}} = ();
    }
    %data = ();
}
    
#
# read_data(path_to_desc_file) : reads di18n.data files
#
sub read_data {
    my ($datafile) = shift;
    my %data;

    if (!open DESC,"$datafile") {
	return (0,\%data);
    }
    my ($pkg)="";
    my ($last_section)=""; 
    # ""  : last can't be continued
    # "err"  : in err
    # "warn" : in warning
    my($last_nb)=0; # were to pu the infos
    my $line=0;
    my $parse_warn = sub {
	my $msg = shift;
	my $str = "Error while parsing $datafile at line $line :\n ".$msg."\n";
	&warn ($str);
    };

    while (<DESC>) {
	chop;
	$line++;
	# tabs at the beginning are illegal, but handle them anyways
    	s/^\t/ \t/o;

	# empty line?
    	if (/^\s*$/) {
	    $pkg = "";
	}
	# package name section ?
	elsif (/^Package: (.*)$/) {
	    $pkg=$1;
	    $last_section="";
	}
	# package version section ?
	elsif (/^Version: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn("version section comes before package name section");
	    }
	    $data{$pkg}{"version"} = $1;
	    $last_section="";
	}
	# "package section" section ?
	elsif (/^Section: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("'package section' section comes before package name section");
	    }
	    $data{$pkg}{"section"} = $1;
	    $last_section="";
	}
	# package priority section ?
	elsif (/^Priority: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("priority section comes before package name section\n");
	    }
	    $data{$pkg}{"priority"} = $1;
	    $last_section="";
	}
	# type (of i18n organisation) section ?
	elsif (/^Type: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("type section comes before package name section");
	    }
	    $data{$pkg}{"type"} = $1;
	    $last_section="";
	}
	# type (of package) section ?
	elsif (/^Upstream: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("upstream section comes before package name section");
	    }
	    $data{$pkg}{"upstream"} = $1;
	    $last_section="";
	}
	# stats ?
	elsif (/^Stats: ([^:]*): (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("stat section comes before package name section");
	    }
	    $data{$pkg}{"stats"}{$1} = $2;
	    $last_section = "";
	}
	# begin of error section ?
	elsif (/^Errors:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("errors section comes before package name section");
	    }
	    $last_section="errors";
	    $last_nb=0;
	}
	# begin of warnings section ?
	elsif (/^Warnings:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("warnings section comes before package name section");
	    }
	    $last_section="warnings";
	    $last_nb=0;
	}
	# begin of catgets section ?
	elsif (/^Catgets:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("catgets section comes before package name section");
	    }
	    $last_section="catgets";
	    $last_nb=0;
	}
	# begin of gettext section ?
	elsif (/^Gettext:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("gettext section comes before package name section");
	    }
	    $last_section="gettext";
	    $last_nb=0;
	}
	# begin of nls section ?
	elsif (/^NLS:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("nls files section comes before package name section");
	    }
	    $last_section="nls";
	    $last_nb=0;
	}
	# begin of po files section ?
	elsif (/^PO:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("po files section comes before package name section");
	    }
	    $last_section="po";
	    $last_nb=0;
	}
	# begin of templates files section ?
	elsif (/^TEMPLATES:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("templates files section comes before package name section");
	    }
	    $last_section="templates";
	    $last_nb=0;
	}
	# begin of menu files section ?
	elsif (/^MENU:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("menu files section comes before package name section");
	    }
	    $last_section="menu";
	    $last_nb=0;
	}
	# next item of current section ?
	elsif (/^ .$/) {
	    if ($pkg eq "") {
		&$parse_warn ("continuing a section comes before package name section");
	    }
	    if (($last_section eq "")
		||($last_section eq "po")||($last_section eq "nls")||($last_section eq "templates")
		||($last_section eq "catgets")||($last_section eq "gettext")) {
		&$parse_warn ("this section can't be continued");
	    }
	    $last_nb++;
	}
	# continuing current item ?
	elsif (/^ (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("continuing a section comes before package name section");
	    }
	    if ($last_section eq "") {
		&$parse_warn ("this section can't be continued");
	    }
	    if (($last_section eq "po")||($last_section eq "nls")||($last_section eq "templates")
		||($last_section eq "catgets")||($last_section eq "gettext")) {
		$data{$pkg}{$last_section}[$last_nb] = "$1";
		$last_nb++;
	    } else {
		$data{$pkg}{$last_section}[$last_nb] .= "$1\n";
	    }
	}
	# else ? it's a parse error !
	else {
	    &$parse_warn ("parse error");
	}
    }
    close DESC;
    return (1,\%data);
}
#
# read_sources(path_to_sources_file) : reads Sources files (obtained from ftp)
#
sub read_sources {
    my ($datafile) = shift;
    my %data;

    if (!open DESC,"$datafile") {
	return (0,\%data);
    }
    my ($pkg)="";
    my ($last_section)=""; 
    # ""  : last can't be continued
    # "err"  : in err
    # "warn" : in warning
    my($last_nb)=0; # were to pu the infos
    my $line=0;
    my $parse_warn = sub {
	my $msg = shift;
	my $str = "Error while parsing $datafile at line $line :\n ".$msg."\n";
	&warn ($str);
    };

    while (<DESC>) {
	chop;
	$line++;
	# tabs at the beginning are illegal, but handle them anyways
    	s/^\t/ \t/o;

	# empty line?
    	if (/^\s*$/) {
	    $pkg = "";
	}
	# package name section ?
	elsif (/^Package: (.*)$/) {
	    $pkg=$1;
	    $last_section="";
	}
	# package version section ?
	elsif (/^Version: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn("version section comes before package name section");
	    }
	    $data{$pkg}{"version"} = $1;
	    $last_section="";
	}
	# "package section" section ?
	elsif (/^Section: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("'package section' section comes before package name section");
	    }
	    $data{$pkg}{"section"} = $1;
	    $last_section="";
	}
	# package priority section ?
	elsif (/^Priority: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("priority section comes before package name section\n");
	    }
	    $data{$pkg}{"priority"} = $1;
	    $last_section="";
	}
	# Name of binary packages (unused)
	elsif (/^Binary: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("binary section comes before package name section");
	    }
	    $data{$pkg}{"binary"} = $1;
	    $last_section="";
	}
	# Maintainer (will be used one day)
	elsif (/^Maintainer: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Maintainer section comes before package name section");
	    }
	    $data{$pkg}{"maintainer"} = $1;
	    $last_section="";
	}
	# Architecture (unused)
	elsif (/^Architecture: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Architecture section comes before package name section");
	    }
	    $data{$pkg}{"architecture"} = $1;
	    $last_section="";
	}
	# Build-Depends (unused)
	elsif (/^Build-Depends: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Build-Depends section comes before package name section");
	    }
	    $data{$pkg}{"Build-Depends"} = $1;
	    $last_section="Build";
	}
	# Build-Conflicts (unused)
	elsif (/^Build-Conflicts: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Build-Conflicts section comes before package name section");
	    }
	    $data{$pkg}{"Build-Conflicts"} = $1;
	    $last_section="Build";
	}
	# Build-Depends-Indep (unused)
	elsif (/^Build-Depends-Indep: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Build-Depends-Indep section comes before package name section");
	    }
	    $data{$pkg}{"Build-Depends-Indep"} = $1;
	    $last_section="Build";
	}
	# Standards-Version (unused)
	elsif (/^Standards-Version: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Standards-Version section comes before package name section");
	    }
	    $data{$pkg}{"Standards-Version"} = $1;
	    $last_section="";
	}
	# Directory
	elsif (/^Directory: (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Directory section comes before package name section");
	    }
	    $data{$pkg}{"directory"} = $1;
	    $last_section="";
	}
	# begin of files section ?
	elsif (/^Files:$/) {
	    if ($pkg eq "") {
		&$parse_warn ("Files section comes before package name section");
	    }
	    $last_section="files";
	    $last_nb=0;
	}
	# begin of format section ?
	elsif (/^Format:/) {
	    if ($pkg eq "") {
		&$parse_warn ("Format section comes before package name section");
	    }
	    $last_section="format";
	    $last_nb=0;
	}
	# begin of Origin section ?
	elsif (/^Origin:/) {
	    if ($pkg eq "") {
		&$parse_warn ("Origin section comes before package name section");
	    }
	    $last_section="origin";
	    $last_nb=0;
	}
	# next item of current section ?
	elsif (/^ .$/) {
	    if ($pkg eq "") {
		&$parse_warn ("continuing a section comes before package name section");
	    }
	    if (($last_section eq "")
		||($last_section eq "files")) {
		&$parse_warn ("this section can't be continued");
	    }
	    $last_nb++;
	}
	# continuing current item ?
	elsif (/^ (.*)$/) {
	    if ($pkg eq "") {
		&$parse_warn ("continuing a section comes before package name section");
	    }
	    if ($last_section eq "") {
		&$parse_warn ("this section can't be continued");
	    }
	    if ($last_section eq "files") {
		$data{$pkg}{$last_section}[$last_nb] .= "$1";
		$last_nb++;
	    } else {
		$data{$pkg}{$last_section}[$last_nb] .= "$1\n";
	    }
	}
	# else ? it's a parse error !
	else {
	    &$parse_warn ("parse error:\n".$_);
	}
    }
    close DESC;
    return (1,\%data);
}

#
# write_data(path_to_desc_file,%data) : write di18n.data file
#
sub write_data {
    my $path = shift;
    my $dataref=shift;
    my %data = %{$dataref};
    my $pkg; # current package
    my $lang; # current language
    my $nb; # nb of section in errors or warnings
    my @list; # all the errors fields
    my @strs; #strings of one error field 
    my $line; # a line in one error field

    open DESC,">$path" or &error ("can't open $path in write access");
    foreach $pkg (keys %data) {
	print DESC "\nPackage: $pkg\n";
	if (defined ($data{$pkg}{'version'})){ print DESC "Version: $data{$pkg}{'version'}\n";}
	if (defined ($data{$pkg}{'section'})){ print DESC "Section: $data{$pkg}{'section'}\n";}
	if (defined ($data{$pkg}{'priority'})){print DESC "Priority: $data{$pkg}{'priority'}\n";}
	if (defined ($data{$pkg}{'type'})){    print DESC "Type: $data{$pkg}{'type'}\n";}
	if (defined ($data{$pkg}{'upstream'})){    print DESC "Upstream: $data{$pkg}{'upstream'}\n";}
	foreach $lang (keys %{$data{$pkg}{"stats"}}) {
	    print DESC "Stats: $lang: $data{$pkg}{'stats'}{$lang}\n";
	}
	if (defined($data{$pkg}{"errors"})) {
	    if (0 != @{$data{$pkg}{"errors"}}) {
		print DESC "Errors:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"errors"}};$nb++) {
#		print "$nb";
		next unless defined $data{$pkg}{"errors"}[$nb];
		@strs = split (/\n/,$data{$pkg}{"errors"}[$nb]);
		while ($line = shift @strs) {
		    print DESC " $line\n";
		}
		if ($nb<@{$data{$pkg}{"errors"}}-1){
		    print DESC " .\n";
		}
	    }
	}
	if (defined($data{$pkg}{"warnings"})) {
	    if (0 != @{$data{$pkg}{"warnings"}}) {
		print DESC "Warnings:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"warnings"}};$nb++) {
		@strs = split (/\n/,$data{$pkg}{"warnings"}[$nb]);
		while ($line = shift @strs) {
		    print DESC " $line\n";
		}
		if ($nb<@{$data{$pkg}{"warnings"}}-1){
		    print DESC " .\n";
		}
	    }
	}

	if (defined($data{$pkg}{"po"})) {
	    if (0 != @{$data{$pkg}{"po"}}) {
		print DESC "PO:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"po"}};$nb++) {
		print DESC " $data{$pkg}{'po'}[$nb]\n";
	    }
	}
	if (defined($data{$pkg}{"templates"})) {
	    if (0 != @{$data{$pkg}{"templates"}}) {
		print DESC "TEMPLATES:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"templates"}};$nb++) {
		print DESC " $data{$pkg}{'templates'}[$nb]\n";
	    }
	}
	if (defined($data{$pkg}{"menu"})) {
	    if (0 != @{$data{$pkg}{"menu"}}) {
		print DESC "MENU:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"menu"}};$nb++) {
		print DESC " $data{$pkg}{'menu'}[$nb]\n";
	    }
	}

	if (defined($data{$pkg}{"nls"})) {
	    if (0 != @{$data{$pkg}{"nls"}}) {
		print DESC "NLS:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"nls"}};$nb++) {
		print DESC " $data{$pkg}{'nls'}[$nb]\n";
	    }
	}
	if (defined($data{$pkg}{"catgets"})) {
	    if (0 != @{$data{$pkg}{"catgets"}}) {
		print DESC "Catgets:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"catgets"}};$nb++) {
		print DESC " $data{$pkg}{'catgets'}[$nb]\n";
	    }
	}
	if (defined($data{$pkg}{"gettext"})) {
	    if (0 != @{$data{$pkg}{"gettext"}}) {
		print DESC "Gettext:\n";
	    }
	    for ($nb=0;$nb<@{$data{$pkg}{"gettext"}};$nb++) {
		print DESC " $data{$pkg}{'gettext'}[$nb]\n";
	    }
	}

    }
    close DESC or &error ("can't close the file $path");
}
sub dump_data {
    my $dataref=shift;
    my %data = %{$dataref};
    my $hash1;
    my $hash2;
    my $hash3;
    my @list;
    print "(dump of the data)\n";
    foreach $hash1 (sort keys %data) {
	foreach $hash2 (sort keys %{$data{$hash1}}){
	    if (($hash2 eq "po")||($hash2 eq "nls")){
		@list = @{$data{$hash1}{$hash2}};
		print "\$data{$hash1}{$hash2}=\n";
		while ($hash3 = shift @list) {
		    print " $hash3\n";
		}
	    } elsif (($hash2 eq "warnings")||($hash2 eq "errors")){
		print "\$data{$hash1}{$hash2}=\n@{$data{$hash1}{$hash2}}";
	    } elsif ($hash2 eq "stats") {
		foreach $hash3 (sort keys %{$data{$hash1}{$hash2}}){
		    print "\$data{$hash1}{$hash2}{$hash3}=$data{$hash1}{$hash2}{$hash3}\n";
		}
	    } else {
		print "\$data{$hash1}{$hash2}=$data{$hash1}{$hash2}\n";
	    }
	}
    }
}
#
# regexp(file,pattern)
#   greps the file against the pattern, and return the number of occurences
#   if file is a directory, do it for all sub dir an files in it, and returns
#   the summe
# (used to grep against "catgets" and "gettext")
sub regexp {
  my ($name, $pattern) = @_;
  chop ($name) if ($name =~ /\/$/);

  return regexp_all($name,$pattern);
  
  sub regexp_all {
    my ($name, $pattern) = @_;
    my ($file);
    my ($count)=0;
    my ($subfile);
    
    if (-d $name) {
      if (!opendir (DIR,$name)) {
	&warn("Unable to open the directory $name : $!");
	return 0;
      }
      foreach $file (readdir(DIR)) {
	$subfile = "$name/$file"; 
	next if ($file eq "." || $file eq ".." || -l $subfile);
	$count=$count+regexp_all($subfile,$pattern);
    } 
    } else {
      $count = $count + regexp_one($name,$pattern);
    }
    return $count;
  }

  sub regexp_one {
    my ($name, $pattern) = @_;
    my $line;
    my ($count) = 0;
    
    if (! open(FH,$name)) { 
      &warn("Unable to open $name : $!"); 
      return 0;
    }
    while (defined($line = <FH>)) {
      if ($line =~ /$pattern/) {
	$count ++;
      }
    }
    close FH;
    return $count; 
  }
}
# end of sub regexp

# (Stolen from lintian)
# general function to read dpkg control files
# this function can parse output of `dpkg-deb -f', .dsc, 
# and .changes files (and probably all similar formats)
# arguments:
#    $file
# output:
#    list of hashes
#    (a hash contains one sections,
#    keys in hash are lower case letters of control fields)
sub parse_dpkg_control  {
    my ($file) = @_;
    
    my @data;
    my $cur_section = 0;
    my $open_section = 0;
    my $last_tag;
    
    while (<CONTROL>) {
	chop;
	
	# tabs at the beginning are illegal, but handle them anyways
        s/^\t/ \t/o;
	
	# empty line?
        if (/^\s*$/) {
	    if ($open_section) {
		# end of current section
		$cur_section++;
		$open_section = 0;
	    }
	}
        # pgp sig?
	elsif (/^-----BEGIN PGP SIGNATURE/) 
	{       # skip until end of signature
	    while (<CONTROL>) 
	    { last if /^-----END PGP SIGNATURE/o; }
        }
        # other pgp control?
        elsif (/^-----BEGIN PGP/) 
	{       # skip until the next blank line
	    while (<CONTROL>) { last if /^\s*$/o; }
        }
        # new empty field?
        elsif (/^(\S+):\s*$/o) 
	{
	    $open_section = 1;
	    
	    my ($tag) = (lc $1);
	    $data[$cur_section]->{$tag} = '';
	    
	    $last_tag = $tag;
        }
        # new field?
        elsif (/^(\S+): (.*)$/o) 
	{
	    $open_section = 1;
	    
	    my ($tag,$value) = (lc $1,$2);
	    $data[$cur_section]->{$tag} = $value;
	    
	    $last_tag = $tag;
        }
        # continued field?
        elsif (/^ (.*)$/o) 
	{
	    $open_section or fail("syntax error in control file: $_");
	    
	    $data[$cur_section]->{$last_tag} .= "\n".$1;
        }
    }
    
    return @data;
}

sub l10n_add {
    my $stat1 = shift;
    my $stat2 = shift;
    $stat1 = "0t0f0u" unless (defined($stat1));
    $stat2 = "0t0f0u" unless (defined($stat2));

    my $t = "0";
    my $u = "0";
    my $f = "0";
    my $res;

    if ($stat1 =~ /([0-9]*)t/) {  $t+=$1;  }
    if ($stat1 =~ /([0-9]*)u/) {  $u+=$1;  }
    if ($stat1 =~ /([0-9]*)f/) {  $f+=$1;  }

    if ($stat2 =~ /([0-9]*)t/) {  $t+=$1;  }
    if ($stat2 =~ /([0-9]*)u/) {  $u+=$1;  }
    if ($stat2 =~ /([0-9]*)f/) {  $f+=$1;  }

    $res ="$t t$f f$u u";
    $res =~ s/ //g;
    return $res;
}
