FROM ubuntu:22.04
RUN apt update && apt install -y curl
RUN curl -O https://fastdl.mongodb.org/tools/mongosync/mongosync-rhel80-x86_64-1.6.1.tgz
RUN tar -xf mongosync-rhel80-x86_64-1.6.1.tgz