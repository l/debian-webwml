<!-- to translate the names of the languages, you have to modify 
    "../../english/template/debian/language_names.wml", which is done for this purpose -->
#include "../../english/template/debian/language_names.wml"
#include "../../english/international/l10n/dtc.def"
<PERL>
#include "../../english/international/l10n/scripts/init.pl"
#include "../../english/international/l10n/scripts/ranking.pl"

$cur_lang = "$(CUR_LANG)";
$header = "<tr><td><Rank><td><Language><td><Score><td><nbpkg><td><avgl10n>\n";
$header =~ s/<td/<td bgcolor="#ddddd5" align=center/g;
print "<table border=1>".$header;
my @langs;
my $rank = 0;
my $score;
my $exaequo;

score_init();
foreach $score (sort {$b <=> $a} keys %scores) {
    $exaequo=0;
    $rank++;
    $str = $scores{$score};
    @langs = split('\|',$str);
    if (@langs == 0) {
	push @langs, $str;
    }
    foreach $lang (sort @langs) {
	if ($exaequo) {
	    $str = "<tr><td>&nbsp;";
	    $rank++;
	} else {
	    $str = "<tr><td>$rank";
	    $exaequo = 1;
	}
	$str .= "<td>";
	if (defined  $trans{language2code($cur_lang)}{lc(code2language($lang))}) {
	    $str .= ucfirst($trans{language2code($cur_lang)}{lc(code2language($lang))});
	} else {
	    $str .= code2language($lang);
	}
	$str .= "<td>$score<td>$nb_per_lang{$lang}<td>";
	$str .= l10n_output($average{$lang})."\n";
	$str =~ s/<td/<td align=center/g;
	print $str;
    }
}
print $header."</table>\n";

</PERL>




