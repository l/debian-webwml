#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="bugs" />

<ul>

  <li><small><gettext domain="bugs">Flags:</gettext>
  <input type="radio" name="archive" value="no" checked>
    <gettext domain="bugs">active bugs</gettext>
  <input type="radio" name="archive" value="yes">
     <gettext domain="bugs">archived bugs</gettext>
  <br>
  <input type="checkbox" name="repeatmerged" value="no">
     <gettext domain="bugs">display merged bugs only once</gettext>
  <input type="checkbox" name="raw" value="yes">
     <gettext domain="bugs">no ordering by status or severity</gettext>
  </small>

  <li><small><gettext domain="bugs">Reverse order of:</gettext>
  <input type="checkbox" name="pend-rev" value="yes">
    <gettext domain="bugs">status</gettext>
  <input type="checkbox" name="sev-rev" value="yes">
    <gettext domain="bugs">severities</gettext>
  <input type="checkbox" name="bug-rev" value="yes">
    <gettext domain="bugs">bugs</gettext>
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
  <input type="checkbox" name="pend-inc" value="pending"><open>
  <input type="checkbox" name="pend-inc" value="forwarded"><forwarded>
  <input type="checkbox" name="pend-inc" value="pending-fixed"><pending>
  <input type="checkbox" name="pend-inc" value="fixed"><fixed>
  <input type="checkbox" name="pend-exc" value="done"><done>
  </small></li>

  <li><small><gettext domain="bugs">Exclude status:</gettext>
  <input type="checkbox" name="pend-exc" value="pending"><open>
  <input type="checkbox" name="pend-exc" value="forwarded"><forwarded>
  <input type="checkbox" name="pend-exc" value="pending-fixed"><pending>
  <input type="checkbox" name="pend-exc" value="fixed"><fixed>
  <input type="checkbox" name="pend-exc" value="done"><done>
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
  <input type="checkbox" name="sev-inc" value="critical"><critical>
  <input type="checkbox" name="sev-inc" value="grave"><grave>
  <input type="checkbox" name="sev-inc" value="serious"><serious>
  <input type="checkbox" name="sev-inc" value="important"><important>
  <input type="checkbox" name="sev-inc" value="normal"><normal>
  <input type="checkbox" name="sev-inc" value="minor"><minor>
  <input type="checkbox" name="sev-inc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-inc" value="fixed"><fixed>
  </small></li>

  <li><small><gettext domain="bugs">Exclude severity:</gettext>
  <input type="checkbox" name="sev-exc" value="critical"><critical>
  <input type="checkbox" name="sev-exc" value="grave"><grave>
  <input type="checkbox" name="sev-exc" value="serious"><serious>
  <input type="checkbox" name="sev-exc" value="important"><important>
  <input type="checkbox" name="sev-exc" value="normal"><normal>
  <input type="checkbox" name="sev-exc" value="minor"><minor>
  <input type="checkbox" name="sev-exc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-exc" value="fixed"><fixed>
  </small></li>

</ul>
