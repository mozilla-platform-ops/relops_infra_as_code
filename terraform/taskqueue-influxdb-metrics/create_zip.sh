#!/usr/bin/env bash

set -e
set -x

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH"

rm -rf package
mkdir package
cd package || exit 1

# hack for osx's homebrew python
touch setup.cfg
printf '[install]\nprefix=  \n' > setup.cfg

pip3 install influxdb --target .
zip -r9 ../function.zip .
cd ..
zip -g function.zip function.py

# cleanup
rm -rf package

# inspect the result...
# zipinfo function.zip
