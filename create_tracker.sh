#!/bin/bash

source /root/sdwan/path.sh

# -p INTFPATH
# -n INTERFACE
# -u UPDTINTF 

while getopts p:n:u: option 
do 
    case "${option}" 
    in 
        p) INTFPATH=${OPTARG};; 
        n) INTERFACE=${OPTARG};; 
        u) UPDTINTF=${OPTARG};;         
    esac 
done 


if [ -z $INTFPATH ]; then
    echo "provide -p INTERFACE PATH"
    exit 1
fi

if [ -z $INTERFACE ]; then
    echo "provide -n INTERFACE NAME"
    exit 1
fi

if [ -z $UPDTINTF ]; then
    echo "provide -u UPDT INTF"
    exit 1
fi

file_str='source /root/sdwan/path.sh''\n'
file_str+='source ${APPPATH}/functions.sh''\n\n'

file_str+='intfpath="'${INTFPATH}'"\n'
file_str+='intf="'${INTERFACE}'"\n'
file_str+='updtintf='${UPDTINTF}'\n\n'

file_str+='source ${APPPATH}/tracker_template.sh''\n'

echo -ne $file_str &> ${TRACKERPATH}/${INTERFACE}.sh
chmod 0755 ${TRACKERPATH}/${INTERFACE}.sh