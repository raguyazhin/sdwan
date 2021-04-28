#!/bin/bash

source /root/sdwan/path.sh

result=$(ls -l ${PHYINTFPATH} | awk '{print $9}')

echo $result