#!/usr/bin/perl

$translations = [

{
	'type'			=> '',
	'key'			=> '',
	'name'			=> '',
	'sub_name'		=> '',
	'author'		=> '',
	'version'		=> '',
	'url'			=> '',
	'source_url'		=> '',
	'package'		=> '',
#	'status'		=> 'traduction � jour',
	'since'			=> '',
	'translation_name'	=> '',
	'translation_sub_name'	=> '',
	'translators'		=> [
					'', 
				],
	'translation_version'	=> '',
	'translation_url'	=> '',
	'translation_source_url'=> '',
	'translation_package'	=> '',
	'last_translated'	=> '',
	'old_translators'	=> [],
},

# Quel est le statut actuel de ta traduction?

# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

{
	'type'			=> 'DDP',
	'key'			=> 'project-history',
	'name'			=> 'The Debian Project History',
	'status'		=> 'non-traduit',
},

{
	'type'			=> 'DDP',
	'key'			=> 'faq',
	'name'			=> 'Debian GNU/Linux FAQ',
	'source_url'		=> '?',
	'package'		=> 'doc-debian',
	'status'		=> 'en cours de traduction',
	'since'			=> '21/07/1998',
	'translation_name'	=> 'FAQ Debian GNU/Linux',
	'translators'		=> ['Philippe Caillaud <phil@penguin.infini.fr>'],
	'ping'			=> '28/11/1998',
	'translation_version'	=> '',
	'translation_package'	=> '',
	'old_translators'	=> ['Vincent Renardias <vincent@waw.com>'],
},

#
# Debian-user FAQ-O-MATIC ?
# Linux Magazines ?
#

{
	'type'			=> 'DDP',
	'key'			=> 'book-suggestions',
	'name'			=> 'Debian GNU/Linux Book Suggestions',
	'status'		=> 'non-disponible',
},

{
	'type'			=> 'DDP',
	'key'			=> 'meta',
	'name'			=> 'Debian META Manual',
	'status'		=> 'non-disponible',
},

{
	'type'			=> 'DDP',
	'key'			=> 'dictionary',
	'name'			=> 'Debian GNU/Linux Dictionary',
	'status'		=> 'non-disponible',
},

{
	'type'			=> 'DDP',
	'key'			=> '',
	'name'			=> 'Debian Tutorial',
	'version'		=> '',
	'url'			=> 'http://www.debian.org/~hp/tutorial/debian-tutorial.html',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/tutorial/tutorial/debian-tutorial.sgml',
	'package'		=> '',
	'status'		=> 'non-traduit',
	'since'			=> '17/08/1998',
	'translation_name'	=> 'Tutorial Debian',
	'translation_sub_name'	=> '',
	'translators'		=> [],
	'ping'			=> '28/11/1998',
	'translation_version'	=> '',
	'translation_package'	=> '',
	'old_translators'	=> ['Lo�c Martin <lomartin@dejanews.com>'],
},

{
	'type'			=> 'DDP',
	'key'			=> 'user',
	'name'			=> 'Debian User Reference Manual',
	'status'		=> 'non-disponible',
},

#
# Debian Tips?
#

#{
#	'type'			=> 'DDP',
#	'key'			=> '',
#	'name'			=> 'Debian Release Notes',
#	'url'			=> 'http://happy.digitaldune.net/~astala/Release-notes-2.0.html/index.html',
#	'status'		=> 'non-disponible',
#},

{
	'type'			=> 'DDP',
	'key'			=> '',
	'name'			=> 'Debian Installation Manual',
	'version'		=> '2.0',
	'url'			=> 'http://www.igoria.net/install/install.html',
	'source_url'		=> 'http://www.igoria.net/install/install.sgml',
	'package'		=> 'boot-floppies',
	'status'		=> 'traduction � jour',
	'since'			=> '28/10/1998',
	'translation_name'	=> 'Manuel d\'installation de Debian',
	'translators'		=> ['Christophe Le Bars <clebars@debian.org>'],
	'translation_version'	=> '2.0',
	'translation_url'	=> 'http://www.debian.org/~clebars/docs-2.0/install.fr.html',
	'translation_source_url'=> 'http://www.debian.org/~clebars/docs-2.0/install.fr.sgml',
	'translation_package'	=> 'doc-debian-fr',
	'last_translated'	=> '27/07/1998',
},

{
	'type'			=> 'DDP',
	'key'			=> 'system-administrator',
	'name'			=> 'Debian GNU/Linux System Administrator\'s Manual',
	'status'		=> 'non-disponible',
},

{
	'type'			=> 'DDP',
	'key'			=> 'network-administrator',
	'name'			=> 'Debian GNU/Linux Network Administrator\'s Manual',
	'status'		=> 'non-disponible',
},


#
# Hardware Compatibility List
#

{
	'type'			=> 'DDP',
	'key'			=> 'policy',
	'name'			=> 'Debian Policy Manual',
	'version'		=> '2.5.0.0',
	'url'			=> 'http://www.fr.debian.org/doc/debian-policy/',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-policy/debian-policy/policy.sgml',
	'package'		=> 'debian-policy',
	'status'		=> 'en relecture',
	'since'			=> '30/11/1998',
	'translation_name'	=> 'Manuel des normes Debian',
	'translation_sub_name'	=> 'parties 4 et 5',
	'translators'		=> ['David Rocher <rocher@mail.dotcom.fr>'],
	'translation_version'	=> '2.5.0.0',
	'translation_package'	=> '',
	'old_translators'	=> ['Serge Stinckwich <serge@info.unicaen.fr>'],
},

{
	'type'			=> 'DDP',
	'key'			=> 'packaging-manual',
	'name'			=> 'Debian Packaging Manual',
	'sub_name'		=> 'chapter 0 to 14',
	'version'		=> '2.4.1.0',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-policy/packaging-manual/packaging.sgml',
#?!	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/dpkg/dpkg/doc/packaging.sgml',
	'package'		=> 'packaging-manual',
	'status'		=> 'en relecture',
	'since'			=> '01/07/1998',
	'translation_name'	=> 'Manuel des paquets Debian',
	'translation_sub_name'	=> 'parties 0 � 14',
	'translators'		=> [
					'David Cure <cure@cnam.fr>', 
					'Christian Jacolot <jacolot@ubolib.univ-brest.fr>',
				],
	'translation_version'	=> '',
	'translation_package'	=> '',
},

{
	'type'			=> 'DDP',
	'key'			=> 'developers-reference',
	'name'			=> 'Debian Developer\'s Reference',
	'version'		=> '2.5.0',
	'url'			=> 'http://www.fr.debian.org/doc/packaging-manuals/developers-reference/',
	'package'		=> 'developers-reference',
	'status'		=> 'traduction � jour',
	'since'			=> '01/07/1998',
	'translation_name'	=> 'Guide de R�f�rence du D�veloppeur Debian',
	'translators'		=> ['Laurent Picouleau <lcrpic@a2points.com>'],
	'translation_version'	=> '0.1',
	'translation_package'	=> '',
	'old_translators'	=> ['Herve Floch <Herve.Floch@linux.eu.org>'],
},

{
	'type'			=> 'DDP',
	'key'			=> '',
	'name'			=> 'Debian New Maintainer\'s Guide',
	'status'		=> 'non-disponible',
},

{
	'type'			=> 'DDP',
	'key'			=> '',
	'name'			=> 'dpkg Internals Manual',
	'version'		=> '1.4.1',
	'url'			=> 'http://www.fr.debian.org/doc/packaging-manuals/dpkg-internals/',
	'source_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/dpkg/dpkg/doc/internals.sgml',
	'package'		=> 'dpkg-dev',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
	'translation_name'	=> '',
	'translation_sub_name'	=> '',
	'translation_version'	=> '',
	'translation_package'	=> '',
},

{
	'type'			=> 'DDP',
	'key'			=> 'menu',
	'name'			=> 'Debian Menu System',
	'version'		=> '',
	'package'		=> '',
	'status'		=> 'non-traduit',
	'since'			=> '14/09/1998',
},

#
# How Software Producers can distribute their products directly in .deb format
#

{
	'type'			=> 'DDP',
	'key'			=> '',
	'name'			=> 'Introduction : Making a Debian Package (obsol�te)',
	'url'			=> 'http://va.debian.org/~jaldhar/',
	'source_url'		=> '?',
	'status'		=> 'traduction � jour',
	'since'			=> '25/09/1998',
	'translation_name'	=> 'Introduction : Cr�er un paquet Debian',
	'translators'		=> ['Frederic Dumont <frederic.dumont@gate71.be>'],
	'translation_version'	=> '',
	'translation_url'	=> 'http://www.debian.org/~clebars/f2dp/docs/debian_package_intro.html/book1.html',
	'translation_source_url'=> 'http://www.debian.org/~clebars/f2dp/docs/debian_package_intro.sgml',
	'translation_package'	=> '',
	'last_translated'	=> '01/07/1998',
},

{
	'type'			=> 'DDP',
	'key'			=> 'programmer',
	'name'			=> 'Debian Packaging HOWTO',
	'status'		=> 'non-disponible',
},

{
	'type'			=> 'DDP',
	'key'			=> 'markup',
	'name'			=> 'Debiandoc-SGML Markup Manual',
	'version'		=> '',
	'package'		=> 'debiandoc-sgml',
	'status'		=> 'traduction � jour',
	'since'			=> '',
	'translation_name'	=> 'Manuel de Debiandoc-SGML',
	'translation_sub_name'	=> '',
	'translators'		=> ['Christophe Le Bars <clebars@debian.org>'],
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

{
	'type'			=> 'DDP',
	'key'			=> 'debian-bugs',
	'name'			=> 'Debian\'s Bug Tracking System',
	'version'		=> '0.2',
	'package'		=> '',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> '',
	'key'			=> '',
	'name'			=> 'Dselect beginner guide',
	'sub_name'		=> '',
	'author'		=> '',
	'version'		=> '',
	'url'			=> 'ftp://ftp.us.debian.org/debian/stable/disks-i386/current/dselect.beginner.6.txt',
	'source_url'		=> '',
	'package'		=> '',
	'status'		=> 'traduction � jour',
	'since'			=> '',
	'translation_name'	=> 'Dselect : le guide du d�butant',
	'translation_sub_name'	=> '',
	'translators'		=> ['Laurent Picouleau <lcrpic@a2points.com>'],
	'translation_version'	=> '',
	'translation_url'	=> 'http://www.debian.org/~clebars/docs-1.3/dselect.beginner.6.fr.txt',
	'translation_source_url'=> '',
	'translation_package'	=> 'doc-debian-fr',
	'last_translated'	=> '',
},

{
	'type'			=> '',
	'key'			=> '',
	'name'			=> 'libc5-libc6-Mini-HOWTO',
	'sub_name'		=> '',
	'author'		=> '',
	'version'		=> '',
	'url'			=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.html',
	'source_url'		=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.sgml',
	'package'		=> '',
	'status'		=> 'traduction � jour',
	'since'			=> '10/08/1998',
	'translation_name'	=> 'libc5-libc6-Mini-HOWTO',
	'translation_sub_name'	=> '',
	'translators'		=> ['Philippe CAILLAUD <phil@penguin.infini.fr>'],
	'translation_version'	=> '',
	'translation_url'	=> 'http://www.debian.org/~clebars/f2dp/docs/libc5-libc6-Mini-HOWTO.fr.html',
	'translation_source_url'=> 'http://www.debian.org/~clebars/f2dp/docs/libc5-libc6-Mini-HOWTO.fr.sgml',
	'translation_package'	=> '',
	'last_translated'	=> '10/08/1998',
},

{
	'type'			=> '',
	'key'			=> '',
	'name'			=> 'debian-organisation',
	'version'		=> '',
	'url'			=> 'http://www.chiark.greenend.org.uk/~ian/debian-organisation.html',
	'source_url'		=> '',
	'package'		=> '',
	'status'		=> 'non-traduit',
	'since'			=> '26/09/1998',
	'translation_name'	=> '',
#	'translators'		=> ['Martin Quinson <mquinson@zeppelin-cb.de>'],
	'translators'		=> [''],
	'ping'			=> '28/11/1998',
	'translation_version'	=> '0.8',
	'translation_url'	=> '',
	'translation_source_url'=> '',
	'translation_package'	=> '',
},

# ########################################################################################
#
# Web
#
# ########################################################################################

{
	'type'			=> 'Web',
	'key'			=> 'contact',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '09/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'donations',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '11/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'index',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Christophe Le Bars <clebars@debian.org>'],
	'last_translated'	=> '27/07/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'license',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '11/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'related_links',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'social_contract',
	'status'		=> 'traduction � jour',
	'since'			=> '24/11/1998',
	'translators'		=> ['Antoine Martin <amartin@atos-group.com>'],
	'last_translated'	=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'support',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '11/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'todo',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> '2.0/2.0beta_CD',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> '2.0/HOWTO.upgrade',
	'status'		=> 'en relecture',
	'since'			=> '10/08/1998',
	'translators'		=> ['Philippe Caillaud <pcaillaud@infini.fr>'],
	'last_translated'	=> '08/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> '2.0/errata',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '21/09/1998',
},

{
	'type'			=> 'Web',
	'key'			=> '2.0/index',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> '2.0/updates',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'News/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'News/1997/',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'News/1998/',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'MailingLists/debian-announce',
	'status'		=> 'en cours de traduction',
	'since'			=> '20/08/1998',
	'translators'		=> ['Frederic Peters <fpeters@multimania.com>'],
},

{
	'type'			=> 'Web',
	'key'			=> 'MailingLists/subscribe',
	'status'		=> 'en cours de traduction',
	'since'			=> '20/08/1998',
	'translators'		=> ['Frederic Peters <fpeters@multimania.com>'],
},

{
	'type'			=> 'Web',
	'key'			=> 'MailingLists/unsubscribe',
	'status'		=> 'en cours de traduction',
	'since'			=> '20/08/1998',
	'translators'		=> ['Frederic Peters <fpeters@multimania.com>'],
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/HOWTO_translate',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/extract_key',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/help',
	'status'		=> 'traduction � jour',
	'since'			=> '28/11/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
	'last_translated'	=> '12/10/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/incoming_mirrors',
	'status'		=> 'en cours de traduction',
	'since'			=> '13/10/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/index',
	'status'		=> 'non-traduit',
	'since'			=> '11/08/1998',
	'translators'		=> ['Christophe Le Bars <clebars@debian.org>'],
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/maintainer_contacts',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/mirror',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/mirror_submit',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/people',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/release_info',
	'status'		=> 'en cours de traduction',
	'since'			=> '13/10/1998',
	'translators'		=> ['Norbert Bottlaender-Prier <norbert@uni.de>'],
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/rsync_examples',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/HOWTO_work.on.website',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'devel/constitution',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'distrib/ftplist',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'distrib/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'distrib/packages',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'distrib/vendors',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'doc/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'events/index',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'events/1998/',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'events/1999/',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/about',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/cn',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/cooperation',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/free',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/international',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/license_disc',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'intro/why_debian',
	'status'		=> 'en relecture',
	'since'			=> '11/10/1998',
	'translation_version'	=> '1.3',
	'translators'		=> ['"Philippe Paill�" <valvert@club-internet.fr>'],
	'last_translated'	=> '11/10/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'logos/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'logos/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'mirror/index',
	'status'		=> 'non-traduit',
	'since'			=> '16/12/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'ports/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'security/index',
	'status'		=> 'non-traduit',
	'since'			=> '01/08/1998',
},

{
	'type'			=> 'Web',
	'key'			=> 'vote/index',
	'status'		=> 'non-traduit',
	'since'			=> '12/16/1998',
},

];
