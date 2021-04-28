#!/bin/bash

result=$(ls -l /sys/class/net/ | grep -v virtual | awk '{print $9}')

echo $result