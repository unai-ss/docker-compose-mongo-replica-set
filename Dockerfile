FROM ubuntu:20.04
RUN apt update && apt install -y curl
RUN curl -O https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-1.6.1.tgz
RUN tar -xf mongosync-ubuntu2004-x86_64-1.6.1.tgz
RUN cp /mongosync-ubuntu2004-x86_64-1.6.1/bin/mongosync /usr/local/bin/
RUN mongosync --config /data/mongosync/mongosync.conf