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
     <DD> La �ltima versi�n de la distribuci�n principal de Debian.
          Todos los paquetes estan a su disposici�n sin costo alguno.
          Est�n protegidos por un copyright que permite la libre
          redistribuci�n, y vienen con todo el c�digo fuente.
<DT>Contrib
     <DD> Los paquetes en este directorio tambi�n son de licencia libre,
          pero dependen para su funcionamiento de otros programas que
          no son libres (como Motif o Qt). Por ello no pueden formar
          parte de una distribuci�n genuinamente libre como Debian
          <abbr>GNU</abbr>/Linux.
<DT>Non-Free
     <DD> Los paquetes en este directorio no son necesariamente
          comerciales, pero sus licencias tienen alg�n tipo de
	  restricci�n  demasiado onerosa como para permitir su
	  libre redistribuci�n.
<DT>Non-US
     <DD> Estos paquetes no pueden ser exportados fuera de los EEUU.
          En su mayor�a son paquetes de software de encriptaci�n.
          Adem�s algunos de ellos no son libres.          
</DL>
<DT><A href="$(HOME)/Packages/unstable/">Vea los paquetes en las
distribuciones <STRONG>inestables</STRONG></A>
     <DD> Este directorio contiene paquetes que estan destinados
          a ser inclu�dos en un futuro en las distribuciones arriba
	  indicadas (main, contrib, non-free o non-us). Estos no
          han sido todav�a probados de manera extensiva (por lo que
          podr�an hacer fallar a su sistema), o simplente han
	  aparecido hace poco y no ha habido tiempo de incluirlos en
          la distribuci�n normal.
</DL>

<HR>
<H2>B�squedas en los directorios de paquetes</H2>
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
<BR>Nota: la b�squeda de subcadenas no est� implementada todav�a. Esto
 puede causar problemas. Por ejemplo, para encontrar libgtk necesita
 escribir <KBD>libgtk1</KBD>.
</FORM>

<HR>
<H2>B�squedas en el contenido de la �ltima versi�n</H2>
<P> Las b�squedas de arriba s�lo encontrar�n los encabezamientos y
descripciones de los los paquetes. Por ello, muchas b�squedas de
ejecutables que forman parte de un paquete, pero cuyo nombre no aparece
expl�citamente en la descripci�n, fallar�n. Aqu� puede sin embargo
buscar entre los componentes de una version, y encontrar todos los paquetes
que contengan la palabra clave en cualquier nombre de archivo.
<BR>
<FORM method=post ACTION="http://cgi.debian.org/cgi-bin/search_contents.pl">
Busca en:
<LABEL><INPUT type=radio name=version value=stable CHECKED> estable&nbsp;&nbsp;</LABEL>
<LABEL><INPUT type=radio name=version value="unstable"> inestable</LABEL>
<BR>

<LABEL><INPUT type=radio name=case value=insensitive CHECKED> sin
importar May�sculas/min�sculas&nbsp;&nbsp;</LABEL>
<LABEL><INPUT type=radio name=case value=sensitive> hacer caso
May�sculas/min�sculas </LABEL>
<BR>
<LABEL>Palabra clave: <INPUT type=text SIZE=30 name=word value=""></LABEL> &nbsp;
<INPUT type=submit value=Search> &nbsp;<INPUT type="reset">
</FORM>

<HR>
<P>De vuelta a la <A href="$(HOME)/">p�gina principal de Debian GNU/Linux</A>.

<:= languages ("$(HOME)", "distrib", "$(WML_SRC_BASENAME)", "$(CUR_LANG)") :>
