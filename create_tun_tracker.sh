#!/bin/bash

source /root/sdwan/path.sh

# -c CLIENT_LOC_NETWORK
# -f FILE_NAME

while getopts c:f: option 
do 
    case "${option}" 
    in 
        c) CLIENT_LOC_NETWORK=${OPTARG};;  
        f) FILE_NAME=${OPTARG};;        
    esac 
done 


if [ -z $CLIENT_LOC_NETWORK ]; then
    echo "provide -c CLIENT LOCAL NETWORK"
    exit 1
fi

if [ -z $FILE_NAME ]; then
    echo "provide -f FILE NAME"
    exit 1
fi

if [ -f "$FILE_NAME" ]; then
    echo "$FILE exists."
    exit 1
fi

file_str='source /root/sdwan/path.sh''\n'
file_str+='source ${APPPATH}/functions.sh''\n\n'

file_str+='cli_loc_network="'${CLIENT_LOC_NETWORK}'"\n'
file_str+='file_name="'${FILE_NAME}'"\n\n'

file_str+='source ${APPPATH}/tun_tracker_template.sh''\n'

echo -ne $file_str &> ${TUNTRACKERPATH}/${FILE_NAME}.sh
chmod 0755 ${TUNTRACKERPATH}/${FILE_NAME}.sh