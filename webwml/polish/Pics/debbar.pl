#!/usr/bin/perl -w
#
# Perl scripts to generate the Debian toolbar icons
# This needs gimp 1.1 and gimp1.1-nonfree to work!!
# By Craig Small <csmall@debian.org>

use Gimp qw( :auto ); 
use Gimp::Fu; 
   
sub debian_button {
	my ($words, $fontcolor, $bgcolor) = @_;
	my ($image,$layer,$text,$width);
	my $height = 18;

	gimp_palette_set_foreground($fontcolor);
	gimp_palette_set_background($bgcolor);


	$image = gimp_image_new(80, $height, RGB);
	$layer = gimp_layer_new($image, 80, $height, RGBA_IMAGE, "Button", 100, NORMAL_MODE);
	$text = gimp_text($image, $layer, 9, 3, $words, 0, 0, "14", PIXELS, "*", "Lucida", "bold", "r", "*", "*", "*", "2");
	

	$width = gimp_drawable_width($text);

	# Resize everything
	gimp_image_resize($image, ($width + $height), $height, 0, 0);
	gimp_layer_resize($layer, ($width + $height), $height, 0, 0);

	gimp_image_add_layer($image, $layer, 0);


	gimp_selection_all($image);
	gimp_edit_clear($layer);

        gimp_rect_select($image, 9, 0, $width, $height, REPLACE, 0, 0);
	gimp_ellipse_select($image, (9-($height/2)), 0, $height, $height, ADD, 0, 0, 0);
	gimp_ellipse_select($image, ((9+$width) - ($height/2)), 0, $height, $height, ADD, 0,0,0);
	gimp_bucket_fill($layer, BG_BUCKET_FILL, NORMAL_MODE, 100, 0, 0, 5, 5);
	gimp_selection_none($image);

	gimp_floating_sel_anchor($text);

	gimp_convert_indexed($image, 0, 0, 8, 0, 0, "");

	return $image;
}
 
   
register 
      "debian_button",                 # fill in name 
      "Create Debian Toolbar button",  # a small description 
      "A tutorial script",       # a help text 
      "Craig Small",            # Your name 
      "(c) SPI Inc",        # Your copyright 
      "1998-05-18",              # Date 
      "<Toolbox>/Xtns/Perl-Fu/Debian/Toolbar",   # menu path 
      "*",                       # Image types 
      [ 
       [PF_STRING,   "words", "words to put in button", "Home"], 
       [PF_COLOR, "fontcolor", "Font color", [255,255,255]] ,
       [PF_COLOR, "bgcolor", "Background color", [0,0,132]] 
      ], 
      \&debian_button; 
   
  exit main()
