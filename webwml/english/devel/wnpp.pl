# originally written by Marcello Magallon

<perl>

use Net::LDAP;

# this is ok this way.  It says which server to query, on which port and what
# to fetch from it.  The attribs array could be reduced.

$server = "bugs.debian.org";
$port = "35567";
$base   = "ou=Bugs,o=Debian Project,c=US";
$attrs  = [
    'bugid',
    'originater',
    'date',
    'subject',
    'package',
    'severity',
    'done',
    'mergedwith'
];

# The maintainers flat database
$MAINTAINERS = "/org/ftp.debian.org/ftp/indices/Maintainers";
my $host = `hostname -f`;
$MAINTAINERS = "Maintainers" if ( $host ne "master.debian.org" );

open MAINTAINERS or die "Can't find Maintainers list: $!\n"; 
while (<MAINTAINERS>) {
    if (/^(\S+)\s+/) {
    	$maintainer{$1} = $';
    }
}
close MAINTAINERS;

$ldap = Net::LDAP->new($server, 'port' => $port);
$ldap->bind;
$mesg = $ldap->search('base' => $base,
                      'filter' => "(package=wnpp)",
                      'attrs' => $attrs) or die;

foreach $entry ($mesg->entries) {
    next if defined ($entry->get('done'));
    my $subject = @{$entry->get('subject')}[0];
    my $bugid = @{$entry->get('bugid')}[0];
    chomp $subject;
    # Make order out of chaos    
    if ($subject =~ m/^(?:ITO|RFA):\s*(\S+)(?:\s+-+\s+)?/) {
        $rfa{$bugid} = $1 . ($'?": ":"") . $';
	if (defined($maintainer{$1})) {
	    push @{$rfabymaint{$maintainer{$1}}}, $bugid;
	} else {
	    push @{$rfabymaint{"Unknown"}}, $bugid;
	}
    } elsif ($subject =~ m/^O:\s*(\S+)(?:\s+-+\s+)?/) {
        $orphaned{$bugid} = $1 . ($'?": ":"") . $';
    } elsif ($subject =~ m/^W:\s*(\S+)(?:\s+-+\s+)?/) {
        $withdrawn{$bugid} = $1 . ($'?": ":"") . $';
    } elsif ($subject =~ m/^ITA:(?:\s*(?:ITO|RFA|O|W):)?\s*(\S+)(?:\s+-+\s+)?/) {
        $ita{$bugid} = $1 . ($'?": ":"") . $';
    } elsif ($subject =~ m/^ITP:(?:\s*RFP:)?\s*(\S+)(?:\s+-+\s+)?/) {
        $itp{$bugid} = $1 . ($'?": ":"") . $';
    } elsif ($subject =~ m/^RFP:\s*(\S+)(?:\s+-+\s+)?/) {
        $rfp{$bugid} = $1 . ($'?": ":"") . $';
    } else {
    	print STDERR "What is this ($bugid): $subject\n";
    }
}

$ldap->unbind;

$\ = "\n";

my (@rfa_bypackage-html, @rfa_bymaint-html, @orphaned-html, @withdrawn-html);
my (@being_adopted-html, @being_packaged-html, @requested-html);

foreach (sort { $rfa{$a} cmp $rfa{$b} } keys %rfa) {
    push @rfa_bypackage-html, "\n<li><a href=\"http://bugs.debian.org/$_\">$rfa{$_}</a>";
}

foreach $maint (sort keys %rfabymaint) {
    push @rfa_bymaint-html, "<li>$maint";
    push @rfa_bymaint-html, "<ul>";
    foreach (sort { $rfa{$a} cmp $rfa{$b} } @{$rfabymaint{$maint}}) {
        push @rfa_bymaint-html, "<li><a href=\"http://bugs.debian.org/$_\">$rfa{$_}</a>";
    }
    push @rfa_bymaint-html, "</ul>";
}

foreach (sort { $orphaned{$a} cmp $orphaned{$b} } keys %orphaned) {
    push @orphaned-html, "<li><a href=\"http://bugs.debian.org/$_\">$orphaned{$_}</a>";
}

foreach (sort { $withdrawn{$a} cmp $withdrawn{$b} } keys %withdrawn) {
    push @withdrawn-html, "<li><a href=\"http://bugs.debian.org/$_\">$withdrawn{$_}</a>";
}

foreach (sort { $ita{$a} cmp $ita{$b} } keys %ita) {
    push @being_adopted-html, "<li><a href=\"http://bugs.debian.org/$_\">$ita{$_}</a>";
}

foreach (sort { $itp{$a} cmp $itp{$b} } keys %itp) {
    push @being_packaged-html, "<li><a href=\"http://bugs.debian.org/$_\">$itp{$_}</a>";
}

foreach (sort { $rfp{$a} cmp $rfp{$b} } keys %rfp) {
    push @requested-html, "<li><a href=\"http://bugs.debian.org/$_\">$rfp{$_}</a>";
}

</perl>
