#!/usr/bin/perl

do 'documents-bd.pl';

# This file should modify the %translations database to include
# all information regarding the translation status for a fixed 
# language

#$$translations{'key'} = {
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
#};


# ########################################################################################
#
# Libros GPL
#
# ########################################################################################

$$translations{'book-gtiau'} = {
	'status' => 1
};


# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

$$translations{'project-history'} = {
	'status'	=> 2,
	'since'			=> '24/01/2000',
	'translation_name'	=> 'Historia del proyecto Debian',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@id-agora.com>']
};

$$translations{'user'} = {
	'status'	=> 2,
	'since'			=> '24/01/2000',
	'translation_name'	=> 'Guía para el usuario de Debian',
	'translation_maintainer'=> ['Enrique Zanardi <ezanardi@id-agora.com>']
};

$$translations{'faq'} = {
	'status'		=> 4,
	'since'			=> '?',
	'translation_name'	=> 'FAQ de Debian GNU/Linux',
	'translation_maintainer'=> ['Santiago Vila <sanvila@ctv.es>'],
	'translation_package'	=> 'doc-debian-es'
};

#


$$translations{'tutorial'} = {
	'status'		=> 3,
	'since'			=> '31/01/1999',
	'translation_name'	=> 'Tutorial de Debian',
	'translation_maintainer'=> ['Javier Fernández-Sanguino Peña <jfs@computer.org>'],
	'translation_cvs_url' 	=>'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/debian-tutorial.es.sgml'
};



$$translations{'install'} = {
	'status'		=> 4,
	'translation_name'	=> 'Manual de instalación de Debian',
	'translation_maintainer'=> ['Enrique Zanardi'],
	'base_revision'		=> '2.1',
	'translation_cvs_url'   => 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/install.es.sgml',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '16/03/1999'
};

$$translations{'dselect-beginner'} = {
	'status'		=> 4,
#	'since'			=> '22/03/1999',
	'translation_name'	=> 'Guía de dselect para principiantes',
	'translation_maintainer'=> ['Enrique Zanardi'],
#	'base_revision'		=> '2.1',
#	'translation_url'	=> 'http://www.debian.org/~clebars/docs-2.1/dselect-beginner.html/dselect-beginner.html',
	'translation_cvs_url'   => 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/dselect-beginner.es.sgml',
	'translation_package'	=> 'boot-floppies'
#	'last_translated'	=> '22/003/1999',
};

$$translations{'release-notes'} = {
	'status'		=> 1,
#	'since'			=> '05/06/1999',
	'translation_name'	=> 'Notas de la versión',
	'translation_maintainer'=> ['Enrique Zanardi'],
	'base_revision'		=> '',
	'translation_url'	=> '',
	'translation_cvs_url'   => '',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> ''
};



$$translations{'maint-guide'} = {
	'status'		=> 6,
	'since'			=> '3/9/1999',
	'translation_name'	=> 'Guía del Nuevo Desarrollador de Debian',
	'translation_maintainer'=> ['Javier Fernández-Sanguino Peña <jfs@computer.org>'],
	'translation_dev_url'	=> 'http://www.dat.etsit.upm.es/~jfs/debian/maint-guide-es/',
	'translation_cvs_url'   => 'http://www.debian.org/cgi-bin/cvsweb/ddp/manuals.sgml/maint-guide/maint-guide.es.sgml',
	'translation_package'   => 'maint-guide-es',
	'last_translated'	=> '12/04/1999'
};

$$translations{'programmer'} = {
	'status'		=> 4,
	'since'			=> '13/04/1998',
        'translation_name'      => 'Cómo hacer paquetes Debian (nuevos desarrolladores)',
        'translation_maintainer'=> ['Javier Fernández-Sanguino Peña <jfs@computer.org>'],
        'translation_dev_url'   => 'http://www.dat.etsit.upm.es/~jfs/debian/doc//'
};

