#!/usr/bin/perl

do 'documents-bd.pl';

# This file should modify the %translations database to include
# all information regarding the translation status for a fixed 
# language

#%translations_status = (
#  'key' => {
#	'status'		=> '',
#use numbers instead of text since it makes translations easier
#               'not-available' - 0
#               'not translated' - 1
#               'being translated' - 2
#               'needs revision' - 3
#               'translation up to date', - 4
#               'needs check' - 5
#               'being revised' -  6
#               'obsolete' - 7
#		'unknown' - 8
# In french:
#		'non-disponible'
#		'à traduire'
#		'en cours de traduction'
#		'à relire'
#		'traduction à jour',
#		'à reviser'
#		'en cours de révision'
#		'obsolète'
#
#	'since'			=> '',
#	'diff'			=> '',
#	'base_revision'	        => '',
#	'translation_name'	=> '',
#	'translation_sub_name'	=> '',
#	'translation_maintainer'=> [
#					'', 
#				],
#	'translation_revision'	=> '',
#	'translation_url'	=> '',
#	'translation_cvs_url'   => '',
#	'translation_source_url'=> '',
#	'translation_diff_url'  => '',
#	'translation_package'	=> '',
#	'last_translated'	=> '',
#	'old_translators'	=> []
#},
#);


# ########################################################################################
#
# Livres GPL
#
# ########################################################################################

%translations_status = (

'book-gtiau' => {
	'status' 		=> 2,
	'since'			=> '13/09/1999',
	'translation_maintainer'=> ['Martin Quinson <mquinson@zeppelin-cb.de>'],
	'translation_name'	=> 'Debian GNU/Linux: guide d\'installation et d\'utilisation',
	'translation_url'	=> 'http://www.ens-lyon.fr/~mquinson/debian/guide/',
	'translation_dev_url'   => 'http://www.newriders.com/debian/debian-guide.tar.bz2',
	'old_translators'	=> ['Fabien Ninoles <fabien@Nightbird.TZoNE.ORG>'],
},

# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

'project-history' => {
	'status'		=> 5,
	'since'			=> '03/05/1999',
	'base_revision'		=> '1.2',
	'translation_name'	=> 'Histoire du projet Debian',
	'translation_maintainer'=> ['Jerome Rousselot <r.jerome@francemel.com>'],
},

'faq' => {
	'status'		=> 2,
	'since'			=> '21/07/1998',
	'translation_name'	=> 'FAQ Debian GNU/Linux',
	'translation_maintainer'=> ['Philippe Caillaud <phil@penguin.infini.fr>'],
	'ping'			=> '28/11/1998',
	'old_translators'	=> ['Vincent Renardias <vincent@waw.com>'],
},

'tutorial' => {
	'status'		=> 2,
	'since'			=> '31/01/1999',
	'translation_name'	=> 'Tutorial Debian',
	'translation_maintainer'=> ['Eric Jacoboni <jaco@titine.fr.eu.org>'],
	'old_translators'	=> ['Loïc Martin <lomartin@dejanews.com>'],
},

'user' => {
	'status'		=> 1,
	'since'			=> '?'
},

'install' => {
	'status'		=> 3,
	'since'			=> '13/03/2000',
	'translation_name'	=> 'Manuel d\'installation de Debian',
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
	'base_revision'		=> '2.1',
	'translation_url'	=> 'http://www.debian.org/releases/stable/source/install.fr.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/boot-floppies/documentation/install.fr.sgml?cvsroot=debian-boot',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '16/03/1999'
},

'dselect-beginner' => {
	'status'		=> 3,
	'since'			=> '13/03/2000',
	'translation_name'	=> 'Guide de dselect pour les débutants',
	'translation_maintainer'=> ['Laurent Picouleau <laurent.picouleau@wanadoo.fr>'],
	'base_revision'		=> '2.1',
	'translation_url'	=> 'http://www.debian.org/releases/stable/source/dselect-beginner.fr.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/boot-floppies/documentation/dselect-beginner.fr.sgml?cvsroot=debian-boot',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '27/03/1999',
	'note'			=> 'Le responsable est prêt à passer la main'
},

'release-notes' => {
	'status'		=> 2,
	'since'			=> '05/06/1999',
	'translation_name'	=> 'Notes sur la version',
	'translation_maintainer'=> ['mmenal <mmenal@francemel.com>'],
	'translation_package'	=> 'boot-floppies',
},

'maint-guide' => {
	'status'		=> 4,
	'since'			=> '30/03/2000',
	'translation_name'	=> 'Guide du nouveau responsable Debian',
	'translation_maintainer'=> ['Frederic Dumont <frederic.dumont@freeworld.be>'],
	'translation_url'	=> 'http://www.info.fundp.ac.be/~fdumont/maint-guide_fr.html/index.html',
	'translation_dev_url'   => 'http://www.info.fundp.ac.be/~fdumont/maint-guide_fr.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/ddp/manuals.sgml/maint-guide/maint-guide.fr.sgml?cvsroot=debian-doc',
	'last_translated'	=> '02/07/1998',
},

'programmer' => {
	'status'		=> 7,
	'since'			=> '?',
},
	
'network-administrator' => {
        'status'                => 1,
	'since'			=> '13/03/2000',
},

'system-administrator' => {
        'status'                => 1,
	'since'			=> '13/03/2000',
},

'intro-i18n' => {
        'status'                => 1,
	'since'			=> '13/03/2000',
},


'meta' => {
        'status'                => 1,
	'since'			=> '13/03/2000',
},

'packaging-manual' => {
	'translation_name'	=> 'Manuel des paquets Debian',
	'status'		=> 'à relire',
	'since'			=> '01/07/1998',
	'translation_maintainer'=> [
					'David Cure <cure@cnam.fr>', 
					'Christian Jacolot <jacolot@ubolib.univ-brest.fr>',
				],
	'translation_package'	=> '',
},

'policy' => {
	'status'		=> '6',
	'since'			=> '6/04/1999',
	'translation_name'	=> 'Manuel des normes Debian',
	'translation_maintainer'=> ['David Rocher <davroc@hplb.hpl.hp.com>'],
	'base_revision'		=> '2.5.0.0',
	'translation_url'	=> 'http://savage.iut-blagnac.fr/projets/developpement/policy.fr/policy.fr.html/',
	'translation_dev_url'   => 'http://savage.iut-blagnac.fr/projets/developpement/policy.fr/policy.fr.sgml',
	'translation_package'	=> '',
	'old_translators'	=> ['Serge Stinckwich <serge@info.unicaen.fr>'],
},

'developers-reference' => {
	'status'		=> '5',
	'since'			=> '01/07/1998',
	'translation_name'	=> 'Guide de Référence du Développeur Debian',
	'translation_maintainer'=> ['Laurent Picouleau <laurent.picouleau@wanadoo.fr>'],
	'base_revision'		=> '0.1',
	'translation_package'	=> '',
	'old_translators'	=> ['Herve Floch <Herve.Floch@linux.eu.org>'],
	'note'			=> 'Le responsable actuel veut passer la main'
},

'internals' => {
	'status'		=> '3',
	'since'			=> '19/10/1999',
	'translation_name'	=> 'Le manuel de l\'intérieur de dpkg',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'base_revision'		=> '1.2',
	'translation_package'	=> '',
},

'making-deb' => {
	'status'		=> '4',
	'since'			=> '25/09/1998',
	'translation_name'	=> 'Introduction : Créer un paquet Debian',
	'translation_maintainer'=> ['Frederic Dumont <frederic.dumont@gate71.be>'],
	'last_translated'	=> '01/07/1998',
},

'sgml-howto' => {
	'status'		=> 2,
	'since'			=> '30/03/2000',
	'translation_name'	=> 'The Debian SGML/XML HOWTO',
	'translation_maintainer'=> ['Jérôme Marant <jerome_marant@hotmail.com>'],
},

'markup' => {
	'status'		=> '4',
	'since'			=> '',
	'translation_name'	=> 'Manuel de Debiandoc-SGML',
	'translation_sub_name'	=> '',
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
	'translation_cvs_url'   => '',
	'translation_package'	=> 'doc-debian-fr',
	'last_translated'	=> '',
},

'libc5-libc6-Mini-HOWTO' => {
	'status'		=> '4',
	'since'			=> '10/08/1998',
	'translation_name'	=> 'libc5-libc6-Mini-HOWTO',
	'translation_sub_name'	=> '',
	'translation_maintainer'=> ['Philippe CAILLAUD <phil@penguin.infini.fr>'],
	'translation_package'	=> '',
	'last_translated'	=> '10/08/1998',
},

);
