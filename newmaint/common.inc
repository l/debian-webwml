<?
// Copyright (C) 2001  Craig Small <csmall@debian.org>
// Copyright (C) 2001, 2002, 2003, 2004, 2005  Martin Michlmayr <tbm@cyrius.com>
// This file may be distributed under the GPL v2 or higher.

  #Common functions used everywhere
  if (!function_exists(pg_connect)) {
    dl("pgsql.so");
  }

  # Opens the Database, returns the database handle if ok and FALSE if there
  # was a problem.
  function open_db()
  {
    global $DBName, $DBUser, $DBPasswd;

    $connstr = "dbname=$DBName user=$DBUser";
    if ($DBPasswd != "") {
      $connstr .= " password=$DBPasswd";
    }
    if (! ($db = pg_Connect($connstr))) {
      echo "<STRONG>Problem with connecting to database: ", pg_ErrorMessage($db), "</STRONG><BR>";
      return FALSE;
    }
    return $db;
  }

  function find_applicant($db, $email) {
    global $row, $query;
    if (! $email) {
        echo "Please choose an applicant from <A href=\"nmlist.php\">this</A> list.<BR>";
	return FALSE;
    }
    # start looking at stuff
    $sql = "SELECT * from applicant WHERE email='$email'";
    if (! ($query = pg_exec($db, $sql))) {
      echo "Problem with query", pg_ErrorMessage($db), "<BR>";
      return FALSE;
    }
    if ( pg_numRows($query) < 1) {
      echo "Could not find $email in the database.  You can find a full list of applicants <A href=\"nmlist.php\">here</A>.<BR>";
      return FALSE;
    }
    $row = pg_Fetch_Array($query, 0);
    return TRUE;
  }

  function logger($db, $who, $manager, $action, $name, $email) {
      $sql = "INSERT INTO log (who, manager, action, name, email) VALUES ('$who', '$manager', '$action', '$name', '$email')";
      if (! ($result = pg_exec($db, $sql))) {
          echo "Problem with interrogating database: ", pg_ErrorMessage($db), "<BR>\n";
          return FALSE;
      }
      if (($tuples = pg_CmdTuples($result)) != 1) {
          echo "Only one row should be effected but $tuples rows were<BR>\n";
          return FALSE;
      }
      return TRUE;
  }

  function print_bool($title, $name, $value, $editable)
  {
    echo "<TR><TD width=\"200\"><B>$title</B> </TD><TD width=\"200\">";
    if ($editable) {
	echo "<INPUT type=\"radio\" name=\"$name\" value=\"t\""; 
	if ($value == 't') { echo " checked"; }
	echo ">Yes &nbsp;\n<INPUT type=\"radio\" name=\"", $name,
	     "\" value=\"f\"";
	if ($value == 'f') { echo " checked"; }
	echo "> No &nbsp;\n<INPUT type=\"radio\" name=\"", $name,
	     "\" value=\"n\"";
	if ($value != 'f' && $value != 't') { echo " checked"; }
	echo "> Not checked\n";
    } else {
      if ($value == 't') { echo "[ Yes ]"; }
      if ($value == 'f') { echo "[ No ]"; }
      if ($value == 'n') { echo "[ Not Checked ]"; }
    }
    echo "</TD></TR>\n";
  }
  function print_text($title, $name, $value, $editable)
  {
    echo "<TR><TD width=\"200\"><B>$title</B> </TD><TD width=\"400\"> ";
    if ($editable) {
      echo "<INPUT type=\"text\" name=\"$name\" value=\"$value\">";
    } else {
      echo "[ $value ]";
    }
    echo "</TD></TR>\n";
  }
  function print_text_size($title, $name, $value, $editable, $size)
  {
    echo "<TR><TD width=\"200\"><B>$title</B> </TD><TD width=\"400\"> ";
    if ($editable) {
      echo "<INPUT type=\"text\" name=\"$name\" value=\"$value\" size=$size>";
    } else {
      echo "[ $value ]";
    }
    echo "</TD></TR>\n";
  }
  function print_checkbox($title, $name, $value, $editable)
  {
    echo "<TR><TD width=\"200\"><B>$title</B> </TD><TD width=\"400\"> ";
    if ($editable) {
      echo "<INPUT type=\"checkbox\" name=\"$name\" value=\"t\" ";
      if ($value == 't') { echo "CHECKED"; }
      echo ">";
    } else {
      if ($value == 't') {
        echo "[ Yes ]";
      } else {
        echo "[ No ]";
      }
    }
    echo "</TD></TR>\n";
  }
  function print_passwd($title, $name)
  {
    echo "<TR><TD width=\"200\"><B>$title</B> </TD><TD width=\"400\"> <INPUT type=\"password\" name=\"$name\"></TD></TR>\n";
  }
  # Operates on bools
  function print_flag($value,$trueflag,$falseflag)
  {
    if ($value == 't') {
      echo $trueflag;
    } else {
      echo $falseflag;
    }
  }
  # Operates on texts
  function print_flag_text($value,$trueflag,$falseflag)
  {
    if ($value != '') {
      echo $trueflag;
    } else {
      echo $falseflag;
    }
  }

  # Those two functions are currently needed in the gpg signing coordination part
  # I took the liberty to add them here as they might be useful for other parts of
  # the page too.
  function passwd_crypt($passwd)
  {
      static $initialized = 0;

      if (! $initialized ) {
          srand((double)microtime()*1000000);
          $initialized=1;
      }
      $salt = '$1$';
      $itoa64="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      # FIXME: What kind of characters are allowed in salts? Is there a better way
      #        to create one?
      #        And no, php's crypt() funktion does not work without salt. At least
      #        it didn't for me.

      $random=rand(); $salt .= substr($itoa64,$random % 64,1).substr($itoa64,($random/64) % 64,1);
      $random=rand(); $salt .= substr($itoa64,$random % 64,1).substr($itoa64,($random/64) % 64,1);
      $random=rand(); $salt .= substr($itoa64,$random % 64,1).substr($itoa64,($random/64) % 64,1);
      $random=rand(); $salt .= substr($itoa64,$random % 64,1).substr($itoa64,($random/64) % 64,1);
      return crypt($passwd, $salt);
  }
  function passwd_verify($stored_passwd, $guess)
  {
      $salt = substr($stored_passwd, 0, 12);
      $crypted_passwd = crypt($guess, $salt);
      return ($stored_passwd == $crypted_passwd);
  }

  function print_applicants($db, $sql, $limit = 0, $show_am = 0, $show_date = 0, $am = 0) {
  if (! ($query = pg_exec($db, $sql))) {
    echo "Problem with query", pg_ErrorMessage($db), "<BR>";
    return FALSE;
  }
  $rows = pg_NumRows($query);
  if ($limit && $rows > $limit) {
      $rows = $limit;
  }
  if ($rows) {
      echo "<TABLE border=\"0\" summary=\"\">\n";
      for ($i = 0 ; $i < $rows ; $i++) {
        $row = pg_Fetch_Array($query, $i);
        echo "<TR>";
        if ($show_date) {
            echo "<TD>", $row["apply_date"], "</TD>";
        }
        print_flag($row["advocate_ok"],"<TD><IMG src=\"/images/shake.png\" alt=\"V\"></TD>","<TD> </TD>");
        print_flag($row["id_ok"],"<TD><IMG src=\"/images/mag.png\" alt=\"I\"></TD>","<TD> </TD>");
        print_flag($row["pnp_ok"],"<TD><IMG src=\"/images/dfsg.png\" alt=\"P\"></TD>","<TD> </TD>");
        print_flag($row["tns_ok"],"<TD><IMG src=\"/images/hammer.png\" alt=\"T\"></TD>","<TD> </TD>");
        print_flag($row["approved"],"<TD><IMG src=\"/images/thumb.png\" alt=\"A\"></TD>","<TD> </TD>");
        print_flag_text($row["newmaint"],"<TD><IMG src=\"/images/new.png\" alt=\"N\"></TD>","<TD> </TD>");
        if ($row["approved"] == "f" || $row["da_approved"] == "f") {
            echo "<TD><IMG src=\"/images/hold.png\" alt=\"H\"></TD>";
        } else {
            echo "<TD> </TD>";
        }
        echo "<TD>";
        if ($am) {
            echo "<A href=\"amstatus.php?"; ?><?=SID?><?;
            echo "&user=";
        } else {
            echo "<A href=\"nmstatus.php?email=";
        }
        echo urlencode($row["email"]), "\">",
          $row["forename"], " ", $row["surname"], " &lt;",
          $row["email"], "&gt;</A></TD>\n";
        if ($show_am) {
            echo "<TD>", $row["manager"], "</TD>";
        }
        echo "</TR>\n";
      }
      echo "</TABLE>\n";
  } else {
      echo "none\n";
  }
  return TRUE;
  }

# Check if there are any free Application Managers.  (FIXME: has code
# duplication with ammain.wml's print_free_managers()
function free_managers($db) {
    $sql = "select a.manager, (max(m.max_applicants) - count(a.email)) as freeslots from applicant a, manager m where approved is null and m.login = a.manager   group by a.manager HAVING max(m.max_applicants) > count(a.email)";
    if (! ($query = pg_exec($db, $sql))) {
        echo "Problem with query", pg_ErrorMessage($db), "<BR>";
        echo "SQL was: $sql<BR>";
        return;
    }
    $rows = pg_NumRows($query);
    if ($rows) {
        return TRUE;
    } else {
        return FALSE;
    }
}

?>

