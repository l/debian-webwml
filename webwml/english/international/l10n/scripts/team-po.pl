#include "$(ENGLISHDIR)/international/l10n/scripts/l10nheader.wml"
#include "$(ENGLISHDIR)/international/l10n/dtc.def"
#include "$(ENGLISHDIR)/international/l10n/scripts/init.pl"
#include "$(ENGLISHDIR)/international/l10n/scripts/ranking.pl"

<:

sub output_details {
    my $data = shift;
    $data =~ s/t/t /; $data =~ s/u/u /; $data =~ s/f/f /;
    $data =~ s/ *$//; $data =~ s/ / ; /g;
    $data =~ s/t/ t/; $data =~ s/u/ u/; $data =~ s/f/ f/;
    return $data;
}

$cur_lang = "$(CUR_LANG)";
$team = "$(TEAM)";
if (defined ($team) && $team ne "") {
    print "<table border=1 cellpadding=0 cellspacing=0>";
    $header =~ s/<(td)/<$1 bgcolor="#ddddd5" align=center/g;
    print $header;

    foreach $pkg (sort keys %data) {
	if (defined $data{$pkg}{'stats'} && defined $data{$pkg}{'po'}) {
#	    next unless defined $data{$pkg}{'stats'}{$team}; 

	    if ($since_header++ >25) {
		print $header;
		$since_header=0;
	    }
	    $str = "<tr><td>$pkg"
		."<td>".l10n_output($data{$pkg}{'stats'}{$team})
		."<td>".output_details($data{$pkg}{'stats'}{$team})
		."<td>";
	    
	    $found = 0;
	    for ($nb=0;$nb<@{$data{$pkg}{"po"}};$nb++) {
		@po_part=split(/:/,$data{$pkg}{'po'}[$nb]);
		if ("$po_part[1]" eq "$team") {
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
} else { #team not defined. Let's output all of them 
    my %polangs;
    foreach $pkg (sort keys %data) {
	if (defined $data{$pkg}{'stats'} && defined $data{$pkg}{'po'}) {
	    foreach my $t (sort keys %{$data{$pkg}{'stats'}}) {
		$polangs{$t}=$1;
	    }
	}
    }
    print "<ul>\n";
    foreach my $l (sort keys %polangs) {
	print "<li><a href=\"po-$l\">";
	language_name($l);
	print "</a></li>\n";
    }
    print "</ul>\n";
}
:>





