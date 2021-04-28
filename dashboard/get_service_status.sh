#!/bin/bash

mysql=$(service mysql status | grep Active | cut -d " " -f5)
dnsmasq=$(service dnsmasq status | grep Active | cut -d " " -f5)
hostapd=$(service hostapd status | grep Active | cut -d " " -f5)
openvpn=$(service openvpn status | grep Active | cut -d " " -f5)
ssh=$(service ssh status | grep Active | cut -d " " -f5)
influxdb=$(service influxdb status | grep Active | cut -d " " -f5)
eventtracker=$(service eventtrack status | grep Active | cut -d " " -f5)
ifplugstatus=$(service ifplugstatus status | grep Active | cut -d " " -f5)


echo "<table class='table'>
<thead>
<th scope='col'>Service</th>
<th scope='col'>Description</th>
<th scope='col'>Status</th>
<th scope='col'>Actions</th>
</thead>
<tr><td style='font-weight: bold'>MYSQL</td><td>MYSQL Service</td><td>"${mysql^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>DNSMASQ</td><td>DHCP Service</td><td>"${dnsmasq^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>HOSTAPD</td><td>WIFI Service</td><td>"${hostapd^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>OPENVPN</td><td>VPN Service</td><td>"${openvpn^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>SSH</td><td>SSH Service</td><td>"${ssh^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>INFLUXDB</td><td>Influx DB Service</td><td>"${influxdb^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>EVENTTRACK</td><td>Event Tracker Service</td><td>"${eventtracker^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
<tr><td style='font-weight: bold'>IFPLUGSTATUS</td><td>Ifplug Status Service</td><td>"${ifplugstatus^^}"</td><td><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-sync'></i></a><a class='btn-grid' href='javascript:void(0)' role='button'><i class='fas fa-power-off'></i></a></td></tr>
</table>"
