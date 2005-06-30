#!/usr/bin/perl

# This is GPL'ed, copyright 2000 Martin Quinson <mquinson@ens-lyon.fr>

# In this file, you can find a DB about the translators.
# It should be hand maintained by the coordinator, it is not modified
#  automatically.
# For now, it is only used by check-translation.pl (in a version not
#  commited to the cvs, but I can send it to you, if you want to)

# Here is the syntax:
#  The data is in a hash table returned by init_translators().
#  Each key is the name of a translator (trimmed, without email adress)
#  For each one, you have a (sub)hash table containing:
#  * email:    the current email of this guy
#  * compress: which type of compression you want to have (NOT YET IMPLEMENTED)
#  Remaining keys have numeric value, which tells when to send info:
#  * summary:  a summary of which documents are outdated
#  * logs:     the `cvs log' between the translated and current versions
#  * diff:     idem with diff
#  * tdiff:    try to find the part of the translated text modified by the
#              patch
#  * file:     add current version of translated file

# The possible frenquencies are:
# 0 (never), 1 (monthly), 2 (weekly) or 3 (daily)


sub init_translators {
        my $translators = {
                'Mohammed Adnène Trojette' => {
                       email           => 'adn@via.ecp.fr',
                       summary         => 3,
                       logs            => 3,
                       diff            => 3,
                       tdiff           => 0,
                       file            => 0,
                       compress        => 'none'
                },
                'Denis Barbier' => {
                        email       => 'barbier@imacs.polytechnique.fr',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
	        'Nicolas Bertolissio' => {
		        email       => 'nico.bertol@free.fr',
		        summary     => 3,
		        logs        => 3,
		        diff        => 3,
		        tdiff       => 0,
		        file        => 0,
		        compress    => 'none'
		},
                'Laurence Bock' => {
                        email       => 'ybecker@mindspring.com',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 3,
                        file        => 3,
                        compress    => 'none'
                },
		'Frédéric Bothamy' => {
                        email       => 'frederic.bothamy@free.fr',
                        summary     => 2,
                        logs        => 0,
                        diff        => 1,
                        tdiff       => 1,
                        file        => 1,
                        compress    => 'none'
                },
                'Norbert Bottlaender-Prier' => {
                        email       => 'norbert@globenet.org',
                        summary     => 2,
                        logs        => 0,
                        diff        => 1,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
		'Cyril Brulebois' => {
  	      		email       => 'cyril.brulebois@enst-bretagne.fr',
		        summary     => 3,
		        logs        => 3,
		        diff        => 3,
		        tdiff       => 0,
		        file        => 0
		},
                'Christian Couder' => {
                        email       => 'christian@couder.net',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 3,
                        file        => 3,
                        compress    => 'none'
                },
                'Guillaume Estival' =>  {
                        email       => 'thomas.huriaux@enst-bretagne.fr',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
                'Arnaud Fontaine' => {
                        email       => 'arnaud@andesi.org',
                        summary     => 2,
                        logs        => 2,
                        diff        => 2,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
		},
                'Thomas Huriaux' => {
                        email       => 'thomas.huriaux@enst-bretagne.fr',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
                'Sébastien Kalt' => {
                        email       => 'ustilago@free.fr',
                        summary     => 2,
                        logs        => 0,
                        diff        => 2,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
                'Pierre Machard' => {
                        email       => 'pmachard@tuxfamily.org',
                        summary     => 2,
                        logs        => 2,
                        diff        => 2,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
		'Eric Madesclair' => {
           		email       => 'eric-m@wanadoo.fr',
           		summary     => 2,
           		logs        => 2,
           		diff        => 2,
           		tdiff       => 0,
           		file        => 0,
                        compress    => 'none'
           	},
                'Jérôme Marant' => {
                        email       => 'thomas.huriaux@enst-bretagne.fr',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
                'Thomas Marteau' => {
                        email       => 'thomas@marteau.org',
                        summary     => 2,
                        logs        => 1,
                        diff        => 1,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
                'Ghislain Mary' => {
		        email       => 'thomas.huriaux@enst-bretagne.fr',
		        summary     => 3,
		        logs        => 3,
		        diff        => 3,
		        tdiff       => 0,
		        file        => 0,
                        compress    => 'none'
		},
               'Simon Paillard' =>  {
                        email       => 'simon.paillard@resel.enst-bretagne.fr',
                        summary     => 2,
                        logs        => 2,
                        diff        => 2,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
	        'Willy Picard' =>  {
                        email       => 'thomas.huriaux@enst-bretagne.fr',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
                },
                'Martin Quinson' => {
                        email       => 'frederic.bothamy@free.fr',
                        summary     => 2,
                        logs        => 0,
                        diff        => 1,
                        tdiff       => 1,
                        file        => 1,
                        compress    => 'none'
                },
		'Yannick Roehlly' => {
			email	    => 'yannick.roehlly@free.fr',
                        summary     => 3,
                        logs        => 0,
                        diff        => 3,
                        tdiff       => 0,
                        file        => 3,
                        compress    => 'none'
                }, 
                'Jérôme Schell' =>  {
                        email       => 'frederic.bothamy@free.fr',
                        summary     => 2,
                        logs        => 0,
                        diff        => 1,
                        tdiff       => 1,
                        file        => 1,
                        compress    => 'none'
                },
                'Mickael Simon' =>  {
                        email       => 'frederic.bothamy@free.fr',
                        summary     => 2,
                        logs        => 0,
                        diff        => 1,
                        tdiff       => 1,
                        file        => 1,
                        compress    => 'none'
                },
		'Clément Stenac' => {
        		email           => 'zorglub@via.ecp.fr',
		        summary         => 3,
		        logs            => 3,
		        diff            => 3,
		        tdiff           => 0,
		        file            => 0,
		        compress        => 'none',
		 },
                'DFS Task Force' =>  {
                        email       => 'simon.paillard@resel.enst-bretagne.fr',
                        summary     => 2,
                        logs        => 2,
                        diff        => 2,
                        tdiff       => 0,
                        file        => 0,
                        compress    => 'none'
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
                        email       => 'debian-l10n-french@lists.debian.org',
                        summary     => 2,
                        mailsubject => 'Pages web orphelines a mettre a jour',
                        mailbody    => 'french/international/french/mail_unmaintained.txt',
                },
                maxdelta            => {
                        email       => 'debian-l10n-french@lists.debian.org',
                        summary     => 2,
                        maxdelta    => 5,
                        mailsubject => '[Important] Pages web obsoletes',
                        mailbody    => 'french/international/french/mail_obsolete.txt',
                },
                # this is a special name containing the default values
                default   => {
                        email       => '',
                        missing     => 0,
                        summary     => 0,
                        logs        => 0,
                        diff        => 0,
                        tdiff       => 0,
                        file        => 0,
                        frequency   => ['jamais', 'mensuel', 'hebdomadaire', 'quotidien'],
                        mailsubject => 'Pages web a mettre a jour',
                        mailbody    => 'french/international/french/mail_user.txt',
                        compress    => 'none'
                },
        };
        return $translators;
}

1;


