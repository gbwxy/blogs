# Q_springcloud OpenFeign
## 参考
官网：https://cloud.spring.io/spring-cloud-openfeign/2.2.x/reference/html/
## OpenFeign 是什么
* Feign 是声明性 Web 服务客户端，它使编写 Web 服务客户端更加容易。
* Feign 的使用方法，定义一个服务接口然后在上面添加注解。
* Feign支持可插拔编码器和解码器。
* Spring Cloud 对 Feign 添加了对 Spring MVC 注释的支持，并支持使用HttpMessageConverters
* Spring Cloud 集成了 Ribbon 和 Eureka 以及 Spring Cloud LoadBalancer，以在使用 Feign 时提供负载平衡的 http 客户端。
## OpenFeign 能干什么
* 使编写 Java Http 客户端更加容易
	- 使用 RestTemplate+Ribbon 时，利用 RestTemplate 对http 请求的封装处理，形成一套模板化的调用方法，但是在实际中，由于对服务的调用可能不止一处，往往一个接口会被多处调用，所以通常都会针对每个微服务自行封装一些客户端类来包装这些依赖服务的调用。所以Feign在此基础上做了进一步封装，由他来帮助我们定义和实现服务接口的定义。
	- **在Feign的实现下我们只需要创建一个接口并使用注解来配置它(以前是Dao接口上标注Mapper注解，现在是一个微服务接口上面标注一个Feign注解即可)。**自动封装服务调用客户端的开发量。
* Feign集成了Ribbon
	- 利用 Ribbon 维护了 Payment 的服务列表信息，并且实现了轮询实现客户端的负载均衡。而与 Ribbon 不同的是，**feign 只需要定义服务绑定接口且以声明式的方法**，优雅而简单的实现服务调用。
* Feign与OpenFeign区别
![](https://note.youdao.com/yws/api/personal/file/C90EA6777F6C48149696DDD99334264F?method=download&shareKey=18bb9fa553b02c0cf0f4be76ebf747bb)

## OpenFeign 怎么用
![](https://note.youdao.com/yws/api/personal/file/9EB1FBC54DB64411AEC5EB7BF803DCA1?method=download&shareKey=5b16af6ee605abf92a43014ef6b41f5e)
### 建项目：cloud-consumer-frign-order80
1. 改pom
```xml
        <!--openfeign-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```
2. 建yml
```yml
server:
  port: 80
eureka:
  client:
    register-with-eureka: false
    service-url:
      defaultZone: http://eureka7001.com:7001/eureka/,http://eureka7002.com:7002/eureka/
```
3. 写启动类
```java
@SpringBootApplication
@EnableFeignClients
public class OrderFeignMain80 {
    public static void main(String[] args) {
        SpringApplication.run(OrderFeignMain80.class,args);
    }
}
```
4. 写业务类
```java
@Component
// 将业务提供者的名写进去
@FeignClient(value = "CLOUD-PAYMENT-SERVICE")
public interface PaymentFeignService {

// 将业务提供者的controller路径和方法复制粘贴进来
    @GetMapping("/payment/get/{id}")
    public CommonResult getPaymentById(@PathVariable("id")Long id);
}
```
5. controller
```java
    @GetMapping("/consumer/payment/get/{id}")
    public CommonResult<Payment> getPaymentById(@PathVariable Long id){
        return paymentFeignService.getPaymentById(id);
    }
```
### 超时控制
- OpenFeign 默认等待时间 1s
- 设置超时时间
```yml
#设置feign客户端超时时间(OpenFeign默认支持ribbon)
ribbon:
#指的是建立连接所用的时间，适用于网络状况正常的情况下,两端连接所用的时间
  ReadTimeout: 5000
#指的是建立连接后从服务器读取到可用资源所用的时间
  ConnectTimeout: 5000
```
### 日志增强
#### 日志级别
1. NONE：默认不显示日志
2. BASIC：仅记录请求方法，URL，响应状态及执行时间
3. HEADERS：除了BASIC中定义的信息之外，还有请求和响应的头信息
4. FULL：除了HEADERS中定义的信息外，还有请求和响应的正文及元数据
#### 配置类
```java
import feign.Logger;
@Configuration
public class FeignConfig {
    @Bean
    Logger.Level feignLoggerLevel(){
        return Logger.Level.FULL;
    }
}
```
#### 选择日志监听接口
```yml
logging:
  level:
    # feign日志以什么级别监控哪个接口
    com.atguigu.Q_springcloud.service.PaymentFeignService: debug
```

## Zookeeper & OpenFegin
这里注意，**@FeignClient(value = "cloud-provider-payment")，Eureka 中服务名默认是大写的，Zookeeper 中默认是小写的。**

1.pom.xml
```xml
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <!-- SpringBoot整合zookeeper客户端 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
            <!--先排除自带的zookeeper-->
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <!--添加zookeeper3.4.9版本-->
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.10</version>
        </dependency>
```
2.application.yml
```yml
server:
  port: 80
spring:
  application:
    name: cloud-consumer-order
  cloud:
  #注册到zookeeper地址
    zookeeper:
      connect-string: 10.0.45.193:2181
  logging:
    level:
      # feign日志以什么级别监控哪个接口
      com.atguigu.Q_springcloud.service.PaymentFeignService: debug
```
3.主启动类
```java
@SpringBootApplication
@EnableFeignClients
public class OrderMainFeignZk80 {
    public static void main(String[] args) {
        SpringApplication.run(OrderMainFeignZk80.class, args);
    }
}
```
4.业务类
```java
@Component
@FeignClient(value = "cloud-provider-payment")
public interface PaymentFeignService {
    @GetMapping(value = "/payment/zk")
    String getzkById();
}
```
5.Controller
```java
@RestController
@Slf4j
public class OrderFeignController {
    @Resource
    private PaymentFeignService paymentFeignService;
    @GetMapping(value = "/consumer/payment/feign/zk")
    public String paymentInfo() {
        String result = paymentFeignService.getzkById();
        log.info(result);
        return result;
    }
}
```
## Consul && OpenFegin
与 上述 类似
