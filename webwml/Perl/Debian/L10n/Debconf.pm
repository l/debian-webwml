#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##  Copyright (C) 2004  Martin Quinson
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Debian::L10n::Debconf - translation status of Debconf templates

=head1 SYNOPSIS

 use Debian::L10n::Debconf;
 my $tmpl = Debian::L10n::Debconf->new();
 $tmpl->read_compact($file);
 my @languages = $tmpl->langs();
 foreach (sort @languages) {
        my ($t,$f,$u) = $tmpl->stats($_);
        print "$_:${t}t${f}f${u}u\n";
 }

=head1 DESCRIPTION

This module extracts informations about translation status of Debconf
templates files.

=head1 METHODS

=over 4

=cut

package Debian::L10n::Debconf;

use strict;

=item new

This is the constructor.

   my $tmpl = Debian::L10n::Debconf->new();

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self = {};
        bless ($self, $class);
        $self->_init();
        return $self;
}

sub _init {
        my $self = shift;

        $self->{orig}  = {};
        $self->{count} = 0;
        $self->{trans} = {};
        $self->{langs} = {};
        $self->{files} = {};
}

=item read_compact

Read a templates file containing all translations.  An optional second
argument may be used, any non-zero value tells that this file comes with
translations in other files.  In such a case no warning is raised if this
file contains translated fields, because maintainer is assumed to be
responsible for such translations.

   $tmpl->read_compact($file);

=cut

sub read_compact {
        my $self = shift;
        my $file = shift;
        my $safe = shift || 0;
        my ($lang, $msg);

        $self->_init();
        open (TMPL, "< $file")
                || die "Unable to read file $file\n";

        my $tmpl = '';
        my $line = 0;
        while (<TMPL>) {
                chomp;
                $line ++;
                if (m/^[A-Z][a-z]*-[A-Za-z_]+-fuzzy:/) {
                        warn "$file:$line: fuzzy-fields-in-templates\n";
                        goto SKIP;
                }
                if ((!$safe) && m/^[A-Z][a-z]*-[A-Za-z_]+:/) {
                        warn "$file:$line: translated-fields-in-master-templates\n";
                        #   Display this message only once
                        $safe = 1;
                }
                if (s/^Template:\s*//) {
                        $tmpl = $_;
                        $self->{orig}->{$tmpl} = {};
                } elsif (s/^(Choices):\s*//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        $self->{orig}->{$tmpl}->{choices} = $_;
                        $self->{count} ++;
                } elsif (s/^(Description):\s*//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        $msg = $_ . "\n";
                        while (<TMPL>) {
                                $line ++;
                                last if (!defined($_) || m/^\S/ || m/^$/m);
                                $msg .= $_;
                        }
                        $msg =~ s/^\s+//gm;
                        $msg =~ s/\s+$//gm;
                        $msg =~ tr/ \t\n/ /s;
                        $self->{orig}->{$tmpl}->{description} = $msg;
                        $self->{count} ++;
                        last unless defined($_);
                        $line --;
                        redo;
                } elsif (s/^(Choices-(.*?)):\s*//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        $lang = $2;
                        unless (defined($self->{langs}->{$lang})) {
                                $self->{langs}->{$lang} = 1;
                                $self->{trans}->{$lang}->{count} = 0;
                                $self->{trans}->{$lang}->{fuzzy} = 0;
                        }
                        $self->{trans}->{$lang}->{count} ++;
                } elsif (s/^(Description-(.*?)):\s+//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        $lang = $2;
                        unless (defined($self->{langs}->{$lang})) {
                                $self->{langs}->{$lang} = 1;
                                $self->{trans}->{$lang}->{count} = 0;
                                $self->{trans}->{$lang}->{fuzzy} = 0;
                        }
                        do {
                                $_ = <TMPL>;
                                $line ++;
                        } until (!defined($_) || m/^\S/ || m/^$/m);
                        $self->{trans}->{$lang}->{count} ++;
                        last unless defined($_);
                        $line --;
                        redo;
                } elsif (m/^\s*$/) {
                        $tmpl = '';
                } elsif (m/^(Type|Default)/) {
                        #   Ignored fields
                } else {
                        warn "$file:$line: Wrong input line:\n $_\n";
                }
                next;

                SKIP:
                        while (<TMPL>) {
                                $line ++;
                                last if (!defined($_) || m/^\S/ || m/^$/m);
                        }
                        last unless defined($_);
                        $line --;
                        redo;
        }
        close(TMPL);
}

=item read_dispatched

Read templates contained in several files.  First argument is the English file,
all other arguments are translated templates files.

   @trans = qw(templates.de templates.fr templates.ja templates.nl);
   $tmpl->read_dispatched('templates', @trans);

=cut

sub read_dispatched {
        my $self = shift;
        my $file = shift;

        $self->_init();
        $self->read_compact($file, 1);
        $self->{trans} = {};
        $self->{langs} = {};
        foreach my $trans (@_) {
                $self->_read_dispatched($trans);
        }
}

sub _read_dispatched {
        my $self = shift;
        my $file = shift;
        my ($lang, $msg, $status_c, $status_d);

        open (TMPL, "< $file")
                || die "Unable to read file $file\n";

        my $tmpl = '';
        my $line = 0;
        my $ext = $file;
        $ext =~ s/.*\.//;
        while (<TMPL>) {
                chomp;
                $line ++;
                if (m/^[A-Z][a-z]*-[A-Za-z_]+-fuzzy:/) {
                        warn "$file:$line: fuzzy-fields-in-templates\n";
                        goto SKIP;
                }
                if (s/^Template:\s*//) {
                        $tmpl = $_;
                        $status_c = $status_d = '';
                        unless (defined $self->{orig}->{$tmpl}) {
                                warn "$file:$line: translated-templates-not-in-original $_\n";
                                while (<TMPL>) {
                                        $line ++;
                                        last if (!defined($_) || m/^$/);
                                }
                                last unless defined($_);
                                $line --;
                                redo;
                        }
                } elsif (s/^(Choices):\s*//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        next unless defined $self->{orig}->{$tmpl};
                        if (defined($self->{orig}->{$tmpl}->{choices}) &&
                            $_ eq $self->{orig}->{$tmpl}->{choices}) {
                                $status_c = 'count';
                        } else {
                                $status_c = 'fuzzy';
                        }
                } elsif (s/^(Choices-(.*?)):\s*//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        $lang = $2;
                        if ($lang ne $ext) {
                                warn "$file:$line: lang-mismatch-in-translated-templates\n"
                        } else {
                                unless (defined($self->{langs}->{$lang})) {
                                        $self->{langs}->{$lang} = 1;
                                        $self->{trans}->{$lang}->{count} = 0;
                                        $self->{trans}->{$lang}->{fuzzy} = 0;
                                }
                                if ($status_c) {
                                        $self->{trans}->{$lang}->{$status_c} ++;
                                } else {
                                        warn "$file:$line: original-fields-removed-in-translated-templates\n";
                                }
                                $status_c = '';
                        }
                } elsif (s/^(Description):\s*//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        next unless defined $self->{orig}->{$tmpl};
                        $msg = $_ . "\n";
                        while (<TMPL>) {
                                $line ++;
                                last if (!defined($_) || m/^\S/ || m/^$/m);
                                $msg .= $_;
                        }
                        $msg =~ s/^\s+//gm;
                        $msg =~ s/\s+$//gm;
                        $msg =~ tr/ \t\n/ /s;
                        if (defined($self->{orig}->{$tmpl}->{description}) &&
                            $msg eq $self->{orig}->{$tmpl}->{description}) {
                                $status_d = 'count';
                        } else {
                                $status_d = 'fuzzy';
                        }
                        last unless defined($_);
                        $line --;
                        redo;
                } elsif (s/^(Description-(.*?)):\s+//) {
                        if ($tmpl eq '') {
                                warn "$file:$line: \`$1' field found before \`Template'\n";
                                goto SKIP;
                        }
                        $lang = $2;
                        if ($lang ne $ext) {
                                warn "$file:$line: lang-mismatch-in-translated-templates\n";
                                do {
                                        $_ = <TMPL>;
                                        $line ++;
                                } until (!defined($_) || m/^\S/ || m/^$/m);
                        } else {
                                if (defined($self->{files}->{$lang})) {
                                        die "Lang \`$lang' found in \`$file' and \`$self->{files}->{$lang}'\n"
                                                unless $self->{files}->{$lang} eq $file;
                                } else {
                                        $self->{files}->{$lang} = $file;
                                }
                                unless (defined($self->{langs}->{$lang})) {
                                        $self->{langs}->{$lang} = 1;
                                        $self->{trans}->{$lang}->{count} = 0;
                                        $self->{trans}->{$lang}->{fuzzy} = 0;
                                }
                                do {
                                        $_ = <TMPL>;
                                        $line ++;
                                } until (!defined($_) || m/^\S/ || m/^$/m);
                                if ($status_d) {
                                        $self->{trans}->{$lang}->{$status_d} ++;
                                } else {
                                        warn "$file:$line: original-fields-removed-in-translated-templates\n";
                                }
                                $status_d = '';
                        }
                        last unless defined($_);
                        $line --;
                        redo;
                } elsif (m/^\s*$/) {
                        $tmpl = '';
                        $status_c = $status_d = '';
                } elsif (m/^(Type|Default)/) {
                        #   Ignored fields
                } else {
                        warn "$file:$line: Wrong input line:\n $_\n";
                }
                next;

                SKIP:
                        while (<TMPL>) {
                                $line ++;
                                last if (!defined($_) || m/^\S/ || m/^$/);
                        }
                        last unless defined($_);
                        $line --;
                        redo;
        }
        close(TMPL);
}

=item langs

Return the languages in which this templates file is translated.

   my @list = $tmpl->langs();

=cut

sub langs {
        my $self = shift;
        return keys %{$self->{langs}};
}

=item filename

When templates are dispatched into several files, return the filename in
which the language passed as argument is found.

   my $filename = $tmpl->filename("de");

=cut

sub filename {
        my $self = shift;
        my $lang = shift;
        return (defined($self->{files}->{$lang}) ? 
                        $self->{files}->{$lang}  : '');
}

=item count

Return the number of translatable strings in this templates file.

   my $number = $tmpl->count();

=cut

sub count {
        my $self = shift;
        return $self->{count};
}

=item stats

With an argument, return an array consisting of the number of
translated, fuzzy and untranslated strings for the language given as
argument.
Without argument, return a hash array indexed by language and returning
an array of the number of translated, fuzzy and untranslated strings.

   my ($t, $f, $u) = $tmpl->stats("de");
   my %stats  = $tmpl->stats();
   foreach (keys %stats) {
           print $_.':'. $stats{$_}->[0].'t'.$stats{$_}->[1].'f'.
                $stats{$_}->[2]."u\n";
   }

=cut

sub stats {
        my $self = shift;
        my $lang;
        if (@_) {
                $lang = shift;
                if (defined($self->{langs}->{$lang})) {
                        return ($self->{trans}->{$lang}->{count},
                                $self->{trans}->{$lang}->{fuzzy},
                                $self->{count} -
                                        $self->{trans}->{$lang}->{fuzzy} -
                                        $self->{trans}->{$lang}->{count});
                } else {
                        return (0,0,0);
                }
        } else {
                my %stats = ();
                foreach $lang (keys %{$self->{langs}}) {
                        $stats{$lang} = [
                                $self->{trans}->{$lang}->{count},
                                $self->{trans}->{$lang}->{fuzzy},
                                $self->{count} -
                                        $self->{trans}->{$lang}->{fuzzy} -
                                        $self->{trans}->{$lang}->{count}
                        ];
                }
                return %stats;
        }
}

=item entries

Return an array containing all Debconf ids found in this templates file.

   my @ids = $tmpl->entries();

=cut

sub entries {
        my $self = shift;
        return keys %{$self->{orig}};
}

=back

=head1 AUTHOR

Copyright (C) 2001  Denis Barbier <barbier@debian.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut

1;

