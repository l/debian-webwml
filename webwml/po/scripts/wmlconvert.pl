#! /usr/bin/perl -w

use strict;

sub processFile {
        my $file = shift;
        my ($text, $body, $out, $pre, $old, $lastpos);

        open(IN, "< $file") || die "Unable to open $file\n";
        local ($/) = undef;
        $text = <IN>;
        close(IN);

        $out = '';
        $lastpos = 0;
        while ($text =~ m{\G(.*?)(<define-tag[^>]*>)(.*?)</define-tag}gs) {
                $lastpos = pos($text);
                $pre  = $1.$2;
                $body = $3;
                $old  = $pre.$body;
                if ($pre =~ m/(^|\n)\s*#.*$/) {
                        $out .= $old;
                } elsif ($body =~ m/\[EN:(.*?):\]\n/s) {
                        $out .= $pre."\n  <gettext>$1</gettext>\n";
                } else {
                        $out .= $old;
                }
                $out .= "</define-tag";
        }
        $out .= substr($text, $lastpos);
        $out =~ s#(</?define-tag)-sliced#$1#g;
        $out =~ s/\n# *Please keep slices sorted alphabetically.*//;

        if ($file eq 'template/debian/common_translation.wml') {
                my $replgettext = <<'EOT';
<use name="intl:gettext" />

<mp4h-l10n LC_MESSAGES="$(CUR_LOCALE:-C)" />
<textdomain domain="templates" />
<bindtextdomain domain="templates" path="$(ENGLISHDIR)/../po/locale" />
<when "$(CHARSET)">
  <bind_textdomain_codeset domain="templates" codeset="$(CHARSET)" />
</when>
EOT
                $out =~ s/#use wml::debian::common_tags/$replgettext/;
        } elsif ($file eq 'template/debian/countries.wml') {
                my $replgettext = <<'EOT';
if ('$(DUMMY_VAR_DO_NOT_REMOVE)' ne '') {
    open(GEN, "> countries.def");
    print GEN "#   File generated automatically.  Do not edit!\n";
    foreach my $c (sort keys %countries) {
        print GEN "<"."define-tag ".$c."c endtag=delete whitespace=delete>\n";
        print GEN "    <"."gettext>".$countries{$c}{EN}."<"."/gettext>\n";
        print GEN "<"."/define-tag>\n";
    }
}
:>
EOT
                $out =~ s/\n[^\n]*DUMMY_VAR_DO_NOT_REMOVE.*$/\n$replgettext/s;
        }
        open(OUT, "> $file") || die "Unable to write $file\n";
        print OUT $out;
        close(OUT);
}

foreach (@ARGV) {
        processFile($_);
}
