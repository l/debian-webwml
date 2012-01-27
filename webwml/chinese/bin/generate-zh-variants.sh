#!/bin/bash

base=$1
ext=$2

MYPATH=`/usr/bin/dirname $0`
OPENCC=/usr/bin/opencc
if [ -x $OPENCC ]; then
HANT_TO_HANS="$OPENCC -c mix2zhs.ini"
HANS_TO_HANT="$OPENCC -c mix2zht.ini"
else
HANT_TO_HANS="cat"
HANS_TO_HANT="cat"
fi
TOCN=$MYPATH/tocn.pl
TOTW=$MYPATH/totw.pl
TOHK=$MYPATH/tohk.pl

check_exist () {
	while [ -n "$1" ]; do
		if [ ! -e "$1" ]; then
			echo "$0: ERROR: $1 does not exist!  Aborting..."
			exit 1
		fi
		shift
	done
}

generate_zh_variants () {
	echo -n "[zh_CN]"
	( eval $HANT_TO_HANS | $TOCN ) < $base.zh-cn.$ext.tmp > $base.zh-cn.$ext
	echo -n ", [zh_TW]"
	( eval $HANS_TO_HANT | $TOTW ) < $base.zh-tw.$ext.tmp > $base.zh-tw.$ext
	echo -n ", [zh_HK]"
	( eval $HANS_TO_HANT | $TOHK ) < $base.zh-hk.$ext.tmp > $base.zh-hk.$ext
	rm -f $base.zh-??.$ext.tmp
	echo "."
}

check_exist $ICONV $TOCN $TOTW $TOHK \
	$base.zh-cn.$ext.tmp $base.zh-tw.$ext.tmp $base.zh-hk.$ext.tmp

generate_zh_variants

