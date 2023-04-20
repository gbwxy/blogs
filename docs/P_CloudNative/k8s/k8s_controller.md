# kubernetes 控制器

## ReplicaSet

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: mydemo
        image: mydemo:v1
        env:
        - name: GET_HOSTS_FROM
          value: dns
        port:
        - containerPort: 80      

```

kubectl apply -f frontend.yaml --namespace=my-namespace --validate=false

kubectl get rs --namespace=my-namespace 

kubectl get pod --namespace=my-namespace  -o wide
kubectl get pod --all-namespaces -o wide | grep frontend

kubectl delete pod --namespace=my-namespace --all


更换其中一个pod的标签
kubectl label pod frontend-99vks tier=frontend1 --overwrite=true --namespace=my-namespace 

kubectl get pod --namespace=my-namespace -o wide --show-labels






## Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: my-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: mydemo-nginx
        image: mydemo:v1
        ports:
        - containerPort: 80
```

#### 创建Deployment

kubectl apply -f nginx-deployment.yaml --namespace=my-namespace --record 

kubectl get deployment  --namespace=my-namespace -o wide 

kubectl get rs  --namespace=my-namespace -o wide

kubectl get pod --namespace=my-namespace -o wide

kubectl get pod --namespace=my-namespace -o wide --show-labels

#### 扩、缩容
kubectl scale deployment nginx-deployment --replicas=10 --namespace=my-namespace

![](https://note.youdao.com/yws/api/personal/file/AA478A3A1B924A1FB194A9596E8AB56F?method=download&shareKey=f00a6b4eb4164b7e96b9d473dee3af62)

#### Horizontal Pod Autoscaling
kubectl autoscale deployment nginx-deployment --min=3 --max=10 --cpu-percent=80  --namespace=my-namespace

#### 更新镜像
kubectl set image deployment/nginx-deployment mydemo-nginx=mydemo:v2 --namespace=my-namespace

![](https://note.youdao.com/yws/api/personal/file/1B94456875A140BB838AE9DF0F996CEB?method=download&shareKey=e1e96a1819d6295f5f5b0f5a25b63fd4)

![](https://note.youdao.com/yws/api/personal/file/DCF9D8BDF29A48E784941B25C66A4FC8?method=download&shareKey=b06583bb7a341772704c571f0a49f254)

#### rollout

**回滚**
kubectl rollout undo deployment/nginx-deployment --namespace=my-namespace

![](https://note.youdao.com/yws/api/personal/file/863E1701A6644B52AB88E2B2DBFF3985?method=download&shareKey=3f32336b312fb2e7c6b207e53c5ced51)

**状态与历史**
kubectl rollout status deployment/nginx-deployment --namespace=my-namespace
kubectl rollout history deployment/nginx-deployment --namespace=my-namespace 
![](https://note.youdao.com/yws/api/personal/file/D85BABC3C41C45BB89467B7423E07070?method=download&shareKey=c9ae30be3e7aae289bfa2d795dce67ca)

**指定rollout版本**

kubectl rollout undo deployment/nginx-deployment -- to-revision=1 --namespace=my-namespace

## DaemonSet

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  # namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
      - name: fluentd-elasticsearch
        image: myfluentd:v1
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers

```

kubectl apply -f daemonset_demo.yaml --namespace=my-namespace --record




## Job

```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.32
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4


```
kubectl create -f job.yaml --namespace=my-namespace 
kubectl log pi-qwgpj --namespace=my-namespace




## CronJob


```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 60
  failedJobsHistoryLimit: 100
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            imagePullPolicy: IfNotPresent
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure

          
```


