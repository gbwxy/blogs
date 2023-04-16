# Q_springcloud Gateway

## 参考
[官网](https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.2.2.RELEASE/reference/html/)

## Gateway 简介
- Q_springcloud Gateway 是 Spring cloud 的一个全新的项目，基于 Spring 5.0 + Spring boot 2.0 和 Project Reactor 等技术开发的网关，它旨在为微服务架构提供一种简单有效的统一 API 路由管理方式。
- Q_springcloud Gateway 作为 Spring cloud 生态系统中的网关，目标是替代 Zuul，在 Spring Cloud 2.0 以上版本中，没有对新版本的 Zuul 2.0 以上最新高性能版本进行集成，仍然还使用 Zuul 1.x 非 Reactor 模式的老版本。而为了提升网关的性能，Spring Cloud Getaway 是基于 WebFlux 框架实现的，而 WebFlux 框架底层则使用了高性能的 Reactor 模式通信框架 Netty
- Spring Cloud Getaway 的目标提供统一的路由方式且基于 Filter 链的方式提供了网关基本的功能，例如：安全、监控/指标、限流
- **Q_springcloud Gateway 使用的 Webflux 中的 reactor-netty 响应式编程组件，底层使用了 Netty 通讯框架（高并发、非阻塞通讯）。**

![](https://note.youdao.com/yws/api/personal/file/4A3A38A5C9724329891CC26854E2353B?method=download&shareKey=56d5fb587bbefddadf5e3c617b1f272c)

![](https://note.youdao.com/yws/api/personal/file/1B3F11FF516B427F8FBC15B009370447?method=download&shareKey=59b973a3e1d5d561fc875eb6592ac793)

### Gateway 能干什么
- 代理
- 鉴权
- 流量控制
- 熔断
- 日志监控
### 为什么选择 Gateway
- Zuul 1.x 已经进入维护阶段，Zuul 2.x 虽已经发布，但是与 Spring Cloud 还没有整合计划；
- Gateway 基于**异步非阻塞模型**上进行开发的，性能方面不需要担心。

### Gateway 特点
- 基于 Spring Framework 5，Project Reactor 和 Spring Boot 2.0 进行构建
- 动态路由：能够匹配任何请求属性
- 可以对路由指定 Predicate （断言）和 Filter（过滤器）
- 集成 Hystrix 的断路器功能
- 集成 Spring Cloud 的服务发现功能
- 易于编写 Predicate （断言）和 Filter（过滤器）
- 请求限流功能
- 支持路径重写

### Gateway 与 Zuul 的区别
- Zuul 1.x 基于阻塞 I/O，基于 Servlet 2.x，使用的是阻塞架构，不支持任何长连接；
- Zuul 1.x 的设计和 Nginx 较像，每次 I/O 操作都是从工作线程中选择一个执行，请求线程被阻塞到工作线程完成，但差不是 Nginx 使用的 C++，Zuul 用的 Java，而 JVM 本身会有第一次加载较慢的情况，使得 Zuul 的性能相对较差
- Zuul 2.x 基于 Netty 非阻塞和支持长连接，但是还没有和 Spring Cloud 进行整合。
- Spring Cloud Gateway 基于 Spring Framework 5，Project Reactor 和 Spring Boot 2.0 进行构建，使用的非阻塞 API
- Spring Cloud Gateway 支持 WebSocket

### 三大核心概念
1. Route（路由）
网关的基本构建块。它由ID，目标URI，谓词集合和过滤器集合定义。如果断言为true，则匹配路由。
2. Predicate（断言）
这是Java 8 Function谓词。输入类型是Spring FrameworkServerWebExchange。这使您可以匹配HTTP请求中的所有内容，例如标头或参数。
3. Filter（过滤器）
这些是使用特定工厂构造的Spring Framework Gateway Filter实例。在这里，您可以在发送下游请求之前或之后修改请求和响应。

### 工作流程
![](https://note.youdao.com/yws/api/personal/file/CE27AB84B542482CBFE2CECEF17C6E2F?method=download&shareKey=4f7ab172a459db31b78885370b186b5b)
客户端向Spring Cloud Gateway发出请求。如果网关处理程序映射确定请求与路由匹配，则将其发送到网关Web处理程序。该处理程序通过特定于请求的过滤器链来运行请求。筛选器由虚线分隔的原因是，筛选器可以在发送代理请求之前和之后运行逻辑。所有“前置”过滤器逻辑均被执行。然后发出代理请求。发出代理请求后，将运行“后”过滤器逻辑。

## 实践
### 建模块:cloud-gateway-gateway9527
1. pom
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
<!-- 注意不要添加 web的依赖，与gateway里的web flux冲突 -->
```
2. yml
```yml
server:
  port: 9527
spring:
  application:
    name: cloud-gateway
eureka:
  instance:
    hostname: cloud-gateway-service
  client:
    service-url:
       register-with-eureka:  true
       fetch-registry:  true
       defaultZone: http://eureka7001.com:7001/eureka
```
3. 启动类
```java
@SpringBootApplication
@EnableEurekaClient
@EnableDiscoveryClient
```
### 测试
1. 9527中配置路由
```yml
spring:
  application:
    name: cloud-gateway
  cloud:
    gateway:
      routes: # 可以配置多个路由
        - id: payment_routh # 路由id，没有固定规则但要求唯一
          uri:  http://localhost:8001 # 匹配后提供服务的路由地址
          predicates:
            - Path=/payment/get/** # 路径相匹配的进行路由

        - id: payment_routh2 # 路由id，没有
          uri:  http://localhost:8001 # 匹配后提供服务的路由地址
          predicates:
            - Path=/payment/payment # 路径相匹配的进行路由
```
2. 配置后可以通过以下路径访问8001中的信息
http://localhost:9527/payment/get/31
不再暴露8001的端口
3. 配置路由的另一种方法，9527注入 RouteLocator的Bean
```java
@Configuration
public class GateWayConfig {
    @Bean
    public RouteLocator routeLocator(RouteLocatorBuilder routeLocatorBuilder){
        RouteLocatorBuilder.Builder  routes = routeLocatorBuilder.routes();

        /*
        * 代表访问http://localhost:9527/guonei
        * 跳转到http://news.baidu.com/guonei
        * */
        routes.route("route1",
                r->r.path("/guonei")
                .uri("http://news.baidu.com/guonei")).build();
        return routes.build();
    }
}
```

## 动态路由
1. 9527yml
```yml
server:
  port: 9527
spring:
  application:
    name: cloud-gateway
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true # 1.开启从服务在注册中心动态创建路由的功能
      routes:
        - id: payment_routh
#          uri:  http://localhost:8001 # 匹配后提供服务的路由地址
          uri:  lb://cloud-payment-service # 2.输入服务名，lb代表负载均衡
          predicates:
            - Path=/payment/get/** 

        - id: payment_routh2 
#          uri:  http://localhost:8001 # 匹配后提供服务的路由地址
          uri:  lb://cloud-payment-service # 2.输入服务名，lb代表负载均衡
          predicates:
            - Path=/payment/create 
```

## 自定义 Routes

GateWayConfig.java
```java
@Configuration
public class GateWayConfig
{
    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder routeLocatorBuilder)
    {
        RouteLocatorBuilder.Builder routes = routeLocatorBuilder.routes();

        routes.route("path_route_atguigu",
                r -> r.path("/guonei")
                        .uri("http://news.baidu.com/guonei")).build();

        return routes.build();
    }
}
```
## 断言 Predicate 
[Predicate的默认类型-官网](https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.2.2.RELEASE/reference/html/#gateway-request-predicates-factories)
[断言工厂](https://blog.csdn.net/chengyuqiang/article/details/93097892)
![](https://note.youdao.com/yws/api/personal/file/6BE64A5504EC4D48BF4FE1D581A0A480?method=download&shareKey=38eaed9aefb9f95931aefd5543ccd7db)

## 过滤器 Filter
### 过滤器作用
Spring Cloud Gateway同zuul类似，有“pre”和“post”两种方式的filter。客户端的请求先经过“pre”类型的filter，然后将请求转发到具体的业务服务，比如上图中的user-service，收到业务服务的响应之后，再经过“post”类型的filter处理，最后返回响应到客户端。
![](https://note.youdao.com/yws/api/personal/file/76C11D0B424142D78902653FC1F67A67?method=download&shareKey=65383a818e42b84d886612a2abdf4aa2)

由filter工作流程点，可以知道filter有着非常重要的作用，在“pre”类型的过滤器可以做参数校验、权限校验、流量监控、日志输出、协议转换等，在“post”类型的过滤器中可以做响应内容、响应头的修改，日志的输出，流量监控等。
![](https://note.youdao.com/yws/api/personal/file/9DF30B6B375045DF91ECF2644013CF6E?method=download&shareKey=4c6bc039c0cda66001e96a50dfd2a682)

### 单个过滤器和全局过滤器
[GatewayFilter Factories](https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.2.2.RELEASE/reference/html/#gatewayfilter-factories)
[Spring Cloud Gateway-过滤器工厂详解（GatewayFilter Factories）](https://www.imooc.com/article/290816)
[Global Filters](https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.2.2.RELEASE/reference/html/#global-filters)
![](https://note.youdao.com/yws/api/personal/file/0D47B2D605584C08902827C5E9E82043?method=download&shareKey=cb8d1467db7159fe9cf020bf81d583b4)

### 自定义全局过滤器
1. 实现接口 GlobalFilter , Ordered
2. 能干嘛
    1. 全局日志记录
    2. 统一网关鉴权
3. 案例
```java
@Component
@Slf4j
public class MyLogFilter implements GlobalFilter, Ordered {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 判断有没有 uname 这个参数
        log.info("自定义全局日志过滤器");
        String uname = exchange.getRequest().getQueryParams().getFirst("uname");
        if (uname==null){
            log.info("用户名非法");
            exchange.getResponse().setStatusCode(HttpStatus.NOT_ACCEPTABLE);
            return exchange.getResponse().setComplete();
        }
        return chain.filter(exchange);
    }
    /*
    *     int HIGHEST_PRECEDENCE = -2147483648;
            int LOWEST_PRECEDENCE = 2147483647;
            * 加载过滤器顺序
            * 数字越小优先级越高
    * */
    @Override
    public int getOrder() {
        return 0;
    }
}
```

