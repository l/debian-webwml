#!wml -o ../../../debian.org/distrib/%BASE.html.es
#use wml::debian::template title="Debian GNU/Linux &mdash; Paquetes"

<H1>Paquetes</H1>

<DL>
<DT><A href="$(HOME)/Packages/stable/">
Vea los paquetes en las distribuciones main, contrib, non-free and
non-us <STRONG>estables</STRONG>
</A>
<DD>
<DL>
<DT>Main
     <DD> La última versión de la distribución principal de Debian.
          Todos los paquetes estan a su disposición sin costo alguno.
          Están protegidos por un copyright que permite la libre
          redistribución, y vienen con todo el código fuente.
<DT>Contrib
     <DD> Los paquetes en este directorio también son de licencia libre,
          pero dependen para su funcionamiento de otros programas que
          no son libres (como Motif o Qt). Por ello no pueden formar
          parte de una distribución genuinamente libre como Debian
          <abbr>GNU</abbr>/Linux.
<DT>Non-Free
     <DD> Los paquetes en este directorio no son necesariamente
          comerciales, pero sus licencias tienen algún tipo de
	  restricción  demasiado onerosa como para permitir su
	  libre redistribución.
<DT>Non-US
     <DD> Estos paquetes no pueden ser exportados fuera de los EEUU.
          En su mayoría son paquetes de software de encriptación.
          Además algunos de ellos no son libres.          
</DL>
<DT><A href="$(HOME)/Packages/unstable/">Vea los paquetes en las
distribuciones <STRONG>inestables</STRONG></A>
     <DD> Este directorio contiene paquetes que estan destinados
          a ser incluídos en un futuro en las distribuciones arriba
	  indicadas (main, contrib, non-free o non-us). Estos no
          han sido todavía probados de manera extensiva (por lo que
          podrían hacer fallar a su sistema), o simplente han
	  aparecido hace poco y no ha habido tiempo de incluirlos en
          la distribución normal.
</DL>

<HR>
<H2>Búsquedas en los directorios de paquetes</H2>
<FORM method="post" action="http://cgi.debian.org/cgi-bin/htsearch">
<LABEL>Operador: <SELECT name=method>
<OPTION value=and>AND
<OPTION value=or>OR
<OPTION value=boolean>BOOLEAN
</SELECT></LABEL>
<LABEL>Formato: <SELECT name=format>
<OPTION value=builtin-long>Extenso
<OPTION value=builtin-short>Abreviado
</SELECT></LABEL>
<INPUT type=hidden name=config value="htdig_packages">
<INPUT type=hidden name=exclude value="">
<BR>
<LABEL>Busca: <INPUT type=text SIZE=30 name=words value=""></LABEL>
<INPUT type=submit value=Search> <INPUT type="reset">
<BR>busca en:
<LABEL><INPUT type=radio name=restrict value="/unstable"> inestable&nbsp;&nbsp;</LABEL>
<LABEL><INPUT type=radio name=restrict value="/stable/" CHECKED> estable&nbsp;&nbsp;</LABEL>
<LABEL><INPUT type=radio name=restrict value="/Packages/"> todos los paquetes</LABEL>
<BR>Nota: la búsqueda de subcadenas no está implementada todavía. Esto
 puede causar problemas. Por ejemplo, para encontrar libgtk necesita
 escribir <KBD>libgtk1</KBD>.
</FORM>

<HR>
<H2>Búsquedas en el contenido de la última versión</H2>
<P> Las búsquedas de arriba sólo encontrarán los encabezamientos y
descripciones de los los paquetes. Por ello, muchas búsquedas de
ejecutables que forman parte de un paquete, pero cuyo nombre no aparece
explícitamente en la descripción, fallarán. Aquí puede sin embargo
buscar entre los componentes de una version, y encontrar todos los paquetes
que contengan la palabra clave en cualquier nombre de archivo.
<BR>
<FORM method=post ACTION="http://cgi.debian.org/cgi-bin/search_contents.pl">
Busca en:
<LABEL><INPUT type=radio name=version value=stable CHECKED> estable&nbsp;&nbsp;</LABEL>
<LABEL><INPUT type=radio name=version value="unstable"> inestable</LABEL>
<BR>

<LABEL><INPUT type=radio name=case value=insensitive CHECKED> sin
importar Mayúsculas/minúsculas&nbsp;&nbsp;</LABEL>
<LABEL><INPUT type=radio name=case value=sensitive> hacer caso
Mayúsculas/minúsculas </LABEL>
<BR>
<LABEL>Palabra clave: <INPUT type=text SIZE=30 name=word value=""></LABEL> &nbsp;
<INPUT type=submit value=Search> &nbsp;<INPUT type="reset">
</FORM>

<HR>
<P>De vuelta a la <A href="$(HOME)/">página principal de Debian GNU/Linux</A>.

<:= languages ("$(HOME)", "distrib", "$(WML_SRC_BASENAME)", "$(CUR_LANG)") :>
