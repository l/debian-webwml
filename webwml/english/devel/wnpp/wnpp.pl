# originally written by Marcelo Magallon
# for <perl>
#use wml::std::tags

<perl>

my $host = `hostname -f`;
chomp($host);

use SOAP::Lite;
use Date::Parse;
use HTML::Entities;

# The maintainers flat database
my $maintainers_file = "$(ENGLISHDIR)/devel/wnpp/Maintainers";

my %maintainer;
open MAINTAINERS, '<', $maintainers_file or die "Can't find $maintainers_file file at $host: $!\n";
while (<MAINTAINERS>) {
    if (/^(\S+)\s+(.*)$/) {
	$maintainer{$1} = encode_entities($2, '<>&"');
    }
}
close MAINTAINERS;

my $soap = SOAP::Lite->uri('Debbugs/SOAP')->proxy('http://bugs.debian.org/cgi-bin/soap.cgi')
       or die "Couldn't make connection to SOAP insterface: $@";
my $bugs = $soap->get_bugs(package=>'wnpp')->result;
my $status = $soap->get_status($bugs)->result() or die;

my $curdate = time;

my ( %rfa, %orphaned, %rfabymaint, %rfp, %ita, %itp, %age,
     %rfh, %oth, %activity, %ita_activity, %itp_activity );
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
     $activity{$bugid} = ($curdate - $status->{$bugid}->{log_modified})/86400;
     $subject = encode_entities($subject, '<>&"');
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
	 $ita_activity{$bugid} = ($curdate - $status->{$bugid}->{log_modified});
     } elsif ($subject =~ m/^ITP:(?:\s*RFP:)?\s*(.*)/) {
         $itp{$bugid} = join(": ", split(/\s+-+\s+/, $1,2));
	 $itp_activity{$bugid} = ($curdate - $status->{$bugid}->{log_modified});
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
my (@rfh_html, @oth_html, %rfh_count);
my (@rfa_byage_html, @orphaned_byage_html, @being_adopted_byage_html, @being_adopted_byactivity_htm);
my (@being_packaged_byage_html, @being_packaged_byactivity_html, @requested_html, @rfh_byage_html);
my ($rfa_number, $orphaned_number, $adopted_number, $packaged_number, $requested_number, $help_number );

foreach my $bug (sort { $rfa{$a} cmp $rfa{$b} } keys %rfa) {
    push @rfa_bypackage_html, "\n<li><btsurl bugnr=\"$bug\">$rfa{$bug}</btsurl>";
    (my $pkg = $rfa{$bug}) =~ s/^(.+?):\s+.*$/$1/;
    push @rfa_bypackage_html, " <pdolink \"$pkg\" />, ";
    if ( $age{$bug} == 0 ) { push @rfa_bypackage_html, '<adoption-today />' }
    elsif ( $age{$bug} == 1 ) { push @rfa_bypackage_html, '<adoption-yesterday />' }
    else { push @rfa_bypackage_html, "<adoption-days \"$age{$bug}\" />" }
    push @rfa_bypackage_html, "</li>\n";
}
if ($#rfa_bypackage_html == -1) { @rfa_bypackage_html = ('<li><norfa /></li>') }
else { $rfa_number = scalar(keys %rfa) };

foreach my $maint (sort keys %rfabymaint) {
    push @rfa_bymaint_html, "<li>$maint";
    push @rfa_bymaint_html, "<ul>";
    foreach my $bug (sort { $rfa{$a} cmp $rfa{$b} } @{$rfabymaint{$maint}}) {
        push @rfa_bymaint_html, "<li><btsurl bugnr=\"$bug\">$rfa{$bug}</btsurl>";
        (my $pkg = $rfa{$bug}) =~ s/^(.+?):\s+.*$/$1/;
        push @rfa_bymaint_html, " <pdolink \"$pkg\" />, ";
	if ( $age{$bug} == 0 ) { push @rfa_bymaint_html, '<adoption-today />' }
        elsif ( $age{$bug} == 1 ) { push @rfa_bymaint_html, '<adoption-yesterday />' }
        else { push @rfa_bymaint_html, "<adoption-days \"$age{$bug}\" />" }
	push @rfa_bymaint_html, "</li>\n";
    }
    push @rfa_bymaint_html, "</ul>";
    push @rfa_bymaint_html, "</li>\n";
}
if ($#rfa_bymaint_html == -1) { @rfa_bymaint_html = ('<li><norfa /></li>') }

foreach (sort {$a <=> $b} keys %rfa) {
    push @rfa_byage_html, "\n<li><btsurl bugnr=\"$_\">$rfa{$_}</btsurl>";
    (my $pkg = $rfa{$_}) =~ s/^(.+?):\s+.*$/$1/;
    push @rfa_byage_html, " <pdolink \"$pkg\" />, ";
    if ( $age{$_} == 0 ) { push @rfa_byage_html, '<adoption-today />' }
    elsif ( $age{$_} == 1 ) { push @rfa_byage_html, '<adoption-yesterday />' }
    else { push @rfa_byage_html, "<adoption-days \"$age{$_}\" />" }
    push @rfa_byage_html, "</li>\n";
}
if ($#rfa_byage_html == -1) { @rfa_byage_html = ('<li><norfa /></li>') }


foreach my $bug (sort { $orphaned{$a} cmp $orphaned{$b} } keys %orphaned) {
    push @orphaned_html, "<li><btsurl bugnr=\"$bug\">$orphaned{$bug}</btsurl>";
    (my $pkg = $orphaned{$bug}) =~ s/^(.+?):\s+.*$/$1/;
    push @orphaned_html, " <pdolink \"$pkg\" />, ";
    if ( $age{$bug} == 0 ) { push @orphaned_html, '<adoption-today />' }
    elsif ( $age{$bug} == 1 ) { push @orphaned_html, '<adoption-yesterday />' }
    else { push @orphaned_html, "<adoption-days \"$age{$bug}\" />" }
    push @orphaned_html, "</li>\n";
}
if ($#orphaned_html == -1) { @orphaned_html = ('<li><noo /></li>') }
else { $orphaned_number = scalar(keys %orphaned) };

foreach (sort {$a <=> $b} keys %orphaned) {
    push @orphaned_byage_html, "<li><btsurl bugnr=\"$_\">$orphaned{$_}</btsurl>";
    (my $pkg = $orphaned{$_}) =~ s/^(.+?):\s+.*$/$1/;
    push @orphaned_byage_html, " <pdolink \"$pkg\" />";
    if ( $age{$_} == 0 ) { push @orphaned_byage_html, '<adoption-today />' }
    elsif ( $age{$_} == 1 ) { push @orphaned_byage_html, '<adoption-yesterday />' }
    else { push @orphaned_byage_html, "<adoption-days \"$age{$_}\" />" }
    push @orphaned_byage_html, "</li>\n";
}
if ($#orphaned_byage_html == -1) { @orphaned_byage_html = ('<li><noo /></li>') }


foreach my $bug (sort { $ita{$a} cmp $ita{$b} } keys %ita) {
    (my $pkg = $ita{$bug}) =~ s/^(.+?):\s+.*$/$1/;
    push @being_adopted_html, 
         "<li><btsurl bugnr=\"$bug\">$ita{$bug}</btsurl>";
    push @being_adopted_html,
         " <pdolink \"$pkg\" />, ";
    if ( $age{$bug} == 0 ) { push @being_adopted_html, '<adoption-today />' }
    elsif ( $age{$bug} == 1 ) { push @being_adopted_html, '<adoption-yesterday />' }
    elsif ( $age{$bug} == $activity{$bug} ) { push @being_adopted_html, "<adoption-days \"$age{$bug}\" />" }
    elsif ( $activity{$bug} == 0 ) { push @being_adopted_html, "<adoption-days-today \"$age{$bug}\" />" }
    elsif ( $activity{$bug} == 1 ) { push @being_adopted_html, "<adoption-days-yesterday \"$age{$bug}\" />" }
    else { push @being_adopted_html, "<adoption-days-days \"$age{$bug}\" \"$activity{$bug}\" />" };
    push @being_adopted_html, "</li>\n";
}
if ($#being_adopted_html == -1) { @being_adopted_html = ('<li><noita /></li>') }
else { $adopted_number = scalar(keys %ita) };

foreach (sort {$a <=> $b} keys %ita) {
    (my $pkg = $ita{$_}) =~ s/^(.+?):\s+.*$/$1/;
    push @being_adopted_byage_html,
         "<li><btsurl bugnr=\"$_\">$ita{$_}</btsurl>";
    push @being_adopted_byage_html,
         " <pdolink \"$pkg\" />, ";
    if ( $age{$_} == 0 ) { push @being_adopted_byage_html, '<adoption-today />' }
    elsif ( $age{$_} == 1 ) { push @being_adopted_byage_html, '<adoption-yesterday />' }
    elsif ( $age{$_} == $activity{$_} ) { push @being_byage_adopted_html, "<adoption-days \"$age{$_}\" />" }
    elsif ( $activity{$_} == 0 ) { push @being_adopted_byage_html, "<adoption-days-today \"$age{$_}\" />" }
    elsif ( $activity{$_} == 1 ) { push @being_adopted_byage_html, "<adoption-days-yesterday \"$age{$_}\" />" }
    else { push @being_adopted_byage_html, "<adoption-days-days \"$age{$_}\" \"$activity{$_}\" />" };
    push @being_adopted_byage_html, "</li>\n";
}
if ($#being_adopted_byage_html == -1) { @being_adopted_byage_html = ('<li><noita /></li>') }

foreach (reverse sort { $ita_activity{$a} <=> $ita_activity{$b} } keys %ita_activity) {
    (my $pkg = $ita{$_}) =~ s/^(.+?):\s+.*$/$1/;
    push @being_adopted_byactivity_html,
         "<li><btsurl bugnr=\"$_\">$ita{$_}</btsurl>";
    push @being_adopted_byactivity_html,
         " <pdolink \"$pkg\" />, ";
    if ( $age{$_} == 0 ) { push @being_adopted_byactivity_html, '<adoption-today />' }
    elsif ( $age{$_} == 1 ) { push @being_adopted_byactivity_html, '<adoption-yesterday />' }
    elsif ( $age{$_} == $activity{$_} ) { push @being_adopted_byactivity_html, "<adoption-days \"$age{$_}\" />" }
    elsif ( $activity{$_} == 0 ) { push @being_adopted_byactivity_html, "<adoption-days-today \"$age{$_}\" />" }
    elsif ( $activity{$_} == 1 ) { push @being_adopted_byactivity_html, "<adoption-days-yesterday \"$age{$_}\" />" }
    else { push @being_adopted_byactivity_html, "<adoption-days-days \"$age{$_}\" \"$activity{$_}\" />" };
    push @being_adopted_byactivity_html, "</li>\n";
}
if ($#being_adopted_byactivity_html == -1) { @being_adopted_byactivity_html = ('<li><noita /></li>') }


foreach (sort { $itp{$a} cmp $itp{$b} } keys %itp) {
    push @being_packaged_html, 
         "<li><btsurl bugnr=\"$_\">$itp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @being_packaged_html, '<prep-today />' }
    elsif ( $age{$_} == 1 ) { push @being_packaged_html, '<prep-yesterday />' }
    elsif ( $age{$_} == $activity{$_} ) { push @being_packaged_html, "<prep-days \"$age{$_}\" />" }
    elsif ( $activity{$_} == 0 ) { push @being_packaged_html, "<prep-days-today \"$age{$_}\" />" }
    elsif ( $activity{$_} == 1 ) { push @being_packaged_html, "<prep-days-yesterday \"$age{$_}\" />" }
    else { push @being_packaged_html, "<prep-days-days \"$age{$_}\" \"$activity{$_}\" />" };
    push @being_packaged_html, "</li>\n";
}
if ($#being_packaged_html == -1) { @being_packaged_html = ('<li><noitp /></li>') }
else { $packaged_number = scalar(keys %itp) };

foreach (sort {$a <=> $b} keys %itp) {
    push @being_packaged_byage_html,
         "<li><btsurl bugnr=\"$_\">$itp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @being_packaged_byage_html, '<prep-today />' }
    elsif ( $age{$_} == 1 ) { push @being_packaged_byage_html, '<prep-yesterday />' }
    elsif ( $age{$_} == $activity{$_} ) { push @being_packaged_byage_html, "<prep-days \"$age{$_}\" />" }
    elsif ( $activity{$_} == 0 ) { push @being_packaged_byage_html, "<prep-days-today \"$age{$_}\" />" }
    elsif ( $activity{$_} == 1 ) { push @being_packaged_byage_html, "<prep-days-yesterday \"$age{$_}\" />" }
    else { push @being_packaged_byage_html, "<prep-days-days \"$age{$_}\" \"$activity{$_}\" />" };
    push @being_packaged_byage_html, "</li>\n";
}
if ($#being_packaged_byage_html == -1) { @being_packaged_byage_html = ('<li><noitp /></li>') }

foreach (reverse sort { $itp_activity{$a} <=> $itp_activity{$b} } keys %itp_activity) {
    push @being_packaged_byactivity_html,
         "<li><btsurl bugnr=\"$_\">$itp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @being_packaged_byactivity_html, '<prep-today />' }
    elsif ( $age{$_} == 1 ) { push @being_packaged_byactivity_html, '<prep-yesterday />' }
    elsif ( $age{$_} == $activity{$_} ) { push @being_packaged_byactivity_html, "<prep-days \"$age{$_}\" />" }
    elsif ( $activity{$_} == 0 ) { push @being_packaged_byactivity_html, "<prep-days-today \"$age{$_}\" />" }
    elsif ( $activity{$_} == 1 ) { push @being_packaged_byactivity_html, "<prep-days-yesterday \"$age{$_}\" />" }
    else { push @being_packaged_byactivity_html, "<prep-days-days \"$age{$_}\" \"$activity{$_}\" />" };
    push @being_packaged_byactivity_html, "</li>\n";
}
if ($#being_packaged_byactivity_html == -1) { @being_packaged_byactivity_html = ('<li><noitp /></li>') }


foreach (sort { $rfp{$a} cmp $rfp{$b} } keys %rfp) {
    push @requested_html, 
         "<li><btsurl bugnr=\"$_\">$rfp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @requested_html, '<req-today />' }
    elsif ( $age{$_} == 1 ) { push @requested_html, '<req-yesterday />' }
    else { push @requested_html, "<req-days \"$age{$_}\" />" };
    push @requested_html, "</li>\n";
}
if ($#requested_html == -1) { @requested_html = ('<li><norfp /></li>') }
else { $requested_number = scalar(keys %rfp) };

foreach (sort {$a <=> $b} keys %rfp) {
    push @requested_byage_html,
         "<li><btsurl bugnr=\"$_\">$rfp{$_}</btsurl>, ";
    if ( $age{$_} == 0 ) { push @requested_byage_html, '<req-today />' }
    elsif ( $age{$_} == 1 ) { push @requested_byage_html, '<req-yesterday />' }
    else { push @requested_byage_html, "<req-days \"$age{$_}\" />" };
    push @requested_byage_html, "</li>\n";
}
if ($#requested_byage_html == -1) { @requested_byage_html = ('<li><norfp /></li>') }


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
    # There might be more than one RFH for one package, we want to
    # display them all, but don't want to count the same package twice.
    $rfh_count{$pkg} = $_;
}
if ($#rfh_html == -1) { @rfh_html = ('<li><norfh /></li>') }
else { $help_number = scalar(keys %rfh_count) }

foreach (sort {$a <=> $b} keys %rfh) {
    (my $pkg = $rfh{$_}) =~ s/^(.+?):\s+.*$/$1/;
    push @rfh_byage_html, 
         "<li><btsurl bugnr=\"$_\">$rfh{$_}</btsurl>, ";
    push @rfh_byage_html,
         " <pdolink \"$pkg\" />, ";
    if ( $age{$_} == 0 ) { push @rfh_byage_html, '<req-today />' }
    elsif ( $age{$_} == 1 ) { push @rfh_byage_html, '<req-yesterday />' }
    else { push @rfh_byage_html, "<req-days \"$age{$_}\" />" };
    push @rfh_byage_html, "</li>\n";
}
if ($#rfh_byage_html == -1) { @rfh_byage_html = ('<li><norfh /></li>') }


<protect pass="2">
print "\\#use wml::debian::wnpp\n";
print "<define-tag rfa_number>$rfa_number</define-tag>\n";
print "<define-tag orphaned_number>$orphaned_number</define-tag>\n";
print "<define-tag adopted_number>$adopted_number</define-tag>\n";
print "<define-tag packaged_number>$packaged_number</define-tag>\n";
print "<define-tag requested_number>$requested_number</define-tag>\n";
print "<define-tag help_number>$help_number</define-tag>\n";
print "<define-tag rfa_bypackage><ul>@rfa_bypackage_html</ul></define-tag>\n";
print "<define-tag rfa_bymaint><ul>@rfa_bymaint_html</ul></define-tag>\n";
print "<define-tag rfa_byage><ul>@rfa_byage_html</ul></define-tag>\n";
print "<define-tag orphaned><ul>@orphaned_html</ul></define-tag>\n";
print "<define-tag orphaned_byage><ul>@orphaned_byage_html</ul></define-tag>\n";
print "<define-tag being_adopted><ul>@being_adopted_html</ul></define-tag>\n";
print "<define-tag being_adopted_byage><ul>@being_adopted_byage_html</ul></define-tag>\n";
print "<define-tag being_adopted_byactivity><ul>@being_adopted_byactivity_html</ul></define-tag>\n";
print "<define-tag being_packaged><ul>@being_packaged_html</ul></define-tag>\n";
print "<define-tag being_packaged_byage><ul>@being_packaged_byage_html</ul></define-tag>\n";
print "<define-tag being_packaged_byactivity><ul>@being_packaged_byactivity_html</ul></define-tag>\n";
print "<define-tag requested><ul>@requested_html</ul></define-tag>\n";
print "<define-tag requested_byage><ul>@requested_byage_html</ul></define-tag>\n";
print "<define-tag help_req><ul>@rfh_html</ul></define-tag>\n";
print "<define-tag help_req_byage><ul>@rfh_byage_html</ul></define-tag>\n";
</protect>

</perl>
