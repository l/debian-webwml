<:
# English pseudopackages descriptions
my $file = "$(ENGLISHDIR)/Bugs/pseudo-packages.description";
# Translated pseudopkgs descriptions
my $tfile= "pseudo-packages.translated-description";

my %pseudos = ();
my %tpseudos= ();
open I, "$file" or die "Can't open $file file: $!\n";

# Read translated descriptions if possible
if (open TI, $tfile) {
  while (<TI>) {
    if (/^(\S+)\s+(.+)$/) {
      my $foo = $2;
      ($tpseudos{$1} = $foo) =~ s/&/&amp;/g;
    }
  }
  close TI or die "Can't close translated descriptions file $tfile: $!\n";
}

while (<I>) {
  if (/^(\S+)\s+(.+)$/) {
    my $foo = $2;
    ($pseudos{$1} = $foo) =~ s/&/&amp;/g;
  }
}
close I;
%pseudos || die "%pseudos is not set -- empty $file file?\n";
foreach $a (sort keys %pseudos) {
  if ($a ne "spam" && $a ne "slink-cd") {
    my $b = $tpseudos{$a} || $pseudos{$a};
    print "<p><code><a href=\"http://bugs.debian.org/$a\">$a</a></code> &mdash; $b\n";
  }
}
:>
