#!/bin/bash

#    Copyright (C) 2016  Oliver Faßbender
#    docker@intrepid.de
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
  # CPU
  /usr/local/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/CPUcore $MQTTPARAMETER -m "`echo "scale = 0 ; $(cat /sys/class/thermal/thermal_zone0/temp) / 1000" | bc -l `" &> /dev/null
  # GPU
  /usr/local/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/GPUcore $MQTTPARAMETER -m "`echo "scale = 0 ; $(cat /sys/class/thermal/thermal_zone1/temp) / 1000" | bc -l `" &> /dev/null

  BAT_PATH=""
  if [ -d /sys/class/power_supply/battery ]; then
    BAT_PATH="/sys/class/power_supply/battery"
  fi
  if [ -d /sys/class/power_supply/axp20x-battery ]; then
    BAT_PATH="/sys/class/power_supply/axp20x-battery"
  fi

  if [ -n "$BAT_PATH" ]; then
    /usr/local/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Temp $MQTTPARAMETER -m "`echo $(( $(grep 'POWER_SUPPLY_TEMP' $BAT_PATH/uevent | cut -d= -f2 ) / 10 ))`" &> /dev/null
    /usr/local/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Min $MQTTPARAMETER -m "`echo "$(grep 'POWER_SUPPLY_VOLTAGE_MIN_DESIGN' $BAT_PATH/uevent | cut -d= -f2 ) / 1000" | bc -l `" &> /dev/null
    /usr/local/bin/mosquitto_pub -h $MQTTBROKER -P $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Max $MQTTPARAMETER -m "`echo "$(grep 'POWER_SUPPLY_VOLTAGE_MAX_DESIGN' $BAT_PATH/uevent | cut -d= -f2 ) / 1000000" | bc -l `" &> /dev/null
    /usr/local/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Volt $MQTTPARAMETER -m "`echo "$(grep 'POWER_SUPPLY_VOLTAGE_NOW' $BAT_PATH/uevent | cut -d= -f2 ) / 1000000" | bc -l `" &> /dev/null
    /usr/local/bin/mosquitto_pub -h $MQTTBROKER -p $MQTTPORT -i $HOSTNAME -q 1 -t $MQTTBASE/$HOSTNAME/LiPo/Prozent $MQTTPARAMETER -m "`echo $(( $(grep 'POWER_SUPPLY_CAPACITY' $BAT_PATH/uevent | cut -d= -f2 ) ))`" &> /dev/null
  fi
  sleep 60
done

exit 1
