#!/bin/bash
#
# Name:         SharkJack Unofficial Payload Library UI (Unix/MAC Patcher)
# Version:      1.1
# Author:       REDD
# Target OS:    Unix/MAC
# Description:  This is the patch script for the Unofficial
#               SharkJack Payload Library. -Enjoy
#

SHARK_IP="172.16.24.1"
clear
echo -e "Please put SharkJack into Arming Mode and
echo -e "connect it to the Ethernet Port on your PC.
echo -e ""
echo -e ""
echo -e "Waiting.."
echo -e ""

# Taking Detection/OS Check/Connection of SharkJack for Unix/Mac systems from Hak5 sharkjack.sh.
# So kudos to all the Developers and development done by everyone with it!
#   - Lets do this!

function os_check() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "\nOSX Detected\n"
    OS=1
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    err "Cygwin not supported"
  else
    OS=0
    iptables_check
  fi
}

function root_check() {
  if [[ "$EUID" -ne 0 ]]; then
    printf "\n%s\n" "Please re-run as root"
    exit 1
  fi
}

function connection_error(){
  IFACE=''
  printf "\n%s\n" "[!] error communicating with the Shark Jack"
}

function connection_check(){
  sleep 1
  ping -c 1 172.16.24.1 &>/dev/null && echo -e " [+] Shark Jack Detected..." && return 0
  connection_error && return 1
}


function locate_interface_to_shark() {
  printf "\n%s" 'Waiting for a Shark Jack to be connected..'
  while [[ -z $IFACE ]]; do
    printf "%s" .
    IFACE=$(ip route show to match 172.16.24.1 2>/dev/null| grep -i 172.16.24.1 | cut -d ' ' -f3 | grep -v 172.16.24.1)
    sleep 1
  done
  echo -e "\n"
  connection_check || locate_interface_to_shark
}

function osx_locate_interface_to_shark(){
  printf "\n%s" 'Waiting for a Shark Jack to be connected..'
  while [[ -z $IFACE ]]; do
    printf "%s" .
    IFACE=$(ifconfig |cut -d ' ' -f1 |grep en|cut -d ':' -f1 | xargs -I {} sh -c "ipconfig getifaddr {}|grep -i 172.16.24 &>/dev/null && echo {}")
    sleep 1
  done
  echo -e "\n"
  connection_check || osx_locate_interface_to_shark
}

function locate_shark(){
  if [[ $OS -eq 1 ]]; then
    osx_locate_interface_to_shark
  else
    locate_interface_to_shark
  fi
}
# Adding simple Pause script to emulate Windows PAUSE Command.
function pause(){
   read -p "$*"
}
function banner() {
	clear
	echo -e "\n"
	echo "O=====================================O"
	echo "|                                     |"
	echo "|         SharkJack Patcher (UNIX)    |"
	echo "|              by REDD                |"
	echo "O=====================================O"
}

function install_patch(){
	if [ ! -f "${PWD}/patch/library.sh" ]; then
		echo -e "No patch content found. Please download the patch and place"
		echo -e "in the correct directory."
		exit 0
	fi
	if [ ! -d "${PWD}/patch" ]; then
		echo -e "No patch directory found or content. Please download the "
		echo -e "patch and place in the correct directory."
		exit 0
	fi
        echo -e "Connecting to the SharkJack.."
        echo -e ""
        echo -e "YOU WILL HAVE TO ENTER YOUR SHARKJACK PASSWORD EACH STEP."
        echo -e "(Input password: hak5shark   OR  Password you have already set.)"
        echo -e ""
        echo  " -> SSH'ing into SharkJack to prepare patch directory."
        ssh root@${SHARK_IP} "mkdir -p /tmp/patch;exit"
        echo -e ""
        echo -e " -> Copying patch installer."
        scp "${PWD}/patch.sh" "root@${SHARK_IP}:/tmp/patch.sh"
        echo -e ""
        echo  -e "-> Copying patch content. (library command)"
        scp "${PWD}/patch/library" root@${SHARK_IP}:/tmp/patch/library
        echo -e ""
        echo  -e "-> Copying patch content. (library.sh)"
        scp "${PWD}/patch/library.sh" root@${SHARK_IP}:/tmp/patch/library.sh
        echo -e ""
        echo -e " -> Executing patcher, and fixing permissions."
        ssh root@${SHARK_IP} "/bin/bash /tmp/patch.sh;chmod 0755 /www/cgi-bin/library.sh;exit"
        echo -e ""
        pause 'Press ENTER to return to Menu.'
        main_menu;
}

function remove_patch(){
        echo -e "Connecting to the SharkJack.."
        echo -e ""
        echo -e "(Input password: hak5shark   OR  Password you have already set.)"
        echo -e ""
        echo -e " -> Removing Payload Library patch and files. Restoring to Stock Web UI."
        ssh root@${SHARK_IP} "/bin/bash /tmp/patch.sh --remove;rm -rf /tmp/patch;rm /tmp/patch.sh;exit"
        echo -e ""
        pause 'Press ENTER to return to Menu.'
        main_menu;
}
# Run the Menu.
function main_menu() {
   banner
   if [[ $OS -eq 1 ]]; then
      echo -e "\n\n OSX DETECTED \n\n"
   fi
   printf "
  1. Install Payload Library Patch
  2. Remove Payload Library Patch

  0. Exit Patcher\n\

Select # from Menu and Press ENTER: "

   read -r -sn1 key
   case "$key" in
		[1]) install_patch;;
		[2]) remove_patch;;
		[qQeE0]) printf "\n\n";exit 0;;
		*) main_menu;;
   esac
}

# Check Root, and connectivity, if good. - TO THE MENU!
root_check
os_check

main_menu

exit 0

