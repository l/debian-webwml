#!/usr/bin/perl
# $Id$

use strict;
use warnings;
use utf8;
binmode STDIN,  ':encoding(utf8)';
binmode STDOUT, ':encoding(utf8)';

my $cjk_regex = join('|',
                     '\p{InBopomofo_Extended}',
                     '\p{InBopomofo}',
                     '\p{InCJK_Compatibility_Forms}',
                     '\p{InCJK_Compatibility_Ideographs}',
                     '\p{InCJK_Compatibility}',
                     '\p{InCJK_Symbols_and_Punctuation}',
                     '\p{InCJK_Unified_Ideographs_Extension_A}',
                     '\p{InCJK_Unified_Ideographs}',
                     '\p{InEnclosed_CJK_Letters_and_Months}',
                     '\p{InHalfwidth_and_Fullwidth_Forms}',
                     '\p{InHangul_Compatibility_Jamo}',
                     '\p{InHangul_Syllables}',
                     '\p{InHiragana}',
                     '\p{InKanbun}',
                     '\p{InKatakana_Phonetic_Extensions}',
                     '\p{InKatakana}',
                     '\p{InYi_Radicals}',
                     '\p{InYi_Syllables}',
                     '\p{InYijing_Hexagram_Symbols}');

my @input_array=<>;
my $c=join("",@input_array);
$c =~ s/(^[^#].*?)(($cjk_regex)(<a\shref[^>]*>)?)\n((<a\shref[^>]*>)?($cjk_regex))/$1$2$5/mg;

# Convert the Big5 forward slash that's not in the GB2312 code table
# to the forward slash that's convertible.
$c =~ s/∕/／/g;

# Note: the following should be automatically generated in the future.
$c =~ s/<tw支援>/[CN:支援:][HKTW:支持:]/g;
$c =~ s/<tw(檔|檔案)>/[CN:文件:][HKTW:$1:]/g;
$c =~ s/<tw文件>/[CN:文檔:][HKTW:文件:]/g;
$c =~ s/<tw資訊>/[CN:信息:][HKTW:資訊:]/g;
$c =~ s/<tw連結>/[CN:鏈接:][HKTW:連結:]/g;
$c =~ s/<tw核心>/[CN:核心:][HKTW:核心:]/g;
$c =~ s/<tw資料(庫)?>/[CN:數據$1:][HKTW:資料$1:]/g;
$c =~ s/<tw匯(出|入)>/[CN:導$1:][HKTW:匯$1:]/g;
$c =~ s/<tw裝置>/[CN:設備:][HKTW:裝置:]/g;
$c =~ s/<tw連接埠>/[CN:端口:][HKTW:連接埠:]/g;
$c =~ s/<tw清單>/[CN:列表:][HKTW:清單:]/g;
$c =~ s/<tw布林>/[CNHK:布爾:][TW:布林:]/g;
$c =~ s/<tw檔案庫>/[CN:倉庫:][HKTW:檔案庫:]/g;
$c =~ s/<tw碟>/[CN:盤:][HKTW:碟:]/g;
$c =~ s/<cn倉庫>/[CN:倉庫:][HKTW:檔案庫:]/g;
$c =~ s/<cn文件>/[CN:文件:][HKTW:檔案:]/g;
$c =~ s/<cn信息>/[CN:信息:][HKTW:資訊:]/g;
$c =~ s/<cn項目>/[CN:項目:][HKTW:計畫:]/g;

print $c;
