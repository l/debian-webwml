#   To translate the names of the languages, you have to modify 
#         $(ENGLISHDIR)/template/debian/language_names.wml
#   which is done for this purpose

#use wml::debian::language_names
#use wml::scripts::l10nheader

#include "$(ENGLISHDIR)/international/l10n/dtc.def"
#include "$(ENGLISHDIR)/international/l10n/scripts/init.pl"
#include "$(ENGLISHDIR)/international/l10n/scripts/ranking.pl"

<table border=1>
<tr>
  <td bgcolor="#ddddd5" align=center><Rank></td>
  <td bgcolor="#ddddd5" align=center><Language></td>
  <td bgcolor="#ddddd5" align=center><Score></td>
  <td bgcolor="#ddddd5" align=center><nbpkg></td>
  <td bgcolor="#ddddd5" align=center><avgl10n></td>
</tr>

<:
$cur_lang = "$(CUR_LANG)";
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
	$str .= "</td><td><a href=\"l10n-lang#$lang\">";
	print $str;
	language_name($lang);
	$str = "</a><td>$score<td>$nb_per_lang{$lang}<td>";
	$str .= l10n_output($average{$lang})."\n";
	$str =~ s/<(td)/<$1 align=center/g;
	print $str;
    }
}
:>

</table>

