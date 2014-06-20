errors_dict = {
    "unknown": {
            "id": "unknown",
            "message":"unknown error"
        },
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
    },

    "database": {
        "id": "database_error",
        "message": "Access database failed"
    }
}

class ChaosException(Exception):
    def __init__(self, value):
        self.message = value
    def __str__(self):
        return repr(self.message)
