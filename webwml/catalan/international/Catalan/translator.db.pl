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
                'Alytidae' => {
                       email           => 'Alytidae@riseup.net',
                       summary         => 1,
                       logs            => 0,
                       diff            => 1,
                       tdiff           => 0,
                       file            => 0,
                       compress        => 'none'
                },

               'Innocent De Marchi' => {
                         email       => 'tangram.peces@gmail.com',
                         summary     => 1,
                         logs        => 0,
                         diff        => 1,
                         tdiff       => 0,
                         file        => 0,
                         compress    => 'none'
                 },
                
                # Below are special users, used to handle special cases
                #     default:      default values
                #     untranslated: pages not translated
                #     unmaintained: pages without maintainer
                #     maxdelta:     outdated pages
# Inicialment, això ho dexairem comentat
#                untranslated        => {
#                        email       => '',
#                        mailsubject => '',
#                        mailbody    => '',
#                },
#                unmaintained        => {
#                        email       => 'debian-l10n-catalan@lists.debian.org',
#                        summary     => 2,
#                        mailsubject => 'Pàgines web orfes pendents d'actualitzar',
#                        mailbody    => 'catalan/international/Catalan/mail_unmaintained.txt',
#                },
#                maxdelta            => {
#                        email       => 'debian-l10n-catalan@lists.debian.org',
#                        summary     => 2,
#                        maxdelta    => 5,
#                        mailsubject => '[Important] Pàgines web obsoletes',
#                        mailbody    => 'catalan/international/Catalan/mail_obsolete.txt',
#                },
                # this is a special name containing the default values
                default   => {
                        email       => '',
                        missing     => 0,
                        summary     => 0,
                        logs        => 0,
                        diff        => 0,
                        tdiff       => 0,
                        file        => 0,
                        frequency   => ['mai', 'mensual', 'setmanal', 'diari'],
                        mailsubject => 'Pàgines web a actualitzar',
                        mailbody    => 'catalan/international/Catalan/mail_user.txt',
                        compress    => 'none'
                },
        };
        return $translators;
}

1;


