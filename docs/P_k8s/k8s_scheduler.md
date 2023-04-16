# kubernetes-调度与驱逐



Pod.Spec.NodeName

```
   nodeName	<string>
     NodeName is a request to schedule this pod onto a specific node. If it is
     non-empty, the scheduler simply schedules this pod onto that node, assuming
     that it fits resource requirements.

```

Sheduler 是作为单独的程序运行的，启动之后会一直监听 API Server，获取 Pod.Spec.nodeName 为空的 pod，对每个 Pod 都会创建一个 binding，表明 pod 应该放到哪个节点上


## node 亲和性

Pod.spec.affinity.nodeAffinity

preferredDuringSchedulingIgnoredDuringExecution  软策略
requiredDuringSchedulingIgnoredDuringExecution  硬策略

```
apiVersion: v1
kind: Pod
metadata:
   name: affinity-demo
   labels:
      app: node-affinity-pod
spec:
   containers:
   - name: with-node-affinity
     image: mydemo:v1
   affinity:
      nodeAffinity:
         requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: NotIn
                values:
                - k8s-node02
```


```
apiVersion: v1
kind: Pod
metadata:
   name: affinity-demo
   labels:
      app: node-affinity-pod
spec:
   containers:
   - name: with-node-affinity
     image: mydemo:v1
   affinity:
      nodeAffinity:
         preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 1
              preference:
                matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                  - k8s-m4
```


## pod 亲和性

Pod.spec.affinity.podAffinity            亲和性
Pod.spec.affinity.podAnitAffinity    反亲和性

![](https://note.youdao.com/yws/api/personal/file/5A63C241094742BFB70FB8390D5A58A1?method=download&shareKey=b1939c98f348e13ab3ead0b0eb609969)

preferredDuringSchedulingIgnoredDuringExecution  软策略
requiredDuringSchedulingIgnoredDuringExecution  硬策略

```
apiVersion: v1
kind: Pod
metadata:
   name: pod-3
   labels:
      app: pod-3
spec:
   containers:
   - name: pod-3
     image: mydemo:v1
   affinity:
      podAffinity:
         preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 1
              podAffinityTerm:
                 topologyKey: kubernetes.io/hostname
                 labelSelector:
                    matchExpressions:
                    - key: app
                      operator: In
                      values:
                      - pod-2
```


```
apiVersion: v1
kind: Pod
metadata:
   name: pod-3
   labels:
      app: pod-3
spec:
   containers:
   - name: pod-3
     image: mydemo:v1
   affinity:
      podAntiAffinity:
         requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                 matchExpressions:
                 - key: app
                   operator: In
                   values:
                   - pod-3
                   - pod-2
```


## 污点 Taint

```
#设置污点
kubectl  taint  nodes node1 key1=value1:NoSchedule

#节点说明中，查找 Taints 字段
kubectl describe pod pod-name

#去除污点
kubectl taint nodes node1 key1:NoSchedule-
```

## 容忍 tolerations

```
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
  tolerationSeconds: 6000
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
- key: "key1"
  operator: "Exists"
  effect: "NoSchedule"
```
当不指定 key 值时，表示容忍所有的污点 key
当不指定 effect 值时，表示容忍所有的污点作用
有多个 Master 存在时，防止资源浪费，可以如下设置
```
kubectl taint nodes NodeName node-role.kubernetes.io/master=:PreferNoSchedule
```

## 指定调度节点

pod.spec.nodeName
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: myweb
spec:
   replicas: 7
   template:
      metadata:
         labels:
            app: myweb
      spec:
         nodeName: k8s-node1
         containers:
         - name: myweb
           image: mydemo:v2
           ports:
           - containersPort: 80
```

pod.spec.nodeSelector
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: myweb
spec:
   replicas: 2
   template:
      metadata:
         labels:
            app: myweb
      spec:
         nodeSelector:
            node: node1
         containers:
         - name: myweb
           image: mydemo:v2
           ports:
           - containerPort: 80
```












