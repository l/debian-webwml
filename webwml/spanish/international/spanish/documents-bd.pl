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
	'url'			=> 'https://www.debian.org/doc/manuals/project-history/',
	'cvs-url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/project-history/?cvsroot=debian-doc'

},

'faq' => {
	'type'			=> 'DDP',
	'author'		=> 'Josip Rodin',
	'name'			=> 'Debian GNU/Linux FAQ',
	'url'			=> 'https://www.debian.org/doc/manuals/debian-faq/',
	'cvs-url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/faq/?cvsroot=debian-doc',
	'package'		=> 'doc-debian',
},

'constitution' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Constitution',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 603,
},

'bug-log-access' => {
	'type'			=> 'DDP',
	'name'			=> 'Accessing bug reports in the tracking system logs',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 24,
},
'mailing-lists' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction to the Debian mailing lists',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 906,
},
'bug-reporting' => {
	'type'			=> 'DDP',
	'name'			=> 'How to report a bug in Debian',
	'cvs_url'		=> '?',
	'package'		=> 'doc-debian',
	'lines'			=> 202,
},
'source-unpack' => {
	'type'			=> 'DDP',
	'name'			=> 'How to unpack a Debian source package',
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
	'url'			=> 'https://www.debian.org/doc/manuals/book-suggestions/',
	'cvs-url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/book-suggestions/?cvsroot=debian-doc'
},

'meta' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian META Manual',
	'author'		=> 'Ardo van Rangelrooij',
	'status'		=> 1,
	'lines'			=> 398,
	'url'			=> 'https://www.debian.org/doc/manuals/meta/',
	'cvs-url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/meta/?cvsroot=debian-doc',
	'lines'			=> 407
},

'dictionary' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Dictionary',
	'status'		=> 1,
	'lines'			=> 346,
	'url'                   => 'https://www.debian.org/doc/manuals/dictionary/',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/dictionary/?cvsroot=debian-doc'
},

'tutorial' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Tutorial',
	'revision'		=> '2.1',
	'lines'			=>  6131,
	'url'			=> 'https://www.debian.org/doc/manuals/debian-tutorial/',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/tutorial/?cvsroot=debian-doc',
	'package'		=> '',
},

'user' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian User Reference Manual',
	'status'		=> 1,
	'url'                   => 'https://www.debian.org/doc/manuals/user/',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/users_manual/?cvsroot=debian-doc'
},

'system-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux System Administrator\'s Manual',
	'status'		=> 1,
	'lines'			=> 2322,
'url'                   => 'https://www.debian.org/doc/manuals/system-administrator/',
'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/system-administrator/?cvsroot=debian-doc'
},

'network-administrator' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian GNU/Linux Network Administrator\'s Manual',
	'status'		=> 1,
	'lines'			=> 2086,
'url'                   => 'https://www.debian.org/doc/manuals/network-administrator/',
'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/network-administrator/?cvsroot=debian-doc'
},

#
# Debian Tips?
#

'install' => {
	'type'			=> 'boot',
	'name'			=> 'Debian Installation Manual',
	'revision'		=> '2.1',
	'url'			=> 'https://www.debian.org/releases/slink/i386/install.en.html',
	'cvs_url'		=> 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/install.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'dselect-beginner' => {
	'type'			=> 'boot',
	'name'			=> 'Dselect beginner guide',
	'revision'		=> '2.1',
	'url'			=> 'https://www.debian.org/releases/slink/i386/dselect-beginner.en.html',
	'cvs_url'		=> 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/dselect-beginner.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},

'release-notes' => {
	'type'			=> 'boot',
	'name'			=> 'Release Notes',
	'revision'		=> '2.1',
	'url'			=> 'https://www.debian.org/releases/slink/i386/release-notes/',
	'cvs_url'		=> 'http://cvs.debian.org/debian-boot/boot-floppies/documentation/release-notes.sgml?cvsroot=debian-boot',
	'package'		=> 'boot-floppies',
},



'policy' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Policy Manual',
	'revision'		=> '2.5.0.0',
	'url'			=> 'httpd://www.debian.org/doc/debian-policy/',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/debian-policy/debian-policy/debian-policy.sgml?cvsroot=debian-doc',
	'package'		=> 'debian-policy',
},

'packaging-manual' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Packaging Manual',
	'sub_name'		=> 'chapter 0 to 14',
	'revision'		=> '2.4.1.0',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/debian-policy/packaging-manual/packaging.sgml?cvsroot=debian-doc',
	'package'		=> 'debian-policy',
},

'developers-reference' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Developer\'s Reference',
	'revision'		=> '2.5.0',
	'lines'			=> 1951,
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/developers-reference/?cvsroot=debian-doc',
	'url'			=> 'https://www.debian.org/doc/manuals/developers-reference/',
	'package'		=> 'developers-reference',
},

'maint-guide' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian New Maintainer\'s Guide',
	'lines'			=> 1448,
	'url'			=> 'https://www.debian.org/doc/manuals/maint-guide/',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/manuals.html/maint-guide/?cvsroot=debian-doc',
},

'internals' => {
	'type'			=> 'DDP',
	'name'			=> 'dpkg Internals Manual',
	'revision'		=> '1.2',
	'url'			=> 'https://www.debian.org/doc/packaging-manuals/dpkg-internals/',
	'cvs_url'		=> 'http://cvs.debian.org/dpkg/dpkg/doc/internals.sgml?cvsroot=dpkg',
	'package'		=> 'dpkg-dev',
},

'menu' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian Menu System',
	'revision'		=> '',
	'url'			=> 'https://www.debian.org/doc/packaging-manuals/menu.html/',
	'cvs_url'		=> 'http://cvs.debian.org/ddp/manuals.sgml/menu/?cvsroot=debian-doc',
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
	'url'                   => 'https://www.debian.org/doc/manuals/programmer/',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/programmer/?cvsroot=debian-doc'
},

'i18n' => {
	'type'			=> 'DDP',
	'name'			=> 'Introduction to internationalization',
	'status'		=> 1,
	'lines'			=> 1974,
	'url'                   => 'https://www.debian.org/doc/manuals/intro-i18n/',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/intro-i18n/?cvsroot=debian-doc'
},


# How to get started on a new SGML-based manual
# Debian Documentation Guidelines

'markup' => {
	'type'			=> 'DDP',
	'name'			=> 'Debiandoc-SGML Markup Manual',
	'revision'		=> '',
	'package'		=> 'debiandoc-sgml',
	'url'                   => 'https://www.debian.org/doc/misc-manuals#markup',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/debiandoc-sgml-doc/?cvsroot=debian-doc'

},

'docstartup' => {
        'type'                  => 'DDP',
        'name'                  => 'Debiandoc Startup',
        'revision'              => '',
        'url'                   => 'https://www.debian.org/~elphick/ddp/manuals.html/debiandoc-startup/',
        'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/debiandoc-startup/?cvsroot=debian-doc'

},



# ########################################################################################
#
# Misc
#
# ########################################################################################

'newbie' => {
	'type'			=> 'DDP',
	'name'			=> 'Documentation for new users',
	'lines'			=> 3803,
	'url'                   => 'https://www.debian.org/~elphick/ddp/manuals.html/newbie-doc/',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/newbie-doc/?cvsroot=debian-doc'

},
'debian-bugs' => {
	'type'			=> 'DDP',
	'name'			=> 'Debian\'s Bug Tracking System',
	'revision'		=> '0.2',
	'package'		=> 'doc-debian',
	'lines'			=> 900,
	'url'                   => 'https://www.debian.org/doc/manuals/debian-bugs/',
	'cvs-url'               => 'http://cvs.debian.org/ddp/manuals.sgml/debian-bugs/?cvsroot=debian-doc'

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

