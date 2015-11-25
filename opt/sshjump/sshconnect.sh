#!/bin/bash
device_categories=/opt/sshjump/files/device_categories
rootdir=/opt/sshjump/files/

function main(){

readCats $device_categories
displayCategories

}

# read categories
function readCats(){
 exec 3<&0
 exec 0<$1
 cindex=1
 category=( null )
 while read line
 do
    cline=$(echo $line | egrep -v "^#")
    ##echo "debug - $line"
    if [ "$cline" != "" ]; then
	category[$cindex]=$(echo "$cline")
	cindex=` expr $cindex + 1 `
    fi
 done
 exec 0<&3	
}

# read array
function readHosts(){
 exec 3<&0
 exec 0<$1 #$1 is the first var passed to the function
 aindex=1
 bindex=1
 hosts=( null )
 while read line
 do
    rline=$(echo $line | egrep -v "^#" | sed '/^$/d')
    if [ "$rline" != "" ]; then
        user=$USER
	device=$(echo "$rline" | awk -F'|' '{ print $1 }')
	##city=$(echo "$rline" | awk -F'|' '{ print $2 }')
	##state=$(echo "$rline" | awk -F'|' '{ print $3 }')
	##facility=$(echo "$rline" | awk -F'|' '{ print $4 }')
 	info=$(echo "$rline" |  awk -F'|' '{ print $4,"(",$5,")" }')
        devices[$aindex]=$(echo "$device")
	infos[$bindex]=$(echo "$device - $info")
        aindex=` expr $aindex + 1 `
        bindex=` expr $bindex + 1 `
    fi
 done
 exec 0<&3
}

# display device categories
function displayCategories(){
# use clear for unix systems
#
  clear
#
# use cls for cygwin
#
#  cmd /c cls
#
  echo ""
  echo ""
  echo "Authorized Use Only."
  echo ""
  echo ""
  echo "------------------------------------"
  echo "Running on $HOSTNAME"
  echo ""
  echo "Cat# : Device Categories"
  echo "------------------------------------"
  for (( i=1; i<$cindex; i++ ))
  do
        echo "#$i : ${category[$i]}"
  done
  echo
  echo "#$i : Quit"
  echo "#c : Press \"c\" to clear the SSH known_hosts files"
  echo
  read -p "Enter Category number: " myCatNumber
  # check for non-numbers
  echo $myCatNumber | grep [^0-9cq] > /dev/null 2>&1
  if [ "$?" -eq "0" ]; then
        showError
  else
	if [ "$myCatNumber" = "c" ]; then
		clear_known_hosts		
	elif [ "$myCatNumber" = "q" ]; then
		exit 1		
	elif [ "$myCatNumber" -ge "$cindex" ]; then
		exit 1
  	fi
  fi
  # check for a blank
  if [ -z "$myCatNumber" ]; then
	showError
  fi
  echo "Reading info for category: ${category[$myCatNumber]}"
  readHosts $rootdir${category[$myCatNumber]}
  displayHosts 
}
# display choice and connect to server
function displayHosts(){
# use clear for unix systems
#
  clear
#
# use cls for cygwin
#
#  cmd /c cls
#
  echo ""
  echo ""
  echo "------------------------------------"
  echo "D# : Device Selection"
  echo "------------------------------------"
  for (( i=1; i<$aindex; i++ ))
  do
        echo "#$i : ${infos[$i]}"
  done
  echo
  echo "#$i : Main Menu"
  read -p "Enter host number: " myHostNumber
  # check for non-numbers
  echo $myHostNumber | grep [^0-9] > /dev/null 2>&1
  if [ "$?" -eq "0" ]; then
	showError
  else
  	if [ "$myHostNumber" -ge "$aindex" ]; then
		displayCategories	
	fi 
  fi
  # check for a blank
  if [ -z "$myHostNumber" ]; then
	showError	
  fi
  echo "Connecting to ${devices[$myHostNumber]} as $USER ..."
  ssh -p22 ${devices[$myHostNumber]}
  wait #wait for process to end, the rerun script
  main
}
function pause(){
   #read -p "$*"
   read -s
}
function clear_known_hosts(){
  clear
  rm -rf /home/PATH/$USER/.ssh/known_hosts
  echo ""
  echo "\"known_hosts\" files removed for $USER."
  echo ""
  echo "Press any key to continue."
  pause
  displayCategories
}
function showError(){
# use clear for unix systems
#
  clear
#
# use cls for cygwin
#
#  cmd /c cls
#
echo ""
echo ""
echo "Please make a proper selection first."
echo ""
#pause "Press enter to continue."
echo "Press enter to continue."
pause
echo ""
main
}
#start app by calling 'main' function
main

