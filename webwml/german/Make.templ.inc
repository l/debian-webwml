$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
	$(WML) $(<F)

$(HTMLDIR)/%.jpg : %.jpg
	@cp $< $@

# template dependencies

template/debian/basic.wml: template/debian/navbar.wml
	touch template/debian/basic.wml

template/debian/footer.wml: template/debian/ctime.wml
	touch template/debian/footer.wml

template/debian/menubar.wml: template/debian/footer.wml
	touch template/debian/menubar.wml

template/debian/mainpage.wml: template/debian/basic.wml template/debian/menubar.wml
	touch template/debian/mainpage.wml

template/debian/template.wml: template/debian/basic.wml template/debian/footer.wml
	touch template/debian/template.wml
