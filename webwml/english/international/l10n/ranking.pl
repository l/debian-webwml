##
## Some initialisations and functions for the pages which want to make some ranking
## ie, the l10n and the l10n-rank pages
##
my %average; # to store the average l10n of each language
my %scores; # to store the score of each language
my %nb_per_lang; # to store the nb of l10n packages per language


sub html_header {
    my $res;
    $res = "<tr>";
}

sub l10n_add {
    my $stat1 = shift;
    my $stat2 = shift;
    my $t = "0";
    my $u = "0";
    my $f = "0";
    my $res;

    if ($stat1 =~ /([0-9]*)t/) {  $t+=$1;  }
    if ($stat1 =~ /([0-9]*)u/) {  $u+=$1;  }
    if ($stat1 =~ /([0-9]*)f/) {  $f+=$1;  }

    if ($stat2 =~ /([0-9]*)t/) {  $t+=$1;  }
    if ($stat2 =~ /([0-9]*)u/) {  $u+=$1;  }
    if ($stat2 =~ /([0-9]*)f/) {  $f+=$1;  }

    $res ="$t t$f f$u u";
    $res =~ s/ //g;
    return $res;
}

sub l10n_output {
    my $stats=shift;
    my $t = "0";
    my $u = "0";
    my $f = "0";
    my $percent;

    if ($stats =~ /([0-9]*)t/) {  $t=$1;  }
    if ($stats =~ /([0-9]*)u/) {  $u=$1;  }
    if ($stats =~ /([0-9]*)f/) {  $f=$1;  }
    $percent = calc_percent($t,$t+$u+$f);
    if ($percent eq "NaN") {
	return "--";
    }
    if ($percent == 100) {
	return "<font color=green>100\%</font>";
    } if ($percent >=50) {
	return "<font color=orange>$percent\%</font>";
    } 
    return "<font color=red>$percent\%</font>";
}

sub score_output {
    my $lang= shift;
    my $t = "0";
    my $u = "0";
    my $f = "0";
    my $percent;
    my $res;

    if ($average{$lang} =~ /([0-9]*)t/) {  $t=$1;  }
    if ($average{$lang} =~ /([0-9]*)u/) {  $u=$1;  }
    if ($average{$lang} =~ /([0-9]*)f/) {  $f=$1;  }

    if ($t+$u+$f == 0) {
	return "Err";
    }
    $res = $t/($t+$u+$f) * $nb_per_lang{$lang};
    $res =~ s/^([0-9]*\..).*/$1/;
    if (defined($scores{$res})) {
	$scores{$res} .= "|$lang";
    } else {
	$scores{$res} = "$lang";
    }

    return "<b>".$res."</b>";
}

sub score_init {
    foreach $pkg (sort keys %data) {
	if (defined($data{$pkg}{'stats'})) {
	    foreach $lang (sort keys %langs) {
		if (defined($data{$pkg}{'stats'}{$lang})) {
		    #store in average
		    if (!defined ($average{$lang})) {
			$average{$lang} = $data{$pkg}{'stats'}{$lang};
		    } else {
			$average{$lang} = l10n_add($average{$lang}, $data{$pkg}{'stats'}{$lang});
		}
		    #store in nb_per_lang
		    if (!defined ($nb_per_lang{$lang})) {
			$nb_per_lang{$lang} = 1;
		    } else {
			$nb_per_lang{$lang}++;
		    }		    
		}
	    }
	}
    }
    foreach $lang (sort keys %langs) {
	score_output($lang);
    }
}

