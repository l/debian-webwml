<define-tag small_Q whitespace=delete>
	[EN:Q:]
	[AR:Q:]
	[CA:P:]
	[DA:Sp:]
	[DE:F:]
	[EL:Q:]
	[EO:Q:]
	[ES:P:]
	[FI:K:]
	[FR:Q.&nbsp;:]
	[HR:Q:]
 	[HU:Q:]
	[ID:Q:]
	[IT:Q:]
 	[JA:Q:]
 	[KO:Q:]
	[LT:Q:]
	[NL:Q:]
	[NO:Q:]
	[PL:Q:]
	[PT:P:]
	[RO:Q:]
	[RU:Q:]
	[SV:F:]
	[TR:S:]
	[ZH:Q:]
</define-tag>

<:
  $item_count = 0;
:>

<define-tag toc-add-entry endtag=required>
<preserve name>
<set-var %attributes>

<if <not <get-var name>>
  <set-var name="<:=++$item_count:>">
>

<p><em><a name="<get-var name>"><small_Q>: %body</a></em></p>

<restore name>
</define-tag>

<define-tag maketoc>

<ol>
<:
  $numid = 0;
  if (open (F, $WML_SRC_FILENAME)) {
    $state = 0;
    while (<F>) {
      if ($state == 0 && m,[<]toc-add-entry(.*),) {
        $state = 1;

        if (m,[<]toc-add-entry[>](.*)[<]/toc-add-entry[>],) {
	  $id = ++$numid;
	  $topic = $1;
	  $state = 2;
        } elsif (m,[<]toc-add-entry\s+name="?([^">]*)"?[>](.*)[<]/toc-add-entry[>],) {
	  $id = $1;
	  $topic = $2;
	  $state = 2;
        } elsif (m,[<]toc-add-entry[>](.*),) {
	  $id = ++$numid;
	  $topic = $1;
	  $state = 1;
        } elsif (m,[<]toc-add-entry\s+name="?([^">]*)"?[>](.*),) {
	  $id = $1;
	  $topic = $2;
	  $state = 1;
	} else {
	}

      } elsif ($state == 1) {
        if (m,\s*(.*)[<]/toc-add-entry[>],) {
	  $topic .= " " . $1;
	  $state = 2;
        } elsif (m,\s*(.*),) {
	  $topic .= " " . $1;
	}
      } # else just skip it

      if ($state == 2) {
        printf "<li> <a href=\"#%s\">%s</a>\n", $id, $topic;
	$state = 0;
      }
    }
    close (F);
  }
:>
</ol>

</define-tag>

# Local variables:
# mode: indented-text
# end:
