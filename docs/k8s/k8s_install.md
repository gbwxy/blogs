# kubernetes 安装部署

### 环境ip和密码

vi /etc/sysconfig/network-scripts/ifcfg-ens33

```

TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=f983a292-3d93-4e25-bdee-14a51ee80f47
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.66.10
NETMASK=255.255.255.0
GATEWAY=192.168.66.1
DNS1=192.168.66.1
DNS2=114.114.114.114

```

192.168.66.10 k8s-master01   root/Test6530!
192.168.66.20 k8s-node01      root/Test6530!
192.168.66.21 k8s-node02      root/Test6530!

### 设置主机名
hostnamectl set-hostname k8s-master01
### host文件相互解析--大型环境这里用DNS解析
vi /etc/hosts

192.168.66.10 k8s-master01
192.168.66.20 k8s-node01
192.168.66.21 k8s-node02

 scp /etc/hosts root@k8s-node01:/etc/hosts
 scp /etc/hosts root@k8s-node02:/etc/hosts

### 修改 yum 源

cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak.20201215

curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all

yum makecache

### 安装 wget
yum -y install wget

### 安装依赖包

yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget vim net-tools git 

### 设置防火墙为iptables，并且设置规则为空

systemctl stop firewalld && systemctl disable firewalld

yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save



### 关闭 SELINUX
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

### 调整内核参数 - 对于k8s
```
cat > kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0 # 开启 OOM
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

cp kubernetes.conf /etc/sysctl.d/kubernetes.conf
sysctl -p /etc/sysctl.d/kubernetes.conf
```
###  调整系统时区
```
timedatectl set-timezone Asia/Shanghai
# 将当前的 UTC 时间写入硬件时钟
timedatectl set-local-rtc 0
# 重启依赖于系统时间的服务
systemctl restart rsyslog
systemctl restart crond
```

### 关闭系统不需要服务
systemctl stop postfix && systemctl disable postfix


### 设置 rsyslogd 和 systemd journald

```
mkdir /var/log/journal # 持久化保存日志的目录
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes

SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst= 1000

# 最大占用空间 10G
SystemMaxUse=10G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间 2 周
MaxRetentionSec=2week

# 不将日志转发到 syslog
ForwardToSyslog=no
EOF

systemctl restart systemd-journald

```

### 升级系统内核为 4.44

```
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

# 安装完成后检查 /boot/grub2/grub.cfg 中对应内核 menuentry 中是否包含 initrd16 配置，如果没有，再安装一次！  

yum --enablerepo=elrepo-kernel install -y kernel-lt

# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (4.4.248-1.el7.elrepo.x86_64) 7 (Core)'

```
uname  -r  #检测是否安装、启动成功


### kube-proxy开启ipvs的前置条件
```
modprobe br_netfilter

cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules  
bash /etc/sysconfig/modules/ipvs.modules 
lsmod | grep -e ip_vs -e nf_conntrack_ipv
```
### 安装 Docker 软件
```
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager \
--add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum update -y 
yum install -y docker-ce

#启动docker && 开机启动docker
systemctl start docker   && systemctl enable docker

## 创建 /etc/docker 目录
mkdir /etc/docker

# 配置 daemon.
cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
}
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

# 重启docker服务
systemctl daemon-reload 
systemctl restart docker
systemctl enable docker


```
安装完docker之后，内核版本又回去了
uname -r
这个时候，重新设置下默认内核版本，并重启
grub2-set-default 'CentOS Linux (4.4.248-1.el7.elrepo.x86_64) 7 (Core)' && reboot


### 安装 Kubeadm （主从配置）

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


yum -y install kubeadm-1.15.1  kubectl-1.15.1  kubelet-1.15.1 #安装最新版本的
systemctl enable kubelet && systemctl enable kubelet.service

```

将基础镜像包copy到虚机中 kubeadm-basic.images.tar.gz
解压
tar -zxvf kubeadm-basic.images.tar.gz 
加载
vim load-images.sh
```
#!/bin/bash
ls /root/kubeadm-basic.images > /tmp/images-list.txt
cd /root/kubeadm-basic.images

for i in $( cat /tmp/images-list.txt)
do
        docker load -i $i
done

rm -rf /tmp/images-list.txt

```
chmod a+x load-images.sh 
./load-images.sh 

拷贝到node01和node02，并执行
scp -r kubeadm-basic.images load-images.sh root@k8s-node01:/root
./load-images.sh 


#### 初始化主节点

kubeadm config print init-defaults  > kubeadm-config.yaml

```

apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.66.10
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: k8s-master01
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.15.1
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
  SupportIPVSProxyMode: true
mode: ipvs


```


```

kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs | tee kubeadm-init.log

```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#### 部署网络

mkdir install-k8s
mv kubeadm-basic.images kubeadm-config.yaml kubeadm-init.log install-k8s/
cd install-k8s/
mkdir core
mv * core/

mkdir plugin
cd plugin/
mkdir flannel
cd flannel


wget  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl apply -f  kube-flannel.yml

kubectl get pod -n kube-system

#### 加入主节点以及其余工作节点

kubeadm join 192.168.66.10:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:8069a43a8fdd7adb632a48bae4fae956566e0d549057274f8f0f629f54bbd0df


mv install-k8s/ /usr/local/



## Habor安装

habor 安装的前置条件是安装了docker  安装步骤如上

cd /etc/docker
vi daemon.json
```
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
   "max-size": "100m"
 },
 "insecure-registries":["https://hub.atguigu.com"]
}
```

scp daemon.json root@k8s-master01:/etc/docker
scp daemon.json root@k8s-node01:/etc/docker
scp daemon.json root@k8s-node02:/etc/docker


systemctl restart docker


把 docker-compare 拷贝到环境中
yum -y install lrzsz
mv docker-compose /usr/local/bin/
chmod a+x /usr/local/bin/docker-compose 

把  harbor-offline-installer-v1.2.0.tgz  拷贝到环境中
tar -zxvf harbor-offline-installer-v1.2.0.tgz 
mv harbor /usr/local/
vi /usr/local/harbor/harbor.cfg

```
hostname = hub.atguigu.com
ui_url_protocol = https


```
mkdir -p /data/cert
cd /data/cert

```
#生成公钥密码，密码：Test6530！
openssl genrsa -des3 -out server.key 2048
#生成公钥
openssl req -new -key  server.key  -out  server.csr
#备份
cp server.key server.key.org
#退密码
openssl rsa -in server.key.org -out server.key
#签名
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
#设置权限
chmod -R 777 /data/cert
```

cd /usr/local/harbor/
./install.sh 


访问测试：https://hub.atguigu.com
用户名/密码为admin /Harbor12345

在k8s-master node中测试
docker login https://hub.atguigu.com

配置镜像加速器
```
sudo mkdir -p /etc/docker
#更新文件
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://h8cpvf2f.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```


docker pull nginx:1.17.1
docker tag nginx:1.17.1  hub.atguigu.com/library/nginx:1.17.1
docker push hub.atguigu.com/library/nginx:1.17.1


docker rmi -f hub.atguigu.com/library/nginx:1.17.1
docker rmi -f nginx:1.17.1

kubectl run nginx-deployment --image=hub.atguigu.com/library/nginx:1.17.1 --port=80 --replicas=2

#master节点查看
kubectl get deployment --all-namespaces -o wide | grep nginx
kubectl get pod --all-namespaces -o wide | grep nginx

#查看是否执行 --node节点
docker ps -a | grep nginx


kubectl scale --replicas=3 deployment/nginx-deployment

kubectl expose deployment nginx-deployment --port=30000 --target-port=80

kubectl get svc
curl  10.100.78.142:30000

#查看负载均衡
ipvsadm -Ln 


















