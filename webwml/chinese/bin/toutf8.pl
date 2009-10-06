#!/usr/bin/perl -pi
s|^(\s*<meta http-equiv=.*charset)=big5">|$1=utf-8">|i;
s|^(\s*<meta http-equiv=.*charset)=gb2312">|$1=utf8">|i;
s|^(\s*<meta http-equiv=.*charset)=big5hkcs">|$1=utf8">|i;
