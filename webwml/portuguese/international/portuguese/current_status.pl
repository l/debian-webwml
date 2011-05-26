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
# GPL Books
#
# ########################################################################################

%translations_status = (

'book-gtiau' => {
	'status'	=> 8
},

# ########################################################################################
#
# Debian Documentation Project
#
# ########################################################################################

'project-history' => {
	'status'	=> 8 
},

'faq' => {
	'status'	=> 8
},

'user' => {
	'status'	=> 8
},

'constitution' => {
	'status'	=> 8
},

'mailing-lists' => {
	'status'	=> 8
},

'bug-reporting' => {
	'status'	=> 8
},

'source-unpack' => {
	'status'	=> 8
},

'tutorial' => {
	'status'	=> 8
},

'install' => {
	'status'	=> 8
},

'dselect-beginner' => {
	'status'	=> 8
},

'release-notes' => {
	'status'	=> 8
},

'maint-guide' => {
	'status'	=> 8,
},

'programmer' => {
	'status'	=> 8,
},
	
'network-administrator' => {
        'status'        => 8
},

'system-administrator' => {
	'status'        => 8, 
},

'i18n' => {
      	'status'        => 8,
},
);
