# Running a Local 2 Mongo Replica Set and a mongosync instance

## Contents
* [What is it?](#what-is-it)
* [Versions](#versions)
* [Are there any prerequisites?](#are-there-any-prerequisites)
* [How do I run the Replica Set?](#how-do-i-run-the-replica-set)
* [How do I access the Mongo Shells for each Instance?](#how-do-i-access-the-mongo-shells-for-each-instance)
* [How does it work?](#how-does-it-work)
* [ToDo](#ToDo)

## Disclaimer
> :warning: **This setup is purely for local development purposes.**
> 
> This setup should not be used for production applications as it was not built with that in mind. 

## What is it?
This `docker-compose` setup starts a local mongo replica set with 3 instances running on: 
- mongoa1:30001
- mongoa2:30002
- mongoa3:30003

This `docker-compose` setup starts a second local mongo replica set with 3 instances running on: 
- mongob1:30011
- mongob2:30012
- mongob3:30013

Finally, This `docker-compose` setup starts a mongosync instance running on: 
- mongosync:27182

## Versions
* Different versions are available to cater for the various major versions of Mongo
* You can find the most suitable one by looking at the [tags](https://hub.docker.com/_/mongo/tags) or [mongo docker hub](https://hub.docker.com/_/mongo)
* There is alternative `4.4.25` version in the `docker-compose-4.4.25.yml` file.

## Are there any prerequisites? 
* Docker
* Docker Compose
* The following in your `/etc/hosts` file:
```
127.0.0.1       host.docker.internal
127.0.0.1       mongob1
127.0.0.1       mongob2
127.0.0.1       mongob3
127.0.0.1       mongoa1
127.0.0.1       mongoa2
127.0.0.1       mongoa3
127.0.0.1       mongosync
```

## How do I run the 2 x Replica Set and MongoSync?
Simples:
```
docker-compose up -d
```

## How do I access the Mongo Shells for each Instance?
```
docker exec -it mongoa1 sh -c "mongosh --port 30001"
docker exec -it mongoa2 sh -c "mongosh --port 30002"
docker exec -it mongoa3 sh -c "mongosh --port 30003"
docker exec -it mongob1 sh -c "mongosh --port 30011"
docker exec -it mongob2 sh -c "mongosh --port 30012"
docker exec -it mongob3 sh -c "mongosh --port 30013"
```
* How to access to the Mongosync Instance
```
docker exec -it mongosync /bin/bash
```

## How does it work?
- Starts three instances of Mongo
- On the first instance it runs the following Mongo Shell command:
```
rs.initiate(
  {
    _id : 'xxx-replica-set',
    members: [
      { _id : 0, host : "mongox1:300x1" },
      { _id : 1, host : "mongox2:300x2" },
      { _id : 2, host : "mongox3:300x3" }
    ]
  }
)
```
- This causes all 3 instances to join the replica set named `my-replica-set` and start talking to each other
- One is elected to become the `PRIMARY` and the other two become `SECONDARY` instances
- The Docker healthcheck config is used to cause the initialisation of the replica set. More info in the further reading links.

## End to End example

[PoC - End to End example](PoC-EndToEnd.md)

Prerequisites to run the End to End example

1.- [mgodatagen tool](https://github.com/feliixx/mgodatagen)

## Connecting with URI
* src-replica-set
```
mongodb://mongoa1:30001,mongoa2:30002,mongoa3:30003/?replicaSet=src-replica-set
```
* dst-replica-set
```
mongodb://mongob1:30011,mongob2:30012,mongob3:30013/?replicaSet=dst-replica-set
```
* mongosync
```
curl localhost:27182/api/v1/progress -XGET
```

## To Do
- Shutdown the replica-set and mantein the data in a healthy status before the `docker-compose down`

## Troubleshooting e.g.

The Docker health check config is used to cause the initialization of the replica set.

According to the docker logs on the mongo1, the health check runs as expected, and it's not triggering any severe error on the log files.

```bash
> docker logs mongo1  | grep "replSetInitiate admin command received from client" | more
{"t":{"$date":"2023-04-18T14:01:51.277+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn2","msg":"replSetInitiate admin command received from client"}
{"t":{"$date":"2023-04-18T14:02:02.971+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn18","msg":"replSetInitiate admin command received from client"}
{"t":{"$date":"2023-04-18T14:02:14.534+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn24","msg":"replSetInitiate admin command received from client"}
{"t":{"$date":"2023-04-18T14:02:26.078+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn28","msg":"replSetInitiate admin command received from client"}
{"t":{"$date":"2023-04-18T14:02:37.596+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn32","msg":"replSetInitiate admin command received from client"}
{"t":{"$date":"2023-04-18T14:02:49.208+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn36","msg":"replSetInitiate admin command received from client"}
{"t":{"$date":"2023-04-18T14:03:00.769+00:00"},"s":"I",  "c":"REPL",     "id":21356,   "ctx":"conn40","msg":"replSetInitiate admin command received from client"}
```

The below  docker exec command pipes to the `mongosh` on `mongo1` container showing the rs.conf()  command successfully
```bash
> docker exec -it mongo1 sh -c "mongosh --port 30001"
Current Mongosh Log ID: 643ea58348e121cd4c7a20ad
Connecting to:          mongodb://127.0.0.1:30001/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.8.0
Using MongoDB:          6.0.5
Using Mongosh:          1.8.0

For mongosh info see: https://docs.mongodb.com/mongodb-shell/

------
   The server generated these startup warnings when booting
   2023-04-18T14:01:41.406+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
   2023-04-18T14:01:41.407+00:00: vm.max_map_count is too low
------

------
   Enable MongoDB's free cloud-based monitoring service, which will then receive and display
   metrics about your deployment (disk utilization, CPU, operation statistics, etc).
   
   The monitoring data will be available on a MongoDB website with a unique URL accessible to you
   and anyone you share the URL with. MongoDB may use this information to make product
   improvements and to suggest MongoDB products and deployment options to you.
   
   To enable free monitoring, run the following command: db.enableFreeMonitoring()
   To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
------

my-replica-set [direct: primary] test> rs.conf()
{
  _id: 'my-replica-set',
  version: 1,
  term: 1,
  members: [
    {
      _id: 0,
      host: 'mongo1:30001',
      arbiterOnly: false,
      buildIndexes: true,
      hidden: false,
      priority: 1,
      tags: {},
      secondaryDelaySecs: Long("0"),
      votes: 1
    },
    {
      _id: 1,
      host: 'mongo2:30002',
      arbiterOnly: false,
      buildIndexes: true,
      hidden: false,
      priority: 1,
      tags: {},
      secondaryDelaySecs: Long("0"),
      votes: 1
    },
    {
      _id: 2,
      host: 'mongo3:30003',
      arbiterOnly: false,
      buildIndexes: true,
      hidden: false,
      priority: 1,
      tags: {},
      secondaryDelaySecs: Long("0"),
      votes: 1
    }
  ],
  protocolVersion: Long("1"),
  writeConcernMajorityJournalDefault: true,
  settings: {
    chainingAllowed: true,
    heartbeatIntervalMillis: 2000,
    heartbeatTimeoutSecs: 10,
    electionTimeoutMillis: 10000,
    catchUpTimeoutMillis: -1,
    catchUpTakeoverDelayMillis: 30000,
    getLastErrorModes: {},
    getLastErrorDefaults: { w: 1, wtimeout: 0 },
    replicaSetId: ObjectId("643ea2cfec688cb2fb3b8c39")
  }
}
my-replica-set [direct: primary] test> 
```
from my laptop command shell, I can connect successfully
```bash
> mongosh "mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set"
Current Mongosh Log ID: 643f008d3b9cc829d54e4ed7
Connecting to:          mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set&appName=mongosh+1.8.0
Using MongoDB:          6.0.5
Using Mongosh:          1.8.0

For mongosh info see: https://docs.mongodb.com/mongodb-shell/

------
   The server generated these startup warnings when booting
   2023-04-18T20:38:31.006+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
   2023-04-18T20:38:31.007+00:00: vm.max_map_count is too low
------

------
   Enable MongoDB's free cloud-based monitoring service, which will then receive and display
   metrics about your deployment (disk utilization, CPU, operation statistics, etc).
   
   The monitoring data will be available on a MongoDB website with a unique URL accessible to you
   and anyone you share the URL with. MongoDB may use this information to make product
   improvements and to suggest MongoDB products and deployment options to you.
   
   To enable free monitoring, run the following command: db.enableFreeMonitoring()
   To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
------

Warning: Found ~/.mongorc.js, but not ~/.mongoshrc.js. ~/.mongorc.js will not be loaded.
  You may want to copy or rename ~/.mongorc.js to ~/.mongoshrc.js.
my-replica-set [primary] test> 
```

I can reproduce the customer error by manually running the replica set init script. 
But why are they doing this? As the above outputs confirm, the health check scripts run successfully on the docker.

```
> docker exec -it mongo1 /bin/bash
root@db8613bc5a41:/# echo "rs.initiate({_id:'my-replica-set',members:[{_id:0,host:\"mongo1:30001\"},{_id:1,host:\"mongo2:30002\"},{_id:2,host:\"mongo3:30003\"}]}).ok || rs.status().ok" | mongosh --port 30001 --quiet
my-replica-set [direct: primary] test> rs.initiate({_id:'my-replica-set',members:[{_id:0,host:"mongo1:30001"},{_id:1,host:"mongo2:30002"},{_id:2,host:"mongo3:30003"}]}).ok || rs.status().ok
MongoServerError: already initialized
my-replica-set [direct: primary] test> root@db8613bc5a41:/# 
```

Finally, this docker-compose.yml is not supported by MongoDB; our tool is the Operator. Hence if the customer feels uncomfortable with how the health check works, they can modify the retry (interval, start_period) values to their necessities.
```
    healthcheck:
      test: test $$(echo "rs.initiate({_id:'my-replica-set',members:[{_id:0,host:\"mongo1:30001\"},{_id:1,host:\"mongo2:30002\"},{_id:2,host:\"mongo3:30003\"}]}).ok || rs.status().ok" | mongosh --port 30001 --quiet) -eq 1
      interval: 10s
      start_period: 30s
```

## Alternative setups (Thanks Nishant!)

With A quick search in mongosync repository shows there is some web server code using default "localhost". But I do notice there is a conditional expression that checks on a "flag". Possibly we have a break through? https://github.com/10gen/mongosync/blob/ed63eef4ca2cf17a63bf5754debeb2c4f0996384/internal/webserver/server.go#L91


``````

	hostName := "localhost"
	if server.featureFlags.IsEnabled(featureflags.AcceptRemoteAPIRequestFlag) {
		hostName = "0.0.0.0"
	}
``````
the file path is internal/webserver/server.go

All the feature flags are listed here https://github.com/10gen/mongosync/blob/ed63eef4ca2cf17a63bf5754debeb2c4f0996384/internal/mongosync/featureflags/feature_flags.go#L13.
