# $Id$
#
# Taken from the webwml CVS tree (english/templates/language_names.wml)

package Packages::I18N::LanguageNames;

use strict;
use warnings;

our @ISA = qw( Exporter );
our @EXPORT = qw( get_language_name get_all_languages );

my %ctrans = (
	ar    => "Arabic",
	fi    => "Finnish",
	hr    => "Croatian",
	da    => "Danish",
	nl    => "Dutch",
	en    => "English",
	fr    => "French",
	de    => "German",
	it    => "Italian",
	ja    => "Japanese",
	ko    => "Korean",
	es    => "Spanish",
	pt_BR => "Portuguese (Brasilia)",
	pt_PT => "Portuguese (Portugal)",
	zh    => "Chinese",
	sv_SE => "Swedish",
	pl    => "Polish",
	'no'  => "Norwegian",
	tr    => "Turkish",
	ru    => "Russian",
	cs    => "Czech",
	eo    => "Esperanto",
	hu    => "Hungarian",
	ro    => "Romanian",
	sk    => "Slovak",
	el    => "Greek",
  	ca    => "Catalan",
	lt    => "Lithuanian",
	sl    => "Slovene",
	bg    => "Bulgarian",
	uk    => "Ukrainian",
);

sub get_language_name {
    return $ctrans{$_[0]};
}

sub get_all_languages {
    return %ctrans;
}

1;
