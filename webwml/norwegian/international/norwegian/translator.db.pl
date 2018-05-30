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
                'Hans F. Nordhaug' => {
                        email       => 'hansfn@gmail.com',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 3,
                        file        => 0,
                        compress    => 'none'
                },

                # Below are special users, used to handle special cases
                #     default:      default values
                #     untranslated: pages not translated
                #     unmaintained: pages without maintainer
                #     maxdelta:     outdated pages
                untranslated        => {
                        email       => 'hansfn@gmail.com',
                        mailsubject => '',
                        mailbody    => '',
                },
                unmaintained        => {
                        email       => 'hansfn@gmail.com',
                        summary     => 1,
                        mailsubject => 'Oversatte Debian nettsider uten vedlikeholder',
                        mailbody    => 'norwegian/international/norwegian/mail_unmaintained.txt',
                },
                maxdelta            => {
                        email       => 'hansfn@gmail.com',
                        summary     => 3,
                        maxdelta    => 5,
                        mailsubject => '[Viktig] Utdaterte oversettelser av Debian nettsider',
                        mailbody    => 'norwegian/international/norwegian/mail_obsolete.txt',
                },
                # this is a special name containing the default values
                default => {
                        email       => '',
                        missing     => 0,
                        summary     => 0,
                        logs        => 0,
                        diff        => 0,
                        tdiff       => 0,
                        file        => 0,
                        frequency   => ['aldri', 'månedlig', 'ukentlig', 'daglig'],
                        mailsubject => 'Oppdatering for oversettelse av Debian nettsider',
                        mailbody    => 'norwegian/international/norwegian/mail_user.txt',
                        compress    => 'none'
                },
        };
        return $translators;
}

1;

