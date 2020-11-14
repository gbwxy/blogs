# ZooKeeper 之客户端 API 的使用
----
Zookeeper 作为一个分布式服务框架，主要用来解决分布式数据一致性问题，它提供了简单的分布式原语，并且对多种编程语言提供了 API。下面我们来看一下 Zookeeper 的 Java 客户端 API 使用方式。

在我们项目里要用到 Zookeeper 的 API 的时候，我们项目中需要添加依赖，以 gradle 方式为例
```
 compile('org.apache.zookeeper:zookeeper:3.4.10')
```

##  创建会话
----
### 构造函数
```
	ZooKeeper(String connectString, int sessionTimeout, Watcher watcher) 
	ZooKeeper(String connectString, int sessionTimeout, Watcher watcher,boolean canBeReadOnly) 
	ZooKeeper(String connectString, int sessionTimeout, Watcher watcher, long sessionId, byte[] sessionPasswd) 
	ZooKeeper(String connectString, int sessionTimeout, Watcher watcher, long sessionId, byte[] sessionPasswd,boolean canBeReadOnly) 
```
使用任意一个构造函数都能够完成与 Zookeeper 服务器的会话（ Session ）创建，下面主要介绍下上述构造函数中每个参数的说明。

| 参数名                     | 描述                                                         |
| -------------------------- | ------------------------------------------------------------ |
| connectString              | 连接服务器列表，用英文 "," 分割，例如：192.168.1.1:2128,192.168.1.2:2128,192.168.1.3:2128。<br> 另外，也可以在 connectString   中设置客户端的根目录 ( Chroot )，例如：192.168.1.1:2128,192.168.1.2:2128,192.168.1.3:2128/root_path，这样客户端连接到服务端后所有的操作都在这个根目录下。 |
| sessionTimeOut             | 心跳检测时间周期（超时时间，毫秒）<br>在一个会话周期内， Zookeeper 客户端和服务器之间会通过心跳检测机制来维持会话的有效性，一旦在 sessionTimeout 时间内没有进行有效的心跳检测，会话就会失效。 |
| watcher                    | 事件处理通知器。关于 Watcher 的详细介绍请参考 [ZooKeeper 之 Watcher](./docs/zookeeper/06_zookeeper_watcher.md) <br>该参数可以设置为 null 以表明不需要设置默认的 Watcher 事件通知处理器。 |
| canBeReadOnly              | boolean类型参数，标识当前会话 **是否支持只读**。<br>默认情况下，在 Zookeeper 集群中，一个机器如果和集群中过半及以上机器失去了网络连接，那么这个机器将不再处理客户端请求，但是在某些场景下，当 ZooKeeper 服务器发生此类故障的时候，我们还是希望ZooKeeper 服务器能够提供读服务，这就是 ZooKeeper 的 **只读** 模式。 |
| sessionId<br>sessionPasswd | 分别代表会话ID和会话密钥，用于唯一确定一个会话，可以实现客户端会话复用，从而达到恢复会话的效果。<br>具体的使用方法是，第一次连接上ZooKeeper服务器时，通过调用ZooKeeper对象实例的以下两个接口，即可获得当前会话的ID和秘钥：<br>long getSessionId()<br>byte[] getSessionPasswd()<br>获取到这两个参数之后，就可以在下次创建 Zookeeper 对象实例的时候传入构造方法了。 |

**注意：**
**Zookeeper 客户端和服务端会话的建立是一个异步的过程**，也就是说在程序中，构造方法会在处理完客户端初始化工作后立即返回，在大多数情况下，此时并没有真正建立好一个可用的会话，在会话的生命周期中处于 “CONNECTING” 状态。

当该会话真正创建完毕后，Zookeeper 服务端会向会话对应的客户端发送一个事件通知，以告知客户端，客户端只有获取到这个通知后才算建立了会话。

该构造函数方法内部实现了与 Zookeeper 服务器之间的 TCP 连接创建，负责维护客户端会话的声明周期。

### 创建最基本的 Zookeeper 会话

其中 Zookeeper_Constructor_Usage_Simple 类实现了 Watcher 接口，重写了 process 方法，该方法负责处理来自 Zookeeper 服务端的 Watcher 通知，在收到服务端发来的 SynConnected 事件之后，解除主程序在 CountDownLatch 上的等待阻塞。关于 Watcher 相关的介绍，后续会介绍。

```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooKeeper;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_Constructor_Usage_Simple implements Watcher {

    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    public static void main(String[] args) throws Exception {
        ZooKeeper zooKeeper = new ZooKeeper("127.0.0.1:2181", 5000, new Zookeeper_Constructor_Usage_Simple());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        try {
            connectedSemaphore.await();
            log.info("=============  zookeeper state is :" + zooKeeper.getState());
        } catch (Exception ex) {
            log.info("=============  zookeeper session established.");
        }
    }
    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. name is :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            connectedSemaphore.countDown();
        }
    }
}

```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. name is :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
```

### 复用 SessionId 和 SessionPasswd 创建 Zookeeper 会话

Zookeeper 构造方法允许传入 SessionId 和 SessionPasswd 的目的是为了复用会话，以维持之前会话的有效性。**客户端传入  SessionId 和 SessionPasswd 的目的是为了复用会话，以维持之前会话的有效性。**

```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooKeeper;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_Constructor_Usage_SID_PW {

    public static void main(String[] args) throws Exception {
        CountDownLatch connectedSemaphore = new CountDownLatch(1);
        ZooKeeper zooKeeper = new ZooKeeper("127.0.0.1:2181",
                5000,
                new MyWatcher(connectedSemaphore));
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        long sessionId = zooKeeper.getSessionId();
        byte[] passwd = zooKeeper.getSessionPasswd();
        ZooKeeper zooKeeper2 = new ZooKeeper("127.0.0.1:2181",
                5000,
                new MyWatcher(connectedSemaphore),
                1L,
                "test".getBytes());
        log.info("=============  zooKeeper2 state is :" + zooKeeper.getState());
        ZooKeeper zooKeeper3 = new ZooKeeper("127.0.0.1:2181",
                5000,
                new MyWatcher(connectedSemaphore),
                sessionId,
                passwd);
        log.info("=============  zooKeeper3 state is :" + zooKeeper.getState());
        Thread.sleep(Integer.MAX_VALUE);
    }

    static class MyWatcher implements Watcher {
        private CountDownLatch connectedSemaphore;

        public MyWatcher(CountDownLatch countDownLatch) {
            connectedSemaphore = countDownLatch;
        }

        @Override
        public void process(WatchedEvent event) {
            log.info("=============  Receive watched event. event  :" + event);
            if (event.getState() == Event.KeeperState.SyncConnected) {
                connectedSemaphore.countDown();
            }
        }
    }
}

```

执行结果：
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
=============  zooKeeper2 state is :CONNECTED
=============  zooKeeper3 state is :CONNECTED
=============  Receive watched event. event  :WatchedEvent state:Expired type:None path:null
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
```


##  创建节点
----
### Create
同步创建：
```
	String create(String path,byte[] data,List<ACL> acl,CreateMode createMode)throws KeeperException,InterruptedException
	String create(String path,byte[] data,List<ACL> acl,CreateMode createMode,Stat stat)throws KeeperException,InterruptedException
	String create(String path,byte[] data,List<ACL> acl,CreateMode createMode,Stat stat,long ttl)throws KeeperException, InterruptedException
```
异步创建：
```
	void create(String path,byte[] data,List<ACL> acl,CreateMode createMode,AsyncCallback.StringCallback cb,Object ctx)
	void create(String path,byte[] data,List<ACL> acl,CreateMode createMode,AsyncCallback.Create2Callback cb,Object ctx)
	void create(String path,byte[] data,List<ACL> acl,CreateMode createMode,AsyncCallback.Create2Callback cb,Object ctx,long ttl)
```

接口参数说明

| 参数名     | 说明                                                         |
| :--------- | ------------------------------------------------------------ |
| path       | 创建的数据节点的路径                                         |
| data[]     | 数据节点的初始值                                             |
| acl        | 数据节点的 ACL 策略，关于 ACL 详细介绍请参考 [ZooKeeper 之 ACL](./docs/zookeeper/06_zookeeper_acl.md) |
| createMode | 节点类型<br>CONTARINER：容器<br>EPHEMERAL：临时<br>EPHEMERAL_SEQUENTIAL：临时顺序<br>PERSISTENT：持久<br>PERSISTENT_SEQUENTIAL：持久顺序<br>PERSISTENT_WITH_TTL：持久，超时时间<br>PERSISTENT_SEQUENTIAL_WITH_TTL：持久顺序，超时时间 |
| stat       | 返回的 stat 状态实体                                         |
| ttl        | long 类型，单位是毫秒。取值范围是 0 到 [EphemeralType.maxValue](https://zookeeper.apache.org/doc/r3.5.8/apidocs/zookeeper-server/org/apache/zookeeper/server/EphemeralType.html#maxValue--)<br>只有当 createMode 是 ERSISTENT_WITH_TTL 或 PERSISTENT_SEQUENTIAL_WITH_TTL类型的时候该参数才起作用。<br>如果节点在给定的 TTL 时间内没有被修改，当它没有子节点的时候将会被立即删除。 |
| cb         | 注册一个回调函数，需要实现接口的方法 processResult()<br>回调接口有三种：<br>当服务端节点创建完毕后， Zookeeper 客户端就会自动调用这个方法，就可以处理相关的业务逻辑了。 |
| ctx        | 用于传递一个对象，可以在回调方法执行的时候使用，通常是上下文信息。 |
| 返回值     | 创建节点的准确路径                                           |

**注意**
- 无论同步还是异步，都不支持递归创建，即无法在父节点不存在的情况下创建子节点
- 不允许创建同名的节点，会抛出 NodeExistsException 异常
- 节点初始值只支持传入字节数组 ( byte[] ) ，即 Zookeeper 不负责序列化，用户需要自己序列化和反序列化
- acl 咱们例子这里先传入 Ids.OPEN_ACL_UNSAFE，这就表明之后对这个节点的任何书籍都不受权限限制。关于 ACL 请参考 [ZooKeeper 之 ACL](./docs/zookeeper/06_zookeeper_acl.md) 

### Create 示例
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_Create_API_Sync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);

    public static void main(String[] args) throws Exception {
        ZooKeeper zooKeeper = new ZooKeeper("127.0.0.1:2181",
                5000,
                new Zookeeper_Create_API_Sync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());


        String path = "/zk-test";
        path = zooKeeper.create(path,
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
        log.info("=============  同步创建完成，Path :" + path);

        log.info("=============  同步创建，Path :" + path);
        String path1 = zooKeeper.create(path + "/sync",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL);
        log.info("=============  同步创建完成，Path :" + path1);


        log.info("=============  异步创建，Path :" + path);
        zooKeeper.create(path + "/async",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL,
                new IStringCallBack(),
                "I am context.");


        zooKeeper.create(path + "/async",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL,
                new IStringCallBack(),
                "I am context.");


        zooKeeper.create(path + "/async2",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL_SEQUENTIAL,
                new IStringCallBack(),
                "I am context.");

        Thread.sleep(Integer.MAX_VALUE);
    }

    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            connectedSemaphore.countDown();
        }
    }

    static class IStringCallBack implements AsyncCallback.StringCallback {
        @Override
        public void processResult(int rc, String path, Object ctx, String name) {
            log.info("=============  Create path result :[" + rc + "," + path + "," + "," + ctx + "]");

        }
    }
}

```
输出结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
=============  同步创建完成，Path :/zk-test
=============  同步创建完成，Path :/zk-test/sync
同步创建完成，Path :/zk-test/sync
=============  异步创建，Path :/zk-test
=============  Create path result :[0,/zk-test/async,,I am context.]
=============  Create path result :[-110,/zk-test/async,,I am context.]
=============  Create path result :[0,/zk-test/async2,,I am context.]
```

回调函数 public void processResult(int rc, String path, Object ctx, String name) 参数说明

| 参数名 | 说明                                                         |
| ------ | ------------------------------------------------------------ |
| rc     | Return Code，服务端响应码。<br>常见响应码如下：<br>· 0：OK，接口调用成功<br>· -4：ConnectionsLoss，客户端和服务端连接已断开<br>· -110：NodeExists，指定节点已存在<br>· -112：SessionExpired，会话已过期 |
| path   | 客户端异步调用时传入的 path ，标识数据节点的路径             |
| ctx    | 客户端异步调用时传入的参数 ctx，标识上下文 object            |
| name   | 创建的数据节点的名字，完整节点路径，序列节点带着数字后缀     |



##  删除节点
### Delete
----
```
	void delete(String path, int version)
	void delete(String path, int version, AsyncCallback.VoidCallback cb, Object ctx)
```

接口参数说明

| 参数名  | 说明                 |
| ------- | -------------------- |
| path    | 指定数据节点的路径   |
| version | 指定节点的数据版本   |
| cb      | 注册一个异步回调函数 |
| ctx     | 用户传递上下文信息   |

### Delete 示例

```
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.Watcher.Event.EventType;
import org.apache.zookeeper.Watcher.Event.KeeperState;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
import java.util.concurrent.CountDownLatch;

public class Delete_API_Sync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    private static ZooKeeper zk;
    public static void main(String[] args) throws Exception {
        String path = "/zktest";
        zk = new ZooKeeper("127.0.0.1:2181",
                5000, //
                new Delete_API_Sync_Usage());
        connectedSemaphore.await();

        zk.create(path, "".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
        zk.delete(path, -1);

        Thread.sleep(Integer.MAX_VALUE);
    }

    @Override
    public void process(WatchedEvent event) {
        if (KeeperState.SyncConnected == event.getState()) {
            if (EventType.None == event.getType() && null == event.getPath()) {
                connectedSemaphore.countDown();
            }
        }
    }
}

```

##  读取数据
----
### GetChildren
Zookeeper 客户端可以通过 API 来获取一个节点的所有的子节点，有如下接口：
同步调用
```
	List<String> getChildren(String path, boolean watch)
	List<String> getChildren(String path, boolean watch, Stat stat)
	List<String> getChildren(String path, Watcher watcher)
	List<String> getChildren(String path, Watcher watcher, Stat stat)
```
异步调用
```
	void getChildren(String path, boolean watch, AsyncCallback.Children2Callback cb, Object ctx)
	void getChildren(String path, boolean watch, AsyncCallback.ChildrenCallback cb, Object ctx)
	void getChildren(String path, Watcher watcher, AsyncCallback.Children2Callback cb, Object ctx)
	void getChildren(String path, Watcher watcher, AsyncCallback.ChildrenCallback cb, Object ctx)

```
接口参数说明

| 参数名        | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| path          | 指定数据节点的节点路径                                       |
| watcher       | 注册的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md), 一旦在本次子节点获取之后，子节点列表发生变更的话，就会向客户端发送通知。<br>该参数允许传入null |
| watch         | 参数类型为 boolean，表明是否需要注册一个默认的 Watcher<br>这里所指的默认 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) 是创建 Zookeeper 连接的时候指定的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) <br>如果这里传入 true，那么 Zookeeper 客户端会自动使用默认的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) ，否则不需要注册 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md)。 |
| cb            | 注册一个异步回调函数                                         |
| ctx           | 用于传递上下文信息                                           |
| stat          | 指定数据节点的节点状态信息<br>用法：传入一个旧的 stat 变量，该变量会在方法执行过程中北来自服务端响应的新 stat 对象替换。关于 stat 的介绍请参考 [ZooKeeper 之基本概念与使用](./docs/zookeeper/02_zookeeper_use.md) |
| return 返回值 | 返回值类型是 List<String>，给定路径下所有的子节点            |

- [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) ：如果客户端在获取到指定节点的子节点列表之后，还需要订阅这个子节点列表的变化通知，那么就可以通过注册一个 Watcher 来实现。当有子节点被添加或删除时，服务端就会向客户端发送一个 NodeChildrenChange 类型的事件通知。**注意：在服务端发送给客户端的时间通知中，是不包含最新的节点列表的，客户端必须主动重新进行获取。**通常客户端在收到这个事件通知后会再次获取最新的子节点列表
- [stat](./docs/zookeeper/02_zookeeper_use.md)：该对象记录了一个节点的基本属性信息，例如节点创建的事务 ID (cZxid) 、最后一次修改的事务 ID (mZxid)、节点数据内容长度等。当我们需要获取最新节点状态信息的时候，可以将一个旧的 stat 传入 API 接口，该 stat 变量会在方法执行过程中，被服务端响应的新 stat 替换。

### GetChildren 示例
#### 同步获取子节点列表
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import java.util.List;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_GetChildren_API_Sync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    static ZooKeeper zooKeeper;
    static String path = "/zk_test";
    public static void main(String[] args) throws Exception {
        zooKeeper = new ZooKeeper("127.0.0.1:2181",
                5000,
                new Zookeeper_GetChildren_API_Sync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        zooKeeper.create(path,
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
        zooKeeper.create(path + "/c1",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL);

        List<String> children = zooKeeper.getChildren(path, true);
        for (String child : children) {
            log.info("=============  child :" + child);
        }
        zooKeeper.create(path + "/c2",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL);

        /**
         * 删除数据节点之前需要先删除其child
         */
        zooKeeper.delete(path + "/c1", 0);
        zooKeeper.delete(path + "/c2", 0);
        zooKeeper.delete(path, 0);
        Thread.sleep(Integer.MAX_VALUE);
    }


    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            if (event.getType() == Event.EventType.None && event.getPath() == null) {
                connectedSemaphore.countDown();
            } else if (event.getType() == Event.EventType.NodeChildrenChanged) {
                try {
                    log.info("==============  ReGet Child :" + zooKeeper.getChildren(event.getPath(), true));
                } catch (Exception ex) {
                    log.info("==============  ReGet Child error :" + ex);
                }
            }
        }
    }
}
```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  child :c1
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/zk_test
==============  ReGet Child :[c1, c2]
==============  ReGet Child :[c2]
==============  ReGet Child :[]
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDeleted path:/zk_test
```

#### 异步获取子节点列表
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import org.apache.zookeeper.data.Stat;
import java.util.List;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_GetChildren_API_ASync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    static ZooKeeper zooKeeper;
    static String path = "/zk_test";

    public static void main(String[] args) throws Exception {
        zooKeeper = new ZooKeeper("127.0.0.1:2181",
                5000,
                new Zookeeper_GetChildren_API_ASync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        zooKeeper.create(path,
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
        zooKeeper.create(path + "/c1",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL);
        zooKeeper.getChildren(path, true, new IChildren2Callback(), null);
        zooKeeper.create(path + "/c2",
                "".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.EPHEMERAL);
        /**
         * 删除数据节点之前需要先删除其child
         */
        zooKeeper.delete(path + "/c1", 0);
        zooKeeper.delete(path + "/c2", 0);
        zooKeeper.delete(path, 0);
        Thread.sleep(Integer.MAX_VALUE);
    }
    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            if (event.getType() == Event.EventType.None && event.getPath() == null) {
                connectedSemaphore.countDown();
            } else if (event.getType() == Event.EventType.NodeChildrenChanged) {
                try {
                    log.info("==============  ReGet Child :" + zooKeeper.getChildren(event.getPath(), true));
                } catch (Exception ex) {
                    log.info("==============  ReGet Child error :" + ex);
                }
            }
        }
    }
    static class IChildren2Callback implements AsyncCallback.Children2Callback {
        @Override
        public void processResult(int rc, String path, Object ctx, List<String> children, Stat stat) {
            log.info("==============  Get Children znode result: [ response  code: " + rc + ", param path :" + path
                    + ", ctx: " + ctx + ", children list :" + children + ", stat :" + stat);
        }
    }
}
```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
==============  Get Children znode result: [ response  code: 0, param path :/zk_test, ctx: null, children list :[c1], stat :55839427571,55839427571,1604039791157,1604039791157,0,1,0,0,0,1,55839427572
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/zk_test
==============  ReGet Child :[c1, c2]
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/zk_test
==============  ReGet Child :[c2]
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/zk_test
==============  ReGet Child :[]
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDeleted path:/zk_test 
```
### GetData
客户端可以通过 API 获取节点的数据内容，有如下接口：
```
	byte[] getData(String path, boolean watch, Stat stat)
	byte[] getData(String path, Watcher watcher, Stat stat)
	void  getData(String path, boolean watch, AsyncCallback.DataCallback cb, Object ctx)
	void  getData(String path, Watcher watcher, AsyncCallback.DataCallback cb, Object ctx)
```
接口参数说明

| 参数名  | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| path    | 指定数据节点的路劲                                           |
| watcher | 注册的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md), 一旦之后节点内容发生变更，就会向客户端发送通知。<br>该参数允许传入null |
| stat    | 指定数据节点的节点状态信息<br/>用法：传入一个旧的 stat 变量，该变量会在方法执行过程中北来自服务端响应的新 stat 对象替换。关于 stat 的介绍请参考 [ZooKeeper 之基本概念与使用](./docs/zookeeper/02_zookeeper_use.md) |
| watch   | 参数类型为 boolean，表明是否需要注册一个默认的 Watcher<br/>这里所指的默认 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) 是创建 Zookeeper 连接的时候指定的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) <br>如果这里传入 true，那么 Zookeeper 客户端会自动使用默认的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md) ，否则不需要注册 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md)。 |
| cb      | 注册一个回到函数                                             |
| ctx     | 用于传递上下文信息                                           |

同步获取数据的 API，返回结果的类型是 byte[]，目前 Zookeeper 只支持这种类型的数据存储，所以设置数据和获取数据的时候需要自己做序列化和反序列化。

### GetData 示例
#### 同步获取数据示例
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import org.apache.zookeeper.data.Stat;
import java.util.List;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_GetData_API_Sync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    static ZooKeeper zooKeeper;
    static String path = "/zk_test";
    static Stat stat = new Stat();
    public static void main(String[] args) throws Exception {
        zooKeeper = new ZooKeeper("127.0.0.1:2181",
                5000,
                new Zookeeper_GetData_API_Sync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        zooKeeper.create(path,
                "123".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
  		log.info("=============  Get data :" + new String(zooKeeper.getData(path, true, stat)));
        log.info("=============  Get data`s stat: czxId： " + stat.getCzxid() + ", MzxId:" + stat.getMzxid() + ", version:" + stat.getVersion());
        List<String> children = zooKeeper.getChildren(path, true);
        for (String child : children) {
            log.info("=============  child :" + child);
        }
        zooKeeper.setData(path, "HelloWorld.".getBytes(), stat.getVersion());
        zooKeeper.delete(path, stat.getVersion() + 1);
        Thread.sleep(Integer.MAX_VALUE);
    }

    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            if (event.getType() == Event.EventType.None && event.getPath() == null) {
                connectedSemaphore.countDown();
            } else if (event.getType() == Event.EventType.NodeDataChanged) {
                try {
                    log.info("=============  Get data :" + new String(zooKeeper.getData(path, true, stat)));
                    log.info("============= process Get data`s stat: czxId： " + stat.getCzxid() + ", MzxId:" + stat.getMzxid() + ", version:" + stat.getVersion());

                } catch (Exception ex) {
                }
            }
        }
    }
}
```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
=============  Get data :123
=============  Get data`s stat: czxId： 55839468951, MzxId:55839468951, version:0
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDataChanged path:/zk_test
=============  Get data :HelloWorld.
============= process Get data`s stat: czxId： 55839472534, MzxId:55839472535, version:1
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDeleted path:/zk_test
```
#### 异步获取数据示例
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import org.apache.zookeeper.data.Stat;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_GetData_API_ASync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    static ZooKeeper zooKeeper;
    static String path = "/zk_test";
    static Stat stat = new Stat();
    public static void main(String[] args) throws Exception {
        zooKeeper = new ZooKeeper("127.0.0.1:2181",
                5000,
                new Zookeeper_GetData_API_ASync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        zooKeeper.create(path,
                "123".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
        log.info("=============  Get Data first.");
        zooKeeper.getData(path, true, new IDataCallback(), "Get Data first.");
        log.info("=============  Set Data.");
        zooKeeper.setData(path, "HelloWorld.".getBytes(), stat.getVersion());
        log.info("=============  Get Data Secand.");
        zooKeeper.getData(path, true, new IDataCallback(), "Get Data Secand.");
        Thread.sleep(Integer.MAX_VALUE);
    }

    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            if (event.getType() == Event.EventType.None && event.getPath() == null) {
                connectedSemaphore.countDown();
            } else if (event.getType() == Event.EventType.NodeDataChanged) {
                zooKeeper.getData(event.getPath(), true, new IDataCallback(), "NodeDataChanged");
            }
        }
    }

    static class IDataCallback implements AsyncCallback.DataCallback {
        @Override
        public void processResult(int rc, String path, Object ctx, byte[] data, Stat stat) {
            log.info("============== ctx :" + ctx + " rc:" + rc + ", path:" + path + ", data:" + new String(data));
            log.info("==============  Czxid:" + stat.getCzxid() + ", Mzxid:" + stat.getMzxid() +
                    ", version:" + stat.getVersion());
        }
    }
}
```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  zookeeper state is :CONNECTED
=============  Get Data first.
=============  Set Data.
============== ctx :Get Data first. rc:0, path:/zk_test, data:123
==============  Czxid:55839473292, Mzxid:55839473292, version:0
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDataChanged path:/zk_test
=============  Get Data Secand.
============== ctx :NodeDataChanged rc:0, path:/zk_test, data:HelloWorld.
==============  Czxid:55839473292, Mzxid:55839473293, version:1
============== ctx :Get Data Secand. rc:0, path:/zk_test, data:HelloWorld.
==============  Czxid:55839473292, Mzxid:55839473293, version:1
```
##  更新数据
----
### SetData
```
	Stat setData(String path, byte[] data, int version)
	void setData(String path, byte[] data, int version, AsyncCallback.StatCallback cb, Object ctx)
```
接口参数说明

| 参数名  | 说明                                                       |
| ------- | ---------------------------------------------------------- |
| path    | 指定数据节点的节点路径                                     |
| data[]  | 字节数组，使用该内容覆盖节点中的数据                       |
| version | 指定节点的数据版本，表明本次更新操作是针对该数据版本进行的 |
| cb      | 注册的一个异步回调函数                                     |
| ctx     | 用于传递上下文信息                                         |

我们着重讲一下参数 **version**。

该参数用于指定节点的数据版本，但是 getData 接口中并没有提供根据指定 version 获取数据的接口，那么这里的 version 意义何在？

在讲解 version 之前先来了解一下 CAS (Compare and Swap)，“对于值 V，每次更新前都会对比对其值是否是预期值 A，只有符合预期，才会将 V 原子化的更新到新值 B。” Zookeeper 的 SetData 接口中的 version 参数正是有 CAS 原理衍化来的。Zookeeper 每个节点都有数据版本的概念，在更新操作的时候，可以添加 version 这个参数，该参数可以对应于 CAS 原理中的“预期值”，表明是针对该数据版本进行更新。

具体来说，如果一个客户端试图进行更新操作，它会携带上次获取到的 version 值进行更新。而如果在这段时间内，Zookeeper 服务器上该节点的数据恰好已经被其他客户端更新了，那么起数据版本一定也发生了变化，因此肯定与客户端携带的 version 无法匹配，于是便无法更新成功。以此来避免一些分布式更新并发问题，Zookeeper 的客户端就可以利用该特性构建更复杂的应用场景。

### SetData示例
#### 异步更新数据示例
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import org.apache.zookeeper.data.Stat;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_SetData_API_ASync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    static ZooKeeper zooKeeper;
    static String path = "/zk_test";

    public static void main(String[] args) throws Exception {
        zooKeeper = new ZooKeeper("10.0.45.193:2181",
                5000,
                new Zookeeper_SetData_API_ASync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        zooKeeper.create(path,
                "123".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
        byte[] data = zooKeeper.getData(path, true, null);
        log.info("=============  Get data :" + String.valueOf(data));
        zooKeeper.setData(path, "HelloWorld.".getBytes(), -1, new ISetCallback(), "Set data first.");
        zooKeeper.setData(path, "HelloWorld.".getBytes(), -1, new ISetCallback(), "Set data secand.");
        zooKeeper.delete(path, -1);
        Thread.sleep(Integer.MAX_VALUE);
    }

    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            if (event.getType() == Event.EventType.None && event.getPath() == null) {
                connectedSemaphore.countDown();
            }
        }
    }


    static class ISetCallback implements AsyncCallback.StatCallback {
        @Override
        public void processResult(int rc, String path, Object ctx, Stat stat) {
            log.info("============== ctx :" + ctx + " rc:" + rc + ", path:" + path);
            log.info("==============  Czxid:" + stat.getCzxid() + ", Mzxid:" + stat.getMzxid() +
                    ", version:" + stat.getVersion());
            if (rc == 0) {
                log.info("============== SetCallback SUCCESS. ");
            }
        }
    }
}
```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
=============  Get data :123
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDataChanged path:/zk_test
============== ctx :Set data first. rc:0, path:/zk_test
==============  Czxid:55839602875, Mzxid:55839602876, version:1
============== SetCallback SUCCESS. 
============== ctx :Set data secand. rc:0, path:/zk_test
==============  Czxid:55839602875, Mzxid:55839602877, version:2
============== SetCallback SUCCESS. 
```

#### 同步更新数据示例
```
import lombok.extern.slf4j.Slf4j;
import org.apache.zookeeper.*;
import org.apache.zookeeper.data.Stat;
import java.util.concurrent.CountDownLatch;

@Slf4j
public class Zookeeper_SetData_API_Sync_Usage implements Watcher {
    private static CountDownLatch connectedSemaphore = new CountDownLatch(1);
    static ZooKeeper zooKeeper;
    static String path = "/zk_test";
    public static void main(String[] args) throws Exception {
        zooKeeper = new ZooKeeper("10.0.45.193:2181",
                5000,
                new Zookeeper_SetData_API_Sync_Usage());
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        connectedSemaphore.await();
        log.info("=============  zookeeper state is :" + zooKeeper.getState());
        zooKeeper.create(path,
                "123".getBytes(),
                ZooDefs.Ids.OPEN_ACL_UNSAFE,
                CreateMode.PERSISTENT);
        byte[] data = zooKeeper.getData(path, true, null);
        log.info("=============  Get data :" + new String(data));
        Stat stat = zooKeeper.setData(path, "HelloWorld.".getBytes(), -1);
        log.info("=============  Set data`s stat: czxId： " + stat.getCzxid() + ", MzxId:" + stat.getMzxid() + ", version:" + stat.getVersion());
        Stat stat2 = zooKeeper.setData(path, "HelloWorld.".getBytes(), -1);
        log.info("=============  Set data`s stat2: czxId： " + stat2.getCzxid() + ", MzxId:" + stat2.getMzxid() + ", version:" + stat2.getVersion());
        zooKeeper.delete(path, stat2.getVersion());
        Thread.sleep(Integer.MAX_VALUE);

    }

    @Override
    public void process(WatchedEvent event) {
        log.info("=============  Receive watched event. event  :" + event);
        if (event.getState() == Event.KeeperState.SyncConnected) {
            if (event.getType() == Event.EventType.None && event.getPath() == null) {
                connectedSemaphore.countDown();
            }
        }
    }
}

```
执行结果
```
=============  zookeeper state is :CONNECTING
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:None path:null
=============  zookeeper state is :CONNECTED
=============  Get data :123
=============  Receive watched event. event  :WatchedEvent state:SyncConnected type:NodeDataChanged path:/zk_test
=============  Set data`s stat: czxId： 55839605248, MzxId:55839605249, version:1
=============  Set data`s stat2: czxId： 55839605248, MzxId:55839605250, version:2
```

在第一次更新操作中，version 使用的是 -1，这里**需要注意的是， Zookeeper 中，数据版本是从 0 开始的， -1 并不是一个合法的版本号，它仅仅是一个标识，如果客户端传入版本参数是 -1，就是告诉服务器，客户端需要基于数据的最新版本进行更新操作**。如果 Zookeeper 数据节点的更新操作没有原子性要求，可以直接用 -1。

##  检测节点是否存在
----
### Exists
```
	Stat exists(String path, boolean watch)
	Stat exists(String path, Watcher watcher)
	void exists(String path, boolean watch, AsyncCallback.StatCallback cb, Object ctx)
	void exists(String path, Watcher watcher, AsyncCallback.StatCallback cb, Object ctx)
```

接口参数说明

| 参数名  | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| path    | 指定数据节点的节点路径                                       |
| watcher | 注册的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md)，用于监听以下三类事件<br>- 节点被创建<br>- 节点被删除<br>- 节点被更新 |
| watch   | 指定是否复用 Zookeeper 中默认的 [Watcher](./docs/zookeeper/06_zookeeper_watcher.md)                     |
| cb      | 注册一个异步回调函数                                         |
| ctx     | 用于传递上下文                                               |

该接口主要用于检测指点节点是否存在，返回值是 stat。如果在调用时注册 Watcher 的话，还可以对节点是否存在进行监听，一旦节点被创建、被删除、或数据被更新都会通知客户端。



### Exists 示例



##  权限控制

----

### SetAcl



### GetAcl



### SetAcl 示例



### GetAcl 示例





## 参考

----
[官方API--r3.5.8](https://zookeeper.apache.org/doc/r3.5.8/apidocs/zookeeper-server/index.html)

