#!/usr/bin/perl -w

##  Copyright (C) 2001-2004  Denis Barbier <barbier@debian.org>
##  Copyright (C) 2004       Martin Quinson <martin.quinson@tuxfamily.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.

=head1 NAME

Debian::L10n::Db - handle database of debian l10n stuff

=head1 SYNOPSIS

 use Debian::L10n::Db;
 my $l10n_db = Debian::L10n::Db->new();
 $l10n_db->read("../data/unstable");
 foreach ($l10n_db->list_packages()) {
         print "Package $_ ".$l10n_db->version($_)."\n";
 }

=head1 DESCRIPTION

This module is an interface to the database files used in several places of
the debian localisation infrastructure, such as the webpages under
C<webwml/E<lt>languageE<gt>/international/l10n/>.

=head1 METHODS

=over 4

=cut

package Debian::L10n::Db;
use strict;
use Time::localtime;
use File::Path;
use Data::Dumper;

#   Do not use ``our'' to be compatible with Perl 5.005
use vars (qw($AUTOLOAD));

# Define data that are used in various places:
# stattrans.pl, english/international/l10n/scripts/gen-files.pl

use Exporter;
our @ISA=('Exporter');
our @EXPORT_OK=('%LanguageList');

our %LanguageList = (
	AR    => 'arabic',
	CA    => 'catalan',
	CS    => 'czech',
	DA    => 'danish',
	DE    => 'german',
	ID    => 'indonesian',
	IT    => 'italian',
	RU    => 'russian',
# Used by the Smith project, not for translations
#       EN    => 'english',
	ES    => 'spanish',
	FR    => 'french',
	GL    => 'galician',
	NL    => 'dutch',
	PT_BR => 'portuguese',
	RO    => 'romanian',
	SK    => 'slovak',
	SV    => 'swedish',
	TR    => 'turkish',
);

=item new

This is the constructor, it only performs some initialization.

   my $l10n_db = Debian::L10n::Db->new();

=cut

sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = {
                data    => {},
	        #   Fields below constitute the header of the files. they are written 
	        #   as fields of a package called '' (that's the same trick than in po files)
	        
	        # Language Year Month Message are for the spider
	        headers => [qw{Date Language Year Month Message Page}],
                #   Fields below are written into file in the same order
                #   Package must always be the first field
	    
                #   Switch is used temporarily to detect packages which
                #   depend on debconf and did not switch to using po-debconf.
                scalar  => [qw(Package Version Section Priority Maintainer PoolDir Type Upstream 
		               Switch )],
                array1  => [qw(Errors Catgets Gettext)],
                array2  => [qw(NLS PO TEMPLATES PODEBCONF PO4A MENU DESKTOP MAN STATUS)],
        };
        $self->{methods} = {};
        foreach (@{$self->{scalar}}) {
                $self->{fields}->{$_} = '$';
        }
        foreach (@{$self->{array1}}) {
                $self->{fields}->{$_} = '@';
        }
        foreach (@{$self->{array2}}) {
                $self->{fields}->{$_} = '@@';
        }
        foreach (keys %{$self->{fields}}) {
                $self->{methods}->{lc $_} = $_;
        }
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
                unless defined($self->{methods}->{$name});

        my $field = $self->{methods}->{$name};

        if ($has) {
                return defined($self->{data}->{$pkg}->{$field});
        } else {
                if ($#_ == -1) {
                        if ($self->{fields}->{$field} =~ m/@/) {
                                return $self->{data}->{$pkg}->{$field} || [];
                        }
                        return $self->{data}->{$pkg}->{$field};
                }
                if ($self->{fields}->{$field} eq '$') {
                        $self->{data}->{$pkg}->{$field} = $_[0];
                } elsif ($self->{fields}->{$field} eq '@') {
                        $self->{data}->{$pkg}->{$field} = []
                                unless defined($self->{data}->{$pkg}->{$field})
                                        || !$add;
                        push (@{$self->{data}->{$pkg}->{$field}}, @_);
                } elsif ($self->{fields}->{$field} eq '@@') {
                        $self->{data}->{$pkg}->{$field} = []
                                unless defined($self->{data}->{$pkg}->{$field})
                                        || !$add;
                        my @list = @_;
                        push (@{$self->{data}->{$pkg}->{$field}}, \@list);
                } else {
                        die __PACKAGE__.":internal error: unknown data type:".$self->{fields}->{$field}."\n";
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
        my $check  = shift;
        $check = 1 unless defined $check;
    
        if ($file =~ m/\.gz$/) {
                open (DB,"gzip -dc $file |") || return 0;
        } else {
                open (DB,"< $file") || return 0;
        }

        MAIN: while (1) {
                my $entry = {};
                my $desc = '';
                my $last_item = 0;
                my $text;

                while (<DB>) {
                        last if m/^\s*$/;
                        $desc .= $_;
                }
	        if ($desc =~ m/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) { # Parse old format date
		    $self->set_date($_);
		    next MAIN;
		}
                if (!defined($_)) {
                        last unless $desc =~ m/\S/;
                        $last_item = 1;
                }

                # Leading tabs are illegal, but handle them anyway
                $desc =~ s/^\t/ \t/mg;

                foreach (@{$self->{scalar}}) {
                        if ($desc =~ m/^$_: ?(.*)$/m) {
 			        if ($_ eq 'Package' && defined $self->{data}->{$1} && length($1)) {
                                        $entry = $self->{data}->{$1};
                                } elsif ($_ eq 'Package' && length($1) == 0) {
				    foreach (@{$self->{headers}}) {
					if ($desc =~ m/^$_: (.*)$/m) {
					    $self->set_header($_,$1);
					}
				    }
				    next MAIN;
				} else {
                                        $entry->{$_} = $1;
                                }
                        } elsif ($check && $_ ne 'Switch' && $_ ne 'STATUS') {
			        $desc =~ s/^/  /mg;
                                warn "Parse error when reading $file: Package ".(defined($entry->{Package}) ? $entry->{Package} : "<unknown>").": missing \`$_' field\nDescription follows:\n$desc\n";
#                                next MAIN;
                        }
                }
                foreach (@{$self->{array1}}) {
                        if ($desc =~ m/(^|\n)$_:\n(.+?)(\n\S|$)/s) {
                                $text = $2;
                                $text =~ s/^ //mg;
                                my @list = split(/\n\./, $text);
                                $entry->{$_} = \@list;
                        }
                }
                foreach (@{$self->{array2}}) {
                        if ($desc =~ m/(^|\n)$_:\n(.+?)(\n\S|$)/s) {
                                $text = $2;
                                $text =~ s/^ //mg;
                                my @list = ();
                                foreach my $line (split(/\n/, $text)) {
                                        my @list2 = split('!', $line);
                                        push(@list, \@list2);
                                }
                                $entry->{$_} = \@list;
                        }
                }
                if (defined $entry) {
                $self->{data}->{$entry->{Package}} = $entry;
                }
                last if $last_item;
        }
        close DB;
        return defined($self->{data}->{''}->{Date});
}

=item write

Write database into file.

   $l10n_db->write("foo");

=cut

sub write {
        my $self = shift;
        my $file = shift;
        my ($text, $line);

        my $dir  = $file;
        File::Path::mkpath($dir, 0, 0755)
           if ($dir  =~ s#/+[^/]*$## && !-d $dir);
    
        if ($file =~ m/\.gz$/) {
                open (DB,"| gzip -c > $file")
                        || die "Unable to write to $file: $!\n";
        } else {
                open (DB,"> $file")
                        || die "Unable to write to $file: $!\n";
        }

        $self->set_date(sprintf "%d-%02d-%02d", 
	                        Time::localtime::localtime->year() + 1900, 
	                        Time::localtime::localtime->mon() + 1, 
	                        Time::localtime::localtime->mday);
        print DB "Package:\n";
        foreach (@{$self->{headers}}) {
	    next unless defined($self->{data}->{''}->{$_});
	    print DB $_.": ".$self->{data}->{''}->{$_}."\n";
	}
        print DB "\n";
        foreach my $pkg (sort keys %{$self->{data}}) {
	        next if $pkg eq ''; # skip headers
                foreach (@{$self->{scalar}}) {
                        next unless defined($self->{data}->{$pkg}->{$_});
                        print DB $_.": ".$self->{data}->{$pkg}->{$_}."\n";
                }
                foreach (@{$self->{array1}}) {
                        next unless defined($self->{data}->{$pkg}->{$_});
                        $text = join("\n\.\n", @{$self->{data}->{$pkg}->{$_}})."\n";
                        $text =~ s/\n\n/\n/g;
                        $text =~ s/\n+$//s;
                        $text =~ s/^/ /mg;
                        print DB $_.":\n".$text."\n";
                }
                foreach (@{$self->{array2}}) {
                        next unless defined($self->{data}->{$pkg}->{$_});
                        $text = '';
                        foreach $line (@{$self->{data}->{$pkg}->{$_}}) {
                                $text .= ' '.join('!', @{$line})."\n";
                        }
                        print DB $_.":\n".$text;
                }
                print DB "\n";
        }
        close (DB) || die "Unable to close $file: $!\n";
}

=item list_packages

Returns an array with the list of package names

=cut

sub list_packages {
        my $self = shift;
        return keys %{$self->{data}};
}

=item clear_pkg

Reset info for a given package

   $l10n_db->clear_pkg("foo");

=cut

sub clear_pkg {
        my $self = shift;
        my $pkg  = shift;

        delete $self->{data}->{$pkg};
}

=item set_status

Change the status for the category specified as second argument.

=cut

sub set_status {
    my ($db,$pkg,$type,$file,$date,$status,$translator,$list,$url,$bug_nb) = @_;

    foreach my $line (@{$db->{data}->{$pkg}->{STATUS}}) {
	if (${$line}[0] eq $type
	 && ${$line}[1] eq $file) {
	    ${$line}[2] = $date;
	    ${$line}[3] = $status;
	    ${$line}[4] = $translator;
	    ${$line}[5] = $list;
	    ${$line}[6] = $url;
	    ${$line}[7] = $bug_nb;
	    return
	}
    }
    $db->add_status($pkg,$type,$file,$date,$status,$translator,$list,$url,$bug_nb);
}

=item del_status

Del the package if there was only one status line. 
If a reference to a statusline is provided, it removes the first found
It should remove the right line from the DB, and empty the package if nothing else is left.

=cut

sub del_status {
    my ($db,$pkg,$type,$statusline) = @_;
    if (scalar @{$db->{data}->{$pkg}->{STATUS}} == 1) {
	$db->clear_pkg($pkg);
    } elsif ($statusline) {
	my $ok;
	for (my $i=0; $i < @{$db->{data}->{$pkg}->{STATUS}}; $i++) {
	    my @a = @$statusline;
	    my @b = @{$db->{data}->{$pkg}->{STATUS}->[$i]};
	    $ok = 1;
	    while (scalar @a) {
		next if (shift(@a) eq shift(@b));
		$ok = 0;
		last;
	    }
	    next unless $ok;
	    splice @{$db->{data}->{$pkg}->{STATUS}}, $i, 1;
	    last;
	}
	print "Cannot del_status, statusline not found\n" unless $ok;
    } else {
	print "Ups, sorry, cannot del_status when there is more than one status field in the pkg\n";
    }
#    foreach my $line (@{$db->{data}->{$pkg}->{STATUS}}) {
#	if (${$line}[0] eq $type) {
#	    print "Do not remove $type from $pkg since it's not implemented yet\n";
#        }
#    }
}


=item get_header

Returns the value of the specified header

=cut

sub get_header {
#    print "get $_[1] -> ".($_[0]->{data}->{''}->{$_[1]})."\n";
    return $_[0]->{data}->{''}->{$_[1]};
}

=item set_header

Sets the specified header to the specified value

=cut

sub set_header {
#    print "set $_[1] -> $_[2]\n";
    $_[0]->{data}->{''}->{$_[1]} = $_[2];
}


=item get_date

Returns date of generation

=cut

sub get_date {
    return get_header($_[0],'Date');
}

=item set_date

Sets the date of generation

=cut

sub set_date {
    set_header($_[0],'Date',$_[1]);
}


=back

=head2 DATA MANIPULATION

Data about packages can be classified within scalar values (C<package>,
C<version>, C<section>, C<priority>, C<maintainer>, C<pooldir>, C<type>,
C<upstream>), arrays (C<errors>, C<catgets>, C<gettext>), and arrays of
arrays (C<nls>, C<po>, C<po4a>, C<templates>, C<podebconf>, C<man>, C<menu>
and C<desktop>).
Each field has a method with the same name to get and set it, e.g.

   $section = $l10n_db->section($pkg);
   $l10n_db->section($pkg, "libs");

The first line get the section associated with the package in C<$pkg>,
whereas the second set it to C<libs>.

Two other methods are also defined to access those data, by prefixing
field name by C<has_> and C<add_>.  The former is used to ask whether
this field is defined in database, and the latter appends values for
arrays or arrays of arrays.

   if ($l10n_db->has_templates($pkg)) {
           print "Package $pkg has Debconf templates\n";
   }
   $l10n_db->add_po($pkg, 'po/fr.po', 'fr', '42t0f0u', 'po/adduser_3.42_po_fr.po');

=head1 AUTHOR

Copyright (C) 2001-2004  Denis Barbier <barbier@debian.org>
Copyright (C) 2004       Martin Quinson <enough@spam>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut

1;

