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
		'integer underflow'                             =>      'Débordement d\'entier par le bas',
		'insecure temp file generation'	=>	'Fichiers temporaires peu sûrs',
		'insufficient input sanitising' =>	'Vérification d\'entrée manquante',
		'insufficient input sanitization' =>	'Vérification d\'entrée manquante',
		'missing input validation'		=>	'Validations des entrées insuffisantes',
		'missing input sanitising'	=>		'Absence de vérification des entrées',
		'missing input sanitizing'      =>              'Absence de vérification des entrées',
		'missing input sanitization'    =>              'Absence de vérification des entrées',
		'NULL pointer dereference'	=>		'Déréférencement de pointeur NULL',
		'several vulnerabilities'		=>	'Plusieurs vulnérabilités',
		'buffer overflow'				=>	'Débordement de mémoire tampon',
		'buffer overflows'				=>	'Débordements de mémoire tampon',
		'programming error'				=>	'Erreur de programmation',
		'heap overflow'					=>	'Débordement de zone de mémoire du système',
		'authorization bypass'			=>	'Contournement d\'autorisation',
		'insufficient input validation'	=>	'Validations des entrées insuffisantes',
		'insufficient checks'			=>	'Vérifications insuffisantes',
		'cross-site scripting'			=>	'Script intersite',
		'Cross-Site Request Forgery'		=>	'Contrefaçon de requête intersite',
		'design flaw'					=>	'Défaut de conception',
		'design flaws'					=>	'Défauts de conception',
		'denial of service'				=>	'Déni de service',
		'directory traversal'				=>	'Traversée de répertoires',
		'path traversal'				=>      'Traversée de répertoires',
		'double free'					=>	'Double libération de zone de mémoire',
		'format string'					=>	'Chaîne de formatage',
		'use-after-free'				=>	'Utilisation de mémoire après libération',
		'privilege escalation'				=>	'Augmentation de droits',
		'SQL injection'					=>	'Injection SQL',
		'sql injection'                                 =>      'Injection SQL',
		'ssl certificate blacklist update'		=>	'Mise à jour de la liste noire des certificats',
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
	# Remove useless started whitespaces
	$output =~ s|    ||g;
	# Translation of fixed version messages
	#$output =~ s|<p>For.the.\S+.distribution.\S+.this.problem.has.been.fixed.in.version.\S+\.</p>|$translation->{$opt_l}{'<p>For the <distrib_release> distribution (<distrib_name>) this problem has been fixed in version <version>.</p>'}|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\),?.th(is\|e).problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ce problème a été corrigé dans la version $4.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).distribution,?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ce problème a été corrigé dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).distribution,?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution,?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1, ce problème a été corrigé dans la version $2.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution,?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour la distribution $1, ces problèmes ont été corrigés dans la version $2.|gs;
	$output =~ s|<p>[\n]?For.the.old.(\S+).distribution.\((\S+)\),?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour l'ancienne distribution $1 ($2), ce problème a été corrigé dans la version $3.|gs;
	$output =~ s|<p>[\n]?For.the.old.(\S+).distribution.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.|<p>Pour l'ancienne distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.|gs;

	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.th(is\|e).problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $6.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).\((\S+)\).distributions?,?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).\((\S+)\).distributions?,?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\) distributions?,?.this.problem.has.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?|<p>Pour les distributions $1 ($2) et $3 ($4), ce problème a été corrigé dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\) distributions?,?.these.problems.have.a?l?s?o?.?been.fixed.in.version.(\S+)\.[\n]?|<p>Pour les distributions $1 ($2) et $3 ($4), ces problèmes ont été corrigés dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.upcoming.(\S+).distribution.\((\S+)\).and.the.(\S+)..??distribution.\((\S+)\),?.this.problem.has.a?l?s?o?.?been.fixed.in.version..??(\S+)\.[\n]?|<p>Pour la distribution $1 à venir ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.upcoming.(\S+).distribution.\((\S+)\).and.the.(\S+)..??distribution.\((\S+)\),?.these.problems.have.a?l?s?o?.?been.fixed.in.version..??(\S+)\.[\n]?|<p>Pour la distribution $1 à venir ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.|gs;
	$output =~ s|of.the.(\S+).package\.|du paquet $1.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.these.problems.will.be.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes seront corrigés dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.this.problem.will.be.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème sera corrigé dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).\((\S+)\).distributions?,?.these.problems.will.be.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes seront corrigés dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\),?.and.t?h?e?.??(\S+).distributions?.\((\S+)\),?.this.problem.will.be.fixed.in.version.(\S+)\.[\n]?|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème sera corrigé dans la version $5.|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\),?.and.t?h?e?.??(\S+).distribution.\((\S+)\),?.this.problem.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).distribution.\((\S+)\).and.t?h?e?.??(\S+).distribution.\((\S+)\),?.these.problems.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\).distributions?,?.these.problems.will.be.fixed.soon\.[\n]?</p>|<p>Pour les distributions $1 ($2) et $3 ($4), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\).distributions?,?.this.problem.?[\n]?will.be.fixed.soon\.[\n]?</p>|<p>Pour les distributions $1 ($2) et $3 ($4), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For the.(\S+).distribution.\((\S+)\),?.this problem.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]?For the.(\S+).distribution.\((\S+)\),?.these problems.will.be.fixed.soon\.[\n]?</p>|<p>Pour la distribution $1 ($2), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).will.be.fixed.soon\.[\n]?</p>|<p>La distribution $1 ($2) sera corrigée prochainement.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).is.not.affected.by.this.problem|<p>La distribution $1 ($2) n'est pas concernée par ce problème|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).is.not.affected.by.these.problems|<p>La distribution $1 ($2) n'est pas concernée par ces problèmes|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).is.not.affected|<p>La distribution $1 ($2) n'est pas concernée|gs;
	$output =~ s|<p>[\n]?The.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\).and.t?h?e?.??(\S+).distributions?.\((\S+)\).are.not.affected.by.this.problem\.[\n]?</p>|<p>La distribution $1 ($2) et la distribution $3 ($4) ne sont pas concernées par ce problème.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\).and.t?h?e?.??(\S+).distributions?.\((\S+)\).are.not.affected.by.these.problems\.[\n]?</p>|<p>La distribution $1 ($2) et la distribution $3 ($4) ne sont pas concernées par ces problèmes.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).does.?n.t.contain.a.(\S+).package\.|<p>La distribution $1 ($2) ne contient pas de paquet $3.|gs;
	$output =~ s|<p>[\n]?The.(\S+).d?i?s?t?r?i?b?u?t?i?o?n?.?\((\S+)\).and.t?h?e?.??(\S+).distributions?.\((\S+)\).do.?n.t.contain.any.(\S+).packages\.[\n]?</p>|<p>La distribution $1 ($2) et la distribution $3 ($4) ne contiennent pas de paquet $5.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).does.?n.t.contain.(\S+).packages\.[\n]?</p>|<p>La distribution $1 ($2) ne contient pas de paquets $3.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).does.?n.t.contain.(\S+)\.[\n]?</p>|<p>La distribution $1 ($2) ne contient pas $3.</p>|gs;
	$output =~ s|The.(\S+).package.is.not.affected.by.this.issue\.|Le paquet $1 n'est pas concerné par ce problème.|gs;
	$output =~ s|<p>[\n]?We.recommend.that.you.upgrade.your.(\S+).packages\.|<p>Nous vous recommandons de mettre à jour vos paquets $1.|gs;
	$output =~ s|<p>[\n]?We.recommend.that.you.upgrade.your.(\S+,?.??\S+?),?.and.(\S+).packages\.[\n]?</p>|<p>Nous vous recommandons de mettre à jour vos paquets $1 et $2.</p>|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).no.longer.contains.(\S+)\.|<p>La distribution $1 ($2) ne contient plus $3.|gs;
	$output =~ s|<p>[\n]?The.(\S+).distribution.\((\S+)\).doesn't.include.(\S+)\.|<p>La distribution $1 ($2) ne contient pas $3.|gs;
	$output =~ s|<p>[\n]?The.following.matrix.lists.additional.source.packages.that.were.rebuilt.for.compatibility.with.or.to.take.advantage.of.this.update:</p>|<p>Le tableau suivant liste les paquets supplémentaires qui ont été reconstruits à des fins de compatibilité ou pour tirer parti de cette mise à jour :</p>|gs;
	$output =~ s|which.was.already.included.in.the.(\S+).release|qui a déjà été incluse dans la publication de $1|gs;
	$output =~ s|as.it.does.not.include|car elle ne contient pas|gs;
	$output =~ s|it.does.not.include|elle ne contient pas|gs;
	$output =~ s|The.packages.for.the.(\S+).architecture.are.not.included.in.this.upgrade|Les paquets pour l'architecture $1 ne sont pas inclus dans cette mise à niveau|gs;
	$output =~ s|They.will.be.released.as.soon.as.they.become.available|Ils seront publiés dès qu'ils seront disponibles|gs;


	# Case adjustment
	$output =~ s|\(etch\)|\(Etch\)|g;
	$output =~ s|\(sid\)|\(Sid\)|g;
	$output =~ s|\(lenny\)|\(Lenny\)|g;
	$output =~ s|\(squeeze\)|\(Squeeze\)|g;
	$output =~ s|\(wheezy\)|\(Wheezy\)|g;

	# Short recurrent part of text. Take care ! substitution order might be important
	$output =~ s|Several.vulnerabilities.(have.been\|were).discovered in|Plusieurs vulnérabilités ont été découvertes dans|gs;
	$output =~ s|It.was.discovered.that|On a découvert que|gs;
	$output =~ s|It.was.discovered|On a découvert|gs;
	$output =~ s|A.buffer.overflow has been discovered in|Un débordement de tampon a été découvert dans|gs; 
	$output =~ s|The.Common.Vulnerabilities.and.Exposures.project.identifies.the.following.problems:|Le projet « Common Vulnerabilities and Exposures » (CVE) identifie les problèmes suivants :|s;
	$output =~ s|,.which.may.lead.to.the.execution.of.arbitrary.code|. Cela peut permettre l'exécution de code arbitraire|gs;
	$output =~ s|,.which.could.lead.to.the.execution.of.arbitrary.code|. Cela pourrait permettre l'exécution de code arbitraire|gs;
	$output =~ s|,.which.may.result.in.the.execution.of.arbitrary.code|. Cela peut avoir pour conséquence l'exécution de code arbitraire|gs;
	$output =~ s|,.which.might.allow.the.execution.of.arbitrary.code|. Cela peut permettre l'exécution de code arbitraire|gs;
	$output =~ s|,.which.allows|. Cela permet|gs;
	$output =~ s|remote.attackers|des attaquants distants|gs;
	$output =~ s|remote.attacker|un attaquant distant|gs;
	$output =~ s|local.attackers|des attaquants locaux|gs;
	$output =~ s|local.attacker|un attaquant local|gs;
	$output =~ s|local.users|des utilisateurs locaux|gs;
	$output =~ s|Local.users|Des utilisateurs locaux|gs;
	$output =~ s|local.user|un utilisateur local|gs;
	$output =~ s|Local.user|Un utilisateur local|gs;
	$output =~ s|a.buffer.overflow|un débordement de mémoire tampon|gs;
	$output =~ s|buffer.overflow|débordement de mémoire tampon|gs;
	$output =~ s|cross.site.request.forgeries|contrefaçons de requête intersite|gs;
	$output =~ s|cross.site.request.forgery|contrefaçon de requête intersite|gs;
	$output =~ s|Cross.Site.Request.Forgery|contrefaçon de requête intersite|gs;
	$output =~ s|cross.site.scripting.attacks|attaques par script intersite|gs;
	$output =~ s|cross.site.scripting.issues|problème de script intersite|gs;
	$output =~ s|cross.site.scripting|script intersite|gs;
	$output =~ s|(denial.of.service\|DoS).attacks|attaques par déni de service|gs;
	$output =~ s|(denial.of.service\|DoS).attack|attaque par déni de service|gs;
	$output =~ s|(denial.of.service\|DoS).issues|problèmes de déni de service|gs;
	$output =~ s|(denial.of.service\|DoS).issue|problème de déni de service|gs;
        $output =~ s|a.(denial.of.service\|DoS)|un déni de service|gs;
	$output =~ s|(denial.of.service\|DoS)|déni de service|gs;
	$output =~ s|(directory\|path).traversal|traversée de répertoires|gs;
	$output =~ s|a.double.free|une double libération de zone de mémoire|gs;
	$output =~ s|double.free|double libération de zone de mémoire|gs;
	$output =~ s|the.execution.of.arbitrary.code|l'exécution de code arbitraire|gs;
	$output =~ s|arbitrary.code.execution|l'exécution de code arbitraire|gs;
	$output =~ s|execution.of.arbitrary.code|exécution de code arbitraire|gs;
	$output =~ s|execute.arbitrary.code|exécuter du code arbitraire|gs;
	$output =~ s|NULL.pointer.dereference|déréférencement de pointeur NULL|gs;
	$output =~ s|application.crash|plantage d'application|gs;
	$output =~ s|insufficient.input.saniti(s\z)(ing\|ation)|vérification d'entrée manquante|gs;
	$output =~ s|missing.input.saniti(s\z)(ing\|ation)|absence de vérification des entrées|gs;
	$output =~ s|missing.input.validation|validations des entrées insuffisantes|gs;
	$output =~ s|the (\S+) parser|l'analyseur $1|gs;

	# This need some check to be done in translated file
	$output =~ s|have.been.(discovered\|found).in|ont été découvertes dans|gs;
	$output =~ s|have.been.(discovered\|found)|ont été découvertes|gs;
	$output =~ s|(has.been\|was).(discovered\|found).in|a été découverte dans|gs;
	$output =~ s|(has.been\|was).(discovered\|found)|a été découverte|gs;
	$output =~ s|have.discovered.in|ont découvert dans|gs;
	$output =~ s|have.discovered|ont découvert|gs;
	$output =~ s|(has.)?discovered.in|a découvert dans|gs;
	$output =~ s|(has.)?discovered|a découvert|gs;
	$output =~ s|reported.an.issue.in.the|a signalé un problème dans le|gs;
        $output =~ s|reported.an.issue.in|a signalé un problème dans|gs;
        $output =~ s|reported.an.issue|a signalé un problème|gs;
        $output =~ s|reported.issues|a signalé des problèmes|gs;
	$output =~ s|reported|a signalé|gs;
	$output =~ s|an.issue.in.the|un problème dans le|gs;
        $output =~ s|an.issue.in|un problème dans|gs;
        $output =~ s|an.issue|un problème|gs;
	$output =~ s|is.already.fixed|est déjà corrigé|gs;

	# usual words, ease copy and paste...
	$output =~ s|attacker|attaquant|gs;
	$output =~ s|attack|attaque|gs;
	$output =~ s|correctly|correctement|gs;
	$output =~ s|specially.crafted|trafiqué pour l'occasion|gs;
	$output =~ s|crafted|trafiqué|gs;
	$output =~ s|can.lead.to|peut conduire à|gs;
	$output =~ s|can.lead|peut conduire|gs;
	$output =~ s|could.lead.to|pourrait conduire à|gs;
	$output =~ s|could.lead|pourrait conduire|gs;
	$output =~ s|could|pourrait|gs;
	$output =~ s|design.flaws|défauts de conception|gs;
	$output =~ s|design.flaw|défaut de conception|gs;
	$output =~ s|frontend|interface|gs;
	$output =~ s|format string|chaîne de formatage|gs;
	$output =~ s|high-level|haut niveau|gs;
	$output =~ s|information.disclosure|divulgation d'informations|gs;
	$output =~ s|information.leak|fuite d'informations|gs;
	$output =~ s|integer.overflow|débordement d'entier|gs;
	$output =~ s|integer.underflow|débordement d'entier par le bas|gs;
	$output =~ s|library|bibliothèque|gs;
	$output =~ s|libraries|bibliothèques|gs;
	$output =~ s|low-level|bas niveau|gs;
	$output =~ s|may.lead.to|pourrait conduire à|gs;
	$output =~ s|may.lead|pourrait conduire|gs;
	$output =~ s|memory.consumption|consommation de mémoire|gs;
	$output =~ s|memory.leak|fuite de mémoire|gs;
	$output =~ s|package|paquet|gs;
	$output =~ s|perform|réaliser|gs;
	$output =~ s|privilege.escalation|augmentation de droits|gs;
	$output =~ s|race.conditions|situations de compétition|gs;
	$output =~ s|race.condition|situation de compétition|gs;
	$output =~ s|remote.vulnerabilities|vulnérabilités distantes|gs;
	$output =~ s|root.privileges|droits du superutilisateur|gs;
	$output =~ s|Several|Plusieurs|gs;
	$output =~ s|This.allows|Cela permet|gs;
	$output =~ s|this.allows|cela permet|gs;
	$output =~ s|to.cause|de provoquer|gs;
	$output =~ s| tools | outils |gs;
	$output =~ s| tool | outil |gs;
	$output =~ s|via.a|à l'aide d'un|gs;
	$output =~ s|vulnerable|vulnérable|gs;
	$output =~ s|vulnerability|vulnérabilité|gs;
	$output =~ s|vulnerabilities|vulnérabilités|gs;

	$output =~ s|that in |que dans |gs;
	$output =~ s| and | et |gs;
	$output =~ s| in order to | afin de |gs;
	$output =~ s| in order | afin |gs;
	$output =~ s| in | dans |gs;
	$output =~ s|if.a.user.is.tricked.into.opening|si un utilisateur est piégé dans l'ouverture|gs;
	$output =~ s|if.a.user.is.tricked.into|si un utilisateur est piégé dans|gs;
	$output =~ s|if.a.user.is.tricked|si un utilisateur est piégé|gs;
	$output =~ s|if.a.user|si un utilisateur|gs;
	$output =~ s|is.tricked.into|est piégé dans|gs;
	$output =~ s| if | si |gs;
	$output =~ s| or | ou |gs;
	$output =~ s| with | avec |gs;

}

# Update translation header
if ($output =~ m|\$Id: dsa-\d+.wml,v (\S+) |s) {
	my $vers = $1;
	$output =~ s|wml::debian::translation-check translation="1.1"|wml::debian::translation-check translation="$vers"|;
}

print $output;
