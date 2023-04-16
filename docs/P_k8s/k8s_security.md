# kubernetes 安全



### kube config

kubeconfig 文件包含集群参数（CA证书、API Server地址），客户端参数（上面生成的证书和秘钥），集群context信息（集群名称、用户名）。kubenetes 组件通过启动时指定不同的 kubeconfig 文件可以切换到不同的集群

cd /root/.kube/
cat config
![](https://note.youdao.com/yws/api/personal/file/4685BD455AA64AEA9A2C2FE6836B1DCE?method=download&shareKey=244ea64d64a2e0665b7eba7e1afa8895)



kubectl get secrets --all-namespaces
![](https://note.youdao.com/yws/api/personal/file/4F2283D15CD942968B8D3ACCFE5DF302?method=download&shareKey=7968dfb63458152c346695bdc2e05f6a)

kubectl describe secrets --namespace=my-namespace default-token-8r2dm







## 实践

```
{
  "CN":"devuser",
  "hosts":[],
  "key"{
    "algo":"rsa",
    "size":2048
  },
  "names":[
    {
     "C":"CN",
     "ST":"BeiJing",
     "L":"BeiJing",
     "O":"k8s",
     "OU":"System"
    }
  ]
}

```
```
##下载包：
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 


cfssl gencert -ca=ca.crt -ca-key=ca.key -profile=kubernetes /root/devuser-csr.json | cfssljson -bare devuser



```














