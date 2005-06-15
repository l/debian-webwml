#use wml::debian::language_names
#use wml::debian::common_tags
#use wml::debian::translation-check translation="1.5"

<bind-gettext-domain domain="distrib" />

<form method="GET" action="http://packages.debian.org/cgi-bin/search_contents.pl">
<label for="keyword"><gettext domain="distrib">Ключова дума</gettext>:</label>
<input type="text" size="30" name="word" id="keyword" /> &nbsp;
<input type="submit" value="<gettext domain="distrib">Търсене</gettext>" />
&nbsp;<input type="reset" value="<gettext domain="distrib">Reset</gettext>" />
<br />
<gettext domain="distrib">Display</gettext>:
<br />
<input type=radio name="searchmode" value="searchfiles" id="searchfiles" checked="checked" />
  <label for="searchfiles"><gettext domain="distrib">пакети, които съдържат файлове с имена подобни на това</gettext></label>
<br />
<input type=radio name="searchmode" value="searchfilesanddirs" id="searchfilesanddirs" />
  <label for="searchfilesanddirs"><gettext domain="distrib">пакети, които съдържат файлове и директории с имена подобни на това</gettext></label>
<br />
<input type=radio name="searchmode" value="searchword" id="searchword" />
  <label for="searchword"><gettext domain="distrib">пакети, които съдържат файлове и директории с имена вкючващи ключовата дума</gettext></label>
<br />
<input type=radio name="searchmode" value="filelist" id="filelist" />
  <label for="filelist"><gettext domain="distrib">всички файлове в този пакет</gettext></label>
<br />
<label for="casesens"><gettext domain="distrib">Разпознаване на малки/големи букви</gettext>:</label>
<select name="case" id="casesens">
  <option value="insensitive" selected="selected"><gettext domain="distrib">не</gettext></option>
  <option value="sensitive"><gettext domain="distrib">да</gettext></option>
</select>
<label for="distro"><gettext domain="distrib">Дистрибуция</gettext>:</label>
<select name="version" id="distro">
<option value="oldstable"><gettext domain="distrib">oldstable</gettext></option>
  <option value="stable" selected="selected"><gettext domain="distrib">stable</gettext></option>
  <option value="testing"><gettext domain="distrib">testing</gettext></option>
  <option value="unstable"><gettext domain="distrib">unstable</gettext></option>
</select>
<label for="architecture"><gettext domain="distrib">Архитектура</gettext>:</label>
<select name="arch" id="architecture">
  <option value="i386" selected="selected"><gettext domain="distrib">Intel x86</gettext></option>
  <option value="m68k"><gettext domain="distrib">Motorola 680x0</gettext></option>
  <option value="alpha"><gettext domain="distrib">Alpha</gettext></option>
  <option value="amd64"><gettext domain="distrib">AMD64</gettext></option>
  <option value="sparc"><gettext domain="distrib">SPARC</gettext></option>
  <option value="powerpc"><gettext domain="distrib">PowerPC</gettext></option>
  <option value="arm"><gettext domain="distrib">ARM</gettext></option>
  <option value="hppa"><gettext domain="distrib">HP PA/RISC</gettext></option>
  <option value="ia64"><gettext domain="distrib">Intel IA-64</gettext></option>
  <option value="mips"><gettext domain="distrib">MIPS</gettext></option>
  <option value="mipsel"><gettext domain="distrib">MIPS (DEC)</gettext></option>
  <option value="s390"><gettext domain="distrib">IBM S/390</gettext></option>
# SuperH is currently not in shape for anything
#  <option value="sh"></option>
# TODO: Hurd should be listed as a separate distribution
  <option value="hurd-i386"><gettext domain="distrib">Hurd (i386)</gettext></option>
</select>
</form>
