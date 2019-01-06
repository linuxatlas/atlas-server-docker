# Examples for ATLAS Wine Docker

**important**: Familiarity with Docker and Compose is expected.

You will need to have [Docker](https://docs.docker.com/install/) 
and [Compose](https://docs.docker.com/compose/install/) installed.

The examples contain the ServerGrid (map) files and docker compose
files. You will need to modify the files to get them to work.

## Quick Start:

* Follow the build [general build instructions](https://github.com/linuxatlas/atlas-server-docker) for this docker image.
  Remove the `redis-server` start command in `bin/start-server` as we will
  run a separate redis server.

* Copy the docker-compose.yml file, the .env file and ServerGrid files to your server.

* In ServerGrid.json replace `ip` with your external IP everywhere
  Make sure ports are opened and forwarded in your firewall and router.

  If you change ports, make sure to change them both in the ServerGrid.json
  and in the docker-compose.yml file (double check ports and command)

* In docker-compose.yml: replace the password in the redis service with the
  password you use in ServerGrid.ServerOnly.json.

* Create a directory somewhere on your server to download the server files
  and store the persistent world data (.e.g /mnt/atlas-server).
  This will be the `HOST_PATH` variable in the docker compose files.

* Start everything up: 
  ```bash
  docker-compose -e EXTERNAL_IP=<MY-IP> -e HOST_PATH=</persistent/storage/for/atlas> -f /path/to/docker-compose.yml up -d
  ```
  This will start a Redis server and a number of ATLAS instances.
  You can view your started instances with `docker ps`.

### Updating the server
If an ATLAS server update is out, you need only to rebuild the Docker image
by executing the installation step from the readme:
```bash
docker run --rm -it -v /some/path/atlas-server:/mnt/atlas-server atlas-server
```
and rerun the start command, it should update the out-of-date containers.

## Included Examples
There are currently 2 examples included, they take a different approach to
networking so you can base yourself on what you like best

### 2x2
This base example start 4 instances of the ATLAS Wine Docker server
and a Redis server. For ease of configuration the host network is
used, this removed the need to map all ports separately.

### 4x4
The 4x4 requires 16 instances to be started and a Redis server, in
addition this example uses port mapping instead of the host network, 
so a little more effort is needed to map everything out.

Ports are chosen so they follow a pattern:
- GamePort: 57$X$Y e.g. B2, which is running on 1,1 would be 5711
- QueryPort: 575$X$Y e.g. D3, which is running on 3,2 would be 57532
- SeamlessPort: 270$X$Y e.g. A1 which is running on 0,0 would be 27000

GamePort and QueryPort are *UDP* while the SeamlessPort is *TCP*, 
make sure to configure the correct range and protocols on your firewall and router.

Using this template for a max 10x10 gives the following port ranges:
- GamePort: 5700-5799 (UDP)
- QueryPort: 57500-57599 (UDP)
- SeamlessPort: 27000-27099 (TCP)

## Extra

### RCON
If you want to enable RCON, add the following to all command strings 
after `?SeamlessIP=${EXTERNAL_IP}`: `?RCONEnabled=True?RCONPort=32330 -servergamelog -ServerRCONOutputTribeLogs`

Make sure to choose an unique port for each ATLAS instance, and if applicable
map the port in the docker-compose file.

### Admin whitelist and VIP
To allow you and/or other people to manage your server you can add
their SteamId to `ShooterGame/Saved/AllowedCheaterSteamIDs.txt`.

If you want people to be able to log in without a password (but not
have admin privileges) you can add them to `ShooterGame/Binaries/Win64/PlayersJoinNoCheckList.txt`
s