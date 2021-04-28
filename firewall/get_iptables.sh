#!/bin/bash

while getopts t: option 
do 
    case "${option}" 
    in 
        t) IPTABLE_NAME=${OPTARG};;    
    esac 
done 

if [ -z $IPTABLE_NAME ]; then
   IPTABLE_NAME='filter'
fi

iptable=$(iptables -L -t ${IPTABLE_NAME} --line-number -n -v | tr '\n' '~')

iptable=$(echo "$iptable" | tr -s '~')

iptable=$(echo "$iptable" | tr -s ' ')

delimiter="Chain"
s=$iptable$delimiter

array=();

while [[ $s ]]; do
	array+=( "${s%%"$delimiter"*}" );
	s=${s#*"$delimiter"};	
done;

arrlen=${#array[@]}
arrayrow=();

for ((i=0; i<$arrlen; i++)); do
	chain=${array[$i]};

	delimiter='~'
	s=$chain$delimiter

	while [[ $s ]]; do
		coldata=( "${s%%"$delimiter"*}" );
		if [ ! -z "$coldata" ]; then
			arrayrow+=( "${s%%"$delimiter"*}" );
		else
			arrayrow+=( "CHAIN START" );
		fi
		s=${s#*"$delimiter"};
	done;
	
done

arrlen=${#arrayrow[@]}
iptable_str="";

for ((i=0; i<$arrlen; i++)); do
	iptable_str=$iptable_str"|"${arrayrow[$i]};
done

echo "$iptable_str";
