# kubernetes 资源清单

**获取 apiversion 版本信息**
kubectl api-versions

**查看资源清单常用字段的解释**
kubectl explain +资源清单类型
例如 ：
kubectl explain pod
kubectl explain pod.spec 

其中 标记  -required- 的是必填项

**查看资源详情**
kubectl  describe pod +pod名字
kubectl  describe svc +svc名字

**查看pod日志**
- kubectl logs -f --tail=500  pod名字
- kubectl   log   pod名字  -c  container名字
 其中 -c  指定pod里面的哪个 container 的名字

**创建**
 kubectl apply -f *.yaml
 kubectl create -f  *.yaml

**将资源配置以yaml或json格式输出**
 kubectl get pod   xx.xx.xx   -o yaml
 kubectl get pod   xx.xx.xx   -o json

 

 

 

 

 

 

 

 