#use wml::debian::submenu
#include "$(ENGLISHDIR)/ports/menu.defs"

#   Arch specific menu entries
<define-menu-item name="freebsd">
  <gettext domain="ports">Main</gettext>
</define-menu-item>
<define-menu-item name="gnu-libc-based">
  <gettext domain="ports">Glibc-based Debian GNU/FreeBSD</gettext>
</define-menu-item>
<define-menu-item name="bsd-libc-based">
  <gettext domain="ports">libc5-based Debian GNU/FreeBSD</gettext>
</define-menu-item>

<menu-item name="ports"         basename="../index">
<menu-item name="freebsd"       basename="index">
<menu-item name="gnu-libc-based"       basename="gnu-libc-based">
<menu-item name="bsd-libc-based"       basename="bsd-libc-based">
