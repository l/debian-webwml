<?
  include("gpgconfig.inc");
  include("common.inc");
?>
#use wml::gpgpage title="GPG Signing Coordination - Get Password"
<?

    if ($email) {
        if (($db = open_db())) {
            $sql = "SELECT passwd FROM people WHERE email = '$email'";

            if (! ($result = pg_exec($db, $sql))) {
                echo "Problem with query", pg_ErrorMessage($db), "<BR>";
                return FALSE;
            }

            if (pg_NumRows($result) == 1) {
                # FIXME: email, dont print
                echo "Password is: ", $row["$passwd"];
            } else {
                echo "Cannot find that e-mail in the database.";
            }
        }
    } else {
        No e-mail given.
    }

?>

