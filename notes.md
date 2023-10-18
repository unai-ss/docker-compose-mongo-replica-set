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


          command:
      - sh -c  "mongosync  --config /data/mongosync/mongosync.conf"


troubleshooting
      https://support.mongodb.com/case/01094019?c__ccId=CC-3536482


    command: [mongosync, --config, /data/mongosync/mongosync.conf]

apt-get update
apt install iputils-ping


curl localhost:27182/api/v1/progress -XGET

mongosh "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"
mongosh "mongodb://127.0.0.1:30011,127.0.0.1:30012,127.0.0.1:30013/?replicaSet=dst-replica-set"
mongosh "mongodb://mongob1:30011,mongob2:30012,mongob3:30013/?replicaSet=dst-replica-set"

❯ ls '/Users/unai.solaguren/Documents/GitHub/mgodatagen/datagen/testdata/big_mongosync_fornova.json'
/Users/unai.solaguren/Documents/GitHub/mgodatagen/datagen/testdata/big_mongosync_fornova.json

repeat 1000 {time ./mgodatagen -a -f datagen/generators/testdata/ref.json --uri  "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"; sleep 1s}

repeat 1000 {time ./mgodatagen -a -f datagen/testdata/big_mongosync_fornova.json --uri  "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"; sleep 1s}
./mgodatagen -a -f datagen/testdata/big_mongosync_fornova.json --uri  "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"

