#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Webwml::L10n::Debconf - translation status of Debconf templates

=head1 SYNOPSIS

 use Webwml::L10n::Debconf;
 my $tmpl = Webwml::L10n::Debconf->new();
 $tmpl->read_compact($file);
 my @languages = $tmpl->langs();
 foreach (sort @languages) {
        my ($t,$f,$u) = $tmpl->stats($_);
        print "$_:${t}t${f}f${u}u\n";
 }

=head1 DESCRIPTION

This module extracts informations about translation status of Debconf
templates.

=head1 METHODS

=over 4

=cut

package Webwml::L10n::Debconf;

use strict;

=item new

This is the constructor.

   my $tmpl = Webwml::L10n::Debconf->new();

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

Read a template containing all translations

   $tmpl->read_compact($file);

=cut

sub read_compact {
        my $self = shift;
        my $file = shift;
        my ($tmpl, $lang, $msg);

        $self->_init();
        open (TMPL, "< $file")
                || die "Unable to read file $file\n";

        $tmpl = '';
        while (<TMPL>) {
                chomp;
                if (s/^Template:\s*//) {
                        $tmpl = $_;
                        $self->{orig}->{$tmpl} = {};
                } elsif (s/^Choices:\s*//) {
                        die "\`Choices' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $self->{orig}->{$tmpl}->{choices} = $_;
                        $self->{count} ++;
                } elsif (s/^Description:\s*//) {
                        die "\`Description' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $msg = $_ . "\n";
                        while (<TMPL>) {
                                last if (!defined($_) || m/^\S/ || m/^$/m);
                                $msg .= $_;
                        }
                        $msg =~ s/^\s+//gm;
                        $msg =~ s/\s+$//gm;
                        $msg =~ tr/ \t\n/ /s;
                        $self->{orig}->{$tmpl}->{description} = $msg;
                        $self->{count} ++;
                        last unless defined($_);
                        redo;
                } elsif (s/^Choices-(.*?):\s*//) {
                        die "\`Choices-$1' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $lang = $1;
                        unless (defined($self->{langs}->{$lang})) {
                                $self->{langs}->{$lang} = 1;
                                $self->{trans}->{$lang}->{count} = 0;
                                $self->{trans}->{$lang}->{fuzzy} = 0;
                        }
                        $self->{trans}->{$lang}->{count} ++;
                } elsif (s/^Description-(.*?):\s+//) {
                        die "\`Description-$1' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $lang = $1;
                        unless (defined($self->{langs}->{$lang})) {
                                $self->{langs}->{$lang} = 1;
                                $self->{trans}->{$lang}->{count} = 0;
                                $self->{trans}->{$lang}->{fuzzy} = 0;
                        }
                        do {
                                $_ = <TMPL>;
                        } until (!defined($_) || m/^\S/ || m/^$/m);
                        $self->{trans}->{$lang}->{count} ++;
                        last unless defined($_);
                        redo;
                } elsif (m/^\s*$/) {
                        $tmpl = '';
                }
        }
        close(TMPL);
}

=item read_dispatched

Read templates contained in several files.  First argument is the English file,
all other arguments are translated template files.

   @trans = qw(templates.de templates.fr templates.ja templates.nl);
   $tmpl->read_dispatched('templates', @trans);

=cut

sub read_dispatched {
        my $self = shift;
        my $file = shift;

        $self->_init();
        $self->read_compact($file);
        $self->{trans} = {};
        $self->{langs} = {};
        foreach my $trans (@_) {
                $self->_read_dispatched($trans);
        }
}

sub _read_dispatched {
        my $self = shift;
        my $file = shift;
        my ($lang, $msg, $status);

        open (TMPL, "< $file")
                || die "Unable to read file $file\n";

        my $tmpl = '';
        while (<TMPL>) {
                chomp;
                if (s/^Template:\s*//) {
                        $tmpl = $_;
                        $status = ''
                } elsif (s/^Choices:\s*//) {
                        die "\`Choices' field found before \`Template'\n"
                                unless $tmpl ne '';
                        if ($_ eq $self->{orig}->{$tmpl}->{choices}) {
                                $status = 'count';
                        } else {
                                $status = 'fuzzy';
                        }
                } elsif (s/^Choices-(.*?):\s*//) {
                        die "\`Choices-$1' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $lang = $1;
                        unless (defined($self->{langs}->{$lang})) {
                                $self->{langs}->{$lang} = 1;
                                $self->{trans}->{$lang}->{count} = 0;
                                $self->{trans}->{$lang}->{fuzzy} = 0;
                        }
                        $self->{trans}->{$lang}->{$status} ++;
                } elsif (s/^Description:\s*//) {
                        die "\`Description' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $msg = $_ . "\n";
                        while (<TMPL>) {
                                last if (!defined($_) || m/^\S/ || m/^$/m);
                                $msg .= $_;
                        }
                        $msg =~ s/^\s+//gm;
                        $msg =~ s/\s+$//gm;
                        $msg =~ tr/ \t\n/ /s;
                        if ($msg eq $self->{orig}->{$tmpl}->{description}) {
                                $status = 'count';
                        } else {
                                $status = 'fuzzy';
                        }
                        last unless defined($_);
                        redo;
                } elsif (s/^Description-(.*?):\s+//) {
                        die "\`Description-$1' field found before \`Template'\n"
                                unless $tmpl ne '';
                        $lang = $1;
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
                        } until (!defined($_) || m/^\S/ || m/^$/m);
                        $self->{trans}->{$lang}->{$status} ++;
                        last unless defined($_);
                        redo;
                } elsif (m/^\s*$/) {
                        $tmpl = '';
                }
        }
        close(TMPL);
}

=item langs

Return the languages in which this template is translated.

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

Return the number of translatable strings in this template.

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

Return an array containing all Debconf ids found in this template.

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

