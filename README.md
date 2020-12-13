# wait4postgresql

A bash script that loops while waiting for netstat to find a process listening on port 5432 (or any port you choose, see below in 'mod, adapt and customize'), then exits. Thought as a step to run in a Dockerfile to keep the back-end container busy, waiting for the db container to be operating before continuing with the creation, seeding and/or migration of its database. 

## instructions

Copy the file in the directory you intend to make available to your container and write run instructions in the dockerfile, or see below how to generate this file directly on execution of docker container.
Run this with your own user (no sudo needed). It needs `chown +x wait4postgresql.sh` authorisation in order to run though.

## the issue

Docker-compose's .yml configuration file allows you to express dependencies with the `depends_on` key, but this only means defining the order in which containers are fired up. When working with Docker-compose with a DB container in parallel with a back-end, you'll often see how the back-end will be ready before the DB container has started listening on its port.

## intended use

What this script does is it loops until something is listening on the port it's monitoring (using netstat and grep, without any root permissions), thus keeping the container on hold until the other container is not only started, but fully operating. 

## testing

Test this in your own environment by stopping the postgres service (`sudo service postgresql stop`) in one terminal, opening a different terminal and running `./wait4postgresql.sh`. The output will warn you that the script is waiting for something to be listening on port 5432 and will keep on looping until it finds a process on it. Go back to the other terminal and run `sudo service posgresql start`, you'll see that the script will find the postgresql service process listening on its default port and exit, freeing the terminal.

## mod, adapt, customize

On line 10 you can see the following assignment: `b=$(netstat -tulpn 2>/dev/null | grep 5432)`. Port 5432 is the default port for PostgreSQL, with which I was working when I had the issue that made me look for a solution to this problem.
Changing the `5432` to any other port number can help you if:
 - you're using a different DB engine (it would be 27017 for MongoDB or 3306 for MySQL or MariaDB)
 - you're using a customized port configuration for your containers

## in-docker generation

If you don't want to add a file, you can generate the script directly on container build by adding the following lines right before the backend's db creation and migration commands. Here's how:

``` 
RUN touch wait4postgres.sh && echo "#!/bin/bash" >> wait4postgres.sh
RUN echo "a=0" >> wait4postgres.sh
RUN echo "t=0" >> wait4postgres.sh
RUN echo "while ((a < 1))" >> wait4postgres.sh
RUN echo "\tdo" >> wait4postgres.sh
RUN echo "t=\$(( t + 1 ))" >> wait4postgres.sh
RUN echo "\t echo -ne \"No process on port 5432, waiting \$t s for postgresql...\\r\"" >> wait4postgres.sh
RUN echo "\t echo -ne \"\\b\\b\"" >> wait4postgres.sh
RUN echo "\tsleep 1s" >> wait4postgres.sh
RUN echo "\tb=\$(netstat -tulpn | grep 5432)" >> wait4postgres.sh
RUN echo "\tif [ ! -z \"\$b\" ]" >> wait4postgres.sh
RUN echo "\tthen" >> wait4postgres.sh
RUN echo "\t\ta=$(( a + 1 ))" >> wait4postgres.sh
RUN echo "\t\techo \"A process is listening on 5432, presuming postgresql\"" >> wait4postgres.sh
RUN echo "\t\texit 0" >> wait4postgres.sh
RUN echo "\tfi" >> wait4postgres.sh
RUN echo "done" >> wait4postgres.sh
RUN chmod +x wait4postgres.sh
# wait for the db container:
# RUN sudo ./wait4postgres.sh && rm -f wait4postgres.sh
```
(The last line will also delete the file after the execution to eliminate unnecessary scripts littering your container).

## dependencies

This script uses Netstat.

## the idea

I had this idea after incurring in complications trying to use vishnubob's excellent wait-for-it (https://github.com/vishnubob/wait-for-it.git), which is a much more complete solution covering a much broader variety of needs, and is maybe not really thought for this use case (although it can probably do in expert hands). This is intended to be more noob-friendly ;)
