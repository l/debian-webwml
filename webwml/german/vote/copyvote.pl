#!/usr/bin/perl -w

# This script copies a set of vote related files named on the command line, 
# and adds the translation-check header to them. It also will create the
# destination directory if necessary, and copy the Makefile from the source.
# Written in 2006 by Helge Kreutzmann <debian@helgefjell.de>

# Based on a script "copyadvisory.pl" by Peter Karlsson <peterk@debian.org>:
# Written in 2000-2006 by Peter Karlsson <peterk@debian.org>
# � Copyright 2000-2005 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use Date::Manip;
use Encode 'decode_utf8';

# Get command line
$number = $ARGV[0];

# Check usage.
unless ($number)
{
	print "Usage: $0 vote#\n\n";
	print "Copies the vote files from the English directory to the local one, translates\n";
	print "some standard strings and adds the translation-check header\n";
	exit;
}

# Some "global" variables
my $dheute=UnixDate(ParseDate("today"),"%Y-%m-%d");
# Check, sanitise and decode these environment variables
check_env_utf8('DEBFULLNAME');
check_env_utf8('NAME');
check_env_utf8('DEBEMAIL');
check_env_utf8('EMAIL');

my $TRANSLATOR="Karl Karlchen";
my $EMAIL="";
if (exists $env{'DEBEMAIL'} and $env{'DEBEMAIL'} =~ /^(.*)\s+<(.*)>$/) {
    $env{'DEBFULLNAME'} = $1 unless exists $env{'DEBFULLNAME'};
    $env{'DEBEMAIL'} = $2;
}
if (! exists $env{'DEBEMAIL'} or ! exists $env{'DEBFULLNAME'}) {
    if (exists $env{'EMAIL'} and $env{'EMAIL'} =~ /^(.*)\s+<(.*)>$/) {
        $env{'DEBFULLNAME'} = $1 unless exists $env{'DEBFULLNAME'};
        $env{'EMAIL'} = $2;
    }
}
if (exists $env{'DEBFULLNAME'}) {
    $TRANSLATOR = $env{'DEBFULLNAME'};
} elsif (exists $env{'NAME'}) {
    $TRANSLATOR = $env{'NAME'};
} else {
    my @pw = getpwuid $<;
    if (defined($pw[6])) {
        if (my $pw = decode_utf8($pw[6])) {
            $pw =~ s/,.*//;
            $TRANSLATOR = $pw;
        } else {
            warn "$progname warning: passwd full name field for uid $<\nis not UTF-8 encoded; ignoring\n";
        }
    }
}
if (exists $env{'DEBEMAIL'}) {
    $EMAIL = $env{'DEBEMAIL'};
} elsif (exists $env{'EMAIL'}) {
    $EMAIL = $env{'EMAIL'};
} else {
    $EMAIL ="";
}


$year = 2006;
$srcdir = "/scr/build/content/debian/web-commit/webwml/english/vote/$year";
# $srcdir = "../../english/vote/$year";
die "Unable to locate English version of vote $number.\n"
	if ! -d $srcdir;

# Locate vote files
#vote_007_index.src vote_007_majority.src vote_007_quorum.src vote_007_quorum.txt vote_007_results.src vote_007.wml suppl_007_stats_detailed.wml suppl_007_stats.wml
@vfiles = ("vote_".$number."_index.src", "vote_".$number."_majority.src", "vote_".$number."_quorum.src", "vote_".$number."_quorum.txt", "vote_".$number."_results.src", "vote_".$number.".wml", "suppl_".$number."_stats_detailed.wml", "suppl_".$number."_stats.wml");

#$number = "vote_" . $number if $number !~ /^vote_/;
foreach $vf (@vfiles)
{
#YEAR: while (-d "../../english/vote/$year")
#{
#	last YEAR if -e "../../english/vote/$year/$number.wml";
#	$year ++;
#}

# Create needed file and directory names
$srcfile= "$srcdir/$vf";
$cvsfile= "$srcdir/CVS/Entries";
$dstdir = "./$year";
$dstfile= "$dstdir/$vf";

# Sanity checks
die "File $srcfile does not exist\n"     unless -e $srcfile;
die "File $dstfile already exists\n"     if     -e $dstfile;
mkdir $dstdir, 0755                      unless -d $dstdir;

# Open the files
open CVS, $cvsfile
	or die "Could not read $cvsfile ($!)\n";

open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

# Retrieve the CVS version number
while (<CVS>)
{
	if (m[^/$number\.wml/([0-9]*\.[0-9]*)/]o)
	{
		$revision = $1;
	}
}

close CVS;

unless ($revision)
{
	print "Could not get revision number - bug in script?\n";
	$revision = '1.1';
}


# Insert the revision number
print DST qq'#use wml::debian::acronyms\n';
print DST qq'#use wml::debian::translation-check translation="$revision"\n';
print DST qq'# \$I';                                        # Too fool CVS
print DST qq'd: $vf,v 1.1 $year/11/02 21:15:10 jseidel Exp \$\n';
print DST qq'# Translator: $TRANSLATOR <$EMAIL> $dheute\n\n';


# Copy the file
while (<SRC>)
{
    #FIXME Depending on which file we copy
	#next if /\$Id/;
	if ($vf eq "vote_".$number."_results.src")
	{
	    s/Graphical rendering of the results/Grafische Darstellung der Ergebnisse/;
	    s/In the graph above, any pink colored nodes imply that/In der obigen Graphik implizieren die rosa gef�rbte Knoten jene,/;
	    s/the option did not pass majority, the Blue is the/die nicht die Mehrheit erlangten, der blaue ist der Gewinner. Das/;
	    s/winner. The Octagon is used for the options that did/Achteck wird f�r die Optionen verwendet, die nicht den Standard/;
	    s/not beat the default./geschlagen haben./;
	    s/In the following table, tally\[row x\]\[col y\] represents/In der folgenden Tabelle repr�sentiert tally[Zeile x][Spalte y]/;
	    s/the votes that option x received over option y. A/die Stimmen, die Option x �ber Option y erhalten hat. Eine <a/;
	    s#<a href="http://en.wikipedia.org/wiki/Schwartz_method">more#href="http://de.wikipedia.org/wiki/Schulze-Methode">detailliertere#;
	    s#detailed explanation of the beat matrix</a> may help in#Erkl�rung der Sieg-Matrix</a> kann Ihnen beim Verst�ndnis der#;
	    s#understanding the table. For understanding the Condorcet method, the#Tabelle helfen. Zum Verst�ndnis der Condorcet-Methode ist der <a#;
	    s#<a href="http://en.wikipedia.org/wiki/Condorcet_method">Wikipedia#href="http://de.wikipedia.org/wiki/Condorcet-Methode">\\#;
	    s#entry</a> is fairly informative.#Wikipedia-Eintrag</a> recht informativ.#;

            s#Debian uses the Condorcet method voting.#Debian benutzt die Condorcet-Methode f�r Abstimmungen.#;
            s#Simplistically, plain Condorcets method#Vereinfachend kann die grundlegende#;
            s#can be stated like so : <br/>#Condorcet-Methode folgenderma�en beschrieben werden:<br />#;
            s#<q>Consider all possible two-way races between candidates.#<q>Ziehe alle m�glichen Zweik�mpfe zwischen den Kandidaten#;
            s#The Condorcet winner, if there is one, is the one#in Betracht. Der Condorcet-Gewinner, wenn es einen gibt,#;
            s#candidate who can beat each other candidate in a two-way#ist derjenige Kandidat, der jeden anderen Kandidaten im#;
            s#race with that candidate.</q>#Zweikampf schlagen kann.</q>#;
            s#The problem is that in complex elections, there may well#Das Problem ist, dass es bei komplexen Wahlen durchaus zu#;
            s#be a circular relations ship in which A beats B, B beats C,#einer kreisf�rmigen Beziehung kommen kann, in der A �ber#;
            s#and C beats A. Most of the variations on Condorcet use#B siegt, B �ber C siegt und C �ber A siegt. Die meisten#;
            s#various means of resolving the tie. See#Variationen von Condorcet verwenden verschiedene Mittel,\num diese Pattsituation aufzul�sen. Siehe#;
            s#<a href="http://en.wikipedia.org/wiki/Cloneproof_Schwartz_Sequential_Dropping">Cloneproof Schwartz Sequential Dropping</a>#<q><a href="http://de.wikipedia.org/wiki/Schulze-Methode">\\#;
            s#for details. Debian's variation is spelled out in the#Cloneproof Schwartz Sequential Dropping</a></q> f�r Details.\nDie Variation von Debian ist in#;
            s#<a href="\$\(HOME\)/devel/constitution">the constitution</a>,#<a href="\$(HOME)/devel/constitution">der Verfassung</a>#;
            s#specifically,  A.6.#schriftlich festgehalten, speziell � A.6.#;
	    s/Looking at row (.*), column (.*),/Wie in Zeile $1, Spalte $2 sichtbar, erhielt/;
	    s/Option (.*) defeats Option (.*) by \( (.*) -   (.*)\) =  (.*) votes/Option $1 besiegt Option $2 mit ( $3 -   $4) =  $5 Stimmen/;

# Generic
	    s/needs/ben�tigt/;
	    s/The Beat Matrix/Die Sieg-Matrix/;
	    s/Pair-wise defeats/Paarweise Niederlagen/;
	    s/The Schwartz Set contains/Die Schwartz-Menge enth�lt/;
	    s/The winners/Die Gewinner/;
	    s/received (.*) votes over/$1 Stimmen gegen�ber/;
	    s#<br/>#<br />#;
	}
	if ($vf eq "vote_".$number.".wml")
	{
	    s#General Resolution#Allgemeiner Beschluss#;
    	    s#Proposal and amendment#Vorschlag und �nderungsantrag#;
	    s#Discussion Period#Diskussionsperiode#;
	    s#Voting Period#Abstimmungsperiode#;
	    s#With the current list of <a href="(.*)">voting#Mit der aktuellen Liste von <a href="$1">stimmberechtigten#;
            s#developers</a>, we have:#Entwicklern</a> haben wir:#;
	    s#For this GR, as always#F�r diese <acronym_GR /> werden wie immer w�hrend der Wahlperiode periodisch <a#;
	    s#<a href="(.*)">statistics</a>#href="$1">\\#;
	    s#shall be gathered about ballots received and acknowledgements#Statistiken</a> �ber die empfangenen Stimmen und die versandten#;
            s#sent periodically during the voting period.  Additionally, the#Best�tigungen gesammelt. Zus�tzlich w�rde die Liste der <a#;
	    s#list of##;
	    s#<a href="(.*)">voters</a>#href="$1">Abstimmenden</a> ver�ffentlicht. Auch#;
	    s#would be made publicly available. Also, the##;
            s#<a href="(.*)">tally sheet</a>#kann die <a href="$1">Strichliste</a>#;
	    s#may also be viewed after to voting is done \(Note that#angeschaut werden (beachten Sie, dass es sich#;
            s#while the vote is in progress it is a dummy tally sheet\).#w�hrend des Urnengangs um eine Pseudo-Strichliste handelt).#;
	    s#All the amendments need simple majority#Alle �nderungsantr�ge ben�tigen die einfache Mehrheit.#;
	    s#The outcome#Das Ergebnis#;

	    #Generic
	    s#January#Januar#;
	    s#February#Februar#;
	    s#March#M�rz#;
	    s#May#Mai#;
	    s#June#Juni#;
	    s#July#Juli#;
	    s#October#Oktober#;
	    s#December#Dezember#;
	    s#Monday#Montag#;
	    s#Tuesday#Dienstag#;
	    s#Wednesday#Mittwoch#;
	    s#Thursday#Donnerstag#;
	    s#Friday#Freitag#;
	    s#Saturday#Samstag#;
	    s#Sunday#Sonntag#;
	    s#<sup>st</sup>#.#;
	    s#<sup>th</sup>#.#;

	}
	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
}

# Taken from dch by Christoph Lameter and Julian Gilbey
# Is the environment variable valid or not?
sub check_env_utf8 {
    my $envvar = $_[0];

    if (exists $ENV{$envvar} and $ENV{$envvar} ne '') {
        if (! decode_utf8($ENV{$envvar})) {
            warn "$progname warning: environment variable $envvar not UTF-8 encoded; ignoring\n";
        } else {
            $env{$envvar} = decode_utf8($ENV{$envvar});
        }
    }
}

