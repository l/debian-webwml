#!/usr/bin/perl


# This document database should be generated automatically
# from the information in the DDP

$translations = {
#
#

#'key'			=> {
#	'type'			=> '',  # one of : DDP, book, web, none, boot
#	'name'			=> '',
#	'sub_name'		=> '',
#	'author'		=> '',
#	'revision'		=> '',
#	'url'			=> '',
#	'cvs_url'		=> '',
#	'source_url'		=> '',
#	'package'		=> '',
#	'status'		=> '',
# Use numbers instead of text since it makes translations easier
#		'not-available' - 0
#		'not translated' - 1
#		'being translated' - 2
#		'needs revision' - 3 
#		'translation updated', - 4
#               'needs check' - 5
#               'being revised' -  6
#               'obsolete' - 7
#               'unknown' - 8
#
#	'since'			=> '', # when did the current status change
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
#	'old_translators'	=> [],
#},

# By default
#	'url'	=> 'http://www.debian.org/doc/manuals/$key/',

# ##############################################################################
#
# GPL Books
#
# ##############################################################################

'book-gtiau' => {
	'status'		=> 0,
	'type'			=> 'none',
	'name'			=> 'Debian GNU/Linux: Guide to Installation and Usage',
	'url'			=> 'http://www.newriders.com/debian/html/noframes/',
},

# ##############################################################################
#
# Debian Documentation Project
#
# ##############################################################################

'book-suggestions' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Book Suggestions',
},

'debian-bugs' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'Debian\'s Bug Tracking System',
	'revision'		=> '0.2',
	'package'		=> 'doc-debian',
	'lines'			=> 900,
	'url'			=> 'http://www.debian.org/doc/manuals/debian-bugs/',
},

'developers-reference' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Developer\'s Reference',
	'revision'		=> '2.5.0',
	'lines'			=> 1951,
	'package'		=> 'developers-reference',
	'url'			=> 'http://www.debian.org/doc/developers-reference/',
},

'dictionary' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Dictionary',
	'lines'			=> 346,
},

'faq' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux FAQ',
	'author'		=> 'Josip Rodin',
	'package'		=> 'doc-debian',
	'url'			=> 'http://www.debian.org/doc/manuals/debian-faq/',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/faq/?cvsroot=debian-doc',
	'source_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/faq/debian-faq.sgml?cvsroot=debian-doc',
},

'intro-i18n' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction to internationalization',
	'status'		=> 1,
	'lines'			=> 1974,
},

'java-faq' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Java FAQ',
	'status'		=> 1,
	'author'		=> 'Javier Fernández-Sanguino Peña',
	'lines'			=> 1034,
	'url'			=> 'http://www.debian.org/doc/manuals/debian-java-faq/',
},

'maint-guide' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian New Maintainer\'s Guide',
	'lines'			=> 1448,
	'package'		=> 'maint-guide',
	'url'			=> 'http://www.debian.org/doc/maint-guide/',
},

'meta' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian META Manual',
	'author'		=> 'Ardo van Rangelrooij',
	'lines'			=> 398,
},

'network-administrator' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Network Administrator\'s Manual',
	'lines'			=> 2086,
},

'newbie-doc' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'Documentation for new users',
	'lines'			=> 3803,
	'url'                   => '?',
},

'programmer' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging HOWTO',
	'status'		=> 1,
	'lines'			=> 368,
},

'project-history' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'The Debian Project History',
	'author'		=> 'Will Lowe',
	'revision'		=> '1.2.0',
	'lines'			=> 624,
},

'securing-debian-howto' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Securing Debian HOWTO',
	'revision'		=> '1.94',
	'lines'			=> 3584,
	'source_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/securing-howto/securing-debian-howto.sgml?cvsroot=debian-doc',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/securing-howto/?cvsroot=debian-doc',
},

'sgml-howto' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'The Debian SGML/XML HOWTO',
},

'system-administrator' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux System Administrator\'s Manual',
	'lines'			=> 2322,
},

'tutorial' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian Tutorial',
	'revision'		=> '2.1',
	'lines'			=>  6131,
	'source_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/tutorial/debian-tutorial.sgml?cvsroot=debian-doc',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/tutorial/?cvsroot=debian-doc',
},

'user' => {
	'status'		=> 1,
	'type'			=> 'DDP',
	'name'			=> 'Debian User Reference Manual',
},

# ##############################################################################
#
# Major Documents
#
# ##############################################################################

'policy' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Policy Manual',
	'revision'		=> '3.5.6.0',
	'url'			=> 'http://www.debian.org/doc/debian-policy/',
	'cvs_url'		=> 'http://cvs.debian.org/debian-policy/?cvsroot=debian-policy',
	'source_url'		=> 'http://cvs.debian.org/debian-policy/policy.sgml?cvsroot=debian-policy',
	'package'		=> 'debian-policy',
},

'packaging-manual' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging Manual',
	'revision'		=> '2.4.1.0',
	'cvs_url'		=> 'http://cvs.debian.org/packaging-manual/?cvsroot=debian-policy',
	'source_url'		=> 'http://cvs.debian.org/packaging-manual/packaging.sgml?cvsroot=debian-policy',
	'package'		=> 'debian-policy',
},

# ##############################################################################
#
# Debian Installation Documentation
#
# ##############################################################################

'install' => {
	'type'			=> 'boot',
	'name'			=> 'Debian Installation Manual',
	'revision'		=> '2.2',
	'url'			=> 'http://www.debian.org/releases/potato/i386/install.en.html',
	'cvs_url'		=> 'http://cvs.debian.org/boot-floppies/documentation/install.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'release-notes' => {
	'type'			=> 'boot',
	'name'			=> 'Release Notes',
	'revision'		=> '2.2',
	'url'			=> 'http://www.debian.org/releases/potato/i386/release-notes/',
	'cvs_url'		=> 'http://cvs.debian.org/boot-floppies/documentation/release-notes.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'dselect-beginner' => {
	'type'			=> 'boot',
	'name'			=> 'Dselect beginner guide',
	'revision'		=> '2.2',
	'url'			=> 'http://www.debian.org/releases/potato/i386/dselect-beginner.en.html',
	'cvs_url'		=> 'http://cvs.debian.org/boot-floppies/documentation/dselect-beginner.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'internals' => {
	'type'			=> 'DDP',
	'name'			=> 'dpkg Internals Manual',
	'revision'		=> '1.5',
	'url'			=> 'http://www.debian.org/doc/packaging-manuals/dpkg-internals/',
	'source_url'		=> 'http://cvs.debian.org/dpkg/doc/internals.sgml?cvsroot=dpkg',
	'cvs_url'		=> 'http://cvs.debian.org/dpkg/doc/internals.sgml?cvsroot=dpkg',
	'package'		=> 'dpkg-doc',
},

'menu' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Menu System',
	'revision'		=> '',
	'url'			=> 'http://www.debian.org/doc/packaging-manuals/menu.html/',
	'package'		=> 'menu',
	'status'		=> 7,
},

#
# How Software Producers can distribute their products directly in .deb format
#

'making-deb' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction : Making a Debian Package',
	'url'			=> 'http://va.debian.org/~jaldhar/',
	'cvs_url'		=> '?',
	'status'		=> 7,
},



# ##############################################################################
#
# Misc
#
# ##############################################################################

'libc5-libc6-Mini-HOWTO' => {
	'type'			=> '',
	'name'			=> 'libc5-libc6-Mini-HOWTO',
	'revision'		=> '',
	'url'			=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.html',
	'source_url'		=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.sgml',
	'package'		=> '',
},

# How to get started on a new SGML-based manual
# Debian Documentation Guidelines

'markup' => {
	'type'			=> 'DDP',
	'name'			=> 'Debiandoc-SGML Markup Manual',
	'revision'		=> '',
	'package'		=> 'debiandoc-sgml-doc',
	'url'                   => '?',
},

'debiandoc-startup' => {
	'status'		=> 0,
        'type'                  => 'DDP',
        'name'                  => 'Debiandoc Starup',
        'revision'              => '',
        'url'                   => '?',
},

'constitution' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'Debian Constitution',
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 603,
},

'bug-log-access' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'Accessing bug reports in the tracking system logs',
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 24,
},

'mailing-lists' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'Introduction to the Debian mailing lists',
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 906,
},

'bug-reporting' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'How to report a bug in Debian',
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 202,
},

'source-unpack' => {
	'status'		=> 0,
	'type'			=> 'DDP',
	'name'			=> 'How to unpack a Debian source package',
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 33,
},

};

