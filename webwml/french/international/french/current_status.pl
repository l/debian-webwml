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
	'translation_maintainer'=> ['Fabien Ninoles <fabien@Nightbird.TZoNE.ORG>'],
	'translation_name'	=> 'Debian GNU/Linux: guide d\'installation et d\'utilisation',
},


# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

      'project-history' => {
	'status'		=> 5,
	'since'			=> '03/05/1999',
	'translation_name'	=> 'Histoire du projet Debian',
	'translation_maintainer'=> ['Jerome Rousselot <r.jerome@francemel.com>'],
},

	'user' => {
	'status'		=> 1,
	'since'			=> '?'
},

	'faq' => {
	'status'		=> 2,
	'since'			=> '21/07/1998',
	'translation_name'	=> 'FAQ Debian GNU/Linux',
	'translation_maintainer'=> ['Philippe Caillaud <phil@penguin.infini.fr>'],
	'ping'			=> '28/11/1998',
	'old_translators'	=> ['Vincent Renardias <vincent@waw.com>'],
},
	'constitution' => {
	'status'		=> 1,
	'since'			=> '?'
},
	'mailing-lists' => {
	'status'		=> 1,
	'since'			=> '?'
},
	'bug-reporting' => {
	'status'		=> 1,
	'since'			=> '?'
},
	'source-unpack' => {
	'status'		=> 1,
	'since'			=> '?'
},



	'tutorial' => {
	'status'		=> 2,
	'since'			=> '31/01/1999',
	'translation_name'	=> 'Tutorial Debian',
	'translation_maintainer'=> ['Eric Jacoboni <jaco@titine.fr.eu.org>'],
	'old_translators'	=> ['Loïc Martin <lomartin@dejanews.com>'],
},



	'install' => {
	'status'		=> 3,
	'since'			=> '13/03/2000',
	'translation_name'	=> 'Manuel d\'installation de Debian',
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
	'base_revision'		=> '2.1',
	'translation_url'	=> 'http://www.debian.org/releases/stable/source/install.fr.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/install.fr.sgml?cvsroot=debian-boot',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '16/03/1999'
},

	'dselect-beginner' => {
	'status'		=> 3,
	'since'			=> '13/03/2000',
	'translation_name'	=> 'Guide de dselect pour les débutants',
	'translation_maintainer'=> ['Laurent Picouleau <lcrpic@a2points.com>'],
	'base_revision'		=> '2.1',
	'translation_url'	=> 'http://www.debian.org/releases/stable/source/dselect-beginner.fr.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/dselect-beginner.fr.sgml?cvsroot=debian-boot',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '27/03/1999'
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
	'since'			=> '19/10/1999',
	'translation_name'	=> 'Nouveau Guide du Responsable Debian',
	'translation_maintainer'=> ['Frederic Dumont <Frederic.Dumont@gate71.be>'],
	'translation_dev_url'   => 'http://www.info.fundp.ac.be/~fdumont/maint-guide_fr.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/ddp/manuals.sgml/maint-guide/maint-guide.es.sgml?cvsroot=debian-doc',
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

	'i18n' => {
        'status'                => 1,
	'since'			=> '13/03/2000',
},


	'meta' => {
        'status'                => 1,
	'since'			=> '13/03/2000',
},




);
