#!/usr/bin/perl -w

#  Extract languages found in data/unstable and store them
#  in a file

use lib ($0 =~ m|(.*)/|, $1 or ".") ."/../../../../Perl";
use Webwml::L10n::Db;

my $data = Webwml::L10n::Db->new();

foreach (@ARGV) {
        $data->read($_);
}

my $langs = {
        po              => {},
        templates       => {},
        all             => {},
};

#   These packages use a RFC1766 naming convention for language codes
#   which makes output page look ugly.  Do not display them until a
#   better solution is found
#   This list is defined in list-languages.pl and gen-files.pl
my %skip_po = (
        abiword         => 1,
        squirrelmail    => 1,
        #   Horde related packages
        horde2          => 1,
        imp3            => 1,
        kronolith       => 1,
        mnemo           => 1,
        nag             => 1,
        'sork-passwd'   => 1,
        turba           => 1,
);

my ($pkg, $line, $file, $lang);
foreach $pkg ($data->list_packages()) {
        if ($data->has_po($pkg) && !defined($skip_po{$pkg})) {
                foreach $line (@{$data->po($pkg)}) {
                        ($file, $lang) = @{$line};
                        $langs->{po}->{$lang}  = 1;
                        $langs->{all}->{$lang} = 1;
                }
        }
        if ($data->has_templates($pkg)) {
                foreach $line (@{$data->templates($pkg)}) {
                        ($file, $lang) = @{$line};
                        next unless $lang ne '' && $lang ne '_';
                        $langs->{templates}->{$lang} = 1;
                        $langs->{all}->{$lang} = 1;
                }
        }
}

foreach my $material (sort keys %$langs) {
        print "$material: ";
        print join(" ", sort keys %{$langs->{$material}});
        print "\n";
}

