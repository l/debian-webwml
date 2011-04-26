#use wml::debian::common_tags

<bind-gettext-domain domain="bugs" />

<define-tag bts_main_form whitespace=delete>
  <form method="get" action="http://bugs.debian.org/cgi-bin/pkgreport.cgi">
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

# this is pasted from debbugs/etc/config
<perl>
@gSeverityList = ( "critical", "grave", "serious", "important", "normal",
                   "minor", "wishlist", "fixed"
                 );
</perl>

<define-tag bts_severities whitespace=delete>
  <: print (join ", ", @gSeverityList); :>
</define-tag>

# this is pasted from debbugs/etc/config
<perl>
@gTags = ( "patch", "wontfix", "moreinfo", "unreproducible", "fixed",
           "potato", "woody", "sid", "help", "security", "upstream",
           "pending", "sarge", "sarge-ignore", "experimental", "d-i",
           "confirmed", "ipv6", "lfs", "fixed-in-experimental",
           "fixed-upstream", "l10n", "etch", "etch-ignore",
           "lenny", "lenny-ignore",
         );
</perl>

<define-tag bts_tags whitespace=delete>
  <: print join(", ", @gTags); :>
</define-tag>
