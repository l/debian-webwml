#!/usr/bin/perl -w

# This script copies a set of vote related files named on the command line, 
# and adds the translation-check header to them. It also will create the
# destination directory if necessary, and copy the Makefile from the source.
# Written in 2006-2011 by Helge Kreutzmann <debian@helgefjell.de>

# Based on a script "copyadvisory.pl" by Peter Karlsson <peterk@debian.org>:
# Written in 2000-2006 by Peter Karlsson <peterk@debian.org>
# © Copyright 2000-2009 Software in the public interest, Inc.
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


$year = 2011;
# Note: you may have to adjust the following path
$srcdir = "/scr/build/content/debian/web-commit/webwml/english/vote/$year";
# $srcdir = "../../english/vote/$year";
die "Unable to locate English version of vote $number.\n"
	if ! -d $srcdir;

# Locate vote files
#vote_007_index.src vote_007_majority.src vote_007_quorum.src vote_007_quorum.txt vote_007_results.src vote_007.wml suppl_007_stats_detailed.wml suppl_007_stats.wml
#@vfiles = ("vote_".$number."_index.src", "vote_".$number."_majority.src", "vote_".$number."_quorum.src", "vote_".$number."_quorum.txt", "vote_".$number."_results.src", "vote_".$number.".wml", "suppl_".$number."_stats_detailed.wml", "suppl_".$number."_stats.wml");
@vfiles = ("vote_".$number.".wml");

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
$revision="";
while (<CVS>)
{
#print "$_ :: $vf\n";
#if (m[^/$number\.wml/([0-9]*\.[0-9]*)/]o)
	if (m(^/$vf/([0-9]*\.[0-9]*)/))
	{
		$revision = $1;
#	print "Found $revision\n";
	}
}

close CVS;

unless ($revision)
{
	print "Could not get revision number for $vf - bug in script?\n";
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
	    s/In the graph above, any pink colored nodes imply that/In der obigen Graphik implizieren die rosa gefärbte Knoten jene,/;
	    s/the option did not pass majority, the Blue is the/die nicht die Mehrheit erlangten, der blaue ist der Gewinner. Das/;
	    s/winner. The Octagon is used for the options that did/Achteck wird für die Optionen verwendet, die nicht den Standard/;
	    s/not beat the default./geschlagen haben./;
	    s/In the following table, tally\[row x\]\[col y\] represents/In der folgenden Tabelle repräsentiert tally[Zeile x][Spalte y]/;
	    s/the votes that option x received over option y. A/die Stimmen, die Option x über Option y erhalten hat. Eine <a/;
	    s#<a href="http://en.wikipedia.org/wiki/Schwartz_method">more#href="http://de.wikipedia.org/wiki/Schulze-Methode">detailliertere#;
	    s#detailed explanation of the beat matrix</a> may help in#Erklärung der Sieg-Matrix</a> kann Ihnen beim Verständnis der#;
	    s#understanding the table. For understanding the Condorcet method, the#Tabelle helfen. Zum Verständnis der Condorcet-Methode ist der <a#;
	    s#<a href="http://en.wikipedia.org/wiki/Condorcet_method">Wikipedia#href="http://de.wikipedia.org/wiki/Condorcet-Methode">\\#;
	    s#entry</a> is fairly informative.#Wikipedia-Eintrag</a> recht informativ.#;

            s#Debian uses the Condorcet method voting.#Debian benutzt die Condorcet-Methode für Abstimmungen.#;
            s#Debian uses the Condorcet method for votes.#Debian benutzt die Condorcet-Methode für Abstimmungen.#;
            s#Simplistically, plain Condorcets method#Vereinfachend kann die grundlegende#;
            s#can be stated like so : <br/>#Condorcet-Methode folgendermaßen beschrieben werden:<br />#;
            s#can be stated like so : <br />#Condorcet-Methode folgendermaßen beschrieben werden:<br />#;
            s#<q>Consider all possible two-way races between candidates.#<q>Ziehe alle möglichen Zweikämpfe zwischen den Kandidaten#;
            s#The Condorcet winner, if there is one, is the one#in Betracht. Der Condorcet-Gewinner, falls es einen gibt,#;
            s#candidate who can beat each other candidate in a two-way#ist derjenige Kandidat, der jeden anderen Kandidaten im#;
            s#race with that candidate.</q>#Zweikampf schlagen kann.</q>#;
	    s#The problem is that in complex elections, there may well be a#Das Problem ist, dass es bei komplexen Wahlen durchaus zu#;
            s#The problem is that in complex elections, there may well#Das Problem ist, dass es bei komplexen Wahlen durchaus zu#;
	    s#circular relations ship in which A beats B, B beats C, and C#einer
	    kreisförmigen Beziehung kommen kann, in der A über#;
            s#be a circular relations ship in which A beats B, B beats C,#einer kreisförmigen Beziehung kommen kann, in der A über#;
	    s#beats A. Most of the variations on Condorcet use various means#B siegt, B über C siegt und C über A siegt. Die meisten#;
            s#and C beats A. Most of the variations on Condorcet use#B siegt, B über C siegt und C über A siegt. Die meisten#;
	    s#of resolving the tie. See <a#Variationen von Condorcet
	    verwenden verschiedene Mittel,\num diese Pattsituation aufzulösen. Siehe#;
            s#various means of resolving the tie. See#Variationen von Condorcet verwenden verschiedene Mittel,\num diese Pattsituation aufzulösen. Siehe#;
#    s#href="http://en.wikipedia.org/wiki/Cloneproof_Schwartz_Sequential_Dropping">Cloneproof#<q><a href="http://de.wikipedia.org/wiki/Schulze-Methode">\\#;
            s#<a href="http://en.wikipedia.org/wiki/Cloneproof_Schwartz_Sequential_Dropping">Cloneproof Schwartz Sequential Dropping</a>#<q><a href="http://de.wikipedia.org/wiki/Schulze-Methode">\\#;
	    s#Schwartz Sequential Dropping</a> for details. Debian's variation#Cloneproof Schwartz Sequential Dropping</a></q> für Details.\nDie Variation von Debian ist in#;
            s#for details. Debian's variation is spelled out in the#Cloneproof Schwartz Sequential Dropping</a></q> für Details.\nDie Variation von Debian ist in#;
	    s#is spelled out in the <a href="\$\(HOME\)/devel/constitution">the#<a href="\$(HOME)/devel/constitution">der Verfassung</a>#;
            s#<a href="\$\(HOME\)/devel/constitution">the constitution</a>,#<a href="\$(HOME)/devel/constitution">der Verfassung</a>#;
	    s#constitution</a>, specifically, A.6.#schriftlich festgehalten, speziell § A.6.#;
            s#specifically,  A.6.#schriftlich festgehalten, speziell § A.6.#;
	    s/Looking at row (.*), column (.*),/Wie in Zeile $1, Spalte $2 sichtbar, erhielt/;
	    s/Option (.*) defeats Option (.*) by \( (.*) -  (.*)\) =\s*(.*) votes/Option $1 besiegt Option $2 mit \( $3 -   $4\) =  $5 Stimmen/;

# Generic
	    s/needs/benötigt/;
	    s/The Beat Matrix/Die Sieg-Matrix/;
	    s/Pair-wise defeats/Paarweise Niederlagen/;
	    s/The Schwartz Set contains/Die Schwartz-Menge enthält/;
	    s/The winners/Die Gewinner/;
	    s/received (.*) votes over/$1 Stimmen gegenüber/;
	    s#<br/>#<br />#;
	    s#To Be determined#Muss noch bestimmt werden#;
	    s#To be determined#Muss noch bestimmt werden#;
	}
	if ($vf eq "vote_".$number.".wml")
	{
	    s#General Resolution#Allgemeiner Beschluss#;
    	    s#Proposal and amendment#Vorschlag und Änderungsantrag#;
	    s#Discussion Period#Diskussionsperiode#;
	    s#Voting Period#Abstimmungsperiode#;
	    s#With the current list of <a href="(.*)">voting#Mit der aktuellen Liste von <a href="$1">stimmberechtigten#;
            s#developers</a>, we have:#Entwicklern</a> haben wir:#;
	    s#For this GR, as always#Für diese <acronym_GR /> werden wie immer während der Wahlperiode periodisch <a#;
	    s#<a href="(.*)"\s*>statistics</a>#href="$1">\\#;
	    s#href="(.*)"\s*>statistics</a>#href="$1">\\#;
	    s#shall be gathered about ballots received and acknowledgements#Statistiken</a> über die empfangenen Stimmen und die versandten#;
	    s#will be gathered about ballots received and#Statistiken</a> über die empfangenen Stimmen#;
	    s#acknowledgements sent periodically during the voting#und die versandten Bestätigungen gesammelt.#;
            s#sent periodically during the voting period.  Additionally, the#Bestätigungen gesammelt. Zusätzlich würde die Liste der <a#;
	    s#period.  Additionally, the  <a#Zusätzlich würde die Liste der <a#;
	    s#Additionally, the list of <a#Zusätzlich würde die Liste der <a#;
	    # FIXME Does not work?
	    s#list of##;
	    s#<a (.*)="(.*)"\s*>voters</a>#$1="$2">Abstimmenden</a> veröffentlicht. Auch#;
            s#(.*)="(.*)">voters</a> will be#$1="$2">Abstimmenden</a> veröffentlicht. Auch#;
	    s#would be made publicly available. Also, the##;
            s#<a (.*)="(.*)"\s*>tally sheet</a>#kann die <a $1="$2">Strichliste</a>#;
	    s#may also be viewed after to voting is done \(Note that#angeschaut werden (beachten Sie, dass es sich#;
            s#while the vote is in progress it is a dummy tally sheet\).#während des Urnengangs um eine Pseudo-Strichliste handelt).#;
   	    s#This year, like always,#Dieses Jahr werden wie immer periodisch während der Wahlperiode <a#;
	    s#<a (.*)="(.*)">statistics</a> shall be gathered#$1="$2">Statistiken</a>#;
	    s#about ballots received and acknowledgements sent#über die empfangenen Stimmen und die versandten#;
	    s#periodically during the voting period.  Additionally, the#Bestätigungen gesammelt. Zusätzlich wird die Liste der <a#;
            s#list of <a (\w*)="(.*)">voters</a>#$1="$2">Abstimmenden</a> aufgezeichnet. Auch#;  # FIXME Is ignored (pattern order)
            s#recorded. Also, the <a (.*)="(.*)">tally#kann die <a $1="$2">Strichliste</a>#;
            s#sheet</a> will also be made available to be viewed.#angeschaut werden.#;
            s#Please remember that the project leader election has a#Bitte beachten Sie, dass die Wahl des Projektleiters einen#;
            s#secret ballot, so the tally sheet will be produced with#geheimen Stimmzettel hat, so dass die Strichliste mit dem Hash des#;
            s#the hash of the alias of the voter rather than the name;#Aliases des Wählenden statt dessen Namen erstellt wird;#;
            s#the alias shall be sent to the corresponding voter along#der Alias wird dem Wähler zusammen mit der Bestätigung des#;
            s#with the acknowledgement of the ballot so that people may#Wahlzettels übersandt, so dass jeder überprüfen kann, ob#;
            s#verify that their votes were correctly tabulated. While#seine Stimme korrekt eingetragen wurde. Während des#;
            s#the voting is open the tally will be a dummy one; after#Urnengangs handelt es sich um eine Pseudo-Strichliste; die#;
            s#the vote, the final tally sheet will be put in#endgültige Strichliste wird nach Abschluss des Urnengangs#;
            s#place. Please note that for secret ballots the md5sum on#veröffentlicht. Bitte beachten Sie, dass für geheime Abstimmungen#;
            s#the dummy tally sheet is randomly generated, as otherwise#die MD5-Prüfsumme in der Pseudo-Strichliste zufällig generiert wird, da andernfalls#;
            s#the dummy tally sheet would leak information relating the#die Pseudostrichliste Informationen über den MD5-Hash und den#;
            s#md5 hash and the voter.#Wähler durchsickern lassen könnte.#;
	    s#All the amendments need simple majority#Alle Änderungsanträge benötigen die einfache Mehrheit.#;
	    s#The outcome#Das Ergebnis#;
	    s#The actual text of the resolution is as follows.  Please note#Der eigentliche Text des Beschlusses lautet wie folgt. Bitte beachten#;
	    s#The actual text of the resolution is as follows. Please note#Der eigentliche Text des Beschlusses lautet wie folgt. Bitte beachten#;
            s#that this does not include preludes, prologues, any preambles to#Sie, dass dieser keinen Vorspann, Nachspann, Präamblen des Beschlusses,#;
	    s#the resolution, post-ambles to the resolution, abstracts,#Postamblen des Beschlusses, Zusammenfassungen, Vorworte, Nachworte,#;
	    s#fore-words, after-words, rationales, supporting documents,#Begründungen, Unterstützende Dokumente, Meinungsumfragen, Argumente für#;
	    s#opinion polls, arguments for and against, and any of the other#und gegen, oder irgendwelches andere wichtige Material, das Sie in den#;
	    s#important material you will find on the mailing list#Mailinglisten-Archiven finden, beinhaltet. Bitte lesen Sie die#;
	    s#archives. Please read the mailing list archives for#Mailinglistenarchive#;
	    s#archives. Please read the debian-vote mailing list archives for#debian-vote-Mailinglistenarchive#;
	    s#details.#für Details.#;
	    s#that this does not include supporting or opposing arguments#Sie, dass dies nicht die unterstützenden oder ablehnenden Argumente#;
	    s#or rationales.  These may be found on the debian-vote mailing#oder Begründungen enthält. Diese können in den Archiven der#;
	    s#list archives\.#debian-vote-Mailingliste gefunden werden.#;
	    s#Nomination period:#Nominierungsperiode#;
	    s#Campaigning period:#Wahlkampfperiode:#;
	    s#Voting period:#Abstimmungsperiode:#;
	    s#Please note that the new term for the project leader shall start#Bitte beachten Sie, dass die neue Amtszeit für den#;
	    s#on April 17<sup>th</sup>, (.*)\.#Projektleiter am 17. April $1 beginnt.#;
	    s#The ballot, when ready, can be requested through email#Wenn es soweit ist, kann der Stimmzettel#;
	    s#by emailing#per E-Mail an#;
	    s#with the subject (.*)\.# mit dem Betreff <q>$1</q> angefordert werden.#;
	    s#All candidates would need a simple majority to be eligible.#Alle Kandidaten benötigten eine einfache Mehrheit, um wählbar zu sein.#;
	    s#The proposal needs simple majority.#Der Vorschlag benötigt eine einfache Mehrheit#;
	    s#Since this proposal and amendment would require modification of#Da dieser Vorschlag und Änderung die Anpassung eines Gründungsdokuments#;
	    s#a foundation document, namely, the#verlangen würde, genauer gesagt der <a#;
	    s#<a href="http://www.debian.org/devel/constitution">constitution</a>#href="http://www.debian.org/devel/constitution">Verfassung</a>,#;
	    s#it requires a 3:1 majority to pass.#benötigt er eine 3:1-Mehrheit, um angenommen zu werden.#;
	    s#Not determinted yet#Noch nicht bestimmt#;
	    s#Debian Project Secretary#Debian-Projekt-Schriftführer#;

	    #Generic
	    s#January#Januar#;
	    s#February#Februar#;
	    s#March#März#;
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
	    s#<sup>nd</sup>#.#;
	    s#<sup>th</sup>#.#;
	    s#Choice#Wahl#;
	}
	if ($vf eq "vote_".$number."_quorum.src")
	{
	    s#Option(.*) Reached quorum#Option $1 erreichte Quorum#;
	}
	if ($vf eq "vote_".$number."_quorum.txt")
	{
	    s#Current Developer Count#Aktuelle Entwickler-Anzahl#;
	}
	if ($vf eq "vote_".$number."_results.src")
	{
	    s#To be decided.#Muss noch entschieden werden.#;
	}
	if ($vf eq "vote_".$number."_majority.src")
	{
	    s#Option(.*) passes Majority#Option $1 erreicht Mehrheit#;
	    s#Dropping Option(.*) because of Majority#Verwerfe Option $1 aufgrund von Mehrheit#;
	    s#Majority#Mehrheit#;
	}
	if ($vf eq "vote_".$number."_index.src")
	{
	    s#To be decided.#Muss noch entschieden werden.#;

	    s#Ballots Received#Empfangene Stimmzettel#;
            s#MIME Decoded#MIME entschlüsselt#;
            s#Passed Sig Check#Unterschrift überprüft#;
	    s#Passed LDAP Check#LDAP überprüft#;
	    s#Votes Tallied#Gezählte Stimmen#;
	    s#Acks Created#Erstellte Bestätigungen#;
            s#Acks Sent#Gesendete Bestätigungen#;
	    s#Acks Unsent#Nicht gesendete Bestätigungen#;
	    s#Rejects Sent#Ablehnungen verschickt#;
	    s#Bad Ballot#Ungültige Stimmzettel#;
	    s#Unique Voters#Eindeutige Wähler#;
            s#Graph of the#Grafik#;
	    s#rate at which the votes are received# der Rate, in der die Stimmen empfangen wurden#;
            s#Click on the image above to get a Zoomed in version.<br> A#Klicken Sie auf das obige Bild, um eine vergrößerte Version zu\nbekommen.<br />#;
            s#Click on the image above to get a Zoomed in version.<br /> A#Klicken Sie auf das obige Bild, um eine vergrößerte Version zu\nbekommen.<br />#;
	    s#<a href="(.*)">tally sheet</a> is#Das <a href="$1">Zählblatt</a> ist verfügbar.#;
	    s#available.  While the voting is still open the tally is a#Während die Wahlphase noch läuft, ist das#;
            s#dummy one; after the vote, the final tally sheet shall be#Zählblatt mit Pseudowerten gefüllt; nach der Abstimmung#;
            s#put in place. Please note that for secret ballots the#wird stattdessen das endgültige Zählblatt veröffentlicht.#;
            s#md5sum on the dummy tally sheet is randomly generated, as#Bitte beachten Sie, dass die MD5-Summen im vorläufigen\nZählblatt für geheime Wahlen zufällig erzeugt werden.#;
	    s#otherwise the dummy tally sheet would leak information#Andernfalls würden Informationen über die MD5-Summe und#;
            s#relating the md5 hash and the voter.  Additionally, the#den zugehörigen Wähler durchsickern können. Außerdem werden#;
	    s#<a href="(.*)">results</a> shall be#die <a href="$1">Ergebnisse</a>#;
	    s#updated after the polls close.#aktualisiert, sobald die Wahlphase abgeschlossen ist.#;
	    s#standings of the candidates#des Standes der Kandidaten#;

	}
	if ($vf eq "suppl_".$number."_stats_detailed.wml")
	{
	    s#Graph of the#Grafik der Rate,#;
	    s#rate at which the votes were received#in der die Stimmen empfangen wurden#;
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

