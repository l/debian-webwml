
IMAGES= dfsg-big.png dfsg.png hammer-big.png hammer.png hold-big.png hold.png mag-big.png mag.png new-big.png new.png shake-big.png shake.png thumb-big.png thumb.png

rsync: $(HTMLFILES) $(PHPFILES) 
	rsync -e ssh $(HTMLFILES) $(PHPFILES) $(IMAGES) $(INCFILES) pandora.debian.org:/org/nm.debian.org/web/images

