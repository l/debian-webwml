#use wml::debian::template title="MIPS Port"

#include "$(ENGLISHDIR)/releases/info"
#use wml::debian::toc

<toc-display/>

<toc-add-entry name="about">Overview</toc-add-entry>
<p>The MIPS port is actually two ports, <em>debian-mips</em> and
<em>debian-mipsel</em>.  They differ in the <a
href="http://foldoc.org/endian">endianness</a>
of the binaries. MIPS CPUs are able to run at both endiannesses, but
since that's normally not changeable in software, we need to have both
architectures.  SGI machines run in <a
href="http://foldoc.org/big-endian">big-endian</a>
mode (debian-mips) while the Loongson 3 machines run in
<a
href="http://foldoc.org/little-endian">little-endian</a>
mode (debian-mipsel).  Some boards, such as Broadcom's BCM91250A evaluation
board (aka SWARM) can run in both modes, selectable by a switch on the board.
Some Cavium Octeon based machines can switch between both modes in the
bootloader.</p>

<p>Given most MIPS machines have 64-bit CPUs, a <em>debian-mips64el</em> port
is currently in development and might be released with Debian GNU/Linux 9.</p>

<toc-add-entry name="status">Current Status</toc-add-entry>
<p>Debian GNU/Linux <current_release_jessie> supports the following machines:</p>

<ul>

<li>SGI Indy with R4x00 and R5000 CPUs, and Indigo2 with R4400 CPU (IP22).</li>

<li>SGI O2 with R5000, R5200 and RM7000 CPU (IP32).</li>

<li>Broadcom BCM91250A (SWARM) evaluation board (big and little-endian).</li>

<li>MIPS Malta boards (big and little-endian, 32 and 64-bit).</li>

<li>Loongson 2e and 2f machines, including the Yeelong laptop (little-endian).</li>

<li>Loongson 3 machines (little-endian).</li>

<li>Cavium Octeon (big-endian).</li>

</ul>

<p>In addition to the above machines, it is possible to use Debian on a lot more
machines provided that a non-Debian kernel is used.  This is for example the
case of the MIPS Creator Ci20 development board.</p>

<toc-add-entry name="info">General Information about</toc-add-entry>

<p>Please see the <a href="$(HOME)/releases/stable/mips/release-notes/">\
release notes</a> and <a href="$(HOME)/releases/stable/mips/">\
installation manual</a> for more information.</p>


<toc-add-entry name="availablehw">Available Hardware for Debian Developers</toc-add-entry>

<p>Two machines are made available to Debian developers for MIPS porting
work: etler.debian.org (mipsel/mips64el) and minkus.debian.org (mips).
The machines have development chroot environments which you can access
with <em>schroot</em>.  Please see the
<a href = "https://db.debian.org/machines.cgi"> machine database</a> for more
information about these machines.</p>


<toc-add-entry name="credits">Credits</toc-add-entry>

<p>This is a list of people who are working on the MIPS port:</p>

#include "$(ENGLISHDIR)/ports/mips/people.inc"

<toc-add-entry name="contacts">Contacts</toc-add-entry>

<h3>Mailing lists</h3>

<p>There are a couple of mailing lists dealing with Linux/MIPS and especially
Debian on MIPS.</p>

<ul>

<li>debian-mips@lists.debian.org &mdash; This list deals with Debian on MIPS.<br />
Subscribe via mail to <email debian-mips-request@lists.debian.org>.<br />
The archive is at <a href="https://lists.debian.org/debian-mips/">lists.debian.org</a>.</li>

<li>linux-mips@linux-mips.org &mdash; This list is for discussions about
MIPS kernel supports.<br />
See the <a href = "http://www.linux-mips.org/wiki/Net_Resources#Mailing_lists">Linux/MIPS</a>
page for subscription information.</li>

</ul>

<h3>IRC</h3>

<p>You can find us on IRC on <em>irc.debian.org</em> on the channel
<em>#debian-mips</em>.</p>


<toc-add-entry name="links">Links</toc-add-entry>

<dl>
  <dt>Linux/MIPS kernel development &mdash; Lots of related information about MIPS</dt>
    <dd><a href="https://www.linux-mips.org/">linux-mips.org</a></dd>
  <dt>CPU Vendor</dt>
    <dd><a href="https://imgtec.com/mips">https://imgtec.com/mips</a></dd>
  <dt>Information about SGI hardware</dt>
    <dd><a href="http://www.sgistuff.net/hardware/">http://www.sgistuff.net/hardware/</a></dd>
  <dt>Debian on SGI Indy</dt>
    <dd><a href="http://www.pvv.org/~pladsen/Indy/HOWTO.html">http://www.pvv.org/~pladsen/Indy/HOWTO.html</a></dd>
  <dt>Debian on SGI Indy</dt>
    <dd><a href="http://www.zorg.org/linux/indy.php">http://www.zorg.org/linux/indy.php</a></dd>
  <dt>Debian on SGI O2</dt>
    <dd><a href="https://cyrius.com/debian/o2/">http://www.cyrius.com/debian/o2</a></dd>
</dl>


<toc-add-entry name="thanks">Thanks</toc-add-entry>

<p>The porterboxes and most of the build servers for the <em>mips</em> and
<em>mipsel</em> architectures are provided by <a href="https://imgtec.com">
Imagination Technologies</a>.</p>


<toc-add-entry name="dedication">Dedication</toc-add-entry>

<p>Thiemo Seufer, who was the lead MIPS porter in Debian, got killed in a
car accident. We <a href =
"$(HOME)/News/2008/20081229">dedicate the release</a> of the
Debian GNU/Linux <q>lenny</q> distribution to his memory.</p>

