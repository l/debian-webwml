use strict;
use warnings;

sub create_sections() {
return (
'admin'		=> [ "Administration Utilities",
		"Utilities to administer system resources, manage user accounts, etc." ],
'base'		=> [ "Base Utilities",
		"Basic needed utilities of every Debian system (you needn\'t install this, they\'re provided only for upgrading purposes)." ],
'comm'		=> [ "Communication Programs",
		"Software to use your modem in the old fashioned style." ],
'devel'		=> [ "Development",
		"Development utilities, compilers, development environments, libraries, etc." ],
'doc'		=> [ "Documentation",
		"FAQs, HOWTOs and other documents trying to explain everything related to Debian, and software needed to browse documentation (man, info, etc)." ],
'editors'	=> [ "Editors",
		"Software to edit files. Programming environments." ],
'electronics'	=> [ "Electronics",
		"Electronics utilities." ],
'embedded'	=> [ "Embedded software",
		"Software suitable for use in embedded applications." ],
'games'		=> [ "Games",
		"Programs to spend a nice time with after all this setting up." ],
'gnome'		=> [ "GNOME",
		"The GNOME desktop environment, a powerful, easy to use set of integrated applications." ],
'graphics'	=> [ "Graphics",
		"Editors, viewers, converters... Everything to become an artist." ],
'hamradio'	=> [ "Ham Radio",
		"Software for ham radio." ],
'interpreters'	=> [ "Interpreters",
		"All kind of interpreters for interpreted languages. Macro processors." ],
'kde'		=> [ "KDE",
		"The K Desktop Environment, a powerful, easy to use set of integrated applications." ],
'libs'		=> [ "Libraries",
		"Libraries to make other programs work. They provide special features to developers." ],
'libdevel'	=> [ "Library development",
		"Libraries necessary for developers to write programs that use them." ],
'mail'		=> [ "Mail",
		"Programs to route, read, and compose E-mail messages." ],
'math'		=> [ "Mathematics",
		"Math software." ],
'misc'		=> [ "Miscellaneous",
		"Miscellaneous utilities that didn\'t fit well anywhere else." ],
'net'		=> [ "Network",
		"Daemons and clients to connect your Debian GNU/Linux system to the world." ],
'news'		=> [ "Newsgroups",
		"Software to access Usenet, to set up news servers, etc." ],
'non-US'	=> [ "Software restricted in the U.S.",
		"These packages probably may not be used in or distributed from the U.S. due to software patents. You should check the regulations in your country before using this software." ],
'oldlibs'	=> [ "Old Libraries",
		"Old versions of libraries, kept for backward compatibility with old applications." ],
'otherosfs'	=> [ "Other OS\'s and file systems",
		"Software to run programs compiled for other operating system, and to use their filesystems." ],
'perl'		=> [ "Perl",
		"Everything about Perl, an interpreted scripting language." ],
'python'	=> [ "Python",
		"Everything about Python, an interpreted, interactive object oriented language." ],
'science'	=> [ "Science",
		"Basic tools for scientific work" ],
'shells'	=> [ "Shells",
		"Command shells. Friendly user interfaces for beginners." ],
'sound'		=> [ "Sound",
		"Utilities to deal with sound: mixers, players, recorders, CD players, etc." ],
'tex'		=> [ "TeX",
		"The famous typesetting software and related programs." ],
'text'		=> [ "Text Processing",
		"Utilities to format and print text documents." ],
'translations'  => [ "Translations", "Translation packages and language support meta packages." ],
'utils'		=> [ "Utilities",
		"Utilities for file/disk manipulation, backup and archive tools, system monitoring, input systems, etc." ],
'virtual'	=> [ "Virtual packages",
		"Virtual packages." ],
'web'		=> [ "Web Software",
		"Web servers, browsers, proxies, download tools etc." ],
'x11'		=> [ "X Window System software",
		"X servers, libraries, fonts, window managers, terminal emulators and many related applications." ],
'debian-installer' => [ "debian-installer udeb packages",
			"Special packages for building customized debian-installer variants. Do not install them on a normal system!" ],
);
}

1;
