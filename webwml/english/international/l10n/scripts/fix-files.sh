#! /bin/sh

#  Usage: fix-file.sh englishdir lang code1 code2 ...

dir=$1
lang=$2
shift; shift

for code
do
    test -f $dir/main-$code.inc     || echo 'DELETE-ME' > $dir/main-$code.inc
    test -f $dir/contrib-$code.inc  || echo 'DELETE-ME' > $dir/contrib-$code.inc
    test -f $dir/non-free-$code.inc || echo 'DELETE-ME' > $dir/non-free-$code.inc
    test -f $dir/main-$code.exc     || echo 'DELETE-ME' > $dir/main-$code.exc
    test -f $dir/contrib-$code.exc  || echo 'DELETE-ME' > $dir/contrib-$code.exc
    test -f $dir/non-free-$code.exc || echo 'DELETE-ME' > $dir/non-free-$code.exc

    sed -e "s/@tmpl_lang@/$code/" \
        -e "/LINE: inc-main/r     $dir/main-$code.inc" \
        -e "/LINE: inc-contrib/r  $dir/contrib-$code.inc" \
        -e "/LINE: inc-non-free/r $dir/non-free-$code.inc" \
        -e "/LINE: exc-main/r     $dir/main-$code.exc" \
        -e "/LINE: exc-contrib/r  $dir/contrib-$code.exc" \
        -e "/LINE: exc-non-free/r $dir/non-free-$code.exc" \
            tmpl.$lang.tmpl |\
        sed -e '/<!-- DO NOT REMOVE THIS LINE/d' |\
        perl -e 'while(<>) {if (m/BEGIN SECTION/) {$body=$_; $found=0;do {$_ = <>; $found=1 if m/DELETE-ME/; $body.=$_} until m/END SECTION/; print $body unless $found} else {print}}' \
                > $code.$lang.html
done

#  Perl code has replaced the following line, which is awfully slow
#  on Potato
#     sed -e ':t /BEGIN SECTION/,/END SECTION/{/END SECTION/!{$!{N;bt};};/DELETE-ME/d;}'
