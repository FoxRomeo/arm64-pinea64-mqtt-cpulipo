#!/bin/bash

#    Copyright (C) 2016  Oliver Faßbender
#	 docker@intrepid.de
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

HOSTNAME=`hostname`

while true; do
  /usr/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/CPUcore $MQTTPARAMETER -m "`cat /sys/class/thermal/thermal_zone0/temp`" &> /dev/null

  /usr/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Temp $MQTTPARAMETER -m "`echo $(( $(grep 'POWER_SUPPLY_TEMP' /sys/class/power_supply/battery/uevent | cut -d= -f2 ) / 10 ))`" &> /dev/null

  /usr/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Min $MQTTPARAMETER -m "`echo "$(grep 'POWER_SUPPLY_VOLTAGE_MIN_DESIGN' /sys/class/power_supply/battery/uevent | cut -d= -f2 ) / 1000" | bc -l | sed s/\"\.\"/\",\"/ `" &> /dev/null

  /usr/bin/mosquitto_pub -h $MQTTBROKER -P $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Max $MQTTPARAMETER -m "`echo "$(grep 'POWER_SUPPLY_VOLTAGE_MAX_DESIGN' /sys/class/power_supply/battery/uevent | cut -d= -f2 ) / 1000000" | bc -l | sed s/\"\.\"/\",\"/ `" &> /dev/null

  /usr/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Volt $MQTTPARAMETER -m "`echo "$(grep 'POWER_SUPPLY_VOLTAGE_NOW' /sys/class/power_supply/battery/uevent | cut -d= -f2 ) / 1000000" | bc -l | sed s/\"\.\"/\",\"/ `" &> /dev/null

  /usr/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Prozent $MQTTPARAMETER -m "`echo $(( $(grep 'POWER_SUPPLY_CAPACITY' /sys/class/power_supply/battery/uevent | cut -d= -f2 ) ))`" &> /dev/null

  sleep 60
done

exit 1
