#include "../../../english/international/l10n/dtc.def"
#include "../../../english/international/l10n/scripts/init.pl"

<table border=1>
<tr>
  <td align=center BGCOLOR="#ddddd5"><category></td>
  <td colspan=2 align=center BGCOLOR="#ddddd5"><I18N-ED></td>
  <td colspan=2 align=center BGCOLOR="#ddddd5"><Catalogs><br><I18N-prcent></td>
  <td colspan=3 align=center BGCOLOR="#ddddd5"><Organisation><br><I18N-prcent></td>
</tr>
<tr>
  <td align=center BGCOLOR="#ddddd5">&nbsp;</td>
  <td align=center BGCOLOR="#ddddd5"><total></td>
  <td align=center BGCOLOR="#ddddd5"><I18N-ED></td>
  <td align=center BGCOLOR="#ddddd5">po</td>
  <td align=center BGCOLOR="#ddddd5">nls</td>
  <td align=center BGCOLOR="#ddddd5">gnu</td>
  <td align=center BGCOLOR="#ddddd5">nls</td>
  <td align=center BGCOLOR="#ddddd5"><full></td>
</tr>
<tr>
<PERL>
  $str = "<td BGCOLOR=\"#eed0ee\"><wholeArch>".stats_output()."</td>\n";
  $str =~ s|>([^<>]+?)<|><b>$1</b><|g;  #change to bold
  print $str;
</PERL>

<PERL>
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
    $str =~ s/<(td)/<$1 bgcolor='#eee0ee'/g; # change background
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
</PERL>
<tr>
  <td align=center BGCOLOR="#ddddd5">&nbsp;</td>
  <td align=center BGCOLOR="#ddddd5"><total></td>
  <td align=center BGCOLOR="#ddddd5"><i18n-ed></td>
  <td align=center BGCOLOR="#ddddd5">po</td>
  <td align=center BGCOLOR="#ddddd5">nls</td>
  <td align=center BGCOLOR="#ddddd5">gnu</td>
  <td align=center BGCOLOR="#ddddd5">nls</td>
  <td align=center BGCOLOR="#ddddd5"><full></td>
</tr>
<tr>
  <td align=center BGCOLOR="#ddddd5"><category></td>
  <td colspan=2 align=center BGCOLOR="#ddddd5"><I18N-ED></td>
  <td colspan=2 align=center BGCOLOR="#ddddd5"><Catalogs><br><I18N-prcent></td>
  <td colspan=3 align=center BGCOLOR="#ddddd5"><Organisation><br><I18N-prcent></td>
</tr>
</table>
