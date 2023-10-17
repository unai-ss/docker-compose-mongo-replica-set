    command:
      - sudo apt install -y curl
      - curl -O https://fastdl.mongodb.org/tools/mongosync/mongosync-rhel80-x86_64-1.6.1.tgz
      - tar -xf mongosync-rhel80-x86_64-1.6.1.tgz
    ports:
      - 27182:27182
    volumes:
      - ./data/mongosync:/data/mongosync
    extra_hosts:
      - "host.docker.internal:host-gateway"