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
	'url'			=> 'http://www.debian.org/doc/project-history/',
	'cvs-url'		=> 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/project-history'

},

'faq' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux FAQ',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
},

#
# Debian-user FAQ-O-MATIC ?
# Linux Magazines ?
#

'book-suggestions' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Book Suggestions',
	'status'		=> 1,
	'url'			=> 'http://www.debian.org/doc/book-suggestions/',
	'cvs-url'		=> 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/book-suggestions/'
},

'meta' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian META Manual',
	'author'		=> 'Ardo van Rangelrooij',
	'status'		=> 1,
	'url'			=> 'http://www.debian.org/doc/meta/',
	'cvs-url'		=> 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/meta/'
},

'dictionary' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Dictionary',
	'status'		=> 1,
	'url'                   => 'http://www.debian.org/doc/dictionary/',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/dictionary/'
},

'tutorial' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Tutorial',
	'revision'		=> '',
	'url'			=> 'http://www.debian.org/~hp/tutorial/debian-tutorial.html',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/tutorial/tutorial/debian-tutorial.sgml',
	'package'		=> '',
},

'user' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian User Reference Manual',
	'status'		=> 1,
	'url'                   => 'http://www.debian.org/doc/users_manual/',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/users_manual/'
},

'system-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux System Administrator\'s Manual',
	'status'		=> 1,
'url'                   => 'http://www.debian.org/doc/system-administrator/',
'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/system-administrator/'
},

'network-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Network Administrator\'s Manual',
	'status'		=> 1,
'url'                   => 'http://www.debian.org/doc/network-administrator/',
'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/network-administrator/'
},

#
# Debian Tips?
#

'install' => {
	'type'			=> 'boot',
	'name'			=> 'Debian Installation Manual',
	'revision'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/install.en.html',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/install.sgml',
	'package'		=> 'boot-floppies',
},

'dselect-beginner' => {
	'type'			=> 'boot',
	'name'			=> 'Dselect beginner guide',
	'revision'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/dselect-beginner.en.html',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/dselect-beginner.sgml',
	'package'		=> 'boot-floppies',
},

'release-notes' => {
	'type'			=> 'boot',
	'name'			=> 'Release Notes',
	'revision'		=> '2.1',
	'url'			=> 'http://www.debian.org/releases/slink/i386/release-notes/',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-boot/boot-floppies/documentation/release-notes.sgml',
	'package'		=> 'boot-floppies',
},



'policy' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Policy Manual',
	'revision'		=> '2.5.0.0',
	'url'			=> 'http://www.debian.org/oc/debian-policy/',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-policy/debian-policy/policy.sgml',
	'package'		=> 'debian-policy',
},

'packaging-manual' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging Manual',
	'sub_name'		=> 'chapter 0 to 14',
	'revision'		=> '2.4.1.0',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/debian-policy/packaging-manual/packaging.sgml',
},

'developers-reference' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Developer\'s Reference',
	'revision'		=> '2.5.0',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/developers-reference/',
	'url'			=> 'http://www.debian.org/doc/packaging-manuals/developers-reference/',
	'package'		=> 'developers-reference',
},

'maint-guide' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian New Maintainer\'s Guide',
	'url'			=> 'http://www.debian.org/doc/maint-guide/',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/ddp/manuals.sgml/maint-guide/',
},

'internals' => {
	'type'			=> 'DDP',
	'name'			=> 'dpkg Internals Manual',
	'revision'		=> '1.2',
	'url'			=> 'http://www.debian.org/doc/packaging-manuals/dpkg-internals/',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/dpkg/dpkg/doc/internals.sgml',
	'package'		=> 'dpkg-dev',
},

'menu' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Menu System',
	'revision'		=> '',
	'url'			=> 'http://www.debian.org/doc/packaging-manuals/menu.html/',
	'cvs_url'		=> 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/menu/',
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
	'status'		=> 7,
},

'i18n' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction to internationalization',
	'status'		=> 1,
	'url'                   => 'http://www.debian.org/doc/intro-i18n/',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/intro-i18n/'
},


# How to get started on a new SGML-based manual
# Debian Documentation Guidelines

'markup' => {
	'type'			=> 'DDP',
	'name'			=> 'Debiandoc-SGML Markup Manual',
	'revision'		=> '',
	'package'		=> 'debiandoc-sgml',
	'url'                   => 'http://www.debian.org/doc/debiandoc-sgml-doc/',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/debiandoc-sgml-doc/'

},

'docstartup' => {
        'type'                  => 'DDP',
        'name'                  => 'Debiandoc Starup',
        'revision'              => '',
        'url'                   => 'http://www.debian.org/doc/debiandoc-startup/',
        'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/debiandoc-startup/'

},



# ########################################################################################
#
# Misc
#
# ########################################################################################

'newbie' => {
	'type'			=> 'DDP',
	'name'			=> 'Documentation for new users',
	'url'                   => 'http://www.debian.org/doc/newbie-doc/',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/newbie-doc/'

},
'debian-bugs' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian\'s Bug Tracking System',
	'revision'		=> '0.2',
	'package'		=> 'doc-debian',
	'url'                   => 'http://www.debian.org/doc/debian-bugs//',
	'cvs-url'               => 'http://www.debian.org/cgi-bin/cvsweb/manuals.sgml/debian-bugs//'

},

'libc5-libc6-Mini-HOWTO' => {
	'type'			=> '',
	'name'			=> 'libc5-libc6-Mini-HOWTO',
	'sub_name'		=> '',
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

