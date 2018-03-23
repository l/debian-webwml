#!/usr/bin/perl -w

# This script copies a security advisory named on the command line, and adds
# the translation-check header to it. It also will create the
# destination directory if necessary, and copy the Makefile from the source.

# Written in 2000-2004 by Peter Karlsson <peterk@debian.org>
# © Copyright 2000-2004 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

# Get command line
$number = $ARGV[0];

# Check usage.
unless ($number)
{
	print "Usage: $0 advisorynumber\n\n";
	print "Copies the advisory from the English directory to the local one and adds\n";
	print "the translation-check header\n";
	exit;
}

# Locate advisory
$number = "dsa-" . $number if $number !~ /^dsa-/;
$year = 2004;
YEAR: while (-d "../../english/security/$year")
{
	last YEAR if -e "../../english/security/$year/$number.wml";
	$year ++;
}

# Create needed file and directory names
$srcdir = "../../english/security/$year";
die "Unable to locate English version of advisory $number.\n"
	if ! -d $srcdir;
$srcfile= "$srcdir/$number.wml";
$cvsfile= "$srcdir/CVS/Entries";
$dstdir = "./$year";
$dstfile= "$dstdir/$number.wml";

# Sanity checks
die "File $srcfile does not exist\n"     unless -e $srcfile;
die "File $dstfile already exists\n"     if     -e $dstfile;
mkdir $dstdir, 0755                      unless -d $dstdir;

# Open the files
open CVS, $cvsfile
	or die "Could not read $cvsfile ($!)\n";

open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

# Retrieve the CVS version number
while (<CVS>)
{
	if (m[^/$number\.wml/([0-9]*\.[0-9]*)/]o)
	{
		$revision = $1;
	}
}

close CVS;

unless ($revision)
{
	print "Could not get revision number - bug in script?\n";
	$revision = '1.1';
}

# Insert the revision number
print DST qq'#use wml::debian::translation-check translation="$revision" mindelta="1"\n';

# Copy the file
while (<SRC>)
{
	next if /\$Id/;

	s/^(<p>)?A problem has been discovered in\b/$1Была обнаружена проблема в/;
	s/\bdiscovered a problem in\b/обнаружил проблему в/;
	s/We recommend that you upgrade your (.*) package immediately/Рекомендуется немедленно обновить пакет $1/;
	s/We recommend that you upgrade your (.*) packages immediately/Рекомендуется немедленно обновить пакеты $1/;
        s/We recommend that you upgrade your (.*) and (.*) packages/Рекомендуется обновить пакеты $1 и $2/;
	s/We recommend that you upgrade your (.*) packages/Рекомендуется обновить пакеты $1/;
	s/We recommend that you upgrade your (.*) package/Рекомендуется обновить пакет $1/;
	s/We recommend that you update your (.*) package immediately/Рекомендуется немедленно обновить пакет $1/;
	s/We recommend that you update your (.*) packages immediately/Рекомендуется немедленно обновить пакеты $1/;
	s/We recommend that you update your (.*) packages/Рекомендуется обновить пакеты $1/;
	s/We recommend that you update your (.*) package/Рекомендуется обновить пакет $1/;
	s/buffer overflows?/переполнение буфера/;
	s/integer overflow/переполнение целых чисел/;
	s/directory traversal/обход каталога/;
	s/format string vulnerability/уязвимость форматной строки/;
	s/format string vulnerabilities/уязвимости форматной строки/;
	s/insecure temporary files/небезопасные временные файлы/;
	s/>insecure temporary file creation</>небезопасное создание временного файла</;
	s/>local root exploit</>локальная уязвимость суперпользователя</;
	s/>remote root exploit</>удалённая уязвимость суперпользователя</;
	s/>symlink attack</>атака через символьные ссылки</;
	s/>remote exploit</>удалённая уязвимость</;
	s/>missing input sanitising</>отсутствие очистки входных данных</;
	s/missing input validation/отсутствие очистки входных данных/;
	s/Several vulnerabilities/Несколько уязвимостей/;
	s/several vulnerabilities/несколько уязвимостей/;
	s/multiple vulnerabilities/многочисленные уязвимости/;
	s/security update/обновление безопасности/;
	s/>several</>несколько</;
	s/>multiple</>многочисленные</;
	s/>the execution of arbitrary code</>выполнение произвольного кода</;
	s/>execution of arbitrary code</>выполнение произвольного кода</;
	s/>information disclosure</>раскрытие информации</;
	s/This has been fixed in version/Эта уязвимость была исправлена в версии/;
	s/this problem has been fixed in/эта проблема была исправлена в/;
	s/this problem has been fixed$/эта проблема была исправлена/;
	s/this problem has(?: been)?$/эта проблема была/;
	s/This problem has been fixed/Эта проблема была исправлена/;
	s/this problem is fixed in/эта проблема была исправлена в/;
	s/this problem is fixed/эта проблема исправлена/;
	s/These problems have been fixed/Эти проблемы были исправлены/;
	s/these problems have been fixed in/эти проблемы были исправлены в/;
	s/these problems have been fixed$/эти проблемы были исправлены/;
	s/these problems have(?: been)?$/эти проблемы были/;
	s/these problem are fixed in/эти проблемы исправлены в/;
	s/these problem are fixed/эти проблемы исправлены/;
	s/these problems will be fixed soon/эти проблемы будут исправлены позже/;
	s/(?:been )?fixed in version/исправлены в версии/;
	s/\bin version\b/в версии/;
	s/of the Debian package/пакета Debian/;
	s/upstream version/версии из основной ветки разработки/;
	s/([Ff])or the old stable distribution/В предыдущем стабильном выпуске/;
	s/([Ff])or the oldstable distribution/В предыдущем стабильном выпуске/;
	s/([Ff])or the old stable/В предыдущем стабильном/;
	s/([Ff])or the oldstable/В предыдущем стабильном/;
	s/([Ff])or the current stable distribution/В текущем стабильном выпуске/;
	s/([Ff])or the current stable/В текущем стабильном/;
	s/([Ff])or the Debian stable distribution/В стабильном выпуске Debian/;
	s/([Ff])or the stable distribution/В стабильном выпуске/;
	s/([Ff])or the stable/В стабильном/;
	s/([Ff])or the Debian unstable distribution/В нестабильном выпуске Debian/;
	s/([Ff])or the unstable distribution/В нестабильном выпуске/;
	s/([Ff])or the unstable/В нестабильном/;
	s/current stable distribution/текущем стабильном выпуске/;
	s/For the upcoming stable distribution/В готовящемся стабильном выпуске/;
	s/unstable distribution/нестабильном выпуске/;
	s/([Tt])he old stable distribution/Предыдущий стабильный выпуск/;
	s/([Tt])he oldstable distribution/Предыдущий стабильный выпуск/;
	s/^stable distribution/стабильный выпуск/;
	s/^unstable distribution/нестабильный выпуск/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/пакет $1 отсутствует/;
	s/For the testing distribution/В тестируемом выпуске/;
	s/testing distribution/тестируемом выпуске/;
	s/privilege escalation/повышений привилегий/;
	s/cross site/межсайтовый/;
	s/heap overflow/переполнение динамической памяти/;
	s/\bis not affected by this problem/не подвержен данной проблеме/;
	s/does not contain ([[:word:]]*) packages?/пакет $1 отсутствует/;
	s/does not contain a(?:ny)? ([[:word:]]*) packages/пакеты $1 отсутствуют/;
	s/does not contain a(?:ny)? ([[:word:]]*) package/пакет $1 отсутствует/;
	s/this problem will be fixed soon/эта проблема будет исправлена позже/;
	s/\(potato\)/(potato)/;
	s/\(woody\)/(woody)/;
	s/\(sarge\)/(sarge)/;
	s/\(lenny\)/(lenny)/;
	s/\(squeeze\)/(squeeze)/;
	s/\(wheezy\)/(wheezy)/;
	s/\(jessie\)/(jessie)/;
	s/\(stretch\)/(stretch)/;
	s/\(sid\)/(sid)/;
	s/\<p\>For the detailed security status of (.*) please refer to/<p>С подробным статусом поддержки безопасности $1 можно ознакомиться на/;
        s/its security tracker page at\:/соответствующей странице отслеживания безопасности по адресу\: /;

	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
