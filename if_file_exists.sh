#!/bin/bash

source /root/sdwan/path.sh

file=$1

if test -f "$file"; then
    echo true
else
    echo false
fi