#use wml::scripts::l10nheader

<: 

#   Calculate @tmpllangs, this variable contains languages with
#   Debconf template files
@tmpllangs = ();
open (IN,"../data/langs") || open (IN,"$(ENGLISHDIR)/international/l10n/data/langs") || die ("Can't read the list of languages.\nThe Makefile is still faulty.\nRun make data/langs manually and report the bug\n");
foreach my $line (<IN>) {
	next unless $line =~ m/^templates:/;
	$line =~ s/^[^:]+:\s*//;
	$line =~ s/\s*$//;
	foreach (split(/ /, $line)) {
		push (@tmpllangs, $_);
	}
}
close(IN);

#   Prepare output files
$uclang = uc('$(CUR_ISO_LANG)');
print "%!slice -o ((UNDEF+$uclang\@-T_*)+(INDEX\@+INDEXn$uclang))-LIST:team-templates.$(CUR_ISO_LANG).html\n";
foreach my $l (@tmpllangs) {
        print "%!slice -o ((UNDEF+$uclang\@+LIST\@+LISTn$uclang-T_*)+(T_".uc($l)."\@+T_".uc($l)."n$uclang))-INDEX:templates-$l.$(CUR_ISO_LANG).html\n";
}

sub output_details {
    my $data = shift;
    $data =~ s/t/t /; $data =~ s/u/u /; $data =~ s/f/f /;
    $data =~ s/ *$//; $data =~ s/ / ; /g;
    $data =~ s/t/ t/; $data =~ s/u/ u/; $data =~ s/f/ f/;
    return $data;
}

sub tmpl_list_langs {
    print "<ul>\n";
    foreach my $l (sort @tmpllangs) {
	print "<li><a href=\"templates-$l\">";
	language_name($l);
	print "</a></li>\n";
    }
    print "</ul>\n";
}

sub tmpl_show_lang {
	$header = "<tr><td><Package><td><Score><td>Details<td>Template<td>Full template\n";
	$header =~ s/<(td)/<$1 bgcolor="#ddddd5" align="center"/g;
	print "<table border=1 cellpadding=0 cellspacing=0>".$header;

	foreach $team (@tmpllangs) {
		$since_header=0;
		print "[T_".uc($team).":";
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
#				next unless $found;

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
		print ":T_".uc($team)."]";
	}
	print $header."</table>";
}

:>
