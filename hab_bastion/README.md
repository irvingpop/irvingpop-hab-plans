# Habitat package: hab_bastion

## Description

This plan simply runs a supervisor, for purposes of providing a "permanent peer".  The idea is that you'd cluster 3 of these together to provide a stable ring for production applications.

## Usage

See the `kubernetes/` folder for an example of launching the bastion ring, as well as an example consumer. the docker containers referenced do exist.
The idea is that we'll create 3 services and statefulsets (hab-bastion-1,2,3) and expose all three as available for consumption.

1. Launch the bastion ring
```
cd kubernetes
kubectl create -f hab-bastion-ring.yaml
```

check that it is working
```
00:43 $ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
hab-bastion-1-0                     1/1       Running   1          22m
hab-bastion-2-0                     1/1       Running   0          22m
hab-bastion-3-0                     1/1       Running   0          22m

00:43 $ kubectl logs hab-bastion-1-0
hab-sup(MR): Supervisor Member-ID 46fa10c1e2e94db791dd968849eebd14
hab-sup(AG): The irvingpop/hab_bastion service was successfully loaded
hab-sup(MR): Starting irvingpop/hab_bastion
hab_bastion.default(UCW): Watching user.toml
hab-sup(MR): Starting gossip-listener on 0.0.0.0:9638
hab-sup(MR): Starting ctl-gateway on 127.0.0.1:9632
hab-sup(MR): Starting http-gateway on 0.0.0.0:9631
hab_bastion.default(HK): run, compiled to /hab/svc/hab_bastion/hooks/run
hab_bastion.default(HK): Hooks compiled
hab_bastion.default(SR): Hooks recompiled
hab_bastion.default(SR): Initializing
hab_bastion.default(SV): Starting service as user=hab, group=hab
hab_bastion.default(HK): Hooks compiled
```

2. Launch a service that will talk to the ring
```
kubectl create -f hab-consumer-of-ring-example.yaml
# deployment.apps/redis-deployment created
```

check that it's working:
```
00:44 $ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
hab-bastion-1-0                     1/1       Running   1          25m
hab-bastion-2-0                     1/1       Running   0          25m
hab-bastion-3-0                     1/1       Running   0          25m
redis-deployment-5d59ff5cd9-hd88b   1/1       Running   0          8m
redis-deployment-5d59ff5cd9-jfpmz   1/1       Running   0          8m
redis-deployment-5d59ff5cd9-xfqlf   1/1       Running   0          8m

00:46 $ kubectl logs -f redis-deployment-5d59ff5cd9-hd88b
hab-sup(MR): Supervisor Member-ID d25ecf35f82c4cc38eaa7d4b1cd61bb9
hab-sup(MR): Starting irvingpop/redis
redis.default(UCW): Watching user.toml
hab-sup(MR): Starting gossip-listener on 0.0.0.0:9638
hab-sup(MR): Starting http-gateway on 0.0.0.0:9631
redis.default(HK): Hooks compiled
default(CF): Updated redis.config e7c6f76ce2c2707b075f335de82d15dda1e07f8870eb220e492313bf8f1074b8
redis.default(SR): Configuration recompiled
redis.default(SR): Waiting to execute hooks; election in progress, and we have no quorum.
redis.default(HK): Hooks compiled
redis.default(HK): Hooks compiled
redis.default(HK): Hooks compiled
default(CF): Updated redis.config 9012cf0411fbc3a1560199e431367765ab0fe093a49978a7d4005c1e72d20a9c
redis.default(SR): Configuration recompiled
redis.default(SR): Executing hooks; d483ea492e2445838c906fa1f6449e22 is the leader
redis.default(SR): Initializing
redis.default(SV): Starting service as user=hab, group=hab
redis.default(O):                 _._
redis.default(O):            _.-``__ ''-._
redis.default(O):       _.-``    `.  `_.  ''-._           Redis 3.2.11 (00000000/0) 64 bit
redis.default(O):   .-`` .-```.  ```\/    _.,_ ''-._
redis.default(O):  (    '      ,       .-`  | `,    )     Running in standalone mode
redis.default(O):  |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
redis.default(O):  |    `-._   `._    /     _.-'    |     PID: 76
redis.default(O):   `-._    `-._  `-./  _.-'    _.-'
redis.default(O):  |`-._`-._    `-.__.-'    _.-'_.-'|
redis.default(O):  |    `-._`-._        _.-'_.-'    |           http://redis.io
redis.default(O):   `-._    `-._`-.__.-'_.-'    _.-'
redis.default(O):  |`-._`-._    `-.__.-'    _.-'_.-'|
redis.default(O):  |    `-._`-._        _.-'_.-'    |
redis.default(O):   `-._    `-._`-.__.-'_.-'    _.-'
redis.default(O):       `-._    `-.__.-'    _.-'
redis.default(O):           `-._        _.-'
redis.default(O):               `-.__.-'
redis.default(O):
redis.default(O): 76:S 30 Aug 00:39:07.700 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
redis.default(O): 76:S 30 Aug 00:39:07.700 # Server started, Redis version 3.2.11
redis.default(O): 76:S 30 Aug 00:39:07.700 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
redis.default(O): 76:S 30 Aug 00:39:07.700 * The server is now ready to accept connections on port 6379
redis.default(O): 76:S 30 Aug 00:39:07.701 * Connecting to MASTER 172.17.0.9:6379
redis.default(O): 76:S 30 Aug 00:39:07.701 * MASTER <-> SLAVE sync started
redis.default(O): 76:S 30 Aug 00:39:07.702 * Non blocking connect for SYNC fired the event.
redis.default(O): 76:S 30 Aug 00:39:07.702 * Master replied to PING, replication can continue...
redis.default(O): 76:S 30 Aug 00:39:07.702 * Partial resynchronization not possible (no cached master)
redis.default(O): 76:S 30 Aug 00:39:07.702 * Full resync from master: c5d485d2e0305d825911e3a89f119476cceee1b6:1
redis.default(O): 76:S 30 Aug 00:39:07.714 * MASTER <-> SLAVE sync: receiving 77 bytes from master
redis.default(O): 76:S 30 Aug 00:39:07.714 * MASTER <-> SLAVE sync: Flushing old data
redis.default(O): 76:S 30 Aug 00:39:07.714 * MASTER <-> SLAVE sync: Loading DB in memory
redis.default(O): 76:S 30 Aug 00:39:07.714 * MASTER <-> SLAVE sync: Finished with success
```

