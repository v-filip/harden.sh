#!/bin/bash
#Author: v-filip

while true
do
	echo "----------------------------"
	echo "SSH OPTIONS:"
	echo "1a) SSHd status"
	echo "2a) SSHd restart"
	echo "3a) Configure SSH"
	echo "----------------------------"
	echo "1b) UFW status"
	echo "2b) UFW enable"
	echo "3b) UFW disable"
	echo "4b) Configure UFW"
	echo "5b) Allow/Deny inbound port"
	echo "x) exit"
	echo "------_---------------------"
	read -p "Please make your selection: " ANSWER
	echo
	case $ANSWER in 
		1a)
			#sshd status
			#function
			;;
		
		2a)
			#sshd restart
			#function
			;;

		3a)
			#configure ssh
			#function
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
			sleep 1
			break
			;;

		*)
			#invlaid input#
			;;
	esac
done
