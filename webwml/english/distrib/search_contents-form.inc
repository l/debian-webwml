#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="distrib" />

<form method="GET" action="//packages.debian.org/search">
<div>
<input type="hidden" name="searchon" value="contents" />
<label for="keyword"><gettext domain="distrib">Keyword</gettext>:</label>
<input type="text" size="30" name="keywords" id="keyword" />
</div>
<div>
<gettext domain="distrib">Display</gettext>:
<br />
<input type=radio name="mode" value="path" id="searchpath" checked="checked" />
  <label for="searchpath"><gettext domain="distrib">paths ending with the keyword</gettext></label>
<br />
<input type=radio name="mode" value="exactfilename" id="searchfiles" />
  <label for="searchfiles"><gettext domain="distrib">packages that contain files named like this</gettext></label>
<br />
<input type=radio name="mode" value="filename" id="searchword" />
  <label for="searchword"><gettext domain="distrib">packages that contain files whose names contain the keyword</gettext></label>
</div>
<div>
<label for="distro"><gettext domain="distrib">Distribution</gettext>:</label>
<select name="suite" id="distro">
  <option value="experimental"><gettext domain="distrib">experimental</gettext></option>
  <option value="unstable"><gettext domain="distrib">unstable</gettext></option>
  <option value="testing"><gettext domain="distrib">testing</gettext></option>
  <option value="stable" selected="selected"><gettext domain="distrib">stable</gettext></option>
  <option value="oldstable"><gettext domain="distrib">oldstable</gettext></option>
</select>
<label for="architecture"><gettext domain="distrib">Architecture</gettext>:</label>

#include "$(ENGLISHDIR)/releases/sid/archive.data"
#include "$(ENGLISHDIR)/releases/arches.data"
<select name="arch" id="architecture">
  <option value="any" selected="selected"><gettext domain="distrib">any</gettext></option>
<:
 foreach my $a (@arches) {
	my $aname = $arches{$a}; $aname =~ s, ,\&nbsp\;,g;
	print "  <option value=\"$a\">$aname</option>\n";
 }
:>
</select>
</div>
<div class="action-block-form">
  <input type="submit" value="<gettext domain="distrib">Search</gettext>" />
  <input type="reset" value="<gettext domain="distrib">Reset</gettext>" />
</div>
</form>
