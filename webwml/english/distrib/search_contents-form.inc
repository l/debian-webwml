#use wml::debian::language_names
#use wml::debian::common_tags

<bind-gettext-domain domain="distrib" />

<form method="GET" action="http://packages.debian.org/search">
<p>
<input type="hidden" name="searchon" value="contents" />
<label for="keyword"><gettext domain="distrib">Keyword</gettext>:</label>
<input type="text" size="30" name="keywords" id="keyword" /> &nbsp;
<input type="submit" value="<gettext domain="distrib">Search</gettext>" />
&nbsp;<input type="reset" value="<gettext domain="distrib">Reset</gettext>" />
<br />
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
<br />
<label for="distro"><gettext domain="distrib">Distribution</gettext>:</label>
<select name="suite" id="distro">
  <option value="experimental"><gettext domain="distrib">experimental</gettext></option>
  <option value="unstable"><gettext domain="distrib">unstable</gettext></option>
  <option value="testing"><gettext domain="distrib">testing</gettext></option>
  <option value="stable" selected="selected"><gettext domain="distrib">stable</gettext></option>
  <option value="oldstable"><gettext domain="distrib">oldstable</gettext></option>
</select>
<label for="architecture"><gettext domain="distrib">Architecture</gettext>:</label>
# TODO: build from archlist available at releases/sid/release.data
<select name="arch" id="architecture">
  <option value="any" selected="selected"><gettext domain="distrib">any</gettext></option>
  <option value="i386"><gettext domain="distrib">Intel x86</gettext></option>
  <option value="m68k"><gettext domain="distrib">Motorola 680x0</gettext></option>
  <option value="alpha"><gettext domain="distrib">Alpha</gettext></option>
  <option value="amd64"><gettext domain="distrib">AMD64</gettext></option>
  <option value="sparc"><gettext domain="distrib">SPARC</gettext></option>
  <option value="powerpc"><gettext domain="distrib">PowerPC</gettext></option>
  <option value="arm"><gettext domain="distrib">ARM</gettext></option>
  <option value="hppa"><gettext domain="distrib">HP PA/RISC</gettext></option>
  <option value="ia64"><gettext domain="distrib">Intel IA-64</gettext></option>
  <option value="mips"><gettext domain="distrib">MIPS (big endian)</gettext></option>
  <option value="mipsel"><gettext domain="distrib">MIPS (little endian)</gettext></option>
  <option value="s390"><gettext domain="distrib">IBM S/390</gettext></option>
  <option value="kfreebsd-amd64"><gettext domain="distrib">kFreeBSD (AMD64)</gettext></option>
  <option value="kfreebsd-i386"><gettext domain="distrib">kFreeBSD (Intel x86)</gettext></option>
# TODO: Hurd should be listed as a separate distribution
  <option value="hurd-i386"><gettext domain="distrib">Hurd (i386)</gettext></option>
</select>
</p>
</form>
