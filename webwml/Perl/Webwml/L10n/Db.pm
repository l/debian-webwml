#!/usr/bin/perl -w

##  Copyright (C) 2001  Denis Barbier <barbier@debian.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Webwml::L10n::Db - handle database of l10n stuff

=head1 SYNOPSIS

 use Webwml::L10n::Db;
 my $l10n_db = Webwml::L10n::Db->new();
 $l10n_db->read("../data/unstable");
 foreach ($l10n_db->list_packages()) {
         print "Package $_ ".$l10n_db->version($_)."\n";
 }

=head1 DESCRIPTION

This module is an interface with the database file used to create
webpages under C<webwml/E<lt>languageE<gt>/internaltional/l10n/>.

=head1 METHODS

=over 4

=cut

package Webwml::L10n::Db;
use strict;
use Time::localtime;

#   Do not use ``our'' to be compatible with Perl 5.005
use vars (qw($AUTOLOAD));

=item new

This is the constructor, it only performs some initialization.

   my $l10n_db = Webwml::L10n::Db->new();

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {
                data => {},
                date => 0,
                methods => {
                        package         => '$',
                        version         => '$',
                        section         => '$',
                        priority        => '$',
                        pooldir         => '$',
                        type            => '$',
                        upstream        => '$',
                        errors          => '@',
                        warnings        => '@',
                        catgets         => '@',
                        gettext         => '@',
                        nls             => '@',
                        po              => '@',
                        templates       => '@',
                        menu            => '@',
                },
        };
        bless ($self, $class);
        return $self;
}

sub AUTOLOAD {
        my $self = shift;
        my $type = ref($self) or die "$self is not an object";
        my $pkg  = shift;

        my $name = $AUTOLOAD;
        $name =~ s/.*://;   # strip fully-qualified portion

        return defined($self->{data}->{$pkg}) if $name eq 'has_package';

        #   Add a new package into database
        $self->{data}->{$pkg} = {} if $name eq 'package';

        if (! defined $self->{data}->{$pkg}) {
                warn __PACKAGE__.": Package $pkg does not exist, method \`$name' skipped\n";
                return;
        }
        my $has = "";
        my $add = "";
        if ($name =~ s/^has_//) {
                $has = "has_";
        } elsif ($name =~ s/^add_//) {
                $add = "add_";
        }

        die "Can't access \`$has$name' method in class $type"
                unless $self->{methods}->{$name} ne '';

        if ($has) {
                return defined($self->{data}->{$pkg}->{$name});
        } else {
                if ($#_ == -1) {
                        return $self->{data}->{$pkg}->{$name};
                }
                if ($self->{methods}->{$name} eq '$') {
                        $self->{data}->{$pkg}->{$name} = $_[0];
                } elsif ($self->{methods}->{$name} eq '%') {
                        $self->{data}->{$pkg}->{$name} = {}
                                unless defined($self->{data}->{$pkg}->{$name})
                                        || !$add;
                        $self->{data}->{$pkg}->{$name}->{$_[0]} = $_[1];
                } elsif ($self->{methods}->{$name} eq '@') {
                        $self->{data}->{$pkg}->{$name} = []
                                unless defined($self->{data}->{$pkg}->{$name})
                                        || !$add;
                        push (@{$self->{data}->{$pkg}->{$name}}, @_);
                } else {
                        die __PACKAGE__.":internal error: unknown data type:".$self->{methods}->{$name}."\n";
                }
        }
}

#    Perl 5.6.1 complains when it does not find this routine
sub DESTROY {
}

=item read

Read database from a given file.  Returns 1 on success and otherwise 0.

   $l10n_db->read("foo");

=cut

sub read {
        my $self = shift;
        my $file  = shift;

        if (! open (DB,"< $file")) {
                warn "Unable to read $file\n";
                return 0;
        }

        $self->{date} = <DB>;
        return 0 unless defined($self->{date});

        chomp($self->{date});
        <DB>;
        MAIN: while (1) {
                my $entry = {};
                my $desc = '';
                my $last_item = 0;
                my $text;

                while (<DB>) {
                        last if m/^\s*$/;
                        $desc .= $_;
                }
                if (!defined($_)) {
                        last unless $desc =~ m/\S/;
                        $last_item = 1;
                }

                # leading tabs are illegal, but handle them anyway
                $desc =~ s/^\t/ \t/mg;

                foreach (qw(Package Version Section Priority PoolDir Type Upstream)) {
                        if ($desc =~ m/^$_: (.*)$/m) {
                                $entry->{lc $_} = $1;
                        } else {
                                warn "Parse error when reading $file: missing $_ field\n";
                                next MAIN;
                        }
                }
                foreach (qw(Errors Warnings Catgets Gettext)) {
                        if ($desc =~ m/(^|\n)$_:\n(.+?)(\n\S|$)/s) {
                                $text = $2;
                                $text =~ s/^ //mg;
                                my @list = split(/\n\./, $text);
                                $entry->{lc $_} = \@list;
                        }
                }
                foreach (qw(NLS PO TEMPLATES MENU)) {
                        if ($desc =~ m/(^|\n)$_:\n(.+?)(\n\S|$)/s) {
                                $text = $2;
                                $text =~ s/^ //mg;
                                my @list = split(/\n/, $text);
                                $entry->{lc $_} = \@list;
                        }
                }
                $self->{data}->{$entry->{package}} = $entry;
                last if $last_item;
        }
        close DB;
        return 1;
}

=item write

Write database into file.

   $l10n_db->write("foo");

=cut

sub write {
        my $self = shift;
        my $file = shift;
        my $text;

        open (DB,"> $file")
                || die "Unable to write to $file\n";

        print DB join('-', (localtime->year() + 1900, localtime->mon() + 1, localtime->mday))."\n\n";
        foreach my $pkg (keys %{$self->{data}}) {
                foreach (qw(Package Version Section Priority PoolDir Type Upstream)) {
                        print DB $_.": ".$self->{data}->{$pkg}->{lc $_}."\n";
                }
                foreach (qw(Errors Warnings Catgets Gettext)) {
                        if (defined($self->{data}->{$pkg}->{lc $_})) {
                                $text = join("\n\.\n", @{$self->{data}->{$pkg}->{lc $_}})."\n";
                                $text =~ s/\n\n/\n/g;
                                $text =~ s/\n+$//s;
                                $text =~ s/^/ /mg;
                                #  Warning: there is already a trailing
                                #  newline within $text.
                                print DB $_.":\n".$text."\n";
                        }
                }
                foreach (qw(NLS PO TEMPLATES MENU)) {
                        if (defined($self->{data}->{$pkg}->{lc $_})) {
                                $text = join("\n", @{$self->{data}->{$pkg}->{lc $_}});
                                $text =~ s/^/ /mg;
                                print DB $_.":\n".$text."\n";
                        }
                }
                print DB "\n";
        }
        close DB;
}

=item list_packages

Returns an array with the list of package names

=cut

sub list_packages {
        my $self = shift;
        return keys %{$self->{data}};
}

=item clear

Reset info for a given package

   $l10n_db->clear("foo");

=cut

sub clear {
        my $self = shift;
        my $pkg  = shift;

        delete $self->{data}->{$pkg};
}

=item get_date

Returns date of generation

=cut

sub get_date {
        my $self = shift;
        return $self->{date};
}

=back

=head2 DATA MANIPULATION

Data about packages can be classified within scalar values (C<package>,
C<version>, C<section>, C<priority>, C<pooldir>, C<type>, C<upstream>),
and arrays (C<errors>, C<warnings>, C<catgets>, C<gettext>, C<nls>,
C<po>, C<templates>, C<menu>).
Each field has a method with the same name to get and set it, e.g.

   $section = $l10n_db->section($pkg);
   $l10n_db->section($pkg, "libs");

The first line get the section associated with the package in C<$pkg>,
whereas the second set it to C<libs>.

Two other methods are also defined to access those data, by prefixing
field name by C<has_> and C<add_>.  The former is used to ask whether
this field is defined in database, and the latter appends values for
arrays or hash values.

   if ($l10n_db->has_templates($pkg)) {
           print "Package $pkg has Debconf templates\n";
   }
   $l10n_db->add_po($pkg, 'po/fr.po:fr:42t0f0u:po/adduser_3.42_po_fr.po');

=head1 AUTHOR

Copyright (C) 2001  Denis Barbier <barbier@debian.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut

1;

