
package Packages::Util;

use Exporter;
use Text::Iconv;
Text::Iconv->raise_error(0); # do not throw exeptions

use Packages::I18N::Locale;
use Generated::Strings qw( gettext );

our @ISA = qw( Exporter );

our @EXPORT = qw( _assert conv_desc first_val split_name_mail );

sub _assert {
    my ( $cond, $message ) = @_;

    die "assertion failed: $message\n" unless $cond;
}

sub first_val {
    my ( $hash ) = @_;
    return (each %$hash)[1];
} 

my %converters = (
		  "UTF-82ISO-8859-1" => Text::Iconv->new("UTF-8", "ISO-8859-1"),
		  "UTF-82ISO-8859-2" => Text::Iconv->new("UTF-8", "ISO-8859-2"),
		  "UTF-82KOI8-U" => Text::Iconv->new("UTF-8", "KOI8-U"),
		 );

sub conv_desc {
    my ( $lang, $text ) = @_;
    
    # we assume that all descriptions are in UTF-8 and convert them
    # if necessary
    my $cs = get_charset($lang);
    if (($cs ne "UTF-8")
	&& exists $converters{"UTF-82$cs"}) {
	my $text_conv = $converters{"UTF-82$cs"}->convert($text);
	if ($text_conv) {
	    return $text_conv;
	}
	# ignore errors for the moment, not sure yet 
	# how to provide usefull information here
    }
    return $text;
}

sub split_name_mail {
    my $string = shift;
    my ( $name, $email );
    if ($string =~ /(.*?)\s*<(.*)>/o) {
	$name =  $1;
	$email = $2;
    } elsif ($string =~ /^[\w.-]*@[\w.-]*$/o) {
	$name =  $string;
	$email = $string;
    } else {
	$name = gettext( 'package has bad maintainer field' );
	$email = '';
    }
    $name =~ s/\s+$//o;
    return ($name, $email);
}

1;
