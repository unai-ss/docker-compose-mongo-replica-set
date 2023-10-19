FROM ubuntu:20.04
RUN apt update && apt install -y curl
RUN apt update && apt install -y curl build-essential libssl-dev libffi-dev python3-dev unzip
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN curl -O https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-1.6.1.tgz
RUN tar -xf mongosync-ubuntu2004-x86_64-1.6.1.tgz
RUN cp /mongosync-ubuntu2004-x86_64-1.6.1/bin/mongosync /usr/local/bin/
COPY requirements.txt /mongosync_monitor/helpers/requirements.txt
VOLUME /mongosync_monitor/
EXPOSE 27182
EXPOSE 8080 