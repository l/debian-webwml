#use wml::debian::submenu
#include "$(ENGLISHDIR)/ports/menu.defs"

#   Arch specific menu entries
<define-menu-item name="freebsd">Main</define-menu-item>
<define-menu-item name="gnu-libc-based">Glibc-based Debian GNU/FreeBSD</define-menu-item>
<define-menu-item name="bsd-libc-based">libc5-based Debian GNU/FreeBSD</define-menu-item>

<menu-item name="ports"         basename="../index">
<menu-item name="freebsd"       basename="index">
<menu-item name="gnu-libc-based"       basename="gnu-libc-based">
<menu-item name="bsd-libc-based"       basename="bsd-libc-based">
