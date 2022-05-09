#!/bin/bash
#Author: v-filip

while true
do
	echo "---------------------------------------------"
	echo "1) option 1"
	echo "2) option 2"
	echo "3) option 3"
	echo "4) option 4"
	echo "5) option 5"
	echo "x) exit"
	echo "---------------------------------------------"
	read -p "Please make your selection: " ANSWER
	echo
	case $ANSWER in 
		1)
			#option one
			#function
			;;
		
		2)
			#option two
			#function
			;;

		3)
			#option three
			#function
			;;

		4)
			#option four
			#function
			;;

		5)
			#option five
			#function
			;;

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
