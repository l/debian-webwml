# Here is the syntax:
#  The data is in a hash table returned by init_translators().
#  Each key is the name of a translator (trimmed, without email adress)
# Here is the syntax:
#  The data is in a hash table returned by init_translators().
#  Each key is the name of a translator (trimmed, without email adress)
#  For each one, you have a (sub)hash table containing:
#  * email:    the current email of this guy
#  * compress: which type of compression you want to have (NOT YET IMPLEMENTED)
#  Remaining keys have numeric value, which tells when to send info:
#  * summary:  a summary of which documents are outdated
#  * logs:     the cvs log' between the translated and current versions
#  * diff:     idem with diff
#  * file:     add current version of translated file

sub init_translators {
    my $translators = { 
	'Antonio Terceiro' => {
	    email     => 'asaterceiro@inf.ufrgs.br',
            summary   => 3,
	    logs      => 3,
	    diff      => 0,
	    tdiff     => 0,
	    compress  => 'none'
	},
	'Carlos Laviola' => {
	    email     => 'claviola@debian.org',
	    summary   => 3,
	    logs      => 3,
	    diff      => 0,
	    tdiff     => 0,
	    file      => 0,
	    compress  => 'none'
	    },
	'Eduardo Macan' => {
	    email     => 'macan@debian.org',
	    summary   => 3,
	    logs      => 3,
	    diff      => 0,
	    tdiff     => 0,
	    file      => 0,
	    compress  => 'none'
	    },	
	'Felipe Augusto van de Wiel (faw)' => {
            email     => 'faw@debian.org',
            summary   => 3,
            logs      => 3,
            diff      => 3,
            tdiff     => 0,
            file      => 0,
            compress  => 'none'
	    },
	'Gustavo Noronha' => {
	    email     => 'kov@debian.org',
	    summary   => 3,
	    logs      => 3,
	    diff      => 0,
	    tdiff     => 0,
	    file      => 0,
	    compress  => 'none'
	    },
	'Gustavo Rezende Montesino' => {
	    email     => 'grmontesino@ig.com.br',
	    summary   => 2,
	    logs      => 2,
	    diff      => 0,
	    tdiff     => 0,
	    compress  => 'none'
	    },
        'Marcio Roberto Teixeira' => {
           email     => 'marciotex@pop.com.br',
           summary   => 2,
           logs      => 2,
           diff      => 0,
           tdiff     => 0,
           compress  => 'none'
           },
	'Philipe Gaspar' => {
	    email     => 'philipegaspar@terra.com.br',
	    summary   => 3,
	    logs      => 3,
	    diff      => 0,
	    tdiff     => 0,
	    file      => 0,
	    compress  => 'none'
	    },
	'Marcelo Santana' => {
	    email     => 'marcgsantana@yahoo.com.br',
	    summary   => 3,
	    logs      => 3,
	    diff      => 0,
	    tdiff     => 0,
	    file      => 0,
	    compress  => 'none'
	    },

	# Below are special users, used to handle special cases
	#     default:      default values
	#     untranslated: pages not translated
	#     unmaintained: pages without maintainer
	#     maxdelta:     outdated pages

	untranslated        => {
	    email       => '',
	    mailsubject => '',
	    mailbody    => '',
	},
	unmaintained        => {
	    email       => 'debian-l10n-portuguese@lists.debian.org',
	    summary     => 2,
	    mailsubject => '[webwml] Páginas desatualizadas sem mantenedor',
	    mailbody    => 'portuguese/international/portuguese/mail_unmaintained.txt',
	},
	maxdelta            => {
	    email       => 'debian-l10n-portuguese@lists.debian.org',
	    summary     => 2,
	    maxdelta    => 5,
	    mailsubject => '[webwml: Importante] Páginas desatualizadas',
	    mailbody    => 'portuguese/international/portuguese/mail_obsolete.txt',
	},
	# this is a special name containing the default values
	# Translate frequency values, mailsubject and mailbody files
	default   => {
	    email       => '',
	    missing     => 0,
	    summary     => 0,
	    logs        => 0,
	    diff        => 0,
	    tdiff       => 0,
	    file        => 0,
	    frequency   => ['nunca', 'mensalmente', 'semanalmente', 'diariamente'],
	    mailsubject => '[wml] Páginas desatualizadas',
	    mailbody    => 'portuguese/international/portuguese/mail_user.txt',
	    compress    => 'none'
	},
    };
    return $translators;
}

1;
