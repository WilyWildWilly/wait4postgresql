# wait4postgresql

A bash script that waits for a process to listen on port 5432 and exits. Thought as a step to run in a Dockerfile for docker compose to wait for the db container to be operating before continuing

## instructions

Run this with your own user (no sudo needed). It needs `chown +x wait4postgresql.sh` authorisation in order to run.

## the issue

Docker-compose's .yml configuration file allows you to express dependencies with the `depends_on` key, but this only means defining the order in which containers are fired up. When working with Docker-compose with a DB container in parallel with a back-end, you'll often see how the back-end will be ready before the DB container has started listening on its port.

## intended use

What this script does is it loops until something is listening on the port it's monitoring (using netstat and grep, without any root permissions), thus keeping the container on hold until the other container is not only started, but fully operating. 

## testing

Test this in your own environment by stopping the postgres service (`sudo service postgresql stop`) in one terminal, opening a different terminal and running `./wait4postgresql.sh`. The output will warn you that the script is waiting for something to be listening on port 5432 and will keep on looping until it finds a process on it. Go back to the other terminal and run `sudo service posgresql start`, you'll see that the script will find the postgresql service process listening on its default port and exit, freeing the terminal.

## mod, adapt, customize

On line 10 you can see the following assignment: `b=$(netstat -tulpn 2>/dev/null | grep 5432)`
Changing the `5432` to any other port number can help you if:
 - you're using a different DB engine (it would be 27017 for MongoDB or 3306 for MySQL or MariaDB)
 - you're using a customized port configuration for your containers
