#use wml::debian::submenu
#include "$(ENGLISHDIR)/ports/menu.defs"


<define-menu-item name="netbsd-i386">
  <gettext domain="ports">Debian GNU/NetBSD for i386</gettext>
</define-menu-item>

<define-menu-item name="netbsd-alpha">
  <gettext domain="ports">Debian GNU/NetBSD for Alpha</gettext>
</define-menu-item>

<define-menu-item name="why">
  <gettext domain="ports">Why</gettext>
</define-menu-item>

<define-menu-item name="people">
  <gettext domain="ports">People</gettext>
</define-menu-item>

<menu-item name="ports"         basename="../index">
<menu-item name="netbsd-i386"   basename="index">
<menu-item name="netbsd-alpha"  basename="alpha">
<menu-item name="news"          basename="news">
<menu-item name="why"           basename="why">
<menu-item name="people"	basename="people">
