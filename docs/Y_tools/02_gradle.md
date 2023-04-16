# gradle

###  热部署Devtools
[参考](https://my.oschina.net/u/4357815/blog/3432047)

1、在build.gradle文件dependencies下加入compile("org.springframework.boot:spring-boot-devtools")
2、开启IDEA自动编译
![](https://note.youdao.com/yws/api/personal/file/58E02B9E8FA94D2D9CA627FF723FE1A4?method=download&shareKey=97434a0480d828137bd8b19e42c0191e)
3、上面的打勾之后，按下面的键
```
windows:ctrl + alt + shift + /
mac: command + alt + shift + /
```
点击Registry,勾选compiler.automake.allow.when.app.running
![](https://note.youdao.com/yws/api/personal/file/74173773AF9A4C58A71551D212A4587D?method=download&shareKey=c4ab6dcbfa1250f7fd3f5d0429ccba70)
![](https://note.youdao.com/yws/api/personal/file/FBEBFA75A6BA4BF4BD4254226DA9D0AC?method=download&shareKey=1465d6aea24a2cdaa405c1299286cdd0)

gradle > Gradle 5.6.x