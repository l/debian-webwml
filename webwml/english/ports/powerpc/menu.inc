[ <a href="../">Ports</a> ]

[ <ifneq <get-var WML_SRC_BASENAME> "index"
  "<a href="index">Debian PowerPC</a>"
  "<b>Debian PowerPC</b>"
> ]

[ <ifneq <get-var WML_SRC_BASENAME> "news"
  "<a href="news">News</a>"
  "<b>News</b>"
> ]

[ <ifneq <get-var WML_SRC_BASENAME> "devel"
  "<a href="devel">Devel</a>"
  "<b>Devel</b>"
> ]

[ <ifneq <get-var WML_SRC_BASENAME> "docu"
  "<a href="docu">Documentation</a>"
  "<b>Documentation</b>"
> ]

[ <ifneq <get-var WML_SRC_BASENAME> "supply"
  "<a href="supply">Supply</a>"
  "<b>Supply</b>"
> ]

[ <a href="inst/install">Installation</a> ]
