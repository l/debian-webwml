#include "../../../english/international/l10n/dtc.def"
#include "../../../english/international/l10n/scripts/init.pl"

<:
my %errors;
my %warns;
my $type;
my $file;
foreach $pkg (sort keys %data) {
    next unless (defined($data{$pkg}{'errors'}) || defined($data{$pkg}{'warnings'})); 
    if (defined($data{$pkg}{'errors'})) {
	for ($nb=0;$nb<@{$data{$pkg}{"errors"}};$nb++) {
	    # find the type of the error
	    if ($data{$pkg}{"errors"}[$nb] =~ m,can't guess the language of,) {#'
		$type = "guess";
	    } elsif ($data{$pkg}{"errors"}[$nb] =~ m,is not a language code,) {
		$type = "guess";
	    } elsif ($data{$pkg}{"errors"}[$nb] =~ m,is not a valid,) {
		$type = "section";
	    } elsif ($data{$pkg}{"errors"}[$nb] =~ m,Error of msgfmt --statistics,) {
		$type = "msgfmt";
	    } else {
		$type = "other";
	    }
	    # put it in the hash table
	    $errors{$type}{$pkg}[@{$errors{$type}{$pkg}}] = 
		$data{$pkg}{"errors"}[$nb];
	}
    }
    if (defined($data{$pkg}{'warnings'})) {
	for ($nb=0;$nb<@{$data{$pkg}{"warnings"}};$nb++) {
	    # find the type of the error
	    if ($data{$pkg}{"warnings"}[$nb] =~ m,Warning of msgfmt,) {
		$type = "msgfmt";
	    } else {
		$type = "other";
	    }
	    # put it in the hash table
	    $warns{$type}{$pkg}[@{$warns{$type}{$pkg}}] = 
		$data{$pkg}{"warnings"}[$nb];
	}
    }
}
sub print_section {
    my $name = shift;
    my $col_file = shift;
    my $header = shift;
    my $dataref = shift;
    my %data= %{$dataref};
    my $rowspawn;

    if (defined %data) {
	$header .= "<font size=-2><a href=#top>(<top>)</a></font>";
	$header =~ s/<(td)/<$1 bgcolor="#ddddd5" align=center/g;
	$since_header = 0;
	print  "<table border=1>".$header;
	foreach $pkg (sort keys %data) {
	    $since_header++;
	    if ($since_header == 25) {
		$since_header=0;
		print  $header;
	    }
	    $rowspawn = @{$data{$pkg}};
	    for ($nb=0;$nb<@{$data{$pkg}};$nb++) {
		@strs = split (/\n/,$data{$pkg}[$nb]);
		$line = shift @strs;
		if ($col_file) {
		    if ($line =~ m/ -v (.*)\)/) {
			$file=$1;
		    } elsif ($file =~ m,Error of msgfmt --statistics,) {
			$file=$1;
		    }
		}
		if ($nb == 0) {
		    print  "\n<tr><td ROWSPAN=\"$rowspawn\" align=center valign=center>$pkg";
		} else {
		    print  "\n<tr>";
		}
		if ($col_file) {
		    print  "<td>$file<td>";
		} else {
		    print  "<td>$line<br>";
		}
		while ($line = shift @strs) {
		    next if ($line =~ m,found [0-9]* fatal errors,);
		    if ($line =~ m,$file: warning: (.*),) {
			$line = $1;
		    }
		    print  "$line<br>";
		}
	    }
	}
	print  $header;
	print  "\n</table>\n";
    } else {
	print  "<br>I didn't found any $name<br>";
    }   
}

print  "<a name=top>\n<li><A href=#warnings><warn-title></a><ul>\n";
if (defined $warns{"msgfmt"}) {
    print  "<li><a href=#w_msgfmt><warn-msgfmt></a>\n";
}
if (defined $warns{"other"}) {
    print  "<li><a href=#w_other><warn-other></a>\n";
}

print  "</ul><li><A href=#errors><err-title></a><ul>\n";
if (defined $errors{"msgfmt"}) {
    print  "<li><a href=#e_msgfmt><err-msgfmt></a>\n";
}
if (defined $errors{"section"}) {
    print  "<li><a href=#section><err-sec></a>\n";
}
if (defined $errors{"guess"}) {
    print  "<li><a href=#guess><err-guess></a>\n";
}
if (defined $errors{"other"}) {
    print  "<li><a href=#e_other><err-other></a>\n";
}
print  "</ul><hr>\n";
### Make the TOC
if ((defined $warns{"msgfmt"})||(defined $warns{"other"})) {
    print "<a name=warnings><h2><warn-title></h2>\n";
}
#### WARNINGS of msgfmt
if (defined $warns{"msgfmt"}) {
    print  <<'EOF'
<a name=w_msgfmt><h3><warn-msgfmt></h3>
$slice{'warn-msgfmt-text'}
EOF
    ;

    print_section("Warnings of msgfmt",
		  1, #col_file true
		  "<hr><tr><td><package><td><file><td><warn-msgfmt>",
		  \%{$warns{"msgfmt"}});
}

#### other WARNINGS
if (defined $warns{"other"}) {
    print  "<a name=w_other><h3><warn-other></h3>";
    print_section("other warnings",
		  0, #col_file true
		  "<hr><tr><td><package><td><warning>",
		  \%{$warns{"other"}});
}

#### ERRORS of msgfmt
if ((defined $errors{"msgfmt"})||
    (defined $errors{"section"})||
    (defined $errors{"guess"})||
    (defined $errors{"other"})) {
    print "<hr><a name=errors><h2><err-title></h2>\n";
}

if (defined $errors{"msgfmt"}) {
    print "<a name=e_msgfmt><h3><err-msgfmt></h3>$slice{'err-msgfmt-text'}\n";
    print_section("errors of msgfmt",
		  1, #col_file true
		  "<tr><td><package><td><file><td><err-msgfmt>\n",
		  \%{$errors{"msgfmt"}});
}

#### ERRORS of section
if (defined $errors{"section"}) {
    print "<a name=section><h3><err-sec></h3>\n$slice{err-sec-text}\n<table border=1>";
    print_section("errors of section and priority",
		  0, #col_file false
		  "<tr><td><package><td><err-sec>\n",
		  \%{$errors{"section"}});
}

#### ERRORS of guess
if (defined $errors{"guess"}) {
    print  "<a name=guess><h3><err-guess></h3>\n$slice{err-guess-text}\n<table border=1>\n";
    print_section("errors of guess",
		  0, #col_file false
		  "<tr><td><package><td><err-guess>\n",
		  \%{$errors{"guess"}});
}

#### other ERRORS
if (defined $errors{"other"}) {
    print  "<a name=e_other><h3><err-other></h3>";
    print_section("other errors",
		  0, #col_file true
		  "<hr><tr><td><package><td><error>",
		  \%{$errors{"other"}});
}

:>
