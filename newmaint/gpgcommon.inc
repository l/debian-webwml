<?

    function print_place($begin, $finish, $city, $country) {
        if ($city) {
            echo "<LI>$city, $country: ";
        } else {
            echo "<LI>$country: ";
        }
        if (! $begin && ! $finish) {
            echo "always";
        } else if ($begin && ! $finish) {
            echo "starting on $begin";
        } else if (! $begin && $finish) {
            echo "until $finish";
        } else {
            echo "$begin to $finish";
        }
    }

    function print_all_places($id, $modify) {

        if (!($db = open_db())) {
            echo "Cannot open SQL database";
            return FALSE;
        }

        $sql = "SELECT id, begin, finish, city, country FROM places WHERE who = '$id' ORDER BY begin, finish";
        if (! ($query = pg_exec($db, $sql))) {
            echo "Problem with query", pg_ErrorMessage($db), "<BR>";
            return FALSE;
        }
        echo "<UL>";
        $rows = pg_NumRows($query);
        for ($i = 0; $i < $rows; $i++) {
            $row = pg_Fetch_Array($query, $i);
            print_place($row["begin"], $row["finish"], $row["city"], $row["country"]);
            if ($modify) {
                echo " <A HREF = \"gpgplace.php?id=", $row["id"], "\">[Modify]</A>";
                echo " <A HREF = \"gpgplace.php?remove=1&id=", $row["id"], "\">[Remove]</A>";
            }
        }
        echo "</UL>";
    }


    function print_people($db, $sql) {
        if (! ($query = pg_exec($db, $sql))) {
            echo "Problem with query", pg_ErrorMessage($db), "<BR>";
            return FALSE;
        }
        $rows = pg_NumRows($query);
        for ($i = 0; $i < $rows; $i++) {
            $row = pg_Fetch_Array($query, $i);
            echo "<H2>";
            echo $row["forename"], " ", $row["surname"];
            echo " &lt;", $row["email"], "&gt;";
            echo "</H2>\n";

            print_all_places($row["id"], FALSE);

        }
    }

?>

