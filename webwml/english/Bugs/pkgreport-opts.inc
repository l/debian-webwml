#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="bugs" />

<define-tag flags whitespace=delete>
  <gettext domain="bugs">Flags:</gettext>
</define-tag>
<define-tag active_bugs whitespace=delete>
  <gettext domain="bugs">active bugs</gettext>
</define-tag>
<define-tag archived_bugs whitespace=delete>
  <gettext domain="bugs">archived bugs</gettext>
</define-tag>
<define-tag no_status whitespace=delete>
  <gettext domain="bugs">no ordering by status or severity</gettext>
</define-tag>
<define-tag no_repeat_merged whitespace=delete>
  <gettext domain="bugs">display merged bugs only once</gettext>
</define-tag>
<define-tag reverse_order whitespace=delete>
  <gettext domain="bugs">Reverse order of: </gettext>
</define-tag>
<define-tag status whitespace=delete>
  <gettext domain="bugs">status</gettext>
</define-tag>
<define-tag severities whitespace=delete>
  <gettext domain="bugs">severities</gettext>
</define-tag>
<define-tag bugs whitespace=delete>
  <gettext domain="bugs">bugs</gettext>
</define-tag>
<define-tag status_include whitespace=delete>
  <gettext domain="bugs">Include status: </gettext>
</define-tag>
<define-tag status_exclude whitespace=delete>
  <gettext domain="bugs">Exclude status: </gettext>
</define-tag>
<define-tag severity_include whitespace=delete>
  <gettext domain="bugs">Include severity: </gettext>
</define-tag>
<define-tag severity_exclude whitespace=delete>
  <gettext domain="bugs">Exclude severity: </gettext>
</define-tag>
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

<ul>
  <li><small><flags>
  <input type="radio" name="archive" value="no" checked> <active_bugs>
  <input type="radio" name="archive" value="yes"> <archived_bugs>
  <input type="checkbox" name="raw" value="yes"> <no_status>
  <input type="checkbox" name="repeatmerged" value="no"> <no_repeat_merged>
  </small>
  <li><small><reverse_order>
  <input type="checkbox" name="pend-rev" value="yes"><status>
  <input type="checkbox" name="sev-rev" value="yes"><severities>
  <input type="checkbox" name="bug-rev" value="yes"><bugs>
  </small>
  <li><small><status_include>
  <input type="checkbox" name="pend-inc" value="pending"><open>
  <input type="checkbox" name="pend-inc" value="forwarded"><forwarded>
  <input type="checkbox" name="pend-inc" value="pending-fixed"><pending>
  <input type="checkbox" name="pend-inc" value="fixed"><fixed>
  <input type="checkbox" name="pend-exc" value="done"><done>
  </small>
  <li><small><status_exclude>
  <input type="checkbox" name="pend-exc" value="pending"><open>
  <input type="checkbox" name="pend-exc" value="forwarded"><forwarded>
  <input type="checkbox" name="pend-exc" value="pending-fixed"><pending>
  <input type="checkbox" name="pend-exc" value="fixed"><fixed>
  <input type="checkbox" name="pend-exc" value="done"><done>
  </small>
  <li><small><severity_include>
  <input type="checkbox" name="sev-inc" value="critical"><critical>
  <input type="checkbox" name="sev-inc" value="grave"><grave>
  <input type="checkbox" name="sev-inc" value="serious"><serious>
  <input type="checkbox" name="sev-inc" value="important"><important>
  <input type="checkbox" name="sev-inc" value="normal"><normal>
  <input type="checkbox" name="sev-inc" value="minor"><minor>
  <input type="checkbox" name="sev-inc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-inc" value="fixed"><fixed>
  </small>
  <li><small><severity_exclude>
  <input type="checkbox" name="sev-exc" value="critical"><critical>
  <input type="checkbox" name="sev-exc" value="grave"><grave>
  <input type="checkbox" name="sev-exc" value="serious"><serious>
  <input type="checkbox" name="sev-exc" value="important"><important>
  <input type="checkbox" name="sev-exc" value="normal"><normal>
  <input type="checkbox" name="sev-exc" value="minor"><minor>
  <input type="checkbox" name="sev-exc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-exc" value="fixed"><fixed>
  </small>
</ul>
