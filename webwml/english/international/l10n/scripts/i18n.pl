#include "../../english/international/l10n/dtc.def"
<PERL>
#include "../../english/international/l10n/scripts/init.pl"
$str = "<table border=1><tr><td><category><td colspan=2><I18N-ED><td colspan=2><Catalogs><br><I18N-prcent><td colspan=3><Organisation><br><I18N-prcent>\n";
$str =~ s/<td/<td align=center BGCOLOR="#ddddd5"/g;
print $str;
$str = "<tr><td>&nbsp;<td><total><td><I18N-ED><td>po<td>nls<td>gnu<td>nls<td><full>\n";
$str =~ s/<td>/<td align=center BGCOLOR="#ddddd5">/g;
print $str;
$str = "<tr><td><wholeArch>".stats_output()."</td>"; #close the last cell to have the "to bold" patern matching this one too
$str =~ s/<td/<td BGCOLOR="#eed0ee"/g; # change background
$str =~ s/>([^<>]+?)</><b>$1<\/b></g;  #change to bold
print $str;

PRIORITY: foreach $priority (sort keys %priorities) {
    ## Stats for this priority only
    stats_clear();
    foreach $pkg (sort keys %data) {
	if ($data{$pkg}{'priority'} eq $priority) {
	    stats_pkg($pkg);
	}
    }
    next PRIORITY if ($stats{"total"} == 0);
    $str = "<tr><td>&nbsp;&nbsp;$priority".stats_output();
    $str =~ s/<td/<td bgcolor='#eee0ee'/g; # change background
    print $str;

    next PRIORITY if ($priority eq "unknown");

    SECTION: foreach $section (sort keys %sections) {
	next SECTION if ($section eq "unknown");
	## read the stats for this priority and section only
	stats_clear();
	foreach $pkg (sort keys %data) {
	    if ($data{$pkg}{'priority'} eq $priority && 
		$data{$pkg}{'section'} eq $section) {
		stats_pkg($pkg);
	    }
	}
	## output the stats for this priority and section
	next SECTION if ($stats{"total"} == 0);
	print "<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;$priority/$section".(stats_output());
    }
}    
$str = "<tr><td>&nbsp;<td><total><td><i18n-ed><td>po<td>nls<td>gnu<td>nls<td><full>\n";
$str =~ s/<td>/<td align=center BGCOLOR="#ddddd5">/g;
print $str;
$str = "<tr><td><category><td colspan=2><I18N-ED><td colspan=2><Catalogs><br><I18N-prcent><td colspan=3><Organisation><br><I18N-prcent>\n";
$str =~ s/<td/<td align=center BGCOLOR="#ddddd5"/g;
print $str;
</PERL>
</table>
