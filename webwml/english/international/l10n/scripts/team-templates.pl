<: 
sub output_details {
    my $data = shift;
    $data =~ s/t/t /; $data =~ s/u/u /; $data =~ s/f/f /;
    $data =~ s/ *$//; $data =~ s/ / ; /g;
    $data =~ s/t/ t/; $data =~ s/u/ u/; $data =~ s/f/ f/;
    return $data;
}

$team = "$(TEAM)";
if (defined ($team) && $team ne "") {

    $header =~ s/<(td)/<$1 bgcolor="#ddddd5" align=center/g;
    print "<table border=1 cellpadding=0 cellspacing=0>".$header;

    foreach $pkg (sort keys %data) {
	if (defined $data{$pkg}{'templates'}) {
	    # search the template entry
	    $found=0;
	    if (defined $data{$pkg}{'templates'}) {
		foreach my $line (@{$data{$pkg}{'templates'}}){
		    if ($line =~ m,^([^:]*):$team:([^:]*):([^:]*)$,) {
			$found = 1;
			$filename=$1;
			$score=$2;
			$file=$3;
		    }
		}
	    }
#	    next unless $found;

	    if ($since_header++ >25) {
		print $header;
		$since_header=0;
	    }
	    print "<tr><td>$pkg";
	    
	    
	    print "<td>".($found ? l10n_output($score) : '--')
		 ."<td>".($found ? output_details($score) : '--')
	         ."<td>".($found ? "<a href=\"$TEMPLATES_ROOT/$pkg/$file\">$filename</a>" : "--");

	    #put english template
	    #FIXME: It's a pain when the english template is not better handeled by DB
	    $found = 0;
 	    $str = "<td>";
            for ($nb=0;$nb<@{$data{$pkg}{"templates"}};$nb++) {
		@po_part=split(/:/,$data{$pkg}{'templates'}[$nb]);
		if ("$po_part[1]" eq "en") {
		    $found = 1;
		    $str .= "<a href=\"$TEMPLATES_ROOT/$pkg/$po_part[3].gz\">$po_part[0]</a>";
		    $str .= "<br>\n";
		}
	    }
	    $str .= "---" unless $found;
	    print "$str\n";
	}
    }
    print $header."</table>";
} else {
    open(IN,"../data/langs")||open(IN,"$(ENGLISHDIR)/international/l10n/data/langs")||die ("Can't read the list of languages.\nThe Makefile is still faulty.\nRun make data/langs manually and report the bug\n");
    foreach $line (<IN>){
	next unless $line =~ m,^templates:,;
	$line =~ m,^([^:]*):(.*)$,;
	foreach (split(/ /,$2)) {
	    $tmpllangs{$_}=1;
	}
    }

    print "<ul>\n";
    foreach my $l (sort keys %tmpllangs) {
	next if $l eq "";
	print "<li><a href=\"templates-$l\">";
	language_name($l);
	print "</a></li>\n";
    }
    print "</ul>\n";
}

:>
