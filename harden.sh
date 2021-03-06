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
	#Making a backup
	ls /etc/ssh/sshd_config.bk &> /dev/null
	if [ $? == "0" ]
	then
		echo "---------------------"
		echo "Backup already exists"
		echo "---------------------"
	else
		echo "-------------------------------------"
		echo "Backup doesn't exist, creating one..."
		echo "-------------------------------------"
		sleep 1
		cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bk
		if [ $? == "0" ]
		then
			echo "---------------"
			echo "Backup created!"
			echo "---------------"
		else
			echo "-------------------------------------------------------"
			echo "Something went wrong during the creation of the backup!"
			echo "-------------------------------------------------------"
		fi
	fi

	echo "Would you like to change SSH's port number? [y|n]: "
	read SSH_ANSWER1

	if [[ $SSH_ANSWER1 == 'y' || $SSH_ANSWER1 == 'Y' ]]
	then
		echo "Would you like to use port 222? [y|n]: "
		read SSH_ANSWER2
		if [[ $SSH_ANSWER2 == 'y' || $SSH_ANSWER2 == 'Y' ]]
		then
			sed -i 's/\#Port\ 22/Port\ 222/g' /etc/ssh/sshd_config
			echo "---------------------------------"
			echo "SSH's port number changed to 222!"
			echo "---------------------------------"
		else
			echo "Understood, which port number would you like to use? [Please enter the port number]: "
			read SSH_ANSWER3
			sed -i s/\#Port\ 22/Port\ $SSH_ANSWER3/g /etc/ssh/sshd_config
			echo "-----------------------------------------"
			echo "SSH's port number changed to $SSH_ANSWER3"
			echo "-----------------------------------------"
		fi
	else
		echo "-------------------------"
		echo "Leaving SSH's port on 22!"
		echo "-------------------------"
	fi

	echo "Would you like to disable root? [y|n]: "
	read SSH_ANSWER4

	if [[ $SSH_ANSWER4 == 'y' || $SSH_ANSWER4 == 'Y' ]]
	then
		echo "Before root login gets disabled, which users would you allow to login? [Please enter the name of the user]"
		read SSH_ANSWER_USER

		sed -i s/\#LoginGraceTime\ 2m/AllowUsers\ $SSH_ANSWER_USER/g /etc/ssh/sshd_config

		sed -i 's/PermitRootLogin\ yes/PermitRootLogin\ no/g' /etc/ssh/sshd_config
		echo "-------------------"
		echo "Root login disabled"
		echo "-------------------"
	else
		echo "---------------------------"
		echo "Leaving root login enabled!"
		echo "---------------------------"
	fi

	echo "Would you that ssh connection terminates after a certion amount of time left idle? [y|n]: "
	read SSH_ANSWER5

	if [[ $SSH_ANSWER5 == 'y' || $SSH_ANSWER5 == 'Y' ]]
	then
		echo "After how much minutes of idle would you like to that the ssh conection terminates?"
		echo "[Please enter the time in seconds ex. 180]"
		read SSH_ANSWER6 
		sed -i s/\#ClientAliveInterval\ 0/ClientAliveInterval\ $SSH_ANSWER6/g /etc/ssh/sshd_config
		echo "----------------------------------------------------------------------"
		echo "Done! Idle connections will now terminate after $SSH_ANSWER6 second(s)"
		echo "----------------------------------------------------------------------"
	else
		echo "-----------------------------------------"
		echo "Skipping the step! Leaving it disabled..."
		echo "-----------------------------------------"
	fi

	echo "Would you like to disable Protocol 1? [y|n]: "
	read SSH_ANSWER6

	if [[ $SSH_ANSWER6 == 'y' || $SSH_ANSWER6 == 'Y' ]]
	then
		sed -i 's/\#\ default value./Protocol\ 2/g' /etc/ssh/sshd_config
		echo "-------------------"
		echo "Protocol 1 disabled"
		echo "-------------------"
	else
		echo "---------------------------"
		echo "Leaving Protocol 1 enabled!"
		echo "---------------------------"
	fi
	
	echo "Would you like to disable password login and enable keypair auth? [y|n]: "
	read SSH_ANSWER7
	if [[ $SSH_ANSWER7 == 'y' || $SSH_ANSWER7 == 'Y' ]]
	then
		echo "----------------------------------------------------------------------------------------------------------"
	        echo "Before proceeding, please copy your public key to your this server/host."
	        echo "If you don't have a keypair generated, you can use the command below on your local machine to generate it:"
	        echo
	        echo "ssh-keygen -t rsa -b 4092"
	        echo
	        echo "To copy it, you can use the command below:"
	        echo
	        echo "ssh-copy-id username@publicIpAddrOfThisHost"
	        echo
	        echo "Failure to do this step will result in a lockout"
	        echo "----------------------------------------------------------------------------------------------------------"
	        echo 
	        echo "Are you sure you did the step above and you want to continue? [type 'proceed' to continue]"
		read LOCKOUT
		if [[ $LOCKOUT == "proceed" || $LOCKOUT == "PROCEED" ]]
		then
		        sed -i 's/PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config
		        sed -i 's/UsePAM\ yes/UsePAM\ no/g' /etc/ssh/sshd_config
		        sed -i 's/ChallengeResponseAuthentication\ yes/ChallengeResponseAuthentication\ no/g' /etc/ssh/sshd_config
		        echo "------------------------"
		        echo "Password login disabled!"
		        echo "------------------------"
		else
			echo "-------------------"
			echo "Skipping the step!!"
			echo "-------------------"
		fi
	else
		echo "------------------------------"
		echo "Leaving password auth enabled!"
		echo "------------------------------"
	fi

	echo "-----------------------------------------------------------------------------"
	echo "Please reset the SSH daemon(service) in order for the changes to take effect!"
	echo "-----------------------------------------------------------------------------"
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

function allow_deny_port {
	echo "Would you like to 1) allow or 2) deny traffic incoming on a specific port? [1|2]: "
	read PORT_ANSWER1
	if [ $PORT_ANSWER1 == "1" ]
	then
		#Allow
		echo "Which port would you like to allow? [Please enter the port number]: "
		read PORT_ANSWER2
		ufw allow $PORT_ANSWER2 &> /dev/null
		if [ $? == "0" ]
		then
			echo "---------------------------"
			echo "Port $PORT_ANSWER2 allowed!"
			echo "---------------------------"
		else
			echo "---------------------------------------"
			echo "Something went wrong, please try again!"
			echo "---------------------------------------"
		fi
	else
		#Deny
		echo "Which port would you like to deny? [Please enter the port number]: "
		read PORT_ANSWER3
		ufw deny $PORT_ANSWER3 &> /dev/null
		if [ $? == "0" ]
		then
			echo "--------------------------"
			echo "Port $PORT_ANSWER3 denied!"
			echo "--------------------------"
		else
			echo "---------------------------------------"
			echo "Something went wrong, please try again!"
			echo "---------------------------------------"
		fi
	fi
}

function show_ports {
	echo "-------------------------------"
	echo "Ports that are currenly ALLOWED"
	ufw status | awk '/ALLOW/ {print $1}' | sort | uniq
	echo "-------------------------------"
	echo "Ports that are currently DENIED"
	ufw status | awk '/DENY/ {print $1}' | sort | uniq
	echo "-------------------------------"
}

function revert_changes {
	rm /etc/ssh/sshd_config && cp /etc/ssh/sshd_config.bk /etc/ssh/sshd_config
}

function ban_ssh {
	echo "Would you like to install a package called Fail2Ban will will imporove the security of your SSH? [y|n]: "
	read BAN_SSH_ANSWER1

	if [[ $BAN_SSH_ANSWER1 == 'y' || $BAN_SSH_ANSWER1 == 'Y' ]]
	then
		echo "------------------------------"
		echo "Installing Fail2Ban pachage..."
		echo "------------------------------"
		apt install fail2ban -y &> /dev/null
		if [ $? == 0 ]
		then
			echo "Which port do you use for your ssh? [Please enter the port number ex. 22]: "
			read BAN_SSH_PORT
			touch /etc/fail2ban/jail.local && echo "[DEFAULT]
bantime = 24h
ignoreip = 127.0.0.1/8
ignoreself = true

[sshd]
enabled = true
port = $BAN_SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3" > /etc/fail2ban/jail.local
			systemctl restart fail2ban || service fail2ban restart
			if [ $? == "0" ]
			then
				echo "-------------------------------------------------------------------------"
				echo "Fail2Ban daemon (service) restarted in order to apply the config changes!"
				echo "-------------------------------------------------------------------------"
			else
				echo "---------------------------------------------------------------------------------------------------"
				echo "There was an issue during the process of restarting the daemon, please restart the daemon manually!"
				echo "---------------------------------------------------------------------------------------------------"
			fi
			echo "----------------------------------------------------------------------------------------------------"
			echo "Done! SSH ban rules setup! Every times someone unsuccessfully fails to login three times in the row,"
		       	echo "they'll be banned for 24 hours!"
			echo "----------------------------------------------------------------------------------------------------"
		else
			echo "--------------------------------------------------------------------"
			echo "Something went wrong during the installation of Fail2Ban! Exiting..."
			echo "--------------------------------------------------------------------"
		fi
	else
		echo "------------------"
		echo "Skipping the step!"
		echo "------------------"
	fi
}

function ban_log {
	grep "Ban" /var/log/fail2ban.log | awk '{print $1 "(" $2 ")" "  |   " $7 "  " $8 " " $9}'
}

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

while true
do
	echo "----------------------------------------------------------------------------------"
	echo "SSH OPTIONS          |   FIREWALL OPTIONS    |   5b) Allow/Deny inbound port     |"        
	echo "1a) SSHd status      |   1b) UFW status      |   6b) Show Allowed/Denied ports   |"   	 
	echo "2a) SSHd restart     |   2b) UFW enable      |   EXTRAS                          |"
	echo "3a) Configure SSH    |   3b) UFW disable     |   1c) Ban malicious ssh logins    |"
	echo "4a) Revert changes   |   4b) Configure UFW   |   2c) Show banned IPs             |"  
	echo "----------------------------------------------------------------------------------"
	echo "c) Clear terminal    |   x) Exit             |                                   |" 
	echo "----------------------------------------------------------------------------------"

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

		4a)	revert_changes
			echo "-----------------"
			echo "Changes reverted!"
			echo "-----------------"
			;;

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
			allow_deny_port
			;;

		6b)
			show_ports
			;;

		1c)
			ban_ssh
			;;

		2c)
			ban_log
			;;

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
