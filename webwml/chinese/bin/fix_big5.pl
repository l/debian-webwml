#!/usr/bin/perl -p

# Fix backslashes in Big5 Chinese characters
s/^((?:[\x00-\x7F]|(?:[\x80-\xFF].))+[\x80-\xFF]\\)$/$1\\/;

# Protect "{:" when the "{" is a second byte of a Big5 Chinese character
# while (s%^((?:[\x00-\x7f]|[\x80-\xff].)*)([\x80-\xFF]x)%$1$2%) {}
while ( s{^((?:[\x00-\x7F]|(?:[\x80-\xFF].))+?)([\x80-\xFF]\{)(?!</protect>)}
	 {$1<protect>$2</protect>} ) {}

# Convert the Big5 forward slash that's not in the GB2312 code table
# to the forward slash that's convertible.
s/�A/��/g;

# Note: the following should be automatically generated in the future.
s/<tw�䴩>/[CN:�䴩:][HKTW:���:]/g;
s/<tw(��|�ɮ�)>/[CN:���:][HKTW:$1:]/g;
s/<tw���>/[CN:����:][HKTW:���:]/g;
s/<tw��T>/[CN:�H��:][HKTW:��T:]/g;
s/<tw�s��>/[CN:�챵:][HKTW:�s��:]/g;
s/<tw�֤�>/[CN:�֤�:][HKTW:�֤�:]/g;
s/<tw���(�w)?>/[CN:�ƾ�$1:][HKTW:���$1:]/g;
s/<tw��(�X|�J)>/[CN:��$1:][HKTW:��$1:]/g;
s/<tw�˸m>/[CN:�]��:][HKTW:�˸m:]/g;
s/<tw�s����>/[CN:�ݤf:][HKTW:�s����:]/g;
s/<tw�M��>/[CN:�C��:][HKTW:�M��:]/g;
s/<tw���L>/[CNHK:����:][TW:���L:]/g;
