#! /usr/bin/perl -w

use strict;

my $lang = uc shift @ARGV;

my $messages = {};
my @msgids = ();

sub escape {
        my $lang = shift;
        my $text = shift;
        if ($lang eq 'ZH') {
                $text =~ s/\\/\\x5c/g;
        } else {
                $text =~ s/\\/\\\\/g;
        }
        if ($lang eq 'ZH' || $lang eq 'JA') {
                $text =~ s/[ \t]*\n[ \t]*//g;
        } else {
                $text =~ s/[ \t]*\n[ \t]*/ /g;
        }
        $text =~ s/"/\\"/g;
        $text =~ s/\n/\\n/g;
        $text =~ s/\t/\\t/g;
        return $text;
}

sub countNewline {
        my $text = shift;
        return ($text =~ s/\n//g);
}

sub processFile {
        my $lang = shift;
        my $file = shift;
        my ($text, $lineno, $nextlineno, $msg, $msgid, $msgstr);

        open(IN, "< $file") || die "Unable to open $file\n";
        local ($/) = undef;
        $text = <IN>;
        close(IN);
        #  Remove comments
        $text =~ s/^[ \t]*#.*//mg;
        $lineno = 1;
        while ($text =~ m{\G(.*?)(<(define-tag|define-menu-item)[^>]*>)(.*?)</\3}gs) {
                $msg = $4;
                $lineno += countNewline ($1.$2);
                $nextlineno = countNewline ($4);
                if ($msg =~ m/(.*?)\[EN:(.*?):\](\n.*)/s) {
                        $msgid = escape('EN', $2);
                        $lineno += countNewline ($1);
                        $nextlineno = countNewline ($2.$3);
                        $msgstr = '';
                        if ($lang ne '' && $msg =~ m/\[${lang}:(.*?):\][ \t]*\n/s) {
                                $msgstr = escape($lang, $1);
                        }
                        $msgstr = '' if $msgid eq $msgstr;
                        push (@msgids, $msgid);
                        $messages->{$msgid} = [$msgstr]
                                unless defined ($messages->{$msgid});
                        push (@{$messages->{$msgid}}, $file, $lineno);
                        $lineno += $nextlineno;
                }
        }
}

foreach (@ARGV) {
        processFile($lang, $_);
}

print "msgid \"\"\nmsgstr \"\"\n".
        "\"Content-Type: text/plain; charset=CHARSET\\n\"\n".
        "\"Content-Transfer-Encoding: 8bit\\n\"\n\n";

foreach my $msgid (@msgids) {
        next unless $messages->{$msgid};
        my $msgstr = shift(@{$messages->{$msgid}});
        while (@{$messages->{$msgid}}) {
                print "#: ".shift(@{$messages->{$msgid}}).":".
                            shift(@{$messages->{$msgid}})."\n";
        }
        print "msgid \"$msgid\"\nmsgstr \"$msgstr\"\n\n";
        undef $messages->{$msgid};
}
