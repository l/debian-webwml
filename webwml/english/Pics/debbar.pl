#!/usr/bin/perl -w
#
# Perl script to generate the Debian toolbar icons
# By Craig Small <csmall@debian.org>, modified by various people
#
# See webwml/english/Pics/README for more information.

use strict;
use Gimp qw( :auto ); 
use Gimp::Fu; 
   
sub debian_button {
	my ($words, $antialias, $fontface, $fontsize, $fonttype, $fontcolor, $bgcolor, $fontregistry, $fontencoding) = @_;
	my ($image,$layer,$text,$width);
	my $height = 18;
	my $top = 3;
	if ($words =~ s/@(.*)//) {
		my $pos = $1;
		if ($pos =~ m/y=(\d+)/) {
			$top = $1;
		}
	}

	gimp_palette_set_foreground($fontcolor);
	gimp_palette_set_background($bgcolor);


	$image = gimp_image_new(80, $height, RGB);
	$layer = gimp_layer_new($image, 80, $height, RGBA_IMAGE, "Button", 100, NORMAL_MODE);
	$text = gimp_text($image, $layer, 9, $top, $words, 0, $antialias, $fontsize, PIXELS, "*", $fontface, $fonttype, "r", "*", "*", $fontregistry, $fontencoding);


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

	gimp_palette_set_background("#df0451");

	gimp_convert_indexed($image, 0, 0, 8, 0, 0, "");

	return $image;
}
 
   
register 
      "debian_button",
      "Create Debian Toolbar button",            # a small description 
      "A script to generate Debian navbar",      # a help text
      "Craig Small",
      "Copyright (c) 1998, 2001  SPI Inc.",
      "2001-06-10",
      "<Toolbox>/Xtns/Perl-Fu/Debian/Toolbar",   # menu path
      "*",                                       # Image types
      [ 
       [PF_STRING, "words", "Words to put in button", "About"], 
       [PF_BOOL, "antialias", "Use anti-aliasing", 1], 
       [PF_STRING, "fontface", "Font face", "Arial"], 
       [PF_INT, "fontsize", "Font size", "14"], 
       [PF_STRING, "fonttype", "Font type (e.g. bold, medium)", "bold"], 
       [PF_COLOR, "fontcolor", "Font color", [255,255,255]] ,
       [PF_COLOR, "bgcolor", "Background color", [0,0,132]],
       [PF_STRING, "fontregistry", "Font registry (e.g. iso8859)", "*"], 
       [PF_STRING, "fontencoding", "Font encoding (e.g. 1)", "*"]
      ], 
      \&debian_button; 
   
  exit main()
