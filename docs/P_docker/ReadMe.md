[TOC]

# 安装使用 Docker

- [Docker 官网](https://docs.docker.com/)
- [Docker 入门](https://yeasy.gitbook.io/docker_practice/)
- 

# 安装使用 MySQL 

- [DockerHub MySQL](https://hub.docker.com/_/mysql)

- ```console
  docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
  ```

- ```console
  docker exec -it some-mysql bash
  ```

- ```
  mysql ‐h host[数据库地址] ‐u root[用户] ‐p root[密码] ‐P 3306
  ```

# 安装使用 Redis

- [DockerHub Redis](https://hub.docker.com/_/redis)

```dockerfile
FROM centos:7

RUN set -x; buildDeps='gcc libc6-dev make wget' \
    && yum update \
    && yum install -y $buildDeps \
    && wget -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz" \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -rf /var/lib/apt/lists/* \
    && rm redis.tar.gz \
    && rm -r /usr/src/redis \
    && yum purge -y --auto-remove $buildDeps
```













