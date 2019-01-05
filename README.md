# Atlas Dedicated Server for Linux/Docker

**IMPORTANT:** This is an initial release intended for testing. I cannot provide support or promise that this solution will work for you.

This Dockerfile has had *very limited* testing. It would be great to get positive feedback, so if this works for you feel free to open an issue to let everyone know. Sharing `ServerGrid.json`'s is also useful, but be sure to sanitize them first.

## Quick Start

* Make sure you have Docker installed on a Linux host
* Clone or download a zip of this repository
* Build the Docker image

        docker build -t atlas-server .

* Install Atlas Dedicated Server

        docker run --rm -v /some/path/atlas-server:/mnt/atlas-server atlas-server

    * This will install the server into the path given and exit. Use this same command to upgrade the server.

* Copy `ServerGrid*` files to `/some/path/atlas-server/ShooterGame/`

* Run Atlas Dedicated Server

        docker run -d --name=atlas-server \
        -v /some/path/atlas-server:/mnt/atlas-server \
        atlas-server start-server \
        "Ocean?ServerX=0?ServerY=0?MaxPlayers=10?ReservedPlayerSlots=5?QueryPort=57555?Port=5755?SeamlessIP=XXX.XXX.XXX.XXX -NoBattlEye -log -server"

    * Make sure to replace the placeholder SeamlessIP with your public IP
    * Depending on your setup you'll likely need to expose docker to your network so the server can be accessed from the Internet. The easiest way to do this is to add `--net=host` to the above `docker run...` command.

* Monitor logs / VNC

    * This container runs a VNC server on port 5920. Use a VNC client to connect to it. Atlas Dedicated Server will throw GUI dialog errors, and this is the only way to see them.
    * Monitor the server console log by running:

            docker logs -f atlas-server

## Support & Contributing

Unfortunately I do not have the time to support each and everyone of you. This is an early-release intended to combine efforts.

If you wish to contribute please open a pull request.

## Known Issues

* This was built and tested with a 1x1 map as such it assumes as much. Redis is started per instance of this container. If you want to use this for more than one tile, it will have to be modified to not run Redis in the `start-server` script.
* I've been unable to start a large 1x1 tile that requires ~22GB or RAM. Wine crashes right around 16GB. Less populated tiles work.
