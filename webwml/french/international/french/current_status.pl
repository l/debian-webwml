#!/usr/bin/perl

do 'documents-bd.pl';

# This file should modify the %translations database to include
# all information regarding the translation status for a fixed 
# language

#  	'key' => {
#	'status'		=> '',
#use numbers instead of text since it makes translations easier
#               'not-available' - 0
#               'not translated' - 1
#               'being translated' - 2
#               'needs revision' - 3
#               'translation up to date', - 4
#               'needs check' - 5
#               'being revised' - 6
#               'obsolete' - 7
#		'unknown' - 8
# In french:
#		'non-disponible' - 0
#		'à traduire' - 1
#		'en cours de traduction' - 2
#		'à relire' - 3
#		'traduction à jour', - 4
#		'à reviser' - 5
#		'en cours de révision' - 6
#		'obsolète' - 7
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


# ########################################################################################
#
# Livres GPL
#
# ########################################################################################

$translations_status = {

'book-gtiau' => {
	'status' 		=> 2,
	'since'			=> '13/09/1999',
	'translation_maintainer'=> ['Patrice Karatchentzeff <pkarat@club-internet.fr>' ],
	'translation_name'	=> 'Debian GNU/Linux: guide d\'installation et d\'utilisation',
	'translation_dev_url'   => 'http://cvs.debian.org/webwml/french/international/french/translations/debian-guide_fr-1.0.sgml?cvsroot=webwml',
	'old_translators'	=> [	'Martin Quinson <mquinson@zeppelin-cb.de>',
					'Fabien Ninoles <fabien@Nightbird.TZoNE.ORG>'],
},

# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

'project-history' => {
	'status'		=> 3,
	'since'			=> '03/11/2000',
	'base_revision'		=> '1.2',
	'translation_name'	=> 'Histoire du projet Debian',
	'translation_maintainer'=> ['Patrice Karatchentzeff <pkarat@club-internet.fr>'],
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
        'status'                => 4,
	'since'			=> '29/11/2000',
	'translation_maintainer'=> ['Mickael Simon <simon.mickael@wanadoo.fr>'],
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
	'status'		=> '4',
	'since'			=> '04/05/2001',
	'translation_name'	=> 'La charte Debian',
	'translation_maintainer'=> ['philippe batailler <pbatailler@teaser.fr>'],
	'base_revision'		=> '3.5.4.0',
	'translation_dev_url'   => 'http://www.teaser.fr/~pbatailler/',
	'old_translators'	=> ['Serge Stinckwich <serge@info.unicaen.fr>'],
},

'developers-reference' => {
	'status'		=> '6',
	'since'			=> '01/07/1998',
	'translation_name'	=> 'Guide de Référence du Développeur Debian',
	'translation_maintainer'=> ['Antoine Hulin <antoine@origan.fdn.fr>'],
	'base_revision'		=> '0.1',
	'translation_package'	=> '',
	'old_translators'	=> ['Alain Meessen <ameessen@ulb.ac.be>',
	                            'Herve Floch <Herve.Floch@linux.eu.org>',
				    'Laurent Picouleau <laurent.picouleau@wanadoo.fr>'],
},

'internals' => {
	'status'		=> '4',
	'since'			=> 'O8/O1/2001',
	'translation_name'	=> 'Manuel des mécanismes internes de dpkg',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'translation_url'	=> '',
	'base_revision'		=> '1.5',
	'translation_package'	=> 'dpkg',
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
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
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

# ########################################################################################
#
# Pages web particulières
#
# ########################################################################################

'international/French' => {
	'status'		=> '4',
	'note'			=> 'Version originale en français',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

# Génération automatique (Ne pas traduire!)

'MailingLists/subscribe' => {
	'status'		=> '0',
},

'MailingLists/unsubscribe' => {
	'status'		=> '0',
},

'devel/maintainer_contacts' => {
	'status'		=> '0',
},

# En cours

'News/weekly/contributing' => {
	'status'		=> '2',
	'since'			=> '24/07/1999',
	'translation_maintainer'=> ['Laurent Le Guillou <leguillo@hep.saclay.cea.fr>'],
},

'devel/help' => {
	'status'		=> '2',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'intro/why_debian' => {
	'status'		=> '2',
	'translation_maintainer'=> ['"Philippe Paillé" <valvert@club-internet.fr>'],
},

# Traducteurs

'News/1999/index' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990204' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990212' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990222' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990225a' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990225b' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990302' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990309' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990330' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'News/1999/19990421a' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'contact' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'donations' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'index' => {
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
},

'license' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'social_contract' => {
	'translation_maintainer'=> ['Antoine Martin <amartin@atos-group.com>'],
},

'support' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'todo' => {
	'translation_maintainer'=> ['Severin Hatt <magloire@multimania.com>'],
},

'MailingLists/debian-announce' => {
	'translation_maintainer'=> ['Sebastien Kalt <ustilago@bigfoot.com>'],
},

'devel/HOWTO_translate' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/extract_key' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/incoming_mirrors' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'devel/index' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/machines' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/people' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/release_info' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'devel/rsync_examples' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/HOWTO_work_on_website' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'devel/constitution' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'distrib/ftplist' => {
	'translation_maintainer'=> ['Severin Hatt <magloire@multimania.com>'],
},

'distrib/packages' => {
	'translation_maintainer'=> ['Marilleau Hugues <marillea@wotan.iie.cnam.fr>'],
},

'distrib/vendors' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'distrib/cdinfo' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'distrib/books' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'intro/about' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'intro/cn' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'intro/cooperation' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/index' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Chinese' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Finnish' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/German' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Italian' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Japanese' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Korean' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Spanish' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'international/Turkish' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'intro/license_disc' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'intro/organization' => {
	'translation_maintainer'=> ['Marilleau Hugues <marillea@wotan.iie.cnam.fr>'],
},

'mirror/explain' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/ftpmirror' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/index' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/submit' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/types' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/webmirror' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/push_server' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'mirror/size' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'vote/index' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/Access' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/Developer' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/Reporting' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/index' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/server-control' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/server-refcard' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'Bugs/server-request' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'vote/howto_proposal' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'vote/howto_result' => {
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
},

'releases/hamm/HOWTO.upgrade' => {
	'translation_maintainer'=> ['Philippe Caillaud <pcaillaud@infini.fr>'],
},

'releases/hamm/errata' => {
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@globenet.org>'],
},

'releases/slink/running-kernel-2.2' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'releases/potato/index' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'releases/index' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'search' => {
	'translation_maintainer'=> ['Jérôme Marant <jerome.marant@free.fr>'],
},

'ports/hurd/hurd-doc-translator' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'ports/hurd/hurd-doc' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'ports/hurd/hurd-faq' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'ports/hurd/hurd-install' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'ports/hurd/hurd-links' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'ports/hurd/hurd-news' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'ports/hurd/index' => {
	'translation_maintainer'=> ['Jérôme Abela <Jerome.Abela@solsoft.fr>'],
},

'y2k/index' => {
	'translation_maintainer'=> ['Sebastien Kalt <ustilago@bigfoot.com>'],
},

'y2k/extra' => {
	'translation_maintainer'=> ['Sebastien Kalt <ustilago@bigfoot.com>'],
},


};
