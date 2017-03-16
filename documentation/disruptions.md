# Chaos

Chaos is the web service which can feed [Navitia](https://github.com/CanalTP/navitia) with real-time [disruptions](http://doc.navitia.io/#traffic-reports).
It can work together with [Kirin](https://github.com/CanalTP/kirin) which can feed [Navitia](https://github.com/CanalTP/navitia) with real-time delays.


# Root [/]

## Retrieve Api [GET]

### Response 200 (application/json)

```javascript
{
    "disruptions": {"href": "https://chaos.apiary-mock.com/disruptions"},
    "disruption": {"href": "https://chaos.apiary-mock.com/disruptions/{id}", "templated": true},
    "severities": {"href": "https://chaos.apiary-mock.com/severities"},
    "causes": {"href": "https://chaos.apiary-mock.com/causes"},
    "channels": {"href": "https://chaos.apiary-mock.com/channels"},
    "impactsbyobject": {"href": "https://chaos.apiary-mock.com/impactsbyobject"},
    "tags": {"href": "https://chaos.apiary-mock.com/tags"},
    "categories": {"href": "https://chaos.apiary-mock.com/categories"},
    "channeltypes": {"href": "https://chaos.apiary-mock.com/channel_types"}
}
```

## Headers

| Name                 | description                                                                    | required | default                 |
| -------------------- | ------------------------------------------------------------------------------ | -------- | ----------------------- |
| Content-Type         | input text type                                                                | true     | application/json        |
| Authorization        | token for navitia services                                                     | true     |                         |
| X-Customer-Id        | client code. A client is owner of cause, channel, severity and tag             | true     |                         |
| X-Contributors       | contributor code. A contributor is owner of a disruption                       | true     |                         |
| X-Coverage           | coverage of navitia services                                                   | true     |                         |

# List of disruptions [/disruptions]

## Retrieve disruptions [GET]

Return all visible disruptions.
### Parameters

| Name                 | description                                                                    | required | default                 |
| -------------------- | ------------------------------------------------------------------------------ | -------- | ----------------------- |
| start_page           | index of the first element returned (start at 1)                               | false    | 1                       |
| items_per_page       | number of items per page                                                       | false    | 20                      |
| publication_status[] | filter by publication_status, possible value are: past, ongoing, coming        | false    | [past, ongoing, coming] |
| current_time         | parameter for settings the use by this request, mostly for debugging purpose   | false    | NOW                     |
| tag[]                | filter by tag (id of tag)                                                      | false    |                         |
| uri                  | filter by uri of ptobject                                                      | false    |                         |
| status[]             | filter by status                                                               | false    | [published, draft]      |
| depth                | with depth=2, you could retrieve the first page of impacts from the disruption | false    | 1                       |

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "disruptions": [
        {
            "id": "d30502d2-e8de-11e3-8c3e-0008ca8657ea",
            "self": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea"},
            "reference": "RER B en panne",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "note": "blablbla",
            "status": "published",
            "publication_status": "ongoing",
            "contributor": "shortterm.tn",
            "version": 1,
            "cause": {
                "id": "3d1f34b2-e8df-11e3-8c3e-0008ca8657ea",
                "wordings": [{"key": "msg", "value": "accident voyageur"}],
                "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
            },
            "tags": [
                {
                    "created_at": "2014-07-30T07:11:08Z",
                    "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                    "name": "rer",
                    "self": {
                        "href": "https://chaos.apiary-mock.com/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                    },
                    "updated_at": null
                }
            ]
            "localization": [
                {
                    "id": "stop_area:RTP:SA:3786125",
                    "name": "HENRI THIRARD - LEON JOUHAUX",
                    "type": "stop_area",
                    "coord": {
                        "lat": "48.778867",
                        "lon": "2.340927"
                    }
                },
                {
                    "id": "stop_area:RTP:SA:3786123",
                    "name": "DE GAULLE - GOUNOD - TABANOU",
                    "type": "stop_area",
                    "coord": {
                        "lat": "48.780179",
                        "lon": "2.340886"
                    }
                }
            ],
            "publication_period" : {
                "begin":"2014-04-31T17:00:00Z",
                "end":"2014-05-01T17:00:00Z"
            },
            "impacts": {
                "pagination": {
                    "start_page": 0,
                    "items_per_page": 20,
                    "total_results": 3,
                    "prev": null,
                    "next": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                    "first": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                    "last": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"}
                }
            }
        },
        {
            "id": "d30502d2-e8de-11e3-8c3e-0008ca8657eb",
            "self": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb"},
            "reference": "RER A en panne",
            "created_at": "2014-05-31T16:52:18Z",
            "updated_at": null,
            "note": null,
            "status": "published",
            "publication_status": "coming",
            "contributor": "shortterm.tn",
            "cause": {
                "id": "3d1f34b2-e8ef-11e3-8c3e-0008ca8657ea",
                "wordings": [{"key": "msg", "value": "accident voyageur"}],
                "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
            },
            "tags": [
                {
                    "created_at": "2014-07-30T07:11:08Z",
                    "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                    "name": "rer",
                    "self": {
                        "href": "https://chaos.apiary-mock.com/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                    },
                    "updated_at": null
                }
            ],
            "properties": {
                "comment": [
                    {
                        "property": {
                            "created_at": "2014-04-12T12:49:58Z",
                            "id": "10216aec-00ad-11e6-9f6d-0050568c8382",
                            "key": "special",
                            "self": {
                                "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8382"
                            },
                            "type": "comment",
                            "updated_at": "2014-04-12T13:00:57Z"
                        },
                        "value": "This is a very nice comment !"
                    }
                ]
            },
            "localization": [],
            "publication_period" : {
                "begin": "2014-04-31T17:00:00Z",
                "end": null
            },
            "impacts": {
                "pagination": {
                    "start_page": 0,
                    "items_per_page": 20,
                    "total_results": 5,
                    "prev": null,
                    "next": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb/impacts?start_page=1&item_per_page=20"},
                    "first": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb/impacts?start_page=1&item_per_page=20"},
                    "last": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657eb/impacts?start_page=1&item_per_page=20"}
                }
            }
        },
        {
            "id": "d30502d2-e8de-11e3-8c3e-0008ca8657ec",
            "self": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec"},
            "reference": "Chatelet fermé",
            "created_at": "2014-05-17T16:52:18Z",
            "update_at": "2014-05-31T06:55:18Z",
            "note": "retour probable d'ici 5H",
            "status": "published",
            "publication_status": "past",
            "contributor": "shortterm.tn",
            "cause": {
                "id": "3d1f34b2-e2df-11e3-8c3e-0008ca8657ea",
                "wordings": [{"key": "msg", "value": "accident voyageur"}],
                "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
            },
            "tags": [
                {
                    "created_at": "2014-07-30T07:11:08Z",
                    "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                    "name": "rer",
                    "self": {
                        "href": "https://chaos.apiary-mock.com/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                    },
                    "updated_at": null
                }
            ],
            "localization": [
                {
                    "id": "stop_area:RTP:SA:378125",
                    "name": "Chatelet",
                    "type": "stop_area",
                    "coord": {
                        "lat": "48.778867",
                        "lon": "2.340927"
                    }
                }
            ],
            "publication_period" : {
                "begin": "2014-04-31T17:00:00Z",
                "end": null
            },
            "impacts": {
                "pagination": {
                    "start_page": 0,
                    "items_per_page": 20,
                    "total_results": 25,
                    "prev": null,
                    "next": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec/impacts?start_page=1&item_per_page=20"},
                    "first": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec/impacts?start_page=1&item_per_page=20"},
                    "last": {"href": "https://chaos.apiary-mock.com/disruptions/d30502d2-e8de-11e3-8c3e-0008ca8657ec/impacts?start_page=21&item_per_page=20"}
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
            "next": {"href": "https://chaos.apiary-mock.com/disruptions/?start_page=4&item_per_page=3"},
            "first": {"href": "https://chaos.apiary-mock.com/disruptions/?start_page=1&item_per_page=3"},
            "last": {"href": "https://chaos.apiary-mock.com/disruptions/?start_page=4&item_per_page=3"}
        }
    }

}
```

## Create a disruption [POST]

Create one valid disruption with impacts

### Request

- [Headers](#headers)
- Body
```javascript
{
    // REQUIRED. max length 250
    "reference": "foo",
    // OPTIONAL. Default: null
    "note": null,
    // REQUIRED.
    "contributor": "shortterm.tn",
    // OPTIONAL. in this list ["published", "draft"]
    "status": "published",
    // REQUIRED.
    "cause": {
        // REQUIRED.
       "id": "3d1f34b2-e8df-1ae3-8c3e-0008ca8657ea"
    },
    // OPTIONAL.
    "tags":[
        {
            // REQUIRED.
            "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be"
        }
    ],
    // OPTIONAL.
    "localization": [
        {
            // REQUIRED.
            "id": "stop_area:RTP:SA:3786125",
            // REQUIRED.
            "type": "stop_area"
        },
        {
            // REQUIRED.
            "id": "stop_area:RTP:SA:3786123",
            // REQUIRED.
            "type": "stop_area"
        }
    ],
    // OPTIONAL.
    "publication_period" : {
        // REQUIRED. PHP date : 'Y-m-d\TH:i:s\Z'
        "begin": "2014-04-31T17:00:00Z",
        // REQUIRED. PHP date : 'Y-m-d\TH:i:s\Z', can be null
        "end": null
    },
    // OPTIONAL.
    "impacts": [
        {
            // REQUIRED.
            "severity": {
                // REQUIRED.
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"
            },
            // OPTIONAL.
            "application_periods": [
                {
                    // REQUIRED. PHP date : 'Y-m-d\TH:i:s\Z'
                    "begin": "2014-04-31T16:52:00Z",
                    // REQUIRED. PHP date : 'Y-m-d\TH:i:s\Z', can be null
                    "end": "2014-05-22T02:15:00Z"
                }
            ],
            // OPTIONAL.
            "messages": [
                {
                    // REQUIRED.
                    "text": "ptit dej à la gare!!",
                    // REQUIRED.
                    "channel": {
                        // REQUIRED.
                        "id": "3d1f42b6-e8df-11e3-8c3e-0008ca8657ea"
                    }
                },
                {
                    // REQUIRED.
                    "text": "#Youpi\n**aujourd'hui c'est ptit dej en gare",
                    // REQUIRED.
                    "channel": {
                        // REQUIRED.
                        "id": "3d1f42b6-e8df-11e3-8c3e-0008ca8657ea"
                    }
                }
            ],
            // OPTIONAL.
            "objects": [
                {
                    // REQUIRED. max length 250
                    "id": "stop_area:RTP:SA:3786125",
                    // REQUIRED. in this list ["stop_area"]
                    "type": "stop_area"
                }
            ]
            // OPTIONAL.
            "send_notifications": true,
            // OPTIONAL. PHP date : 'Y-m-d\TH:i:s\Z'
            "notification_date": "2014-04-31T17:00:00Z"
        }
    ],
    // OPTIONAL.
    "properties": [
        {
            // REQUIRED.
            "property_id": "10216aec-00ad-11e6-9f6d-0050568c8382",
            // REQUIRED. max length 250
            "value": "This is a very nice comment !"
        }
    ]
}
```

### Response

#### 201 (application/json)

* Body like [GET](#retrieve-disruptions-get)

#### Errors

- 400 (application/json)
- 404 (application/json)
- 500 (application/json)
- 503 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

# Disruptions [/disruptions/{id}]

## Retrieve one disruption [GET]

### Parameters

| Name                 | description                                                                    | required | default                 |
| -------------------- | ------------------------------------------------------------------------------ | -------- | ----------------------- |
| depth                | with depth=2, you could retrieve the first page of impacts from the disruption | false    | 1                       |

Retrieve one existing disruption:

### Response 200 (application/json)

```javascript
{
    "disruption": {
        "id": "3d1f32b2-e8df-11e3-8c3e-0008ca8657ea",
        "self": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea"},
        "reference": "RER B en panne",
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "note": "blablbla",
        "status": "published",
        "publication_status": "ongoing",
        "contributor": "shortterm.tn",
        "version": 2,
        "cause": {
            "id": "3d1e32b2-e8df-11e3-8c3e-0008ca8657ea",
            "wordings": [{"key": "msg", "value": "accident voyageur"}],
            "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
        },
        "tags": [
            {
                "created_at": "2014-07-30T07:11:08Z",
                "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                "name": "rer",
                "self": {
                    "href": "https://chaos.apiary-mock.com/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                },
                "updated_at": null
            }
        ],
        "localization": [
            {
                "id": "stop_area:RTP:SA:3786125",
                "name": "HENRI THIRARD - LEON JOUHAUX",
                "type": "stop_area",
                "coord": {
                    "lat": "48.778867",
                    "lon": "2.340927"
                }
            },
            {
                "id": "stop_area:RTP:SA:3786123",
                "name": "DE GAULLE - GOUNOD - TABANOU",
                "type": "stop_area",
                "coord": {
                    "lat": "48.780179",
                    "lon": "2.340886"
                }
            }
        ],
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
                "next": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                "first": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"},
                "last": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts?start_page=1&item_per_page=20"}
            }
        }
    },
    "meta": {}
}
```

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No disruption"
    }
}
```

## Update a disruption [PUT]

### Request

- [Headers](#headers)
- Body like [POST](#create-a-disruption-post)

```javascript
{
    "reference": "foo",
    "note": null,
    "contributor": "shortterm.tn",
    "cause": {
        "id": "3d1f32b2-e8df-11e3-8c3e-0008ca86c7ea"
    },
    "tags": [
        {
            "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be"
        }
    ],
    "localization": [
        {
            "id": "stop_area:RTP:SA:3786125",
            "type": "stop_area"
        },
        {
            "id": "stop_area:RTP:SA:3786123",
            "type": "stop_area"
        }
    ],
    "publication_period" : {
        "begin": "2014-04-31T17:00:00Z",
        "end": null
    },
    "impacts": [
        {
            "severity": {
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"
            },
            "application_periods": [
                {
                    "begin": "2014-04-31T16:52:00Z",
                    "end": "2014-05-22T02:15:00Z"
                }
            ]
        },
        {
            "id":"7ffab230-3d48-4eea-aa2c-22f8680230b6",
            "severity": {
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"
            },
            "application_periods": [
                {
                    "begin": "2014-04-31T16:52:00Z",
                    "end": "2014-05-22T02:15:00Z"
                }
            ],
            "send_notifications": true,
            "notification_date": "2014-04-31T17:00:00Z"
        }
    ],
    "properties": [
        {
            "property_id": "10216aec-00ad-11e6-9f6d-0050568c8382",
            "value": "This is a very nice comment !"
        }
    ]
}
```

### Response 200 (application/json)

```javascript
{
    "disruption":{
        "id": "3d1f32b2-e8df-11e3-8c3e-0008ca8657ea",
        "self": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea"},
        "reference": "foo",
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "note": null,
        "status": "published",
        "publication_status": "ongoing",
        "contributor": "shortterm.tn",
        "version": 2,
        "cause": {
            "id": "3d1f32b2-e8df-11e3-8c3e-0008ca8657ea",
            "wordings": [{"key": "msg", "value": "accident voyageur"}],
            "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
        },
        "tags": [
            {
                "created_at": "2014-07-30T07:11:08Z",
                "id": "ad9d80ce-17b8-11e4-a553-d4bed99855be",
                "name": "rer",
                "self": {
                    "href": "https://chaos.apiary-mock.com/tags/ad9d80ce-17b8-11e4-a553-d4bed99855be"
                },
                "updated_at": null
            }
        ],
        "localization": [
            {
                "id": "stop_area:RTP:SA:3786125",
                "name": "HENRI THIRARD - LEON JOUHAUX",
                "type": "stop_area",
                "coord": {
                    "lat": "48.778867",
                    "lon": "2.340927"
                }
            },
            {
                "id": "stop_area:RTP:SA:3786123",
                "name": "DE GAULLE - GOUNOD - TABANOU",
                "type": "stop_area",
                "coord": {
                    "lat": "48.780179",
                    "lon": "2.340886"
                }
            }
        ],
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
        "properties": {
            "comment": [
                {
                    "property": {
                        "created_at": "2014-04-12T12:49:58Z",
                        "id": "10216aec-00ad-11e6-9f6d-0050568c8382",
                        "key": "special",
                        "self": {
                            "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8382"
                        },
                        "type": "comment",
                        "updated_at": "2014-04-12T13:00:57Z"
                    },
                    "value": "This is a very nice comment !"
                }
            ]
        }
    },
    "meta": {}
}
```

### Errors

- 400 (application/json)
- 404 (application/json)
- 409 (application/json)
- 500 (application/json)
- 503 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```
You can pass the status in the request in order to update it:

### Example request

    Method
            PUT
    Uri
            /disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6
    Headers
            X-Customer-Id: [customer id]
            X-Coverage: jdr
            Authorization: d5b0148c-36f4-443c-9818-1f2f74a00be0
            X-Contributors: contributor
    Body
        {
            "reference": "foo",
            "contributor": "contributor",
            "cause": {
                "id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"
            },
            "status": "draft"
        }

But you can't make a 'published' disruption going back to 'draft' status:

### Response 409 CONFLICT (application/json)

```javascript
{
    "error": {
        "message": "The current disruption is already published and cannot get back to the 'draft' status."
    }
}
```

## Delete a disruption [DELETE]

Archive one disruption.

- [Headers](#headers)

### Response 204 NO CONTENT

Disruption archived

### Error 404 (application/json)

- Body

```javascript
{
    "error": {
        "message": "..."
    }
}
```

# List of Impacts by object type [/impacts]

## Retrieve impacts [GET]

Return all impacts by ptobject.

### Parameters

| Name                 | description                                                                                | required | default                     |
| -------------------- | ------------------------------------------------------------------------------------------ | -------- | --------------------------- |
| pt_object_type       | filter by ptobject, possible value are: network, stop_area, line, line_section, stop_point  | false    |                             |
| uri[]                | filtre by ptobject.uri                                                                     | false    |                             |
| start_date           | filtre by application period :star date                                                    | false    | Now():00:00:00Z             |
| end_date             | filtre by application period :end date                                                     | false    | Now():23:59:59Z             |

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "meta": {
        "pagination": {
                "first": {
                    "href": "https://chaos.apiary-mock.com/impacts?start_page=1&items_per_page=20"
                },
                "items_on_page": "1",
                "items_per_page": "20",
                "last": {
                    "href": "https://chaos.apiary-mock.com/impacts?start_page=1&items_per_page=20"
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
                    "application_periods": [
                            {
                                "begin": "2014-03-29T16:52:00Z",
                                "end": "2014-05-22T02:15:00Z"
                            }
                    ],
                    "send_notifications": true,
                    "notification_date": "2014-04-31T17:00:00Z",
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
                                    "types": ["sms", "notification"]
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
```

# List of Impacts [/disruptions/{disruption_id}/impacts]

## Retrieve impacts [GET]

Return all impacts of a impact.

### Parameters

| Name           | description                                      | required | default |
| -------------- | ------------------------------------------------ | -------- | ------- |
| start_page    | index of the first element returned (start at 1) | false    | 1       |
| items_per_page | number of items per page                         | false    | 20      |

- [Headers](#headers)


### Response 200 (application/json)

```javascript
{
    "impacts": [
        {
        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea",
        "self": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f32b2-e8df-11e3-8c3e-0008ca8657ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"},
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "send_notifications": true,
        "notification_date": "2014-04-31T17:00:00Z",
        "severity": {
            "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea",
            "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "color": "#123456",
            "priority": null,
            "effect": null
        },
        "application_period_patterns": [],
        "application_periods": [
            {
                "begin": "2014-04-31T16:52:00Z",
                "end": "2014-05-22T02:15:00Z"
            }
        ],
        "messages":[
            {
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ca",
                "created_at": "2014-04-31T16:52:18Z",
                "updated_at": "2014-04-31T16:55:18Z",
                "text": "ptit dej à la gare!!",
                "publication_date": ["2014-04-31T16:52:18Z"],
                "publication_period": null,
                "channel": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657da",
                    "name": "message court",
                    "content_type": "text/plain",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "max_size": 140,
                    "types": ["web", "mobile"]
                }
            },
            {
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8257ea",
                "created_at": "2014-04-31T16:52:18Z",
                "updated_at": "2014-04-31T16:55:18Z",
                "text": "#Youpi\n**aujourd'hui c'est ptit dej en gare",
                "publication_period" : {
                    "begin":"2014-04-31T17:00:00Z",
                    "end":"2014-05-01T17:00:00Z"
                },
                "publication_date" : null,
                "channel": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008cb8657ea",
                    "name": "message long",
                    "content_type": "text/markdown",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "max_size": null,
                    "types": ["web", "mobile"]
                }
            }
        ],
        "objects": [
            {
                "id": "stop_area:RTP:SA:3786125",
                "name": "HENRI THIRARD - LEON JOUHAUX",
                "type": "stop_area",
                "coord": {
                    "lat": "48.778867",
                    "lon": "2.340927"
                }
            },
            {
                "id": "line:RTP:LI:378",
                "name": "DE GAULLE - GOUNOD - TABANOU",
                "type": "line",
                "code": 2,
                "color": "FFFFFF"
            }
        ],
        "disruption" : {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea"}
        }
    ],
    "meta": {
        "pagination": {
        "start_page": 1,
        "items_per_page": 3,
        "total_results": 6,
        "prev": null,
        "next": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea/impacts?start_page=4&items_per_page=3"},
        "first": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea/impacts?start_page=1&items_per_page=3"},
        "last": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-823e-0008ca8657ea/impacts?start_page=4&items_per_page=3"}
        }
    }
}
```

## Create an impact [POST]

Create a new impact.

### Request

- [Headers](#headers)
- body

```javascript
{
    // REQUIRED.
    "severity": {
        // REQUIRED.
        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"
    },
    // OPTIONAL.
    "application_periods": [
        {
            // REQUIRED. PHP date : 'Y-m-d\TH:i:s\Z'
            "begin": "2014-04-31T16:52:00Z",
            // REQUIRED. PHP date : 'Y-m-d\TH:i:s\Z', can be null
            "end": "2014-05-22T02:15:00Z"
        }
    ],
    // OPTIONAL.
    "messages": [
        {
            // REQUIRED.
            "text": "ptit dej à la gare!!",
            // REQUIRED.
            "channel": {
                // REQUIRED.
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea"
            }
        },
        {
            // REQUIRED.
            "text": "#Youpi\n**aujourd'hui c'est ptit dej en gare",
            // REQUIRED.
            "channel": {
                // REQUIRED.
                "id": "3d1f42b2-e8df-11e3-8c3e-0002ca8657ea"
            }
        }
    ],
    // OPTIONAL.
    "objects": [
        {
            // REQUIRED. max length 250
            "id": "stop_area:RTP:SA:3786125",
            // REQUIRED. in this list ["network", "stop_area", "line", "line_section", "route", "stop_point"]
            "type": "stop_area"
        },
        {
            // REQUIRED. max length 250
            "id": "line:AME:3",
            // REQUIRED. in this list ["network", "stop_area", "line", "line_section", "route", "stop_point"]
            "type": "line_section"
            // OPTIONAL.
            "line_section": {
                // REQUIRED.
                "line": {
                    // REQUIRED. max length 250
                    "id":"line:AME:3",
                    // REQUIRED. in this list ["line"]
                    "type":"line"
                },
                // REQUIRED.
                "start_point": {
                    // REQUIRED. max length 250
                    "id":"stop_area:MTD:SA:154",
                    // REQUIRED. in this list ["stop_area"]
                    "type":"stop_area"
                },
                // REQUIRED.
                "end_point": {
                    // REQUIRED. max length 250
                    "id":"stop_area:MTD:SA:155",
                    // REQUIRED. in this list ["stop_area"]
                    "type":"stop_area"
                },
                // OPTIONAL. Integer, Default null
                "sens":0,
                // OPTIONAL.
                "routes":[
                   {
                        // REQUIRED. max length 250
                        "id": "route:MTD:9",
                        // REQUIRED. in this list ["route"]
                        "type": "route"
                   },
                   {
                        // REQUIRED. max length 250
                        "id": "route:MTD:10",
                        // REQUIRED. in this list ["route"]
                        "type": "route"
                   },
                   {
                        // REQUIRED. max length 250
                        "id": "route:MTD:Nav24",
                        // REQUIRED. in this list ["route"]
                        "type": "route"
                   }
                ],
                // OPTIONAL.
                "via":[
                    {
                        // REQUIRED. max length 250
                        "id":"stop_area:MTD:SA:154",
                        // REQUIRED. in this list ["stop_area"]
                        "type":"stop_area"
                    }
                ]
            }
        }
    ],
    // OPTIONAL.
    "send_notifications": true,
    // OPTIONAL. PHP date : 'Y-m-d\TH:i:s\Z'
    "notification_date": "2014-04-31T17:00:00Z"
}
```

### Response 201 (application/json)

```javascript
{
    "impact": {
        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
        "self": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "send_notifications": true,
        "notification_date": "2014-04-31T17:00:00Z",
        "severity": {
            "id": "3d1f42b2-e8df-11e3-8c3e-0008ca861aea",
            "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "color": "#123456",
            "priority": 1,
            "effect": null
        },
        "application_period_patterns": []
        "application_periods": [
            {
                "begin": "2014-04-31T16:52:00Z",
                "end": "2014-05-22T02:15:00Z"
            }
        ],
        "messages": [
            {
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8631ea",
                "created_at": "2014-04-31T16:52:18Z",
                "updated_at": "2014-04-31T16:55:18Z",
                "text": "ptit dej à la gare!!",
                "publication_date": ["2014-04-31T16:52:18Z"],
                "publication_period": null,
                "channel": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86a7ea",
                    "name": "message court",
                    "content_type": "text/plain",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "max_size": 140,
                    "types": ["web", "mobile"]
                }
            },
            {
                "id": "3d1f42b2-e8df-11a3-8c3e-0008ca8617ea",
                "created_at": "2014-04-31T16:52:18Z",
                "updated_at": "2014-04-31T16:55:18Z",
                "text": "#Youpi\n**aujourd'hui c'est ptit dej en gare",
                "publication_period" : {
                    "begin":"2014-04-31T17:00:00Z",
                    "end":"2014-05-01T17:00:00Z"
                },
                "publication_date" : null,
                "channel": {
                    "id": "3d1f42b2-e8af-11e3-8c3e-0008ca8617ea",
                    "name": "message long",
                    "content_type": "text/markdown",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "max_size": null,
                    "types": ["web", "mobile"]
                }
            }
        ],
        "objects": [
            {
                "id": "stop_area:RTP:SA:3786125",
                "name": "HENRI THIRARD - LEON JOUHAUX",
                "type": "stop_area",
                "coord": {
                    "lat": "48.778867",
                    "lon": "2.340927"
                }
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
        "disruption" : {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
    },
    "meta": {}
}
```

### Errors

- 400 (application/json)
- 404 (application/json)
- 500 (application/json)
- 503 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

## Update a impact [PUT]

### Request

- [Headers](#headers)
- Body like [POST](#create-an-impact-post)

```javascript
{
    "impact": {
        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
        "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "send_notifications": true,
        "notification_date": "2014-04-31T17:00:00Z",
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
                    "types": ["web", "mobile"]
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
        "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
    },
    "meta": {}
}
```

### Response 200 (application/json)

```javascript
{
    "impact": {
        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
        "self": {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "send_notifications": true,
        "notification_date": "2014-04-31T17:00:00Z",
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
                    "types": ["web", "mobile"]
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
        "disruption" : {"href": "https://ogv2ws.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
    },
    "meta": {}
}
```

### Errors

- 400 (application/json)
- 404 (application/json)
- 500 (application/json)
- 503 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

## Delete an impact [DELETE]

Archive one impact.

- [Headers](#headers)

### Response 204 NO CONTENT

Impact archived

### Errors

- 404 (application/json)
- 500 (application/json)
- 503 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

# Impact [/disruptions/{disruption_id}/impacts/{id}]

## Retrieve a impact [GET]

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "impact": {
        "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8617ea",
        "self": {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-8c3e-0008ca8647ea/impacts/3d1f42b2-e8df-11e3-8c3e-0008ca8617ea"},
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "send_notifications": true,
        "notification_date": "2014-04-31T17:00:00Z",
        "severity": {
            "id": "3d1f42b2-e8df-11e3-8c3e-0008ca861aea",
            "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "color": "#123456",
            "priority": 1,
            "effect": null
        },
        "application_period_patterns": [],
        "application_periods": [
            {
                "begin": "2014-04-31T16:52:00Z",
                "end": "2014-05-22T02:15:00Z"
            }
        ],
        "messages": [
            {
                "id": "3d1f42b2-e8df-11e3-8c3e-0008ca8631ea",
                "created_at": "2014-04-31T16:52:18Z",
                "updated_at": "2014-04-31T16:55:18Z",
                "text": "ptit dej à la gare!!",
                "publication_date": ["2014-04-31T16:52:18Z"],
                "publication_period": null,
                "channel": {
                    "id": "3d1f42b2-e8df-11e3-8c3e-0008ca86a7ea",
                    "name": "message court",
                    "content_type": "text/plain",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "max_size": 140,
                    "types": ["web", "mobile"]
                }
            },
            {
                "id": "3d1f42b2-e8df-11a3-8c3e-0008ca8617ea",
                "created_at": "2014-04-31T16:52:18Z",
                "updated_at": "2014-04-31T16:55:18Z",
                "text": "#Youpi\n**aujourd'hui c'est ptit dej en gare",
                "publication_period" : {
                    "begin":"2014-04-31T17:00:00Z",
                    "end":"2014-05-01T17:00:00Z"
                },
                "publication_date" : null,
                "channel": {
                    "id": "3d1f42b2-e8af-11e3-8c3e-0008ca8617ea",
                    "name": "message long",
                    "content_type": "text/markdown",
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": "2014-04-31T16:55:18Z",
                    "max_size": null,
                    "types": ["web", "mobile"]
                }
            }
        ],
        "objects": [
            {
                "id": "stop_area:RTP:SA:3786125",
                "name": "HENRI THIRARD - LEON JOUHAUX",
                "type": "stop_area",
                "coord": {
                    "lat": "48.778867",
                    "lon": "2.340927"
                }
            },
            {
                "id": "line:RTP:LI:378",
                "name": "DE GAULLE - GOUNOD - TABANOU",
                "type": "line",
                "code": 2,
                "color": "FFFFFF"
            }
        ],
        "disruption" : {"href": "https://chaos.apiary-mock.com/disruptions/3d1f42b2-e8df-11e3-1c3e-0008ca8617ea"}
    },
    "meta": {}
}
```

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No disruption or impact"
    }
}
```

# List of severities [/severities]

## Retrieve the list of all severities [GET]

Return all the severities ordered by priority.

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "severities": [
        {
            "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
            "wordings" : [{"key": "msg", "value": "Normal"}],
            "effect": null,
            "priority": 1,
            "color": "#123456",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        },
        {
            "id": "3d1f42b4-e8df-11e3-8c3e-0008ca8617ea",
            "wordings" : [{"key": "msg", "value": "Majeur"}],
            "effect": null,
            "priority": 2,
            "color": "#123456",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        },
        {
            "id": "3d1f42b5-e8df-11e3-8c3e-0008ca8617ea",
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
```

## Create a severity [POST]

### Request

- [Headers](#headers)
- body

```javascript
{
    // REQUIRED.
    "wordings" : [
        {
            // REQUIRED. 1 > length <= 250
            "key": "msg",
            // REQUIRED.  max length 250
            "value": "Normal"
        }
    ],
    // OPTIONAL. max length 20, Default null
    "color": "#123456",
    // OPTIONAL. integer, Default null
    "priority": 1,
    // OPTIONAL. in this list ["no_service", "reduced_service", "significant_delays", "detour", "additional_service", "modified_service", "other_effect", "unknown_effect", "stop_moved"], can be null
    "effect": null
}
```

### Response 201 (application/json)

```javascript
{
    "severity": {
        "color": "#123456",
        "created_at": "2014-04-31T16:52:18Z",
        "effect": null,
        "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
        "priority": 1,
        "self": {
            "href": "http://localhost:5000/severities/3d1f42b3-e8df-11e3-8c3e-0008ca8617ea"
        },
        "updated_at": null,
        "wording": "Normal",
        "wordings": [
            {
                "key": "msg",
                "value": "Normal"
            }
        ]
    }
}
```

### Error 400 (application/json)

```javascript
{
    "error": {
        "message": "'wordings' is a required property"
    }
}
```

# List of causes [/causes]

## Retrieve the list of all causes [GET]

### Parameters

| Name                 | description                                                                               | required | default                 |
| -------------------- | ----------------------------------------------------------------------------------------- | -------- | ----------------------- |
| category             |  filter by category (id of category)                                                      | false    |                         |

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "causes": [
        {
            "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
            "wordings": [{"key": "msg", "value": "accident voyageur"}],
            "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "test"}
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        },
        {
            "id": "3d1f42b2-e8df-11e5-8c3e-0008ca8617ea",
            "wordings": [{"key": "msg", "value": "accident voyageur"}],
            "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "category-1"}
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        },
        {
            "id": "3d1f42b2-e8df-11e6-8c3e-0008ca8617ea",
            "wordings": [{"key": "msg", "value": "accident voyageur"}],
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        }
    ],
    "meta": {}
}
```

# List of tags [/tags]

## Retrieve the list of all tags [GET]

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "tags": [
        {
            "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
            "name": "meteo",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        },
        {
            "id": "3d1f42b2-e8df-11e5-8c3e-0008ca8617ea",
            "name": "probleme",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        },
        {
            "id": "3d1f42b2-e8df-11e6-8c3e-0008ca8617ea",
            "name": "rer",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z"
        }
    ],
    "meta": {}
}
```

## Create a tag [POST]

### Request

- [Headers](#headers)
- body

```javascript
{
    // REQUIRED. max length 250
    "name": "meteo"
}
```

### Response 201 (application/json)

```javascript
{
    "tag": {
        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
        "name": "meteo",
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": null
    },
    "meta": {}
}
```

### Error 400 (application/json)

```javascript
{
    "error": {
        "message": "'name' is a required property"
    }
}
```

# tags [/tags/{id}]

## Retrieve one tag [GET]

Retrieve one existing tag

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
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
```

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No tag"
    }
}
```

## Update a tag [PUT]

### Request

- [Headers](#headers)
- Body like [POST](#create-a-tag-post)

```javascript
{
    "name": "rer"
}
```

### Response 200 (application/json)

```javascript
{
    "tag": {
        "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
        "self": {
            "href": "https://ogv2ws.apiary-mock.com/tags/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
        }
        "name": "rer",
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z"
    }
}
```

### Errors

- 400 (application/json)
- 404 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

## Delete a tag [DELETE]

Archive a tag.

### Parameters

- [Headers](#headers)

### Response 204 NO CONTENT

Disruption archived

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No tag"
    }
}
```

# List of channel types [/channel_types]

## Retrieve the list of all channel types [GET]

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "channel_types": ["web", "sms", "email", "mobile", "notification", "twitter", "facebook"]
}
```

# List of channels [/channels]

## Retrieve the list of all channels [GET]

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "channels": [
        {
            "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
            "name": "court",
            "max_size": 140,
            "content_type": "text/plain",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "types": ["sms", "notification"]
        },
        {
            "id": "3d1a42b7-e8df-11e4-8c3e-0008ca8617ea",
            "name": "long",
            "max_size": 512,
            "content_type": "text/plain",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "types": ["mobile"]
        },
        {
            "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
            "name": "long riche",
            "max_size": null,
            "content_type": "text/markdown",
            "created_at": "2014-04-31T16:52:18Z",
            "updated_at": "2014-04-31T16:55:18Z",
            "types": ["web"]
        }
    ],
    "meta": {}
}
```

## Create a channels [POST]

### Request

- [Headers](#headers)
- body

```javascript
{
    // REQUIRED. max length 250
    "name": "court",
    // REQUIRED. integer
    "max_size": 140,
    // REQUIRED. max length 250
    "content_type": "text/plain",
    // REQUIRED. array from this list ["web", "sms", "email", "mobile", "notification", "twitter", "facebook"]
    "types": [
        "sms",
        "notification"
    ]
}
```

### Response 201 (application/json)

```javascript
{
    "channel": {
        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
        "name": "court",
        "max_size": 140,
        "content_type": "text/plain",
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "types": ["sms", "notification"]
    },
    "meta": {}
}
```

### Error 400 (application/json)

```javascript
{
    "error": {
        "message": "'name' is a required property"
    }
}
```

# Severities [/severities/{id}]

## Retrieve one severity [GET]

Retrieve one existing severity

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "severity": {
        "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
        "wordings" : [{"key": "msg", "value": "Normal"}],
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": null,
        "color": "#123456",
        "priority": 1,
        "effect": null
    },
    "meta": {}
}
```

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No severity"
    }
}
```

## Update a severity [PUT]

### Request

- [Headers](#headers)
- Body like [POST](#create-a-severity-post)

```javascript
{
    "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
    "color": "#123456",
    "effect": null
}
```

### Response 200 (application/json)

```javascript
{
    "severity": {
        "id": "3d1f42b3-e8df-11e3-8c3e-0008ca8617ea",
        "wordings" : [{"key": "msg", "value": "Bonne nouvelle"}],
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": "2014-04-31T16:55:18Z",
        "color": "#123456",
        "priority": 1,
        "effect": null
    },
    "meta": {}
}
```

### Errors

- 400 (application/json)
- 404 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

## Delete a severity [DELETE]

Archive one severity.

### Parameters

- [Headers](#headers)

### Response 204 NO CONTENT

Severity archived

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No severity"
    }
}
```

# Causes [/causes/{id}]

## Retrieve one cause [GET]

Retrieve one existing cause

### Parameters

- [Headers](#headers)

### Response 200 (application/json)

```javascript
{
    "cause": {
        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
        "wordings": [{"key": "msg", "value": "accident voyageur"}],
        "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be", "name": "test"}
        "created_at": "2014-04-31T16:52:18Z",
        "updated_at": null
    },
    "meta": {}
}
```

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No cause"
    }
}
```

## Create a cause [POST]

### Request

- [Headers](#headers)
- body

```javascript
{
    // OPTIONAL.
    "category": {
        // REQUIRED.
        "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be"
    },
    // REQUIRED.
    "wordings": [
        {
            // REQUIRED. 1 >= length <= 250
            "key": "msg_interne",
            // REQUIRED. max length 250
            "value": "Bebert a encore laissé une locomotive en double file"
        },
        {
            // REQUIRED. 1 >= length <= 250
            "key": "msg_media",
            // REQUIRED. max length 250
            "value": "train retardé"
        },
        {
            // REQUIRED. 1 >= length <= 250
            "key": "msg_sms",
            // REQUIRED. max length 250
            "value": "prenez le bus"
        }
    ],
    // OPTIONAL.
    "wording": "Message envoyé à navitia"
}
```

### Response 201 (application/json)

```javascript
{
    "cause": {
        "category": {
            "created_at": "2017-02-21T09:30:09Z",
            "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
            "name": "test",
            "self": {
                "href": "http://localhost:5000/categories/32b07ff8-10e0-11e4-ae39-d4bed99855be"
            },
            "updated_at": null
        },
        "created_at": "2017-02-21T09:38:59Z",
        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
        "self": {
            "href": "http://localhost:5000/causes/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
        },
        "wordings": [
            {
                "key": "msg_interne",
                "value": "Bebert a encore laissé une locomotive en double file"
            },
            {
                "key": "msg_media",
                "value": "train retardé"
            },
            {
                "key": "msg_sms",
                "value": "prenez le bus"
            }
        ]
    }
}
```

### Error 400 (application/json)

```javascript
{
    "error": {
        "message": "'wordings' is a required property"
    }
}
```

## Update a cause [PUT]

### Request

- [Headers](#headers)
- Body like [POST](#create-a-tag-post)

```javascript
{
    "category": {"id": "32b07ff8-10e0-11e4-ae39-d4bed99855be"},
    "wordings": [{"key": "msg_interne", "value": "Bebert va déplacer sa locomotive"}, {"key": "msg_media", "value": "train retardé"}, {"key": "msg_sms", "value": "le train va arriver"}],
    "wording": "train retardé"
}
```

### Response 200 (application/json)

```javascript
{
    "cause": {
        "category": {
            "created_at": "2017-02-21T09:30:09Z",
            "id": "32b07ff8-10e0-11e4-ae39-d4bed99855be",
            "name": "test",
            "self": {
                "href": "http://localhost:5000/categories/32b07ff8-10e0-11e4-ae39-d4bed99855be"
            },
            "updated_at": null
        },
        "created_at": "2017-02-21T09:38:59Z",
        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
        "self": {
            "href": "http://localhost:5000/causes/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
        },
        "wordings": [
            {
                "key": "msg_interne",
                "value": "Bebert va déplacer sa locomotive"
            },
            {
                "key": "msg_media",
                "value": "train retardé"
            },
            {
                "key": "msg_sms",
                "value": "le train va arriver"
            }
        ]
    }
}
```

### Errors

- 400 (application/json)
- 404 (application/json)

```javascript
{
    "error": {
        "message": "..."
    }
}
```

## Delete a cause [DELETE]

Archive a cause.

### Parameters

- [Headers](#headers)

### Response 204 NO CONTENT

Cause archived

### Error 404 (application/json)

```javascript
{
    "error": {
        "message": "No cause"
    }
}
```

# List of categories [/categories]

## Retrieve the list of all categories [GET]

- response 200 (application/json)

    * Body

            {
                "categories": [
                    {
                        "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                        "name": "meteo",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e5-8c3e-0008ca8617ea",
                        "name": "probleme",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    },
                    {
                        "id": "3d1f42b2-e8df-11e6-8c3e-0008ca8617ea",
                        "name": "rer",
                        "created_at": "2014-04-31T16:52:18Z",
                        "updated_at": "2014-04-31T16:55:18Z"
                    }
                ],
                "meta": {}
            }

## Create a category [POST]

- request
    + headers

            Content-Type: application/json
            X-Customer-Id: [customer id]

    * Body

            {
                "name": "meteo"
            }

- response 201 (application/json)

    * Body

            {
                "category": {
                    "id": "3d1f42b2-e8df-11e4-8c3e-0008ca8617ea",
                    "name": "meteo",
                    "self": {
                        "href": "http://localhost:5000/categories/3d1f42b2-e8df-11e4-8c3e-0008ca8617ea"
                    },
                    "created_at": "2014-04-31T16:52:18Z",
                    "updated_at": null
                }
            }

# categories [/categories/{id}]

## Retrieve one category [GET]

### Parameters

Retrieve one existing category:

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
                }
            }

## Update a category [PUT]

### Parameters

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
                }
            }

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No category"
                }
            }

- response 400 (application/json)
    * Body

            {
                "error": {
                    "message": "'name' is a required property"
                }
            }

## Delete a category [DELETE]

Archive a category.

### Parameters


- Response 204

- response 404 (application/json)
    * Body

            {
                "error": {
                    "message": "No category"
                }
            }

# Properties

## Retrieve the list of all properties

### Request

    Method
            GET
    Uri
            /properties
    Available arguments for filtering
            type, key
    Headers
            X-Customer-Id: [customer id]

### Response 200 OK (application/json)

    Body
            {
                "properties": [
                    {
                        "created_at": "2016-04-12T12:00:00Z",
                        "id": "10216aec-00ad-11e6-9f6d-0050568c8380",
                        "key": "almost-special",
                        "self": {
                            "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8380"
                        },
                        "type": "not_a_comment",
                        "updated_at": "2016-04-12T13:00:00Z"
                    },
                    {
                        "created_at": "2016-04-12T12:01:00Z",
                        "id": "10216aec-00ad-11e6-9f6d-0050568c8382",
                        "key": "special",
                        "self": {
                            "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8382"
                        },
                        "type": "comment",
                        "updated_at": "2016-04-12T13:01:00Z"
                    }
                ]
            }

## Retrieve one property by id

### Request

    Method
            GET
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8382
    Headers
            X-Customer-Id: [customer id]

### Response 200 OK (application/json)

    Body
            {
                "property": {
                    "created_at": "2016-04-12T12:01:00Z",
                    "id": "10216aec-00ad-11e6-9f6d-0050568c8382",
                    "key": "special",
                    "self": {
                        "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8382"
                    },
                    "type": "comment",
                    "updated_at": "2016-04-12T13:01:00Z"
                }
            }

### Request

    Method
            GET
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8381
    Headers
            X-Customer-Id: [customer id]

### Response 404 NOT FOUND (application/json)

    Body
            {
                "error": {
                    "message": "Property 10216aec-00ad-11e6-9f6d-0050568c8381 not found""
                }
            }

## Create a property

### Request

    Method
            POST
    Uri
            /properties
    Headers
            Content-Type: application/json
            X-Customer-Id: [customer id]
    Body
            {
                "key": "really-special",
                "type": "comment"
            }

### Response 201 CREATED (application/json)

    Body
            {
                "property": {
                    "created_at": "2016-04-12T14:00:00Z",
                    "id": "10216aec-00ad-11e6-9f6d-0050568c8383",
                    "key": "really-special",
                    "self": {
                        "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8383"
                    },
                    "type": "comment"
                }
            }

If a property with the same attributes 'key' and 'type' already exists in database:

### Request

    Method
            POST
    Uri
            /properties
    Headers
            Content-Type: application/json
            X-Customer-Id: [customer id]
    Body
            {
                "key": "special",
                "type": "comment"
            }

### Response 409 CONFLICT (application/json)

    Body
            {
                "error": {
                    "message": "(IntegrityError) duplicate key value violates unique constraint \"property_type_key_client_id_uc\"\nDETAIL:  Key (type, key, client_id)=(comment, special, 9dbf2fa4-86d0-11e4-b461-f01faf2a7e2a) already exists.\n"
                }
            }

### Request

    Method
            POST
    Uri
            /properties
    Headers
            Content-Type: application/json
            X-Customer-Id: [customer id]
    Body
            {
                "type": "comment"
            }

### Response 400 BAD REQUEST (application/json)

    Body
            {
                "error": {
                    "message": "'key' is a required property"
                }
            }

## Update a property

### Request

    Method
            PUT
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8382
    Headers
            Content-Type: application/json
            X-Customer-Id: [customer id]
    Body
            {
                "key": "special",
                "type": "datasource"
            }

### Response 200 OK (application/json)

    Body
            {
                "property": {
                    "created_at": "2016-04-12T12:01:00Z",
                    "id": "10216aec-00ad-11e6-9f6d-0050568c8382",
                    "key": "special",
                    "self": {
                        "href": "https://chaos.apiary-mock.com/properties/10216aec-00ad-11e6-9f6d-0050568c8382"
                    },
                    "type": "datasource",
                    "updated_at": "2016-04-12T14:01:00Z"
                }
            }

### Request

    Method
            PUT
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8381
    Headers
            Content-Type: application/json
            X-Customer-Id: [customer id]
    Body
            {
                "key": "special",
                "type": "datasource"
            }

### Response 404 NOT FOUND (application/json)

    Body
            {
                "error": {
                    "message": "Property 10216aec-00ad-11e6-9f6d-0050568c8381 not found""
                }
            }

### Request

    Method
            PUT
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8382
    Headers
            Content-Type: application/json
            X-Customer-Id: [customer id]
    Body
            {
                "type": "comment"
            }

### Response 400 BAD REQUEST (application/json)

    Body
            {
                "error": {
                    "message": "'key' is a required property"
                }
            }


## Delete a property

### Request

    Method
            DELETE
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8382
    Headers
            X-Customer-Id: [customer id]

### Response 204 NO CONTENT

### Request

    Method
            DELETE
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8381
    Headers
            X-Customer-Id: [customer id]

### Response 404 NOT FOUND (application/json)

    Body
            {
                "error": {
                    "message": "Property 10216aec-00ad-11e6-9f6d-0050568c8381 not found""
                }
            }

If the requested property is linked via associate_disruption_property table:

### Request

    Method
            DELETE
    Uri
            /properties/10216aec-00ad-11e6-9f6d-0050568c8380
    Headers
            X-Customer-Id: [customer id]

### Response 409 CONFLICT (application/json)

    Body
            {
                "error": {
                    "message": "The current <Property: 10216aec-00ad-11e6-9f6d-0050568c8380 comment almost_special> is linked to at least one disruption and cannot be deleted"
                }
            }

# Traffic reports [/traffic_reports]

This service provides the state of public transport traffic.

## Objects

Disruptions is an array of some impact objects.

Traffic_reports is an array of some traffic_report objects. One traffic_report object is a complex object, made of a network, an array of lines and an array of stop_areas.

A typical traffic_report object will contain:

- 1 **network** which is the grouping object

    it can contain links to its disruptions. These disruptions are globals and might not be applied on lines or stop_areas.

- 0..n **lines**
    each line contains at least a link to its disruptions

- 0..n **line_sections**
    each line_section contains at least a link to its disruptions, start_point, stop_point, the line, routes, meta and via if exist

- 0..n **stop_areas**
    each stop_area contains at least a link to its disruptions

- 0..n **stop_points**
    each stop_point contains at least a link to its disruptions

It means that if a stop_area is used by many networks, it will appear many times.

## Parameters

| Name                 | description                                                                    | required | default                 |
| -------------------- | ------------------------------------------------------------------------------ | -------- | ----------------------- |
| current_time         | parameter for settings the use by this request, mostly for debugging purpose   | false    | NOW                     |

- request
    * Headers

            Content-Type: application/json
            Authorization: [navitia token]
            X-Contributors: [contributor id]
            X-Coverage: [navitia coverage]


- response 200 (application/json)

    * Body

            {
                "disruptions": [
                    {
                        "application_periods": [
                            {
                                "begin": "2015-12-08T00:00:00Z",
                                "end": "2015-12-11T22:00:00Z"
                            }
                        ],
                        "cause": "Travaux",
                        "disruption_id": "8cc6a5ec-9d90-11e5-b08a-ecf4bb4460c7",
                        "id": "a3ca6a6e-9dca-11e5-b08a-ecf4bb4460c7",
                        "messages": [
                            {
                                "channel": {
                                    "content_type": "text/html",
                                    "id": "ffe4308f-7e4b-f211-8e74-4ed3e055a969",
                                    "max_size": 1000,
                                    "name": "email",
                                    "types": [
                                        "email"
                                    ]
                                },
                                "text": "<p>C'est entièrement gainé de plomb il n'y a plus rien à craindre.</p> <a href=\"http://navitia.io\">Pour navitia, cliquez ici</a>"
                            },
                            {
                                "channel": {
                                    "content_type": "text/plain",
                                    "id": "7a831bc8-8c5f-11e5-b2c5-ecf4bb4460c7",
                                    "max_size": 255,
                                    "name": "Titre (OV1)",
                                    "types": [
                                        "web"
                                    ]
                                },
                                "text": "Je suis pour toi OV1 "
                            },
                            {
                                "channel": {
                                    "content_type": "text/plain",
                                    "id": "90b61dbd-d5a0-3df4-c426-79f8893bbc60",
                                    "max_size": 160,
                                    "name": "sms",
                                    "types": [
                                        "sms"
                                    ]
                                },
                                "text": "T'as de beaux yeux tu sais"
                            }
                        ],
                        "severity": {
                            "color": "#FF4455",
                            "effect": "no_service",
                            "id": "69fb2a67-4e61-ff72-7ed6-65529f2502fc",
                            "name": "Blocking",
                            "priority": 0
                        },
                        "status": "active"
                    },
                    {
                        "application_periods": [
                            {
                                "begin": "2015-12-08T00:00:00Z",
                                "end": "2015-12-10T02:00:00Z"
                            }
                        ],
                        "cause": "Travaux",
                        "disruption_id": "8cc6a5ec-9d90-11e5-b08a-ecf4bb4460c7",
                        "id": "8cc97e3e-9d90-11e5-b08a-ecf4bb4460c7",
                        "messages": [
                            {
                                "channel": {
                                    "content_type": "text/plain",
                                    "id": "7a831bc8-8c5f-11e5-b2c5-ecf4bb4460c7",
                                    "max_size": 255,
                                    "name": "Titre (OV1)",
                                    "types": [
                                        "web"
                                    ]
                                },
                                "text": "That's a message OV1"
                            },
                            {
                                "channel": {
                                    "content_type": "text/plain",
                                    "id": "90b61dbd-d5a0-3df4-c426-79f8893bbc60",
                                    "max_size": 160,
                                    "name": "sms",
                                    "types": [
                                        "sms"
                                    ]
                                },
                                "text": "That's a message SMS"
                            },
                            {
                                "channel": {
                                    "content_type": "text/html",
                                    "id": "ffe4308f-7e4b-f211-8e74-4ed3e055a969",
                                    "max_size": 1000,
                                    "name": "email",
                                    "types": [
                                        "email"
                                    ]
                                },
                                "text": "That's a message mail"
                            }
                        ],
                        "severity": {
                            "color": "#FF4455",
                            "effect": "no_service",
                            "id": "69fb2a67-4e61-ff72-7ed6-65529f2502fc",
                            "name": "Blocking",
                            "priority": 0
                        },
                        "status": "past"
                    },
                    {
                        "application_periods": [
                            {
                                "begin": "2015-09-28T23:30:00Z",
                                "end": "2016-01-01T02:00:00Z"
                            }
                        ],
                        "cause": "Trafic",
                        "disruption_id": "0614bf52-8c60-11e5-b2c5-ecf4bb4460c7",
                        "id": "0615615a-8c60-11e5-b2c5-ecf4bb4460c7",
                        "messages": [
                            {
                                "channel": {
                                    "content_type": "text/plain",
                                    "id": "7a831bc8-8c5f-11e5-b2c5-ecf4bb4460c7",
                                    "max_size": 255,
                                    "name": "Titre (OV1)",
                                    "types": [
                                        "web"
                                    ]
                                },
                                "text": "Des travaux sur les voies interrompent la circulation. <a href=\"http://navitia.io\">Pour navitia, cliquez ici</a>    Pendant les travaux, covoiturez !"
                            }
                        ],
                        "severity": {
                            "color": "#FF4455",
                            "effect": "no_service",
                            "id": "69fb2a67-4e61-ff72-7ed6-65529f2502fc",
                            "name": "Blocking",
                            "priority": 0
                        },
                        "status": "active"
                    }
                ],
                "traffic_reports": [
                    {
                        "lines": [
                            {
                                "code": "D",
                                "id": "line:DUA:123456789",
                                "links": [
                                    {
                                        "id": "0615615a-8c60-11e5-b2c5-ecf4bb4460c7",
                                        "internal": true,
                                        "rel": "disruptions",
                                        "template": false,
                                        "type": "disruption"
                                    }
                                ],
                                "name": "Creil - Saturne / Mars / Pluton"
                            }
                        ],
                        "line_sections": [
                                    {
                                        "id": "7ffab234-3d49-4eea-aa2c-22f8680230b6",
                                        "line_section": {
                                            "end_point": {
                                                "id": "stop_area:DUA:SA:8775810",
                                                "type": "stop_area"
                                            },
                                            "line": {
                                                "id": "line:DUA:810801041",
                                                "name": "Cergy Le Haut / Poissy / St-Germain-en-Laye - Marne-la-Vall\u00e9e Chessy Disneyland / Boissy-St-L\u00e9ger",
                                                "type": "line",
                                                "code": "A"
                                            },
                                            "start_point": {
                                                "id": "stop_area:DUA:SA:8738221",
                                                "type": "stop_area"
                                            },
                                            "routes":[
                                               {
                                                   "id": "route:MTD:9",
                                                   "type": "route"
                                               },
                                               {
                                                   "id": "route:MTD:10",
                                                   "type": "route"
                                               },
                                               {
                                                   "id": "route:MTD:Nav24",
                                                   "type": "route"
                                               }
                                            ],
                                            "via":[
                                                {
                                                "id":"stop_area:MTD:SA:154",
                                                "type":"stoparea"
                                                }
                                            ],
                                            "metas": [
                                                {
                                                    "key": "direction",
                                                    "value": "5"
                                                },
                                                {
                                                    "key": "direction",
                                                    "value": "4"
                                                }
                                            ]
                                        },
                                        "links": [
                                            {
                                                "id": "0615615a-8c60-11e5-b2c5-ecf4bb4460c7",
                                                "internal": true,
                                                "rel": "disruptions",
                                                "template": false,
                                                "type": "disruption"
                                            }
                                        ],
                                        "type": "line_section"
                                    }
                                ],
                        "network": {
                            "id": "network:DUA777",
                            "name": "RESEAU D"
                        }
                    },
                    {
                        "network": {
                            "id": "network:DUA999",
                            "links": [
                                {
                                    "id": "a3ca6a6e-9dca-11e5-b08a-ecf4bb4460c7",
                                    "internal": true,
                                    "rel": "disruptions",
                                    "template": false,
                                    "type": "disruption"
                                },
                                {
                                    "id": "8cc97e3e-9d90-11e5-b08a-ecf4bb4460c7",
                                    "internal": true,
                                    "rel": "disruptions",
                                    "template": false,
                                    "type": "disruption"
                                }
                            ],
                            "name": "RESEAU A"
                        }
                    }
                ]
            }
