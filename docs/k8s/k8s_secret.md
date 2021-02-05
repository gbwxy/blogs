# kubernetes Secret

## Opaque Secret

### 创建说明
echo -n "admin" | base64
echo -n "admin1230" | base64 

echo -n "YWRtaW4xMjMw" | base64 -d

```
apiVersion: v1
kind: Secret
metadata:
   name: mysecret
type: Opaque
data:
   password: YWRtaW4xMjMw
   username: YWRtaW4=
```
 kubectl create -f mysecret.yaml --namespace=my-namespace 
 kubectl get secrets --namespace=my-namespace mysecret -o yaml

```
apiVersion: v1
data:
  password: YWRtaW4xMjMw
  username: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: "2021-01-12T06:07:46Z"
  name: mysecret
  namespace: my-namespace
  resourceVersion: "76059133"
  selfLink: /api/v1/namespaces/my-namespace/secrets/mysecret
  uid: 7da92b6f-549c-11eb-8a71-0cda411df71b
type: Opaque
```

### 使用说明
#### 将 Secret 挂载到 Volume 中
```
apiVersion: v1
kind: Pod
metadata:
   labels:
      name: seret-test
   name: seret-test
spec:
   volumes:
   - name: secrets
     secret:
        secretName: mysecret
   containers:
   - image: mydemo:v1
     name: db
     volumeMounts:
     - name: secrets
       mountPath: "/etc/secrets"
       readOnly: true
       
```
kubectl apply -f pod-secret.yaml --namespace=my-namespace --record

![](https://note.youdao.com/yws/api/personal/file/8DBF1C6C2FF845C283CD4C1F6BA65E24?method=download&shareKey=9d886e882867c8725df964446fc878f4)

**注意：secrets里面是加密的，挂载到pod中就是解密后的数据** 

#### 将 Secret 导出到环境变量中
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: secret-deployment
spec:
   replicas: 3
   template:
      metadata:
         labels:
            app: secret-deployment
      spec:
         containers:
         - image: mydemo:v1
           name: pod-1
           ports:
           - containerPort: 8080
           env:
           - name: TEST_USER
             valueFrom:
                secretKeyRef:
                   name: mysecret
                   key: username
           - name: TEST_PASSWOED
             valueFrom:
                secretKeyRef:
                   name: mysecret
                   key: password          
```

kubectl apply -f deployment-secret.yaml --namespace=my-namespace --record

kubectl get pod --namespace=my-namespace -o wide

![](https://note.youdao.com/yws/api/personal/file/245955D5A0BC43F58096A4611D751ABD?method=download&shareKey=bddde14acf7e3da054afeb0fa7133987)


##  kubernetes.io/dockerconfigjson

kubectl create secret docker-registry myregistrykey --docker-server=www.harbor.com  --docker-username=jenkins --docker-password=Jenkins123


```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: private-deployment
spec:
   replicas: 3
   template:
      metadata:
         labels:
            app: private-deployment
      spec:
         containers:
         - image: docker pull www.harbor.com/test/nginx:1.15.6-alpine
           name: private-dep-c
           ports:
           - containerPort: 8080
           env:
           - name: TEST_USER
             valueFrom:
                secretKeyRef:
                   name: mysecret
                   key: username
           - name: TEST_PASSWOED
             valueFrom:
                secretKeyRef:
                   name: mysecret
                   key: password 
         imagePullSecrets:
         - name: myregistrykey
```

## kubernetes.io/service-account-token

Service Account 用来访问 kubernetes API, 由 kubernetes 自动创建，并且会自动挂载到 Pod 的 
/run/secrets/kubernetes.io/serviceaccount/  目录中

![](https://note.youdao.com/yws/api/personal/file/A4A9355170DF4DE2804464E2469EB519?method=download&shareKey=8847f1185c3623e183e75b387249b092)



