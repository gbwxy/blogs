# Habor 安装与使用

## Habor 安装
参考
https://docs.docker.com/install/linux/docker-ce/centos/
https://docs.docker.com/compose/install/

### 修改 yum 源

cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak.20201215

curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all

yum makecache

### 安装前准备
**安装 wget**
yum -y install wget
**更新 yum**
yum update -y 

### 升级系统内核

```
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

# 安装完成后检查 /boot/grub2/grub.cfg 中对应内核 menuentry 中是否包含 initrd16 配置，如果没有，再安装一次！  

yum --enablerepo=elrepo-kernel install -y kernel-lt

# 设置开机从新内核启动
grub2-set-default 'CentOS Linux (5.4.94-1.el7.elrepo.x86_64) 7 (Core)'

```
uname  -r  #检测是否安装、启动成功


### 安装 docker && docker-compare

vim docker-ce-yum-install.sh
```
#!/bin/bash

# 卸载旧版本
yum remove docker \
           docker-client \
           docker-client-latest \
           docker-common \
           docker-latest \
           docker-latest-logrotate \
           docker-logrotate \
           docker-engine

# 安装所需软件包
yum install -y  yum-utils \
                device-mapper-persistent-data \
                lvm2

# 设置存储库
# 阿里云 http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装最新版的 docker-ce
yum -y install docker-ce docker-ce-cli containerd.io

# 配置阿里云 docker 镜像加速器
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "registry-mirrors": [
        "https://h8cpvf2f.mirror.aliyuncs.com"
    ]
}
EOF

# 重新加载配置、重启 docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# 安装 docker-compose
# 下载 docker-compose（由于下载速度过慢，提前已经下载完成）
wget https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Linux-x86_64
mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose

# 赋予可执行权限
chmod +x /usr/local/bin/docker-compose

echo "===================================================="
docker -v
docker-compose --version
echo "===================================================="
```

bash docker-ce-yum-install.sh

安装完docker之后，内核版本又回去了
uname -r
这个时候，重新设置下默认内核版本，并重启
grub2-set-default 'CentOS Linux (5.4.94-1.el7.elrepo.x86_64) 7 (Core)' && reboot

### 安装Harbor










## Harbor 使用














