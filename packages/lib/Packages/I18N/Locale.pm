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

my %lang2charset = (
		    default => 'UTF-8',
		    ja => 'EUC-JP',
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
