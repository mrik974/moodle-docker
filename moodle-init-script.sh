#!/bin/bash

moosh maintenance-on

moosh config-set langmenu 0 core # Enlève à l'utilisateur la possibilité de choisir sa langue
moosh config-set lang fr core # Sélectionne le français comme langue par défaut (ne fonctionne que si la langue est déjà installée)
moosh config-set autolang 0 core # désactive la détection du langage du navigateur

cd auth # va vers les plugins auth
curl https://moodle.org/plugins/download.php/19424/auth_oidc_moodle36_2018120300.zip -o oidc.zip # télécharge le plugin oidc
unzip oidc.zip # dézip du plugin oidc

cd .. # retour arrière

php admin/cli/check_database_schema.php # check si les schemas de base de données sont à jour
php admin/cli/upgrade.php --non-interactive # met à jour la configuration et la base de données

moosh auth-manage enable oidc #. Active le plugin oidc mais ne le configure pas encore
moosh auth-manage disable email # désactive le login via email

# Configuration de base du plugin OIDC. Il manquera la conf de l'image, là, je sais pas comment m'y prendre…

moosh config-set opname "Madelink Identity" auth_oidc
moosh config-set clientid moodle auth_oidc
moosh config-set clientsecret $OIDC_SECRET auth_oidc
moosh config-set authendpoint "https://identity.apps.dev.madelink.fr/auth/realms/master/protocol/openid-connect/auth" auth_oidc
moosh config-set tokenendpoint "https://identity.apps.dev.madelink.fr/auth/realms/master/protocol/openid-connect/token" auth_oidc
moosh config-set oidcresource "https://identity.apps.dev.madelink.fr/auth/realms/master/protocol/openid-connect/userinfo" auth_oidc
# moosh config-set userrestrictions "restrictions" auth_oidc # Inclure ici les possibles restrictions d'utilisateurs

moosh config-set authpreventaccountcreation 1 core # désactive la création de compte utilisateur au login
moosh config-set guestloginbutton 0 core # désactive le guest login
	
cd mod # va dans le dossier des modules
curl -o hvp.zip https://moodle.org/plugins/download.php/19594/mod_hvp_moodle37_2019052100.zip
php admin/cli/upgrade.php --non-interactive

# TROUVER UN MOYEN DE TELECHARGER LES SOUS MODULES H5P UTILES (ou laisser hvp le faire tout seul au besoin…)

moosh config-set send_usage_statistics 0 mod_hvp # désactive l'envoi de stats à h5P
moosh config-set export 0 mod_hvp # désactive l'export de modules
moosh config-set embed 0 mod_hvp # désactive les possibilités d'embed
moosh config-set icon 0 mod_hvp # désactive le "about h5p"

moosh maintenance-off
