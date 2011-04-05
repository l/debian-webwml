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
                'Stanislav Valasek' => {
                        email       => 'valasek@fastmail.fm',
                        summary     => 2,
                        logs        => 2,
                        diff        => 2,
                        tdiff       => 2,
                        file        => 2,
                        compress    => 'none'
                },
                'Matej Kovac' => {
                        email       => 'matej.kovac@telnet.sk',
                        summary     => 2,
                        logs        => 2,
                        diff        => 2,
                        tdiff       => 2,
                        file        => 2,
                        compress    => 'none'
                },
                'Ivan Masar' => {
                        email       => 'helix84@centrum.sk',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 3,
                        file        => 3,
                        compress    => 'none'
                },
                'Slavko' => {
                        email       => 'linux@slavino.sk',
                        summary     => 3,
                        logs        => 3,
                        diff        => 3,
                        tdiff       => 3,
                        file        => 3,
                        compress    => 'none'
                },
        };
        return $translators;
}

1;
