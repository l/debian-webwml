#include "../../../english/international/l10n/dtc.def"
#include "../../../english/international/l10n/scripts/init.pl"
#include "../../../english/international/l10n/scripts/ranking.pl"

<table border=1 cellpadding=0 cellspacing=0>

<:
###
### Makes the big table
###
my $str;	
#my $nb_i18n; #total number of i18n'ed packages
my $header; # header of the table
my $since_header=0;

my $header = "<tr><td><package></td><td><orgAbrev></td>";
foreach $lang (sort keys %l10nlangs) {
    $header .= "<td>$lang</td>";
}
$header .= "\n";
$header =~ s/<(td)/<$1 BGCOLOR="#ddddd5" align=center/g; # change background and center
print $header;
## output the list of packages
score_init();
foreach $pkg (sort keys %data) {
    if (defined($data{$pkg}{'stats'})) {
	print "<tr><td>";
	if (defined($data{$pkg}{'errors'}) || defined($data{$pkg}{'warnings'})){
	    print "<a href='l10n-packages#$pkg'>$pkg</a>";
	} else {
	    print "$pkg";
	}
	print "<td>$data{$pkg}{'type'}";
	foreach $lang (sort keys %l10nlangs) {
	    print "<td>";
	    if (defined($data{$pkg}{'stats'}{$lang})) {
		print  l10n_output($data{$pkg}{'stats'}{$lang});
	    } else {
		print "--";
	    }
	}
	print "\n";
	#print header if needed
	$since_header++;
	if ($since_header == 15) {
	    $since_header=0;
	    print $header;
	}
    }
}
print $header if ($since_header > 0);

# output the average l10n of each language
$str = "<tr><td colspan=2 align=center><AVG>";
foreach $lang (sort keys %l10nlangs) {
    $str .= "<td>".l10n_output($average{$lang});
}
$str =~ s/>([^<>]+?)</><b>$1<\/b></g;  #change to bold
print $str;
# output the number of package l10n in each language
$str = "<tr><td colspan=2 align=center><nbpkg>";
foreach $lang (sort keys %l10nlangs) {
    $str .= "<td align=center>".$nb_per_lang{$lang};
}
$str .= "</td>"; # to have the next regexp matching the last cell
$str =~ s/>([^<>]+?)</><b>$1<\/b></g;  #change to bold
print $str;
#output the score of each language
$str = "<tr><td colspan=2 align=center><b><SCORE></b>";
foreach $lang (sort keys %l10nlangs) {
    $str .= "<td align=center>".score_output($lang);
}
print $str;

###
### Defines some usefull functions
###
sub score_output {
    my $lang= shift;
    my $t = "0";
    my $u = "0";
    my $f = "0";
    my $percent;
    my $res;

    if ($average{$lang} =~ /([0-9]*)t/) {  $t=$1;  }
    if ($average{$lang} =~ /([0-9]*)u/) {  $u=$1;  }
    if ($average{$lang} =~ /([0-9]*)f/) {  $f=$1;  }

    if ($t+$u+$f == 0) {
	return "Err";
    }
    $res = $t/($t+$u+$f) * $nb_per_lang{$lang};
    $res =~ s/^([0-9]*\..).*/$1/;
    if (defined($scores{$res})) {
	$scores{$res} .= "|$lang";
    } else {
	$scores{$res} = "$lang";
    }

    return "<b>".$res."</b>";
}

###
### End of the file
###
:>

</table>
<br><br>
