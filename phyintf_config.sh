#!/bin/bash

source /root/sdwan/path.sh

mapfile -t interface_name < <(lshw -class network | grep logical | awk '{print $3}')
mapfile -t interface_description < <(lshw -class network | grep description | awk '{print $2}')

cat /dev/null > ${DBPATH}/phyintf_type

for (( i=0; i<${#interface_name[@]}; i++ )); do 
    echo "${interface_name[$i]}","${interface_description[$i]}" &>> ${DBPATH}/phyintf_type; 
done

count=0

for (( i=0; i<${#interface_name[@]}; i++ )); do

    phyintf=${interface_name[$i]}

    count=$(( $count + 1 ))

    echo displayname=${phyintf} &> ${PHYINTFPATH}/${phyintf}
    echo interfacename=${phyintf} &>> ${PHYINTFPATH}/${phyintf}
    echo interfacetype=LAN &>> ${PHYINTFPATH}/${phyintf}
    
    if [ $count -eq 1 ]; then

        echo iptype=STATIC &>> ${PHYINTFPATH}/${phyintf}
        echo ipaddress=192.168.50.1 &>> ${PHYINTFPATH}/${phyintf}
        echo subnetmask=255.255.255.0 &>> ${PHYINTFPATH}/${phyintf}
        echo gateway=192.168.50.1 &>> ${PHYINTFPATH}/${phyintf}
        echo dns_1= &>> ${PHYINTFPATH}/${phyintf}
        echo dns_2= &>> ${PHYINTFPATH}/${phyintf}
        echo status=1 &>> ${PHYINTFPATH}/${phyintf}
        echo enable=YES &>> ${PHYINTFPATH}/${phyintf}

    else

        echo iptype=STATIC &>> ${PHYINTFPATH}/${phyintf}
        echo ipaddress=0.0.0.0 &>> ${PHYINTFPATH}/${phyintf}
        echo subnetmask=0.0.0.0 &>> ${PHYINTFPATH}/${phyintf}
        echo gateway=0.0.0.0 &>> ${PHYINTFPATH}/${phyintf}
        echo dns_1=8.8.8.8 &>> ${PHYINTFPATH}/${phyintf}
        echo dns_2==8.8.8.8 &>> ${PHYINTFPATH}/${phyintf}
        echo status=3 &>> ${PHYINTFPATH}/${phyintf}
        echo enable=NO &>> ${PHYINTFPATH}/${phyintf}

    fi

    ${APPPATH}/create_tracker.sh -p ${PHYINTFPATH} -n ${phyintf} -u 0

done

