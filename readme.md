Chaos
======

Chaos is the web service which implements the realtime aspect of Navitia

See [Documentation](./documentation/index.md)

## Installation instruction

After clonning, get submodules
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

To init database structure:
```
export CHAOS_CONFIG_FILE=./chaos/default_settings.py
./manage.py db upgrade
```
