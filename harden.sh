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
	#UFW precheck
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

function awk_ufw {
	ufw status | grep Status | awk '{print $2}'
}

function ufw_status {
	#Option 1b
	#Checking whether ufw is installed
	ufw_installed

	local CHECK_STATUS=$(awk_ufw)
	if [ $CHECK_STATUS == "active" ]
	then
		echo "-------------------------"
		echo "Host firewall is enabled!"
		echo "-------------------------"
	elif [ $CHECK_STATUS == "inactive" ]
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

function ufw_enable {
	#Option 2b
	#Checking whether ufw is installed
	ufw_installed
	
	local CHECK_STATUS=$(awk_ufw)
	if [ $CHECK_STATUS == "active" ]
	then
		echo "----------------------------"
		echo "Firewall is already enabled!"
		echo "----------------------------"
	else
		echo "Before you enable the firewall, please ensure that at least inbound port for your ssh connection is open, "
	        echo "otherwise you'll be locked out if ssh is the only way to access the system!"
		echo "[Please type \"understood\" to continue]: " 
		read UNDERSTOOD_PROMPT
		if [[ $UNDERSTOOD_PROMPT == "understood" || $UNDERSTOOD_PROMPT == "UNDERSTOOD" ]]
		then
			echo y | ufw enable &> /dev/null
			if [ $? == "0" ]
			then
				echo "-----------------"
				echo "Firewall enabled!"
				echo "-----------------"
			else
				echo "------------------------------------------------------------------------------------------------------"
				echo "Something went wrong during the process, unsure whether firewall was enabled, please recheck manually!"
				echo "------------------------------------------------------------------------------------------------------"
			fi
		else
			echo "------------------------------------------------------"
			echo "Skipping the step since \"understood\" wasn't entered!"
			echo "------------------------------------------------------"
		fi
	fi
		
}

function ufw_disable {
	#Option 3b
	#Checking whether ufw is installed
	ufw_installed
	
	local CHECK_STATUS=$(awk_ufw)
	if [ $CHECK_STATUS == "inactive" ]
	then
		echo "----------------------------"
		echo "Firewall is already disabled"
		echo "----------------------------"
	else
		ufw disable &> /dev/null
		echo "------------------"
		echo "Firewall disabled!"
		echo "------------------"
	fi
}

function config_ufw {
	echo "Would you like to deny inbound traffic/allow outbound traffic by default? [y|n]"
	read UFW_ANSWER0
	echo "Would you like to allow inbound port 22? [y|n]: "
	read UFW_ANSWER1
	echo "Would you like to allow inbound port 222? [y|n] "
	read UFW_ANSWER2

	ufw_disable

	if [[ $UFW_ANSWER0 == 'y' || $UFW_ANSWER0 == 'Y' ]]
	then
		ufw default deny incoming &> /dev/null
		echo "----------------------------------------------"
		echo "Denying unspecified incoming ports by default!"
		echo "----------------------------------------------"
		ufw default allow outgoing &> /dev/null
		echo "-----------------------------------------------"
		echo "Allowing unspecified outbound ports by default!"
		echo "-----------------------------------------------"
	else
		echo "---------------------------------------------------"
		echo "Leaving default settings as they are at the moment!"
		echo "---------------------------------------------------"
	fi	

	if [[ $UFW_ANSWER1 == 'y' || $UFW_ANSWER1 == 'Y' ]]
	then
		ufw allow ssh &> /dev/null
		echo "------------------------"
		echo "Inbound port 22 allowed!"
		echo "------------------------"
	else
		ufw deny ssh &> /dev/null
		echo "----------------------------------"
		echo "Leaving inbound port 22 as denied!"
		echo "----------------------------------"
	fi

	if [[ $UFW_ANSWER2 == 'y' || $UFW_ANSWER2 == 'Y' ]]
	then
		ufw allow 222 &> /dev/null
		echo "-------------------------"
		echo "Inbound port 222 allowed!"
		echo "-------------------------"
	else
		ufw deny 222 &> /dev/null
		echo "-----------------------------------"
		echo "Leaving inbound port 222 as denied!"
		echo "-----------------------------------"
	fi 

	echo "-------------------------------------------------------------"
	echo "Leaving the firewall disabled, please enabled it if you wish!"
	echo "-------------------------------------------------------------"
}

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

while true
do
	echo "---------------------------"
	echo "SSH OPTIONS"
	echo "1a) SSHd status"
	echo "2a) SSHd restart"
	echo "3a) Configure SSH"
	echo "---------------------------"
	echo "FIREWALL OPTIONS"
	echo "1b) UFW status"
	echo "2b) UFW enable"
	echo "3b) UFW disable"
	echo "4b) Configure UFW"
	echo "5b) Allow/Deny inbound port"
	echo "c) Clear terminal"
	echo "x) Exit"
	echo "---------------------------"
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
			ufw_enable
			;;

		3b)
			ufw_disable
			;;

		4b)
			config_ufw
			;;

		5b)
			#allow deny inbound port
			#function
			;;
#		6b)
#			#extra
#			#function
#			;;

		c)
			clear
			echo "------------------"
			echo "Terminal clearned!"
			echo "------------------"
			;;

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
