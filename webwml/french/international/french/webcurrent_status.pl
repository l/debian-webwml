#!/usr/bin/perl

eval `cat check_trans.status`;

# This file should modify the %translations database to include
# all information regarding the translation status for a fixed 
# language

#       'key' => {
#               'status'        => '',
#use numbers instead of text since it makes translations easier
#                      'not-available'                 0
#                      'not translated'                1
#                      'being translated'              2
#                      'needs revision'                3
#                      'translation up to date'        4
#                      'needs check'                   5
#                      'being revised'                 6
#                      'obsolete'                      7
#                      'unknown'                       8
# In french:
#                       'non-disponible'                0
#                       'à traduire'                    1
#                       'en cours de traduction'        2
#                       'à relire'                      3
#                       'traduction à jour'             4
#                       'à reviser'                     5
#                       'en cours de révision'          6
#                       'obsolète'                      7
#                       'inconnu'                       8
#
#       'since'                 => '',
#       'diff'                  => '',
#       'base_revision'         => '',
#       'translation_name'      => '',
#       'translation_sub_name'  => '',
#       'translation_maintainer'=> [ '', ...],
#       'translation_revision'  => '',
#       'translation_url'       => '',
#       'translation_cvs_url'   => '',
#       'translation_source_url'=> '',
#       'translation_diff_url'  => '',
#       'translation_package'   => '',
#       'last_translated'       => '',
#       'old_translators'       => []


# ########################################################################################
#
# Livres GPL
#
# ########################################################################################

$translations = {

%$automatic,

'international/French' => {
	'status'		=> 4,
	'type'			=> 'Web',
	'note'			=> 'Version originale en français',
	'translation_maintainer'=> ['Christian Couder'],
},

};

