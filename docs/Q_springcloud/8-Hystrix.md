# Q_springcloud Hystrix
## 参考
官网： https://github.com/Netflix/Hystrix
官网文档：https://github.com/Netflix/Hystrix/wiki/How-To-Use
## Hystrix 简介
### 分布式系统面临的问题
复杂分布式系统中的应用程序有数十个依赖关系，每个依赖关系在某些时候不可避免的失败。
![](https://note.youdao.com/yws/api/personal/file/5CF84964339D4EF5B4A70B45B1B20F78?method=download&shareKey=5f813828b554d537671744fdebf1ae01)

### 重要概念
#### 服务雪崩
多个微服务之间调用的时候，假设微服务 A 调用微服务 B 和微服务 C，微服务 B 和微服务 C 又调用其他的微服务，这就是所谓的“扇出”。如果扇出的链路上某个微服务的调用响应时间过长或者不可用，对微服务 A 的调用就会占用越老越多的系统资源，进而引起系统崩溃，这就是所谓的“雪崩效应”。
    
对于高流量的应用来说，单一的后端依赖可能会导致所有服务器上的所有资源都在几秒内饱和。比失败更糟糕的是，这些应用程序还可能导致服务之间的延迟增加，备份队列、线程和其他系统资源紧张，导致整个系统发生更多的级联故障。因此**需要对故障和延迟进行隔离和管理，以便单个依赖关系的失败，不能取消整个应用程序或系统。**

所以，通常当发现一个模块下某个接口调用失败后，这个模块依然在接收流量，然后整个有问题的模块还调用了其他的模块，这样就会发生级联故障，或者叫雪崩

#### 服务降级（Fallback）
1. 服务器忙时，不让客户端等待并立即返回一个友好的提示（例如：服务器繁忙，请稍后重试.）
2. 哪些情况会导致服务降级
	- 程序运行异常
	- 超时
	- 服务熔断触发服务降级
	- 线程池/信号量打满
#### 服务熔断（break）
1. 类比保险丝达到最大服务访问时，直接拒绝访问，拉闸限电，然后调用服务降级的方法返回友好提示。
2. 服务降级->进而熔断->恢复调用链路
#### 服务限流（flow limit）
1. 秒杀高并发等操作，严禁一窝蜂过来拥挤，一秒N个有序进行。

### Hystrix 是什么
- Hystrix 是处理分布式系统的**延迟**和**容错**的开源库，保证一个依赖出现问题时不会导致整体服务失败，避免级联故障，以提高分布式系统弹性。
- “断路器“本身是一种开关装置，当某个服务单元发生故障后，通过断路器的故障监控（类似熔断保险丝），**向调用方返回一个符合预期的可处理的备选响应（Fallback），而不是长时间的等待或抛出调用方法无法处理的异常 **。这样就保证了服务调用方的线程不会被长时间、不必要的占用，从而避免了故障在分布式系统中的蔓延，乃至雪崩

## Hystrix 怎么用
[Hystrix配置](https://github.com/Netflix/Hystrix/wiki/Configuration)

### 超时时间设置
[Ribbon、Fegin、Hystrix 超时时间设置](https://priesttomb.github.io/%E5%88%86%E5%B8%83%E5%BC%8F/2018/09/19/Zuul-Ribbon-Feign-Hystrix-%E8%B6%85%E6%97%B6%E6%97%B6%E9%97%B4%E8%AE%BE%E7%BD%AE%E9%97%AE%E9%A2%98/)
[Q_springcloud + OpenFegin 超时设置](https://blog.csdn.net/catoop/article/details/107698575)

#### 默认配置超时时间
**注意：
Hystrix 默认超时时间是 1s（timeoutInMilliseconds = 1000）
Fegin 默认连接超时时间 connect-timeout 是 10s；读取超时时间read-timeout 是 60s **

![](https://note.youdao.com/yws/api/personal/file/57EC720EC6794A288A3BDBD450720BEF?method=download&shareKey=aed57a2ed36bfbd31b8c281f1201da8c)

#### Feign + Hystrix + Ribbon
最基本的配置，是 Hystrix 自己的一长串配置：hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds，**但在 Feign 模块中，单独设置这个超时时间不行，还要额外设置 Ribbon 的超时时间**，比如：
```yml
feign:
  client:
    config:        #  如果要单独设置某个服务的超时时间，下面的 default 换成服务名
      default:     #  这里default 是设置所有fegin client调用服务的超时时间
        connectTimeout: 12000  # 这里单位是毫秒
        readTimeout: 12000     # 这里单位是毫秒
  hystrix:
    enabled: true  # 设置开启 hystrix  默认是 false 不开启
    
hystrix:
  command:     #  如果要单独设置某个服务的超时时间，下面的 default 换成服务名
    default:   #  这里default 是设置所有调用服务的超时时间
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 5000  # 这里单位是毫秒

ribbon:
  ReadTimeout: 5000
  ConnectTimeout: 5000
```
### 创建服务提供方 payment
1. 创建 Module - cloud-provider-hystrix-payment8001
2. pom
```xml
<!--hystrix-->
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
</dependency>
```
3. yml
```yml
server:
  port: 8001
spring:
  application:
    name: cloud-provider-hystrix-payment
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://eureka7001.com:7001/eureka,http://eureka7002.com:7002/eureka,http://eureka7003.com:7003/eureka
      #defaultZone: http://eureka7001.com:7001/eureka
```
4. 主启动
```java
@SpringBootApplication
@EnableEurekaClient
public class PaymentHystrixMain8002 {
    public static void main(String[] args) {
        SpringApplication.run(PaymentHystrixMain8002.class, args);
    }
}
```
5. 业务类
```java
@Service
public class PaymentService {
    /**
     * 正常访问，肯定OK
     *
     * @param id
     * @return
     */
    public String paymentInfo_OK(Integer id) {
        return "线程池:  " + Thread.currentThread().getName() + "  paymentInfo_OK,id:  " + id + "\t" + "O(∩_∩)O哈哈~";
    }

    public String paymentInfo_TimeOut(Integer id) {
        //int age = 10/0;
        try {
            TimeUnit.MILLISECONDS.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return "线程池:  " + Thread.currentThread().getName() + " id:  " + id + "\t" + "O(∩_∩)O哈哈~" + "  耗时(3秒): ";
    }

```
```java
@RestController
@Slf4j
public class PaymentController {
    @Resource
    private PaymentService paymentService;

    @Value("${server.port}")
    private String serverPort;
    @Value("${spring.application.name}")
    private String appName;
    @Value("${spring.cloud.client.ip-address}")
    private String ipAddr;

    @GetMapping("/payment/hystrix/ok/{id}")
    public String paymentInfo_OK(@PathVariable("id") Integer id) {
        String result = paymentService.paymentInfo_OK(id);
        result = result + "---【" + ipAddr + "-" + appName + "-" + serverPort + "】";
        log.info("*****result: " + result);
        return result;
    }

    @GetMapping("/payment/hystrix/timeout/{id}")
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id) {
        String result = paymentService.paymentInfo_TimeOut(id);
        result = result + "---【" + ipAddr + "-" + appName + "-" + serverPort + "】";
        log.info("*****result: " + result);
        return result;
    }

```
6. 测试
先启动7001，在启动8001测试两个方法，全部正常
### 使用Jmeter模拟高并发
#### Jmeter 参考
官网：https://jmeter.apache.org/
官网下载：http://jmeter.apache.org/download_jmeter.cgi
中文教程：https://www.yiibai.com/jmeter
入门：https://www.jianshu.com/p/0e4daecc8122
#### 使用 Jmeter 压测
给这个接口  http://localhost:8002/payment/hystrix/timeout/1  20000的并发
结果：
http://localhost:8001/ok/1 也有延迟
上述还是8001单独测试，如果外部消费者80也来访问，那么消费者只能干等，最终导致消费端80不满意，服务端8001直接被拖死。

### 创建服务调用方 order
1. 建moudle cloud-consumer-feign-hystrix-order80
2. pom
```xml
<!--openfeign-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
<!--hystrix-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter	-netflix-hystrix</artifactId>
</dependency>
<!--eureka client-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```
3. yml
```yml
server:
  port: 80
eureka:
  client:
    register-with-eureka: true
    service-url:
      defaultZone: http://eureka7001.com:7001/eureka/,http://eureka7002.com:7002/eureka/,http://eureka7002.com:7002/eureka/

feign:
  hystrix:
    enabled: true #开启 hystrix
```
4. 主启动类
```java
@SpringBootApplication
@EnableFeignClients
public class OrderHystrixMain80
{
    public static void main(String[] args)
    {
        SpringApplication.run(OrderHystrixMain80.class,args);
    }
}
```
5. service
```java
@Component
@FeignClient(value = "CLOUD-PROVIDER-HYSTRIX-PAYMENT")
public interface PaymentHystrixService {
    @GetMapping("/payment/hystrix/ok/{id}")
    String paymentInfo_OK(@PathVariable("id") Integer id);
    @GetMapping("/payment/hystrix/timeout/{id}")
    String paymentInfo_TimeOut(@PathVariable("id") Integer id);
}
```
6. controller
```java
@RestController
@Slf4j
public class OrderHystirxController
{
    @Resource
    private PaymentHystrixService paymentHystrixService;

    @GetMapping("/consumer/payment/hystrix/ok/{id}")
    public String paymentInfo_OK(@PathVariable("id") Integer id)
    {
        String result = paymentHystrixService.paymentInfo_OK(id);
        return result;
    }

    @GetMapping("/consumer/payment/hystrix/timeout/{id}")
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id)
    {
        //int age = 10/0;
        String result = paymentHystrixService.paymentInfo_TimeOut(id);
        return result;
    }
}
```
7. 测试
    1. 正常情况下
        1. http://localhost:8001/ok/1
        2. http://localhost:8001/timeout/1
        3. http://localhost/ok/1
        4. 通过80 访问的非常快
    2. 高并发打到8001端口时,80端口也会非常慢

### 降级如何做
1. 超时导致服务器变慢（转圈）->超时不再等待
2. 出错（宕机或程序运行时出错）->出错要有兜底
3. 解决
    1. 服务 8001 超时，调用者 80 不能一直等待，必须有服务降级【服务提供方降级】
    2. 服务 8001 宕机，调用者 80 不能一直等待，必须有服务降级【服务提供方降级】
    3. 服务 8001 OK ，调用者自己出故障或有自我要求（自己的等待时间小于服务提供的时间），自己降级处理【服务调用方降级】

### 服务降级
#### 服务提供方 payment
PaymentService.java
模拟超时
```java
    //设置超时时间 3s 
    @HystrixCommand(fallbackMethod = "paymentInfo_TimeOutHandler",commandProperties = {            @HystrixProperty(name="execution.isolation.thread.timeoutInMilliseconds",value="3000")})
    public String paymentInfo_TimeOut(Integer id)
    {
        try { TimeUnit.MILLISECONDS.sleep(3000); } catch (InterruptedException e) { e.printStackTrace(); }
        return "线程池:  "+Thread.currentThread().getName()+" id:  "+id+"\t"+"O(∩_∩)O哈哈~"+"  耗时(秒): ";
    }
    public String paymentInfo_TimeOutHandler(Integer id)
    {
        return "线程池:  "+Thread.currentThread().getName()+"  8001系统繁忙或者运行报错，请稍后再试,id:  "+id+"\t"+"o(╥﹏╥)o";
    }
```
PaymentService.java
模拟异常
```java
    @HystrixCommand(fallbackMethod = "paymentInfo_TimeoutHandler",commandProperties = {            @HystrixProperty(name="execution.isolation.thread.timeoutInMilliseconds",value = "3000")})
    public String paymentInfo_Timeout(Integer id){
        int a = 10/0;
		//       try {
		//            TimeUnit.MILLISECONDS.sleep(3000);
		//        } catch (InterruptedException e) {
		//            e.printStackTrace();
		//        }
        return "线程池："+Thread.currentThread().getName()+"Timeout"+id;
    }
```
主程序：需要添加注解@EnableCircuitBreaker
```java
@SpringBootApplication
@EnableEurekaClient
@EnableCircuitBreaker
public class PaymentHystrixMain8001
{
    public static void main(String[] args) {
            SpringApplication.run(PaymentHystrixMain8001.class, args);
    }
}
```
无论是运行异常还是超时都有兜底策略
#### 服务调用方 order
**Hystrix既可以配在客户端也可以配在服务端，一般建议放在客户端**
1. yml
```yml
feign:
  hystrix:
    enabled: true
```
2. controller 
```java
@RestController
@Slf4j
public class OrderHystirxController {
    @Resource
    private PaymentHystrixService paymentHystrixService;
    @GetMapping("/consumer/payment/hystrix/ok/{id}")
    public String paymentInfo_OK(@PathVariable("id") Integer id) {
        String result = paymentHystrixService.paymentInfo_OK(id);
        return result;
    }
    @GetMapping("/consumer/payment/hystrix/timeout/{id}")
    @HystrixCommand(fallbackMethod = "paymentTimeOutFallbackMethod", commandProperties = {
            @HystrixProperty(name = "execution.isolation.thread.timeoutInMilliseconds", value = "4000")
    })
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id) {
        //int age = 10/0;
        String result = paymentHystrixService.paymentInfo_TimeOut(id);
        return result;
    }
    public String paymentTimeOutFallbackMethod(@PathVariable("id") Integer id) {
        return "我是消费者80,对方支付系统繁忙请10秒钟后再试或者自己运行出错请检查自己,o(╥﹏╥)o";
    }
}
```
3. 主类
添加 @EnableHystrix 注解
```java 
@SpringBootApplication
@EnableFeignClients
@EnableHystrix
public class OrderHystrixMain80 {
    public static void main(String[] args) {
        SpringApplication.run(OrderHystrixMain80.class, args);
    }
}
```
4. 注意：降级处理方法参数列表必须跟异常方法一样

#### 全部服务降级
##### 存在问题
1. 每一个方法都需要配置一个降级方法，代码膨胀
2. 和业务代码在一起，耦合太高
##### 统一降级方法，解决问题1
服务调用放 order
OrderHystirxController.java
```java
    @RestController
    @Slf4j
    // 1. 添加注解，标注全局服务降级方法
    @DefaultProperties(defaultFallback = "paymentGlobalFallBack")
    public class OrderController {
        @Resource
        private PaymentHystrixService service;
        // 3. 写 @HystrixCommand单不指定具体方法 
        @GetMapping("/consumer/payment/hystrix/timeout/{id}")
        @HystrixCommand
        public String paymentInfo_OK(@PathVariable Integer id) {
            int a = 10/0;
            return service.paymentInfo_OK(id);
        }
        // 2. 定义全局服务降级方法
        // 下面是全局 fallback
        public String paymentGlobalFallBack(){
            return "80：获取异常，调用方法为全局fallback";
        }
    }

```
##### 降级方法与业务逻辑解耦，解决问题2
1. 找到注解 @FeignClient 对应的接口
2. 再写一个类实现该接口，对降级方法进行处理
```java
        @Component
        @FeignClient(value = "CLOUD-PROVIDER-HYSTRIX-PAYMENT",fallback = PaymentFallBackService.class)
        public interface PaymentHystrixService {}

        @Component
        public class PaymentFallBackService implements PaymentHystrixService {}
```
3. 测试在 8001 内加异常，或使 8001 宕机 ，返回异常处理

### 服务熔断
### 简介
参考：https://martinfowler.com/bliki/CircuitBreaker.html
- 熔断机制是应对雪崩效应的一种微服务链路保护机制，类比保险丝，达到最大访问后直接拒绝访问，拉闸限电，然后调用服务降级。**当检测到该节点微服务调用正常后，恢复调用链路。**
- 当失败的调用达到一定阈值，**缺省是5s内20次调用失败，就会启动熔断机制。**
- 熔断机制的注解是，@HystrixCommand

![](https://note.youdao.com/yws/api/personal/file/C1CC319EA5AE4B48AB714C8F5C2A2501?method=download&shareKey=3817704fff5bfb735817ada4c0f73bd6)
熔断器主要由三种状态：
closed：服务正常执行，断路器关闭，线路是通的
open：服务终止，断路器打开，线路不通
half open：服务半开启，断路器半打开，尝试提供服务

### 服务提供方 payment
1. PaymentService.java
例如服务熔断的条件是 **在10s内的10次请求中如果失败超过6次服务则进行熔断**，实现如下：
```java
    // 服务熔断
@HystrixCommand(fallbackMethod = "paymentInfo_Circuit",commandProperties = {
@HystrixProperty(name="circuitBreaker.enabled",value = "true"),//是否开启断路器            @HystrixProperty(name="circuitBreaker.requestVolumeThreshold",value = "10"),// 请求次数            @HystrixProperty(name="circuitBreaker.sleepWindowInMilliseconds",value = "10000"),// 时间窗口期            @HystrixProperty(name="circuitBreaker.errorThresholdPercentage",value = "60")// 失败率    
    })
    public String paymentCircuitBreaker(@PathVariable("id") Integer id){
        if (id<0){
            throw new RuntimeException("id 不能为负数");
        }
        String serialNumber = IdUtil.simpleUUID();
        return "调用成功："+serialNumber;
    }
    //熔断函数
    public String paymentInfo_Circuit(Integer id){
        return "id不能为负数："+id;
    }
```
2. controller
```java
    // 服务熔断
    @GetMapping("/circuit/{id}")
    public String paymentCircuitBreaker(@PathVariable("id") Integer id){
        String result = paymentService.paymentCircuitBreaker(id);
        log.info("************"+result);
        return result;
    }
```
3. 主函数
需要加上注解@EnableCircuitBreaker，开启熔断
4. 结果
一直输入id为负数，达到失败率后即使输入id为正数也进入错误页面。

### 服务熔断总结
#### 熔断类型
1. 熔断打开
请求不再进行调用当前服务，内部设有时钟一般为 MTTR，当打开时长达时钟则进入半熔断状态
2. 熔断关闭
熔断关闭不会对服务进行熔断
3. 熔断半开
根据规则调用当前服务，符合规则恢复正常，关闭熔断
#### 什么时候打开
设计三个参数：时间窗，请求总阈值，错误百分比阈值
1. 快照时间窗：默认为最近的10s。断路器是否需要打开需要统计一些请求和错误数据，而统计的时间范围就是快照时间戳。
2. 请求总数阈值：默认为20。在快照时间窗内，必须满足请求总阈值才有资格熔断。意味着在10s内，如果命令调用次数不足20次，即使所有请求都超时或其他原因失败断路器都不会打开。
3. 错误百分比阈值：默认是50%，当请求总数在快照时间窗内超过了阈值，且错误次数占总请求次数的比值大于阈值，断路器将会打开。
![](https://note.youdao.com/yws/api/personal/file/2C6EB851138E4497914D7356BE238AC9?method=download&shareKey=977d89ed95f56e00aea78f38e4a6ad25)
#### 如何恢复主逻辑
Hystrix 实现了自动恢复的功能。当断路器打开，对主逻辑进行熔断后，Hystrix 会启动一个休眠时间窗，在这个时间窗内，降级逻辑是历史的成为主逻辑，当休眠时间时间窗到期，断路器将进入半开状态，释放一次请求到原来的主逻辑上，乳沟此次请求正常返回，那么断路器将继续闭合，主逻辑恢复，如果这次请求依然有问题，断路器继续进入打开状态，休眠时间窗重新计时。

## Hystrix 流程
![](https://note.youdao.com/yws/api/personal/file/50D1029EA1134AF2BBF01204AAA25488?method=download&shareKey=69a68c445837e8b98f492be45a253e6f)
　下面解释流程图中具体逻辑：
1、包装请求：
　可以使用继承HystrixCommand或HystrixObservableCommand来包装业务方法；
2、发起请求：
　使用调用Command的execute来执行一个业务方法调用；
　Hystrix除了提供了execute方法，另外还提供了3种方来，所有的请求入口：
　　如上图所示：
　　执行同步调用execute方法，会调用queue().get()方法，queue()又会调用toObservable().toBlocking().toFuture()；
　　所以，所有的方法调用都依赖Observable的方法调用，只是取决于是需要同步还是异步调用；
3、缓存处理：
　　当请求来到后，会判断请求是否启用了缓存（默认是启用的），再判断当前请求是否携带了缓存Key；
　　如果命中缓存就直接返回；否则进入剩下的逻辑；
4、判断断路器是否打开（熔断）
　　断路器是Hystrix的设计核心，断路器是实现快速失败的重要手段（断路器打开就直接返回失败）；
　　可以设置断路器打开一定时间后，可以进行尝试进行业务请求（默认是5000毫秒）；
5、判断是否进行业务请求（请求是否需要隔离或降级）：
　　是否进行业务请求之前还会根据当前服务处理质量，判断是否需要去请求业务服务；
　　如果当前服务质量较低（线程池/队列/信号量已满），那么也会直接失败；
　　线程池或信号量的选择（默认是线程池）：
　　　　线程池主要优势是客户端隔离和超时设置，但是如果是海量低延迟请求时，频繁的线程切换带来的损耗也是很可观的，这种情况我们就可以使用信号量的策略；
　　　　信号量的主要缺点就是不能处理超时，请求发送到客户端后，如果被客户端pending住，那么就需要一直等待；
6、执行业务请求：
　　当前服务质量较好，那么就会提交请求到业务服务器去；
　　HystrixObservableCommand.construct() or HystrixCommand.run()
7、健康监测：
　　根据历史的业务方法执行结果，来统计当前的服务健康指标，为断路器是否熔断等动作作为依据；　　
8/9、响应失败或成功的处理结果

## web界面图形化展示Dashboard
### 搭建
1. 建 moudle
cloud-consumer-hystrix-dashboard9001
2. pom
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
</dependency>
```
3. yml
只需要配置端口号就行
4. 启动类
加注解@EnableHystrixDashboard
5. 测试
http://localhost:9001/hystrix有页面即为成功

### 使用
#### 注意
1. 注意：依赖于actuator，要监控哪个接口，哪个接口必须有这个依赖
2. 业务模块需要添加bean
```java
    @Bean
    public ServletRegistrationBean getServlet(){
        HystrixMetricsStreamServlet streamServlet = new HystrixMetricsStreamServlet();
        ServletRegistrationBean registrationBean = new ServletRegistrationBean(streamServlet);
        registrationBean.setLoadOnStartup(1);
        registrationBean.addUrlMappings("/hystrix.stream");
        registrationBean.setName("HystrixMetricsStreamServlet");
        return registrationBean;
    }
```
##### 使用
![](https://note.youdao.com/yws/api/personal/file/71719716CC2E4E3A8C2155EA08B63E27?method=download&shareKey=ceb097d26d4f29e0d4ea016c41504875)
1. 进行8001 的访问查看对应页面变化
2. 页面状态
    1. 七色
        对应不同状态
    2. 一圈
        对应访问量
    3. 一线
        访问趋势