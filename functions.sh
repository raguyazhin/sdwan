#!/bin/bash

source /root/sdwan/path.sh

get_network () {
	ipcalc $(ip addr show $1 | grep 'inet' | grep -v ":" | awk '{print $2}') | awk -F = '{print $1}'  | grep ^"Network" | awk '{print $2}'
}

get_ip_address () {
	ip -f inet addr show $1 | grep -Po 'inet \K[\d.]+' | head -n1
}

get_gateway () {
	ip route show default | grep ^"default" | awk '{print $3, $5}'  | grep $1 | awk '{print $1}'
}
          
get_netmask () {
	ipcalc $(ip addr show $1 | grep 'inet' | grep -v ":" | awk '{print $2}') | awk -F = '{print $1}'  | grep ^"Netmask" | awk '{print $2}'
}

get_network4lan () {
	ipcalc $1 $2 | grep "Network" | awk '{print $2}'  
}

get_hostmin () {
	ipcalc $1 | grep HostMin | awk '{$1=$1};1' | cut -d' ' -f2
}


#////////////////////////////////////////////////////////////////////////////////////////

get_address () {
	ipcalc $1 | grep Address | awk '{$1=$1};1' | cut -d' ' -f2
}

get_mask () {
	ipcalc $1 | grep Netmask | awk '{$1=$1};1' | cut -d' ' -f2
}

get_next_ip () {
	echo $(echo "$1" | cut -d. -f1).$(echo "$1" | cut -d. -f2).$(echo "$1" | cut -d. -f3).$(($(echo "$1" | cut -d. -f4) + 1))
}

get_last_ip () {
	echo $(echo "$1" | cut -d. -f1).$(echo "$1" | cut -d. -f2).$(echo "$1" | cut -d. -f3).$(($(echo "$1" | cut -d. -f4) + 99))
}

ip2ascii () {

    #Returns the integer representation of an IP arg, passed in ascii dotted-decimal notation (x.x.x.x)
    IP=$1; IPNUM=0
    for (( i=0 ; i<4 ; ++i )); do
    ((IPNUM+=${IP%%.*}*$((256**$((3-${i}))))))
    IP=${IP#*.}
    done
    echo $IPNUM 
} 

ascii2ip () {
    #returns the dotted-decimal ascii form of an IP arg passed in integer format
    echo -n $(($(($(($((${1}/256))/256))/256))%256)).
    echo -n $(($(($((${1}/256))/256))%256)).
    echo -n $(($((${1}/256))%256)).
    echo $((${1}%256)) 
}

display_time () {
	local T=$1
	local D=$((T/60/60/24))
	local H=$((T/60/60%24))
	local M=$((T/60%60))
	local S=$((T%60))
	(( $D > 0 )) && printf '%d days ' $D
	(( $H > 0 )) && printf '%d hours ' $H
	(( $M > 0 )) && printf '%d minutes ' $M
	(( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
	printf '%d seconds\n' $S
}

if_intf_exist() {

	if [[ -f "${PHYINTFPATH}/$1" ]] || [[ -f "${USRCONFPATH}/$1" ]]; then
    	echo "1"
	else
		echo "0"
	fi
}

if_phy_intf() {

	if [ -f "${PHYINTFPATH}/$1" ]; then
    	echo "1"
	else
		echo "0"
	fi
}

if_usr_intf() {

	if [ -f "${USRCONFPATH}/$1" ]; then
    	echo "1"
	else
		echo "0"
	fi
}

get_intf_type() {

	if [ $(if_intf_exist $1) = "1" ]; then

		if [ $(if_phy_intf $1) = "1" ]; then

			intf_type=$(cat ${PHYINTFPATH}/$1 | grep 'interfacetype' | cut -d'=' -f2)

		elif [ $(if_usr_intf $1) = "1" ]; then

			intf_type=$(cat ${USRCONFPATH}/$1 | grep 'interfacetype' | cut -d'=' -f2)

		else

			intf_type="none"

		fi

		echo $intf_type

	else

		echo "interface $1 not exist"

	fi

}

