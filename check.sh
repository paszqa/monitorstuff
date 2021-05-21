#!/bin/bash
path=/home/pi/monitoring_logs
mkdir -p $path

if [ -z $1 ]; then
	echo "please supply check name: disk, swap, ping, uptime, ram"
	exit 2;
else
	check=$1
fi

if [[ $check -eq 'disk' ]]; then
	echo -n $(date) >> $path/disk.csv
	echo -n ";" >> $path/disk.csv
	sudo df -m / | grep -i "/dev/root" | awk '{print $5}' >> $path/disk.csv
fi

if [[ $check -eq 'swap' ]]; then
	logname=swap
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(sudo free -m|grep Swap:| awk '{print $4/$2 * 100 "%"}')
	echo $results >> $path/$logname.csv
fi

if [[ $check -eq 'ping' ]]; then
	logname=ping
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(ping -c 1 google.com &>/dev/null ; echo $?)
	echo $results >> $path/$logname.csv
fi

if [[ $check -eq 'uptime' ]]; then
	logname=uptime
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(awk '{print int($1/3600)}' /proc/uptime)
	echo $results >> $path/$logname.csv
fi

if [[ $check -eq 'ram' ]]; then
	logname=ram
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(sudo free -m|grep Mem:| awk '{print $4/$2 * 100 "%"}')
	echo $results >> $path/$logname.csv
fi

if [[ $check -eq 'command' ]]; then
	logname=command
	echo -n $(date) >> $path/$logname.log
	echo -n ";" >> $path/$logname.log
	if [ -f "$path/command.last" ]; then
		first=$(cat $path/command.last)
		second=$(date +%s)
		diff=$(($second - $first))
	else
		diff=0
	fi
	date +%s > $path/command.last
	echo $diff >> $path/$logname.log
fi
