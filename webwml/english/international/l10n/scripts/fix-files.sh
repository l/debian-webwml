#! /bin/sh

#  Usage: fix-file.sh englishdir lang code1 code2 ...

dir=$1
lang=$2
shift; shift

for code
do
    for dist in main contrib non-free
    do
        for type in todo ok exc
        do
            file=$dir/${dist}-$code.$type
            test -f $file || echo 'DELETE-ME' > $file
        done
    done

    stat=`grep "^$code:" $dir/stats|sed 's/^.*://'`

    sed -e "s/@tmpl_lang@/$code/" \
        -e "s/@tmpl_lang_stats@/$stat/" \
        -e "s/href=\"tmpl\\./href=\"$code./" \
        -e "/LINE: todo-main/r     $dir/main-$code.todo" \
        -e "/LINE: todo-contrib/r  $dir/contrib-$code.todo" \
        -e "/LINE: todo-non-free/r $dir/non-free-$code.todo" \
        -e "/LINE: ok-main/r     $dir/main-$code.ok" \
        -e "/LINE: ok-contrib/r  $dir/contrib-$code.ok" \
        -e "/LINE: ok-non-free/r $dir/non-free-$code.ok" \
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
