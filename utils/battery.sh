#!/bin/zsh

# Instructions for adding this in cronjob
# 0 */6 * * * ~/dotfiles/utils/battery.sh -r "$HOME/battery.csv" >/dev/null 2>&1
# Add above line in crontab by running $ "crontab -e"
# check if it's active $ "crontab -l"

show_battery_help() {
	echo "	* Use -r [CSV_PATH] for starting the battery log or directly run function $ batterylog"
	echo "	* Use showbatterylog [n] function for checking last n entries"
}

batterylog() {
	if [[ "$OSTYPE" != "darwin"* ]] ;then
        echo "Battery log is only for macOS. Not Supported OS."
		return 0
	fi

	if [ $# -eq 1 ] ;then
		if [ "$1" = "-h" ] ;then
			show_battery_help
			return 0
		fi
		local readonly CSV_PATH=$1	# Use Passed argument
	else
		local readonly CSV_PATH=$BATTERY_LOG_PATH
	fi

	echo "Battery log started"

	system_power_data=$(/usr/sbin/system_profiler SPPowerDataType)

	fully_charged=$(echo "$system_power_data" | grep "Fully Charged" | awk '{print $3}')
	charging=$(echo "$system_power_data" | grep "Charging" -m 1 | awk '{print $2}')
	full_charge_capacity=$(echo "$system_power_data" | grep "Full Charge Capacity (mAh)" | awk '{print $5}')
	state_of_charge=$(echo "$system_power_data" | grep "State of Charge (%)" | awk '{print $5}')
	cycle_count=$(echo "$system_power_data" | grep "Cycle Count" | awk '{print $3}')
	condition=$(echo "$system_power_data" | grep "Condition" | awk '{print $2}')

	# This will only work when system is connected to a power source
	connected=$(echo "$system_power_data" | grep "Connected" | awk '{print $2}')

	if [ "$connected" = "Yes" ] ;then
		ac_info=$(echo "$system_power_data" | grep "AC Charger Information:" -A10 )

		wattage=$(echo "$ac_info" | grep "Wattage (W)" | awk '{print $3}')
		ac_serial_number=$(echo "$ac_info" | grep "Serial Number" | awk '{print $3}')
		ac_name=$(echo "$ac_info" | grep "Name" | sed 's/ *Name: //')
		ac_firmware_ver=$(echo "$ac_info" | grep "Firmware Version" | awk '{print $3}')
	else
		wattage=""
		ac_serial_number=""
		ac_name=""
		ac_firmware_ver=""
	fi

	echo `date`,"$fully_charged,$charging,$full_charge_capacity,$state_of_charge,$cycle_count,$condition,"\
"$connected,$wattage,$ac_serial_number,$ac_name,$ac_firmware_ver" >> "$CSV_PATH"
	echo "Battery log saved in ${CSV_PATH}"
}

showbatterylog() {
	row_head=$(head -n 1 "$BATTERY_LOG_PATH")
	row_cols=$(tail -n ${1:-5} "$BATTERY_LOG_PATH")
	echo "$row_head\n$row_cols" | sed 's/,/ ,/g' | column -t -s, | less -S
}


if [ "$1" = "-h" ] ;then
	show_battery_help
	exit 0
elif [ "$1" = "-r" ] ;then
	echo $2
	if [ $# -ne 2 ] ;then
		echo 'Missing inline CSV_PATH after ./battery.sh -r "~/battery.csv"'
	else
		batterylog "$2"
	fi
fi