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
#  * file:     add current version of translated file

sub init_translators {
        my $translators = {
                'Jerome Abela' => {
                        'email'     => 'Jerome.Abela@solsoft.fr',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Denis Barbier' => {
                        'email'     => 'barbier@imacs.polytechnique.fr',
                        'summary'   => 3,
                        'logs'      => 3,
                        'diff'      => 3,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Norbert Bottlaender-Prier' => {
                        'email'     => 'norbert@globenet.org',
                        'summary'   => 1,
                        'logs'      => 0,
                        'diff'      => 1,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Olivier Bounhoure' =>  {
                        'email'     => 'olivier.bounhoure@club-internet.fr',
                        'summary'   => 3,
                        'logs'      => 3,
                        'diff'      => 3,
                        'tdiff'     => 3,
                        'file'      => 3,
                        'compress'  => 'none'
                },
                'Philippe Caillaud' => {
                        'email'     => 'pcaillaud@infini.fr',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'file'      => 0,
                        'tdiff'     => 0,
                        'compress'  => 'none'
                },
                'Christian Couder' => {
                        'email'     => 'chcouder@club-internet.fr',
                        'summary'   => 3,
                        'logs'      => 3,
                        'diff'      => 3,
                        'tdiff'     => 3,
                        'file'      => 3,
                        'compress'  => 'none'
                },
                'Guillaume Estival' =>  {
                        'email'     => 'estival@dspnet.claranet.fr',
                        'summary'   => 2,
                        'logs'      => 2,
                        'diff'      => 2,
                        'tdiff'     => 2,
                        'file'      => 2,
                        'compress'  => 'none'
                },
                'S�bastien Kalt' => {
                        'email'     => 'ustilago@bigfoot.com',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 2,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Christophe Le Bars' =>  {
                        'email'     => 'clebars@debian.org',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'J�r�me Marant' => {
                        'email'     => 'jerome.marant@free.fr',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Antoine Martin' => {
                        'email'     => 'amartin@atos-group.com',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Martin Quinson' => {
                        'email'     => 'mquinson@ens-lyon.fr',
                        'summary'   => 3,
                        'logs'      => 3,
                        'diff'      => 3,
                        'tdiff'     => 3,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'Mickael Simon' =>  {
                        'email'     => 'mickaelsimon@free.fr',
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'J�r�me Schell' =>  {
                        'email'     => 'jschell@noos.fr',
                        'summary'   => 2,
                        'logs'      => 2,
                        'diff'      => 2,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                },
                'list' => {
                # this is a special name containing the default addressee
                        'email'     => 'debian-l10n-french@lists.debian.org',
                        'missing'   => 1,
                        'summary'   => 2,
                        'logs'      => 0,
                        'diff'      => 0,
                        'tdiff'     => 0,
                        'file'      => 0,
                        'compress'  => 'none'
                }
        };
        return $translators;
}

1;

