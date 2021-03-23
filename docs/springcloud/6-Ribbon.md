# SpringCloud Ribbon
## Ribbon概述
### 资料
官网：https://github.com/Netflix/ribbon
### Ribbon是什么？
- Spring Cloud Ribbon 是基于 Netflix Ribbon 实现的一套**客户端负载均衡的工具。**
- Ribbon 是 Netflix 的开源项目，主要功能是提供**客户端的软件负载均衡算法和服务调用。**
- Ribbon 客户端组件提供一系列完善的配置项，如连接超时、重试等。
- 在配置文件中列出  Load Balancer 后面所有机器，Ribbon 会自动帮助你基于某种规则 (如简单轮询、随机连接等)去连接这些机器。我们很容易使用Ribbon实现自定义的负载均衡算法。
- Ribbon 虽然已经处于维护阶段，不再更新，但是由于大规模的应用在生产环境中，很难短时间内被替换掉。Spring Cloud 的 LoadBalancer 是未来的替代品。
### Ribbon能干什么？
* 负载均衡- Load Balance 
	- 什么是负载均衡：将用户的请求平摊的分配到多个服务上，从而达到HA(高可用)，常见的负载均衡有 Nginx、LVS、硬件 F5 等。
	- 负载均衡又分为集中式 LB和进程内 LB
		- 集中式 LB，在服务的消费方和服务的提供方之间使用的独立 LB 设置，例如:软件Nginx，或硬件 F5等。该 LB 设施将访问请求通过某种策略转发给服务提供方。
		- 进程内 LB，将 LB 逻辑集成到消费方，消费方从服务注册中心获知有哪些地址可用，然后自己再从这些地址中选择出一个合适的服务器，例如 Ribbon
* Ribbon 只是一个类库，集成与消费方进程，消费方通过它来获取到服务提供方的地址。
* Ribbon 本地负载均衡客户端 VS Nginx 服务端负载均衡
	- Nginx 是服务器负载均衡，客户端所有请求都会交给 nginx，然后由 nginx 实现请求转发。即负载均衡是由服务端实现的。
	- Ribbon 是本地负载均衡，在微服务调用接口时，在注册中心上获取注册信息服务列表 之后缓存在 JVM 本地，从而实现本地 RPC 远程服务调用技术。

## Ribbon 负责均衡的实现
![](https://note.youdao.com/yws/api/personal/file/CAC1F68BCD0E4153B7FE7F0C44BC5E83?method=download&shareKey=0ec39ceef9bdb8ea366e8d7c8d48cdfc)
实现就是**负载均衡+RestTemplate 调用**
Ribbon工作时有两步
1. 第一步先选择 EurekaServer，优先选择统一区域负载较少的 server
2. 第二部再根据用户指定的策略，从server取到的服务注册列表中选择一个地址。其中 Riibon 提供了多种策略（轮询，随机，根据响应时间加权）。

### 引入依赖
- 新版本的 Eureka Client 中已经包含了 spring-cloud-starter-netflix-eureka-client，所以 pom.xml 中就不再需要另外引入依赖。
- spring-cloud-starter-netflix-eureka-client 已经引入了 Ribbon-Balance的依赖

### RestTemplate 使用
1. getForObject 返回json
2. getForEntity 返回ResponseEnity对象，包括响应头，响应体等信息。
3. postForObject
与 get 方法一样，不同的是传进去的参数是对象
4. postForEntity
5. GET 请求方法
6. POST请求方法

## Ribbon 核心组件 IRule
```
public interface IRule{
    /*
     * choose one alive server from lb.allServers or
     * lb.upServers according to key
     * @return choosen Server object. NULL is returned if none
     *  server is available 
     */
    public Server choose(Object key);    
    public void setLoadBalancer(ILoadBalancer lb);    
    public ILoadBalancer getLoadBalancer();    
}
```
### IRule 的实现
![](https://note.youdao.com/yws/api/personal/file/81CC4CF02F2F4254BE6C1195EA240DDB?method=download&shareKey=cb3b4b633600a143fb96e613f8f20d52)
com.netflix.loadbalancer 的实现
1. RoundRobinRule   轮询
2. RandomRule   随机
3. RetryRule    先按照RoundRobinRule的 策略获取服务，如果获取服务失败则在指定时间里进行重试，获取可用服务
4. WeightedResponseTimeRule 对RoundRobinRule的扩展，响应速度越快，实例选择权重越大 ，越容易被选择
5. BestAvailableRule    会先过滤掉由于多次访问故障而处于断路器跳闸状态的服务，然后选择一个并发一个最小的服务
6. AvailabilityFilteringRule  先过滤掉故障实例，再选择并发量较小的实例
7. ZoneAvoidanceRule    默认规则，符合server所在区域的性能和server的可用性选择服务器
### 如何修改默认的负载均衡策略
1. **注意：IRule配置类不能放在@ComponentSan 的包及子包下，因为默认的扫描会变成全局负载均衡都按照这样的规则。**
2. 新建包 com.wxh.myRule
3. 新建类 
```java
    public class MySelfRule {
        @Bean
        public IRule myRule(){
            return new RandomRule();//定义为随机
        }
    }
```
4. 主类添加注解
```java
// 选择要接收的服务和配置类
@RibbonClient(name = "CLOUD-PAYMENT-SERVICE",configuration = MySelfRule.class)
```
## Ribbon 负载均衡算法
### 轮回算法
rest 接口第几次请求数 % 服务器集群=实际调用服务器位置下标，每次服务重启后rest接口计数从1
例如：
总台数：2台
请求数  调用下标
  1        1%2=1       
  2        2%2=0
  3        3%2=1
  4        4%2=0
###  RoundRobinRule源码分析
```java
 public Server choose(ILoadBalancer lb, Object key) {
        if (lb == null) {
            log.warn("no load balancer");
            return null;
        }

        Server server = null;
        int count = 0;
        while (server == null && count++ < 10) {
            List<Server> reachableServers = lb.getReachableServers();
            List<Server> allServers = lb.getAllServers();
            int upCount = reachableServers.size();
            int serverCount = allServers.size();

            if ((upCount == 0) || (serverCount == 0)) {
                log.warn("No up servers available from load balancer: " + lb);
                return null;
            }

            int nextServerIndex = incrementAndGetModulo(serverCount);
            server = allServers.get(nextServerIndex);

            if (server == null) {
                /* Transient. */
                Thread.yield();
                continue;
            }

            if (server.isAlive() && (server.isReadyToServe())) {
                return (server);
            }

            // Next.
            server = null;
        }

        if (count >= 10) {
            log.warn("No available alive servers after 10 tries from load balancer: "
                    + lb);
        }
        return server;
    }
    
        /**
     * Inspired by the implementation of {@link AtomicInteger#incrementAndGet()}.
     *
     * @param modulo The modulo to bound the value of the counter.
     * @return The next value.
     */
    private int incrementAndGetModulo(int modulo) {
        for (;;) {
            int current = nextServerCyclicCounter.get();
            int next = (current + 1) % modulo;
            if (nextServerCyclicCounter.compareAndSet(current, next))
                return next;
        }
    }
```
### 自定义负载均衡实现
**如果要用自己写的负载均衡算法，RestTemplate 上要去掉注解 @LoadBalanced**
如果用 Ribbon 自带的，需要用注解 @LoadBalanced

LoadBalancer.java
```java
import org.springframework.cloud.client.ServiceInstance;
import java.util.List;
public interface LoadBalancer
{
    ServiceInstance instances(List<ServiceInstance> serviceInstances);
}
```

MyLB.java
```java
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.stereotype.Component;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
@Component
public class MyLB implements LoadBalancer
{

    private AtomicInteger atomicInteger = new AtomicInteger(0);

    public final int getAndIncrement()
    {
        int current;
        int next;

        do {
            current = this.atomicInteger.get();
            next = current >= 2147483647 ? 0 : current + 1;
        }while(!this.atomicInteger.compareAndSet(current,next));
        System.out.println("*****第几次访问，次数next: "+next);
        return next;
    }

    //负载均衡算法：rest接口第几次请求数 % 服务器集群总数量 = 实际调用服务器位置下标  ，每次服务重启动后rest接口计数从1开始。
    @Override
    public ServiceInstance instances(List<ServiceInstance> serviceInstances)
    {
        int index = getAndIncrement() % serviceInstances.size();

        return serviceInstances.get(index);
    }
}

```



