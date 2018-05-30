#!/usr/bin/perl

# This is GPL'ed, copyright 2000 Martin Quinson <mquinson@ens-lyon.fr>

# In this file, you can find a DB about the translators.
# It should be hand maintained by the coordinator, it is not modified
#  automatically.

# Here is the syntax:
#  The data is in a hash table returned by init_translators().
#  Each key is the name of a translator (trimmed, without email adress)
#  For each one, you have a (sub)hash table containing:
#  * email:    the current email of this guy
#  * compress: which type of compression you want to have (NOT YET IMPLEMENTED)
#  Remaining keys have numeric value, which tells when to send info:
#  * summary:  a summary of which documents are outdated
#  * logs:     the commit logs between the translated and current versions
#  * diff:     idem with diff
#  * tdiff:    try to find the part of the translated text modified by the
#              patch
#  * file:     add current version of translated file

# The possible frenquencies are:
# 0 (never), 1 (monthly), 2 (weekly) or 3 (daily)


sub init_translators {
        my $translators = {
		'Alexander Reshetov' => {
			email		=> 'eof@debian-by.org',
			summary		=> 3,
			logs		=> 3,
			diff		=> 3,
			tdiff		=> 3,
			file		=> 0,
			compress	=> 'none'
		},
		'Lev Lamberov' => {
			email		=> 'dogsleg@debian.org',
			summary		=> 2,
                        diff		=> 2,
                        file            => 0,
			compress	=> 'none'
		},
	default   => {
			email       => '',
			missing     => 0,
			summary     => 0,
			logs        => 0,
			diff        => 0,
			tdiff       => 0,
			file        => 0,
			frequency   => ['never', 'monthly', 'weekly', 'daily'],
			mailsubject => 'Страницы www.d.o, требующие обновления',
			mailbody    => 'russian/international/russian/mail_user.txt',
			compress    => 'none'
		},

        };
        return $translators;
}

1;
