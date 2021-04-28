function ip2ascii
{
    #Returns the integer representation of an IP arg, passed in ascii dotted-decimal notation (x.x.x.x)
    IP=$1; IPNUM=0
    for (( i=0 ; i<4 ; ++i )); do
    ((IPNUM+=${IP%%.*}*$((256**$((3-${i}))))))
    IP=${IP#*.}
    done
    echo $IPNUM 
} 

function ascii2ip
{
    #returns the dotted-decimal ascii form of an IP arg passed in integer format
    echo -n $(($(($(($((${1}/256))/256))/256))%256)).
    echo -n $(($(($((${1}/256))/256))%256)).
    echo -n $(($((${1}/256))%256)).
    echo $((${1}%256)) 
}

CCDPATH='/etc/openvpn/server/ccd'

if [ ! -d ${CCDPATH} ] 
then
    mkdir -p ${CCDPATH}
fi

#if already ccd file exists

i=0

for ccdp in ${CCDPATH}/*; do

    ccdf=${ccdp##*/}

    cli_ip[i]=$(atoi $(cat ${CCDPATH}/${ccdf} | grep 'ifconfig-push' | cut -d' ' -f2))
    i+=1
    
done

for i in "${cli_ip[@]}"; do 
    echo "$i"; 
done



max=0
for v in ${cli_ip[@]}; do
    if (( $v > $max )); then max=$v; fi; 
done

echo $max

echo $(itoa $(($max + 1)))





#echo $(atoi "10.1.1.1")
#echo $(itoa "167837954")
