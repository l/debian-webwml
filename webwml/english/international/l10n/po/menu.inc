#use wml::debian::submenu
#use wml::debian::language_names

# Please keep slices sorted alphabetically so it's easier to detect
# languages in them (except english ones).

<define-tag-sliced menu-l10n whitespace=delete>
   [EN:L10n:]
   [DA:Lokaltilpasning:]
   [DE:Lokalisierung:]
   [SV:Lokalanpassning:]
</define-tag-sliced>

<define-tag-sliced menu-list whitespace=delete>
   [EN:Language list:]
   [DA:Liste over sprog:]
   [DE:Sprachen-Liste:]
   [FR:Liste des langues:]
   [SV:Lista över språk:]
</define-tag-sliced>

<define-tag-sliced menu-rank whitespace=delete>
   [EN:Ranking:]
   [DA:Placering:]
   [DE:Reihung:]
   [FR:Classement:]
   [SV:Rankning:]
</define-tag-sliced>

<define-tag-sliced menu-todo whitespace=delete>
   [EN:Todo:]
   [DA:Skal gøres:]
   [DE:Noch zu tun:]
   [SV:Att göra:]
</define-tag-sliced>

<define-menu-item name="l10n"><menu-l10n></define-menu-item>
<define-menu-item name="list"><menu-list></define-menu-item>
<define-menu-item name="rank"><menu-rank></define-menu-item>
<define-menu-item name="todo"><menu-todo></define-menu-item>

<menu-item name="l10n"          basename="../index">
<menu-item name="list"          basename="index">
<menu-item name="rank"          basename="rank">
<menu-item name="todo"          basename="todo">

