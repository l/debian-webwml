<define-tag flags whitespace=delete>
	[EN:Flags::]
	[DA:Flag::]
	[HR:Oznake::]
	[SV:Flaggor::]
</define-tag>
<define-tag active_bugs whitespace=delete>
	[EN:active bugs:]
	[DA:aktive fejl:]
	[HR:aktivni bugovi:]
	[SV:aktiva fel:]
</define-tag>
<define-tag archived_bugs whitespace=delete>
	[EN:archived bugs:]
	[DA:arkiverede fejl:]
	[HR:arhivirani bugovi:]
	[SV:arkiverade fel:]
</define-tag>
<define-tag no_status whitespace=delete>
	[EN:no ordering by status or severity:]
	[DA:ingen sortering på status/alvorlighedsgrad:]
	[HR:bez slaganja po stanju ni severityu:]
	[SV:ingen sortering på status/allvarlighetsgrad:]
</define-tag>
<define-tag reverse_order whitespace=delete>
	[EN:Reverse order of: :]
	[DA:Omvendt rækkefølge af: :]
	[HR:Obrnut redoslijed za: :]
	[SV:Omvänd ordning för: :]
</define-tag>
<define-tag status whitespace=delete>
	[EN:status:]
	[DA:status:]
	[HR:stanje:]
	[SV:status:]
</define-tag>
<define-tag severities whitespace=delete>
	[EN:severities:]
	[DA:alvorlighedsgrader:]
	[HR:severityi:]
	[SV:allvarlighetsgrader:]
</define-tag>
<define-tag bugs whitespace=delete>
	[EN:bugs:]
	[DA:fejl:]
	[HR:bugovi:]
	[SV:fel:]
</define-tag>
<define-tag status_include whitespace=delete>
	[EN:Include status: :]
	[DA:Status indeholder: :]
	[HR:Ukljuèi stanje: :]
	[SV:Inkludera status: :]
</define-tag>
<define-tag status_exclude whitespace=delete>
	[EN:Exclude status: :]
	[DA:Status indeholder ikke: :]
	[HR:Iskljuèi stanje: :]
	[SV:Exkludera status: :]
</define-tag>
<define-tag severity_include whitespace=delete>
	[EN:Include severity: :]
	[DA:Alvorlighedsgrad indeholder: :]
	[HR:Ukljuèen severity: :]
	[SV:Inkludera allvarlighetsgrader: :]
</define-tag>
<define-tag severity_exclude whitespace=delete>
	[EN:Exclude severity: :]
	[DA:Alvorlighedsgrad indeholder ikke: :]
	[HR:Iskljuèen severity: :]
	[SV:Exkludera allvarlighetsgrader: :]
</define-tag>
<define-tag open whitespace=delete>
	[EN:open:]
	[DA:åben:]
	[HR:otvoreni:]
	[SV:öppet:]
</define-tag>
<define-tag forwarded whitespace=delete>
	[EN:forwarded:]
	[DA:videresendt:]
	[HR:proslijeðeni:]
	[SV:vidaresänt:]
</define-tag>
<define-tag pending whitespace=delete>
	[EN:pending:]
	[DA:i gang:]
	[HR:u radu:]
	[SV:på gång:]
</define-tag>
<define-tag fixed whitespace=delete>
	[EN:fixed:]
	[DA:rettet:]
	[HR:rije¹eni:]
	[SV:rättat:]
</define-tag>
<define-tag done whitespace=delete>
	[EN:done:]
	[DA:færdig:]
	[HR:gotovi:]
	[SV:klart:]
</define-tag>
<define-tag critical whitespace=delete>
	[EN:critical:]
	[DA:kritisk:]
	[HR:kritièni:]
	[SV:kritiskt:]
</define-tag>
<define-tag grave whitespace=delete>
	[EN:grave:]
	[DA:graverende:]
	[HR:te¹ki:]
	[SV:gravt:]
</define-tag>
<define-tag serious whitespace=delete>
	[EN:serious:]
	[DA:alvorlig:]
	[HR:ozbiljni:]
	[SV:allvarligt:]
</define-tag>
<define-tag important whitespace=delete>
	[EN:important:]
	[DA:vigtig:]
	[HR:va¾ni:]
	[SV:viktigt:]
</define-tag>
<define-tag normal whitespace=delete>
	[EN:normal:]
	[DA:normal:]
	[HR:normalni:]
	[SV:normalt:]
</define-tag>
<define-tag minor whitespace=delete>
	[EN:minor:]
	[DA:mindre:]
	[HR:maleni:]
	[SV:mindre:]
</define-tag>
<define-tag wishlist whitespace=delete>
	[EN:wishlist:]
	[DA:ønskeliste:]
	[HR:¾elje:]
	[SV:önskelista:]
</define-tag>

  <small>
  <ul>
  <li><flags>
  <input type="radio" name="archive" value="no" checked> <active_bugs>
  <input type="radio" name="archive" value="yes"> <archived_bugs>
  <input type="checkbox" name="raw" value="yes"> <no_status>
  <li><reverse_order>
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
