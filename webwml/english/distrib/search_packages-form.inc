#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="distrib" />

<form method="GET" action="http://packages.debian.org/cgi-bin/search_packages.pl">
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
<gettext domain="distrib">Allow searching on subwords</gettext>:
<input type="checkbox" name="subword" value="1" checked="checked" />
<br />
<gettext domain="distrib">Search case sensitive</gettext>:
<input type="checkbox" name="case" value="sensitive" />
<br />
<gettext domain="distrib">Distribution</gettext>:
<select name="version">
  <option value="unstable"><gettext domain="distrib">unstable</gettext></option>
  <option value="testing"><gettext domain="distrib">testing</gettext></option>
  <option value="stable" selected="selected"><gettext domain="distrib">stable</gettext></option>
  <option value="oldstable"><gettext domain="distrib">oldstable</gettext></option>
  <option value="all"><gettext domain="distrib">any</gettext></option>
</select>
<gettext domain="distrib">Section</gettext>:
<select name="release">
  <option value="main"><gettext domain="distrib">main</gettext></option>
  <option value="contrib"><gettext domain="distrib">contrib</gettext></option>
  <option value="non-free"><gettext domain="distrib">non-free</gettext></option>
  <option value="non-us"><gettext domain="distrib">non-US</gettext></option>
  <option value="all" selected="selected"><gettext domain="distrib">any</gettext></option>
</select>
</form>
