#use wml::debian::common_tags
#use wml::debian::submenu

<bind-gettext-domain domain="others" />

<define-menu-item name="newmaint">
  <gettext domain="others">K±cik nowych opiekunów</gettext>
</define-menu-item>

<define-menu-item name="step1"><gettext domain="others">Krok 1</gettext></define-menu-item>
<define-menu-item name="step2"><gettext domain="others">Krok 2</gettext></define-menu-item>
<define-menu-item name="step3"><gettext domain="others">Krok 3</gettext></define-menu-item>
<define-menu-item name="step4"><gettext domain="others">Krok 4</gettext></define-menu-item>
<define-menu-item name="step5"><gettext domain="others">Krok 5</gettext></define-menu-item>

<define-menu-item name="nm-checklist">
  <gettext domain="others">Lista kwalifikacyjna kandydata</gettext>
</define-menu-item>

<menu-item name="newmaint" basename="newmaint">
<menu-item name="nm-checklist" basename="nm-checklist">
<menu-item name="step1" basename="nm-step1">
<menu-item name="step2" basename="nm-step2">
<menu-item name="step3" basename="nm-step3">
<menu-item name="step4" basename="nm-step4">
<menu-item name="step5" basename="nm-step5">
