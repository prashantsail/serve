#!/bin/bash

# Hack needed to make it work with existing benchmark.py
# benchmark.py expects jmeter to be present at a very specific location
mkdir -p /home/ubuntu/.linuxbrew/Cellar/jmeter/5.3/libexec/bin/
ln -s /opt/apache-jmeter-5.3/bin/jmeter /home/ubuntu/.linuxbrew/Cellar/jmeter/5.3/libexec/bin/jmeter

# Start TS and redirect console ouptut and errors to a log file
torchserve --start >> ts_console.log 2>&1
sleep 30

cd benchmarks
python benchmark.py latency
EXIT_CODE=$?

torchserve --stop

# Moving TS console log file to logs directory
# Just a convenience for CircleCI to pick up logs from one directory
cd ../
mv ts_console.log logs/

# Exit with the same error code as that of benchmark script
exit $EXIT_CODE