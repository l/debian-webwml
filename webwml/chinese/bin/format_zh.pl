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

print $c;
