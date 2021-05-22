#!/bin/bash
path=/home/pi/monitoring_logs
mkdir -p $path

if [ -z $1 ]; then
	echo "please supply check name: disk, swap, ping, uptime, ram"
	exit 2;
else
	check=$1
fi

if [[ $check == 'disk' ]]; then
	if [ ! -f $path/$check.csv ]; then
		echo "Date;Result" >> $path/$check.csv
	fi
	echo -n $(date) >> $path/disk.csv
	echo -n ";" >> $path/disk.csv
	sudo df -m / | grep -i "/dev/root" | awk '{print $5}' >> $path/disk.csv
fi

if [[ $check == 'swap' ]]; then
	if [ ! -f $path/$check.csv ]; then
		echo "Date;Result" >> $path/$check.csv
	fi
	logname=swap
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(sudo free -m|grep Swap:| awk '{print $4/$2 * 100 "%"}')
	echo $results >> $path/$logname.csv
fi

if [[ $check == 'ping' ]]; then
	if [ ! -f $path/$check.csv ]; then
		echo "Date;Result" >> $path/$check.csv
	fi
	logname=ping
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(ping -c 1 google.com &>/dev/null ; echo $?)
	echo $results >> $path/$logname.csv
fi

if [[ $check == 'uptime' ]]; then
	if [ ! -f $path/$check.csv ]; then
		echo "Date;Result" >> $path/$check.csv
	fi
	logname=uptime
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(awk '{print int($1/3600)}' /proc/uptime)
	echo $results >> $path/$logname.csv
fi

if [[ $check == 'ram' ]]; then
	if [ ! -f $path/$check.csv ]; then
		echo "Date;Result" >> $path/$check.csv
	fi
	logname=ram
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	results=$(sudo free -m|grep Mem:| awk '{print $4/$2 * 100 "%"}')
	echo $results >> $path/$logname.csv
fi

if [[ $check == 'command' ]]; then
	if [ ! -f $path/$check.csv ]; then
		echo "Date;Result" >> $path/$check.csv
	fi
	logname=command
	echo -n $(date) >> $path/$logname.csv
	echo -n ";" >> $path/$logname.csv
	if [ -f "$path/command.last" ]; then
		first=$(cat $path/command.last)
		second=$(date +%s)
		diff=$(($second - $first))
	else
		diff=0
	fi
	date +%s > $path/command.last
	echo $diff >> $path/$logname.csv
fi

if [[ $check == 'service' ]]; then
	process=$2
	if [ ! -f $path/service_$process.csv ]; then
		echo "Date;Result" >> $path/service_$process.csv
	fi
	logname=$process
	result=$(systemctl status $process|grep "Active"|awk {'print $2'})
	if [[ $result -eq 'active' ]]; then
		result=1
	else
		result=0
	fi
	echo -n $(date) >> $path/service_$logname.csv
	echo -n ";" >> $path/service_$logname.csv
	echo $result >> $path/service_$logname.csv
	exit 0;
fi

if [[ $check == 'process' ]]; then
	process=$2
	if [ ! -f $path/process_$process.csv ]; then
		echo "XYZ"
		echo "Date;Result" >> $path/process_$process.csv
	fi
	logname=$process
	result=$(ps -ef|grep -i $process|grep -vi 'grep'|wc -l)
	echo -n $(date) >> $path/process_$logname.csv
	echo -n ";" >> $path/process_$logname.csv
	echo $result >> $path/process_$logname.csv
fi
