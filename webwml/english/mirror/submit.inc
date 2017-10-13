#use wml::std::tags
#use wml::debian::common_tags

<bind-gettext-domain domain="others" />

<define-tag sameastheabove whitespace=delete>
  <gettext domain="others">same as the above</gettext>
</define-tag>

<define-tag form-action>
<form method=post action="%2">
</define-tag>

<define-tag tablerow>
	<tr><td>%0: </td><td><input type="text" name="%1" id="%1" size="%2"></td></tr>
</define-tag>

<define-tag tablerowdef>
	<tr><td>%0: </td><td><input type="text" name="%1" id="%1" size="%2" value="%3">%4</td></tr>
</define-tag>

#include "$(ENGLISHDIR)/releases/sid/archive.data"
#include "$(ENGLISHDIR)/releases/arches.data"

<define-tag archlist>
<div id="archlist">
<:
my $na = scalar @arches; $na = int($na / 4 + .5);
my $i = 0;
foreach my $a (@arches) {
  my $aname = $arches{$a}; $aname =~ s, ,\&nbsp\;,g;
  print "<label id=arch_".$a." style=\"white-space: pre\"><input type=checkbox id=cbarch_".$a." name=architectures value=".$a.">&nbsp;".$aname."&nbsp;[".$a."]</label>";
  $i++;
  if ($i != 0 && $i % $na == 0) {
    print "<br>\n";
  } else {
    print " &nbsp;\n";
  }
}
:>
</div>
</define-tag>

<script type="text/javascript">
function allarches() {
  aa = document.getElementById('allarch');
  al = document.getElementById('archlist');
  if (aa.checked) {
    al.style.color = "#b0b0b0";
    al.style.backgroundColor = "#e0e0e0";
  } else {
    al.style.color = "#000000";
    al.style.backgroundColor = "#ffffff";
  }
  var locarches = new Object();
<: 
  foreach my $a (@arches) {
    print "  locarches[\'$a\'] = \'cbarch_$a\';\n";
  }
:>
  for ( a in locarches ) {
    ele = document.getElementById(locarches[a]);
    if (ele.checked == false)
      ele.checked = true;
  }
}
</script>

#use wml::debian::countries

<define-tag countrylist>
<: country_list() :>
</define-tag>
