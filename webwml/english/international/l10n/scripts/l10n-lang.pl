#include "../../../english/international/l10n/dtc.def"
#include "../../../english/international/l10n/scripts/init.pl"
#include "../../../english/international/l10n/scripts/ranking.pl"

<:
$cur_lang = "$(CUR_LANG)";

sub output_details {
    my $data = shift;
    $data =~ s/t/t /; $data =~ s/u/u /; $data =~ s/f/f /;
    $data =~ s/ *$//; $data =~ s/ / ; /g;
    $data =~ s/t/ t/; $data =~ s/u/ u/; $data =~ s/f/ f/;
    return $data;
}
sub make_one_lang {
    $lang = shift;
    my $since_header = 0;
    my $str = "<h2>";
    if (defined  $trans{language2code($cur_lang)}{lc(code2language($lang))}) {
	$str .= ucfirst($trans{language2code($cur_lang)}{lc(code2language($lang))});
    } else {
	$str .= code2language($lang);
    }
    $str .= "</h2>\n<l10nLangIntro>\n";
    $str .= "<ul><li><a href=\"#po\"><listPoFiles></a></li>\n";
    $str .= "<li><a href=\"#templates\"><listTemplates></a></li></ul>\n\n";
    $str .= "<h3><a name=\"po\"><listPoFiles></h3>\n";
    $str .= "<table border=1 cellpadding=0 cellspacing=0>\n";
    print $str;

    #
    # outputs the po files
    #
    $header = "<tr><td><package><td><score><td><details><td><poFiles>\n";#<td>Maintainer<td>comments\n";
    $header =~ s/<(td)/<$1 bgcolor="#ddddd5" align=center/g;
    print $header;

    foreach $pkg (sort keys %data) {
	if (defined $data{$pkg}{'stats'} && defined $data{$pkg}{'po'}) {
	    if ($since_header++ >25) {
		print $header;
		$since_header=0;
	    }
	    $str ="<tr><td>$pkg<td>";
	    $str .= (defined $data{$pkg}{'stats'}{$lang} ? 
		     l10n_output($data{$pkg}{'stats'}{$lang}) :
		     "--");
	    $str .= "<td>";
	    $str .= (defined $data{$pkg}{'stats'}{$lang} ? 
		     output_details($data{$pkg}{'stats'}{$lang}) :
		     "--");
	    $str .= "<td>";
	    $found = 0;
	    for ($nb=0;$nb<@{$data{$pkg}{"po"}};$nb++) {
		@po_part=split(/:/,$data{$pkg}{'po'}[$nb]);
		if ("$po_part[1]" eq "$lang") {
		    $found = 1;
		    $str .= "<a href=\"$PO_ROOT/$pkg/$po_part[3].gz\">$po_part[0]</a>";
		    $str .= "&nbsp;(".(output_details($po_part[2])).")" if ($po_part[2] ne ""); 
		    $str .= "<br>";
		}
	    }
	    $str .= "---" unless $found;
	    print $str."\n";
	}
    }
    print $header."</table>";

    #
    # Outputs the templates
    #
    $header = "<tr><td><package><td><templatesFiles><td><englishTemplate>\n";#<td>Maintainer<td>comments\n";
    $header =~ s/<(td)/<$1 bgcolor="#ddddd5" align=center/g;
    $since_header=0;

    print "<h3><a name=\"templates\"><listTemplates></h3>\n";
    print "<table border=1 cellpadding=0 cellspacing=0>\n".$header;

    foreach $pkg (sort keys %data) {
	if (defined $data{$pkg}{'templates'}) {
	    if ($since_header++ >25) {
		print $header;
		$since_header=0;
	    }
	    print "<tr><td>$pkg";

	    #put link to template in this lang
	    $found = 0;
	    $str = "<td>";
	    for ($nb=0;$nb<@{$data{$pkg}{"templates"}};$nb++) {
		@po_part=split(/:/,$data{$pkg}{'templates'}[$nb]);
		if ("$po_part[1]" eq "$lang") {
		    $found = 1;
		    $str .= "<a href=\"$TEMPLATES_ROOT/$pkg/$po_part[3].gz\">$po_part[0]</a>";
		    $str .= "&nbsp;(".(output_details($po_part[2])).")" if ($po_part[2] ne ""); 
		    $str .= "<br>";
		}
	    }
	    $str .= "---" unless $found;
	    print $str;

	    #put english template
	    $found = 0;
	    $str = "<td>";
	    for ($nb=0;$nb<@{$data{$pkg}{"templates"}};$nb++) {
		@po_part=split(/:/,$data{$pkg}{'templates'}[$nb]);
		if ("$po_part[1]" eq "en") {
		    $found = 1;
		    $str .= "<a href=\"$TEMPLATES_ROOT/$pkg/$po_part[3].gz\">$po_part[0]</a>";
		    $str .= "&nbsp;(".(output_details($po_part[2])).")" if ($po_part[2] ne ""); 
		    $str .= "<br>";
		}
	    }
	    $str .= "---" unless $found;
	    print $str."\n";
	}
    }
    print $header."</table>";

}
sub do_all {
    my $cil = uc("$(CUR_ISO_LANG)");

    print("[INDEX:\n");
    print "<ul>";
    foreach $lang (sort keys %l10nlangs) {
	$str =  "<li><a href=\"l10n-lang-$lang\">";
	if (defined  $trans{language2code($cur_lang)}{lc(code2language($lang))}) {
	    $str .= ucfirst($trans{language2code($cur_lang)}{lc(code2language($lang))});
	} else {
	    $str .= code2language($lang);
	}
	print $str."</a></li>\n";
    }
    print "</ul>";
    print(":INDEX]\n");

    foreach $lang (sort keys %l10nlangs) {
	my $code = 'L10N' . uc ($lang);
	print("[NULL:\n");
	print("%!slice -o UNDEFu(${cil}-L10N*)u${code}\@u(${code}n${cil}):$(WML_SRC_BASENAME)-$lang.$(CUR_ISO_LANG).html\n");
	print(":NULL]\n");
	print("<protect pass=5-8>[$code:\n");
	make_one_lang($lang);
	print(":$code]</protect>\n");
    }
}	

do_all();

:>

