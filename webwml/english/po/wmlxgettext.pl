#! /usr/bin/perl -w

use strict;
use Getopt::Std;

use vars qw($opt_p);

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
        my $prefix = shift;
        my ($text, $lineno, $nextlineno, $msgid);
        my (@messages) = ();
        my (%msgids) = ();
        my $repl = '';

        open(IN, "< $file") || die "Unable to open $file\n";
        local ($/) = undef;
        $text = <IN>;
        close(IN);

        if ($prefix =~ s/=(.*)//) {
                $repl = $1;
        }
        $file =~ s{^$prefix}{$repl}o unless $prefix eq '__';
        #  Remove comments
        $text =~ s/^[ \t]*#.*//mg;
        $lineno = 1;
        while ($text =~ m{\G(.*?)(<gettext\b[^>]*>)(.*?)</gettext>}gs) {
                $msgid = escape($3);
                $lineno += countNewline ($1.$2);
                $nextlineno = countNewline ($3);;
                push (@msgids, $msgid);
                if (defined ($messages->{$msgid})) {
                        print STDERR "Warning: msgid multiple defined:\n\t".
                                $msgid."\n";
                } else {
                        $messages->{$msgid} = [];
                }
                push (@{$messages->{$msgid}}, $file, $lineno);
                $lineno += $nextlineno;
        }
}

$opt_p = '__';
getopt('p');

foreach (@ARGV) {
        processFile($_, $opt_p);
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
