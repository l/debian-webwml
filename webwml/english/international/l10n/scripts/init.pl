
<:
##########
# Config part
##########
my $DISTRIB="unstable";
my $DB_FILE="$(ENGLISHDIR)/international/l10n/data/$DISTRIB";
my $PO_ROOT="http://www.ens-lyon.fr/~mquinson/debian/material/po/$DISTRIB";
my $TEMPLATES_ROOT="http://www.ens-lyon.fr/~mquinson/debian/material/templates/$DISTRIB";

##########
# Init
##########
push (@INC,"../../../english/international/l10n/scripts/");
require 'utils.pl';

my %data;
my %sections;
my %priorities;
my %l10nlangs;
my $pkg;
my $lang;
my %stats;
my @malformed;


my ($succeded,$res) = read_data ($DB_FILE);
if ($succeded) {
    %data=%{$res};
} else {
    die "Can't read from the datafile '$DB_FILE'.";
}

stats_clear();
foreach $pkg (keys %data) {
    if (!defined($data{$pkg}{"priority"}) || 
	!defined($data{$pkg}{"section"}) ||
	!defined($data{$pkg}{"type"})) {
	push @malformed,$pkg;
	undef $data{$pkg};
	next;
    }
    stats_pkg($pkg);
    $sections{$data{$pkg}{"section"}}=1;
    $priorities{$data{$pkg}{"priority"}}=1;
    if (defined($data{$pkg}{"stats"})) {
	foreach $lang(keys %{$data{$pkg}{"stats"}}) {
	    $l10nlangs{$lang} = 1;
	}
    }
}


#########################################
# Definitions of some usefull functions #
#########################################
###
### sub stat_clear() : clears the stat hash
###
sub stats_clear {
    $stats{"total"} = $stats{"i18n"} = 0;
    $stats{"po"} = $stats{"nls"} = 0;
    $stats{"t_gnu"} = $stats{"t_full"} = $stats{"t_nls"} = 0;
}
###
### sub stat_pkg(pkg) : add this pkg to the stats
sub stats_pkg {
    my $pkg = shift;
    
    my $i18n = 0;

    $stats{"total"}++;
    if (defined($data{$pkg}{"po"}) && @{$data{$pkg}{"po"}}) {
	$stats{"po"}++;
	$i18n = 1;
    }
    if (defined($data{$pkg}{"nls"})  && @{$data{$pkg}{"nls"}}) {
	$stats{"nls"}++;
	$i18n = 1;
    }

    if (defined($data{$pkg}{"type"}) && $data{$pkg}{"type"} eq "gnu") {
	$stats{"t_gnu"}++;
	$i18n = 1;
    }
    if (defined($data{$pkg}{"type"}) && $data{$pkg}{"type"} eq "nls") {
	$stats{"t_nls"}++;
	$i18n = 1;
    }
    if (defined($data{$pkg}{"type"}) && $data{$pkg}{"type"} eq "full") {
	$stats{"t_full"}++;
	$i18n = 1;
    }
    if ($i18n) {
	$stats{"i18n"}++;
    }
}

sub calc_percent{
    my $up=shift;
    my $down=shift;
    my $res;

    if ($down==0) {
	return "NaN";
    }
    $res = $up/$down*100;
    $res =~ s/^([0-9]*)\..*/$1/;
    return $res;
}
sub one_stat_output {
    my $name = shift;
    my $percent1=calc_percent($stats{$name},$stats{'total'});
    my $percent2=calc_percent($stats{$name},$stats{'i18n'});

    if ($stats{$name} == 0) {
	return "<td align=center>$stats{$name}";
    }

    my $res = "<td align=center>$stats{$name} (";

    if ($percent1 eq "NaN") {
	$res .= "--";
    } else {
	$res .="$percent1\%";
    }
    $res .= ",";
    if ($percent2 eq "NaN") {
	$res .= "--";
    } else {
	$res .="$percent2\%";
    }
    return $res.")";
}
sub stats_output {
    my $percent;
    my $res = "";

    # general statistic
    $percent = calc_percent($stats{'i18n'},$stats{'total'});
    $res.= "<td align=center>$stats{'total'}<td align=center> $stats{'i18n'}";
    if ($percent ne "NaN" && $percent ne "0") {
	$res .= "($percent\%)";
    }
    
    # per sort of file statistics 
    $res .= one_stat_output("po");
    $res .= one_stat_output("nls");
    
    # per organisation statistics
    $res .= one_stat_output("t_gnu");
    $res .= one_stat_output("t_nls");
    $res .= one_stat_output("t_full");

    return $res."\n";
}

:>

