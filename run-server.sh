#!/bin/bash

honcho run ./manage.py db upgrade

honcho start
