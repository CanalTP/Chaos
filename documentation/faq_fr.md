# FAQ Chaos

Pour rappel, Chaos est une API d'alimentation de  [Navitia](https://github.com/CanalTP/navitia) en [disruptions](http://doc.navitia.io/#traffic-reports).
## Erreur 400 lors de ma première requête POST ?
Vérifiez la présence de content-type "application/json" dans votre le header.

## Quelle est la différence entre `application_period` et `publication_period` ?
La `publication_period` est au niveau de la perturbation et indique à partir de quand le ou les impacts qu'elle contient seront remontés dans Navitia et à la disposition des voyageurs.
L'`application_period` est au niveau de l'impact et indique sa date de début réel.
Exemple: Une ligne peut être arrêtée le 21 Juin pour la fête de la musique (`application_date`) mais on voudra sans doute en informer les voyageurs bien avant (`publication_period`).

## Qu'est ce qu'une `application_period_pattern` ?
L'`application_period_pattern` est une alternative à `application_period` d'un impact.
Cela permet de donner une plage de date, une plage horaire et des jours. Chaos calculera automatiquement les dates exactes des périodes d'application.
Exemple : Arrêter une ligne en travaux "Entre le 1 Janvier et le 1 Avril, tous les Samedi et Dimanche, entre 6h et 12h".

## Qu'est ce que `category` ?
Cette propriété permet de rassembler plusieurs causes sous un même étendard.
Par exemple pour faciliter la présélection de causes dans une IHM quand il en existe un très grand nombre.

## Comment fonctionnent les `properties` dans une `disruption`?
Une `property` est une série de couple key/value attachée à une `disruption`.
Ces key/value sont au libre choix de l'intégrateur pour permettre à d'autres applications d'avoir accès à des informations supplémentaires.
Il est important de noter que ces `properties` sont liées à la `disruption` Chaos et non à l'`impact`, tous les impacts d'une même disruption auront donc les mêmes `properties` dans Navitia.

## Dans l'attribut `meta` d'un message, quels sont les couples key/Value possibles ?
`meta` est une série de couple key/value attachée à un message contenu dans un `impact`.
Ces key/value sont au libre choix de l'intégrateur pour permettre à d'autres applications d'avoir accès à des informations supplémentaires.
</br>Par exemple dans l'IHM Traffic Report Kisio Digital, la key `subject` est utilisée pour donner un sujet aux messages de type `email`.

## Quelle est la différence entre un `impact` et une `disruption` ?
Une `disruption` sert à réunir un ou plusieurs `impacts` provoqués par un même problème.
La `disruption` porte la date de publication. Un `impact` contient lui les dates d'application, les objets impactés, la sévérité, et les messages.

## Correspondance `disruptions` et `impacts` de Chaos à Navitia ?
Chaque `impact` dans Chaos génère une `disruption` dans Navitia.
</br>L'identifiant d'un `impact` Chaos correspond donc à l'identifiant d'une `disruption` Navitia.


## A quoi servent les attributs de la `severity` ?
Seul l'attribut EFFECT a un réel impact dans Navitia: il determine si l'impact provoque une interruption de service ou des délais.
Les autres attributs remontent dans le flux Navitia et aident à l'affichage dans une IHM ou un média si l’intégrateur le souhaite (exemple: la couleur).

## Qu'est ce qu'une `line_section` ?
`line_section` est un objet composé dans Chaos qui n'existe pas en tant que tel dans les données transport.
Une `line_section` permet d'impacter une partie d'une ou plusieurs lignes entre deux zones d'arrêt qui peuvent être identiques, dans une direction en particulier.
Nous avons ainsi une ligne X avec les arrêts A, B, C, D, E, F, G. En raison d'un évènement, les arrêts C, D, E, F de cette ligne ne seront plus desservis.
La `line_section` permets de dire que la ligne X est impacté de C vers F.
Quand Navitia reçoit cet impact, il peut en déduire que les routes de la ligne X passant d'abord par C puis F sont touchées, et uniquement entre C et F (compris).
Il est possible de donner une ou plusieurs routes, dans lequel cas Navitia ne déduira pas de lui-même les routes impactées, il prendra celles données par Chaos.
La `line_section` est passante, c'est à dire qu'un impact entre C et F n’empêchera pas le véhicule de faire son trajet complet de A vers G.
https://github.com/CanalTP/navitia/blob/dev/documentation/rfc/line_sections.md

## La ligne X ne desservira pas l'arrêt D : j'ai fais un impact sur le point d'arrêt D mais il remonte dans le flux Navitia pour la ligne Y. Pourquoi?
Cet arrêt sert de desserte pour les lignes X et Y. Un impact sur cet arrêt pénalise donc les deux lignes.
Pour que cet arrêt ne remonte que pour la ligne X, il faut faire une line_section pour cette ligne sur cet arrêt particulier: de D vers D pour la ligne X.
Grace à la line_section, Navitia ne remontera l'impact que pour les itinéraires de la ligne X où le voyageur descends / monte à l'arrêt D.

## Combien de temps faut-il a Navitia pour intégrer un `impact` ?
Il peut s'écouler de 30 secondes à 2 minutes entre une création dans Chaos et la publication dans Navitia. Le temps de calculer tous les effets générés par l'impact dans les données de transport.

## Un média 'front' peut-il utiliser directement Chaos pour connaître l'Information Voyageurs ?
Non, Chaos est un composant d'une chaîne d'outils back-office. Les medias 'front' doivent requêter Navitia pour obtenir cette information.

## Dans un impact, à quoi servent les attributs `notification_date` et `send_notification` ?
Ce sont des attributs destinés à des applications tierces d'envois de notification, au libre choix des intégrateurs.
Dans notre propre applicatif, send_notification indique que l'impact doit générer des envois de notification, et notification_date a quelle date cela doit être fait.