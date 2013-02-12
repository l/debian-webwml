#! /bin/sh

#  Usage: fix-file.sh englishdir lang tmpl code1 code2 ...

dir=$1
lang=$2
tmpl=$3
shift; shift; shift

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
    langname=`perl -e '
my $langname = "'$langname'";
my $lang = "'$lang'";
my $country = "'$country'";
use Locale::gettext;
use SDBM_File;
my (%languages,%countries);
dbmopen(%languages,"../languages",0444) or die($!);
$langname = $languages{$langname};
    if ($langname ne "") {
	    $langname = dgettext("iso_639_3", $langname);
    }
    dbmclose(%languages) or die($!);
    if ($country ne "") {
	    dbmopen(%countries,"../countries",0444) or die($!);
	    my $country = $countries{$country};
	    if ($country ne "") {
		    $langname .= " &ndash; ".$country;
	    }
	    dbmclose(%countries) or die($!);
    }
    print $langname;
'`
    for dist in main contrib non-free
    do
        echo 'DELETE-ME' > $dir/${dist}-$code.todo-nostatus
        echo 'DELETE-ME' > $dir/${dist}-$code.todo-status
        echo 'DELETE-ME' > $dir/${dist}-$code.todo-both
        if [ -f $dir/${dist}-$code.todo ] || [ -f $dir/${dist}-$code.todol ]
        then
            rm -f $dir/${dist}-$code.todo-both
            if [ -f $dir/../../data/status.$code ]
            then
                rm -f $dir/${dist}-$code.todo-status
            else
                rm -f $dir/${dist}-$code.todo-nostatus
            fi
        fi

        for type in todol todo ok exc
        do
            file=$dir/${dist}-$code.$type
            test -f $file || echo 'DELETE-ME' > $file
        done
    done

    stat=`grep "^$code:" $dir/stats|sed 's/^.*://'`
    sed -e "s/@tmpl_lang@/$code \&mdash; $langname /" \
        -e "s/@tmpl_lang_stats@/$stat/" \
        -e "s/href=\"$tmpl\\./href=\"$code./" \
        -e "/LINE: todo-main /r     $dir/main-$code.todo" \
	-e "/LINE: todol-main /r     $dir/main-$code.todol" \
        -e "/LINE: todo-main-nostatus/r $dir/main-$code.todo-nostatus" \
        -e "/LINE: todo-main-status/r   $dir/main-$code.todo-status" \
        -e "/LINE: todo-main-both/r     $dir/main-$code.todo-both" \
        -e "/LINE: todo-contrib /r  $dir/contrib-$code.todo" \
	-e "/LINE: todol-contrib /r  $dir/contrib-$code.todol" \
        -e "/LINE: todo-contrib-nostatus/r  $dir/contrib-$code.todo-nostatus" \
        -e "/LINE: todo-contrib-status/r    $dir/contrib-$code.todo-status" \
        -e "/LINE: todo-contrib-both/r      $dir/contrib-$code.todo-both" \
        -e "/LINE: todo-non-free /r $dir/non-free-$code.todo" \
	-e "/LINE: todol-non-free /r $dir/non-free-$code.todol" \
        -e "/LINE: todo-non-free-nostatus/r $dir/non-free-$code.todo-nostatus" \
        -e "/LINE: todo-non-free-status/r   $dir/non-free-$code.todo-status" \
        -e "/LINE: todo-non-free-both/r     $dir/non-free-$code.todo-both" \
        -e "/LINE: ok-main/r     $dir/main-$code.ok" \
        -e "/LINE: ok-contrib/r  $dir/contrib-$code.ok" \
        -e "/LINE: ok-non-free/r $dir/non-free-$code.ok" \
        -e "/LINE: exc-main/r     $dir/main-$code.exc" \
        -e "/LINE: exc-contrib/r  $dir/contrib-$code.exc" \
        -e "/LINE: exc-non-free/r $dir/non-free-$code.exc" \
            $tmpl.$lang.tmpl |\
        sed -e '/<!-- DO NOT REMOVE THIS LINE/d' |\
	sed -e ':t /BEGIN SECTION/,/END SECTION/{/END SECTION/!{$!{N;bt};};/DELETE-ME/d;}' |\
	sed -e '/DELETE-ME/d' |\
	sed -e ':begin;$!N;s,<h3>.*</h3>\n<h,<h,;tbegin;P;D'\
                > $code.$lang.html
done
