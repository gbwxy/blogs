# kubernetes-PV&PVC

## 概念

#### PV - Persistent Volume 
PV 是由管理员设置的存储，它是集群的一部分。就像节点是集群的资源一样，PV 也是集群中的资源。PV 是 Volume 之类的卷插件，但具有独立与使用 PV 的 Pod 的生命周期。此 API 对象包含存储实现细节，即 NFS、ISCSI 或特定的云供应商的存储系统

#### PVC - Persistent Volume Claim
PVC 是用户存储的请求。它与 Pod 相似。Pod 消耗节点的资源，PVC 消耗 PV 资源。Pod 可以请求特定级别的资源（CPU 和内存）。PVC 可以请求特定的大小和访问模式（例如，可以以读/写一次或多次模式挂载）

#### 静态 PV
集群管理员创建一些 PV。它们带有可供集群用户使用的实际存储的细节。它们存在于 kubernetes API 中，可用于消费。

#### 动态 PV
当管理员创建的静态 PV 都不匹配用户的 PVC 时，集群可能会尝试动态地为 PVC 创建卷。此配置基于 Storage Classes：PVC 必须请求 Storage Classes，并且管理员必须创建并配置该 Storage Classes 才能进行动态创建。

要启用基于存储级别的动态存储配置，集群管理员需要启用 API server 上的 Default Storage Class 。例如，通过确保 Default Storage Class 位于 API server 组件 --admission-control 标志，使用逗号分隔的有序值列表中，可以完成此操作。

#### 绑定
master 中的控制环路监控新的 PVC ，寻找匹配的 PV，并将它们绑定在一起。如果为新的 PVC 动态调配 PV ，则该环路将始终将该 PV 绑定到 PVC，否则，用户总会得到他们所请求的存储，但是容量可能超出要求的数量。一旦 PV 和 PVC 绑定后， PVC 绑定是排他性的，不管它们是如何绑定的，PVC 和 PV 绑定是一对一映射的。

####  Storage Classes

####  Default Storage Class



## 例子

所有节点都需要安装nfs-common nfs-utils rpcbind

yum install -y nfs-common nfs-utils rpcbind
mkdir /nfsdata
chmod 777 /nfsdata/
chown nfsnobody /nfsdata/
vim  /etc/exports
```
/nfsdata *(rw,no_root_squash,no_all_squash,sync)
```
systemctl start rpcbind
systemctl start nfs




```
apiVersion: v1
kind: PersistentVolume
metadata:
   name: nfspv1
spec:
   capacity:
      storage: 10Gi
   accessModes:
     - ReadWriteOnce
   persistentVolumeReclaimPolicy: Recycle
   storageClassName: nfs
   nfs:
      path: /nfs1
      server: 10.0.46.30
---
apiVersion: v1
kind: PersistentVolume
metadata:
   name: nfspv2
spec:
   capacity:
      storage: 1Gi
   accessModes:
     - ReadWriteMany
   persistentVolumeReclaimPolicy: Recycle
   storageClassName: nfs
   nfs:
      path: /nfs2
      server: 10.0.46.30
---
apiVersion: v1
kind: PersistentVolume
metadata:
   name: nfspv3
spec:
   capacity:
      storage: 5Gi
   accessModes:
     - ReadOnlyMany
   persistentVolumeReclaimPolicy: Recycle
   storageClassName: hahaha
   nfs:
      path: /nfs3
      server: 10.0.46.30
---
apiVersion: v1
kind: PersistentVolume
metadata:
   name: nfspv4
spec:
   capacity:
      storage: 1Gi
   accessModes:
     - ReadWriteOnce
   persistentVolumeReclaimPolicy: Recycle
   storageClassName: slow
   nfs:
      path: /data/nfs
      server: 10.0.46.30
      
```

kubectl create -f pv.yaml
kubectl  get pv 


```
apiVersion: v1
kind: Service
metadata:
   name: nginx
   labels:
      app: nginx
spec:
   ports:
   - port: 80
     name: web
   clusterIP: None
   selector:
      app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
   name: web
spec:
   selector:
      matchLabels:
         app: nginx
   serviceName: "nginx"
   replicas: 3
   template:
      metadata:
         labels:
            app: nginx
      spec:
         containers:
         - name: nginx
           image: myapp:v1
           ports:
           - containerPort: 80
             name: web
           volumeMounts:
           - name: www
             mountPath: /home/demo/nginx/html
   volumeClaimTemplates:
   - metadata:
      name: www
     spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: "nfs"
        resources:
           requests:
             storage: 10Gi
```

kubectl apply -f pod.yaml --namespace=my-namespace --record

kubectl get pod --namespace=my-namespace 


kubectl  get pv --namespace=my-namespace



kubectl  get pvc --namespace=my-namespace

kubectl  get pvc --namespace=my-namespace www-web-0 -o yaml

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    pv.kubernetes.io/bind-completed: "yes"
    pv.kubernetes.io/bound-by-controller: "yes"
  creationTimestamp: "2021-01-18T08:21:03Z"
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: nginx
  name: www-web-0
  namespace: my-namespace
  resourceVersion: "76834499"
  selfLink: /api/v1/namespaces/my-namespace/persistentvolumeclaims/www-web-0
  uid: 1aaeabdc-5966-11eb-8a71-0cda411df71b
spec:
  accessModes:
  - ReadWriteOnce
  dataSource: null
  resources:
    requests:
      storage: 10Gi
  storageClassName: nfs
  volumeMode: Filesystem
  volumeName: nfspv1
status:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  phase: Bound
```




