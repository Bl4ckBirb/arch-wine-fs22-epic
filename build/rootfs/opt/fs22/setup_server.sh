#!/bin/bash

export WINEDLLOVERRIDES=mscoree=d
export WINEDEBUG=-all
export WINEPREFIX=~/.fs22server
export WINEARCH=win64
export USER=nobody

# Debug info/warning/error color
NOCOLOR='\033[0;0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Create a clean 64bit Wineprefix
if [ -d ~/.fs22server ]
then
    rm -r ~/.fs22server && wine wineboot
else
    wine wineboot
fi

# it's important to check if the config directory exists on the host mount path. If it doesn't exist, create it.
if [ -d /opt/fs22/config/FarmingSimulator2022 ]
then
    echo -e "${GREEN}INFO: The host config directory exists, no need to create it!${NOCOLOR}"
else
    mkdir -p /opt/fs22/config/FarmingSimulator2022
fi

# it's important to check if the game directory exists on the host mount path. If it doesn't exist, create it.
if [ -d /opt/fs22/game/FarmingSimulator22 ]
then
    echo -e "${GREEN}INFO: The host game directory exists, no need to create it!${NOCOLOR}"
else
    mkdir -p /opt/fs22/game/FarmingSimulator22
fi

# Symlink the host game path inside the wine prefix to preserve the installation on image deletion or update.
if [ -d /opt/fs22/game/FarmingSimulator22 ]
then
    ln -s /opt/fs22/game/FarmingSimulator22 ~/.fs22server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2022
else
    echo -e "${RED}Error: There is a problem... the host game directory does not exist, unable to create the symlink, the installation has failed!${NOCOLOR}"
fi

# Symlink the host config path inside the wine prefix to preserver the config files on image deletion or update.
if [ -d ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022 ]
then
    echo -e "${GREEN}INFO: The symlink is already in place, no need to create one!${NOCOLOR}"
else
    mkdir -p ~/.fs22server/drive_c/users/$USER/Documents/My\ Games && ln -s /opt/fs22/config/FarmingSimulator2022 ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022
fi

if [ -d ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs ]
then
    echo -e "${GREEN}INFO: The log directories are in place!${NOCOLOR}"
else
    mkdir -p ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs
fi

if [ -f ~/.fs22server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2022/FarmingSimulator2022.exe ]
then
    echo -e "${GREEN}INFO: Game is installed.${NOCOLOR}"
else
    echo -e "${RED}ERROR: Game is not installed?${NOCOLOR}" && exit
fi

# Cleanup Desktop
if [ -f ~/Desktop/ ]
then
    rm -r "~/Desktop/Farming\ Simulator\ 22\ .*"
else
    echo -e "${GREEN}INFO: Nothing to cleanup!${NOCOLOR}"
fi

# Copy run.bat which will enable us to start the server from the webinterface
cp /opt/fs22/run.bat /opt/fs22/game/FarmingSimulator22/x64/run.bat
chmod +x /opt/fs22/game/FarmingSimulator22/x64/run.bat

# Copy webserver config..
if [ -d ~/.fs22server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2022/ ]
then
    cp "/config/default_dedicatedServer.xml" ~/.fs22server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2022/dedicatedServer.xml
else
    echo -e "${RED}ERROR: Game is not installed?${NOCOLOR}" && exit
fi

# Copy server config
if [ -d ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/ ]
then
    cp "/config/default_dedicatedServerConfig.xml" ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/dedicatedServerConfig.xml
else
    echo -e "${RED}ERROR: Game didn't start for first time, no directories?${NOCOLOR}" && exit
fi

# Check config if not exist exit
if [ -f ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/dedicatedServerConfig.xml ]
then
    echo -e "${GREEN}INFO: We can run the server now by clicking on 'Start Server' on the desktop!${NOCOLOR}"
else
    echo -e "${RED}ERROR: We are missing files?${NOCOLOR}" && exit
fi

# Lets purge the logs so we won't have errors/warnings at server start...
if [ -f ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/server.log ]
then
    rm ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/server.log && touch ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/server.log
else
    touch ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/server.log
fi

if [ -f ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/webserver.log ]
then
    rm ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/webserver.log && touch ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/webserver.log
else
    touch ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/dedicated_server/logs/webserver.log
fi

if [ -f ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/log.txt ]
then
    rm ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/log.txt && touch ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/log.txt
else
    touch ~/.fs22server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2022/log.txt
fi

echo -e "${YELLOW}INFO: All done, closing this window in 20 seconds...${NOCOLOR}"

exec sleep 20