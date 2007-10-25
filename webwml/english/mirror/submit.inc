
<define-tag tablerow>
	<tr><td>%0: </td><td><input type="text" name="%1" id="%1" size="%2"></td></tr>
</define-tag>

<define-tag tr-upstream-give>
  <tr><td>%0: </td><td><input type="text" name="%1" id="%1" size="%2" onchange="giveau('%1')" onsubmit="giveau('%1')"></td></tr>
</define-tag>

<define-tag tr-upstream-take>
  <tr><td>%0: </td><td>
  <input type="text" name="%1" id="%1" size="%2">
  <label><input id="cb_%1" name="cb_%1" type="checkbox" onclick="takeau('%1')">&nbsp;<em>same as the above</em></label>
  </td></tr>
</define-tag>

<script type="text/javascript">
function takeau(element) {
  au = document.getElementById('archive-upstream');
  cbn = 'cb_' + element;
  cbe = document.getElementById(cbn);
  xu = document.getElementById(element);
  if (cbe.checked) {
    xu.style.color = "#b0b0b0";
    xu.style.backgroundColor = "#e0e0e0";
    xu.value = au.value;
  } else {
    xu.style.color = "#000000";
    xu.style.backgroundColor = "#ffffff";
  }
}
function giveau(element) {
  au = document.getElementById('archive-upstream');
  vu = document.getElementById('volatile-upstream');
  vuc = document.getElementById('cb_volatile-upstream');
  if (vuc.checked) {
    vu.value = au.value;
  }
  su = document.getElementById('security-upstream');
  suc = document.getElementById('cb_security-upstream');
  if (suc.checked) {
    su.value = au.value;
  }
  cu = document.getElementById('cdimage-upstream');
  cuc = document.getElementById('cb_cdimage-upstream');
  if (cuc.checked) {
    cu.value = au.value;
  }
}
</script>

#include "$(ENGLISHDIR)/releases/sid/archive.data"

<define-tag archlist>
<div id="archlist">
<:
my $na = scalar keys %arches; $na = int($na / 3 + .5);
foreach my $a (sort keys %arches) {
  $i++;
  my $aname = $arches{$a}; $aname =~ s, ,\&nbsp\;,g;
  print "<br>\n" if ($i % $na == 0);
  print "<label id=arch_".$a." style=\"white-space: pre\"><input type=checkbox id=cbarch_".$a." name=architectures value=".$a.">&nbsp;".$aname."&nbsp;(".$a.")</label> &nbsp;\n";
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
  var arches = new Object();
<: 
  foreach my $a (sort keys %arches) {
    print "  arches[\'$a\'] = \'cbarch_$a\';\n";
  }
:>
  for ( a in arches ) {
    ele = document.getElementById(arches[a]);
    if (ele.checked == false)
      ele.checked = true;
  }
}
</script>

#use wml::debian::countries_all

<define-tag countrylist>
<: country_list() :>
</define-tag>
