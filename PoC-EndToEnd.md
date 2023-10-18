PoC-EndToEnd.md

## PoC MongoDB Mongosync End To End Experience.

1.- Writing data to MongoDB SRC database

The below [mgodatagen tool](https://github.com/feliixx/mgodatagen) writes `500000` documents of `308` bytes bson size each second for `1000` times on `mgodatagen_test.test` namespace running the below command on a `zsh` session.

```
repeat 1000 {time ./mgodatagen -a -f datagen/testdata/big_mongosync_fornova.json --uri  "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"; sleep 1s}
```

- mgodatagen output per each time.

```
./mgodatagen -a -f datagen/testdata/big_mongosync_fornova.json --uri   1.98s user 0.31s system 4% cpu 47.142 total
usage: sleep seconds
connecting to mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set
MongoDB server version 7.0.2

Using seed: 1697630987

collection double_id_Fornova: done  [====================================================================] 100%

+-------------------+----------+-----------------+-----------------+
|    COLLECTION     |  COUNT   | AVG OBJECT SIZE |     INDEXES     |
+-------------------+----------+-----------------+-----------------+
| double_id_Fornova | 16111100 |             308 | _id_  734260 kB |
+-------------------+----------+-----------------+-----------------+

run finished in 43.78s
```

* Check the document bson size

```
> use mgodatagen_test
switched to db mgodatagen_test
> Object.bsonsize(db.double_id_Fornova.findOne())
306

```

*  mgodatagen `datagen/testdata/big_mongosync_fornova.json` file config.

- `Count` value in the `datagen/testdata/big_mongosync_fornova.json` file allow us to set the number of inserted document per second
```
[
    {
      "database": "mgodatagen_test",
      "collection": "double_id_Fornova",
      "count": 500000,
```

- Strictly for this repro scenario, testing a `double`, such I understand it's a golang `float64`, following [mgodatagen types](https://github.com/feliixx/mgodatagen#generator-types)

```
      "content": {
        "_id": {
          "type": "double",
          "min" : 0.0,
          "max" : 10.0,
          "nullPercentage":   0,
          "maxDistinctValue": 500000 
        },
```

2.- Mongosync - configuration.

On this project `data\mongotools\mongosync.conf` file you will find a standard mongosync config as the below snippet

```
cluster0: "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"
cluster1: "mongodb://mongob1:30011,mongob2:30012,mongob3:30013/?replicaSet=dst-replica-set"
logPath: "/data/mongosync/logs"
verbosity: "TRACE"
```

The above snippet show the below parameters:

* cluste0: point to this project `replicaSet=src-replica-set` RS ("mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set").
* cluste0: point to this project `replicaSet=dst-replica-set` RS ("mongodb://mongob1:30011,mongob2:30012,mongob3:30013/?replicaSet=dst-replica-set").
* logPath: the mongosync log files will be accesible on the local disk on the `PROJECT_PATH/data/mongotools/logs` folder (logPath: "/data/mongosync/logs").

Initially the `mongosync` container is able to connect with Atlas or RS running out of the docker enviroment, due to the `extra_hosts: "host.docker.internal:host-gateway"` docker parameter. [E.g.] Similar config on previous repro enviroment for Kafka [here](https://github.com/unai-ss/Kafka-Kconnector-Prometheus-Grafana/tree/main#mongodb-rs-on-localhost).


2.1- Mongosync - run.

* How to access to the Mongosync Instance from localhost.
```
docker exec -it mongosync /bin/bash
```

Start to `mongosync` migration process on the `mongosync` container [MongoDB Official Doc](https://www.mongodb.com/docs/cluster-to-cluster-sync/current/reference/api/start/#example--start-a-sync-job).
```
curl localhost:27182/api/v1/start -XPOST \
--data '
   {
      "source": "cluster0",
      "destination": "cluster1"
   } '

```

The `mongosync` migration status [MongoDB Official Doc](https://www.mongodb.com/docs/cluster-to-cluster-sync/current/reference/api/progress/#request-1):

```
curl localhost:27182/api/v1/progress -XGET

```

Then I run the below `curl` command on a command shell session.

```
curl -s -X POST -H 'Content-Type: application/json' --data @./source.json http://localhost:8083/connectors
```

3.- Check the MongoDB RS DST and SRC

* Connect to SRC cluster from localhost
```
mongosh "mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set"
```

* Connect to DST cluster from localhost
```
mongosh "mongodb://mongob1:30011,mongob2:30012,mongob3:30013/?replicaSet=dst-replica-set"
```
