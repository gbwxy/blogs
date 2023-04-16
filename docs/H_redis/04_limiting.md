# Redis 限流方案

## 简单限流

``` Java
public class SimpleRateLimiter {

    private Jedis jedis;

    public SimpleRateLimiter(Jedis jedis) {
        this.jedis = jedis;
    }

    /**
     * 这里 Redis 操作都是针对同一个 Key 的，使用 Pipeline 可以显著提升 Redis 存取效率
     * 缺点：
     *      要记录时间窗口内所有的行为记录，如果这个量很大，比如 限定 60s 内操作不得超过 100w 次，
     *      这种场景是不适合做这样的限流的，因为会消耗大量的存储空间。
     *
     * @param userId
     * @param actionKey
     * @param period
     * @param maxCount
     * @return
     */
    public boolean isActionAllowed(String userId, String actionKey, int period, int maxCount) {
        String key = String.format("hist:%s:%s", userId, actionKey);
        long nowTs = System.currentTimeMillis();
        System.out.println("The Key is " + key);
        System.out.println("Now time is " + nowTs);
		
		//使用 Pipeline 
        Pipeline pipe = jedis.pipelined();
        pipe.multi();
        pipe.zremrangeByScore(key, 0, nowTs - period * 1000);
        Response<Long> zcard = pipe.zcard(key);
        pipe.exec();
        pipe.close();
        
        //查看个数
        boolean isAllow = zcard.get() < maxCount;
        if (isAllow) {
        	//如果没有到达限流，向 redis 中写入
            pipe = jedis.pipelined();
            pipe.multi();
            pipe.zadd(key, nowTs, "" + nowTs);
            pipe.expire(key, period + 60);
            pipe.exec();
            pipe.close();
        }
        return isAllow;
    }

	//测试
    public static void main(String[] args) {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MyRedisConfig.class);
        Jedis jedis = (Jedis) applicationContext.getBean("jedis");

        SimpleRateLimiter simpleRateLimiter = new SimpleRateLimiter(jedis);

        for (int i = 0; i < 20; i++) {
            boolean actionAllowed = simpleRateLimiter.isActionAllowed("gbwxy", "reply", 60, 5);
            System.out.println(actionAllowed);
        }

    }
}


```


## 漏斗限流

### 漏斗算法

``` Java
public class FunnelRateLimiter {

    /**
     * 漏斗算法：先漏水，再灌水
     */
    static class Funnel {
        /**
         * 漏斗总容量
         */
        int capacity;
        /**
         * 漏水速率
         */
        float leakingRate;
        /**
         * 漏斗剩余容量
         */
        int leftQuota;
        /**
         * 记录上一次获取漏斗的时间
         */
        long leakingTs;

        public Funnel(int capacity, float leakingRate) {
            this.capacity = capacity;
            this.leakingRate = leakingRate;
            this.leakingTs = System.currentTimeMillis();
            this.leftQuota = capacity;
        }


        /**
         * 漏水
         */
        void makeSpace() {
            long nowTs = System.currentTimeMillis();
            long deltaTs = nowTs - leakingTs;
            //计算上次获取漏斗，到目前，一共漏了多少水
            //deltaQuota 可以腾出的空间
            int deltaQuota = (int) (deltaTs * leakingRate);
            if (deltaQuota < 0) {
                this.leftQuota = capacity;
                this.leakingTs = nowTs;
                return;
            }
            //腾出空间
            if (deltaQuota < 1) {
                return;
            }
            //剩余空间 = 原剩余空间 + 可以腾出来的空间
            this.leftQuota += deltaQuota;
            //更新上一次灌水时间
            this.leakingTs = nowTs;
            if (this.leftQuota > this.capacity) {
                this.leftQuota = this.capacity;
            }
        }

        /**
         * 灌水
         *
         * @param quota
         * @return
         */
        boolean watering(int quota) {

            //灌水前先漏水
            makeSpace();
            if (this.leftQuota >= quota) {
                this.leftQuota -= quota;
                return true;
            }
            return false;
        }

    }


    private Map<String, Funnel> funnels = new HashMap<>();

    public boolean isActionAllowed(String userId, String actionKey, int capacity, float leakingRate) {
        String key = String.format("%s:%s", userId, actionKey);
        Funnel funnel = funnels.get(key);
        if (funnel == null) {
            funnel = new Funnel(capacity, leakingRate);
            funnels.put(key, funnel);
        }

        return funnel.watering(1);
    }

}


```

### Redis-Cell
















