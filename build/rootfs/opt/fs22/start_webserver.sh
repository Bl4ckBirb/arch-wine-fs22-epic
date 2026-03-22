#!/bin/bash

export WINEDEBUG=-all
export WINEPREFIX=~/.fs22server

# Start the server

if [ -f /opt/fs22/game/FarmingSimulator22/dedicatedServer.exe ]
then
    legendary launch "Farming Simulator 22" --wine-prefix ~/.fs22server --override-exe /opt/fs22/game/FarmingSimulator22/dedicatedServer.exe
else
    echo "Game not installed?" && exit
fi

exit 0
