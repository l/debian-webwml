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

s/撥號連接/撥接連線/g;
s/筆記本(計算機|電腦)/筆記型電腦/g;

s/窗口系統/視窗系統/g;
s/服務器/伺服器/g;
s/軟件包(?!裝|括)/套件/g;
s/郵(遞|件)列表/通信論壇/g;
s/鏡像站點/映射站台/g;
s/鏡像站/映射站/g;
s/鏡像/映射站台/g;
# s/鏡像((網)?站)/映射$1/g;
s/網絡對象模型環境/網絡物件模型環境/g;
s/調制解調器/數據機/g;

s/急救盤/救援磁碟/g;
s/(引導|啟動)盤/啟動磁碟/g;
s/安裝盤/安裝磁碟/g;

s/文本文件/純文字檔/g;
s/發布系統/發行套件/g;
s/體系結構/架構/g;
s/源代碼/原始碼/g;
s/補丁文件/修補檔案/g;

# 1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)“/$1「/);
# 1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)”/$1」/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(軟|硬|光|磁))盤/$1碟/);


1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)計算機/$1電腦/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)內核/$1核心/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)內存/$1記憶體/);
if ($sublang eq 'tw') {
	1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)以太(?=網)/$1乙太/);
}
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)字體/$1字型/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)後台/$1背景/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)菜單/$1選單/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)光標/$1游標/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)鼠標/$1滑鼠/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)站點/$1站台/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)界面/$1介面/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)腳本/$1命令稿/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)屏幕/$1螢幕/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)文檔(?!案)/$1文件/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)通過/$1透過/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)寬帶/$1寬頻/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)帶寬/$1頻寬/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)搜索/$1搜尋/);

if ($sublang eq 'hk') {
    s/作業系統/操作系統/g;
#    s/萬維網/全球資訊網/g;
    s/全球資訊網/萬維網/g;
    s/網際網(?:路|絡)/互聯網/g;
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)網路/$1網絡/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)使用者/$1用戶/);
#   1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)連(?=繫|絡)/$1聯/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)連(?=絡)/$1聯/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(軟|硬))體/$1件/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)列印/$1打印/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)印表機/$1打印機/);

  if (0 == 1) {
# 廣東話
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)在/$1��/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)也/$1亦都/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)哪(�圌兒)/$1邊度/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)這(�圌兒)/$1呢度/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)那(�圌兒)/$1�鶣�/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)如何/$1點樣/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)怎麼辦/$1點算好/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(?<!目)的(?!確)/$1��/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)是否/$1係唔係/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)是/$1係/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(什|甚)麼/$1乜��/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)找到/$1搵到/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(我|你|您|妳))們/$1�]/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)(他|她|牠|它)們/$1佢\�]/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(一|有|多|少|大|小))些/$1��/);
  }
}

if ($sublang eq 'tw') {
    s/操作系統/作業系統/g;
    s/萬維網/全球資訊網/g;
    s/(因特網|互聯網)/網際網路/g;
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)網絡/$1網路/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)用戶/$1使用者/);
#   1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)聯(?=繫|絡)/$1連/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(軟|硬))件/$1體/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)打印機/$1印表機/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)打印/$1列印/);
}

s/即插即用/隨插即用/g;
s/窗口系統/視窗系統/g;
s/X~窗口/X~視窗/g;
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)窗口/$1視窗/);
s/數據庫/資料庫/g;


# 生怕有人的電腦讀不到「�堙v字。
if ($sublang eq 'tw') {
	1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)��/$1裡/);
}
elsif ($sublang eq 'hk') {
	1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)裡/$1��/);
}

