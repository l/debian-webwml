#!/usr/bin/perl

$translations = {

#'key'			=> {
#	'type'			=> '', # obsolète, se déduit de la clef
#	'name'			=> '',
#	'sub_name'		=> '',
#	'author'		=> '',
#	'version'		=> '',
#	'url'			=> '',
#	'source_url'		=> '',
#	'package'		=> '',
#	'status'		=> '',
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
#	'translation_name'	=> '',
#	'translation_sub_name'	=> '',
#	'translation_maintainer'=> [
#					'', 
#				],
#	'translation_version'	=> '',
#	'translation_url'	=> '',
#	'translation_source_url'=> '',
#	'translation_package'	=> '',
#	'last_translated'	=> '',
#	'old_translators'	=> [],
#},

# Quel est le statut actuel de ta traduction?

# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

'project-history' => {
	'type'			=> 'DDP',
	'name'			=> 'The Debian Project History',
	'status'		=> 'à relire',
	'since'			=> '03/05/1999',
	'translation_name'	=> 'Histoire du projet Debian',
	'translation_maintainer'=> ['Jerome Rousselot <r.jerome@francemel.com>'],
	'translation_version'	=> '1.2',
	'last_translated'	=> '03/05/1999',
},

'faq' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux FAQ',
	'source_url'		=> '?',
	'package'		=> 'doc-debian',
	'status'		=> 'en cours de traduction',
	'since'			=> '21/07/1998',
	'translation_name'	=> 'FAQ Debian GNU/Linux',
	'translation_maintainer'=> ['Philippe Caillaud <phil@penguin.infini.fr>'],
	'ping'			=> '28/11/1998',
	'translation_version'	=> '',
	'translation_package'	=> '',
	'old_translators'	=> ['Vincent Renardias <vincent@waw.com>'],
},

#
# Debian-user FAQ-O-MATIC ?
# Linux Magazines ?
#

'book-suggestions' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Book Suggestions',
	'status'		=> 'non-disponible',
},

'meta' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian META Manual',
	'status'		=> 'non-disponible',
},

'dictionary' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Dictionary',
	'status'		=> 'non-disponible',
},

'tutorial' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Tutorial',
	'version'		=> '',
	'url'			=> 'http://www.debian.org/~hp/tutorial/debian-tutorial.html',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/tutorial/tutorial/debian-tutorial.sgml',
	'package'		=> '',
	'status'		=> 'en cours de traduction',
	'since'			=> '31/01/1999',
	'translation_name'	=> 'Tutorial Debian',
	'translation_sub_name'	=> '',
	'translation_maintainer'=> ['Eric Jacoboni <jaco@titine.fr.eu.org>'],
	'ping'			=> '',
	'translation_version'	=> '',
	'translation_package'	=> '',
	'old_translators'	=> ['Loïc Martin <lomartin@dejanews.com>'],
},

'user' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian User Reference Manual',
	'status'		=> 'non-disponible',
},

#
# Debian Tips?
#

'install' => {
	'type'			=> 'boot',
	'name'			=> 'Debian Installation Manual',
	'version'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/install.en.html',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/install.sgml',
	'package'		=> 'boot-floppies',
	'status'		=> 'traduction à jour',
	'since'			=> '16/03/1999',
	'translation_name'	=> 'Manuel d\'installation de Debian',
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
	'translation_version'	=> '2.1',
	'translation_url'	=> 'http://www.debian.org/~clebars/docs-2.1/install.html/install.html',
	'translation_source_url'=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/Attic/install.fr.sgml',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '16/03/1999',
},

'dselect-beginner' => {
	'type'			=> 'boot',
	'name'			=> 'Dselect beginner guide',
	'version'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/dselect-beginner.en.html',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/dselect-beginner.sgml',
	'package'		=> 'boot-floppies',
	'status'		=> 'traduction à jour',
	'since'			=> '22/03/1999',
	'translation_name'	=> 'Guide de dselect pour les débutants',
	'translation_maintainer'=> ['Laurent Picouleau <lcrpic@a2points.com>'],
	'translation_version'	=> '2.1',
	'translation_url'	=> 'http://www.debian.org/~clebars/docs-2.1/dselect-beginner.html/dselect-beginner.html',
	'translation_source_url'=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/Attic/dselect-beginner.fr.sgml',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '22/003/1999',
},

'release-notes' => {
	'type'			=> 'boot',
	'name'			=> 'Release Notes',
	'version'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/release-notes/',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/release-notes.sgml',
	'package'		=> 'boot-floppies',
	'status'		=> 'en cours de traduction',
	'since'			=> '05/06/1999',
	'translation_name'	=> 'Notes sur la version',
	'translation_maintainer'=> ['mmenal <mmenal@francemel.com>'],
	'translation_version'	=> '',
	'translation_url'	=> '',
	'translation_source_url'=> '',
	'translation_package'	=> 'boot-floppies',
	'last_translated'	=> '',
},

'system-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux System Administrator\'s Manual',
	'status'		=> 'non-disponible',
},

'network-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Network Administrator\'s Manual',
	'status'		=> 'non-disponible',
},


#
# Hardware Compatibility List
#

'policy' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Policy Manual',
	'version'		=> '2.5.0.0',
	'url'			=> 'http://www.fr.debian.org/doc/debian-policy/',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-policy/debian-policy/policy.sgml',
	'package'		=> 'debian-policy',
	'status'		=> 'en cours de révision',
	'since'			=> '6/04/1999',
	'translation_name'	=> 'Manuel des normes Debian',
	'translation_maintainer'=> ['David Rocher <davroc@hplb.hpl.hp.com>'],
	'translation_version'	=> '2.5.0.0',
	'translation_url'	=> 'http://savage.iut-blagnac.fr/projets/developpement/policy.fr/policy.fr.html/',
	'translation_source_url'=> 'http://savage.iut-blagnac.fr/projets/developpement/policy.fr/policy.fr.sgml',
	'translation_package'	=> '',
	'old_translators'	=> ['Serge Stinckwich <serge@info.unicaen.fr>'],
},

'packaging-manual' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging Manual',
	'sub_name'		=> 'chapter 0 to 14',
	'version'		=> '2.4.1.0',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-policy/packaging-manual/packaging.sgml',
#?!	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/dpkg/dpkg/doc/packaging.sgml',
	'package'		=> 'packaging-manual',
	'status'		=> 'à relire',
	'since'			=> '01/07/1998',
	'translation_name'	=> 'Manuel des paquets Debian',
	'translation_sub_name'	=> 'parties 0 à 14',
	'translation_maintainer'		=> [
					'David Cure <cure@cnam.fr>', 
					'Christian Jacolot <jacolot@ubolib.univ-brest.fr>',
				],
	'translation_version'	=> '',
	'translation_package'	=> '',
},

'developers-reference' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Developer\'s Reference',
	'version'		=> '2.5.0',
	'url'			=> 'http://www.fr.debian.org/doc/packaging-manuals/developers-reference/',
	'package'		=> 'developers-reference',
	'status'		=> 'à réviser',
	'since'			=> '01/07/1998',
	'translation_name'	=> 'Guide de Référence du Développeur Debian',
	'translation_maintainer'=> ['Laurent Picouleau <lcrpic@a2points.com>'],
	'translation_version'	=> '0.1',
	'translation_package'	=> '',
	'old_translators'	=> ['Herve Floch <Herve.Floch@linux.eu.org>'],
},

'maint-guide' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian New Maintainer\'s Guide',
	'status'		=> 'à relire',
	'since'			=> '02/07/1999',
	'translation_maintainer'=> ['Frederic Dumont <Frederic.Dumont@gate71.be>'],
	'translation_url'	=> 'http://www.info.fundp.ac.be/~fdumont/maint-guide_fr.html/index.html',
	'translation_source_url'=> 'http://www.info.fundp.ac.be/~fdumont/maint-guide_fr.sgml',
	'translation_package'	=> '',
	'last_translated'	=> '02/07/1998',
},

'' => {
	'type'			=> 'DDP',
	'name'			=> 'dpkg Internals Manual',
	'version'		=> '1.4.1',
	'url'			=> 'http://www.fr.debian.org/doc/packaging-manuals/dpkg-internals/',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/dpkg/dpkg/doc/internals.sgml',
	'package'		=> 'dpkg-dev',
	'status'		=> 'à traduire',
	'since'			=> '01/08/1998',
	'translation_name'	=> '',
	'translation_sub_name'	=> '',
	'translation_version'	=> '',
	'translation_package'	=> '',
},

'menu' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Menu System',
	'version'		=> '',
	'url'			=> 'http://www.debian.org/doc/packaging-manuals/menu.html/',
	'source_url'		=> '',
	'package'		=> '',
	'status'		=> 'obsolète',
	'since'			=> '14/09/1998',
},

#
# How Software Producers can distribute their products directly in .deb format
#

'?' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction : Making a Debian Package (obsolète)',
	'url'			=> 'http://va.debian.org/~jaldhar/',
	'source_url'		=> '?',
	'status'		=> 'traduction à jour',
	'since'			=> '25/09/1998',
	'translation_name'	=> 'Introduction : Créer un paquet Debian',
	'translation_maintainer'=> ['Frederic Dumont <frederic.dumont@gate71.be>'],
	'translation_version'	=> '',
	'translation_url'	=> 'http://www.debian.org/~clebars/f2dp/docs/debian_package_intro.html/book1.html',
	'translation_source_url'=> 'http://www.debian.org/~clebars/f2dp/docs/debian_package_intro.sgml',
	'translation_package'	=> '',
	'last_translated'	=> '01/07/1998',
},

'programmer' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging HOWTO',
	'status'		=> 'obsolète',
},

'markup' => {
	'type'			=> 'DDP',
	'name'			=> 'Debiandoc-SGML Markup Manual',
	'version'		=> '',
	'package'		=> 'debiandoc-sgml',
	'status'		=> 'traduction à jour',
	'since'			=> '',
	'translation_name'	=> 'Manuel de Debiandoc-SGML',
	'translation_sub_name'	=> '',
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
	'translation_version'	=> '',
	'translation_source_url'=> '',
	'translation_package'	=> 'doc-debian-fr',
	'last_translated'	=> '',
},

# How to get started on a new SGML-based manual
# Debian Documentation Guidelines

# ########################################################################################
#
# Misc
#
# ########################################################################################

'debian-bugs' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian\'s Bug Tracking System',
	'version'		=> '0.2',
	'package'		=> '',
	'status'		=> 'à traduire',
	'since'			=> '01/08/1998',
},

'libc5-libc6-Mini-HOWTO' => {
	'type'			=> '',
	'name'			=> 'libc5-libc6-Mini-HOWTO',
	'sub_name'		=> '',
	'version'		=> '',
	'url'			=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.html',
	'source_url'		=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.sgml',
	'package'		=> '',
	'status'		=> 'traduction à jour',
	'since'			=> '10/08/1998',
	'translation_name'	=> 'libc5-libc6-Mini-HOWTO',
	'translation_sub_name'	=> '',
	'translation_maintainer'		=> ['Philippe CAILLAUD <phil@penguin.infini.fr>'],
	'translation_version'	=> '',
	'translation_url'	=> 'http://www.debian.org/~clebars/f2dp/docs/libc5-libc6-Mini-HOWTO.fr.html',
	'translation_source_url'=> 'http://www.debian.org/~clebars/f2dp/docs/libc5-libc6-Mini-HOWTO.fr.sgml',
	'translation_package'	=> '',
	'last_translated'	=> '10/08/1998',
},

# ########################################################################################
#
# Web
#
# ########################################################################################

'News/1997/index' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '02/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
},

'News/1998/index' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '02/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
},

'News/index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
},

'News/1999/index' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '02/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
},

'News/weekly/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'News/weekly/contributing' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '24/07/1999',
	'translation_maintainer'=> ['Laurent Le Guillou <leguillo@hep.saclay.cea.fr>'],
},

'contact' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '09/08/1998',
},

'donations' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '11/08/1998',
},

'index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Christophe Le Bars <clebars@debian.org>'],
	'last_translated'	=> '27/07/1998',
},

'license' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '11/08/1998',
},

'related_links' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '17/04/1999',
},

'social_contract' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '24/11/1998',
	'translation_maintainer'=> ['Antoine Martin <amartin@atos-group.com>'],
	'last_translated'	=> '01/08/1998',
},

'support' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '11/08/1998',
},

'todo' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '21/07/1999',
	'translation_maintainer'=> ['<magloire@multimania.com>'],
	'last_translated'	=> '21/07/1999',
},

'MailingLists/debian-announce' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '20/08/1998',
	'translation_maintainer'=> ['Frederic Peters <fpeters@multimania.com>'],
	'translation_source_url'=> 'http://www.multimania.com/fpeters/debian/debian-announce.fr',
	'last_translated'	=> '25/03/1999',
},

'MailingLists/subscribe' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '20/08/1998',
	'translation_maintainer'=> ['Frederic Peters <fpeters@multimania.com>'],
	'translation_source_url'=> 'http://www.multimania.com/fpeters/debian/subscribe.fr',
	'last_translated'	=> '25/03/1999',
},

'MailingLists/unsubscribe' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '20/08/1998',
	'translation_maintainer'=> ['Frederic Peters <fpeters@multimania.com>'],
	'translation_source_url'=> 'http://www.multimania.com/fpeters/debian/unsubscribe.fr',
	'last_translated'	=> '25/03/1999',
},

'devel/HOWTO_translate' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '17/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '17/05/1999',
},

'devel/extract_key' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'devel/help' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '12/10/1998',
},

'devel/incoming_mirrors' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '20/12/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
},

'devel/index' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '17/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '17/05/1999',
},

'devel/maintainer_contacts' => {
	'type'			=> 'Web',
	'status'		=> 'non-disponible',
	'since'			=> '01/08/1998',
},

'devel/machines' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '05/07/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '05/07/1999',
},

'devel/people' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'devel/release_info' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '13/07/1999',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '13/07/1999',
},

'devel/rsync_examples' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'devel/HOWTO_work_on_website' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'devel/constitution' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '17/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '17/05/1999',
},

'distrib/ftplist' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '11/07/1999',
	'translation_maintainer'=> ['magloire@multimania.com'],
	'last_translated'	=> '11/07/1999',
},

'distrib/index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '17/04/1999',
},

'distrib/packages' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'translation_maintainer'=> ['Marilleau Hugues <marillea@wotan.iie.cnam.fr>'],
	'since'			=> '28/07/1999',
},

'distrib/vendors' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '01/08/1998',
},

'distrib/cdinfo' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'distrib/books' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'doc/index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '19/03/1999',
},

'events/index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '17/04/1999',
},

'events/1998/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '16/12/1998',
},

'events/1999/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '16/12/1998',
},

'intro/about' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'intro/cn' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'intro/cooperation' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'intro/free' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '22/03/1999',
},

'intro/international' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'intro/license_disc' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'intro/why_debian' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '11/10/1998',
	'translation_version'	=> '1.3',
	'translation_maintainer'=> ['"Philippe Paillé" <valvert@club-internet.fr>'],
	'last_translated'	=> '11/10/1998',
},

'intro/organization' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'translation_maintainer'=> ['Marilleau Hugues <marillea@wotan.iie.cnam.fr>'],
	'since'			=> '28/07/1999',
},

'logos/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '01/08/1998',
},

'mirror/explain' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'mirror/ftpmirror' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'mirror/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '16/12/1998',
},

'mirror/submit' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '02/06/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '02/06/1999',
},

'mirror/types' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'mirror/webmirror' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'mirror/push_server' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'mirror/size' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'ports/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '01/08/1998',
},

'security/index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '17/04/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '17/04/1999',
},

'vote/index' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/05/1999',
	'translation_maintainer'=> ['Christian Couder <chcouder@mail.club-internet.fr>'],
	'last_translated'	=> '25/05/1999',
},

'partners/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'partners/partners-form' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'partners/partners' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'partners/thankyou' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'y2k/extra' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'y2k/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/Access' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/Developer' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/Reporting' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/index' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/server-control' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/server-refcard' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'Bugs/server-request' => {
	'type'			=> 'Web',
	'status'		=> 'à traduire',
	'since'			=> '25/05/1999',
},

'releases/hamm/HOWTO.upgrade' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '10/08/1998',
	'translation_maintainer'=> ['Philippe Caillaud <pcaillaud@infini.fr>'],
	'last_translated'	=> '08/08/1998',
},

'releases/hamm/errata' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '28/11/1998',
	'translation_maintainer'=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '21/09/1998',
},

'releases/slink/index' => {
	'type'			=> 'Web',
	'status'		=> 'traduction à jour',
	'since'			=> '16/03/1999',
	'translation_maintainer'=> ['Frederic Pascal <frederic.pascal@maisel-gw.enst-bretagne.fr>'],
	'last_translated'	=> '16/03/1999',
},

'releases/slink/running-kernel-2.2' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '23/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
},

'releases/potato/index' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '23/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
},

'releases/index' => {
	'type'			=> 'Web',
	'status'		=> 'en cours de traduction',
	'since'			=> '23/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
},

'search' => {
	'type'			=> 'Web',
	'status'		=> 'à relire',
	'since'			=> '25/07/1999',
	'translation_maintainer'=> ['Marant Jerome <jerome_marant@hotmail.com>'],
	'last_translated'	=> '25/07/1999',
},

};
