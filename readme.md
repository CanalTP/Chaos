Chaos
======

Chaos is the web service which implements the realtime aspect of Navitia

You need to compile the protobuf before using chaos:
```
./setup.py build_pbf
```

To init database structure:
```
export CHAOS_CONFIG_FILE=./chaos/default_settings.py
./manage.py db upgrade
```
