#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="bugs" />

<ul>

  <li><small><gettext domain="bugs">Flags:</gettext>
  <label><input type="radio" name="archive" value="no" checked>
    <gettext domain="bugs">active bugs</gettext></label>
  <label><input type="radio" name="archive" value="yes">
     <gettext domain="bugs">archived bugs</gettext></label>
  <br>
  <label><input type="checkbox" name="repeatmerged" value="no">
     <gettext domain="bugs">display merged bugs only once</gettext></label>
  <label><input type="checkbox" name="raw" value="yes">
     <gettext domain="bugs">no ordering by status or severity</gettext></label>
  <br>
  <label><input type="checkbox" name="show_list_header" value="no">
     <gettext domain="bugs">don't show table of contents in the header</gettext></label>
  <label><input type="checkbox" name="show_list_footer" value="no">
     <gettext domain="bugs">don't show statistics in the footer</gettext></label>
  </small>

<define-tag oldstable whitespace=delete>
  <gettext domain="bugs">oldstable</gettext>
</define-tag>
<define-tag stable whitespace=delete>
  <gettext domain="bugs">stable</gettext>
</define-tag>
<define-tag proposed-updates whitespace=delete>
  <gettext domain="bugs">proposed-updates</gettext>
</define-tag>
<define-tag testing whitespace=delete>
  <gettext domain="bugs">testing</gettext>
</define-tag>
<define-tag testing-proposed-updates whitespace=delete>
  <gettext domain="bugs">testing-proposed-updates</gettext>
</define-tag>
<define-tag unstable whitespace=delete>
  <gettext domain="bugs">unstable</gettext>
</define-tag>
<define-tag experimental whitespace=delete>
  <gettext domain="bugs">experimental</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Package version:</gettext>
  <label><input type="text" name="version" value="" size="20"></label>
  </small></li>

  <li><small><gettext domain="bugs">Distribution:</gettext>
  <label><input type="radio" name="dist" value="oldstable"><oldstable></label>
  <label><input type="radio" name="dist" value="stable"><stable></label>
  <label><input type="radio" name="dist" value="proposed-updates"><proposed-updates></label>
  <label><input type="radio" name="dist" value="testing"><testing></label>
  <label><input type="radio" name="dist" value="testing-proposed-updates"><testing-proposed-updates></label>
  <label><input type="radio" name="dist" value="unstable" checked><unstable></label>
  <label><input type="radio" name="dist" value="experimental"><experimental></label>
  </small></li>

  <li><small><gettext domain="bugs">Reverse order of:</gettext>
  <label><input type="checkbox" name="pend-rev" value="yes">
    <gettext domain="bugs">status</gettext></label>
  <label><input type="checkbox" name="sev-rev" value="yes">
    <gettext domain="bugs">severities</gettext></label>
  <label><input type="checkbox" name="bug-rev" value="yes">
    <gettext domain="bugs">bugs</gettext></label>
  </small></li>

<define-tag open whitespace=delete>
  <gettext domain="bugs">open</gettext>
</define-tag>
<define-tag forwarded whitespace=delete>
  <gettext domain="bugs">forwarded</gettext>
</define-tag>
<define-tag pending whitespace=delete>
  <gettext domain="bugs">pending</gettext>
</define-tag>
<define-tag fixed whitespace=delete>
  <gettext domain="bugs">fixed</gettext>
</define-tag>
<define-tag done whitespace=delete>
  <gettext domain="bugs">done</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Include status:</gettext>
  <label><input type="checkbox" name="pend-inc" value="pending"><open></label>
  <label><input type="checkbox" name="pend-inc" value="forwarded"><forwarded></label>
  <label><input type="checkbox" name="pend-inc" value="pending-fixed"><pending></label>
  <label><input type="checkbox" name="pend-inc" value="fixed"><fixed></label>
  <label><input type="checkbox" name="pend-inc" value="done"><done></label>
  </small></li>

  <li><small><gettext domain="bugs">Exclude status:</gettext>
  <label><input type="checkbox" name="pend-exc" value="pending"><open></label>
  <label><input type="checkbox" name="pend-exc" value="forwarded"><forwarded></label>
  <label><input type="checkbox" name="pend-exc" value="pending-fixed"><pending></label>
  <label><input type="checkbox" name="pend-exc" value="fixed"><fixed></label>
  <label><input type="checkbox" name="pend-exc" value="done"><done></label>
  </small></li>

<define-tag critical whitespace=delete>
  <gettext domain="bugs">critical</gettext>
</define-tag>
<define-tag grave whitespace=delete>
  <gettext domain="bugs">grave</gettext>
</define-tag>
<define-tag serious whitespace=delete>
  <gettext domain="bugs">serious</gettext>
</define-tag>
<define-tag important whitespace=delete>
  <gettext domain="bugs">important</gettext>
</define-tag>
<define-tag normal whitespace=delete>
  <gettext domain="bugs">normal</gettext>
</define-tag>
<define-tag minor whitespace=delete>
  <gettext domain="bugs">minor</gettext>
</define-tag>
<define-tag wishlist whitespace=delete>
  <gettext domain="bugs">wishlist</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Include severity:</gettext>
  <label><input type="checkbox" name="sev-inc" value="critical"><critical></label>
  <label><input type="checkbox" name="sev-inc" value="grave"><grave></label>
  <label><input type="checkbox" name="sev-inc" value="serious"><serious></label>
  <label><input type="checkbox" name="sev-inc" value="important"><important></label>
  <label><input type="checkbox" name="sev-inc" value="normal"><normal></label>
  <label><input type="checkbox" name="sev-inc" value="minor"><minor></label>
  <label><input type="checkbox" name="sev-inc" value="wishlist"><wishlist></label>
  <label><input type="checkbox" name="sev-inc" value="fixed"><fixed></label>
  </small></li>

  <li><small><gettext domain="bugs">Exclude severity:</gettext>
  <label><input type="checkbox" name="sev-exc" value="critical"><critical></label>
  <label><input type="checkbox" name="sev-exc" value="grave"><grave></label>
  <label><input type="checkbox" name="sev-exc" value="serious"><serious></label>
  <label><input type="checkbox" name="sev-exc" value="important"><important></label>
  <label><input type="checkbox" name="sev-exc" value="normal"><normal></label>
  <label><input type="checkbox" name="sev-exc" value="minor"><minor></label>
  <label><input type="checkbox" name="sev-exc" value="wishlist"><wishlist></label>
  <label><input type="checkbox" name="sev-exc" value="fixed"><fixed></label>
  </small></li>

# distributions in the usual order, then other tags alphabetically
<define-tag potato whitespace=delete>
  <gettext domain="bugs">potato</gettext>
</define-tag>
<define-tag woody whitespace=delete>
  <gettext domain="bugs">woody</gettext>
</define-tag>
<define-tag sarge whitespace=delete>
  <gettext domain="bugs">sarge</gettext>
</define-tag>
<define-tag sarge-ignore whitespace=delete>
  <gettext domain="bugs">sarge-ignore</gettext>
</define-tag>
<define-tag etch whitespace=delete>
  <gettext domain="bugs">etch</gettext>
</define-tag>
<define-tag etch-ignore whitespace=delete>
  <gettext domain="bugs">etch-ignore</gettext>
</define-tag>
<define-tag sid whitespace=delete>
  <gettext domain="bugs">sid</gettext>
</define-tag>
<define-tag confirmed whitespace=delete>
  <gettext domain="bugs">confirmed</gettext>
</define-tag>
<define-tag d-i whitespace=delete>
  <gettext domain="bugs">d-i</gettext>
</define-tag>
# 'fixed' is defined above
<define-tag fixed-in-experimental whitespace=delete>
  <gettext domain="bugs">fixed-in-experimental</gettext>
</define-tag>
<define-tag fixed-upstream whitespace=delete>
  <gettext domain="bugs">fixed-upstream</gettext>
</define-tag>
<define-tag help whitespace=delete>
  <gettext domain="bugs">help</gettext>
</define-tag>
<define-tag l10n whitespace=delete>
  <gettext domain="bugs">l10n</gettext>
</define-tag>
<define-tag moreinfo whitespace=delete>
  <gettext domain="bugs">moreinfo</gettext>
</define-tag>
<define-tag patch whitespace=delete>
  <gettext domain="bugs">patch</gettext>
</define-tag>
# 'pending' is defined above
<define-tag security whitespace=delete>
  <gettext domain="bugs">security</gettext>
</define-tag>
<define-tag unreproducible whitespace=delete>
  <gettext domain="bugs">unreproducible</gettext>
</define-tag>
<define-tag upstream whitespace=delete>
  <gettext domain="bugs">upstream</gettext>
</define-tag>
<define-tag wontfix whitespace=delete>
  <gettext domain="bugs">wontfix</gettext>
</define-tag>
<define-tag ipv6 whitespace=delete>
  <gettext domain="bugs">ipv6</gettext>
</define-tag>
<define-tag lfs whitespace=delete>
  <gettext domain="bugs">lfs</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Include tag:</gettext>
  <label><input type="checkbox" name="include" value="potato"><potato></label>
  <label><input type="checkbox" name="include" value="woody"><woody></label>
  <label><input type="checkbox" name="include" value="sarge"><sarge></label>
  <label><input type="checkbox" name="include" value="sarge-ignore"><sarge-ignore></label>
  <label><input type="checkbox" name="include" value="etch"><etch></label>
  <label><input type="checkbox" name="include" value="etch-ignore"><etch-ignore></label>
  <label><input type="checkbox" name="include" value="sid"><sid></label>
  <label><input type="checkbox" name="include" value="experimental"><experimental></label>
  <label><input type="checkbox" name="include" value="confirmed"><confirmed></label>
  <label><input type="checkbox" name="include" value="d-i"><d-i></label>
  <label><input type="checkbox" name="include" value="fixed"><fixed></label>
  <label><input type="checkbox" name="include" value="fixed-in-experimental"><fixed-in-experimental></label>
  <label><input type="checkbox" name="include" value="fixed-upstream"><fixed-upstream></label>
  <label><input type="checkbox" name="include" value="help"><help></label>
  <label><input type="checkbox" name="include" value="l10n"><l10n></label>
  <label><input type="checkbox" name="include" value="moreinfo"><moreinfo></label>
  <label><input type="checkbox" name="include" value="patch"><patch></label>
  <label><input type="checkbox" name="include" value="pending"><pending></label>
  <label><input type="checkbox" name="include" value="security"><security></label>
  <label><input type="checkbox" name="include" value="unreproducible"><unreproducible></label>
  <label><input type="checkbox" name="include" value="upstream"><upstream></label>
  <label><input type="checkbox" name="include" value="wontfix"><wontfix></label>
  <label><input type="checkbox" name="include" value="ipv6"><ipv6></label>
  <label><input type="checkbox" name="include" value="lfs"><lfs></label>
  </small></li>

  <li><small><gettext domain="bugs">Exclude tag:</gettext>
  <label><input type="checkbox" name="exclude" value="potato"><potato></label>
  <label><input type="checkbox" name="exclude" value="woody"><woody></label>
  <label><input type="checkbox" name="exclude" value="sarge"><sarge></label>
  <label><input type="checkbox" name="exclude" value="sarge-ignore"><sarge-ignore></label>
  <label><input type="checkbox" name="exclude" value="etch"><etch></label>
  <label><input type="checkbox" name="exclude" value="etch-ignore"><etch-ignore></label>
  <label><input type="checkbox" name="exclude" value="sid"><sid></label>
  <label><input type="checkbox" name="exclude" value="experimental"><experimental></label>
  <label><input type="checkbox" name="exclude" value="confirmed"><confirmed></label>
  <label><input type="checkbox" name="exclude" value="d-i"><d-i></label>
  <label><input type="checkbox" name="exclude" value="fixed"><fixed></label>
  <label><input type="checkbox" name="exclude" value="fixed-in-experimental"><fixed-in-experimental></label>
  <label><input type="checkbox" name="exclude" value="fixed-upstream"><fixed-upstream></label>
  <label><input type="checkbox" name="exclude" value="help"><help></label>
  <label><input type="checkbox" name="exclude" value="l10n"><l10n></label>
  <label><input type="checkbox" name="exclude" value="moreinfo"><moreinfo></label>
  <label><input type="checkbox" name="exclude" value="patch"><patch></label>
  <label><input type="checkbox" name="exclude" value="pending"><pending></label>
  <label><input type="checkbox" name="exclude" value="security"><security></label>
  <label><input type="checkbox" name="exclude" value="unreproducible"><unreproducible></label>
  <label><input type="checkbox" name="exclude" value="upstream"><upstream></label>
  <label><input type="checkbox" name="exclude" value="wontfix"><wontfix></label>
  <label><input type="checkbox" name="exclude" value="ipv6"><ipv6></label>
  <label><input type="checkbox" name="exclude" value="lfs"><lfs></label>
  </small></li>

</ul>
