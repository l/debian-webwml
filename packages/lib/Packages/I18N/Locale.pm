package Packages::I18N::Locale;

use strict;
use warnings;

our @ISA = qw( Exporter );
our @EXPORT = qw( get_locale get_charset );

my %lang2loc = ( en => "en_US",
		 cs => "cs_CZ",
		 da => "da_DK",
		 ja => "ja_JP",
		 sv => "sv_SE",
		 uk => "uk_UA",
		 default => "en_US",
		 );

# most of them can probably changed to UTF-8 in Sarge
# as there are more available UTF-8 locales then
my %lang2charset = (
		    default => 'UTF-8',
		    cs => 'ISO-8859-2',
		    da => 'ISO-8859-1',
		    es => 'ISO-8859-1',
		    fi => 'ISO-8859-1',
		    hu => 'ISO-8859-2',
		    it => 'ISO-8859-1',
		    ja => 'EUC-JP',
		    nl => 'ISO-8859-1',
		    pl => 'ISO-8859-2',
		    pt_BR => 'ISO-8859-1',
		    pt_PT => 'ISO-8859-1',
		    sk => 'ISO-8859-2',
		    sv_SE => 'ISO-8859-1',
		    uk => 'KOI8-U',
		    );

sub get_locale {
    my $lang = shift;
    my $locale = $lang;

    return "$lang2loc{default}.".get_charset() unless $lang;

    if ( length($lang) == 2 ) {
	$locale = $lang2loc{$lang} || ( "${lang}_" . uc $lang );
    } elsif ( $lang !~ /^[a-z][a-z]_[A-Z][A-Z]$/ ) {
	warn "get_locale: couldn't determine locale\n";
	return;
    }
    $locale .= ".".get_charset($lang);
    return $locale;
}

sub get_charset {
    my $lang = shift;

    return $lang2charset{default} unless $lang;
    return $lang2charset{$lang} || $lang2charset{default};
}

1;
