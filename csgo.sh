#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'ubuntu:18.04'
apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates
apt -y install lib32gcc1 lib32stdc++6


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

## install game using steamcmd
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /mnt/server +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} +quit ## other flags may be needed depending on install. looking at you cs 1.6

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

cd /mnt/server/csgo/
wget https://github.com/nkyo/pterodactyl/releases/download/latest/nkCSGO.tar
tar -xvf nkCSGO.tar
rm -f nkCSGO.tar
sed -i '/\"FollowCSGOServerGuidelines\"/d' addons/sourcemod/configs/core.cfg
sed -i '/\}/d' addons/sourcemod/configs/core.cfg
echo "\"FollowCSGOServerGuidelines\" \"no\"" >> addons/sourcemod/configs/core.cfg
echo "}" >> addons/sourcemod/configs/core.cfg
