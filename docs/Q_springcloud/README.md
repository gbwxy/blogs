# 微服务 & Spring Cloud 

## 微服务架构体系
微服务必备组件
![](https://note.youdao.com/yws/api/personal/file/C4CA6546784F4C52B63835C9C2F1F026?method=download&shareKey=7d32c4dffa55ed2c6e3e4dc4f9ce2db8)

某商场微服务架构
![](https://note.youdao.com/yws/api/personal/file/031AFEC7A34D44B4A691434181A9C9F5?method=download&shareKey=de7c1de5355c1b70c9e4811eb4c1350d)

![](https://note.youdao.com/yws/api/personal/file/8322CC2938664F5E9B1BEB8DE4D93A5E?method=download&shareKey=ba85b96ec479648638d4a98491d71621)

![](https://note.youdao.com/yws/api/personal/file/4D5B12903EC34F8AB313D74B630B77AE?method=download&shareKey=3233f1fa07d8c124ef8d6e9df4f34189)

## Spring Cloud 框架
Q_springcloud，分布式微服务架构的一站式解决方案，是多种微服务架构落地技术的集合体，俗称微服务全家桶。

![](https://note.youdao.com/yws/api/personal/file/5DCC3FDE76A34A2198B6A5BA46B75816?method=download&shareKey=f6b5452fc6cdf7a99b217a6807c6ef11)

微服务架构的 Q_springcloud 实现
![](https://note.youdao.com/yws/api/personal/file/97298EE01A3A41C7B63761DF773CDE31?method=download&shareKey=5102122ac7075969ca37bc66a6de9101)

主要项目
Spring Cloud的子项目，大致可分成两类，一类是对现有成熟框架"Spring Boot化"的封装和抽象，也是数量最多的项目；第二类是开发了一部分分布式系统的基础设施的实现，如Spring Cloud Stream扮演的就是kafka, ActiveMQ这样的角色。

#### Spring Cloud Config
集中配置管理工具，分布式系统中统一的外部配置管理，默认使用Git来存储配置，可以支持客户端配置的刷新及加密、解密操作。

#### Spring Cloud Netflix
Netflix OSS 开源组件集成，包括Eureka、Hystrix、Ribbon、Feign、Zuul等核心组件。

Eureka：服务治理组件，包括服务端的注册中心和客户端的服务发现机制；
Ribbon：负载均衡的服务调用组件，具有多种负载均衡调用策略；
Hystrix：服务容错组件，实现了断路器模式，为依赖服务的出错和延迟提供了容错能力；
Feign：基于Ribbon和Hystrix的声明式服务调用组件；
Zuul：API网关组件，对请求提供路由及过滤功能。
#### Spring Cloud Bus
用于传播集群状态变化的消息总线，使用轻量级消息代理链接分布式系统中的节点，可以用来动态刷新集群中的服务配置。

#### Spring Cloud Consul
基于Hashicorp Consul的服务治理组件。

#### Spring Cloud Security
安全工具包，对Zuul代理中的负载均衡OAuth2客户端及登录认证进行支持。

#### Spring Cloud Sleuth
Spring Cloud应用程序的分布式请求链路跟踪，支持使用Zipkin、HTrace和基于日志（例如ELK）的跟踪。

#### Spring Cloud Stream
轻量级事件驱动微服务框架，可以使用简单的声明式模型来发送及接收消息，主要实现为Apache Kafka及RabbitMQ。

#### Spring Cloud Task
用于快速构建短暂、有限数据处理任务的微服务框架，用于向应用中添加功能性和非功能性的特性。

#### Spring Cloud Zookeeper
基于Apache Zookeeper的服务治理组件。

#### Spring Cloud Gateway
API网关组件，对请求提供路由及过滤功能。

#### Spring Cloud OpenFeign
基于Ribbon和Hystrix的声明式服务调用组件，可以动态创建基于Spring MVC注解的接口实现用于服务调用，在Spring Cloud 2.0中已经取代Feign成为了一等公民。

#### Spring Cloud 与 Spring Boot

Spring Cloud 与 Spring Boot 的版本关系
![](https://note.youdao.com/yws/api/personal/file/62E500A3AFCF490F8DFA4A9169EE239A?method=download&shareKey=fde27104a431ad072c40912de151a7bb)

- Spring Boot 是 Spring 的一套快速配置脚手架，可以基于Spring Boot 快速开发单个微服务，Spring Cloud是一个基于Spring Boot实现的云应用开发工具。Spring -> Spring Boot > Spring Cloud 这样的关系。
- Spring Boot可以离开Spring Cloud独立使用开发项目，但是Spring Cloud离不开Spring Boot，属于依赖的关系
- Spring Boot专注于快速、方便集成的单个个体微服务，Spring Cloud是关注全局的服务治理框架
- Spring Boot使用了默认大于配置的理念，很多集成方案已经帮你选择好了，能不配置就不配置，Spring Cloud很大的一部分是基于Spring Boot来实现，可以不基于Spring Boot吗？不可以

