ordlista: ../international/Swedish/ordlista.wml
	test -e ../international/Swedish/ordlista.sv.html && \
	test -e /usr/bin/w3m-en && \
	/usr/bin/w3m-en -dump ../international/Swedish/ordlista.sv.html | \
	grep '^[|+]' > ordlista || true

install: ordlista
