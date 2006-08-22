#!/usr/bin/perl

sub catfile {
    my $a = "";
    open(F, shift) || return "";
    while (<F>) { s/\r//g; trim; if (not m/^#/) { $a .= $_; } };
    close(F);
    return $a;
}

$original = "english";
$translation = "german";
$origfile = "links.en.txt";
$transfile = "links.de.txt";

open FR, ">$transfile" || die "Can't create file";
open FE, ">$origfile" || die "Can't create file";

@list = `find $translation/ -name *.wml -type f -print`;

foreach $rus (@list) {
    chomp($rus);
    ($eng = $rus) =~ s{$translation}{$original};
    ($f = $rus) =~ s{$translation/}{};

    $rrus = catfile($rus);
    $rrus =~ s{/\n}{}g;
    $rrus =~ s{\n}{ }g;
    @lrus = ();
    $rrus =~ s{<[aA]\s*[hH][rR][eE][fF]=(.*?)>}{
	push @lrus, "$f: $1"; $1
    }gse;
    foreach (sort @lrus) { print FR "$_\n"; }

    $reng = catfile($eng);
    $reng =~ s{/\n}{}g;
    $reng =~ s{\n}{ }g;
    @leng = ();
    $reng =~ s{<[aA]\s*[hH][rR][eE][fF]=(.*?)>}{
	push @leng, "$f: $1"; $1
    }gse;
    foreach (sort @leng) { print FE "$_\n"; }
}

close FE;
close FR;

exec("diff -u $transfile $origfile > links.diff");
