ordlista: ../international/Swedish/index.wml
	test -e ../international/Swedish/index.sv.html && \
	test -e /usr/bin/w3m-en && \
	/usr/bin/w3m-en -dump ../international/Swedish/ordlista.sv.html | \
	grep '^[|+]' > ordlista || true

install: ordlista
