CREATE TABLE `employees` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`name` varchar(24) NOT NULL DEFAULT '' COMMENT '姓名',
`age` int(11) NOT NULL DEFAULT '0' COMMENT '年龄',
`position` varchar(20) NOT NULL DEFAULT '' COMMENT '职位',
`hire_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入职时间',
PRIMARY KEY (`id`),
KEY `idx_name_age_position` (`name`,`age`,`position`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='员工记录表';

 INSERT INTO employees(name,age,position,hire_time) VALUES('gbwxy',33,'ceo',NOW());
 INSERT INTO employees(name,age,position,hire_time) VALUES('wxy', 23,'cfo',NOW());
 INSERT INTO employees(name,age,position,hire_time) VALUES('wby',23,'master',NOW());
 INSERT INTO employees(name,age,position,hire_time) VALUES('LiLei',22,'manager',NOW());
 INSERT INTO employees(name,age,position,hire_time) VALUES('HanMeimei', 23,'dev',NOW());
 INSERT INTO employees(name,age,position,hire_time) VALUES('Lucy',23,'dev',NOW());


DROP TABLE IF EXISTS `actor`;
CREATE TABLE `actor` (
`id` int(11) NOT NULL,
`name` varchar(45) DEFAULT NULL,
`update_time` datetime DEFAULT NULL,
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 INSERT INTO `actor` (`id`, `name`, `update_time`) VALUES (1,'a',now()), (2,'b',now()), (3,'c',now());

 DROP TABLE IF EXISTS `film`;
 CREATE TABLE `film` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `name` varchar(10) DEFAULT NULL,
 PRIMARY KEY (`id`),
 KEY `idx_name` (`name`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 INSERT INTO `film` (`id`, `name`) VALUES (3,'film0'),(1,'film1'),(2,'film2');

 DROP TABLE IF EXISTS `film_actor`;
 CREATE TABLE `film_actor` (
 `id` int(11) NOT NULL,
 `film_id` int(11) NOT NULL,
 `actor_id` int(11) NOT NULL,
 `remark` varchar(255) DEFAULT NULL,
 PRIMARY KEY (`id`),
 KEY `idx_film_actor_id` (`film_id`,`actor_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 INSERT INTO `film_actor` (`id`, `film_id`, `actor_id`) VALUES (1,1,1),(2,1,2),(3,2,1);

 ‐‐ 插入一些示例数据
 drop procedure if exists insert_emp;
 delimiter ;;
 create procedure insert_emp()
 begin
 declare i int;
 set i=1;
 while(i<=100000)do
 insert into employees(name,age,position) values(CONCAT('didi',i),i,'dev');
 insert into employees(name,age,position) values(CONCAT('dada',i),i,'dev');
 set i=i+1;
 end while;
 end;;
 delimiter ;
 call insert_emp();





 ‐‐建表SQL
CREATE TABLE `mylock` (
`id` INT (11) NOT NULL AUTO_INCREMENT,
`NAME` VARCHAR (20) DEFAULT NULL,
PRIMARY KEY (`id`)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;
‐‐插入数据
 INSERT INTO `mylock` (`id`, `NAME`) VALUES ('1', 'a');
 INSERT INTO `mylock` (`id`, `NAME`) VALUES ('2', 'b');
 INSERT INTO `mylock` (`id`, `NAME`) VALUES ('3', 'c');
 INSERT INTO `mylock` (`id`, `NAME`) VALUES ('4', 'd');