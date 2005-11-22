#include '$(ENGLISHDIR)/international/l10n/dtc.def'

{: [[s/.*<ul>\s*\n<\/ul>//s]]
<h3><pkg-section main></h3>
<ul>
#include '$(ENGLISHDIR)/international/l10n/templates/gen/errors-by-pkg.main.inc'
</ul>
:}

{: [[s/.*<ul>\s*\n<\/ul>//s]]
<h3><pkg-section contrib></h3>
<ul>
#include '$(ENGLISHDIR)/international/l10n/templates/gen/errors-by-pkg.contrib.inc'
</ul>
:}

{: [[s/.*<ul>\s*\n<\/ul>//s]]
<h3><pkg-section non-free></h3>
<ul>
#include '$(ENGLISHDIR)/international/l10n/templates/gen/errors-by-pkg.non-free.inc'
</ul>
:}

