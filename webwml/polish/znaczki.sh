#!/bin/sh
sed -e "s/,,/\&#8222;/g; s/''/\&#8221;/g;" $1 > temp
mv temp $1
