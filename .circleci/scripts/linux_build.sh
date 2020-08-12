#!/bin/bash

# Build torchserve
python setup.py bdist_wheel --release --universal
TS_BUILD_EXIT_CODE=$?

# Build model archiver
cd model-archiver/
python setup.py bdist_wheel --release --universal
MA_BUILD_EXIT_CODE=$?

# If any one of the builds fail, exit with error
if [ "$TS_BUILD_EXIT_CODE" -ne 0 ] || [ "$MA_BUILD_EXIT_CODE" -ne 0 ]
then exit 1
fi