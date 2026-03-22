# Farming Simulator 22 Docker Server

Dedicated Farming Simulator 22 server running inside a docker image based on ArchLinux. 
This fork is set up to use the Epic Games version of FS22 by using [Legendary](https://github.com/derrod/legendary).

Note: DLC support might not work as i do not own any and therefore cannot test it.

## Table of contents
<!-- vim-markdown-toc GFM -->
* [Motivation](#motivation)
* [Getting Started](#getting-started)
	* [Hardware Requirements](#hardware-requirements)
	* [Software Requirements](#software-requirements)
		* [Linux Distribution](#linux-distribution)
		* [Server License](#server-license)
		* [VNC Client](#vnc-client)
* [Deployment](#deployment)
	* [Deploying with docker-compose](#docker-compose)
	* [Deploying with docker run](#docker-run)
* [Installation](#installation)
  * [Preparing the needed directories on the host machine](#preparing-the-needed-directories-on-the-host-machine)
  * [Starting the container](#starting-the-container)
  * [Connecting to the VNC Server](#connecting-to-the-vnc-Server)
	* [Server Installation](#server-installation)
    * [Login to Epic Games](#login-to-epic-games)
    * [Install the game](#install-the-game)
    * [Running the setup](#running-the-setup)
		* [Starting the admin portal](#starting-the-admin-portal)
* [Environment variables](#environment-variables)
<!-- vim-markdown-toc -->

# Motivation

GIANTS Software encourages its customers to consider renting a server from one of their verified partners, as it helps protect their business and maintain close relationships with these partners. Unfortunately, they do not allow third parties to host servers in order to support their partner network effectively.

For customers who prefer running personal servers, there is a requirement to purchase all the game content (game, DLC, packs) twice. This means obtaining one license for the player and another license specifically for the server.

While renting a server remains a viable option for certain players, it has become increasingly common for game developers to provide free-to-use server tools. Regrettably, the server tools provided by GIANTS Software are considered outdated and inefficient. As a result, users are compelled to set up an entire Windows environment. However, with our project, we have overcome this limitation by enabling users to deploy servers within a lightweight Docker environment, eliminating the need for a Windows setup.

# Getting Started

Please note that this may not cover every possible scenario, particularly for NAS (synology) users. In such cases, you may need to utilize the provided admin console to configure the necessary directories and user permissions. If you encounter any issues while attempting to run the program, kindly refrain from sending me private messages, instead please create an [issue](https://github.com/Bl4ckBirb/arch-wine-fs22-epic/issues) in this GitHub repository. 

## Hardware Requirements

Intel: Haswell or newer (Intel Celeron specially from older generations are not recommended)
AMD: Zen1 or newer

- Server for 2-4 players (without DLCs) 2.4 GHz (min. 3 Cores), 4 GB RAM
- Server for 5-10 players (with DLCs) 2.8 GHz (min. 3 Cores), 8 GB RAM
- Server for up to 16 players (with all DLCs) 3.2 GHz (min. 4 Cores), 12 GB RAM

*** Storage depends on installed dlc + mods ***

## Software Requirements

### Linux Distribution

To install Docker and Docker Compose, please consult the documentation specific to your Linux distribution. It's important to note that the provided image is intended for operating systems that support Docker and utilize the x86_64 / amd64 architecture. Unfortunately, arm/apple architectures are not supported.

### Server License

This project is only set up for the Epic Games version of the game. The Steam version is not supported.
To use the game version directly bought from Giants please use https://github.com/wine-gameservers/arch-wine-fs22/

### VNC Client

After starting the Docker container for the first time, you will need to go through the initial installation of the game and DLC using a VNC client. One example of a VNC client is VNC® Viewer. This will allow you to set up the game and install the necessary content within the Docker environment.

- [VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)

## Deployment

The primary distinction between `docker run` and `docker-compose` is that `docker run` relies solely on command-line instructions, whereas `docker-compose` reads configuration data from a YAML file. If you are unsure about which option to choose, I recommend opting for `docker-compose`. It provides a more organized and manageable approach to container deployment by utilizing a YAML file to define and configure multiple containers and their dependencies.

### Docker compose
```
services:
  arch-wine-fs22-epic:
    image: ghcr.io/bl4ckbirb/arch-wine-fs22-epic:latest
    container_name: arch-wine-fs22-epic
    shm_size: 3gb  #legendary install/download fails without this
    environment:
      - VNC_PASSWORD=<your vnc password>
      - WEB_USERNAME=<dedicated server portal username>
      - WEB_PASSWORD=<dedicated server portal password>
      - SERVER_NAME=<your server name>
      - SERVER_PASSWORD=<your game join password>
      - SERVER_ADMIN=<your server admin password>
      - SERVER_PLAYERS=16
      - SERVER_PORT=10823
      - SERVER_REGION=en
      - SERVER_MAP=MapUS
      - SERVER_DIFFICULTY=3
      - SERVER_PAUSE=2
      - SERVER_SAVE_INTERVAL=180.000000
      - SERVER_STATS_INTERVAL=31536000
      - SERVER_CROSSPLAY=true
      - PUID=<UID from user>
      - PGID=<PGID from user>
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /opt/fs22/config:/opt/fs22/config
      - /opt/fs22/game:/opt/fs22/game
    ports:
      - 5900:5900/tcp
      - 8080:8080/tcp
      - 10823:10823/tcp
      - 10823:10823/udp
    cap_add:
      - SYS_NICE
    restart: unless-stopped
```

### Docker run
```
$ docker run -d \
    --name arch-wine-fs22-epic \
    --shm-size="3g" \
    -p 5900:5900/tcp \
    -p 8080:8080/tcp \
    -p 9000:9000/tcp \
    -p 10823:10823/tcp \
    -p 10823:10823/udp \
    -v /etc/localtime:/etc/localtime:ro \
    -v /opt/fs22/config:/opt/fs22/config \
    -v /opt/fs22/game:/opt/fs22/game \
    -e VNC_PASSWORD="<your vnc password>" \
    -e WEB_USERNAME="<dedicated server portal username>" \
    -e WEB_PASSWORD="<dedicated server portal password>" \
    -e SERVER_NAME="<your server name>" \
    -e SERVER_PASSWORD="your game join password" \
    -e SERVER_ADMIN="<your server admin password>" \
    -e SERVER_PLAYERS="16" \
    -e SERVER_PORT="10823" \
    -e SERVER_REGION="en" \
    -e SERVER_MAP="MapUS" \
    -e SERVER_DIFFICULTY="3" \
    -e SERVER_PAUSE="2" \
    -e SERVER_SAVE_INTERVAL="180.000000" \
    -e SERVER_STATS_INTERVAL="31536000" \
    -e SERVER_CROSSPLAY="true" \
    -e PUID=<UID from user> \
    -e PGID=<PGID from user> \
    ghcr.io/bl4ckbirb/arch-wine-fs22-epic:latest
```
# Installation

## Preparing the needed directories on the host machine

To ensure that the installation remains intact even if you remove or update the Docker container, it is important to configure specific directories on the host side. A common practice is to place these directories in `/opt`, although you can choose any other preferred mount point according to your needs and preferences.

`$sudo mkdir -p /opt/fs22/{config,game}`

To enable read and write access for the user account configured in the compose file (PUID/PGID), we need to ensure that the Docker container can interact with the designated directory. This can be achieved by executing the following command, which grants the necessary permissions:

```bash
sudo chown -R myuser:mygroup /opt/fs22
```

Replace `<myuser>` with the appropriate user and `<mygroup>` with the users primary group (often the same as `<myuser>` if unsure use the id command below).

To incorporate the necessary PUID (User ID) and PGID (Group ID) values into the docker-compose/run file, you can utilize the Linux `id` command to retrieve the appropriate values. Run the following command:

```bash
id username
```

Replace `username` with the desired username.

Once you have obtained the User ID (UID) and Group ID (PGID) from the output of the `id` command, add them to the docker-compose/run file using the following YAML syntax:

```yaml
- PUID=<UID from user>
- PGID=<PGID from user>
```

Make sure to append `<UID=>` with the actual User ID value and `<PGID=>` with the corresponding Group ID value.

Example:

```yaml
- PUID=1000
- PGID=1000
```

## Starting the container

With the host directories configured and the compose file set up accordingly, you are now ready to start the container.
inside the same direcoty where the modified docker-compose.yml is located run the following command.

```bash
docker-compose up -d
```

*Tip: You can use `$docker ps` to see if the container started correctly.

## Connecting to the VNC Server

To connect to the VNC Server using VNC Viewer, you can establish a connection by specifying the IP address followed by the choosen vnc port number default `5900`. This connection will open up a full desktop environment, allowing you to proceed with the installation of the dedicated server.

Please launch VNC Viewer and enter the following in the connection field:

```
ip:5900
```

Replace `ip` with the actual IP address of the server.

# Server Installation

## Login to Epic Games

Open up the terminal, and run the below commands.

Login to Epic Games - This will open firefox with the login page. (Ignore the errors in the terminal)
```bash
legendary auth
```
After you log in, copy the shown authorization code and paste it in the terminal.

## Install the game

```bash
legendary list && legendary install "Farming Simulator 22" -y --max-workers 4 --base-path /opt/fs22/game/
```
This will download and install the game.

## Running the setup

`$./setup_server.sh`

This completes the setup by creating the wine prefix and other configs. 

## Starting the admin portal

`$./start_webserver.sh`

Check if the webserver is working by going to localhost:8080 in the browser inside the vnc connection or ip:8080 on an external machine.

# Environment variables

Getting the PUID and GUID is explained [here](https://man7.org/linux/man-pages/man1/id.1.html).

| Name | Default | Purpose |
|----------|----------|-------|
| `VNC_PASSWORD` || Password for connecting using the vnc client |
| `WEB_USERNAME` | `admin` | Username for admin portal at :8080 |
| `SERVER_NAME` || Servername that will be shown in the server browser |
| `SERVER_PORT` | `10823` | Default: 10823, port that the server will listen on |
| `SERVER_PASSWORD` || The game join password |
| `SERVER_ADMIN` || The server ingame admin password |
| `SERVER_REGION` | `en` | en, de, jp, pl, cz, fr, es, ru, it, pt, hu, nl, cs, ct, br, tr, ro, kr, ea, da, fi, no, sv, fc |
| `SERVER_PLAYERS` | `16` | Default: 16, amount of players allowed on the server |
| `SERVER_MAP` | `MapUS` | Default: MapUS (Elmcreek), other official maps are: MapFR (Haut-Beyleron), MapAlpine (Erlengrat) |
| `SERVER_DIFFICULTY` | `3` | Default: 3, start from scratch |
| `SERVER_PAUSE` | `2` | Default: 2, pause the server if no players are connected 1, never pause the server |
| `SERVER_SAVE_INTERVAL` | `180.000000` | Default: 180.000000, in seconds.|
| `SERVER_STATS_INTERVAL` | `31536000` | Default: 120.000000|
| `SERVER_CROSSPLAY` | `true/false` | Default: true |
| `PUID` || PUID of username used on the local machine |
| `GUID` || GUID of username used on the local machine |

# Legal disclaimer
This Docker container is not endorsed by, directly affiliated with, maintained, authorized, or sponsored by [Giants Software](https://giants-software.com) and [Farming Simulator 22](https://farming-simulator.com/). The logo [Farming Simulator 22](https://giants-software.com) are © 2023 Giants Software.
