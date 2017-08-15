#!/bin/bash

## generate-zh-variants.sh -- Generate pages for different Chinese variants
#
# This script try to process and convert the original texts into different
# Chinese variants using opencc and some predefined converting rules.

base=$1
ext=$2

MYPATH=$(/usr/bin/dirname $0)
OPENCC="/usr/bin/opencc"
OPENCC_VERSION_COMPAT=""
if [ -x "$OPENCC" ]; then
    # test opencc version here
    _OPENCC_VERSION="$(${OPENCC} --version | grep '^Version' | cut -d' ' -f2)"
    OPENCC_VERSION_COMPAT=$(echo "${_OPENCC_VERSION}" | grep -o '^.')
fi

# opencc has API breakage between v0.x and v1.x, so we test the opencc version
# and set the correct behaviour before we start.

if [ -z "$OPENCC_VERSION_COMPAT" ]; then
    printf "%s WARN: opencc NOT FOUND! not converting variants...\n" "$0"
    HANT_TO_HANS="cat"
    HANS_TO_HANT="cat"
    HANT_TO_TW="cat"
    HANT_TO_HK="cat"
elif [ "${OPENCC_VERSION_COMPAT}x" = "0x" ]; then
    printf "%s INFO: using old opencc 0.x...\n" "$0"
    HANT_TO_HANS="$OPENCC -c mix2zhs.ini"
    HANS_TO_HANT="$OPENCC -c mix2zht.ini"
    HANT_TO_TW="cat"
    HANT_TO_HK="cat"
elif [ "${OPENCC_VERSION_COMPAT}x" = "1x" ]; then
    HANT_TO_HANS="$OPENCC -c t2s.json"
    HANS_TO_HANT="$OPENCC -c s2t.json"
    HANT_TO_TW="$OPENCC -c t2tw.json"
    HANT_TO_HK="$OPENCC -c t2hk.json"
else
    printf "%s WARN: opencc v%s not supported! not converting variants...\n"\
            "$0" "${OPENCC_VERSION_COMPAT}"
    HANT_TO_HANS="cat"
    HANS_TO_HANT="cat"
    HANT_TO_TW="cat"
    HANT_TO_HK="cat"
fi # opencc version compat


TOCN=$MYPATH/tocn.pl
TOTW=$MYPATH/totw.pl
TOHK=$MYPATH/tohk.pl

check_exist() {
    while [ -n "$1" ]; do
        if [ ! -e "$1" ]; then
            echo "$0: ERROR: $1 does not exist! Aborting..."
            exit 1
        fi
        shift
    done
}

generate_zh_variants () {
    echo -n "[zh_CN]"
    ( eval $HANT_TO_HANS | $TOCN ) < "$base".zh-cn."$ext".tmp > "$base".zh-cn."$ext"
    echo -n ", [zh_TW]"
    # TODO
    ( eval $HANS_TO_HANT | $HANT_TO_TW | $TOTW ) < "$base".zh-tw."$ext".tmp > "$base".zh-tw."$ext"
    echo -n ", [zh_HK]"
    ( eval $HANS_TO_HANT | $HANT_TO_HK | $TOHK ) < "$base".zh-hk."$ext".tmp > "$base".zh-hk."$ext"
    rm -f "$base".zh-??."$ext".tmp
    echo "."
}

check_exist "${ICONV}" "${TOCN}" "${TOTW}" "${TOHK}" \
            "$base".zh-cn."$ext".tmp "$base".zh-tw."$ext".tmp "$base".zh-hk."$ext".tmp

generate_zh_variants

