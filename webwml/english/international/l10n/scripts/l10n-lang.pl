#include "../../../english/international/l10n/scripts/l10nheader.wml"
#include "../../../english/international/l10n/dtc.def"

<:
$cur_lang = "$(CUR_LANG)";

open(IN,"../data/langs")||open(IN,"$(ENGLISHDIR)/international/l10n/data/langs")||die ("Can't read the list of languages.\nThe makefile is still faulty.\nRun make data/langs manually and report the bug");

print "<ul>\n";
foreach $line (<IN>){
    $line =~ m,^([^:]*):(.*)$,;
    foreach (split(/ /,$2)) {
	$mylangs{$1}{$_}=1;
    }
}
print "<table border=1 cellpadding=0 cellspacing=0>";
$header =~ s/<(td)/<$1 bgcolor="#ddddd5" align=center/g;
print $header;
$sinceheader = 0;

foreach $lang (sort keys %{$mylangs{all}}) {
    next if $lang eq "";
    if ($since_header++ >25) {
	print $header;
	$since_header=0;
    }

    print "<tr><td><a name=$lang>";
    language_name($lang);
    print "</a>";
    if (defined ($mylangs{'po'}{$lang})) {
	print "<td align=center><a href=\"po-$lang\"><yes></a> ";
    } else {
	print "<td align=center><no>";
    }
    if (defined ($mylangs{'templates'}{$lang})) {
	print "<td align=center><a href=\"templates-$lang\"><yes></a> ";
    } else {
	print "<td align=center><no>";
    }
    print "</tr>\n";
}
print "</table>";

:>

