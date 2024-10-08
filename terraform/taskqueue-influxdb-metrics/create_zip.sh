#!/usr/bin/env bash

set -e
set -x

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH" || exit 1

rm -rf package
mkdir package
cd package || exit 1

# hack for osx's homebrew python
touch setup.cfg
printf '[install]\nprefix=  \n' > setup.cfg

# install deps to .
pipenv requirements > requirements.txt
pipenv run pip install -r requirements.txt --target .

# create the zip
zip -r9 ../function.zip .
cd ..
zip -g function.zip function.py

# cleanup
rm -rf package

# inspect the result...
# zipinfo function.zip
