#!/usr/bin/perl -p

# Fix backslashes in Big5 Chinese characters
s/^((?:[\x00-\x7F]|(?:[\x80-\xFF].))+[\x80-\xFF]\\)$/$1\\\\/;

# Protect "{:" when the "{" is a second byte of a Big5 Chinese character
# while (s%^((?:[\x00-\x7f]|[\x80-\xff].)*)([\x80-\xFF]x)%$1$2%) {}
while ( s{^((?:[\x00-\x7F]|(?:[\x80-\xFF].))+?)([\x80-\xFF]\{)(?!</protect>)}
	 {$1<protect>$2</protect>} ) {}
