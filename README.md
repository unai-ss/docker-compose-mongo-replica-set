# Running a Local Mongo Replica Set

## Contents
* [What is it?](#what-is-it)
* [Versions](#versions)
* [Are there any prerequisites?](#are-there-any-prerequisites)
* [How do I run the Replica Set?](#how-do-i-run-the-replica-set)
* [How do I access the Mongo Shells for each Instance?](#how-do-i-access-the-mongo-shells-for-each-instance)
* [How does it work?](#how-does-it-work)
* [Robo 3T](#robo-3t)
* [Thanks / Further Reading](#thanks--further-reading)

## Disclaimer
> :warning: **This setup is purely for local development purposes.**
> 
> This setup should not be used for production applications as it was not built with that in mind. 

## What is it?
This `docker-compose` setup starts a local mongo replica set with 3 instances running on: 
- mongo1:30001
- mongo2:30002
- mongo3:30003

## Versions
* Different versions are available to cater for the various major versions of Mongo
* You can find the most suitable one by looking at the [tags](https://github.com/UpSync-Dev/docker-compose-mongo-replica-set/tags) or [releases](https://github.com/UpSync-Dev/docker-compose-mongo-replica-set/releases) 

## Are there any prerequisites? 
* Docker
* Docker Compose
* The following in your `/etc/hosts` file:
```
127.0.0.1       host.docker.internal
127.0.0.1       mongo1
127.0.0.1       mongo2
127.0.0.1       mongo3
```

## How do I run the Replica Set?
Simples:
```
docker-compose up -d
```

## How do I access the Mongo Shells for each Instance?
```
docker exec -it mongo1 sh -c "mongo --port 30001"
docker exec -it mongo2 sh -c "mongo --port 30002"
docker exec -it mongo3 sh -c "mongo --port 30003"
```

## How does it work?
- Starts three instances of Mongo
- On the first instance it runs the following Mongo Shell command:
```
rs.initiate(
  {
    _id : 'my-replica-set',
    members: [
      { _id : 0, host : "mongo1:30001" },
      { _id : 1, host : "mongo2:30002" },
      { _id : 2, host : "mongo3:30003" }
    ]
  }
)
```
- This causes all 3 instances to join the replica set named `my-replica-set` and start talking to each other
- One is elected to become the `PRIMARY` and the other two become `SECONDARY` instances
- The Docker healthcheck config is used to cause the initialisation of the replica set. More info in the further reading links.


## Connecting with URI
```
mongodb://mongo1:30001,mongo2:30002,mongo3:30003/?replicaSet=my-replica-set
```
