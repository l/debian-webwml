#use wml::debian::common_tags

<bind-gettext-domain domain="bugs" />

<define-tag bts_main_form whitespace=delete>
  <form method="get" action="https://bugs.debian.org/cgi-bin/pkgreport.cgi">
  <p style="display:none">
  <input type="hidden" name="_fo_combine_key_fo_searchkey_value_fo_searchvalue" value="1">
  <input type="hidden" name="form_options" value="1">
  </p>
</define-tag>

<define-tag bts_select_form whitespace=delete>
  <span style="white-space:nowrap">
  <select name="_fo_searchkey">
  <option value="package" selected>
    <gettext domain="bugs">in package</gettext>
  </option>
  <option value="tag">
    <gettext domain="bugs">tagged</gettext>
  </option>
  <option value="severity">
    <gettext domain="bugs">with severity</gettext>
  </option>
  <option value="src">
    <gettext domain="bugs">in source package</gettext>
  </option>
  <option value="maint">
    <gettext domain="bugs">in packages maintained by</gettext>
  </option>
  <option value="submitter">
    <gettext domain="bugs">submitted by</gettext>
  </option>
  <option value="owner">
    <gettext domain="bugs">owned by</gettext>
  </option>
  <option value="status">
    <gettext domain="bugs">with status</gettext>
  </option>
  <option value="correspondent">
    <gettext domain="bugs">with mail from</gettext>
  </option>
  <option value="newest">
    <gettext domain="bugs">newest bugs</gettext>
  </option>
  </select>
  <input type="text" name="_fo_searchvalue" value ="">
  </span>
  <br>
</define-tag>

<define-tag bts_include_form whitespace=delete>
  <input type="hidden" name="_fo_concatenate_into_include_fo_includekey_fo_includevalue" value="1">
  <span style="white-space:nowrap">
  <select name="_fo_includekey">
  <option value="subject">
    <gettext domain="bugs">with subject containing</gettext>
  </option>
  <option value="tags">
    <gettext domain="bugs">tagged</gettext>
  </option>
  <option value="severity">
    <gettext domain="bugs">with severity</gettext>
  </option>
  <option value="pending">
    <gettext domain="bugs">with pending state</gettext>
  </option>
  <option value="originator">
    <gettext domain="bugs">with submitter containing</gettext>
  </option>
  <option value="forwarded">
    <gettext domain="bugs">with forwarded containing</gettext>
  </option>
  <option value="owner">
    <gettext domain="bugs">with owner containing</gettext>
  </option>
  <option value="package">
    <gettext domain="bugs">with package</gettext>
  </option>

  </select>
  <input type="text" name="_fo_includevalue" value ="">
  </span>
</define-tag>

<define-tag bts_exclude_form whitespace=delete>
  <input type="hidden" name="_fo_concatenate_into_exclude_fo_excludekey_fo_excludevalue" value="1">
  <span style="white-space:nowrap">
  <select name="_fo_excludekey">
  <option value="subject">
    <gettext domain="bugs">with subject containing</gettext>
  </option>
  <option value="tags">
    <gettext domain="bugs">tagged</gettext>
  </option>
  <option value="severity">
    <gettext domain="bugs">with severity</gettext>
  </option>
  <option value="pending">
    <gettext domain="bugs">with pending state</gettext>
  </option>
  <option value="originator">
    <gettext domain="bugs">with submitter containing</gettext>
  </option>
  <option value="forwarded">
    <gettext domain="bugs">with forwarded containing</gettext>
  </option>
  <option value="owner">
    <gettext domain="bugs">with owner containing</gettext>
  </option>
  <option value="package">
    <gettext domain="bugs">with package</gettext>
  </option>
  </select>
  <input type="text" name="_fo_excludevalue" value ="">
  </span>
</define-tag>

<define-tag bts_orderby_form whitespace=delete>
  <select name="ordering">
  <option value="normal" selected>
    <gettext domain="bugs">normal</gettext>
  </option>
  <option value="oldview">
    <gettext domain="bugs">oldview</gettext>
  </option>
  <option value="raw">
    <gettext domain="bugs">raw</gettext>
  </option>
  <option value="age">
    <gettext domain="bugs">age</gettext>
  </option>
  </select>
</define-tag>

<define-tag bts_miscopts_form whitespace=delete>
  <input type="checkbox" name="repeatmerged">&nbsp;<gettext domain="bugs">Repeat Merged</gettext><br>
  <input type="checkbox" name="bug-rev" >&nbsp;<gettext domain="bugs">Reverse Bugs</gettext><br>
  <input type="checkbox" name="pend-rev" >&nbsp;<gettext domain="bugs">Reverse Pending</gettext><br>
  <input type="checkbox" name="sev-rev" >&nbsp;<gettext domain="bugs">Reverse Severity</gettext><br>
  <input type="checkbox" name="noaffects">&nbsp;<gettext domain="bugs">No Bugs which affect packages</gettext><br>
  <select name="dist">
<option value="">&nbsp;<gettext domain="bugs">None</gettext></option>
<option value="testing">&nbsp;<gettext domain="bugs">testing</gettext></option>
<option value="oldstable">&nbsp;<gettext domain="bugs">oldstable</gettext></option>
<option value="stable">&nbsp;<gettext domain="bugs">stable</gettext></option>
<option value="experimental">&nbsp;<gettext domain="bugs">experimental</gettext></option>
<option value="unstable" selected>&nbsp;<gettext domain="bugs">unstable</gettext></option>
  </select>
  <select name="archive">
  <option value="0" selected>
    <gettext domain="bugs">Unarchived</gettext>
  </option>
  <option value="1">
    <gettext domain="bugs">Archived</gettext>
   </option>
  <option value="both">
    <gettext domain="bugs">Archived and Unarchived</gettext>
  </option>
  </select>
</define-tag>

# bug severities. See debbugs/etc/config
<define-tag bts_severities>
<code>critical</code>, <code>grave</code>, <code>serious</code>, 
<code>important</code>, <code>normal</code>, <code>minor</code>, 
<code>wishlist</code></define-tag>

# obsolete bug severities.
<define-tag bts_severities_obsolete>
<code>fixed</code></define-tag>

<define-tag bts_severities_all>
<bts_severities>, <bts_severities_obsolete></define-tag>

# bug tags. See debbugs/etc/config
<define-tag bts_tags>
<code>patch</code>, <code>wontfix</code>, <code>moreinfo</code>, 
<code>unreproducible</code>, <code>help</code>, <code>newcomer</code>, <code>pending</code>, 
<code>security</code>, <code>upstream</code>, <code>confirmed</code>, 
<code>fixed</code>, <code>fixed-upstream</code>, 
<code>fixed-in-experimental</code>, <code>d-i</code>, <code>ipv6</code>, 
<code>lfs</code>, <code>l10n</code>, 
<code>potato</code>, <code>woody</code>, 
<code>sarge</code>, <code>sarge-ignore</code>, 
<code>etch</code>, <code>etch-ignore</code>, 
<code>lenny</code>, <code>lenny-ignore</code>, 
<code>squeeze</code>, <code>squeeze-ignore</code>, 
<code>wheezy</code>, <code>wheezy-ignore</code>, 
<code>jessie</code>, <code>jessie-ignore</code>, 
<code>stretch</code>, <code>stretch-ignore</code>, 
<code>buster</code>, <code>buster-ignore</code>, 
<code>sid</code>, 
<code>experimental</code></define-tag>

