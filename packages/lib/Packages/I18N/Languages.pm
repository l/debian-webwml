# $Id$
#
# Taken from the webwml CVS tree (english/templates/languages.wml)

package Packages::I18N::Languages;

use strict;
use warnings;

our @ISA = qw( Exporter );
our @EXPORT = qw( langcmp get_transliteration );

# language directory name => ISO 639 two-letter code for the language name
my %langs = (
	     english    => "en",
	     arabic     => "ar",
	     bulgarian  => "bg",
	     catalan    => "ca",
	     czech	=> "cs",
	     danish     => "da",
	     german     => "de",
	     greek      => "el",
	     esperanto  => "eo",
	     spanish    => "es",
	     finnish    => "fi",
	     french     => "fr",
	     croatian   => "hr",
	     hungarian  => "hu",
	     indonesian => "id",
	     italian    => "it",
	     japanese   => "ja",
	     korean     => "ko",
	     lithuanian => "lt",
	     dutch      => "nl",
	     norwegian  => "no",
	     polish     => "pl",
	     portuguese => "pt",
	     romanian   => "ro",
	     russian    => "ru",
	     swedish    => "sv",
	     slovene    => "sl",
	     slovak     => "sk",
	     turkish    => "tr",
	     chinese    => "zh",
	     );

# language directory name => native name of the language
# non-ASCII letters must be escaped (using entities)!
my %selflang = (
		ar     => '&#1593;&#1585;&#1576;&#1610;&#1577;',
		bg     => '&#1041;&#1098;&#1083;&#1075;&#1072;&#1088;&#1089;&#1082;&#1080;',
		ca     => 'catal&agrave;',
		zh     => '&#20013;&#25991;',
		hr     => 'hrvatski',
		cs     => '&#269;esky',
		da     => 'dansk',
		nl     => 'Nederlands',
		en     => 'English',
		eo     => 'Esperanto',
		fi     => 'suomi',
		fr     => 'fran&ccedil;ais',
		de     => 'Deutsch',
		el     => '&#917;&#955;&#955;&#951;&#957;&#953;&#954;&#940;',
		hu     => 'magyar',
		id     => 'Indonesia',
		it     => 'Italiano',
		ja     => '&#26085;&#26412;&#35486;',
		ko     => '&#54620;&#44397;&#50612;',
		lt     => 'Lietuvi&#371;',
		"no"   => 'norsk&nbsp;(bokm&aring;l)',
		pl     => 'polski',
		pt_PT  => 'Portugu&ecirc;s (pt)',
		pt_BR  => 'Portugu&ecirc;s (br)',
		ro     => 'rom&acirc;n&#259;',
		ru     => '&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;',
		es     => 'espa&ntilde;ol',
		sk     => 'slovak', #FIXME
		sv_SE  => 'svenska',
		sl     => 'sloven&#353;&#269;ina',
		tr     => 'T&uuml;rk&ccedil;e',
		uk     => 'ukrainian', #FIXME
		);

# language directory name => Latin transliteration of the language name
# This is used for language names which consist entirely of non-Latin
# characters, to aid those that have browsers which cannot show different
# character sets at once.
my %translit = (
		ar => "Arabiya",
		bg => "B&#601;lgarski",
		zh => "Zhongzu", # Not printed due to Chinese-specific code; kept for sort order
		el => "Ellinika",
		ja => "Nihongo",
		ko => "Hangul", # Not sure. "Hanguk-Mal" (=Spoken Korean)?
		ru => "Russkij",
		);

# second transliteration table, used for languages starting with a latin
# diacritic letter
my %translit2 = (
		 cs    => "cesky",
);

my %sorted_langs;

sub langcmp {
  my ($first, $second) = ($a, $b);

  # Handle sorting of non-latin characters
  # If there is a transliteration for this language available, use it
  $first = $translit{$sorted_langs{$a}} if defined $translit{$sorted_langs{$a}};
  $second = $translit{$sorted_langs{$b}} if defined $translit{$sorted_langs{$b}};

  # Then handle special cases (initial latin letters with diacritics)
  $first = $translit2{$sorted_langs{$a}} if defined $translit2{$sorted_langs{$a}};
  $second = $translit2{$sorted_langs{$b}} if defined $translit2{$sorted_langs{$b}};

  # Put remaining entity-only names last in the list
  if (substr($first,0,1) eq '&')
  {
    $first =~ s/^&/ZZZ&/;
  }
  if (substr($second,0,1) eq '&')
  {
    $second =~ s/^&/ZZZ&/;
  }
  #    There seems to be a bug with localization in
  #    Perl 5.005 so we need those extra variables.
  my ($ufirst, $usecond) = (uc($first), uc($second));
  return $ufirst cmp $usecond;
}

sub get_transliteration {
    return $translit{$_[0]} if exists $translit{$_[0]};
    return undef;
}

1;
