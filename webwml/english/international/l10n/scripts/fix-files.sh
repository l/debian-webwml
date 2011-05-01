#! /bin/sh

#  Usage: fix-file.sh englishdir lang code1 code2 ...

dir=$1
lang=$2
shift; shift

for code
do

# TODO: share this code from dtc.def
    langname=${code%@*}
    country=''
    if [ `expr index $langname '_'` -ne 0 ]
    then
        country=${langname#*_}
        langname=${langname%_*}
    fi
    if [ "`isoquery -i 639 --name $langname`" != '' ]
    then
        langname=`isoquery -i 639 -n $langname | sed 's/^.*\t//'`
        langname=`perl -e "use Locale::gettext; print dgettext('iso_639', '$langname')"`
        # #624476 workaround: French typography expect languages to start with a lowercase
	if [ $lang = 'fr' ]
        then
            langname=`perl -e "print lcfirst '$langname'"`
        fi
	if [ "$country" != '' ]
       	then
            if [ "`isoquery --name $country`" != '' ]
            then
                country=`isoquery -n $country | sed 's/^.*\t//'`
	        country=`perl -e "use Locale::gettext; print dgettext('iso_3166', '$country')"`
	        langname="$langname \&ndash; $country"
            fi
        fi
        # Workaround for Languages not in UTF-8 yet
        if [ $lang = 'en' ]
        then
            langname=`echo $langname | iconv -f utf8 -t latin1`
        elif [ $lang = 'es' ]
        then
            langname=`echo $langname | iconv -f utf8 -t latin1`
	elif [ $lang = 'pl' ]
        then
            langname=`echo $langname | iconv -f utf8 -t latin2`
        elif [ $lang = 'pt' ]
        then
            langname=`echo $langname | iconv -f utf8 -t latin1`
        fi		
    else
        langname=''
    fi

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
    sed -e "s/@tmpl_lang@/$code \&mdash; $langname /" \
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
