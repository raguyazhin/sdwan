#!/bin/bash

#ip route
route=$(route -n)
 
route=${route//Kernel IP routing table/}

echo ${route}

# declare -A routearr

# i=0
# j=0

# for VARIABLE in $route
# do

#     if [ $j == 8 ]; then
#         i=$(($i+1))
#         j=0
#     fi

#     routearr[${i},${j}]=$VARIABLE
#     j=$(($j+1))
 
# done

# echo ${routearr}

