errors_dict = {
    "page_index": {
        "id": "invalid_page_index",
        "message":"page_index argument value is not valid"
    },

    "items_per_page": {
        "id": "invalid_items_per_page",
        "message":"items_per_page argument value is not valid"
    },

    "parse_json": {
        "id": "invalid_json",
        "message": "Failed to parse JSON"
    },

    "schema_json": {
        "id": "invalid_json",
        "message": "Json schema is not valid"
    },

    "id_not_exist": {
        "id": "not_id_object",
        "message": "Object id not exist in database"
    }
}


class Error_Enum(object):
    page_index = "page_index"
    items_per_page = "items_per_page"
    json = "json"
    parse_json = "parse_json"
    schema_json = "schema_json"
    id_not_exist = "id_not_exist"


def get_message(enum):
    return errors_dict[enum]
