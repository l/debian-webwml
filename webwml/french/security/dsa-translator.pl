#!/usr/bin/perl -w

# This script translate common part of DSA

# Written by Jean-Edouard Babin, radius in gmail.com

# Todo
# - Make a regexp that is enough generic to catch lines like that to be able to use $translation for theses lines instead of s//// '<p>For the <distrib_release> distribution (<distrib_name>) this problem has been fixed in version <version>.</p>' => 
# - Split translation of "For the ... distribution" and "this problem" in 2 part ?? Not yet sure that it's a good idea even if it would reduce number of s///
# - Take DSA from URL (http://cvs.debian.org/*checkout*/webwml/english/security/<YEAR>/dsa-<ID>.wml)
#   or from local copy. use -Y for year and -n for dsa numner, assume -Y as current year if not provided.
#   Check for ../../english/security/<YEAR>/dsa-<ID>.wml if not found, download it
# - Save translated DSA instead of print to STDOUT. As to be saved in <YEAR>/dsa-<ID>.wml

# History
# Revision 1.1 16/02/2009 03:23
# - Handle DWWW_LANG and DWWW_MAINT
# - Add squeeze "translation"
# - Changed $translation->{String}{LANG} to $translation->{LANG}{String}
#   so LANG alias can be done easily (I mean alias like FR for french)
# - Catch more "For the ... distribution ..." type

use Getopt::Std;
#use utf8;
#binmode(STDOUT, ":utf8");	

# Export your name in DWWW_MAINT or put it here explicitly
my $maintainer = $ENV{DWWW_MAINT} || "";

my $output= "";
$opt_l = $ENV{DWWW_LANG} if (exists $ENV{DWWW_LANG});
getopts('l:f:');
die "Usage: $0 -f <file> -l <LANG> > <translted_file>" if (!defined($opt_f) or !defined($opt_l));


$translation = {
	'french'	=> {
		'interpretation conflict'		=>	'conflit d\'interprétation',
		'incorrect API usage'			=>	'Mauvaise utilisation de l\'interface de programmation',
		'integer overflow'				=>	'Débordement d\'entier',
		'insecure temp file generation'	=>	'Fichiers temporaires peu sûrs',
		'insufficient input sanitising' =>	'Vérification d\'entrée manquante',
		'missing input validation'		=>	'Validations des entrées insuffisantes',
		'missing input sanitising'	=>		'Absence de vérification des entrées',
		'missing input sanitization'    =>              'Absence de vérification des entrées',
		'NULL pointer dereference'	=>		'Déréférencement de pointeur NULL',
		'several vulnerabilities'		=>	'Plusieurs vulnérabilités',
		'buffer overflow'				=>	'Débordement de mémoire tampon',
		'buffer overflows'				=>	'Débordements de mémoire tampons',
		'programming error'				=>	'Erreur de programmation',
		'heap overflow'					=>	'Débordement de zone de mémoire du système',
		'authorization bypass'			=>	'Contournement d\'autorisation',
		'insufficient input validation'	=>	'Validations des entrées insuffisantes',
		'cross-site scripting'			=>	'Script intersite',
		'design flaw'					=>	'Défaut de conception',
		'design flaws'					=>	'Défauts de conception',
		'denial of service'				=>	'Déni de service',
		'SQL injection'					=>	'Injection SQL',
		'denial of service/privilege escalation'	=>	'Déni de service et augmentation de droits',
		'<p>We recommend that you upgrade your <package> package.</p>'	=>	'<p>Nous vous recommandons de mettre à jour votre paquet <package>.</p>',
		'<p>We recommend that you upgrade your <package> packages.</p>'	=>	'<p>Nous vous recommandons de mettre à jour vos paquets <package>.</p>',
	},
};

# Lang Alias
$translation->{'FR'} = $translation->{'french'};

open(FILE, $opt_f) or die "Can't open file $opt_f : $!";

$output = "#use wml::debian::translation-check translation=\"1.1\" maintainer=\"$maintainer\"\n";
print STDERR "---------------------------------------------------\n" if ($maintainer eq "");
print STDERR "Don't forget to complete translation-check header !\n" if ($maintainer eq "");
print STDERR "---------------------------------------------------\n" if ($maintainer eq "");

while(<FILE>) {
	if (m|^<define-tag description>(.+?)</define-tag>$|) {
		$desc = $1;
		if (defined($translation->{$opt_l}{$desc})) {
			$line = $_;
			$line =~ s/$desc/$translation->{$opt_l}{$desc}/;
			$output .= $line;
		} else {
			print STDERR "I was not able to find a translation for this line !\n";
			print STDERR "$_\n";
			$output .= $_;
		}
	}
	elsif (m|^<p>We recommend that you upgrade your (.+?) package\.</p>$|) {
		$package_name = $1;
		if (defined($translation->{$opt_l}{'<p>We recommend that you upgrade your <package> package.</p>'})) {
			$line = $translation->{$opt_l}{'<p>We recommend that you upgrade your <package> package.</p>'};
			$line =~ s/<package>/$package_name/;
			$output .= "$line\n";
		} else {
			print STDERR "I was not able to find a translation for this line !\n";
			print STDERR "$_\n";
			$output .= $_;
		}
	}
	elsif (m|^<p>We recommend that you upgrade your (.+?) packages\.</p>$|) {
		$package_name = $1;
		if (defined($translation->{$opt_l}{'<p>We recommend that you upgrade your <package> packages.</p>'})) {
			$line = $translation->{$opt_l}{'<p>We recommend that you upgrade your <package> packages.</p>'};
			$line =~ s/<package>/$package_name/;
			$output .= "$line\n";
		} else {
			print STDERR "I was not able to find a translation for this line !\n";
			print STDERR "$_\n";
			$output .= $_;
		}
	}
	else {
		$output .= $_;
	}
}
close(FILE);

if (($opt_l eq "french") || ($opt_l eq "FR")) {
	# Translation of fixed version messages
	#$output =~ s|<p>For.the.\S+.distribution.\S+.this.problem.has.been.fixed.in.version.\S+\.</p>|$translation->{$opt_l}{'<p>For the <distrib_release> distribution (<distrib_name>) this problem has been fixed in version <version>.</p>'}|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\),?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ce problème a été corrigé dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).distribution,?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ce problème a été corrigé dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).distribution,?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.|gs;

	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\) distributions?,?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?</p>|<p>Pour les distributions $1 ($2) et $3 ($4), ce problème a été corrigé dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\) distributions?,?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?</p>|<p>Pour les distributions $1 ($2) et $3 ($4), ces problèmes ont été corrigés dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]?For.the.upcoming.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?</p>|<p>Pour la distribution $1 à venir ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]?For.the.upcoming.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?</p>|<p>Pour la distribution $1 à venir ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),?.this.problem.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),?.these.problems.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\).distributions?,?.these.problems.will.be.fixed.soon\.[\n]?</p>|<p>Pour les distributions $1 ($2) et $3 ($4), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\).distributions?,?.this.problem.?[\n]?will.be.fixed.soon\.[\n]?</p>|<p>Pour les distributions $1 ($2) et $3 ($4), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For the.(\S+).distribution.\((\S+)\),?.this problem.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For the.(\S+).distribution.\((\S+)\),?.these problems.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).will.be.fixed.soon\.[\n]?</p>|<p>La distribution $1 ($2) sera corrigée prochainement.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).is.not.affected.by.this.problem\.[\n]?</p>|<p>La distribution $1 ($2) n'est pas concernée par ce problème.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).is.not.affected.by.these.problems\.[\n]?</p>|<p>La distribution $1 ($2) n'est pas concernée par ces problèmes.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).is.not.affected\.[\n]?</p>|<p>La distribution $1 ($2) n'est pas concernée.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\).and.t?h?e?.??(\S+).distributions?.\((\S+)\).are.not.affected.by.this.problem\.[\n]?</p>|<p>La distribution $1 ($2) et la distribution $3 ($4) ne sont pas concernées par ce problème.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\).and.t?h?e?.??(\S+).distributions?.\((\S+)\).are.not.affected.by.these.problems\.[\n]?</p>|<p>La distribution $1 ($2) et la distribution $3 ($4) ne sont pas concernées par ces problèmes.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).does.not.contain.a.(\S+).package\.[\n]?</p>|<p>La distribution $1 ($2) ne contient pas de paquet $3.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\).and.t?h?e?.??(\S+).distributions?.\((\S+)\).do.not.contain.any.(\S+).packages\.[\n]?</p>|<p>La distribution $1 ($2) et la distribution $3 ($4) ne contiennent pas de paquet $5.</p>|gs;

	# Case adjustment
	$output =~ s|\(etch\)|\(Etch\)|g;
	$output =~ s|\(sid\)|\(Sid\)|g;
	$output =~ s|\(lenny\)|\(Lenny\)|g;
	$output =~ s|\(squeeze\)|\(Squeeze\)|g;
	$output =~ s|\(wheezy\)|\(Wheezy\)|g;

	# Short recurrent part of text. Take care ! substitution order might be important
	$output =~ s|Several.vulnerabilities.(have.been\|were).discovered in|Plusieurs vulnérabilités ont été découvertes dans|gs;
	$output =~ s|A buffer.overflow has been discovered in|Un débordement de tampon a été découvert dans|gs; 
	$output =~ s|The.Common.Vulnerabilities.and.Exposures.project.identifies.the.following.problems:|Le projet « Common Vulnerabilities and Exposures » (CVE) identifie les problèmes suivants :|s;
	$output =~ s|,.which.may.lead.to.the.execution.of.arbitrary.code|. Cela peut permettre l'exécution de code arbitraire|gs;
	$output =~ s|,.which.could.lead.to.the.execution.of.arbitrary.code|. Cela pourrait permettre l'exécution de code arbitraire|gs;
	$output =~ s|,.which.may.result.in.the.execution.of.arbitrary.code|. Cela peut avoir pour conséquence l'exécution de code arbitraire|gs;
	$output =~ s|,.which.might.allow.the.execution.of.arbitrary.code|. Cela peut permettre l'exécution de code arbitraire|gs;
	$output =~ s|remote.attackers|des attaquants distants|gs;
	$output =~ s|denial.of.service|déni de service|gs;
	$output =~ s|the.execution.of.arbitrary.code|l'exécution de code arbitraire|gs;
	$output =~ s|execute.arbitrary.code|exécuter du code arbitraire|gs;
 
	$output =~ s|the (\S+) parser|l'analyseur $1|gs;

	# This need some check to be done in translated file
	$output =~ s|have been discovered|ont été découvert(e)s|gs;
	$output =~ s|have been found|ont été découvert(e)s|gs;
	$output =~ s|has been discovered|a été découvert(e)|gs;
	$output =~ s|has been found|a été découvert(e)|gs;
	$output =~ s|was discovered|a été découvert(e)|gs;

}

# Update translation header
if ($output =~ m|\$Id: dsa-\d+.wml,v (\S+) |s) {
	my $vers = $1;
	$output =~ s|wml::debian::translation-check translation="1.1"|wml::debian::translation-check translation="$vers"|;
}

print $output;
