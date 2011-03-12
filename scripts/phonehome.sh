#!/bin/bash
while true;
do
#echo "Checking for an existing session."
PROCESS=`ps -A | grep "syzygryd@209.237.247.224" | grep -v grep`
#echo $PROCESS
if [ "$PROCESS" = "" ]
then
#echo "Attempting connection over local network."
ssh -R 22210:localhost:22 -R 22211:10.10.10.11:22 -R 22212:10.10.10.12:22 -R 22213:10.10.10.13:22 syzygryd@209.237.247.224
#echo "Local network connection timed out."
fi
#echo "Sleeping."
sleep 3
done
