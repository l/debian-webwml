# originally written by Marcello Magallon

<perl>

use Net::LDAP;
use Date::Parse;

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

sub htmlsanit {
    %escape = ('<' => 'lt', '>' => 'gt', '&' => 'amp', '"' => 'quot');
    my $in = shift;
    my $out;
    while ($in =~ m/[<>&"]/) {
        $out.= $`. '&'. $escape{$&}. ';';
        $in=$';
    }
    $out .= $in;
    return $out;
}

# The maintainers flat database
$MAINTAINERS = "/org/ftp.debian.org/ftp/indices/Maintainers";
my $host = `hostname -f`; chop $host;
$MAINTAINERS = "Maintainers" if ( $host ne "master.debian.org" );

open MAINTAINERS or die "Can't find $MAINTAINERS file at $host: $!\n";
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

$curdate = time;

foreach $entry ($mesg->entries) {
    use integer;
    next if defined ($entry->get('done'));
    my $subject = @{$entry->get('subject')}[0];
    my $bugid = @{$entry->get('bugid')}[0];
    $age{$bugid} = ($curdate - str2time(@{$entry->get('date')}[0]))/86400;    
    chomp $subject;
    $subject = htmlsanit($subject);    
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
    } elsif ($subject =~ m/^ITP:(?:\s*RFP:)?\s*/) {
        $itp{$bugid} = join(": ", split(/\s+-+\s+/, $',2));
    } elsif ($subject =~ m/^RFP:\s*/) {
        $rfp{$bugid} = join(": ", split(/\s+-+\s+/, $',2)); 
    } else {
    	print STDERR "What is this ($bugid): $subject\n" if ( $host ne "master.debian.org" );
    }
}

$ldap->unbind;

my (@rfa_bypackage_html, @rfa_bymaint_html, @orphaned_html, @withdrawn_html);
my (@being_adopted_html, @being_packaged_html, @requested_html);

foreach (sort { $rfa{$a} cmp $rfa{$b} } keys %rfa) {
    push @rfa_bypackage_html, "\n<li><a href=\"http://bugs.debian.org/$_\">$rfa{$_}</a>";
}

foreach $maint (sort keys %rfabymaint) {
    push @rfa_bymaint_html, "<li>$maint";
    push @rfa_bymaint_html, "<ul>";
    foreach (sort { $rfa{$a} cmp $rfa{$b} } @{$rfabymaint{$maint}}) {
        push @rfa_bymaint_html, "<li><a href=\"http://bugs.debian.org/$_\">$rfa{$_}</a>";
    }
    push @rfa_bymaint_html, "</ul>";
}

foreach (sort { $orphaned{$a} cmp $orphaned{$b} } keys %orphaned) {
    push @orphaned_html, "<li><a href=\"http://bugs.debian.org/$_\">$orphaned{$_}</a>";
}

foreach (sort { $withdrawn{$a} cmp $withdrawn{$b} } keys %withdrawn) {
    push @withdrawn_html, "<li><a href=\"http://bugs.debian.org/$_\">$withdrawn{$_}</a>";
}

foreach (sort { $ita{$a} cmp $ita{$b} } keys %ita) {
    push @being_adopted_html, 
         "<li><a href=\"http://bugs.debian.org/$_\">$ita{$_}</a>, ",
         "$age{$_} days in adoption.";
}

foreach (sort { $itp{$a} cmp $itp{$b} } keys %itp) {
    push @being_packaged_html, 
         "<li><a href=\"http://bugs.debian.org/$_\">$itp{$_}</a>, ",
         "$age{$_} days in preparation";
}

foreach (sort { $rfp{$a} cmp $rfp{$b} } keys %rfp) {
    push @requested_html, 
         "<li><a href=\"http://bugs.debian.org/$_\">$rfp{$_}</a>, ";
    if ( $age{$_} == 0 ) { push @requested_html, "requested today." }
    elsif ( $age{$_} == 1 ) { push @requested_html, "requested yesterday." }
    else { push @requested_html, "requested $age{$_} days ago." };
}

</perl>
