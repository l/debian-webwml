<define-tag active_bugs whitespace=delete>
	[EN:active bugs:]
</define-tag>
<define-tag archived_bugs whitespace=delete>
	[EN:archived bugs:]
</define-tag>
<define-tag no_status whitespace=delete>
	[EN:No status/severity ordering:]
</define-tag>
<define-tag reverse_order whitespace=delete>
	[EN:Reverse order of: :]
</define-tag>
<define-tag status whitespace=delete>
	[EN:status:]
</define-tag>
<define-tag severities whitespace=delete>
	[EN:severities:]
</define-tag>
<define-tag bugs whitespace=delete>
	[EN:bugs:]
</define-tag>
<define-tag status_include whitespace=delete>
	[EN:Status Include: :]
</define-tag>
<define-tag status_exclude whitespace=delete>
	[EN:Status Exclude: :]
</define-tag>
<define-tag severity_include whitespace=delete>
	[EN:Severity Include: :]
</define-tag>
<define-tag severity_exclude whitespace=delete>
	[EN:Severity Exclude: :]
</define-tag>
<define-tag open whitespace=delete>
	[EN:Open:]
</define-tag>
<define-tag forwarded whitespace=delete>
	[EN:Forwarded:]
</define-tag>
<define-tag pending whitespace=delete>
	[EN:Pending:]
</define-tag>
<define-tag fixed whitespace=delete>
	[EN:Fixed:]
</define-tag>
<define-tag done whitespace=delete>
	[EN:Done:]
</define-tag>
<define-tag critical whitespace=delete>
	[EN:Critical:]
</define-tag>
<define-tag grave whitespace=delete>
	[EN:Grave:]
</define-tag>
<define-tag serious whitespace=delete>
	[EN:Serious:]
</define-tag>
<define-tag important whitespace=delete>
	[EN:Important:]
</define-tag>
<define-tag normal whitespace=delete>
	[EN:Normal:]
</define-tag>
<define-tag minor whitespace=delete>
	[EN:Minor:]
</define-tag>
<define-tag wishlist whitespace=delete>
	[EN:Wishlist:]
</define-tag>
<define-tag fixed whitespace=delete>
	[EN:Fixed:]
</define-tag>
  <small>
  <ul>
  <li>Flags:
  <input type="radio" name="archive" value="no" checked> <active_bugs>
  <input type="radio" name="archive" value="yes"> <archived_bugs>
  <input type="checkbox" name="raw" value="yes"> <no_status>
  <li><reverse order>
  <input type="checkbox" name="pend-rev" value="yes"><status>
  <input type="checkbox" name="sev-rev" value="yes"><severities>
  <input type="checkbox" name="bug-rev" value="yes"><bugs>
  <li><status_include>
  <input type="checkbox" name="pend-inc" value="pending"><open>
  <input type="checkbox" name="pend-inc" value="forwarded"><forwarded>
  <input type="checkbox" name="pend-inc" value="pending-fixed"><pending>
  <input type="checkbox" name="pend-inc" value="fixed"><fixed>
  <input type="checkbox" name="pend-exc" value="done"><done>
  <li><status_exclude>
  <input type="checkbox" name="pend-exc" value="pending"><open>
  <input type="checkbox" name="pend-exc" value="forwarded"><forwarded>
  <input type="checkbox" name="pend-exc" value="pending-fixed"><pending>
  <input type="checkbox" name="pend-exc" value="fixed"><fixed>
  <input type="checkbox" name="pend-exc" value="done"><done>
  <li>Severity Include:
  <input type="checkbox" name="sev-inc" value="critical"><critical>
  <input type="checkbox" name="sev-inc" value="grave"><grave>
  <input type="checkbox" name="sev-inc" value="serious"><serious>
  <input type="checkbox" name="sev-inc" value="important"><important>
  <input type="checkbox" name="sev-inc" value="normal"><normal>
  <input type="checkbox" name="sev-inc" value="minor"><minor>
  <input type="checkbox" name="sev-inc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-inc" value="fixed"><fixed>
  <li>Severity Exclude:
  <input type="checkbox" name="sev-exc" value="critical"><critical>
  <input type="checkbox" name="sev-exc" value="grave"><grave>
  <input type="checkbox" name="sev-exc" value="serious"><serious>
  <input type="checkbox" name="sev-exc" value="important"><important>
  <input type="checkbox" name="sev-exc" value="normal"><normal>
  <input type="checkbox" name="sev-exc" value="minor"><minor>
  <input type="checkbox" name="sev-exc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-exc" value="fixed"><fixed>
  </ul>
  </small>
