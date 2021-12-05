#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'ubuntu:18.04'
apt-get update &>/dev/null
apt install software-properties-common -y &>/dev/null
add-apt-repository multiverse -y &>/dev/null
dpkg --add-architecture i386 
apt-get update &>/dev/null
apt-get install libgcc1 lib32gcc1 lib32stdc++6 &>/dev/null
apt -y update &>/dev/null
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates &>/dev/null
clear

echo "Setting steamcmd"

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server
clear
echo "Setting CSGO Server, please wait 15-20 minutes..."

## install game using steamcmd
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /mnt/server +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} +quit &>/dev/null

echo "Installing plugin..."

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

cd /mnt/server/csgo/
wget https://github.com/nkyo/pterodactyl/releases/download/latest/nkCSGO.tar &>/dev/null
tar -xvf nkCSGO.tar &>/dev/null
rm -f nkCSGO.tar &>/dev/null
