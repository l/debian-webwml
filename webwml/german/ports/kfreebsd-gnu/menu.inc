#use wml::debian::submenu
#include "$(ENGLISHDIR)/ports/menu.defs"
#use wml::debian::translation-check translation="1.1"

#   Arch specific menu entries
<define-menu-item name="kfreebsd-gnu">
  <gettext domain="ports">Hauptseite</gettext>
</define-menu-item>
<define-menu-item name="index">
  <gettext domain="ports">Debian GNU/FreeBSD</gettext>
</define-menu-item>

<menu-item name="ports"         basename="../index">
<menu-item name="kfreebsd-gnu"       basename="index">
