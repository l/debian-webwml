#!/usr/bin/perl

#use strict;
use DBI;
use POSIX qw(strftime);
use vars qw($enable_email);


my $DBNAME="newmaint";
my $DBUSER="tbm";
$enable_email = 0;

sub send_email(@)
{
    my ($email, $body, $subject) = @_;

    open (FP, "| /usr/lib/sendmail -t") or die "Cannot open to sendmail $!";
    print FP "To: $email\n";
    print FP "CC: new-maintainer\@debian.org\n";
    print FP "From: Debian New Maintainer <new-maintainer\@debian.org>\r\n";
    print FP "Errors-To: new-maintainer\@debian.org\r\n";
    print FP "Content-Type: text/plain; charset=iso-8859-1\r\n";
    print FP "Subject: $subject\n\n";
    print FP $body;
    close FP;
}

sub print_warn_email(@)
{
    my ($fname, $email, $apply_date) = @_;

    my $body = "Dear $fname,\n\n" .
    "On $apply_date you applied to become a Debian maintainer on the Debian\n".
    "New Maintainer website at http://nm.debian.org/ After 3 weeks of applying,\n".
    "all applicants who have not yet been advocated receive this warning email.\n\n".
    "Advocacy is where a current Debian maintainer believes you have made\n".
    "enough preparations for applying to be a maintanier.  It is generally\n".
    "reasonably easy to be advocated.  For example, if you are wanting to\n".
    "build packages for the Debian Project then you would probably want to\n".
    "built a package and then get it checked and uploaded by a sponsor\n".
    "(see http://www.internatif.org/bortzmeyer/debian/sponsor/ for more\n".
    "information) then your sponsor could be your advocate.  If you are\n".
    "working on a porting or translation subproject, then someone there\n".
    "should be able to advocate you.\n\n".
    "If you have not found an advocate within six weeks from the date of\n".
    "your application, then your application will be automatically deleted\n".
    "from the New Maintainer database. You may re-apply any time when you\n".
    "believe that you are prepared for the new maintainer process.\n\n".
    "For more information about advocates, see\n".
    "http://www.debian.org/devel/join/nm-advocate\n\n".
    "  - New Maintainer Committee\n";
    send_email($email, $body, "Warning about Debian New Maintainer Application");
}

sub print_err_email(@)
{
    my ($fname, $email, $apply_date) = @_;

    my $body = "Dear $fname,\n\n" .
    "On $apply_date you applied to become a Debian maintainer on the Debian\n".
    "New Maintainer website at http://nm.debian.org/  After 6 weeks of\n".
    "applying, all applications who have not yet been advocated are deleted.\n\n".
    "Advocacy is where a current Debian maintainer believe you have made\n".
    "enough preparations for applying to a maintainer.  It is generally\n".
    "reasonably easy to be advocated.  For example if you are wanting to\n".
    "build packages for the Debian Project then you would probably want to\n".
    "build them and then get them uploaded by a sponsor (see\n".
    "http://www.internatif.org/bortzmeyer/debian/sponsor/ for more information)\n".
    "then your sponsor could be your advocate.  If you are working on a\n".
    "porting or translation subproject, then someone there should be able\n".
    "to advocate you.\n\n".
    "This email is to inform you that your application has now been deleted\n".
    "from the New Maintainer database. You may re-apply any time when you\n".
    "believe that you are prepared for the new maintainer process.\n\n".
    "For more information about advocates, see\n".
    "http://www.debian.org/devel/join/nm-advocate\n\n".
    "  - New Maintainer Committee\n";


    send_email($email, $body, "Your Debian New Maintainer Application has been removed");
}
sub print_stat(@)
{
    my ($dbh, $blurb, $sql) = @_;
    my @row;
    my $sth;

    $sth = $dbh->prepare($sql);
    $sth->execute();
    @row = $sth->fetchrow_array();

    print "$row[0] $blurb\n";

}

sub print_dateerror(@)
{
    my ($dbh, $blurb, $sql) = @_;
    my $sth;
    my ($label, $firstdate, $lastdate, $manager);

    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$label, \$firstdate, \$lastdate, \$manager);
    if ($sth->rows > 0) {
        print "$blurb\n";
        while($sth->fetch()) {
            print "  $label: $firstdate occurs after $lastdate ($manager)\n";
        }
    }

}

sub print_pairerror(@)
{
    my ($dbh, $blurb, $sql) = @_;
    my $sth;
    my ($label, $manager);

    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$label, \$manager);
    if ($sth->rows > 0) {
        print "$blurb\n";
        while($sth->fetch()) {
            print "  $label ($manager)\n";
        }
    }

}

sub print_errors($)
{
    my ($dbh) = @_;

    print "\n\nDatabase inconsistency errors\n";
    print "-----------------------------\n";
    print "  AM name is in brackets.\n";

    print_pairerror($dbh, "AM has confirmed but no AM confirm date",
        "SELECT email, manager from applicant WHERE am_confirm IS NOT NULL AND am_confirm_date IS NULL");
    print_pairerror($dbh, "AM confirm date filled in but AM confirm field blank",
        "SELECT applicant.email, applicant.manager from applicant, manager WHERE am_confirm_date IS NOT NULL AND am_confirm IS NULL");
    print_dateerror($dbh, "Apply dates set into the future",
        "SELECT email, apply_date, CURRENT_DATE, manager from applicant WHERE apply_date > CURRENT_DATE");
    print_dateerror($dbh, "Manager date set into the future",
        "SELECT email, manager_date, CURRENT_DATE, manager from applicant WHERE manager_date > CURRENT_DATE");
    print_dateerror($dbh, "Manager assigned date before apply date",
        "SELECT email, apply_date, manager_date, manager from applicant WHERE apply_date > manager_date");
    print_dateerror($dbh, "AM Confirm date set into the future",
        "SELECT email, am_confirm_date, CURRENT_DATE, manager from applicant WHERE am_confirm_date > CURRENT_DATE");
    print_dateerror($dbh, "AM confirm date occurs before AM assignment date",
        "SELECT email, manager_date, am_confirm_date, manager from applicant WHERE manager_date > am_confirm_date");
    print_dateerror($dbh, "AM recommendation to the DAM date set into the future",
        "SELECT email, decision, CURRENT_DATE, manager from applicant WHERE decision > CURRENT_DATE");

}
sub print_stats($)
{
    my ($dbh) = @_;

    print "Weekly Summary Statistics\n";
    print "=========================\n";
    print_stat($dbh, "more people applied to become a new maintainer", "SELECT COUNT(*) FROM applicant WHERE CURRENT_TIMESTAMP - apply_date < '7 days'");
    print_stat($dbh, "applicants became maintainers.", "SELECT COUNT(*) FROM applicant WHERE CURRENT_TIMESTAMP - newmaint < '7 days' AND da_approved = 't'");

    print "\n";

}



sub get_new_maintainers($)
{
    my ($dbh) = @_;
    my ($firstname, $surname, $email);
    my $sth;
    my $sql = "SELECT forename, surname, email FROM applicant WHERE da_approved = 't' AND CURRENT_TIMESTAMP - newmaint < '7 days' ORDER BY surname";


    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$firstname, \$surname, \$email);
    if ($sth->rows > 0) {
        print "New Maintainers\n";
        print "===============\n";
        print "The following applicants became new maintainers last week:\n";
        while($sth->fetch()) {
            print "$firstname $surname <$email>\n";
        }
    }
}

sub fd_checks($)
{
    my ($dbh) = @_;
    my ($email, $manager, $decision);
    my $sth;

    print "\n";
    print "Random checks\n";
    print "===============\n";

    my $sql = "SELECT email, manager FROM applicant WHERE id_ok AND pnp_ok AND tns_ok AND decision is NULL ORDER BY manager";

    print "The following applicants have completed all checks but are not\napproved by their AM:\n\n";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$email, \$manager);
    while($sth->fetch()) {
        print "  $email ($manager)\n";
    }

    print "\n";

    my $sql = "SELECT a.email, m.login FROM applicant a, manager m WHERE (a.approved = 'f' OR a.approved IS NULL) AND a.manager = m.login AND m.is_active = 'f' ORDER BY m.login";
    print "The following applicants are not AM approved but have an inactive AM:\n\n";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$email, \$manager);
    while($sth->fetch()) {
        print "  $email ($manager)\n";
    }

    print "\n";

    my $sql = "SELECT email, manager, decision FROM applicant WHERE
approved = 'f' and CURRENT_TIMESTAMP - decision > '6 months' ORDER BY decision";
    print "The following applicants have been on hold longer than 6 months:\n\n";

    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$email, \$manager, \$decision);
    while($sth->fetch()) {
        printf("  %-60.60s  %s\n", ("$email ($manager)"), $decision);
    }

}

sub get_warn_maintainers($)
{
    my ($dbh) = @_;
    my ($firstname, $surname, $email, $apply_date);
    my $sth;
    my $sql = "SELECT forename, surname, email, apply_date from applicant where CURRENT_TIMESTAMP - apply_date > '3 weeks' AND CURRENT_TIMESTAMP - apply_date < '4 weeks' and advocate_date IS NULL ORDER BY surname";

    print "\nApplicants with no advocate\n";
    print "===========================\n";

    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$firstname, \$surname, \$email, \$apply_date);
    if ($sth->rows > 0) {
        print "The following applicants have no advocate and have been waiting in the queue\n";
        print "for longer than 3 weeks but less than 6 weeks:\n";
        while($sth->fetch()) {
            print "$firstname $surname <$email>\n";
            if ($main::enable_email != 0) {
                print_warn_email($firstname, $email, $apply_date);
            }
        }
        print "Email will ";
        if ($main::enable_email == 0) { print "NOT "; }
        print "be sent to the applicants.\n";
    }
}

sub get_err_maintainers($)
{
    my ($dbh) = @_;
    my ($firstname, $surname, $email, $apply_date, $manager);
    my $sth;
    my $sql = "SELECT forename, surname, email, apply_date, manager FROM applicant WHERE CURRENT_TIMESTAMP - apply_date > '6 weeks' AND advocate_ok is NULL AND (advocate_date IS NULL OR CURRENT_TIMESTAMP - advocate_date > '1 week') ORDER BY surname";

    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->bind_columns(\$firstname, \$surname, \$email, \$apply_date, \$manager);
    if ($sth->rows > 0) {
        print "\nThe following applicants will be deleted as they have been waiting in the\n";
        print "the queue for longer than 6 weeks with no advocate:\n";
        while($sth->fetch()) {
            print "$firstname $surname <$email>\n";
            if ($main::enable_email != 0) {
                print_err_email($firstname, $email, $apply_date);
                my $sql1 = "DELETE FROM applicant WHERE email = '$email'";
                $sth1 = $dbh->prepare($sql1);
                $sth1->execute();
                # log this removal
                my $fullname = $firstname . " " . $surname;
                my $sql2 = "INSERT INTO log (who, manager, action, name, email) VALUES ('auto', '$manager', 'REMOVE', '$fullname', '$email')";
                $sth2 = $dbh->prepare($sql2);
                $sth2->execute();
            }
        }
        print "Email will ";
        if ($main::enable_email == 0) { print "NOT "; }
        print "be sent to the applicants.\n";
    }
}

my $dbh = DBI->connect("dbi:Pg:dbname=$DBNAME", $DBUSER, "", "");

print "          Weekly Report on Debian New Maintainers\n";
print "          =======================================\n";
print "\nFor week ending ", strftime("%d %h %Y", gmtime), ".\n\n";

if ($ARGV[0] eq '--email') { $enable_email = 1; }
#print $enable_email;
print_stats($dbh);
get_new_maintainers($dbh);
get_warn_maintainers($dbh);
get_err_maintainers($dbh);
fd_checks($dbh);
print_errors($dbh);
$dbh->disconnect();

