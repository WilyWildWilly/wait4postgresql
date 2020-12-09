#!/bin/bash
a=0
t=0
while ((a < 1))
        do
                t=$(( t + 1 ))
                echo -ne "No process on port 5432, waiting $t s for postgresql...^M"
                echo -ne "\b\b"
                sleep 1s
        b=$(netstat -tulpn 2>/dev/null | grep 5432)
        if [ ! -z "$b" ]
        then
                a=1
                echo "A process is listening on 5432, presuming postgresql"
                exit 0
        fi
done
