#!/usr/bin/perl -pi

# $Id$

$0 =~ m|to(..)\.pl$|;
my $sublang = $1;
my $SUBLANG = uc($sublang);

s|^(<html lang="zh)">|$1-$SUBLANG">|i;
if ($sublang eq 'hk') {
	s|^(<meta http-equiv=.*charset)=big5">|$1=big5-hkscs">|i;
}
s/(\.zh)(?=\.(?:gif|jpg|png))/$1-$sublang/g;
s|^<A href=".*">(&#20013;&#25991;&nbsp;.+$SUBLANG.+)</A>(?=&nbsp;)|<B>$1</B>|;

s/怠╰参/跌怠╰参/g;
s/狝叭竟/狝竟/g;
s/硁ン(?!杆|珹)/甅ン/g;
s/秎(患|ン)/硄獺阶韭/g;
s/描钩翴/琈甮/g;
s/描钩/琈甮/g;
s/描钩/琈甮/g;
# s/描钩((呼)?)/琈甮$1/g;
s/呼蹈癸禜家吏挂/呼蹈ン家吏挂/g;

s/毕絃/毕穿合盒/g;
s/(ま旧|币笆)絃/币笆合盒/g;
s/杆絃/杆合盒/g;

s/ゅセゅン/ゅ郎/g;
s/祇ガ╰参/祇︽甅ン/g;
s/砰╰挡篶/琜篶/g;
s/方絏/﹍絏/g;
s/干ゅン/干郎/g;

# 1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)¨/$1/);
# 1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)〃/$1/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(硁|祑||合))絃/$1盒/);


1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)璸衡诀/$1筿福/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ず/$1み/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ず/$1癘拘砰/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)び(?=呼)/$1び/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)砰/$1/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1璉春/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)垫虫/$1匡虫/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)夹/$1村夹/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)公夹/$1菲公/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)翴/$1/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1ざ/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)竲セ/$1絑セ/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)辊/$1棵辊/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ゅ郎(?!)/$1ゅン/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)硄筁/$1硓筁/);

if ($sublang eq 'hk') {
    s/穨╰参/巨╰参/g;
#    s/窾蝴呼/瞴戈癟呼/g;
    s/瞴戈癟呼/窾蝴呼/g;
    s/呼悔呼(?=隔|蹈)/が羛呼/g;
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)呼隔/$1呼蹈/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ㄏノ/$1ノめ/);
#   1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)硈(?=么|蹈)/$1羛/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)硈(?=蹈)/$1羛/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(硁|祑))砰/$1ン/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1ゴ/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)诀/$1ゴ诀/);

# 約狥杠
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1濚/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1ョ常/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(|ㄠ)/$1娩/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)硂(|ㄠ)/$1㎡/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ê(|ㄠ)/$1濙/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1翴妓/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)或快/$1翴衡/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(?<!ヘ)(?!絋)/$1濓/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)琌/$1玒玒/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)琌/$1玒/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(ぐ|)或/$1葾澫/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)т/$1莜/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(и||眤|﹑))/$1抅/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(||╡|ウ)/$1蔦\抅/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(|Τ||ぶ||))ㄇ/$1濜/);
}

if ($sublang eq 'tw') {
    s/巨╰参/穨╰参/g;
    s/窾蝴呼/瞴戈癟呼/g;
    s/が羛呼/呼悔呼隔/g;
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)呼蹈/$1呼隔/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ノめ/$1ㄏノ/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)羛(?=么|蹈)/$1硈/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(硁|祑))ン/$1砰/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ゴ诀/$1诀/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)ゴ/$1/);
}

s/础ノ/繦础ノ/g;
s/怠╰参/跌怠╰参/g;
s/X~怠/X~跌怠/g;
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)怠/$1跌怠/);
s/计沮畐/戈畐/g;


# ネ┤Τ筿福弄ぃ
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)/$1柑/);
