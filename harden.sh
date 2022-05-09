#!/bin/bash
#Author: v-filip

function sshd_status {
	#Option 1a
	systemctl status ssh || service ssh status
}

function sshd_restart {
	#Option 2a
	systemctl restart ssh || service ssh restart
}

function config_ssh {
	#Option 3a
	#code
	echo "Under contraction"
}

function ufw_installed {
	#Option 1b
	ufw status &> /dev/null
	if [ $? == "0" ]
	then
		echo "----------------------------------"
		echo "UFW package exists on the machine!"
		echo "----------------------------------"
	else
		echo "--------------------------------------------------------"
		echo "UFW package is not installed - installing the package..."
		echo "--------------------------------------------------------"
		apt install ufw -y &> /dev/null
		if [ $? == "0" ]
		then
			echo "--------------"
			echo "UFW installed!"
			echo "--------------"
		else
			echo "-------------------------------------------------------------------------"
			echo "Something went wrong during the installation, please install it manually!"
			echo "-------------------------------------------------------------------------"
		fi
	fi
}

function ufw_status {
	#Checking whether ufw is installed
	ufw_installed

	UFW_STATUS=$(ufw status | grep Status | awk '{print $2}')
	if [ $UFW_STATUS == "active" ]
	then
		echo "-------------------------"
		echo "Host firewall is enabled!"
		echo "-------------------------"
	elif [ $UFW_STATUS == "inactive" ]
	then
		echo "--------------------------"
		echo "Host firewall is disabled!"
		echo "--------------------------"
	else
		echo "-----------------------------------------------------------------------------------"
		echo "Unknown reading, unable to determine whether host firewall is enabled or disabled!"
		echo "-----------------------------------------------------------------------------------"
	fi
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
			ufw_status
			echo "--------------------"
			echo "UFW status displyed!"
			echo "--------------------"
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
