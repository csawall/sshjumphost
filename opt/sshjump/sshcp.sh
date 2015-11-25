#/bin/bash

DIR="/opt/sshjump/files/*"
RDIR="/opt/sshjump/files"

read -p "Enter server to copy files to: " SERVER

echo "Copying to $SERVER..." 
SCP="$DIR $SERVER:$RDIR"
echo "SCP CMD = scp $SCP"

echo -n "Enter your root "
scp $SCP
#scp -r "$DIR" "$SERVER:$RDIR" > /dev/null 2>&1
echo ""
echo "...done." 
