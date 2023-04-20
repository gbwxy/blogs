#  Kubernetes Prometheus

### 下载源码
git clone https://github.com/coreos/kube-prometheus.git


### 更改为 NodePort
修改 manifests/grafana-service.yaml

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 7.3.5
  name: grafana
  namespace: monitoring
spec:
  ports:
  - name: http
    port: 3000
    targetPort: http
    nodePort: 30100   # 注意这里可能要修改
  selector:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
  type: NodePort  # 注意这里可能要修改
```

修改 manifests/prometheus-service.yaml
```
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: prometheus
    app.kubernetes.io/name: prometheus
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 2.24.0
    prometheus: k8s
  name: prometheus-k8s
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
    port: 9090
    targetPort: web
    nodePort: 30200
  selector:
    app: prometheus
    app.kubernetes.io/component: prometheus
    app.kubernetes.io/name: prometheus
    app.kubernetes.io/part-of: kube-prometheus
    prometheus: k8s
  sessionAffinity: ClientIP

```

修改  manifests/alertmanager-service.yaml 

```
apiVersion: v1
kind: Service
metadata:
  labels:
    alertmanager: main
    app.kubernetes.io/component: alert-router
    app.kubernetes.io/name: alertmanager
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 0.21.0
  name: alertmanager-main
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
    port: 9093
    targetPort: web
    nodePort: 30300
  selector:
    alertmanager: main
    app: alertmanager
    app.kubernetes.io/component: alert-router
    app.kubernetes.io/name: alertmanager
    app.kubernetes.io/part-of: kube-prometheus
  sessionAffinity: ClientIP

```

kubectl create -f manifests

kubectl get pod -n monitoring -o wide
![](https://note.youdao.com/yws/api/personal/file/9B55C8D616A04C4FB510C66796C1E620?method=download&shareKey=6b069e302857116801719c1bd3af25eb)

kubectl get svc -n monitoring -o wide
![](https://note.youdao.com/yws/api/personal/file/66A74A737699464D8D017F5A49DA6307?method=download&shareKey=c7979ea29d1de52d79e154a93cf3b431)

















