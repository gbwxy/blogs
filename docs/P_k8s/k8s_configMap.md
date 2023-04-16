# kubernetes ConfigMap

### ConfigMap 创建
#### 目录or文件创建
创建时候指定文件所在目录或文件
创建后的 ConfigMap 中 data 以 key-value 方式存储，其中文件名为 key，文件内容为 value

cat game.properties
```json
enenies.cheat=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLBABAS
secret.code.allowed=true
secret.code.lives=30
```

cat ui.properties
```json
color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice
```

kubectl create configmap game-config --from-file=/home/demo/configMap/ --namespace=my-namespace

![](https://note.youdao.com/yws/api/personal/file/1626814BBDA24A499BB07DC271182BDF?method=download&shareKey=75279dbc32de3c9904796d26f3a531c0)

kubectl get cm --namespace=my-namespace game-config -o yaml
```yaml
apiVersion: v1
data:
  game.properties: |
    enenies.cheat=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLBABAS
    secret.code.allowed=true
    secret.code.lives=30
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
kind: ConfigMap
metadata:
  creationTimestamp: "2021-01-11T02:31:14Z"
  name: game-config
  namespace: my-namespace
  resourceVersion: "75912539"
  selfLink: /api/v1/namespaces/my-namespace/configmaps/game-config
  uid: 1364e4f1-53b5-11eb-80f5-0cda411d909b
  
```
#### 字面值创建

创建时候指定 key 和 value
创建后的 ConfigMap 中 data 以 key-value 方式存储，创建命令中指定的 key 和 value 一 一对应

kubectl create configmap special-config --namespace=my-namespace --from-literal=special.how=very --from-literal=special.type=charm

 kubectl get cm --namespace=my-namespace special-config -o yaml
```yaml
apiVersion: v1
data:
  special.how: very
  special.type: charm
kind: ConfigMap
metadata:
  creationTimestamp: "2021-01-11T02:44:33Z"
  name: special-config
  namespace: my-namespace
  resourceVersion: "75913719"
  selfLink: /api/v1/namespaces/my-namespace/configmaps/special-config
  uid: efc0d36a-53b6-11eb-8a71-0cda411df71b

```

#### 以资源清单的方案创建
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
  namespace: my-namespace
data:
  log_level: INFO

```

kubectl apply -f env.yaml --namespace=my-namespace --record 



### Pod 中使用 ConfigMap

```
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  restartPolicy: Never
  containers:
    - name: demo
      image: mydemo:v1
      command: ["/bin/sh","-c","env"]
      env:
        - name: SPECIAL_LEVEL_KEY    # 这里和 ConfigMap 中的键名是不一样的
          valueFrom:
            configMapKeyRef:
              name: special-config  # 这个值来自 ConfigMap
              key: special.how      # 需要取值的键
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
      envFrom:
          - configMapRef:
              name: env-config
```

kubectl logs -f --tail=500 configmap-demo-pod --namespace=my-namespace
```
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
MYAPP_SERVICE_PORT_HTTP=30080
MYAPP_N_PORT_30080_TCP=tcp://10.100.24.57:30080
HOSTNAME=configmap-demo-pod
HOME=/root
MYAPP_SERVICE_HOST=10.104.163.13
PKG_RELEASE=1~stretch
SPECIAL_TYPE_KEY=charm
MYAPP_PORT_30080_TCP_ADDR=10.104.163.13
MYAPP_SERVICE_PORT=30080
MYAPP_PORT=tcp://10.104.163.13:30080
MYAPP_PORT_30080_TCP_PORT=30080
MYAPP_PORT_30080_TCP_PROTO=tcp
MYAPP_N_SERVICE_PORT_HTTP=30080
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
NGINX_VERSION=1.17.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
NJS_VERSION=0.3.2
KUBERNETES_PORT_443_TCP_PROTO=tcp
MYAPP_PORT_30080_TCP=tcp://10.104.163.13:30080
MYAPP_N_SERVICE_HOST=10.100.24.57
SPECIAL_LEVEL_KEY=very
log_level=INFO
MYAPP_N_PORT_30080_TCP_ADDR=10.100.24.57
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
MYAPP_N_PORT_30080_TCP_PORT=30080
MYAPP_N_SERVICE_PORT=30080
MYAPP_N_PORT=tcp://10.100.24.57:30080
MYAPP_N_PORT_30080_TCP_PROTO=tcp
KUBERNETES_SERVICE_HOST=10.96.0.1
PWD=/

```

### 通过数据卷插件使用 ConfigMap

```
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: mydemo:v1
      command: ["sleep", "36000"]
      env:
        - name: SPECIAL_LEVEL_KEY    # 这里和 ConfigMap 中的键名是不一样的
          valueFrom:
            configMapKeyRef:
              name: special-config  # 这个值来自 ConfigMap
              key: special.how      # 需要取值的键
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
      volumeMounts:
      - name: config-volume
        mountPath: "/etc/config"
        readOnly: true
  volumes:
    - name: config-volume
      configMap:        
        name: game-config # 提供你想要挂载的 ConfigMap 的名字
        items:   # 来自 ConfigMap 的一组键，将被创建为文件
        - key: "game.properties"
          path: "game.properties"
        - key: "ui.properties"
          path: "ui.properties"
```
kubectl create -f pod_env_cm_vl.yaml --namespace=my-namespace --record

kubectl exec -ti --namespace=my-namespace configmap-demo-pod  /bin/bash

![](https://note.youdao.com/yws/api/personal/file/74888312047F44F29CD5AEE16BB3FFA5?method=download&shareKey=c241403d32cad214c3fea7fa39a7bbc5)


###  ConfigMap热更新

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-cm
  labels:
    app: my-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mydemo-nginx
  template:
    metadata:
      labels:
        app: mydemo-nginx
    spec:
      containers:
      - name: mydemo-nginx
        image: mydemo:v1
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: "/etc/config"
          readOnly: true
      volumes:
        - name: config-volume
          configMap:        
            name: game-config # 提供你想要挂载的 ConfigMap 的名字
            items:   # 来自 ConfigMap 的一组键，将被创建为文件
            - key: "game.properties"
              path: "game.properties"
            - key: "ui.properties"
              path: "ui.properties"


```
 kubectl apply -f deployment_cm.yaml --namespace=my-namespace 
 kubectl get pod --namespace=my-namespace -o wide

![](https://note.youdao.com/yws/api/personal/file/CA7749C2DAEF4A009937C805B2FD1C29?method=download&shareKey=476c2c463f817ab4d9ec8e3a9309ae6b)

 kubectl exec -ti nginx-deployment-cm-5584f8f989-6jp5r --namespace=my-namespace /bin/bash

![](https://note.youdao.com/yws/api/personal/file/6B0F46C95BF840DD994C3E2ED9E1C36B?method=download&shareKey=dd7be6a745067d25921ad8978f1acd45) 

kubectl edit cm --namespace=my-namespace game-config

修改   game.properties.lives=10

kubectl exec -ti nginx-deployment-cm-5584f8f989-6jp5r --namespace=my-namespace /bin/bash

![](https://note.youdao.com/yws/api/personal/file/2930F239A0CA40AE9276BA269B97C97F?method=download&shareKey=286bb49033250f58ab2b2a8ca49b4095)


**更新 ConfigMap 后：
使用该 ConfigMap 挂载的 Env 不会同步更新
使用该 ConfigMap 挂载的 Volume 中的数据需要一段时间（大概10s）才能同步更新**


