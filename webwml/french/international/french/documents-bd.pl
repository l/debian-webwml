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

# ########################################################################################
#
# GPL Books
#
# ########################################################################################

'book-gtiau' => {
	'type'			=> 'none',
	'name'			=> 'Debian GNU/Linux: Guide to Installation and Usage',
	'url'			=> 'http://www.newriders.com/debian/html/noframes/',
},

# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

'project-history' => {
	'type'			=> 'DDP',
	'name'			=> 'The Debian Project History',
	'author'		=> 'Will Lowe',
	'revision'		=> '1.1.1',
	'status'		=> 1,
	'lines'			=> 336,
},

'faq' => {
	'type'			=> 'DDP',
	'author'		=> 'Josip Rodin',
	'name'			=> 'Debian GNU/Linux FAQ',
	'package'		=> 'doc-debian',
},

'constitution' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Constitution',
	'status'		=> 0,
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 603,
},

'bug-log-access' => {
	'type'			=> 'DDP',
	'name'			=> 'Accessing bug reports in the tracking system logs',
	'status'		=> 0,
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 24,
},
'mailing-lists' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction to the Debian mailing lists',
	'status'		=> 0,
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 906,
},
'bug-reporting' => {
	'type'			=> 'DDP',
	'name'			=> 'How to report a bug in Debian',
	'status'		=> 0,
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 202,
},
'source-unpack' => {
	'type'			=> 'DDP',
	'name'			=> 'How to unpack a Debian source package',
	'status'		=> 0,
	'url'			=> '#',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 33,
},

#
# Debian-user FAQ-O-MATIC ?
# Linux Magazines ?
#

'book-suggestions' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Book Suggestions',
	'status'		=> 1,
},

'meta' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian META Manual',
	'author'		=> 'Ardo van Rangelrooij',
	'status'		=> 1,
	'lines'			=> 398,
	'lines'			=> 407
},

'dictionary' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Dictionary',
	'status'		=> 1,
	'lines'			=> 346,
},

'tutorial' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Tutorial',
	'revision'		=> '2.1',
	'lines'			=>  6131,
	'url'			=> 'http://www.debian.org/~hp/tutorial/debian-tutorial.html',
},

'user' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian User Reference Manual',
	'status'		=> 1,
},

'system-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux System Administrator\'s Manual',
	'status'		=> 1,
	'lines'			=> 2322,
},

'network-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Network Administrator\'s Manual',
	'status'		=> 1,
	'lines'			=> 2086,
},

#
# Debian Tips?
#

'install' => {
	'type'			=> 'boot',
	'name'			=> 'Debian Installation Manual',
	'revision'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/install.en.html',
	'cvs_url'		=> 'http://cvs.debian.org/boot-floppies/documentation/install.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'dselect-beginner' => {
	'type'			=> 'boot',
	'name'			=> 'Dselect beginner guide',
	'revision'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/dselect-beginner.en.html',
	'cvs_url'		=> 'http://cvs.debian.org/boot-floppies/documentation/dselect-beginner.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'release-notes' => {
	'type'			=> 'boot',
	'name'			=> 'Release Notes',
	'revision'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/release-notes/',
	'cvs_url'		=> 'http://cvs.debian.org/boot-floppies/documentation/release-notes.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},



'policy' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Policy Manual',
	'revision'		=> '3.5.4.0',
	'url'			=> 'http://www.debian.org/doc/debian-policy/',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/debian-policy/debian-policy/debian-policy.sgml?cvsroot=debian-doc',
	'package'		=> 'debian-policy',
},

'packaging-manual' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging Manual',
	'revision'		=> '2.4.1.0',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/debian-policy/packaging-manual/packaging.sgml?cvsroot=debian-doc',
	'package'		=> 'debian-policy',
},

'developers-reference' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Developer\'s Reference',
	'revision'		=> '2.5.0',
	'lines'			=> 1951,
	'package'		=> 'developers-reference',
},

'maint-guide' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian New Maintainer\'s Guide',
	'lines'			=> 1448,
},

'internals' => {
	'type'			=> 'DDP',
	'name'			=> 'dpkg Internals Manual',
	'revision'		=> '1.5',
	'url'			=> 'http://www.debian.org/~elphick/manuals.html/dpkg-internals/',
	'cvs_url'		=> 'http://cvs.debian.org/dpkg/dpkg/doc/internals.sgml?cvsroot=dpkg',
	'package'		=> 'dpkg-dev',
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

'programmer' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging HOWTO',
	'status'		=> 1,
	'lines'			=> 368,
},

'intro-i18n' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction to internationalization',
	'status'		=> 1,
	'lines'			=> 1974,
},


'sgml-howto' => {
	'type'			=> 'DDP',
	'name'			=> 'The Debian SGML/XML HOWTO',
	'status'		=> 1,
},


# How to get started on a new SGML-based manual
# Debian Documentation Guidelines

'markup' => {
	'type'			=> 'DDP',
	'name'			=> 'Debiandoc-SGML Markup Manual',
	'revision'		=> '',
	'package'		=> 'debiandoc-sgml',
	'url'                   => 'http://www.debian.org/~elphick/ddp/manuals.html/debiandoc-sgml-doc/',
},

'debiandoc-startup' => {
        'type'                  => 'DDP',
        'name'                  => 'Debiandoc Starup',
        'revision'              => '',
        'url'                   => '?',
},



# ########################################################################################
#
# Misc
#
# ########################################################################################

'newbie-doc' => {
	'type'			=> 'DDP',
	'name'			=> 'Documentation for new users',
	'lines'			=> 3803,
	'url'                   => '?',
},

'debian-bugs' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian\'s Bug Tracking System',
	'revision'		=> '0.2',
	'package'		=> 'doc-debian',
	'lines'			=> 900,
},

'libc5-libc6-Mini-HOWTO' => {
	'type'			=> '',
	'name'			=> 'libc5-libc6-Mini-HOWTO',
	'revision'		=> '',
	'url'			=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.html',
	'source_url'		=> 'http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.sgml',
	'package'		=> '',
}

# ########################################################################################
#
# Web
#
# ########################################################################################

# This should be automatically generated

};

