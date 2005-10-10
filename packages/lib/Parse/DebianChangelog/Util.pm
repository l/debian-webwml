#
# Parse::DebianChangelog::Util
#
# Copyright 1996 Ian Jackson
# Copyright 2005 Frank Lichtenheld <frank@lichtenheld.de>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

=head1 NAME

Parse::DebianChangelog::Util - utility functions for parsing Debian changelogs

=head1 SYNOPSIS

=head1 DESCRIPTION

This is currently only used internally by Parse::DebianChangelog and
is not yet documented. There may be still API changes until this module
is finalized.

=cut

package Parse::DebianChangelog::Util;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
		 find_closes
		 data2rfc822
		 data2rfc822_mult
		 get_dpkg_changes
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

sub find_closes {
    my $changes = shift;
    my @closes = ();

    while ($changes && ($changes =~ /closes:\s*(?:bug)?\#?\s?\d+(?:,\s*(?:bug)?\#?\s?\d+)*/ig)) {
	push(@closes, $& =~ /\#?\s?(\d+)/g);
    }

    @closes = sort { $a <=> $b } @closes;
    return \@closes;
}

sub data2rfc822_mult {
    my ($data, $fieldimps) = @_;
    my @rfc822 = ();

    foreach my $entry (@$data) {
	push @rfc822, data2rfc822($entry,$fieldimps);
    }

    return join "\n", @rfc822;
}

sub data2rfc822 {
    my ($data, $fieldimps) = @_;
    my $rfc822_str = '';

# based on /usr/lib/dpkg/controllib.pl
    for my $f (sort { $fieldimps->{$b} <=> $fieldimps->{$a} } keys %$data) {
	my $v= $data->{$f};
	$v =~ m/\S/o || next; # delete whitespace-only fields
	$v =~ m/\n\S/o && warn("field $f has newline then non whitespace >$v<");
	$v =~ m/\n[ \t]*\n/o && warn("field $f has blank lines >$v<");
	$v =~ m/\n$/o && warn("field $f has trailing newline >$v<");
	$v =~ s/\$\{\}/\$/go;
	$rfc822_str .= "$f: $v\n";
    }

    return $rfc822_str;
}

sub get_dpkg_changes {
    my $changes = "\n $_[0]->{Header}\n .\n$_[0]->{Changes}";
    chomp $changes;
    $changes =~ s/^ $/ ./mgo;
    return $changes;
}

1;
__END__
=head1 SEE ALSO

Parse::DebianChangelog

=head1 AUTHOR

Frank Lichtenheld, E<lt>frank@lichtenheld.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Frank Lichtenheld

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

=cut
