<?
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
  function print_flag($value,$trueflag,$falseflag)
  {
    if ($value == 't') {
      echo $trueflag;
    } else {
      echo $falseflag;
    }
  }
?>

