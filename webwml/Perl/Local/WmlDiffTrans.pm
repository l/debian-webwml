# This is GPL'ed code, copyright 2000 Christian Couder <chcouder@club-internet.fr>.
 
##############################
# Documentation
#
# hashes structures :
#
# tag elem hash :  
#           'before' : string before the tag
#           'tag'    : tag string
#           'after'  : string after the tag
#           'num'    : the tag's line number 
#
# diff elem array :
#           'orig_line'  : line in the original text where the change begins
#           'diff_line'  : line in the diff file where the change begins
#           'orig_count' : line count of the change in the orig file
#           'diff_count' : line count of the change in the diff file
#           'before_tag' : index of the tag before the change
#           'after_tag'  : index of the tag after the change
#           'before'     : line in the translation file where the change begins
#           'after'      : line in the translation file where the change ends
#
##############################
# Known Bugs
#
# - Multiline tags (tags starting at a given line and ending at another line) 
#   are not found by the parsing.
#   This means that if a tag is multiline in the original file it must be
#   multiline in the translated file too. And of course if it's not multiline
#   in the original file it must not be multiline in the translated file.
#


use strict;

package Local::WmlDiffTrans;

##############################
# ignore_tag
# returns 1 if the tag must be ignored
##############################
sub ignore_tag {

  my $tag = shift(@_);

  # ignore comment tags like this <!-- ... -->
  if($tag =~ /^<\!\-\-.*\-\->$/) {
    return 1;
  }
  
  return "";
}

##############################
# ignore_most_tag
# return "" only if tag is one of <p>,</p>,<h1>,</h1>,<h2>,</h2>,<h3>,</h3>
##############################
sub ignore_most_tag {

  my $tag = shift(@_);

  # ignore <p> and </p> tags
  if($tag =~ /^<[\/]?(p|P)>$/) {
    # print "tag found : $tag\n";
    return "";
  }
  # ignore <hX> and </hX> tags with X = 1 or 2 or 3
  if($tag =~ /^<[\/]?(h|H)(1|2|3)>$/) {
    # print "tag found : $tag\n";
    return "";
  }
  
  return 1;
}

##############################
# next_tag
##############################
sub next_tag {

  my ($text, $full) = @_;

  my $elems;

  # print "text : $text \n"; 

  # Search next wml tags in the text
  if($text =~ /([^<]*)(<[^>]*>)(.*)/) {

    if($full ? not ignore_tag($2) : not ignore_most_tag($2)) {

      $elems->{'before'} = $1; # the string before the tag
      $elems->{'tag'}    = $2; # the tag

    }

    $elems->{'after'}  = $3; # the string after the tag

    # print "before : $1 ! \n";
    # print "tag : $2 ! \n";
    # print "after : $3 ! \n";

  }

  # Returns the elems hash
  return $elems;
}

##############################
# get_file_lines
##############################
sub get_file_lines {

  my $filename = shift(@_);

  open TAG_FILE, "<$filename" or die "Couldn't open $filename : $!";

  my @lines = <TAG_FILE>;

  close TAG_FILE;

  return \@lines;
}

##############################
# tags_from_lines
##############################
sub tags_from_lines {

  my ($file_lines, $full) = @_;

  my $line;
  my $elem;
  my $line_num;

  my @tags;

  for $line_num (0..$#$file_lines) {

    $line = $file_lines->[$line_num];

    # print "line : $line \n";

    # Don't search wml tags in comment lines (lines starting with #)
    if($line =~ /^[^\#]/) {

      # Search the next wml tags in the line
      while($elem = next_tag($line, $full)) {

	# Check if a tag has been found
	if($elem->{'tag'}) {

	  $elem->{'num'} = $line_num; # the tag line number

	  push(@tags, $elem);

	  # print "before : " . $elem->{'before'} . "\n";
	  # print "tag : " . $elem->{'tag'} . "\n";
	}

	$line = $elem->{'after'};

	# print "after : " . $elem->{'after'} . "\n";
      }

    }
  }

  return \@tags;
}

##############################
# tag_match
##############################
sub tag_match {

  my $orig_tag;
  my $trans_tag;

  ($orig_tag, $trans_tag) = @_;

  # convert tags to lower case
  $orig_tag =~ tr/A-Z/a-z/;
  $trans_tag =~ tr/A-Z/a-z/;

  # special case for tablerow tag
  if(($orig_tag =~ /^<tablerow/) && ($trans_tag =~ /^<tablerow/)) {

    # remove string like '"..."   ' in the tag 
    # because it can be translated
    $orig_tag =~ s/\"[^\"]*\"\s*//;
    $trans_tag =~ s/\"[^\"]*\"\s*//;

    # print "new tablerow orig tag : $orig_tag \n";
    # print "new tablerow trans tag : $trans_tag \n";
  }

  # special case for table tag
  if(($orig_tag =~ /^<table/) && ($trans_tag =~ /^<table/)) {
    
    # remove string like 'summary="..."  ' in the tag
    # because it can be translated
    $orig_tag =~ s/summary\=\"[^\"]*\"\s*//;
    $trans_tag =~ s/summary\=\"[^\"]*\"\s*//;    
  }

  return ($orig_tag eq $trans_tag);
}

##############################
# check_tags
##############################
sub check_tags {

  my ($orig_tags, $trans_tags) = @_;

  my $i;
  my $orig;
  my $trans;

  my $text = "";

  foreach $i (0..$#$orig_tags) {

    # print "i is $i \n";

    $orig = $orig_tags->[$i]; 
    $trans = $trans_tags->[$i]; 
    
    # print "orig before is " . $orig->{'before'} . " \n";
    # print "trans before is " . $trans->{'before'} . " \n";
    # print "orig tag is " . $orig->{'tag'} . " \n";
    # print "trans tag is " . $trans->{'tag'} . " \n";
    # print "orig after is " . $orig->{'after'} . " \n";
    # print "trans after is " . $trans->{'after'} . " \n";

    if(not tag_match($orig->{'tag'}, $trans->{'tag'})) {

      $text = "In the translation file, at line " . $trans->{'num'} . ", ";
      $text .= "there is the tag " . $trans->{'tag'} . ", but in the ";
      $text .= "original file at line " . $orig->{'num'} . " there is ";
      $text .= "the tag " . $orig->{'tag'} . " instead !\n";
      $text .= "Please correct this error !\n";
      
      return $text;
    }

  }

  return $text;
}

##############################
# read_check_tags
##############################
sub read_check_tags {

  my ($orig_lines, $trans_lines, $full) = @_;

  my $info_text ="";

  $info_text .= "Reading tags from original file.\n";
  my $orig_tags = tags_from_lines($orig_lines, $full);
  $info_text .= "$#$orig_tags tags found.\n";

  $info_text .= "Reading tags from translation file.\n";
  my $trans_tags = tags_from_lines($trans_lines, $full);
  $info_text .= "$#$trans_tags tags found.\n";

  $info_text .= "Checking if tags from the translation file ";
  $info_text .= "and the original file match.\n";
  my $check_tags_text = check_tags($orig_tags, $trans_tags);

  return ($check_tags_text, $orig_tags, $trans_tags, $info_text);
}

##############################
# add_diff_elem
##############################
sub add_diff_elem {
  
  my ($parts, $orig_line, $orig_count, $line_num) = @_;

  # print "add_diff_elem : last part : " . $#$parts . " \n";

  # Set the value of the number of lines that changed
  if($#$parts >= 0) {

    my $old_elem = $parts->[$#$parts];

    $old_elem->{'diff_count'} = ($line_num - 1) - $old_elem->{'diff_line'};

    # print "setting diff count : line num : $line_num ; diff count : ";
    # print $old_elem->{'diff_count'} . " diff line : ";
    # print $old_elem->{'diff_line'} . " \n";
  }

  # Create a new part element
  if($orig_line ne "") {
    
    my $elem;

    $elem->{'orig_line'} = $orig_line;
    $elem->{'diff_line'} = $line_num;
    $elem->{'orig_count'} = $orig_count;

    push(@$parts, $elem);
  }
}

##############################
# diff_parts_from_lines
##############################
sub diff_parts_from_lines {

  my $file_lines = shift(@_);

  my $line;
  my $line_num = 0;

  my @parts;

  for $line_num (0..$#$file_lines) {

    $line = $file_lines->[$line_num];

    # find diff line like @@ -12,7 +14,7 @@
    if($line =~ /^\@\@ \-(.*),(.*) \+(.*),(.*) \@\@$/) {

      # print "orig line : $1 \n";
      # print "orig count : $2 \n";

      add_diff_elem(\@parts, $1, $2, $line_num);

      # print "line num : $line_num \n";
      # print "last part : " . $#parts . "\n";
      # print "last orig_line : " . $parts[$#parts]{'orig_line'}. " \n";
      # print "last diff_line : " . $parts[$#parts]{'diff_line'}. " \n";
      # print "last orig_count : " . $parts[$#parts]{'orig_count'}. " \n";
      # if($#parts > 0) {
      #   print "part number : " . ($#parts - 1) . "\n";
      #   print "count : " . $parts[$#parts - 1]{'diff_count'}. " \n\n";
      # }
    }
  }
  
  add_diff_elem(\@parts, "", "", ($#$file_lines + 1));

  # print "line num : $line_num \n";
  # print "last part : " . $#parts . "\n";
  # print "last orig_line : " . $parts[$#parts]{'orig_line'}. " \n";
  # print "last diff_line : " . $parts[$#parts]{'diff_line'}. " \n";
  # print "last orig_count : " . $parts[$#parts]{'orig_count'}. " \n";
  # print "last diff_count : " . $parts[$#parts]{'diff_count'}. " \n";

  return \@parts;
}

##############################
# find_tag_number_before
##############################
sub find_tag_number_before {

  my $tags;
  my $line_num;

  ($tags, $line_num) = @_;

  my $i;

  for $i (0..$#$tags) {
    if($tags->[$i]{'num'} > $line_num) {
      return ($i - 1);
    }
  }

  return (-1); 
}

##############################
# find_tag_number_after
##############################
sub find_tag_number_after {

  my $tags;
  my $line_num;

  ($tags, $line_num) = @_;

  my $i;

  for $i (0..$#$tags) {
    if($tags->[$i]{'num'} >= $line_num) {
      return $i;
    }
  }

  return ($#$tags + 1); 
}

##############################
# find_tags_around
##############################
sub find_tags_around {

  my $orig_tags;
  my $diff_elem;

  ($orig_tags, $diff_elem) = @_;

  my $first_orig_line = $diff_elem->{'orig_line'};
  my $last_orig_line = $diff_elem->{'orig_line'} + $diff_elem->{'orig_count'};

  # print "original first line : $first_orig_line \n";
  # print "original last line : $last_orig_line \n";
  # print "line count : " . $diff_elem->{'orig_count'} . " \n";

  my $tag_before = find_tag_number_before($orig_tags, $first_orig_line);
  my $tag_after = find_tag_number_after($orig_tags, $last_orig_line);

  # print "tag before : $tag_before \n";
  # print "tag after : $tag_after \n";

  $diff_elem->{'before_tag'} = $tag_before;
  $diff_elem->{'after_tag'} = $tag_after;
}

##############################
# find_trans_lines
##############################
sub find_trans_lines {

  my $trans_tags;
  my $diff_elem;
  my $trans_line_count;

  ($trans_tags, $diff_elem, $trans_line_count) = @_;

  my $tag_before = $diff_elem->{'before_tag'};
  my $tag_after = $diff_elem->{'after_tag'};

  # print "tag before : $tag_before \n";
  # print "tag after : $tag_after \n";

  my $first_trans_tag_line = 1;
  my $last_trans_tag_line = $trans_line_count;

  if($tag_before > -1) {
    $first_trans_tag_line = $trans_tags->[$tag_before]{'num'};
  }
  if($tag_after <= $#$trans_tags) {
    $last_trans_tag_line = $trans_tags->[$tag_after]{'num'};
  }

  # print "before : $first_trans_tag_line \n";
  # print "after : $last_trans_tag_line \n\n";

  $diff_elem->{'before'} = $first_trans_tag_line;
  $diff_elem->{'after'} = $last_trans_tag_line;
}

##############################
# set_trans_lines
##############################
sub set_trans_lines {

  my $orig_tags;
  my $trans_tags;
  my $diff_elems;
  my $trans_line_count;

  ($orig_tags, $trans_tags, $diff_elems, $trans_line_count) = @_;

  my $elem;
  my $i;

  for $i (0..$#$diff_elems) {

    $elem = $diff_elems->[$i];

    find_tags_around($orig_tags, $elem);

    find_trans_lines($trans_tags, $elem, $trans_line_count);
  }
}

##############################
# display_few_diff_info
##############################
sub display_few_diff_info {

  my ($diff_parts) = @_;

  my $elem;

  my $text = "Diff information:\n\n";

  for $elem (@$diff_parts) {

    $text .= "   start line in original file : ";
    $text .= $elem->{'orig_line'} . " \n";
    $text .= "   end line in original file : ";
    $text .= $elem->{'orig_line'} + $elem->{'orig_count'} . " \n";
    
    $text .= "   start line in the translated file : ";
    $text .= $elem->{'before'} . " \n";
    $text .= "   end line in the translated file : ";
    $text .= $elem->{'after'} . " \n\n";
  }

  return $text;
}

##############################
# add_text_lines
##############################
sub get_text_lines {

  my ($lines, $start, $stop) = @_;

  my $text = "";

  my $line_num;

  # print " start : $start \n";
  # print " stop : $stop \n";

  for $line_num ($start..$stop) {
    $text .= $lines->[$line_num] || '';
  }

  return $text;
}

##############################
# display_full_diff_info
##############################
sub display_full_diff_info {

  my ($diff_parts, $diff_lines, $trans_lines) = @_;

  my $elem;

  my $text = "Diff information:\n\n";

  $text .= get_text_lines($diff_lines, 1, $diff_parts->[0]{'diff_line'} - 1) . "\n";

  for $elem (@$diff_parts) {

    my $diff_start = $elem->{'diff_line'} || 0;
    my $diff_count = $elem->{'diff_count'} || 0;
    my $diff_stop = $diff_start + $diff_count;
    
    $text .= get_text_lines($diff_lines, $diff_start, $diff_stop) . "\n"; 

    my $trans_start = $elem->{'before'} || 0;
    my $trans_stop = $elem->{'after'} || 0;
    my $trans_count = $trans_stop - $trans_start;

    $text .= "--> $trans_start,$trans_count <--\n";
    
    $text .= get_text_lines($trans_lines, $trans_start, $trans_stop) . "\n\n"; 
  }

  return $text;
}

##############################
# display_diff_info
##############################
sub display_diff_info {

  my ($diff_parts, $diff_lines, $trans_lines, $option) = @_;

  # print " option : $option \n";

  if($option eq 'few') {
    return display_few_diff_info($diff_parts);
  }
  if($option eq 'full') {
    return display_full_diff_info($diff_parts, $diff_lines, $trans_lines);
  }
}

##############################
# find_trans_parts
##############################
sub find_trans_parts {

  my ($orig_lines, $trans_lines, $diff_lines) = @_;

  my $text = "Try tag match with most tags.\n";

  # Try to read most tags and check them 
  my ($check_tags_text, $orig_tags, $trans_tags, $info_text) =
    read_check_tags($orig_lines, $trans_lines, 1);

  $text .= $info_text;

  if($check_tags_text) {
    $text .= $check_tags_text . "Try tag match again with fewer tags.\n";

    # try again with fewer tags
    ($check_tags_text, $orig_tags, $trans_tags, $info_text) =
      read_check_tags($orig_lines, $trans_lines, "");

    $text .= $info_text;

    if($check_tags_text) {
      return $text . $check_tags_text;
    }
  }

  $text .= "Ok, tags  match !\n";

  if(not $diff_lines) {
    return $info_text . "No diff file was specified.\n";
  }
  
  # Get the parts of the diff file
  my $diff_parts = diff_parts_from_lines($diff_lines);

  # Find the lines in the translated file where the changes must be translated
  set_trans_lines($orig_tags, $trans_tags, $diff_parts, $#$trans_lines);

  # Get display information
  $text .= display_diff_info($diff_parts, $diff_lines, $trans_lines, 'full');

  return $text;
}

return 1;
