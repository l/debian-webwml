#!/usr/bin/perl

# This is GPL'ed, copyright 2000 Martin Quinson <mquinson@ens-lyon.fr>

# In this file, you can find a DB about the translators. 
# It should be hand maintained by the coordinator, it is not modified
#  automatically.
# For now, it is only used by check-translation.pl (in a version not 
#  commited to the cvs, but I can send it to you, if you want to)

# Here is the syntax:
#  The data is in a hash table named 'translators'. 
#  Each key is the name of a translator (trimmed, without email adress)
#  For each one, you have a (sub)hash table containing:
#    email => the current email of this guy
#    informations to describe what sort of automatic mail he/she want to get.
#     For each part, the value is numeric and means:
#        0: never, 1:monthly, 2:weekly, 3:daily
#     The different parts are:
#        summary: just the summary of what is needed
#          example: NeedToUpdate french/donations.wml from version 1.16 to version 1.29
#        logs: the cvs logs between the translated and actual version
#        diff: idem with the diff
#        file: add the last version of translated file (to avoid to cvs update it before work)
#   compress: which type of compression you want to have
#     it could be: "none","gzip" ou "bzip2" 
#     (NOT IMPLEMENTED: for now, "none" is assumed in all case)

sub init_translators {
 $translators = {
    'Denis Barbier' => {
         'email'     => 'barbier@imacs.polytechnique.fr',
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
    'Sébastien Kalt' => {
         'email'     => 'ustilago@bigfoot.com',
         'summary'   => 2, 
         'logs'      => 0, 
         'diff'      => 2, 
         'tdiff'     => 0,
	 'file'      => 0,
         'compress'  => 'none' 
    },
    'Jérôme Marant' => {
         'email'     => 'jerome.marant@free.fr',
         'summary'   => 2, 
         'logs'      => 0, 
         'diff'      => 0, 
         'tdiff'     => 0,
	 'file'      => 0,
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
    'Norbert Bottlaender-Prier' => {
         'email'     => 'norbert@globenet.org',
         'summary'   => 1, 
         'logs'      => 0, 
         'diff'      => 1, 
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
    'Jerome Abela' => {
         'email'     => 'Jerome.Abela@solsoft.fr',
         'summary'   => 2, 
         'logs'      => 0, 
         'diff'      => 0, 
         'tdiff'     => 0,
	 'file'      => 0,
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
    'Christophe Le Bars' =>  {
 	 'email'     => 'clebars@debian.org',
         'summary'   => 2, 
         'logs'      => 0, 
         'diff'      => 0, 
         'tdiff'     => 0,
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
    'Olivier Bounhoure' =>  {
 	 'email'     => 'olivier.bounhoure@club-internet.fr',
         'summary'   => 3, 
         'logs'      => 3, 
         'diff'      => 3, 
         'tdiff'     => 3,
	 'file'      => 3,
         'compress'  => 'none' 
    },
    'list' => { # this is a special name containing the default addressee
         'email'      => 'debian-l10n-french@lists.debian.org',
         'missing'    => 1, 
         'summary'    => 2, 
         'logs'       => 0, 
         'diff'       => 0, 
         'tdiff'      => 0,
	 'file'       => 0,
         'compress'   => 'none'
    }
};
return $translators;
}
1;





