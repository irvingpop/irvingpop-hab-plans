# The Habitat Bastion Pattern in Kubernetes

The idea of this pattern is to establish a single, highly robust kubernetes pod to serve as an initial and permament peer for Habitat gossip.  

This pod is deployed as a Stateful Set with a Persistent Volume attached to store all gossip ring state.

A kubernetes service is attached in order to make it easily discoverable with DNS.

## Running it

1. Launch the bastion
```
kubectl apply -f hab-bastion.yaml
```

2. Wait for the it to come online
```
kubectl get all
kubectl describe pod hab-bastion-0
kubectl logs -f hab-bastion-0
```

3. Bring up a service that would want to talk to hab bastion
```
kubectl apply -f hab-bastion-consumer.yaml
```

## What's going on here?

First let's break down the hab-bastion.yaml file:

```
---
apiVersion: v1
kind: Service
metadata:
  name: hab-bastion
spec:
  ports:
  - name: gossip-listener
    protocol: UDP
    port: 9638
    targetPort: 9638
  - name: http-gateway
    protocol: TCP
    port: 9631
    targetPort: 9631
  selector:
    app: hab-bastion
  clusterIP: None
```

This service defition creates a VIP-type thing, opening access to the Habitat service that will run on the pod.
- The habitat gossip port (9638/UDP) listener
- The habitat http-gateway (9631/TCP) listener
- the service name becomes available in DNS (as `hab-bastion` or `hab-bastion.namespacename`, etc) so any pod can find it

```
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: hab-bastion
spec:
   spec:
      securityContext:
        fsGroup: 42
```

This bit sets a group ownership for the persistent volume mount point, so that the hab supervisor can write to it.  The habitat user by default has uid `42` and gid `42`

```
      containers:
      - name: hab-bastion
        image: irvingpop/hab_bastion:latest
        args:
        - '--permanent-peer'
```

This tells you where to get the docker container from, the hab plan that defines this contaienr is one folder up in this repo. It basically runs no service but the supervisor.
The argument `--permanent-peer` instructs the supervisor to act as a permanent peer.

```
        resources:
          requests:
            memory: "100Mi"
            cpu: "100m" # equivalent to 0.1 of a CPU core
```

Resource requests are important to inform the kubernetes scheduler - without them, some nodes could be overloaded while others are underutilized.

```
        ports:
        - name: gossip-listener
          protocol: UDP
          containerPort: 9638
        - name: http-gateway
          protocol: TCP
          containerPort: 9631
        readinessProbe:
          httpGet:
            path: /
            port: 9631
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 9631
          initialDelaySeconds: 15
          periodSeconds: 20
```

The livenessProbe lets kubernetes know if the pod is healthy or not.  If not it will get restarted.

```
        volumeMounts:
        - name: hab-bastion
          mountPath: /hab/sup
  volumeClaimTemplates:
  - metadata:
      name: hab-bastion
    spec:
      accessModes: [ "ReadWriteOnce" ]
      # uncomment if you don't have a default storageclass
      # storageClassName: "standard"
      resources:
        requests:
          storage: 10Gi
```

All of habitat's state data is stored under `/hab/sup` - we mount this on a persistent volume so it gets re-attached if the pod is ever relaunched. The data persists! 
