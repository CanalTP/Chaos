Chaos
======

Chaos is the web service which implements the realtime aspect of Navitia

See [Documentation](./documentation/index.md)

## Installation instruction

After cloning, get submodules
```
git submodule init
git submodule update
```

Install system dependancies
```
apt-get install python python-dev libpq-dev rabbitmq-server
```

Install python dependancies (here in a virtualenv):
```
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

You need to compile the protobuf before using chaos:
```
./setup.py build_pbf
```

### With honcho

Install honcho
```
virtualenv venv
source venv/bin/activate
pip install honcho
```

create a file .env in the root of chaos and put this

```
CHAOS_CONFIG_FILE=default_settings.py
```

Init (or migrate) db
```
honcho run ./manage.py db upgrade
```

Launch app (by default on port 5000)

```
honcho start
```

#### Tests

```
cd tests
```

create .env file and put this

```
CHAOS_CONFIG_FILE=absolute/path/to/Chaos/tests/testing_settings.py
PYTHONPATH=..
```

Start unit tests: 

```
honcho run nosetests
```

Start functional tests:

```
honcho run lettuce
```

### Without honcho

To init database structure:
```
export CHAOS_CONFIG_FILE=./chaos/default_settings.py
./manage.py db upgrade
```

Start chaos with uwsgi
