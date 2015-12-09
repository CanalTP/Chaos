FORMAT: 1A
HOST: https://ogv2ws.apiary-mock.com

Version du document: 2.1
Date de derniére modification: 30/10/2014

#Web Services Ogesper v2
Les web Services Ogesper v2 permettent la gestion des perturbations sur un référentiel de transport.
Les entités manipulées par le web service sont:

   - les perturbations (disruptions), qui représentent toutes situations affectant positivement ou négativement le réseau de transport.
   - les impacts (impacts), qui représentent toute application d'une perturbation sur une entité du référentiel de transport (ligne, zone d'arrêt, ...).
   - les sévérités, ou conséquences (severities), qui représentent les conséquences d'un impact sur l'entité du référentiel affectée (bloquant, information, ...)
   - les causes, ou motif (causes), qui représentent les origine de la perturbation (obstacle sur les voies, accident de voyageur, ...)
   - les tags (tags), qui permettent de tager des perturbations (rer, meteo, probleme, ...)
   - les canaux de diffusion (channels), qui représentent les medias vers lesquels les informations seront transmises.
   - les types de canal de diffusion (channel_types), qui représentent les modes de communications destinés.

Pour chacune des entités présentées, les web services proposent les fonctions de création, suppression, édition, liste, et recherche unitaire. Sauf mention contraire, seules les fonctions de liste et de recherche sont proposées à l'implémentation.

L'ensemble des services retournent les URLs nécessaires à une séquence d'appel. Par exemple, l'API disruptions retourne une URL permettant d'accéder au détail de chaque perturbation retournée (attribut "self"), des liens vers la liste des impacts de la perturbation ("impacts"); il est donc inutile de retravailler les paramètres d'appels côté media entre deux interrogations.
Dans ce document, toutes les sections décrivent les différents points d'entrée.

Dans chacune des APIs il est décrit les méthodes http qui sont implémentées

En général les APIs implémentent sur les méthodes GET la pagination.
On peut alors préciser le numéro de la page demandé avec le paramètre start_page, puis préciser le
nombre d'items que l'on veut par page à l'aide du paramètre items_per_page.

Certaines des urls contiennent des places holders, ils sont contenus entre ```{ }```,
il faudra remplacer, ```{}```, par une valeur.
Exemple : ```/disruptions/{disruption_id}/impacts```
Cette url n'est pas valide, il faut remplacer ```{disruption_id}``` par un id de
disruption valide.


Les différents concepts manipulés sont présentés dans la diagramme suivant:

![schema conceptuel](https://raw.githubusercontent.com/CanalTP/Chaos/master/documentation/Conceptuel.jpg?token=AAbWuaL-akym2v2qwvhG2Tm-DwxVFMgYks5UWxsnwA%3D%3D)


La gestion des erreurs est embryonaire, en cas d'erreur technique une réponse de type 500 est retourné sans plus d'information.
Si il est fait référence à une resources qui n'existe pas (ou plus), que ce soit dans les URL, ou dans le json de création/modfication une réponse de type 404 est retournée.
Enfin, en cas de paramétre non valide, y compris un json ne respestant pas les contraintes définies, une réponse de type 400 est retourné, celle ci contient un message textuel précisant l'erreur.

# Racine [/]
##Récupérer la liste des API [GET]

- response 200 (application/json)
    * Body

            {
                "disruptions": {"href": "https://ogv2ws.apiary-mock.com/disruptions"},
                "disruption": {"href": "https://ogv2ws.apiary-mock.com/disruptions/{id}", "templated": true},
                "severities": {"href": "https://ogv2ws.apiary-mock.com/severities"},
                "causes": {"href": "https://ogv2ws.apiary-mock.com/causes"},
                "channels": {"href": "https://ogv2ws.apiary-mock.com/channels"},
                "tags": {"href": "https://ogv2ws.apiary-mock.com/tags"},
                "categories": {"href": "https://chaos.apiary-mock.com/categories"},
                "channeltypes": {"href": "http://127.0.0.1:5000/channel_types"}
            }


##Headers

| Name                 | description                                                                       | required | default                 |
| -------------------- | --------------------------------------------------------------------------------- | -------- | ----------------------- |
| Content-Type         | type du texte                                                                     | true     | application/json        |
| Authorization        | token pour avoir accès aux services navitia                                       | true     |                         |
| X-Customer-Id        | client code. Les données référentielles comme cause, channel sont liées au client | true     |                         |
| X-Contributors       | contributor code. Un disruption est lié au contributor                            | true     |                         |
| X-Coverage           | coverage des services navitia                                                     | true     |                         |


# Liste des perturbations [/disruptions]

##Récupérer les disruptions [GET]
Retourne la liste de toutes les perturbations visibles.
##Paramètres

| Name                 | description                                                                               | required | default                 |
| -------------------- | ----------------------------------------------------------------------------------------- | -------- | ----------------------- |
| start_page           | Numéro de la page (commence par 1)                                                        | false    | 1                       |
| items_per_page       | Nombre d'items par page                                                                   | false    | 20                      |
| publication_status[] | Filtre sur publication_status,  les valeurs possibles sont : past, ongoing, coming        | false    | [past, ongoing, coming] |
| current_time         | Permet de changer l'heure d'appel, sert surtout pour le debug                             | false    | NOW                     |
| tag[]                | filtre sur tag (identifiant du tag)                                                       | false    |                         |
| uri                  | filtre sur uri de l'objet TC                                                              | false    |                         |

Le paramétre ```publication_status``` permet, par rapport à l'heure de référence passée en paramètre, de retourner les perturbations en cours (c'est à dire ayant des dates/heures de publications encadrant la date/heure de référence), à venir (qui ont des dates/heures de publications postérieures à la date/heure de référence) ou passées (ayant des dates/heures de publications antérieures à la date/heure de référence).

L'attribut ```status``` des disruptions ne peut actuellement prendre qu'une seule valeurs: ```published```.

L'attribut ```publication_status``` des disruptions correspond à l'énumération ```DisruptionStatus``` du schéma ci dessus.

Le champs ```impacts``` contient un objet de pagination contenant les liens vers la liste des impacts.

Le champs ```cause``` contient un objet cause de la perturbation.

Le champs ```localization``` contient un objet localisation de la perturbation.

Le champs ```tags``` contient une liste de tag de la perturbation.

##Example
- response 200 (application/json)

    * Body

            {
                "disruptions": [
                    {
                        "id": "d30502d2-e8de-11e3-8c3e-0008ca8657ea",
                        "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea"},
                        "reference": "RER B en panne",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "note": "blablbla",
                        "status": "published",
                        "publication_status": "ongoing",
                        "contributor": "shortterm.tn",
                        "version": 1,
                        "publication_period" : {
                            "begin":"2014-04-31T17:00:00Z",
                            "end":"2014-05-01T17:00:00Z"
                        },
                        tags": [
                            {
                                "created_at": "2014-07-30T07:11:08Z",
                                "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                                "name": "rer",
                                "self": {
                                    "href": "http://127.0.0.1:5000/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                                },
                                "updated_at": null
                            }
                        ],
                        "impacts": {
                            "pagination": {
                                "start_page": 0,
                                "items_per_page": 20,
                                "total_results": 3,
                                "prev": null,
                                "next": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                                "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                                "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"}
                            }
                        }
                    },
                    {
                        "id": "d30502d2-e8de-11e3-8c3e-0008ca8657eb",
                        "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb"},
                        "reference": "RER A en panne",
                        "created_at": "2014-05-31T16:52:18Z",
                        "updated_at": null,
                        "note": null,
                        "status": "published",
                        "publication_status": "coming",
                        "contributor": "shortterm.tn",
                        "publication_period" : {
                            "begin": "2014-04-31T17:00:00Z",
                            "end": null
                        },
                        tags": [
                            {
                                "created_at": "2014-07-30T07:11:08Z",
                                "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                                "name": "rer",
                                "self": {
                                    "href": "http://127.0.0.1:5000/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                                },
                                "updated_at": null
                            }
                        ],
                        "cause": {
                            "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"},
                            "created_at": "2014-07-21T14:06:23Z",
                            "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
                            "self": {
                                "href": "https://ogv2ws.apiary-mock.com/causes/32b07ff8-10e0-11e4-ae39-d4bed99855be"
                            },
                            "updated_at": null,
                            "wordings": [{"key": "key1", "value": "foo1"}]
                        },
                        "impacts": {
                            "pagination": {
                                "start_page": 0,
                                "items_per_page": 20,
                                "total_results": 5,
                                "prev": null,
                                "next": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb/impacts?start_page=1&item_per_page=20"},
                                "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb/impacts?start_page=1&item_per_page=20"},
                                "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb/impacts?start_page=1&item_per_page=20"}
                            }
                        },
                        "localization":[
                        {
                            "administrative_regions": [
                            {
                                "coord": {
                                        "lat": "48.04517157",
                                        "lon": "2.697975614"
                                },
                                "id": "admin:45104",
                                "level": 8,
                                "name": "Corquilleroy",
                                "zip_code": "45120"
                            }
                            ],
                            "comment": "",
                            "coord": {
                                "lat": "48.025",
                                "lon": "2.71639"
                            },
                            "id": "stop_area:MTD:SA:154",
                            "name": "Pichon",
                            "type": "stop_area"

                        }
                        ]
                    },
                    {
                        "id": "d30502d2-e8de-11e3-8c3e-0008ca8657ec",
                        "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec"},
                        "reference": "Chatelet fermé",
                        "created_at": "2014-05-17T16:52:18Z",
                        "update_at": "2014-05-31T06:55:18Z",
                        "note": "retour probable d'ici 5H",
                        "status": "published",
                        "publication_status": "past",
                        "contributor": "shortterm.tn",
                        "publication_period" : {
                            "begin": "2014-04-31T17:00:00Z",
                            "end": null
                        },
                        "cause": {

                            "created_at": "2014-07-21T14:06:23Z",
                            "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
                            "self": {
                                "href": "https://ogv2ws.apiary-mock.com//causes/32b07ff8-10e0-11e4-ae39-d4bed99855be"
                            },
                            "updated_at": null,
                            "wordings": [{"key": "key1", "value": "foo1"}],
                            "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
                        },
                        tags": [
                            {
                                "created_at": "2014-07-30T07:11:08Z",
                                "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                                "name": "rer",
                                "self": {
                                    "href": "http://127.0.0.1:5000/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                                },
                                "updated_at": null
                            }
                        ],
                        "impacts": {
                            "pagination": {
                                "start_page": 0,
                                "items_per_page": 20,
                                "total_results": 25,
                                "prev": null,
                                "next": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec/impacts?start_page=1&item_per_page=20"},
                                "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec/impacts?start_page=1&item_per_page=20"},
                                "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec/impacts?start_page=2&item_per_page=20"}
                            }
                        }
                    }

                ],
                "meta": {
                    "pagination": {
                        "start_page": 1,
                        "items_per_page": 3,
                        "total_results": 6,
                        "prev": null,
                        "next": {"href": "https://ogv2ws.apiary-mock.com/disruptions/?start_page=2&item_per_page=3"},
                        "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/?start_page=1&item_per_page=3"},
                        "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/?start_page=2&item_per_page=3"}
                    }
                }
            }

##Créer une perturbation [POST]

La création d'une perturbation est réalisé via une requéte ```POST``` à sur la resource ```disruptions```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une perturbation.

Les champs suivant peuvent etre défini:

  - reference (obligatoire)
  - contributor (obligatoire)
  - note
  - publication_period
  - localization
  - cause (obligatoire)
  - tags
  - impacts

Lors d'un succés une réponse 201 est retourné, celle ci contient la perturbation créée.

###Exemple
- Request (application/json)

    * Body

            {
                "reference": "foo",
                "contributor": "shortterm.tn",
                "note": null,
                "publication_period" : {
                    "begin": "2014-04-31T17:00:00Z",
                    "end": null
                },
                "localization":[{"id":"stop_area:JDR:SA:CHVIN", "type": "stop_area"}],
                "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},
                "tags":[{"id": "ad9d80ce-17b8-11e4-a553-d4bed99855be"}],
                "impacts":[{ "severity": {"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"},
                             "application_periods": [{"begin": "2014-04-31T16:52:00Z","end": "2014-05-22T02:15:00Z"}]
                          }]
            }



- response 201 (application/json)

    * Body

            {
                "disruption":{
                    "id": "3d1f32b2-e8df-11e3-8c3e-0008ca8657ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea"},
                    "reference": "foo",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null,
                    "note": null,
                    "status": "published",
                    "publication_status": "ongoing",
                    "contributor": "shortterm.tn",
                    "version": 1,
                    "publication_period" : {
                        "begin": "2014-04-31T17:00:00Z",
                        "end": null
                    },
                    "impacts": {
                        "pagination": {
                            "start_page": 1,
                            "items_per_page": 20,
                            "total_results": 1,
                            "prev": null,
                            "next": null,
                            "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/1/impacts?start_page=1&item_per_page=20"},
                            "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/1/impacts?start_page=1&item_per_page=20"}
                        }
                    },

                    "cause": {

                        "created_at": "2014-07-21T14:06:23Z",
                        "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com//causes/32b07ff8-10e0-11e4-ae39-d4bed99855be"
                        },
                        "updated_at": null,
                        "wordings": [{"key": "key1", "value": "foo1"}],
                        "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
                    },
                    "localization":[
                    {
                        "administrative_regions": [
                        {
                            "coord": {
                                    "lat": "48.04517157",
                                    "lon": "2.697975614"
                            },
                            "id": "admin:45104",
                            "level": 8,
                            "name": "Corquilleroy",
                            "zip_code": "45120"
                        }
                        ],
                        "comment": "",
                        "coord": {
                            "lat": "48.025",
                            "lon": "2.71639"
                        },
                        "id": "stop_area:MTD:SA:154",
                        "name": "Pichon",
                        "type": "stop_area"

                    }
                    ],
                    tags": [
                        {
                            "created_at": "2014-07-30T07:11:08Z",
                            "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                            "name": "rer",
                            "self": {
                                "href": "http://127.0.0.1:5000/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                            },
                            "updated_at": null
                        }
                    ]
                },
                "meta": {}
            }

- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'reference' is a required property"
                }
                "meta": {}
            }


# Disruptions [/disruptions/{id}]
##Récupérer une perturbation [GET]

Retourne une perturbation (si elle existe):

###Exemple
- response 200 (application/json)

    * Body

            {
                "disruption": {
                    "id": "3d1f32b2-e8df-11e3-8c3e-0008ca8657ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea"},
                    "reference": "RER B en panne",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "note": "blablbla",
                    "status": "published",
                    "publication_status": "ongoing",
                    "contributor": "shortterm.tn",
                    "version": 1,
                    "publication_period" : {
                        "begin": "2014-04-31T17:00:00Z",
                        "end": null
                    },
                    "impacts": {
                        "pagination": {
                            "start_page": 1,
                            "items_per_page": 20,
                            "total_results": 3,
                            "prev": null,
                            "next": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                            "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                            "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"}
                        }
                    },
                    "cause": {

                        "created_at": "2014-07-21T14:06:23Z",
                        "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com//causes/32b07ff8-10e0-11e4-ae39-d4bed99855be"
                        },
                        "updated_at": null,
                        "wordings": [{"key": "key1", "value": "foo1"}],
                        "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
                    },
                    "localization":[
                    {
                        "administrative_regions": [
                        {
                            "coord": {
                                    "lat": "48.04517157",
                                    "lon": "2.697975614"
                            },
                            "id": "admin:45104",
                            "level": 8,
                            "name": "Corquilleroy",
                            "zip_code": "45120"
                        }
                        ],
                        "comment": "",
                        "coord": {
                            "lat": "48.025",
                            "lon": "2.71639"
                        },
                        "id": "stop_area:MTD:SA:154",
                        "name": "Pichon",
                        "type": "stop_area"

                    }
                    ],
                    tags": [
                        {
                            "created_at": "2014-07-30T07:11:08Z",
                            "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                            "name": "rer",
                            "self": {
                                "href": "http://127.0.0.1:5000/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                            },
                            "updated_at": null
                        }
                    ]
                },
                "meta": {}
            }


- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No disruption"
                },
                "meta": {}
            }


##Mise à jour d'une perturbation [PUT]

La mise à jour d'une perturbation est réalisé via une requéte ```PUT``` à sur la resource ```disruptions```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une perturbation.

Les champs suivant peuvent etre mis à jour:

  - reference
  - contributor
  - note
  - publication_period
  - localization
  - cause
  - tags
  - impacts

Si un champs n'est pas présent dans le json la valeur est considéré null.

Lors d'un succés une réponse 200 est retourné, celle ci contient la perturbation modifiée.

###Exemple
- Request

    * Headers

            Content-Type: application/json
            Authorization: [navitia token]
            X-Customer-Id: [customer id]
            X-Contributors: [contributor id]
            X-Coverage: [navitia coverage]

    * Body

            {
                "reference": "foo",
                "contributor": "shortterm.tn",
                "note": null,
                "publication_period" : {
                    "begin": "2014-04-31T17:00:00Z",
                    "end": null
                },
                "localization":[{"id":"stop_area:AME:SA:104", "type": "stop_area"}],
                "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},
                "tags":[{"id": "ad9d80ce-17b8-11e4-a553-d4bed99855be"}],
                "impacts":[{ "severity": {"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"},
                             "application_periods": [{"begin": "2014-04-31T16:52:00Z","end": "2014-05-22T02:15:00Z"}]
                          },{ "id":"7ffab230-3d48-4eea-aa2c-22f8680230b6", "severity": {"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"},
                             "application_periods": [{"begin": "2014-04-31T16:52:00Z","end": "2014-05-22T02:15:00Z"}]
                          },"send_notifications": true]
            }


- Response 200 (application/json)

    * Body

            {
                "disruption":{
                    "id": "3d1f32b2-e8df-11e3-8c3e-0008ca8657ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea"},
                    "reference": "foo",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "note": null,
                    "status": "published",
                    "publication_status": "ongoing",
                    "contributor": "shortterm.tn",
                    "version": 2,
                    "publication_period" : {
                        "begin": "2014-04-31T17:00:00Z",
                        "end": null
                    },
                    "impacts": {
                        "pagination": {
                            "start_page": 1,
                            "items_per_page": 20,
                            "total_results": 2,
                            "prev": null,
                            "next": null,
                            "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/1/impacts?start_page=1&item_per_page=20"},
                            "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/1/impacts?start_page=1&item_per_page=20"}
                        }
                    },
                    "cause": {

                        "created_at": "2014-07-21T14:06:23Z",
                        "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com//causes/32b07ff8-10e0-11e4-ae39-d4bed99855be"
                        },
                        "updated_at": null,
                        "wordings": [{"key": "key1", "value": "foo1"}],
                        "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
                    },
                    "localization":[
                    {
                        "administrative_regions": [
                        {
                            "coord": {
                                "lat": "48.01470003",
                                "lon": "2.73233169"
                            },
                            "id": "admin:45068",
                            "level": 8,
                            "name": "Châlette-sur-Loing",
                            "zip_code": "45120"
                        }
                        ],
                        "comment": "",
                        "coord": {
                            "lat": "48.02202",
                            "lon": "2.715535"
                        },
                        "id": "stop_area:AME:SA:104",
                        "name": "Jaillon",
                        "type": "stop_area"

                    }
                    ],
                    tags": [
                        {
                            "created_at": "2014-07-30T07:11:08Z",
                            "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                            "name": "rer",
                            "self": {
                                "href": "http://127.0.0.1:5000/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                            },
                            "updated_at": null
                        }
                    ]
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No disruption"
                },
                "meta": {}
            }


- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'reference' is a required property"
                }
                "meta": {}
            }

##Effacer une perturbation [DELETE]
Cette fonction archive une perturbation, elle pourra eventuellement être restaurée par la suite.

L'archivage est réalisé via un une requete ```DELETE``` sur une pertubation.

Une réponse de type 204 est retournée en cas de succés.
###Exemple

- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No disruption"
                },
                "meta": {}
            }


# List des Impacts par type object [/impacts]

##Retourne les impacts [GET]
Cette fonction donne la liste des impacts par type d'objet.
##Parameters

| Name                 | description                                                                                                | required | default                 |
| -------------------- | ---------------------------------------------------------------------------------------------------------- | -------- | ----------------------- |
| pt_object_type       | Filtre par type d'objet,  les valeurs possibles sont : network, stop_area, line, line_section, stop_point   | false    |                         |
| uri[]                | filtre par uri de l'objet TC                                                                               | false    |                         |
| start_date           | filtre sur la période d'application :date de début                                                         | false    | Now():00:00:00Z         |
| end_date             | filtre sur la période d'application :date de fin                                                           | false    | Now():23:59:59Z         |



- response 200 (application/json)
    * Body

            {

            "meta": {
                "pagination": {
                        "first": {
                            "href": "http://127.0.0.1:5000/impacts?start_page=1&items_per_page=20"
                        },
                        "items_on_page": "1",
                        "items_per_page": "20",
                        "last": {
                            "href": "http://127.0.0.1:5000/impacts?start_page=1&items_per_page=20"
                        },
                        "next": {
                            "href": null
                        },
                        "prev": {
                            "href": null
                        },
                        "start_page": "1",
                        "total_result": "1"
                }
            },
            "objects": [
                {
                    "id": "RER:A",
                    "impacts": [
                        {
                            "application_period_patterns": [],
                            "send_notifications": true,
                            "application_periods": [
                                    {
                                        "begin": "2014-03-29T16:52:00Z",
                                        "end": "2014-05-22T02:15:00Z"
                                    }
                            ],
                            "created_at": "2014-04-31T16:52:18Z",
                            "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea",
                            "messages": [
                                    {
                                        "channel": {
                                        "content_type": "text/plain",
                                        "created_at": "2014-04-31T16:52:18Z",
                                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657da",
                                        "max_size": 140,
                                        "name": "message court",
                                        "updated_at": "2014-04-31T16:55:18Z",
                                        "types": ["web", "mobile"]
                                        },
                                        "created_at": "2014-04-31T16:52:18Z",
                                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                                        "publication_date": [
                                            "2014-04-31T16:52:18Z"
                                            ],
                                        "publication_period": null,
                                        "text": "ptit dej la gare!!",
                                        "updated_at": "2014-04-31T16:55:18Z"
                                    },
                                    {
                                        "channel": {
                                            "content_type": "text/markdown",
                                            "created_at": "2014-04-31T16:52:18Z",
                                            "id": "3d1f42b2-e8df-11e3-8c3e-0008cb8657ea",
                                            "max_size": null,
                                            "name": "message long",
                                            "updated_at": "2014-04-31T16:55:18Z",
                                            "types": ["web", "mobile"]
                                        },
                                        "created_at": "2014-04-31T16:52:18Z",
                                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                                        "publication_date": null,
                                        "publication_period": {
                                            "begin": "2014-04-31T17:00:00Z",
                                            "end": "2014-05-01T17:00:00Z"
                                        },
                                        "text": "est ptit dej en gare",
                                        "updated_at": "2014-04-31T16:55:18Z"
                                    }
                            ],
                            "object": [
                                {
                                    "id": "RER:A",
                                    "name": "RER:A",
                                    "type": "network"
                                }
                            ],
                            "self": {
                                "href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"
                            },
                            "severity": {
                                "color": "#123456",
                                "created_at": "2014-04-31T16:52:18Z",
                                "effect": "none",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
                                "updated_at": "2014-04-31T16:55:18Z",
                                "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}]
                            },
                            "updated_at": "2014-04-31T16:55:18Z"
                            }
                    ],
                    "name": "RER:A",
                    "type": "network"
                }
            ]
            }


# Liste des Impacts [/disruptions/{disruption_id}/impacts]
Un impact représente une relation entre une liste d'objet TC, une sévérité, des périodes d'application et des messages (pas encore implémenté).

Seul les objet TC de type network et stop area sont actuellement géré.

##Retourne les impacts [GET]
Retourne tous les impacts d'une perturbation. Ils sont triés par la priorité de leurs sévérité.
###Paramètres

| Name                 | description                                        | required | default                 |
| -------------------- | -------------------------------------------------- | -------- | ----------------------- |
| start_page           | Numéro de la page (commence par 1)                 | false    | 1                       |
| items_per_page       | Nombre d'items par page                            | false    | 20                      |

Aucun filtre actuellement sur la récupération de liste des impacts: l'interrogation se fait seulement avec un identifiant de perturbation, afin de récupérer l'ensemble des impacts déclarés pour la perturbation demandée.

###Exemple
- response 200 (application/json)

    * Body

            {
                "impacts": [
                    {
                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea",
                        "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"},
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "send_notifications": true,
                        "severity": {
                            "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
                            "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                            "created_at": "2014-04-31T16:52:18Z",
                            "updated_at": "2014-04-31T16:55:18Z",
                            "color": "#123456",
                            "effect": null,
                            "priority": 1,
                        },
                        "messages": [
                                {
                                    "channel": {
                                    "content_type": "text/plain",
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657da",
                                    "max_size": 140,
                                    "name": "message court",
                                    "updated_at": "2014-04-31T16:55:18Z",
                                    "types": ["sms", "notification"]
                                    },
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                                    "publication_date": [
                                        "2014-04-31T16:52:18Z"
                                        ],
                                    "publication_period": null,
                                    "text": "ptit dej la gare!!",
                                    "updated_at": "2014-04-31T16:55:18Z"
                                },
                                {
                                    "channel": {
                                        "content_type": "text/markdown",
                                        "created_at": "2014-04-31T16:52:18Z",
                                        "id": "3d1f42b2-e8df-11e3-8c3e-0008cb8657ea",
                                        "max_size": null,
                                        "name": "message long",
                                        "updated_at": "2014-04-31T16:55:18Z",
                                        "types": ["web", "mobile"]
                                    },
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                                    "publication_date": null,
                                    "publication_period": {
                                        "begin": "2014-04-31T17:00:00Z",
                                        "end": "2014-05-01T17:00:00Z"
                                    },
                                    "text": "est ptit dej en gare",
                                    "updated_at": "2014-04-31T16:55:18Z"
                                }
                        ],
                        "application_period_patterns": [],
                        "application_periods": [
                            {
                                "begin": "2014-04-31T16:52:00Z",
                                "end": "2014-05-22T02:15:00Z"
                            }
                        ],
                        "objects": [
                            {
                                "id": "network:RTP:3786125",
                                "name": "RER A",
                                "type": "network",
                            }
                        ],
                        "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea"}
                    }
                ],
                "meta": {
                    "pagination": {
                        "start_page": 1,
                        "items_per_page": 3,
                        "total_results": 6,
                        "prev": null,
                        "next": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea/impacts?start_page=2&items_per_page=3"},
                        "first": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea/impacts?start_page=1&items_per_page=3"},
                        "last": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea/impacts?start_page=2&items_per_page=3"}
                    }
                }
            }



##Créer un impact [POST]
Création d'un nouvel impact.

La création d'un impact est réalisé via une requéte ```POST``` à sur la resource ```impacts```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'un impact.

Les champs suivant peuvent etre défini:

  - severity (obligatoire)
  - application_periods
  - objects
  - messages

Lors d'un succés une réponse 201 est retourné, celle ci contient l'impact créé.
###Exemple

- request
    + headers

            Content-Type: application/json
            Authorization: [navitia token]
            X-Customer-Id: [customer id]
            X-Contributors: [contributor id]
            X-Coverage: [navitia coverage]

    + body

            {
                "severity": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"
                },
                "send_notifications": true,
                "application_period_patterns": [
                    {
                        "end_date": "2015-02-06",
                        "start_date": "2015-02-01",
                        "time_slots": [
                            {
                                "begin": "07:45",
                                "end": "09:30"
                            },
                            {
                                "begin": "17:30",
                                "end": "20:30"
                            }
                        ],
                        "weekly_pattern": "1111100",
                        "time_zone": "Europe/Paris"
                    }
                ],
                "objects": [
                    {
                        "id": "network:RTP:3786125",
                        "type": "network"
                    },
                    {
                        "id": "line:AME:3",
                        "type": "line_section"
                        "line_section": {
                            "line": {
                                "id":"line:AME:3",
                                "type":"line"
                            },
                            "start_point": {
                                "id":"stop_area:MTD:SA:154",
                                "type":"stop_area"
                            },
                            "end_point": {
                                "id":"stop_area:MTD:SA:155",
                                "type":"stop_area"
                            },
                            "sens":0,
                            "routes":[
                               {
                                   "id": "route:MTD:9",
                                   "name": "corquilleroy",
                                   "type": "route"
                               },
                               {
                                   "id": "route:MTD:10",
                                   "name": "corquilleroy",
                                   "type": "route"
                               },
                               {
                                   "id": "route:MTD:Nav24",
                                   "name": "pannes",
                                   "type": "route"
                               }
                            ],
                            "via":[
                                {
                                "id":"stop_area:MTD:SA:154",
                                "type":"stoparea"
                                }
                            ]
                        }
                    }
                ],
                "messages": [
                    {
                        "text": "Message2",
                        "channel": {
                            "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea"
                        }
                    },
                    {
                        "text": "Message 1",
                        "channel": {
                            "id": "3d1f42b2-e8df-11e3-8c3e-0002ca8657ea"
                        }
                    }
                ]
            }

- response 200 (application/json)

    * Body

            {
                "impact": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "send_notifications": true,
                    "severity": {
                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca861aea",
                        "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "color": "#123456",
                        "effect": null,
                        "priority": 0
                    },
                    "messages": [
                            {
                                "channel": {
                                "content_type": "text/plain",
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0002ca8657ea",
                                "max_size": 140,
                                "name": "message court",
                                "updated_at": "2014-04-31T16:55:18Z",
                                "types": ["sms", "notification"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                                "text": "Message 1",
                                "updated_at": "2014-04-31T16:55:18Z"
                            },
                            {
                                "channel": {
                                    "content_type": "text/markdown",
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
                                    "max_size": null,
                                    "name": "message long",
                                    "updated_at": "2014-04-31T16:55:18Z",
                                    "types": ["web", "mobile"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                                "text": "Message 2",
                                "updated_at": "2014-04-31T16:55:18Z"
                            }
                    ],
                    "application_period_patterns": [
                        {
                            "end_date": "2015-02-06",
                            "start_date": "2015-02-01",
                            "time_slots": [
                                {
                                    "begin": "07:45",
                                    "end": "09:30"
                                },
                                {
                                    "begin": "17:30",
                                    "end": "20:30"
                                }
                            ],
                            "weekly_pattern": "1111100"
                        }
                    ],
                    "application_periods": [
                        {
                            "begin": "2015-02-05T17:30:00Z",
                            "end": "2015-02-05T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-05T07:45:00Z",
                            "end": "2015-02-05T09:30:00Z"
                        },
                        {
                            "begin": "2015-02-04T17:30:00Z",
                            "end": "2015-02-04T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-04T07:45:00Z",
                            "end": "2015-02-04T09:30:00Z"
                        },
                        {
                            "begin": "2015-02-03T17:30:00Z",
                            "end": "2015-02-03T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-03T07:45:00Z",
                            "end": "2015-02-03T09:30:00Z"
                        },
                        {
                            "begin": "2015-02-02T17:30:00Z",
                            "end": "2015-02-02T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-02T07:45:00Z",
                            "end": "2015-02-02T09:30:00Z"
                        }
                    ],
                    "objects": [
                        {
                            "id": "network:RTP:3786125",
                            "name": "RER A",
                            "type": "network",
                        },
                        {
                            "id": "line:AME:3",
                            "type": "line_section"
                            "line_section": {
                                "line": {
                                    "id":"line:AME:3",
                                    "type":"line",
                                    "name": "Lancy / Cepoy - Antibes / Saint Firmin"
                                },
                                "start_point": {
                                    "id":"stop_area:MTD:SA:154",
                                    "type":"stop_area",
                                    "name": "Pichon"
                                },
                                "end_point": {
                                    "id":"stop_area:MTD:SA:155",
                                    "type":"stop_area",
                                    "name": "Pinsons"
                                },
                                "sens":0,
                                "routes":[
                                   {
                                       "id": "route:MTD:9",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:10",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:Nav24",
                                       "name": "pannes",
                                       "type": "route"
                                   }
                                ],
                                "via":[
                                    {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "Pinsons",
                                    "type":"stoparea"
                                    }
                                ]
                            }
                        }
                    ],
                    "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
                },
                "meta": {}
            }

- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'severity' is a required property"
                }
                "meta": {}
            }


#Impact [/disruptions/{disruption_id}/impacts/{id}]
##Retourne un impact [GET]
###Exemple

- response 200 (application/json)

    * Body

            {
                "impact": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "send_notifications": true,
                    "severity": {
                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca861aea",
                        "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "color": "#123456",
                        "effect": null,
                        "priority": 1
                    },
                    "messages": [
                            {
                                "channel": {
                                "content_type": "text/plain",
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0002ca8657ea",
                                "max_size": 140,
                                "name": "message court",
                                "updated_at": "2014-04-31T16:55:18Z",
                                "types": ["sms", "notification"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                                "text": "Message 1",
                                "updated_at": "2014-04-31T16:55:18Z"
                            },
                            {
                                "channel": {
                                    "content_type": "text/markdown",
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
                                    "max_size": null,
                                    "name": "message long",
                                    "updated_at": "2014-04-31T16:55:18Z",
                                    "types": ["web", "mobile"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                                "text": "Message 2",
                                "updated_at": "2014-04-31T16:55:18Z"
                            }
                    ],
                    "application_period_patterns": [],
                    "application_periods": [
                        {
                            "begin": "2014-04-31T16:52:00Z",
                            "end": "2014-05-22T02:15:00Z"
                        }
                    ],
                    "objects": [
                        {
                            "id": "network:RTP:3786125",
                            "name": "RER A",
                            "type": "network",
                        },
                        {
                            "id": "line:AME:3",
                            "type": "line_section"
                            "line_section": {
                                "line": {
                                    "id":"line:AME:3",
                                    "name": "Lancy / Cepoy - Antibes / Saint Firmin",
                                    "type":"line"
                                },
                                "start_point": {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "Pinsons",
                                    "type":"stop_area"
                                },
                                "end_point": {
                                    "id":"stop_area:MTD:SA:155",
                                    "name": "Pinsons",
                                    "type":"stop_area"
                                },
                                "sens":0,
                                "routes":[
                                   {
                                       "id": "route:MTD:9",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:10",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:Nav24",
                                       "name": "pannes",
                                       "type": "route"
                                   }
                                ],
                                "via":[
                                    {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "Pinsons",
                                    "type":"stoparea"
                                    }
                                ]
                            }
                        }
                    ],
                    "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No disruption or impact"
                },
                "meta": {}
            }


##Mise à jour d'un impact [PUT]

La mise à jour d'un impact est réalisé via une requéte ```PUT``` à sur la resource ```/disruptions/{disruption_id}/impacts/{id}```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'un impact.

Les champs suivant peuvent etre mis à jour:

  - severity (obligatoire)
  - application_periods
  - objects
  - messages

Si un champs n'est pas présent dans le json la valeur est considéré null.

Lors d'un succés une réponse 200 est retourné, celle ci contient l'impact modifié.

###Exemple
- Request

    * Headers

            Content-Type: application/json
            Authorization: [navitia token]
            X-Customer-Id: [customer id]
            X-Contributors: [contributor id]
            X-Coverage: [navitia coverage]

    * Body

            {
                "impact": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "send_notifications": true,
                    "severity": {
                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca861aea",
                        "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "color": "#123456",
                        "effect": null,
                        "priority": 1
                    },
                    "messages": [
                            {
                                "channel": {
                                "content_type": "text/plain",
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0002ca8657ea",
                                "max_size": 140,
                                "name": "message court",
                                "updated_at": "2014-04-31T16:55:18Z",
                                "types": ["sms", "notification"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                                "text": "Message 1",
                                "updated_at": "2014-04-31T16:55:18Z"
                            },
                            {
                                "channel": {
                                    "content_type": "text/markdown",
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
                                    "max_size": null,
                                    "name": "message long",
                                    "updated_at": "2014-04-31T16:55:18Z",
                                    "types": ["web", "mobile"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                                "text": "Message 2",
                                "updated_at": "2014-04-31T16:55:18Z"
                            }
                    ],
                    "application_period_patterns": [
                        {
                            "end_date": "2015-02-06",
                            "start_date": "2015-02-01",
                            "time_slots": [
                                {
                                    "begin": "07:45",
                                    "end": "09:30"
                                },
                                {
                                    "begin": "17:30",
                                    "end": "20:30"
                                }
                                ],
                            "weekly_pattern": "1111100",
                            "time_zone": "Europe/Paris"
                        }
                    ],
                    "objects": [
                        {
                            "id": "network:RTP:3786125",
                            "name": "RER A",
                            "type": "network",
                        },
                        {
                            "id": "network:RTP:378",
                            "name": "RER B",
                            "type": "network",
                        },
                        {
                            "id": "line:AME:3",
                            "type": "line_section"
                            "line_section": {
                                "line": {
                                    "id":"line:AME:3",
                                    "name": "Lancy / Cepoy - Antibes / Saint Firmin",
                                    "type":"line"
                                },
                                "start_point": {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "Pinsons",
                                    "type":"stop_area"
                                },
                                "end_point": {
                                    "id":"stop_area:MTD:SA:155",
                                    "name": "Pinsons",
                                    "type":"stop_area"
                                },
                                "sens":0,
                                "routes":[
                                   {
                                       "id": "route:MTD:9",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:10",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:Nav24",
                                       "name": "pannes",
                                       "type": "route"
                                   }
                                ],
                                "via":[
                                    {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "Pinsons",
                                    "type":"stoparea"
                                    }
                                ]
                            }
                        }
                    ],
                    "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
                },
                "meta": {}
            }


- Response 200 (application/json)

    * Body

            {
                "impact": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "send_notifications": true,
                    "severity": {
                        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca861aea",
                        "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "color": "#123456",
                        "effect": null,
                        "priority": 1
                    },
                    "messages": [
                            {
                                "channel": {
                                "content_type": "text/plain",
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0002ca8657ea",
                                "max_size": 140,
                                "name": "message court",
                                "updated_at": "2014-04-31T16:55:18Z",
                                "types": ["sms", "notification"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                                "text": "Message 1",
                                "updated_at": "2014-04-31T16:55:18Z"
                            },
                            {
                                "channel": {
                                    "content_type": "text/markdown",
                                    "created_at": "2014-04-31T16:52:18Z",
                                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
                                    "max_size": null,
                                    "name": "message long",
                                    "updated_at": "2014-04-31T16:55:18Z",
                                    "types": ["web", "mobile"]
                                },
                                "created_at": "2014-04-31T16:52:18Z",
                                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                                "text": "Message 2",
                                "updated_at": "2014-04-31T16:55:18Z"
                            }
                    ],
                    "application_period_patterns": [
                        {
                            "end_date": "2015-02-06",
                            "start_date": "2015-02-01",
                            "time_slots": [
                                {
                                    "begin": "07:45",
                                    "end": "09:30"
                                },
                                {
                                    "begin": "17:30",
                                    "end": "20:30"
                                }
                                ],
                            "weekly_pattern": "1111100"
                        }
                    ],
                    "application_periods": [
                        {
                            "begin": "2015-02-05T17:30:00Z",
                            "end": "2015-02-05T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-05T07:45:00Z",
                            "end": "2015-02-05T09:30:00Z"
                        },
                        {
                            "begin": "2015-02-04T17:30:00Z",
                            "end": "2015-02-04T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-04T07:45:00Z",
                            "end": "2015-02-04T09:30:00Z"
                        },
                        {
                            "begin": "2015-02-03T17:30:00Z",
                            "end": "2015-02-03T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-03T07:45:00Z",
                            "end": "2015-02-03T09:30:00Z"
                        },
                        {
                            "begin": "2015-02-02T17:30:00Z",
                            "end": "2015-02-02T20:30:00Z"
                        },
                        {
                            "begin": "2015-02-02T07:45:00Z",
                            "end": "2015-02-02T09:30:00Z"
                        }
                    ],
                    "objects": [
                        {
                            "id": "network:RTP:3786125",
                            "name": "RER A",
                            "type": "network",
                        },
                        {
                            "id": "network:RTP:378",
                            "name": "RER B",
                            "type": "network",
                        },
                        {
                            "id": "line:AME:3",
                            "type": "line_section"
                            "line_section": {
                                "line": {
                                    "id":"line:AME:3",
                                    "name": "Lancy / Cepoy - Antibes / Saint Firmin",
                                    "type":"line"
                                },
                                "start_point": {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "pincons",
                                    "type":"stop_area"
                                },
                                "end_point": {
                                    "id":"stop_area:MTD:SA:155",
                                    "name": "pincons",
                                    "type":"stop_area"
                                },
                                "sens":0,
                                "routes":[
                                   {
                                       "id": "route:MTD:9",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:10",
                                       "name": "corquilleroy",
                                       "type": "route"
                                   },
                                   {
                                       "id": "route:MTD:Nav24",
                                       "name": "pannes",
                                       "type": "route"
                                   }
                                ],
                                "via":[
                                    {
                                    "id":"stop_area:MTD:SA:154",
                                    "name": "pincons",
                                    "type":"stoparea"
                                    }
                                ]
                            }
                        }
                    ],
                    "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No impact"
                },
                "meta": {}
            }


- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'severity' is a required property"
                }
                "meta": {}
            }

##Effacer un impact [DELETE]
Cette fonction archive un impact, elle pourra eventuellement être restaurée par la suite.

L'archivage est réalisé via un une requete ```DELETE``` sur un impact.

Une réponse de type 204 est retournée en cas de succés.
###Exemple

- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No impact"
                },
                "meta": {}
            }


#Liste des sévérités [/severities]

Une sévérité est composé des champs suivants:

  - ```wording``` correspond au libellé qui sera affiché pour cette sévérité.
  - ```color``` correspond à la couleur, en hexadécimale, associé à cette sévérité.
  - ```priority``` correspond à l'ordre d'affichage de la sévérité, et donc des impacts qui lui sont rattachés.
  - ```effect``` correspond à l'énumération ```SeverityEffect``` et détermine l'effet dans le calculateur d'itinéraire.

##Retourne la liste de toutes les sévérités [GET]
Permet de récupérer l'ensemble des sévérités (ou conséquences) déclarées.

- response 200 (application/json)

    * Body

            {
                "severities": [
                    {
                        "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/severities/3d1f42b3-e8df-11e3-8c3e-0008ca8617ea"
                        }
                        "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                        "effect": null,
                        "priority": 1,
                        "color": "#123456",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b4-e8df-11e3-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/severities/3d1f42b4-e8df-11e3-8c3e-0008ca8617ea"
                        }
                        "wordings" : [{"key": "msg", "value": "Majeur"}],
                        "effect": null,
                        "priority": 2,
                        "color": "#123456",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b5-e8df-11e3-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/severities/3d1f42b5-e8df-11e3-8c3e-0008ca8617ea"
                        }
                        "wordings" : [{"key": "msg", "value": "Bloquant"}],
                        "effect": "no_service",
                        "priority": 3,
                        "color": "#123456",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    }
                ],
                "meta": {}
            }

##Créer une sévérité [POST]


La création d'une sévérité est réalisée via une requête ```POST``` sur la resource ```severities```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une sévéritié.

Les champs suivant peuvent etre défini:

  - wording (obligatoire)
  - color
  - priority
  - effect


Lors d'un succés une réponse 201 est retourné, celle ci contient la sévérité créée.

- request
    + headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

                {
                    "wording": "normal",
                    "color": "#123456",
                    "effect": null,
                    "priority": 1
                }

- response 200 (application/json)

    * Body

            {
                "severity": {
                    "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/severities/3d1f42b3-e8df-11e3-8c3e-0008ca8617ea"
                    }
                    "wordings" : [{"key": "msg", "value": "Normal"}],
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null,
                    "color": "#123456",
                    "priority": 1,
                    "effect": null
                },
                "meta": {}
            }

- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'wording' is a required property"
                }
                "meta": {}
            }


# Severities [/severities/{id}]
##Retourne une sévérité [GET]

##Exemple

Retourne une sévérité existante.

- response 200 (application/json)

    * Body

            {
                "severity": {
                    "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/severities/3d1f42b3-e8df-11e3-8c3e-0008ca8617ea"
                    }
                    "wordings" : [{"key": "msg", "value": "Normal"}],
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null,
                    "color": "#123456",
                    "effect": null,
                    "priority": 1
                },
                "meta": {}
            }


- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No severity"
                },
                "meta": {}
            }

##Mise à jour d'une sévérité [PUT]
La mise à jour d'une sévérité est réalisé via une requéte ```PUT``` sur la resource ```severities```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une sévérité.

Les contraintes sont les meme que pour la création.

Lors d'un succés une réponse 200 est retourné, celle ci contient la sévérité modifiée.

###Exemple

- Request

    * Headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

            {
                "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                "color": "#123456",
                "effect": null,
                "priority": 1
            }


- Response 200 (application/json)

    * Body

            {
                "severity": {
                    "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/severities/3d1f42b3-e8df-11e3-8c3e-0008ca8617ea"
                    }
                    "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "color": "#123456",
                    "effect": null,
                    "priority": 1
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No severity"
                },
                "meta": {}
            }


- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'wordings' is a required property"
                }
                "meta": {}
            }

##supprimer une sévérité [DELETE]
supprime une sévérité.
###Exemple


- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No severity"
                },
                "meta": {}
            }

#Liste des causes [/causes]

##Retourne la liste de toutes les causes [GET]

##Paramètres

| Name                 | description                                                                               | required | default                 |
| -------------------- | ----------------------------------------------------------------------------------------- | -------- | ----------------------- |
| category             | filtre sur tag (identifiant du category)                                                  | false    |                         |

Le champs ```category``` contient la catégorie de la cause.

- response 200 (application/json)

    * Body

            {
                "causes": [
                    {
                        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/causes/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                        }
                        "wordings": [{"key": "key1", "value": "foo1"}],
                        "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "test"}
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e5-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/causes/3d1f42b2-e8df-11e5-8c3e-0008ca8617ea"
                        }
                        "wordings": [{"key": "key1", "value": "foo1"}],
                        "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e6-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/causes/3d1f42b2-e8df-11e6-8c3e-0008ca8617ea"
                        }
                        "wordings": [{"key": "msg", "value": "accident voyageur"}],
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    }
                ],
                "meta": {}
            }

##Créer une cause [POST]

La création d'une cause est réalisée via une requête ```POST``` sur la resource ```cause```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une cause.

Les champs suivant peuvent etre défini:

  - wordings (obligatoire)

Le champs ```wordings``` correspond aux cle/valeur qui seront affichés pour cette cause.

Lors d'un succés une réponse 201 est retourné, celle ci contient la cause créée.

###Exemple
- request
    + headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

                {
                    "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be"},
                    "wordings": [{"key": "msg", "value": "accident voyageur"}],
                }

- response 200 (application/json)

    * Body

            {
                "cause": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/causes/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "wordings": [{"key": "msg", "value": "accident voyageur"}],
                    "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "test"}
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                },
                "meta": {}
            }

- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'wording' is a required property"
                }
                "meta": {}
            }

# Causes [/causes/{id}]
##Retourne une cause. [GET]

##Paramètres

Retourne une cause existante.

- response 200 (application/json)

    * Body

            {
                "cause": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/causes/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "wordings": [{"key": "msg", "value": "accident voyageur"}],
                    "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                },
                "meta": {}
            }


- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No cause"
                },
                "meta": {}
            }

##Mise à jour d'une cause [PUT]
La mise à jour d'une cause est réalisé via une requéte ```PUT``` sur la resource ```causes```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une cause.

Les contraintes sont les meme que pour la création.

Lors d'un succés une réponse 200 est retourné, celle ci contient la cause modifiée.
###Exemple


- Request

    * Headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

            {
                "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be"},
                "wordings": [{"msg": "météo"}]
            }

- Response 200 (application/json)

    * Body

            {
                "cause": {
                    "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/causes/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "wordings": [{"key": "msg", "value": "accident voyageur"}],
                    "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "test"}
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z"
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No cause"
                },
                "meta": {}
            }

- response 400 (application/json)
    * Body

            {
                "error": {
                    "message": "'wordings' is a required property"
                }
                "meta": {}
            }

##Archive une cause [DELETE]
Archive une cause.
###Paramètres


- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No cause"
                },
                "meta": {}
            }

#Liste des tags [/tags]

##Retourne la liste de tous les tags [GET]

- response 200 (application/json)

    * Body

            {
                "tags": [
                    {
                        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                        }
                        "name": "probleme",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e5-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e5-8c3e-0008ca8617ea"
                        }
                        "name": "meteo",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e6-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e6-8c3e-0008ca8617ea"
                        }
                        "name": "rer",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    }
                ],
                "meta": {}
            }

##Créer un tag [POST]

La création d'un tag est réalisée via une requête ```POST``` sur la resource ```tag```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'un tag.

Les champs suivant peuvent etre défini:

  - wording (obligatoire)

Le champs ```wording``` correspond au libellé qui sera affiché pour ce tag.

Lors d'un succés une réponse 201 est retourné, celle ci contient le tag créé.

###Exemple
- request
    + headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

                {
                    "name": "rer"
                }

- response 200 (application/json)

    * Body

            {
                "tag": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "rer",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                },
                "meta": {}
            }

- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'name' is a required property"
                }
                "meta": {}
            }

# tags [/tags/{id}]
##Retourne une cause. [GET]

##Paramètres

Retourne un tag existant.

- response 200 (application/json)

    * Body

            {
                "tag": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "rer",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                },
                "meta": {}
            }


- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No tag"
                },
                "meta": {}
            }

##Mise à jour d'un tag [PUT]
La mise à jour d'un tag est réalisé via une requête ```PUT``` sur la resource ```tags```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'un tag.

Les contraintes sont les meme que pour la création.

Lors d'un succés une réponse 200 est retourné, celle ci contient le tag modifié.
###Exemple


- Request

    * Headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

            {
                "name": "rer"
            }

- Response 200 (application/json)

    * Body

            {
                "tag": {
                    "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "rer",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z"
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No tag"
                },
                "meta": {}
            }

- response 400 (application/json)
    * Body

            {
                "error": {
                    "message": "'name' is a required property"
                }
                "meta": {}
            }

##Archive un tag [DELETE]
Archive un tag.
###Paramètres


- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No tag"
                },
                "meta": {}
            }


#Lists des types du canal de diffusions [/channel_types]

##Retourne la liste de tous les types de canal de diffusion [GET]

- response 200 (application/json)

    * Body

            {
                "channel_types": ["web", "sms", "email", "mobile", "notification", "twitter", "facebook"]
            }


#Liste des canaux de diffusions [/channels]

##Retourne la liste de tous les canaux de diffusion [GET]

- response 200 (application/json)

    * Body

            {
                "channels": [
                    {
                        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/channels/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                        }
                        "name": "court",
                        "max_size": 140,
                        "content_type": "text/plain",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "types": ["sms", "notification"]
                    },
                    {
                        "id": "3d1a42b7-e8df-11e4-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/channels/3d1f42b7-e8df-11e4-8c3e-0008ca8617ea"
                        }
                        "name": "long",
                        "max_size": 512,
                        "content_type": "text/plain",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "types": ["email"]
                    },
                    {
                        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/channels/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                        }
                        "name": "long riche",
                        "max_size": null,
                        "content_type": "text/markdown",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z",
                        "types": ["web", "mobile"]
                    }
                ],
                "meta": {}
            }

##Créer un canal [POST]
La création d'un canal est réalisée via une requête ```POST``` sur la resource ```channel```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'un canal.

Les champs suivant peuvent etre défini:

  - name (obligatoire)
  - max_size (obligatoire mais peut etre null pour signifier qu'il n'y a pas de taille max)
  - content_type (obligatoire)

Lors d'un succés une réponse 201 est retourné, celle ci contient la canal créé.

###Exemple

- request
    + headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

                {
                    "name": "court",
                    "max_size": 140,
                    "content_type": "text/plain",
                    "types": ["sms", "notification"]
                }

- response 200 (application/json)

    * Body

            {
                "channel": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/channels/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "court",
                    "max_size": 140,
                    "content_type": "text/plain",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "types": ["sms", "notification"]
                },
                "meta": {}
            }

- response 400 (application/json)
    * Body

            {
                "error": {
                    "message": "'name' is a required property"
                }
                "meta": {}
            }

#Liste des categories [/categories]

##Retourne la liste de tous les categories [GET]

- response 200 (application/json)

    * Body

            {
                "categories": [
                    {
                        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/categories/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                        }
                        "name": "probleme",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e5-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/categories/3d1f42b2-e8df-11e5-8c3e-0008ca8617ea"
                        }
                        "name": "meteo",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e6-8c3e-0008ca8617ea",
                        "self": {
                            "href": "https://ogv2ws.apiary-mock.com/categories/3d1f42b2-e8df-11e6-8c3e-0008ca8617ea"
                        }
                        "name": "rer",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    }
                ],
                "meta": {}
            }

##Créer une category [POST]

La création d'une category est réalisée via une requête ```POST``` sur la resource ```category```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une category.

Les champs suivant peuvent etre défini:

  - name (obligatoire)

Le champs ```name``` correspond au libellé qui sera affiché pour cette category.

Lors d'un succés une réponse 201 est retourné, celle ci contient la category créé.

###Exemple
- request
    + headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

                {
                    "name": "rer"
                }

- response 200 (application/json)

    * Body

            {
                "category": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/categories/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "rer",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                },
                "meta": {}
            }

- response 400 (application/json)

    * Body

            {
                "error": {
                    "message": "'name' is a required property"
                }
                "meta": {}
            }

# categories [/categories/{id}]
##Retourne une cause. [GET]

##Paramètres

Retourne une category existant.

- response 200 (application/json)

    * Body

            {
                "category": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/categories/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "rer",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                },
                "meta": {}
            }


- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No category"
                },
                "meta": {}
            }

##Mise à jour d'une category [PUT]
La mise à jour d'une category est réalisé via une requête ```PUT``` sur la resource ```categories```.
Le content-type de la requete doit etre json et le corps de celle ci doit contenir un json correspondant au format d'une category.

Les contraintes sont les meme que pour la création.

Lors d'un succés une réponse 200 est retourné, celle ci contient la category modifié.
###Exemple


- Request

    * Headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

            {
                "name": "rer"
            }

- Response 200 (application/json)

    * Body

            {
                "category": {
                    "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
                    "self": {
                        "href": "https://ogv2ws.apiary-mock.com/categories/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    }
                    "name": "rer",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z"
                },
                "meta": {}
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No category"
                },
                "meta": {}
            }

- response 400 (application/json)
    * Body

            {
                "error": {
                    "message": "'name' is a required property"
                }
                "meta": {}
            }

##Archive une category [DELETE]
Archive une category.
###Paramètres


- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No category"
                },
                "meta": {}
            }

