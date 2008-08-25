#! /bin/sh

#  Usage: fix-file.sh englishdir lang code1 code2 ...

dir=$1
lang=$2
shift; shift

for code
do
    for dist in main contrib non-free
    do
        echo 'DELETE-ME' > $dir/${dist}-$code.todo-nostatus
        echo 'DELETE-ME' > $dir/${dist}-$code.todo-status
        echo 'DELETE-ME' > $dir/${dist}-$code.todo-both
        if [ -f $dir/${dist}-$code.todo ]
        then
            rm -f $dir/${dist}-$code.todo-both
            if [ -f $dir/../../data/status.$code ]
            then
                rm -f $dir/${dist}-$code.todo-status
            else
                rm -f $dir/${dist}-$code.todo-nostatus
            fi
        fi

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
        -e "/LINE: todo-main /r     $dir/main-$code.todo" \
        -e "/LINE: todo-main-nostatus/r $dir/main-$code.todo-nostatus" \
        -e "/LINE: todo-main-status/r   $dir/main-$code.todo-status" \
        -e "/LINE: todo-main-both/r     $dir/main-$code.todo-both" \
        -e "/LINE: todo-contrib /r  $dir/contrib-$code.todo" \
        -e "/LINE: todo-contrib-nostatus/r  $dir/contrib-$code.todo-nostatus" \
        -e "/LINE: todo-contrib-status/r    $dir/contrib-$code.todo-status" \
        -e "/LINE: todo-contrib-both/r      $dir/contrib-$code.todo-both" \
        -e "/LINE: todo-non-free /r $dir/non-free-$code.todo" \
        -e "/LINE: todo-non-free-nostatus/r $dir/non-free-$code.todo-nostatus" \
        -e "/LINE: todo-non-free-status/r   $dir/non-free-$code.todo-status" \
        -e "/LINE: todo-non-free-both/r     $dir/non-free-$code.todo-both" \
        -e "/LINE: ok-main/r     $dir/main-$code.ok" \
        -e "/LINE: ok-contrib/r  $dir/contrib-$code.ok" \
        -e "/LINE: ok-non-free/r $dir/non-free-$code.ok" \
        -e "/LINE: exc-main/r     $dir/main-$code.exc" \
        -e "/LINE: exc-contrib/r  $dir/contrib-$code.exc" \
        -e "/LINE: exc-non-free/r $dir/non-free-$code.exc" \
            tmpl.$lang.tmpl |\
        sed -e '/<!-- DO NOT REMOVE THIS LINE/d' |\
        perl -e '
my @print = ();
my @block = ();
my $print = 1;
my $block = "";
while (<>) {
	if (m/BEGIN SECTION/){
		$block .= $_;
		push @print, $print;
		push @block, $block;
		$block = "";
		$print = 1;
	} elsif (m/END SECTION/) {
		my $tmp = "";
		$tmp = $block if $print;
		$print = pop @print;
		$block = pop @block;
		$block .= $tmp;
		$block .= $_;
	} elsif (m/DELETE-ME/) {
		$print = 0;
	} else {
		$block .= $_;
	}
}
print $block;' \
                > $code.$lang.html
done

#  Perl code has replaced the following line, which is awfully slow
#  on Potato
#     sed -e ':t /BEGIN SECTION/,/END SECTION/{/END SECTION/!{$!{N;bt};};/DELETE-ME/d;}'
