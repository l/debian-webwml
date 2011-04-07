#!/bin/bash

base=$1
ext=$2

MYPATH=`/usr/bin/dirname $0`
ICONV=/usr/bin/iconv
HANT_TO_HANS="$ICONV -f UTF-8 -t big5 | $ICONV -f big5 -t gb2312 | $ICONV -f gb2312 -t UTF-8"
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
	$TOTW < $base.zh-tw.$ext.tmp > $base.zh-tw.$ext
	echo -n ", [zh_HK]"
	$TOHK < $base.zh-hk.$ext.tmp > $base.zh-hk.$ext
	rm -f $base.zh-??.$ext.tmp
	echo "."
}

check_exist $ICONV $TOCN $TOTW $TOHK \
	$base.zh-cn.$ext.tmp $base.zh-tw.$ext.tmp $base.zh-hk.$ext.tmp

generate_zh_variants

