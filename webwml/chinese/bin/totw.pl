#!/usr/bin/perl -pi

$0 =~ m|to(..)\.pl$|;
my $sublang = $1;
my $SUBLANG = uc($sublang);

s|^(<HTML lang="zh)">|$1-$SUBLANG)">|;
s/(\.zh)(?=\.(?:gif|jpg|png))/$1-$sublang/g;
s|^<A href=".*">(&#20013;&#25991;&nbsp;.+$SUBLANG.+)</A>(?=&nbsp;)|<B>$1</B>|;

s/操作系統/作業系統/g;
s/窗口系統/視窗系統/g;
s/服務器/伺服器/g;
s/軟件包(?!裝|括)/套件/g;
s/郵(遞|件)列表/通信論壇/g;
s/鏡像(站(點)?)?/映射站台/g;
# s/鏡像((網)?站)/映射$1/g;
s/網絡對象模型環境/網絡物件模型環境/g;

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
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(軟|硬))件/$1體/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*(軟|硬|光|磁))盤/$1碟/);


1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)計算機/$1電腦/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)內核/$1核心/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)乙太(?=網)/$1以太/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)字體/$1字型/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)後台/$1背景/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)菜單/$1選單/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)屏幕/$1螢幕/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)光標/$1游標/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)鼠標/$1滑鼠/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)腳本/$1稿本/);
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)站點/$1站台/);

if ($sublang eq 'hk') {
#    s/萬維網/全球資訊網/g;
#    s/互聯網/網際網路/g;
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)網路/$1網絡/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)用戶/$1使用者/);
#   1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)界面/$1介面/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)計畫/$1計劃/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)連(?=繫|絡)/$1聯/);
}

if ($sublang eq 'tw') {
    s/萬維網/全球資訊網/g;
    s/互聯網/網際網路/g;
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)網絡/$1網路/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)用戶/$1使用者/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)界面/$1介面/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)計劃/$1計畫/);
    1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)聯(?=繫|絡)/$1連/);
}

s/即插即用/隨插即用/g;
s/窗口系統/視窗系統/g;
s/X~窗口/X~視窗/g;
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)窗口/$1視窗/);
s/數據庫/資料庫/g;


# 生怕有人的電腦讀不到「�堙v字。
1 while (s/^((?:[\x00-\x7f]|[\x80-\xff].)*)��/$1裡/);
