# Maven

### Maven 中 dependencyManagement 和 dependencies 有什么区别

- Maven 使用 dependencyManagement 元素来提供一种管理依赖版本号的方式，**通常会在一个组织或项目的最顶层的父 POM 中看到 dependencyManagement**
- 使用 pom.xml 中的 dependencyManagement 元素能让所有在子项目中引用一个依赖而不用显式的列出版本号。Maven 会沿着父子层次向上走，直到找到一个拥有 dependencyManagement 元素的项目，然后它就会使用这个 dependencyManagement 元素中指定的版本。
- 这样做的好处：如果多个子项目都引用同一个依赖，则可以避免在每个使用的子项目中都声明一个版本号，这样当升级或者切换到另一个版本时，只需要在顶层父项目中更新，不需要一个一个项目中修改；另外，如果某个子项目需要另外的一个版本，只需要自己声明 version 即可。
- **dependencyManagement 里只是声明依赖，并不引入，因此子项目需要显示的声明需要用的依赖**
- 如果不在子项目中声明依赖，是不会从父项目中继承下来的；只有在子项目中写了该依赖，并且没有指定具体的版本，才会从父项目中继承该项，并且 version 和 scope 都读自父 pom
- 如果子项目中指定了版本，则使用子项目中指定的

###  热部署Devtools

1. 引入坐标依赖

   ```xml
       <!--热部署-->
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-devtools</artifactId>
           <scope>runtime</scope>
           <optional>true</optional>
       </dependency>
   ```

2. 添加插件到父类总工程中

   ```xml
     <build>
           <finalName>工程名字</finalName>
           <plugins>
               <plugin>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-maven-plugin</artifactId>
                   <configuration>
                   <fork>true</fork>
                   <addResources>true</addResources>
                   </configuration>
               </plugin>
           </plugins>
       </build>
   ```
3. 开启自动编译权限
   setting->Build,Execution,Deployment->Compiler 内复选框全部打勾

4. 开启热注册
   1. 进入子模块 ctrl shift alt /
   2. 选择 Registry
      compiler.automake.allow.when.app.running
      compiler.automake.allow.when.app.running
      这两个勾选中
   3. 重启idea