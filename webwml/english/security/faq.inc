#use wml::debian::common_tags

<bind-gettext-domain domain="others" />

<define-tag small_Q whitespace=delete>
  <gettext domain="others">Q</gettext>
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
