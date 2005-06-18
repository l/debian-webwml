#use wml::debian::language_names
#use wml::debian::common_tags
#use wml::debian::translation-check translation="1.41"

<bind-gettext-domain domain="bugs" />

<ul>

  <li><small><gettext domain="bugs">Флагове:</gettext>
  <label><input type="radio" name="archive" value="no" checked>
    <gettext domain="bugs">активни бъгове</gettext></label>
  <label><input type="radio" name="archive" value="yes">
     <gettext domain="bugs">стари бъгове</gettext></label>
  <br>
  <label><input type="checkbox" name="repeatmerged" value="no">
     <gettext domain="bugs">показване на вмъкнатите бъгове само веднъж</gettext></label>
  <label><input type="checkbox" name="raw" value="yes">
     <gettext domain="bugs">без сортиране по статус и критичности</gettext></label>
  <br>
  <label><input type="checkbox" name="show_list_header" value="no">
     <gettext domain="bugs">скриване на съдържанието в заглавната част</gettext></label>
  <label><input type="checkbox" name="show_list_footer" value="no">
     <gettext domain="bugs">скриване на статистиките в долния колонтитул</gettext></label>
  </small>

  <li><small><gettext domain="bugs">Обратно сортиране по:</gettext>
  <label><input type="checkbox" name="pend-rev" value="yes">
    <gettext domain="bugs">статус</gettext></label>
  <label><input type="checkbox" name="sev-rev" value="yes">
    <gettext domain="bugs">критичност</gettext></label>
  <label><input type="checkbox" name="bug-rev" value="yes">
    <gettext domain="bugs">бъгове</gettext></label>
  </small></li>

<define-tag open whitespace=delete>
  <gettext domain="bugs">отворен</gettext>
</define-tag>
<define-tag forwarded whitespace=delete>
  <gettext domain="bugs">препратен</gettext>
</define-tag>
<define-tag pending whitespace=delete>
  <gettext domain="bugs">нерешен</gettext>
</define-tag>
<define-tag fixed whitespace=delete>
  <gettext domain="bugs">поправен</gettext>
</define-tag>
<define-tag done whitespace=delete>
  <gettext domain="bugs">готов</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Включване на статус:</gettext>
  <label><input type="checkbox" name="pend-inc" value="pending"><отворен></label>
  <label><input type="checkbox" name="pend-inc" value="forwarded"><препратен></label>
  <label><input type="checkbox" name="pend-inc" value="pending-fixed"><нерешен></label>
  <label><input type="checkbox" name="pend-inc" value="fixed"><поправен></label>
  <label><input type="checkbox" name="pend-inc" value="done"><готов></label>
  </small></li>

  <li><small><gettext domain="bugs">Изключване на статус:</gettext>
  <label><input type="checkbox" name="pend-exc" value="pending"><отворен></label>
  <label><input type="checkbox" name="pend-exc" value="forwarded"><препратен></label>
  <label><input type="checkbox" name="pend-exc" value="pending-fixed"><нерешен></label>
  <label><input type="checkbox" name="pend-exc" value="fixed"><поправен></label>
  <label><input type="checkbox" name="pend-exc" value="done"><готов></label>
  </small></li>

<define-tag critical whitespace=delete>
  <gettext domain="bugs">критичен</gettext>
</define-tag>
<define-tag grave whitespace=delete>
  <gettext domain="bugs">опасен</gettext>
</define-tag>
<define-tag serious whitespace=delete>
  <gettext domain="bugs">сериозен</gettext>
</define-tag>
<define-tag important whitespace=delete>
  <gettext domain="bugs">важен</gettext>
</define-tag>
<define-tag normal whitespace=delete>
  <gettext domain="bugs">нормален</gettext>
</define-tag>
<define-tag minor whitespace=delete>
  <gettext domain="bugs">маловажен</gettext>
</define-tag>
<define-tag wishlist whitespace=delete>
  <gettext domain="bugs">желан</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Включване на критичност:</gettext>
  <label><input type="checkbox" name="sev-inc" value="critical"><критичен></label>
  <label><input type="checkbox" name="sev-inc" value="grave"><опасен></label>
  <label><input type="checkbox" name="sev-inc" value="serious"><важен></label>
  <label><input type="checkbox" name="sev-inc" value="important"><важен></label>
  <label><input type="checkbox" name="sev-inc" value="normal"><нормален></label>
  <label><input type="checkbox" name="sev-inc" value="minor"><маловажен></label>
  <label><input type="checkbox" name="sev-inc" value="wishlist"><желан></label>
  <label><input type="checkbox" name="sev-inc" value="fixed"><поправен></label>
  </small></li>

  <li><small><gettext domain="bugs">Изключване на критичност:</gettext>
  <label><input type="checkbox" name="sev-exc" value="critical"><критичен></label>
  <label><input type="checkbox" name="sev-exc" value="grave"><опасен></label>
  <label><input type="checkbox" name="sev-exc" value="serious"><сериозен></label>
  <label><input type="checkbox" name="sev-exc" value="important"><важен></label>
  <label><input type="checkbox" name="sev-exc" value="normal"><нормален></label>
  <label><input type="checkbox" name="sev-exc" value="minor"><маловажен></label>
  <label><input type="checkbox" name="sev-exc" value="wishlist"><желан></label>
  <label><input type="checkbox" name="sev-exc" value="fixed"><поправен></label>
  </small></li>

# distributions in the usual order, then other tags alphabetically
<define-tag potato whitespace=delete>
  <gettext domain="bugs">potato</gettext>
</define-tag>
<define-tag woody whitespace=delete>
  <gettext domain="bugs">woody</gettext>
</define-tag>
<define-tag sarge whitespace=delete>
  <gettext domain="bugs">sarge</gettext>
</define-tag>
<define-tag sarge-ignore whitespace=delete>
  <gettext domain="bugs">sarge-ignore</gettext>
</define-tag>
<define-tag etch whitespace=delete>
  <gettext domain="bugs">etch</gettext>
</define-tag>
<define-tag etch-ignore whitespace=delete>
  <gettext domain="bugs">etch-ignore</gettext>
</define-tag>
<define-tag sid whitespace=delete>
  <gettext domain="bugs">sid</gettext>
</define-tag>
<define-tag experimental whitespace=delete>
  <gettext domain="bugs">experimental</gettext>
</define-tag>
<define-tag confirmed whitespace=delete>
  <gettext domain="bugs">потвърден</gettext>
</define-tag>
<define-tag d-i whitespace=delete>
  <gettext domain="bugs">d-i</gettext>
</define-tag>
# 'fixed' is defined above
<define-tag fixed-in-experimental whitespace=delete>
  <gettext domain="bugs">поправен-в-experimental</gettext>
</define-tag>
<define-tag fixed-upstream whitespace=delete>
  <gettext domain="bugs">поправен-от-автора</gettext>
</define-tag>
<define-tag help whitespace=delete>
  <gettext domain="bugs">помощ</gettext>
</define-tag>
<define-tag l10n whitespace=delete>
  <gettext domain="bugs">l10n</gettext>
</define-tag>
<define-tag moreinfo whitespace=delete>
  <gettext domain="bugs">повече-инфо</gettext>
</define-tag>
<define-tag patch whitespace=delete>
  <gettext domain="bugs">патч</gettext>
</define-tag>
# 'pending' is defined above
<define-tag security whitespace=delete>
  <gettext domain="bugs">сигурност</gettext>
</define-tag>
<define-tag unreproducible whitespace=delete>
  <gettext domain="bugs">нерепродуцируем</gettext>
</define-tag>
<define-tag upstream whitespace=delete>
  <gettext domain="bugs">авторски</gettext>
</define-tag>
<define-tag wontfix whitespace=delete>
  <gettext domain="bugs">пожелан</gettext>
</define-tag>
<define-tag ipv6 whitespace=delete>
  <gettext domain="bugs">ipv6</gettext>
</define-tag>
<define-tag lfs whitespace=delete>
  <gettext domain="bugs">lfs</gettext>
</define-tag>

  <li><small><gettext domain="bugs">Включване на таг:</gettext>
  <label><input type="checkbox" name="include" value="potato"><potato></label>
  <label><input type="checkbox" name="include" value="woody"><woody></label>
  <label><input type="checkbox" name="include" value="sarge"><sarge></label>
  <label><input type="checkbox" name="include" value="sarge-ignore"><sarge-ignore></label>
  <label><input type="checkbox" name="include" value="sid"><sid></label>
  <label><input type="checkbox" name="include" value="experimental"><experimental></label>
  <label><input type="checkbox" name="include" value="confirmed"><потвърден></label>
  <label><input type="checkbox" name="include" value="d-i"><d-i></label>
  <label><input type="checkbox" name="include" value="fixed"><поправен></label>
  <label><input type="checkbox" name="include" value="fixed-in-experimental"><поправен-в-experimental></label>
  <label><input type="checkbox" name="include" value="fixed-upstream"><поправен-от-автора></label>
  <label><input type="checkbox" name="include" value="help"><помощ></label>
  <label><input type="checkbox" name="include" value="l10n"><l10n></label>
  <label><input type="checkbox" name="include" value="moreinfo"><повече-инфо></label>
  <label><input type="checkbox" name="include" value="patch"><патч></label>
  <label><input type="checkbox" name="include" value="pending"><нерешен></label>
  <label><input type="checkbox" name="include" value="security"><сигурност></label>
  <label><input type="checkbox" name="include" value="unreproducible"><нерепродуцируем></label>
  <label><input type="checkbox" name="include" value="upstream"><авторски></label>
  <label><input type="checkbox" name="include" value="wontfix"><пожелан></label>
  <label><input type="checkbox" name="include" value="ipv6"><ipv6></label>
  <label><input type="checkbox" name="include" value="lfs"><lfs></label>
  </small></li>

  <li><small><gettext domain="bugs">Изкючване на таг:</gettext>
  <label><input type="checkbox" name="exclude" value="potato"><potato></label>
  <label><input type="checkbox" name="exclude" value="woody"><woody></label>
  <label><input type="checkbox" name="exclude" value="sarge"><sarge></label>
  <label><input type="checkbox" name="exclude" value="sarge-ignore"><sarge-ignore></label>
  <label><input type="checkbox" name="exclude" value="sid"><sid></label>
  <label><input type="checkbox" name="exclude" value="experimental"><experimental></label>
  <label><input type="checkbox" name="exclude" value="confirmed"><confirmed></label>
  <label><input type="checkbox" name="exclude" value="d-i"><d-i></label>
  <label><input type="checkbox" name="exclude" value="fixed"><fixed></label>
  <label><input type="checkbox" name="exclude" value="fixed-in-experimental"><поправен-в-experimental></label>
  <label><input type="checkbox" name="exclude" value="fixed-upstream"><поправен-от-автора></label>
  <label><input type="checkbox" name="exclude" value="help"><помощ></label>
  <label><input type="checkbox" name="exclude" value="l10n"><l10n></label>
  <label><input type="checkbox" name="exclude" value="moreinfo"><повече-инфо></label>
  <label><input type="checkbox" name="exclude" value="patch"><патч></label>
  <label><input type="checkbox" name="exclude" value="pending"><нерешен></label>
  <label><input type="checkbox" name="exclude" value="security"><сигурност></label>
  <label><input type="checkbox" name="exclude" value="unreproducible"><нерепродуцируем></label>
  <label><input type="checkbox" name="exclude" value="upstream"><авторски></label>
  <label><input type="checkbox" name="exclude" value="wontfix"><пожелан></label>
  <label><input type="checkbox" name="exclude" value="ipv6"><ipv6></label>
  <label><input type="checkbox" name="exclude" value="lfs"><lfs></label>
  </small></li>

</ul>
