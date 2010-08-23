<:
my %pseudos = ();
my $file = "pseudo-packages.translated-description";

# Read translated descriptions if possible
if (open I, $file) {
  while (<I>) {
    if (/^(\S+)\s+(.+)$/) {
      my $foo = $2;
      ($pseudos{$1} = $foo) =~ s/&/&amp;/g;
    }
  }
  close I or die "Can't close translated descriptions file $file: $!\n";
}

# now try English to fill in the blanks
$file = "$(ENGLISHDIR)/Bugs/pseudo-packages.description";
open I, "$file" or die "Can't open $file file: $!\n";
while (<I>) {
  if (/^(\S+)\s+(.+)$/) {
    my $foo = $2;
    if (not exists $pseudos{$1}) {
      ($pseudos{$1} = $foo) =~ s/&/&amp;/g;
    }
  }
}
close I or die "Can't close descriptions file $file: $!\n";

%pseudos || die "%pseudos is not set -- empty $file file?\n";
foreach $a (sort keys %pseudos) {
  if ($a ne "spam" && $a ne "slink-cd") {
    print "<p><code><a href=\"http://bugs.debian.org/$a\">$a</a></code> &mdash; $pseudos{$a}\n";
  }
}
:>
