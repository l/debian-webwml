#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="distrib" />

<form method="GET" action="http://packages.debian.org/search">
<p>
<label for="kw"><gettext domain="distrib">Keyword</gettext>:</label>
<input type="text" size="30" name="keywords" id="kw" />
<input type="submit" value="<gettext domain="distrib">Search</gettext>" /> <input type="reset" value="<gettext domain="distrib">Reset</gettext>" />
<br />
<gettext domain="distrib">Search on</gettext>:
<input type="radio" name="searchon" value="names" id="onlynames" checked="checked" />
<label for="onlynames"><gettext domain="distrib">Package names only</gettext></label>&nbsp;&nbsp;
<input type="radio" name="searchon" value="all" id="descs" />
<label for="descs"><gettext domain="distrib">Descriptions</gettext></label>
<input type="radio" name="searchon" value="sourcenames" id="src" />
<label for="src"><gettext domain="distrib">Source package names</gettext></label>
<br />
<label for="searchexact"><gettext domain="distrib">Only show exact matches</gettext>:</label>
<input type="checkbox" name="exact" value="1" id="searchexact" />
<br />
<label for="distribversion"><gettext domain="distrib">Distribution</gettext>:</label>
<select name="suite" id="distribversion">
  <option value="experimental"><gettext domain="distrib">experimental</gettext></option>
  <option value="unstable"><gettext domain="distrib">unstable</gettext></option>
  <option value="testing"><gettext domain="distrib">testing</gettext></option>
  <option value="stable" selected="selected"><gettext domain="distrib">stable</gettext></option>
  <option value="oldstable"><gettext domain="distrib">oldstable</gettext></option>
  <option value="all"><gettext domain="distrib">any</gettext></option>
</select>
<label for="releasesection"><gettext domain="distrib">Section</gettext>:</label>
<select name="section" id="releasesection">
  <option value="main"><gettext domain="distrib">main</gettext></option>
  <option value="contrib"><gettext domain="distrib">contrib</gettext></option>
  <option value="non-free"><gettext domain="distrib">non-free</gettext></option>
  <option value="all" selected="selected"><gettext domain="distrib">any</gettext></option>
</select>
</p>
</form>
