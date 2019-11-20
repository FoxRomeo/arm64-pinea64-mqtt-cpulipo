#!/bin/bash

VERSION=`curl -s "http://mosquitto.org/download/" | grep 'a href="https://mosquitto.org/files/source/mosquitto-' | sed -n -e 's/^.*\.tar\.gz">mosquitto-'//p | sed -n -e 's/\.tar\.gz<\/a> .*$'//p`

echo ${VERSION}