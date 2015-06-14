#!/bin/bash

#Check for root
if [ "$(whoami)" != "root" ]
then
    echo "You must be root to run this script"
    exit 1
fi

#Get processor information
if [[ `uname -m` == "arm"* ]]; then
	arm=true
elif [[ `uname -m` == "x86"* ]]; then
	x86=true
else
	echo "An incompatible processor has been identified"
	exit 1
fi

set -e
#Processor found
echo `uname -m` processor identified

MHN_HOME=$(dirname "$0")
SCRIPTS="$MHN_HOME/scripts"
cd "$SCRIPTS"

#update and install packages needed independent of processor type
echo "[`date`] Starting Installation of all MHN packages"
apt-get update
apt-get install -y libffi-dev python-pip python-dev supervisor golang mercurial make redis-server libgeoip-dev nginx

#Initiate all required apt-get install calls
if [ $arm == true ]; then
	#Mongo requirements
	apt-get install -y build-essential libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev scons libboost-all-dev python-pymongo git
	#Nodejs/coffeescript requirements
	apt-get install -y libssl-dev git-core redis-server libexpat1-dev libicu-dev
	echo "[`date`] ========= Installing Mongo ========="
	./install_mongo_arm.sh
	echo "[`date`] ========= Installing coffeescript ========="
	./install_coffeescript.sh
elif [ $x86 == true ]; then
	apt-get install -y coffeescript
	echo "[`date`] ========= Installing Mongo ========="
	./install_mongo.sh
fi

echo "[`date`] ========= Installing hpfeeds ========="
./install_hpfeeds.sh

echo "[`date`] ========= Installing menmosyne ========="
./install_mnemosyne.sh

echo "[`date`] ========= Installing Honeymap ========="
./install_honeymap.sh

echo "[`date`] ========= Installing MHN Server ========="
./install_mhnserver.sh

echo "[`date`] ========= MHN Server Install Finished ========="
echo ""

while true;
do
    echo -n "Would you like to integrate with Splunk? (y/n) "
    read SPLUNK
    if [ "$SPLUNK" == "y" -o "$SPLUNK" == "Y" ]
    then
        echo -n "Splunk Forwarder Host: "
        read SPLUNK_HOST
        echo -n "Splunk Forwarder Port: "
        read SPLUNK_PORT
        echo "The Splunk Universal Forwarder will send all MHN logs to $SPLUNK_HOST:$SPLUNK_PORT"
        ./install_splunk_universalforwarder.sh "$SPLUNK_HOST" "$SPLUNK_PORT"
        ./install_hpfeeds-logger-splunk.sh
        break
    elif [ "$SPLUNK" == "n" -o "$SPLUNK" == "N" ]
    then
        echo "Skipping Splunk integration"
        echo "The splunk integration can be completed at a later time by running this:"
        echo "    cd /opt/mhn/scripts/"
        echo "    sudo ./install_splunk_universalforwarder.sh <SPLUNK_HOST> <SPLUNK_PORT>"
        echo "    sudo ./install_hpfeeds-logger-splunk.sh"
        break
    fi
done

echo "[`date`] Completed Installation of all MHN packages"
