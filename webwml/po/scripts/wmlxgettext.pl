#! /usr/bin/perl -w

use strict;

my $messages = {};
my @msgids = ();

sub escape {
        my $text = shift;
        $text =~ s/\\/\\\\/g;
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
        my $file = shift;
        my ($text, $lineno, $nextlineno, $msgid);
        my (@messages) = ();
        my (%msgids) = ();

        open(IN, "< $file") || die "Unable to open $file\n";
        local ($/) = undef;
        $text = <IN>;
        close(IN);
        #  Remove comments
        $text =~ s/^[ \t]*#.*//g;
        $lineno = 1;
        while ($text =~ m{\G(.*?)(<gettext\b[^>]*>)(.*?)</gettext>}gs) {
                $msgid = escape($3);
                $lineno += countNewline ($1.$2);
                $nextlineno = countNewline ($3);;
                push (@msgids, $msgid);
                $messages->{$msgid} = []
                        unless defined ($messages->{$msgid});
                push (@{$messages->{$msgid}}, $file, $lineno);
                $lineno += $nextlineno;
        }
}

foreach (@ARGV) {
        processFile($_);
}

print "msgid \"\"\nmsgstr \"\"\n".
        "\"Content-Type: text/plain; charset=ASCII\\n\"\n".
        "\"Content-Transfer-Encoding: 8bit\\n\"\n\n";

foreach my $msgid (@msgids) {
        next unless $messages->{$msgid};
        while (@{$messages->{$msgid}}) {
                print "#: ".shift(@{$messages->{$msgid}}).":".
                            shift(@{$messages->{$msgid}})."\n";
        }
        print "msgid \"$msgid\"\nmsgstr \"\"\n\n";
        undef $messages->{$msgid};
}
