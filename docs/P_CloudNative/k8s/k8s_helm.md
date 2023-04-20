# kubernetes-helm

[helm 中文文档](https://whmzsu.github.io/helm-doc-zh-cn/)

## helm 部署

[helm 官方部署文档](https://helm.sh/zh/docs/intro/install/)


### 在 worker 节点配置好 kubectl

在 woker 节点上创建文件夹
mkdir -p $HOME/.kube

把 matser 中的 admin.conf 复制到 node 中的conf
scp /etc/kubernetes/admin.conf root@192.168.66.20:/$HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config

### 分配权限
[helm-RBAC](https://whmzsu.github.io/helm-doc-zh-cn/quickstart/rbac-zh_cn.html)

因为 kubernetes APIServer 开启了 RBAC 访问控制，所以需要创建 tiller 使用的 service account:tiller 并分配合适的角色给它。
这里直接分配 cluster-admin 这个集群内置的 ClusterRole 给它。
创建 rbac-config.yaml 文件

```
apiVersion: v1
kind: ServiceAccount
metadata:
   name: tiller
   namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
   name: tiller
roleRef:
   apiGroup: rbac.authorization.k8s.io
   kind: ClusterRole
   name: cluster-admin
subjects:
   - kind: ServiceAccount
     name: tiller
     namespace: kube-system

```
创建 ServiceAccount 和 ClusterRoleBinding
kubectl create -f rbac-config.yaml
初始化 helm
helm init --service-account tiller --skip-refresh

### 查看是否安装成功
helm version 
![](https://note.youdao.com/yws/api/personal/file/F4F9291CE7A3426998B0B90E19E5786D?method=download&shareKey=a125d12c76f470e5341be3703602e408)


## helm 使用
[helm仓库](https://artifacthub.io/)

./templates/deployment.yaml
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: mychart_demo
spec:
   replicas: 3
   template:
      metadata:
         labels:
            app: mychart_demo
      spec:
         containers:
            - name: mychart_demo
              image: mydemo:v1
              ports:
                - containerPort: 80
                  protocol: TCP
```
./templates/service.yaml
```
apiVersion: v1
kind: Service
metadata:
   name: mychart_demo
spec:
   type: NodePort
   ports:
   - port: 80
     targetPort: 80
     protocol: TCP
   selector:
      app: mychart_demo   
```
**使用命令  helm install RELATIVE_PATH_TO_CHART 创建一次 Release **
helm install ./

values.yaml
```
image:
   repository: mydemo:v1
   tag: '1.0'
```
deployment.yaml
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: mychart_demo
spec:
   replicas: 3
   template:
      metadata:
         labels:
            app: mychart_demo
      spec:
         containers:
            - name: mychart_demo
              image: {{.Values.image.repository}}:{{.Values.image.tag}}
              ports:
                - containerPort: 80
                  protocol: TCP
```

### helm 删除 
helm  delete --purge  release-name


## helm 安装 dashboard

升级helm
helm repo update

下载 dashboard 模板
helm fetch stable/kubernetes-dashboard 

tar -zxvf kubernetes-dashboard-1.11.1.tgz


编辑  kubernetets-dashboard.yaml
```
image:
   repository: k8s.gcr.io/kubernetes-dashboard-amd64
   tag: v1.10.1
ingress:
   enabled: true
   hosts:
      - k8s.frognew.com
   annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
   tls:
     - secretName: frognew-com-tls-secret
       hosts:
       - k8s.frognew.com
rbac:
   clusterAdminRole: true
```
helm install . -n kuberbetes-dashboard --namespace kube-system -f kubernetets-dashboard.yaml

kubectl -n kube-system get secret | grep kubernetes-d
kubectl describe -n kube-system secret kuberbetes-dashboard-kubernetes-dashboard-token-676bv

![](https://note.youdao.com/yws/api/personal/file/3FE5FDD91F204F67BF48E74FF3CD4844?method=download&shareKey=f6c2cc58dc3009b1042774762f78898d)

kubectl edit svc kubernetes-dashboard -n kube-system 

























