#!/usr/bin/perl -p

# $Id$

use strict;
use warnings;
use utf8;
use open ':std', ':utf8';
#binmode STDIN, ':encoding(utf8)';
#binmode STDOUT, ':encoding(utf8)';

# Fix backslashes in Big5 Chinese characters
#s/^((?:[\x00-\x7F]|(?:[\x80-\xFF].))+[\x80-\xFF]\\)$/$1\\/;

# Protect "{:" when the "{" is a second byte of a Big5 Chinese character
# while (s%^((?:[\x00-\x7f]|[\x80-\xff].)*)([\x80-\xFF]x)%$1$2%) {}
#while ( s{^((?:[\x00-\x7F]|(?:[\x80-\xFF].))+?)([\x80-\xFF]\{)(?!</protect>)}
#	 {$1<protect>$2</protect>} ) {}

# Convert the Big5 forward slash that's not in the GB2312 code table
# to the forward slash that's convertible.
s/∕/／/g;
s/着/著/g;

# Note: the following should be automatically generated in the future.
s/<tw支援>/[CN:支援:][HKTW:支持:]/g;
s/<tw(檔|檔案)>/[CN:文件:][HKTW:$1:]/g;
s/<tw文件>/[CN:文檔:][HKTW:文件:]/g;
s/<tw資訊>/[CN:信息:][HKTW:資訊:]/g;
s/<tw連結>/[CN:鏈接:][HKTW:連結:]/g;
s/<tw核心>/[CN:核心:][HKTW:核心:]/g;
s/<tw資料(庫)?>/[CN:數據$1:][HKTW:資料$1:]/g;
s/<tw匯(出|入)>/[CN:導$1:][HKTW:匯$1:]/g;
s/<tw裝置>/[CN:設備:][HKTW:裝置:]/g;
s/<tw連接埠>/[CN:端口:][HKTW:連接埠:]/g;
s/<tw清單>/[CN:列表:][HKTW:清單:]/g;
s/<tw布林>/[CNHK:布爾:][TW:布林:]/g;
