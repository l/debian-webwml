#include "../../../english/international/l10n/dtc.def"
#include "../../../english/international/l10n/scripts/init.pl"

<:
my $nb; #counter
my @strs; #all strings of a <error|warning>
my $line; #one string of above
foreach $pkg (sort keys %data) {
    next unless (defined($data{$pkg}{'errors'}) || defined($data{$pkg}{'warnings'})); 
    print "<a name='$pkg'><h2><Package> $pkg</h2><ul>\n";
    if (defined($data{$pkg}{'errors'})) {
	print "<li><Errors><ul>\n";
	for ($nb=0;$nb<@{$data{$pkg}{"errors"}};$nb++) {
	    @strs = split (/\n/,$data{$pkg}{"errors"}[$nb]);
	    $line = shift @strs;
	    print "<li>$line<ul>\n";
	    while ($line = shift @strs) {
		print "<li>$line\n";
	    }
	    print "</ul>\n";
	}
	print "</ul>\n";
    }
    if (defined($data{$pkg}{'warnings'})) {
	print "<li><Warnings><ul>\n";
	for ($nb=0;$nb<@{$data{$pkg}{"warnings"}};$nb++) {
	    @strs = split (/\n/,$data{$pkg}{"warnings"}[$nb]);
	    $line = shift @strs;
	    print "<li>$line<ul>\n";
	    while ($line = shift @strs) {
		print "<li>$line\n";
	    }
	    print "</ul>\n";
	}
	print "</ul>\n";
    }
    print "</ul>\n";
}
:>
