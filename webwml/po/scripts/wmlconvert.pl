#! /usr/bin/perl -w

use strict;

sub processFile {
        my $file = shift;
        my ($text, $body, $orig, $out, $pre, $def, $old, $lastpos);

        open(IN, "< $file") || die "Unable to open $file\n";
        local ($/) = undef;
        $text = <IN>;
        close(IN);

        $out = '';
        $lastpos = 0;
        while ($text =~ m{\G(.*?)(<(define-tag|define-menu-item)[^>]*>)(.*?)</\3}gs) {
                $lastpos = pos($text);
                $pre  = $1.$2;
                $def  = $3;
                $body = $4;
                $old  = $pre.$body;
                if ($pre =~ m/(^|\n)\s*#.*$/) {
                        $out .= $old;
                } elsif ($body =~ m/\[EN:(.*?):\] *\n/s) {
                        $orig = $1;
                        $orig =~ s/[ \t]*\n[ \t]*/ /g;
                        if ($def eq 'define-menu-item') {
                                $out .= $pre."\n  <gettext domain=\"ports\">$orig</gettext>\n";
                        } else {
                                $out .= $pre."\n  <gettext>$orig</gettext>\n";
                        }
                } else {
                        $out .= $old;
                }
                $out .= "</$def";
        }
        $out .= substr($text, $lastpos);
        $out =~ s#(</?define-tag)-sliced#$1#g;
        $out =~ s/\n# *Please keep slices sorted alphabetically.*?(\n[^#])/$1/s;
        open(OUT, "> $file") || die "Unable to write $file\n";
        print OUT $out;
        close(OUT);
}

foreach (@ARGV) {
        processFile($_);
}
