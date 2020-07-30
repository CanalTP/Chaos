#!/bin/sh

set -e

echo -n "Waiting for postgres to be reachables..."
until nc -z database 5432
do
    echo -n "."
    sleep 0.5
done
echo

if [ ! -d "venv" ]
then
    virtualenv venv
fi

. venv/bin/activate
pip install -r requirements.txt -i https://pypi.python.org/simple/
pip install coverage isort==4.3.8 pylint==1.9.2 -i https://pypi.python.org/simple/
python setup.py build_pbf
CHAOS_CONFIG_FILE=$(pwd)/tests/testing_settings.py nosetests ./tests/*.py --with-xunit --xunit-file=nosetest_chaos.xml  --with-coverage --cover-package=chaos --cover-xml
CHAOS_CONFIG_FILE=$(pwd)/tests/testing_settings.py coverage run --append --source=chaos $(which lettuce) --with-xunit --verbosity=3 --failfast tests/features
pylint --rcfile=pylint.rc --output-format=parseable chaos | cat > pylint.log
