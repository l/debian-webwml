# originally written by Marcelo Magallon
# for <perl>
#use wml::std::tags

<perl>

my $host = `hostname -f`;
chomp($host);

use SOAP::Lite;
use Date::Parse;
use HTML::Entities;
use Encode qw(decode);

# The maintainers flat database
my $maintainers_file = "$(ENGLISHDIR)/devel/wnpp/Maintainers";

my %maintainer;
open MAINTAINERS, '<:utf8', $maintainers_file or die "Can't find $maintainers_file file at $host: $!\n";
while (<MAINTAINERS>) {
    if (/^(\S+)\s+(.*)$/) {
	$maintainer{$1} = encode_entities($2);
    }
}
close MAINTAINERS;

my $soap = SOAP::Lite->uri('Debbugs/SOAP')->proxy('http://bugs.debian.org/cgi-bin/soap.cgi')
       or die "Couldn't make connection to SOAP insterface: $@";;
my $bugs = $soap->get_bugs(package=>'wnpp')->result;
my $status = $soap->get_status($bugs)->result() or die;

my $curdate = time;

my ( %rfa, %orphaned, %rfabymaint, %rfp, %ita, %itp, %age,
     %rfh, %oth );
 ALLPKG: foreach my $bugid (@$bugs) {
     use integer;
     next if $status->{$bugid}->{done};
     next if $status->{$bugid}->{archived};
     my $subject = $status->{$bugid}->{subject};
     # If a bug is merged with another, then only consider the youngest
     # bug and throw the others away.  This will weed out duplicates.
     my $mergedwith = $status->{$bugid}->{mergedwith};
     foreach my $merged (split ' ',$mergedwith) {
         next ALLPKG if int($merged) < int($bugid);
     }
     $age{$bugid} = ($curdate - $status->{$bugid}->{date})/86400;
     $subject = encode_entities($subject);    
     # Make order out of chaos    
     if ($subject =~ m/^(?:ITO|RFA):\s*(\S+)(?:\s+-+\s+)?(.*)$/) {
         $rfa{$bugid} = $1 . ($2?": ":"") . $2;
         if (defined($maintainer{$1})) {
             push @{$rfabymaint{$maintainer{$1}}}, $bugid;
         } else {
             push @{$rfabymaint{"Unknown"}}, $bugid;
         }
     } elsif ($subject =~ m/^O:\s*(\S+)(?:\s+-+\s+)?(.*)$/) {
         $orphaned{$bugid} = $1 . ($2?": ":"") . $2;
     } elsif ($subject =~ m/^ITA:(?:\s*(?:ITO|RFA|O|W):)?\s*(\S+)(?:\s+-+\s+)?(.*)$/) {
         $ita{$bugid} = $1 . ($2?": ":"") . $2;
     } elsif ($subject =~ m/^ITP:(?:\s*RFP:)?\s*(.*)/) {
         $itp{$bugid} = join(": ", split(/\s+-+\s+/, $1,2));
     } elsif ($subject =~ m/^RFP:\s*(.*)/) {
         $rfp{$bugid} = join(": ", split(/\s+-+\s+/, $1,2));
     } elsif ($subject =~ m/^RFH:\s*(.*)/) {
         $rfh{$bugid} = join(": ", split(/\s+-+\s+/, $1,2));
     } elsif ($subject =~ m/^(?:OTH|ITH):\s*(.*)/) {
         $oth{$bugid} = join(": ", split(/\s+-+\s+/, $1,2));
     } else {
#         print STDERR "What is this ($bugid): $subject\n" if ( $host ne "klecker.debian.org" );
     }
 }

my (@rfa_bypackage_html, @rfa_bymaint_html, @orphaned_html);
my (@being_adopted_html, @being_packaged_html, @requested_html);
my (@rfh_html, @oth_html);

foreach my $bug (sort { $rfa{$a} cmp $rfa{$b} } keys %rfa) {
    push @rfa_bypackage_html, "\n<li><btsurl bugnr=\"$bug\">$rfa{$bug}</btsurl>";
    (my $pkg = $rfa{$bug}) =~ s/^(.+?):\s+.*$/$1/;
    push @rfa_bypackage_html, " <pdolink \"$pkg\" />";
    push @rfa_bypackage_html, "</li>\n";
}
if ($#rfa_bypackage_html == -1) { @rfa_bypackage_html = ('<li><norfa /></li>') }

foreach my $maint (sort keys %rfabymaint) {
    push @rfa_bymaint_html, "<li>$maint";
    push @rfa_bymaint_html, "<ul>";
    foreach my $bug (sort { $rfa{$a} cmp $rfa{$b} } @{$rfabymaint{$maint}}) {
        push @rfa_bymaint_html, "<li><btsurl bugnr=\"$bug\">$rfa{$bug}</btsurl>";
        (my $pkg = $rfa{$bug}) =~ s/^(.+?):\s+.*$/$1/;
        push @rfa_bymaint_html, " <pdolink \"$pkg\" /></li>\n";
    }
    push @rfa_bymaint_html, "</ul>";
    push @rfa_bymaint_html, "</li>\n";
}
if ($#rfa_bymaint_html == -1) { @rfa_bymaint_html = ('<li><norfa /></li>') }

foreach my $bug (sort { $orphaned{$a} cmp $orphaned{$b} } keys %orphaned) {
    push @orphaned_html, "<li><btsurl bugnr=\"$bug\">$orphaned{$bug}</btsurl>";
    (my $pkg = $orphaned{$bug}) =~ s/^(.+?):\s+.*$/$1/;
    push @orphaned_html, " <pdolink \"$pkg\" />";
    push @orphaned_html, "</li>\n";
}
if ($#orphaned_html == -1) { @orphaned_html = ('<li><noo /></li>') }

foreach my $bug (sort { $ita{$a} cmp $ita{$b} } keys %ita) {
    (my $pkg = $ita{$bug}) =~ s/^(.+?):\s+.*$/$1/;
    push @being_adopted_html, 
         "<li><btsurl bugnr=\"$bug\">$ita{$bug}</btsurl>";
    push @being_adopted_html,
         " <pdolink \"$pkg\" />, ";
    if ( $age{$bug} == 0 ) { push @being_adopted_html, '<adoption-today />' }
    elsif ( $age{$bug} == 1 ) { push @being_adopted_html, '<adoption-yesterday />' }
    else { push @being_adopted_html, "<adoption-days \"$age{$bug}\" />" };
    push @being_adopted_html, "</li>\n";
}
if ($#being_adopted_html == -1) { @being_adopted_html = ('<li><noita /></li>') }

foreach (sort { $itp{$a} cmp $itp{$b} } keys %itp) {
    push @being_packaged_html, 
         "<li><btsurl bugnr=\"$_\">$itp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @being_packaged_html, '<prep-today />' }
    elsif ( $age{$_} == 1 ) { push @being_packaged_html, '<prep-yesterday />' }
    else { push @being_packaged_html, "<prep-days \"$age{$_}\" />" };
    push @being_packaged_html, "</li>\n";
}
if ($#being_packaged_html == -1) { @being_packaged_html = ('<li><noitp /></li>') }

foreach (sort { $rfp{$a} cmp $rfp{$b} } keys %rfp) {
    push @requested_html, 
         "<li><btsurl bugnr=\"$_\">$rfp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @requested_html, '<req-today />' }
    elsif ( $age{$_} == 1 ) { push @requested_html, '<req-yesterday />' }
    else { push @requested_html, "<req-days \"$age{$_}\" />" };
    push @requested_html, "</li>\n";
}
if ($#requested_html == -1) { @requested_html = ('<li><norfp /></li>') }

foreach (sort { $rfh{$a} cmp $rfh{$b} } keys %rfh) {
    (my $pkg = $rfh{$_}) =~ s/^(.+?):\s+.*$/$1/;
    push @rfh_html, 
         "<li><btsurl bugnr=\"$_\">$rfh{$_}</btsurl>, ";
    push @rfh_html,
         " <pdolink \"$pkg\" />, ";
    if ( $age{$_} == 0 ) { push @rfh_html, '<req-today />' }
    elsif ( $age{$_} == 1 ) { push @rfh_html, '<req-yesterday />' }
    else { push @rfh_html, "<req-days \"$age{$_}\" />" };
    push @rfh_html, "</li>\n";
}
if ($#rfh_html == -1) { @rfh_html = ('<li><norfh /></li>') }

<protect pass="2">
print "\\#use wml::debian::wnpp\n";
print "<define-tag rfa_bypackage><ul>@rfa_bypackage_html</ul></define-tag>\n";
print "<define-tag rfa_bymaint><ul>@rfa_bymaint_html</ul></define-tag>\n";
print "<define-tag orphaned><ul>@orphaned_html</ul></define-tag>\n";
print "<define-tag being_adopted><ul>@being_adopted_html</ul></define-tag>\n";
print "<define-tag being_packaged><ul>@being_packaged_html</ul></define-tag>\n";
print "<define-tag requested><ul>@requested_html</ul></define-tag>\n";
print "<define-tag help_req><ul>@rfh_html</ul></define-tag>\n";
</protect>

</perl>
