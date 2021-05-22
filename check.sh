#!/bin/bash
path=/home/pi/monitoring_logs
mkdir -p $path


RunCheck () {
	check=$1
	
	VerifyOrCreateFile $path/$check.csv
	
	AddDateToFile $path/$check.csv
	
	case "$check" in
		"disk") results=$(sudo df -m / | grep -i "/dev/root" | awk '{print $5}') ;;
		"swap") results=$(sudo free -m|grep Swap:| awk '{print $4/$2 * 100 "%"}') ;;
		"ping") results=$(ping -c 1 google.com &>/dev/null ; echo $?) ;;
		"uptime") results=$(awk '{print int($1/3600)}' /proc/uptime) ;; 
		"ram") results=$(sudo free -m|grep Mem:| awk '{print $4/$2 * 100 "%"}') ;;
		"command") 
			if [ -f "$path/command.last" ]; then
				first=$(cat $path/command.last)
				second=$(date +%s)
				diff=$(($second - $first))
			else
				diff=0
			fi
			date +%s > $path/command.last
			results=$diff ;;
		"service")
			process=$2
			result=$(systemctl status $process|grep "Active"|awk {'print $2'})
			if [[ $result -eq 'active' ]]; then
				results=1
			else
				results=0
			fi ;;
		"process")
			process=$2
			results=$(ps -ef|grep -i $process|grep -vi 'grep'|wc -l) ;;
	esac
	
	results=$(echo $results | tr -d '%')
	echo $results >> $path/$check.csv
}

VerifyOrCreateFile () {
	file=$1
	#echo "Verifying file $file"
	if [ ! -f $file ]; then
		echo "Date;Result" >> $file
	fi
}

AddDateToFile () {
	file=$1
	#echo "Adding date to file $file"
	echo -n $(date +"%y-%m-%d %H:%M") >> $file
	echo -n ";" >> $file
}




if [ -z $1 ]; then
	echo "please supply check name: disk, swap, ping, uptime, ram"
	exit 2;
else
	check=$1
	RunCheck $check $2
fi

