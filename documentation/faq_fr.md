# FAQ Chaos

Pour rappel, Chaos est une API d'alimentation de  [Navitia](https://github.com/CanalTP/navitia) en [disruptions](http://doc.navitia.io/#traffic-reports).

## Erreur 400 lors de ma première requête POST ?
Vérifiez la présence de content-type "application/json" dans votre header.

## Quelle est la différence entre un `impact` et une `disruption` ?
Une `disruption` sert à réunir un ou plusieurs `impacts` provoqués par un même problème.
La `disruption` porte la date de publication. Un `impact` contient lui les dates d'application, les objets impactés, la sévérité, et les messages.

## Correspondance `impacts` et `disruptions` entre Chaos à Navitia ?
Chaque `impact` dans Chaos génère une `disruption` dans Navitia.
<br>L'identifiant d'un `impact` Chaos correspond donc à l'identifiant d'une `disruption` Navitia.

## Quelle est la différence entre `application_period` et `publication_period` ?
La `publication_period` est au niveau de la perturbation et indique à partir de quand le ou les impacts qu'elle contient seront remontés dans Navitia et à la disposition des voyageurs.
L'`application_period` est au niveau de l'impact et indique sa date de début réel.
Exemple: Une ligne peut être arrêtée le 21 Juin pour la fête de la musique (`application_date`) mais on voudra sans doute en informer les voyageurs bien avant (`publication_period`).

## Qu'est ce qu'`application_period_pattern` ?
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
<br>Par exemple dans l'IHM Traffic Report Kisio Digital, la key `subject` est utilisée pour donner un sujet aux messages de type `email`.

## Comment sont utilisés les attributs de la `severity` ?
Tous les attributs remontent dans le flux Navitia. Un intégrateur peut par exemple afficher son intitulé et/ou sa couleur dans une IHM ou un média.<br>
Par contre seul l'attribut `EFFECT` a un réel impact dans les calculs Navitia, pour déclencher une interruption de service, des délais ou simplement afficher une information. Précisions : [real-time-integration-in-navita](http://doc.navitia.io/#real-time-integration-in-navita) 

## Qu'est ce qu'une `line_section` ?
`line_section` est un objet composé dans Chaos qui n'existe pas en tant que tel dans les données transport.
Une `line_section` permet d'impacter une partie d'une ou plusieurs lignes entre deux zones d'arrêt, dans une direction en particulier. Note : les deux zones d'arrêt peuvent être identiques, ce qui influera sur sa prise en charge par Navitia.
<br>Exemple une ligne 42 avec les arrêts A, B, C, D, E, F, G. En raison d'un évènement, les arrêts C, D, E, F de cette ligne ne seront plus desservis.
Utiliser une `line_section` permet d'impacter la ligne 42 de C vers F.
<br>À la prise en charge de cet impact, Navitia va déduire que les routes de la ligne 42 passant d'abord par C puis F sont touchées (et uniquement les routes entre C et F, arrêts compris).
<br>Si un intégrateur souhaite impacter une liste de routes spécifiques, il peut les renseigner dans l'attribut `routes`. Navitia ne surchargera pas cette liste de `routes` et calculera les itinéraires touchés en fonction de celles qui ont été fournies.
<br>Une `line_section` est 'passante', c'est à dire qu'un impact entre C et F n’empêchera pas un trajet de A vers G. cf [Navitia > line_sections](https://github.com/CanalTP/navitia/blob/dev/documentation/rfc/line_sections.md)

## Comment ne perturber un point d'arrêt que pour une seule ligne s'il est desservi par plusieurs autres lignes ?
Exemple un arrêt D est desservi par les lignes 42 et  69. Un évènement à cet arrêt ne concernera que la ligne 42.
- si vous créez un impact sur le point d'arrêt D, Navitia remontera l'évènement pour toutes les lignes passant par cet arrêt lignes 42 et  69.
- en créant un impact `line_section` pour la ligne 42 de l'arrêt D à l'arrêt D, Navitia remontera l’évènement précisément pour les itinéraires de la ligne 42 où le voyageur monte ou descend à l'arrêt D.

## Combien de temps faut-il a Navitia pour intégrer un `impact` ?
Il peut s'écouler de 30 secondes à 2 minutes entre une création dans Chaos et la publication dans Navitia. Le temps de calculer tous les effets générés par l'impact.

## Dans un impact, à quoi servent les attributs `notification_date` et `send_notification` ?
Ce sont des attributs destinés à des applications tierces d'envois de notification, au libre choix des intégrateurs.
Dans notre propre applicatif, send_notification indique que l'impact doit générer des envois de notification, et notification_date a quelle date cela doit être fait.

## Un média 'front' peut-il utiliser directement Chaos pour connaître l'Information Voyageurs ?
Non, Chaos est un composant d'une chaîne d'outils back-office. Les medias 'front' doivent requêter Navitia pour obtenir cette information.
