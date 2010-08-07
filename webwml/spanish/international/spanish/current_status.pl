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
# Libros GPL
#
# ########################################################################################

%translations_status = (

'book-gtiau' => {
	'status' => 2,
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@id-agora.com>'],
	'since'			=> '08/02/2000'
},


# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

      'project-history' => {
	'status'	=> 2,
	'since'			=> '24/01/2000',
	'translation_name'	=> 'Historia del proyecto Debian',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@id-agora.com>']
},

	'user' => {
	'status'	=> 2,
	'since'			=> '24/01/2000',
	'translation_name'	=> 'Guía para el usuario de Debian',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@id-agora.com>']
},

	'faq' => {
	'status'		=> 5,
	'since'			=> '8 Jul 1999 12:25:56 +0200',
	'translation_name'	=> 'FAQ de Debian GNU/Linux',
	'translation_maintainer'=> ['Santiago Vila <sanvila@ctv.es>'],
	'translation_package'	=> 'doc-debian-es'
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
	'status'		=> 3,
	'since'			=> '31/01/1999',
	'translation_name'	=> 'Tutorial de Debian',
	'translation_maintainer'=> ['Javier Fernández-Sanguino Peña <jfs@debian.org>'],
	'translation_cvs_url' 	=>'http://cvs.debian.org/ddp/manuals.sgml/tutorial/debian-tutorial.es.sgml?cvsroot=debian-doc'
},



	'install' => {
	'status'		=> 4,
	'translation_name'	=> 'Manual de instalación de Debian',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@debian.org>'],
	'base_revision'		=> '2.1',
	'translation_url'	=> 'http://www.debian.org/releases/stable/source/install.es.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/install.es.sgml?cvsroot=debian-boot',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '16/03/1999'
},

	'dselect-beginner' => {
	'status'		=> 4,
#	'since'			=> '22/03/1999',
	'translation_name'	=> 'Guía de dselect para principiantes',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@debian.org>'],
	'base_revision'		=> '2.1',
	'translation_url'	=> 'http://www.debian.org/releases/stable/source/dselect-beginner.es.sgml',
	'translation_cvs_url'   => 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/dselect-beginner.es.sgml?cvsroot=debian-boot',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '27/03/1999'
},

	'release-notes' => {
	'status'		=> 2,
	'since'			=> '05/06/1999',
	'translation_name'	=> 'Notas de la versión',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@debian.org>'],
#	'base_revision'		=> '',
#	'translation_url'	=> '',
#	'translation_cvs_url'   => '',
	'translation_package'	=> 'boot-floppies',
#	'last_translated'	=> ''
},



	'maint-guide' => {
	'status'		=> 6,
	'since'			=> '3/9/1999',
	'translation_name'	=> 'Guía del Nuevo Desarrollador de Debian',
	'translation_maintainer'=> ['Javier Fernández-Sanguino Peña <jfs@debian.org>'],
	'translation_dev_url'	=> 'http://www.dat.etsit.upm.es/~jfs/debian/maint-guide-es/',
	'translation_cvs_url'   => 'http://cvs.debian.org/ddp/manuals.sgml/maint-guide/maint-guide.es.sgml?cvsroot=debian-doc',
	'translation_package'   => 'maint-guide-es',
	'last_translated'	=> '12/04/1999'
},

	'programmer' => {
	'status'		=> 4,
	'since'			=> '13/04/1998',
        'translation_name'      => 'Cómo hacer paquetes Debian (nuevos desarrolladores)',
        'translation_maintainer'=> ['Javier Fernández-Sanguino Peña <jfs@debian.org>'],
        'translation_dev_url'   => 'http://www.dat.etsit.upm.es/~jfs/debian/doc/'
},
	
	'network-administrator' => {
        'status'                => 2,
	'since'			=> '08/02/2000',
	'translation_maintainer' => ['Josep Llauradó Selvas <darlock@teleline.es>'],
'url'                   => 'http://www.debian.org/doc/network-administrator/',
'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/network-administrator/?cvsroot=debian-doc'
},

	'system-administrator' => {
		'status'               => 2, 
		'translation_maintainer' => ['Jose Angel Fdez. Luengo <skaven@linuxfreak.com>'],
		'since' 		=> '06/02/2000',
},

	'i18n' => {
        	'status'                => 2,
        	'lines'                 => 1974,
		'translation_maintainer' => ['Javier Macias-Guarasa <macias@die.upm.es>'],
		'since'			=> '08/02/2000'
},


	'meta' => {
        'name'                  => 'META Manual de Debian',
	'status'		=> 2,
	'base_revision'		=> '0.9',
	'translation_maintainer' => ['Lluís Vilanova <xscript.geo@yahoo.com>'],
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/meta/meta.es.sgml?cvsroot=debian-doc',
	'since'			=> '08/02/2000'
},




);
