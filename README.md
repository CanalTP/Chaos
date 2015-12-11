# Chaos

Chaos is the web service which implements the real-time aspect of Navitia

## Installation

Install [`pip`](https://pip.pypa.io/en/latest/installing/) and [`virtualenv`](http://virtualenv.readthedocs.org/en/latest/installation.html)

Install Python dependencies

```
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

You need to compile `protobuf` files before using chaos:

```
# Add `protobuf` files to the `proto` directory
# before executing the following command
./setup.py build_pbf
```
