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

my ($pkg, $line, $file, $lang);
foreach $pkg ($data->list_packages()) {
        if ($data->has_po($pkg)) {
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

