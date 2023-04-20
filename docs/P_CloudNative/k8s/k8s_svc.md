# kubernetes 服务





ipvsadm -Ln 


svc_deployment.yaml
```
apiVersion: app/v1
kind: Deployment
metadata:
	name: myapp-deplpyment
spec:
	replicas: 3
	selector:
		matchLabels:
			app: myapp
			release: stabel
	template:
		metadata:
			labels:
				app: myapp
				release: stabel
				env: test
		spec:
			containers:
			- name: myapp
			  image: mydemo:v1
			  imagePullPolicy: IfNotPresent
			  ports:
			  - name: http
			    containerPort: 80

```

svc.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp
    release: stabel
  ports:
  - name: http
    port: 30080        # 对外提供的接口
    targetPort: 80     # 后端服务的接口-container提供出的接口
```


查看 namespace = kube-system 中的 pod
kubectl get pod --namespace=kube-system -o wide
 
![](https://note.youdao.com/yws/api/personal/file/C57CE008227B4FAE9E0536F4BC38A0C6?method=download&shareKey=b0ba203030c865ff1b9b08bb5cc2f7ea)

**在集群中定义的每个 Service（包括 DNS 服务器自身）都会被指派一个 DNS 名称。默认，一个客户端 Pod 的 DNS 搜索列表将包含该 Pod 自己的名字空间和集群默认域。** 

“普通” 服务（除了无头服务）会以 **my-svc.my-namespace.svc.cluster-domain.example** 这种名字的形式被分配一个 DNS A 或 AAAA 记录，取决于服务的 IP 协议族。 该名称会解析成对应服务的集群 IP。

“无头（Headless）” 服务（没有集群 IP）也会以 my-svc.my-namespace.svc.cluster-domain.example 这种名字的形式被指派一个 DNS A 或 AAAA 记录， 具体取决于服务的 IP 协议族。 与普通服务不同，这一记录会被解析成对应服务所选择的 Pod 集合的 IP。 客户端要能够使用这组 IP，或者使用标准的轮转策略从这组 IP 中进行选择。

