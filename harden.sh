#!/bin/bash
#Author: v-filip

function sshd_status {
	systemctl status ssh || service ssh status
}

function sshd_restart {
	systemctl restart ssh || service ssh restart
}

function config_ssh {
	#code
}

while true
do
	echo "----------------------------"
	echo "SSH OPTIONS"
	echo "1a) SSHd status"
	echo "2a) SSHd restart"
	echo "3a) Configure SSH"
	echo "----------------------------"
	echo "FIREWALL OPTIONS"
	echo "1b) UFW status"
	echo "2b) UFW enable"
	echo "3b) UFW disable"
	echo "4b) Configure UFW"
	echo "5b) Allow/Deny inbound port"
	echo "x) exit"
	echo "------_---------------------"
	read -p "Please make your selection: [ex. 1a] " ANSWER
	echo
	case $ANSWER in 
		1a)
			sshd_status
			echo "-------------------"
			echo "SSH status displyed"
			echo "-------------------"
			;;
		
		2a)
			sshd_restart
			echo "---------------------"
			echo "SSH daemon restarted!"
			echo "---------------------"
			;;

		3a)
			config_ssh
			echo "---------------------"
			echo "Done! SSH configured!"
			echo "---------------------"
			;;
#		4a)
#			#extra
#			#function
#			;;

		1b)
			#ufw status
			#function
			;;
		2b)
			#ufw enable
			#function
			;;
		3b)
			#ufw disable
			#function
			;;
		4b)
			#config ufw
			#function
			;;
		5b)
			#allow deny inbound port
			#function
			;;
#		6b)
#			#extra
#			#function
#			;;


		x)
			echo "--------------------------------------"
			echo "Thank you for using v-filip/harden.sh!"
			echo "--------------------------------------"
			echo
			sleep 1
			break
			;;

		*)
			echo "----------------------------------------------------------------------"
			echo "Invalid input, please use one of the provided selections (Example. 1)!"
			echo "----------------------------------------------------------------------"
			;;
	esac
done
