ordlista: ../international/Swedish.wml
	test -e ../international/Swedish.sv.html && \
	test -e /usr/bin/w3m-en && \
	/usr/bin/w3m-en -dump ../international/Swedish.sv.html | \
	grep '^[|+]' > ordlista || true
