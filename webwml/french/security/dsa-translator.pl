#!env perl -w

# This script translate common parts of DSA

# Written by Jean-Edouard Babin


use Getopt::Std;
#use utf8;
#binmode(STDOUT, ":utf8");	

# You may put your name here to add it automatically in the translation header
my $maintainer = ""; 

my $output= "";
getopts('l:f:');
die "Usage: $0 -f <file> -l <LANG> > <translated_file>" if (!defined($opt_f) or !defined($opt_l));


$translation = {
		'interpretation conflict'	=> {
			'FR' => 'conflit d\'interprétation'
		},
		'incorrect API usage'	=> {
			'FR' => 'Mauvaise utilisation de l\'interface de programmation'
		},
		'integer overflow'	=> {
			'FR' => 'Débordement d\'entier'
		},
		'insecure temp file generation' => {
			'FR' => 'Fichiers temporaires peu sûrs'
		},
		'insufficient input sanitising' => {
			'FR' => 'Vérification d\'entrée manquante'
		},
		'missing input validation' => {
			'FR' => 'Validations des entrées insuffisantes'
		},
		'several vulnerabilities' => {
			'FR' => 'Plusieurs vulnérabilités'
		},
		'buffer overflow' => {
			'FR' => 'Débordement de mémoire tampon'
		},
		'buffer overflows' => {
			'FR' => 'Débordements de mémoire tampons'
		},
		'programming error' => {
			'FR' => 'Erreur de programmation'
		},
		'heap overflow' => {
			'FR' => 'Débordement de zone de mémoire du système'
		},
		'authorization bypass' => {
			'FR' => 'Contournement d\'autorisation'
		},
		'insufficient input validation' => {
			'FR' => 'Validations des entrées insuffisantes'
		},
		'cross-site scripting' => {
			'FR' => 'Script intersite'
		},
		'design flaw' => {
			'FR' => 'Défaut de conception'
		},
		'design flaws' => {
			'FR' => 'Défauts de conception'
		},
		'denial of service' => {
			'FR' => 'Déni de service'
		},
		'denial of service/privilege escalation' => {
			'FR' => 'Déni de service et augmentation de droits'
		},
		'SQL injection' => {
			'FR' => 'Injection SQL'
		},
		'<p>We recommend that you upgrade your <package> package.</p>' => {
			'FR' => '<p>Nous vous recommandons de mettre à jour votre paquet <package>.</p>'
		},
		'<p>We recommend that you upgrade your <package> packages.</p>' => {
			'FR' => '<p>Nous vous recommandons de mettre à jour vos paquets <package>.</p>'
		},
		'<p>For the <distrib_release> distribution (<distrib_name>) this problem has been fixed in version <version>.</p>' => {
			'FR' => '<p>Pour la distribution <distrib_release> (<distrib_name>), ce problème a été corrigé dans lav ersion <version>.</p>'
		},
		'<p>For the <distrib_release> distribution (<distrib_name>), these problems have been fixed in version <version>.</p>' => {
			'FR' => '<p>Pour la distribution <distrib_release> (<distrib_name>), ces problèmes ont été corrigés dans la version <version>.</p>'
		},
		'etch' => {
			'FR' => 'Etch'
		},
		'sid' => {
			'FR' => 'Sid'
		},
		'lenny' => {
			'FR' => 'Lenny'
		}
};


open(FILE, $opt_f) or die "Can't open file $opt_f : $!";

$output = "#use wml::debian::translation-check translation=\"\" maintainer=\"$maintainer\"\n";
print STDERR "---------------------------------------------------\n";
print STDERR "Don't forget to complete translation-check header !\n";
print STDERR "---------------------------------------------------\n";

while(<FILE>) {
	if (m|^<define-tag description>(.+?)</define-tag>$|) {
		$desc = $1;
		if (defined($translation->{$desc}{$opt_l})) {
			$line = $_;
			$line =~ s/$desc/$translation->{$desc}{$opt_l}/;
			$output .= $line;
		} else {
			print STDERR "I was not able to find a translation for this line !\n";
			print STDERR "$_\n";
			$output .= $_;
		}
	}
	elsif (m|^<p>We recommend that you upgrade your (.+?) package\.</p>$|) {
		$package_name = $1;
		if (defined($translation->{'<p>We recommend that you upgrade your <package> package.</p>'}{$opt_l})) {
			$line = $translation->{'<p>We recommend that you upgrade your <package> package.</p>'}{$opt_l};
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
		if (defined($translation->{'<p>We recommend that you upgrade your <package> packages.</p>'}{$opt_l})) {
			$line = $translation->{'<p>We recommend that you upgrade your <package> packages.</p>'}{$opt_l};
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

if ($opt_l eq "FR") {
	# Translation of fixed version messages
	#$output =~ s|<p>For.the.\S+.distribution.\S+.this.problem.has.been.fixed.in.version.\S+\.</p>|$translation->{'<p>For the <distrib_release> distribution (<distrib_name>) this problem has been fixed in version <version>.</p>'}{$opt_l}|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).distribution.\((\S+)\),{0,1}.this.problem.has.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2), ce problème a été corrigé dans la version $3.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).distribution.\((\S+)\),{0,1}.these.problems.have.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).\((\S+)\).distribution,{0,1}.this.problem.has.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2), ce problème a été corrigé dans la version $3.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).\((\S+)\).distribution,{0,1}.these.problems.have.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2), ces problèmes ont été corrigés dans la version $3.</p>|gs;

	$output =~ s|<p>[\n]{0,1}For.the.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),{0,1}.this.problem.has.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),{0,1}.these.problems.have.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\) distributions,{0,1}.this.problem.has.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.(\S+).\((\S+)\).and.(\S+).\((\S+)\) distributions,{0,1}.these.problems.have.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.upcoming.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),{0,1}.this.problem.has.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 à venir ($2) et la distribution $3 ($4), ce problème a été corrigé dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For.the.upcoming.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),{0,1}.these.problems.have.been.fixed.in.version.(\S+)\.[\n]{0,1}</p>|<p>Pour la distribution $1 à venir ($2) et la distribution $3 ($4), ces problèmes ont été corrigés dans la version $5.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For the.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),{0,1}, this problem will.be.fixed.soon\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ce problème sera corrigé prochainement.</p>|gs;
	$output =~ s|<p>[\n]{0,1}For the.(\S+).distribution.\((\S+)\).and.the.(\S+).distribution.\((\S+)\),{0,1}, these problems will.be.fixed.soon\.[\n]{0,1}</p>|<p>Pour la distribution $1 ($2) et la distribution $3 ($4), ces problèmes seront corrigés prochainement.</p>|gs;
	$output =~ s|<p>[\n]{0,1}The.(\S+).distribution.\((\S+)\).will.be.fixed.soon\.[\n]{0,1}</p>|<p>La distribution $1 ($2) sera corrigé prochainement.</p>|gs;

	# Case adjustment
	$output =~ s|\(etch\)|\(Etch\)|g;
	$output =~ s|\(sid\)|\(Sid\)|g;
	$output =~ s|\(lenny\)|\(Lenny\)|g;

	# Short recurrent part of text. Take care ! substitution order might be important
	$output =~ s|Several.vulnerabilities.have.been.discovered in|Plusieurs vulnérabilités ont été découvertes dans|gs;
	$output =~ s|A buffer.overflow has been discovered in|Un débordement de tampon a été découvert dans|gs; 
	$output =~ s|The.Common.Vulnerabilities.and.Exposures.project.identifies.the.following.problems:|Le projet « Common Vulnerabilities and Exposures » (CVE) identifie les problèmes suivants :|s;
	$output =~ s|,.which.may.lead.to.the.execution.of.arbitrary.code\.|. Cela peut mener à l'exécution de code arbitraire.|gs;
	$output =~ s|,.which.may.result.in.the.execution.of.arbitrary.code\.|. Cela peut avoir pour conséquence l'exécution de code arbitraire.|gs;
	$output =~ s|,.which.might.allow.the.execution.of.arbitrary.code\.|. Cela peut permettre l'exécution de code arbitraire.|gs;
#	$output =~ s|||gs;
#	$output =~ s|||gs;
 
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
	$output =~ s|wml::debian::translation-check translation=""|wml::debian::translation-check translation="$vers"|;
}

print $output;
