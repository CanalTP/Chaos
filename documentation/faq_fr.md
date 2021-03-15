# FAQ Chaos

## Erreur 400 lors de ma première requête POST.
Verifiez la présence de content-type "application/json" votre le header.

## Quelle est la difference entre `application_period` et `publication_period` ?
La publication_period est au niveau de la perturbation, et indique à partir de quand les impacts qu'elle contient seront remontées dans Navitia, à la disposition des voyageurs.
L'application_period est au niveau de l'impact, et indique quand l'impact se produit réellement.
Exemple: Une ligne peut être arrétée le 21 Juin pour la fête de la musique (application_date) mais on voudra sans doute en informer les voyageurs bien avant (publication_period).

## Qu'est ce qu'une `application_period_pattern` ?
L'application_period_pattern est une alternative à l'application_period d'un impact.
Cela permets de donner une plage de date, une plage horaire et des jours, et demander à ce que Chaos déduise lui-même les periodes d'application sans avoir à lui fournir les dates specifiques.
Ainsi on peut demander à Chaos d'impacter tel objet "Entre le 1 Janvier et le 1 Avril, tous les Samedi et Dimanche, entre 10h et 14h".

## Qu'est ce qu'une category ?
Une category est un moyen de rassembler plusieurs causes sous un même etendard.
Cela permets de faciliter la selection dans une IHM s'il existe un très grand nombre de causes.

## Comment fonctionnent les properties ?
Une property est une serie de couple key/value attachée à une disruption.
Ces key/value sont au libre choix de l'intégrateur, et seront remontées dans le flux Navitia pour être utilisés par des médias Front.
Il est important de noter que ces properties sont liées à la disruption et non à l'impact: les impacts d'une disruption auront donc les mêmes properties.

## Quelle est la difference entre un `impact` et une `disruption` ?
D'un point de vue d'usage, une `disruption` sert à réunir un ou plusieurs `impacts` provoqués par un même problème.
La `disruption` porte la date de publication. Un `impact` contient lui les dates d'application, les objets impactés, la sévérité, et les messages.

## Correspondance `disruptions` et `impacts` de Chaos à Navitia ?
Chaque `impact` dans Chaos génère une `disruption` dans Navitia.
</br>L'identifiant d'un `impact` Chaos correspond donc à l'identifiant d'une `disruption` Navitia.

## Dans l'attribut `meta` des `messages`, quels sont les couples key/Value possibles ?
Son usage est relativmeent libre, justement pour permettre à d'autres applications utilisant Chaos d'y ajouter des informations qui lui seraient utiles.
</br>Par exemple dans l'IHM TrafficReport Kisio Digital, nous utilisons la key `subject` pour donner un sujet aux messages de type `email`.

## A quoi servent les attributs de la `severity` ?
Seul l'attribut EFFECT a un réel impact dans Navitia: il determine si l'impact provoque une interruption de service ou des délais.
Les autres attributs remontent dans le flux Navitia et aident à l'affichage dans une IHM ou un média si l'integrateur le souhaite (exemple: la couleur).

## Qu'est ce qu'une `line_section` ?
La line_section est un objet composé de Chaos qui n'existe pas en tant que tel dans les données.
La line_section permets d'impacter une partie d'une ou plusieurs lignes entre deux zones d'arrêt qui peuvent être identiques, dans une direction en particulier.
Nous avons ainsi une ligne X avec les arrêts A, B, C, D, E, F, G. En raison d'un évènement, les arrêts C, D, E, F de cette ligne ne seront plus desservis.
La line_section permets de dire que la ligne X est impacté de C vers F.
Quand Navitia reçoit cet impact, il peut en déduire que les routes de la ligne X passant d'abord par C puis F sont touchées, et uniquement entre C et F (compris).
Il est possible de donner une ou plusieurs routes, dans lequel cas Navitia ne déduira pas de lui-même les routes impactées, il prendra celles données par Chaos.
La line_section est passante, c'est à dire qu'un impact entre C et F n'empechera pas le vehicule de faire son trajet complet de A vers G.
https://github.com/CanalTP/navitia/blob/dev/documentation/rfc/line_sections.md

## La ligne X ne desservira pas l'arrêt D : j'ai fais un impact sur le point d'arrêt D mais il remonte dans le flux Navitia pour la ligne Y. Pourquoi?
Cet arrêt sert de desserte pour les lignes X et Y. Un impact sur cet arrêt pénalise donc les deux lignes.
Pour que cet arrêt ne remonte que pour la ligne X, il faut faire une line_section pour cette ligne sur cet arrêt particulier: de D vers D pour la ligne X.
Grace à la line_section, Navitia ne remontera l'impact que pour les itineraires de la ligne X où le voyageur descends / monte à l'arrêt D.

## Combien de temps faut-il a Navitia pour integrer un impact ?
A chaque reception de perturbation, Navitia recalcule les effets de l'impact. Cela peut prendre entre 30 secondes et 2 minutes en production.

## Un média 'front' peut-il utiliser directement Chaos pour connaître l'Information Voyageurs ?
Non, Chaos est un composant d'une chaine d'outils backoffice. Les medias 'front' doivent requêter Navitia pour obtenir cette information.

## Dans un impact, à quoi servent les attributs `notification_date` et `send_notification` ?
Ce sont des attributs destinés à des applications tierces d'envois de notification, au libre choix des integrateurs.
Dans notre propre applicatif, send_notification indique que l'impact doit generer des envois de notification, et notification_date a quelle date cela doit être fait.


