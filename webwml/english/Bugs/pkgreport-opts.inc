<define-tag flags whitespace=delete>
	[EN:Flags::]
	[SV:Flaggor::]
</define-tag>
<define-tag active_bugs whitespace=delete>
	[EN:active bugs:]
	[SV:aktiva fel:]
</define-tag>
<define-tag archived_bugs whitespace=delete>
	[EN:archived bugs:]
	[SV:arkiverade fel:]
</define-tag>
<define-tag no_status whitespace=delete>
	[EN:No status/severity ordering:]
	[SV:Ingen sortering på status/allvarlighetsgrad:]
</define-tag>
<define-tag reverse_order whitespace=delete>
	[EN:Reverse order of: :]
	[SV:Omvänd ordning för: :]
</define-tag>
<define-tag status whitespace=delete>
	[EN:status:]
	[SV:status:]
</define-tag>
<define-tag severities whitespace=delete>
	[EN:severities:]
	[SV:allvarlighetsgrader:]
</define-tag>
<define-tag bugs whitespace=delete>
	[EN:bugs:]
	[SV:fel:]
</define-tag>
<define-tag status_include whitespace=delete>
	[EN:Status Include: :]
	[SV:Inkludera status: :]
</define-tag>
<define-tag status_exclude whitespace=delete>
	[EN:Status Exclude: :]
	[SV:Exkludera status: :]
</define-tag>
<define-tag severity_include whitespace=delete>
	[EN:Severity Include: :]
	[SV:Inkludera allvarlighetsgrader: :]
</define-tag>
<define-tag severity_exclude whitespace=delete>
	[EN:Severity Exclude: :]
	[SV:Exkludera allvarlighetsgrader: :]
</define-tag>
<define-tag open whitespace=delete>
	[EN:Open:]
	[SV:Öppet:]
</define-tag>
<define-tag forwarded whitespace=delete>
	[EN:Forwarded:]
	[SV:Vidaresänt:]
</define-tag>
<define-tag pending whitespace=delete>
	[EN:Pending:]
	[SV:På gång:]
</define-tag>
<define-tag fixed whitespace=delete>
	[EN:Fixed:]
	[SV:Rättat:]
</define-tag>
<define-tag done whitespace=delete>
	[EN:Done:]
	[SV:Klart:]
</define-tag>
<define-tag critical whitespace=delete>
	[EN:Critical:]
	[SV:Kritiskt:]
</define-tag>
<define-tag grave whitespace=delete>
	[EN:Grave:]
	[SV:Gravt:]
</define-tag>
<define-tag serious whitespace=delete>
	[EN:Serious:]
	[SV:Allvarligt:]
</define-tag>
<define-tag important whitespace=delete>
	[EN:Important:]
	[SV:Viktigt:]
</define-tag>
<define-tag normal whitespace=delete>
	[EN:Normal:]
	[SV:Normalt:]
</define-tag>
<define-tag minor whitespace=delete>
	[EN:Minor:]
	[SV:Mindre:]
</define-tag>
<define-tag wishlist whitespace=delete>
	[EN:Wishlist:]
	[SV:Önskelista:]
</define-tag>
<define-tag fixed whitespace=delete>
	[EN:Fixed:]
	[SV:Rättat:]
</define-tag>
  <small>
  <ul>
  <li><flags>
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
  <li><severity_include>
  <input type="checkbox" name="sev-inc" value="critical"><critical>
  <input type="checkbox" name="sev-inc" value="grave"><grave>
  <input type="checkbox" name="sev-inc" value="serious"><serious>
  <input type="checkbox" name="sev-inc" value="important"><important>
  <input type="checkbox" name="sev-inc" value="normal"><normal>
  <input type="checkbox" name="sev-inc" value="minor"><minor>
  <input type="checkbox" name="sev-inc" value="wishlist"><wishlist>
  <input type="checkbox" name="sev-inc" value="fixed"><fixed>
  <li><severity_exclude>
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
