# Spring Cloud - Consul
## Consul 简介
### Consul 是什么？
https://www.consul.io/intro
- **Consul 是一套开源的分布式服务发现和配置管理系统，提供了微服务系统中的服务治理、配置中心、控制总线等功能。**
- Consul是一种服务网格解决方案，提供具有服务发现，配置和分段功能的全功能控制平面。这些功能中的**每一个都可以根据需要单独使用，也可以一起使用以构建完整的服务网格**。
- Consul需要一个数据平面，并支持代理和本机集成模型。Consul附带了一个简单的内置代理，因此一切都可以直接使用，还支持Envoy等第三方代理集成。
- 优点：**基于 Raft 协议，比较简洁；支持健康检查；同时支持 HTTP 和 DNS 协议，支持跨数据中心的 WAN 集群；提供图形界面；跨平台支持，支持 Linux、Mac、WIndows。**

### Consul  能做什么？
* 服务注册与发现：Consul 的客户端可以注册服务，例如 api或mysql，其他客户端可以使用Consul 来发现服务的提供者。使用 DNS 或 HTTP 协议，应用程序可以轻松找到它们依赖的服务。
* 健康检查：Consul Client 可以提供任何数量的健康检查，这些检查可以针对指定的服务（例如， Web服务器返回是否是 200 OK），也可以是 Node（例如，内存利用率是否低于90％）等。这些信息来可以用来监视群集的运行状况，Consul 可以根据这些信息将流量路由到运行状况良好的主机上。
* KV 存储： Consul 的 Key/Value 有多种用途，包括动态配置，功能标记，协调，领导者选举等。Consul 提供了简单的 HTTP API ，使其使用很方便。
* 安全的服务通信：Consul 可以为服务生成并分发TLS证书，以建立相互TLS连接，以指定允许哪些服务进行通信。该功能可以轻松的实现服务分段的实时更改和管理，而不必使用复杂的网络拓扑和静态防火墙规则。
* 多数据中心：Consul 天生的支持多个数据中心。这意味着 Consul 的用户不必担心在有其他不必要的封装。
### 参考
- 官网地址：https://www.consul.io
- 官网地址：https://www.consul.io/downloads
- 英文说明文档：https://learn.hashicorp.com/consul
- 中文使用手册：http://www.liangxiansen.cn/2017/04/06/consul/
- 安装使用说明：https://www.Q_springcloud.cc/spring-cloud-consul.html
## 安装启动
集群安装：https://blog.csdn.net/junaozun/article/details/90699384
- Consul 下载 wget https://releases.hashicorp.com/consul/1.5.1/consul_1.5.1_linux_amd64.zip 或者 https://www.consul.io/downloads.html
- 下载完后，解压，得到一个可执行文件 consul
- 将这个文件移动到全局变量环境中   $ sudo mv consul /usr/local/bin/
- 验证是否安装成功  $ consul --version
- 启动consul server和client
	1.node1:运行cosnul agent以server模式：consul agent -server -ui -bootstrap-expect=2 -data-dir=/tmp/consul -node=n1 -config-dir /etc/consul.d -advertise=106.14.125.167 -bind=0.0.0.0 -client=0.0.0.0
	2.node2:运行cosnul agent以server模式：consul agent -server -ui -bootstrap-expect=2 -data-dir=/tmp/consul -node=n2 -advertise=129.28.80.79 -bind=0.0.0.0 -client=0.0.0.0 -join 106.14.125.167
	3.node3:运行cosnul agent以client模式：consul agent -data-dir=/tmp/consul -node=n3 -advertise=106.12.77.99 -bind=0.0.0.0 -client=0.0.0.0 -join 106.14.125.167
- 在终端中查看集群成员：新开一个终端窗口运行consul members, 你可以看到Consul集群的成员
![](https://note.youdao.com/yws/api/personal/file/249EB238B584418D9D079C5765268215?method=download&shareKey=ea1c4ec13e838ba6386626fb657d7073)
- 停止Agent：$ consul leave 或者直接 使用 Ctrl-C 结束 Agent

## 服务提供者
1. 改pom
```xml
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-consul-discovery</artifactId>
    </dependency>
```
2. 建yml
```yml
server:
  port: 8006
spring:
  application:
    name: cloud-provider-payment
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        service-name: ${spring.application.name}
```
3. 建启动类
4. 建controller类
5. 测试
http://localhost:8006/payment/consul
http://localhost:8500/ui/dc1/services
## 服务消费者
1. 改pom
```xml
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-consul-discovery</artifactId>
    </dependency>
```
2. 建yml
```yml
server:
  port: 80
spring:
  application:
    name: cloud-consumer-order
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        service-name: ${spring.application.name}
```
3. 建启动类
4. 建controller
5. 测试
http://localhost/consumer/payment/cs
http://localhost:8006/payment/consul
## 三个注册中心 eureka zookeeper consul的异同点
![](https://note.youdao.com/yws/api/personal/file/5B686A8C06964FADBB4C76F19FFF0ECB?method=download&shareKey=f52ee16089a92439b4a4926f20bb422c)

### CAP
CAP 理论关注粒度是数据，而不是整体系统设计的策略。
另，可参考  [ZooKeeper-是什么](./docs/zookeeper/01_zookeeper_what.md)
C:Cosistency（强一致性）
A:Availability（可用性）
P:Partition tolerance（分区容错性）
![](https://note.youdao.com/yws/api/personal/file/5D92C2A55533405E97CA9AF714A8674D?method=download&shareKey=4279cd6073ae9d465d7b4776ee5bae62)
CAP 理论的核心是：**一个分布式系统不可能同时满足一致性、可用性、分区容错性，这三个特性。**因此，根据 CAP 原理将 NoSQL 数据库分成了满足 CA 原则、满足 CP 原则、满足AP原则三大类：
- CA ：单点集群，满足一致性、可用性的系统，通常在可扩展性上不太强大
- CP ：满足一致性、分区容错性的系统，通常性能不是特别高 **zookeeper、consul**
当网络分区出现后，为了保证一致性，就必须拒绝请求。
![](https://note.youdao.com/yws/api/personal/file/7E8B44722CD74D84921918F02E141D67?method=download&shareKey=c9b69936d7b6d9e0031275db88468442)
- AP ：满足可用项、分区容错性的系统，通常可能对一致性要求低一些 **Eureka**
当网络分区出现后，为了保证可用性，系统B可以返回旧值。
![](https://note.youdao.com/yws/api/personal/file/C367F3D7E063458A822BA050BC14E1EF?method=download&shareKey=732c449ec7eff752afcc239af987618f)