#! /usr/bin/perl

open(TRANS, '../../../check_trans.pl -v -C ../../.. 2>&1 |');
print "\$automatic = {\n";

$line = <TRANS>;
while (chop($line)) {
        ($line =~ m/Checking\s+(\S+), English revision ([\d.]+)/) || do {
                $line = <TRANS> || last;
                redo;
        };
        ($doc, $rev) = ($1, $2);
        $doc =~ s/,$//;
        $doc =~ s/\.wml$//;
        $doc =~ s#^french/##;
        print "'$doc' => {\n";
        print "\t'original_revision' => '$rev',\n";
        $status = 1;

        while ($line = <TRANS> and $line !~ m/Checking/) {
                if ($line =~ m/Missing/) {
                        $status = 1;
                        last;
                } elsif ($line =~ s/Found translation for ([\d.]+)//) {
                        print "\t'base_revision' => '$1',\n";
                        $status = $rev eq $1 ? 4 : 3;
                } elsif ($line =~ m/Translated by (.*)/) {
                        print "\t'translation_maintainer' => ['$1'],\n";
                }
        }
        print "\t'status' => $status,\n";
        print "},\n";
}
close(TRANS);

print "}; 1;\n";

1;

