/*
 Navicat Premium Data Transfer

 Source Server         : 10.0.46.25
 Source Server Type    : MySQL
 Source Server Version : 50721
 Source Host           : 10.0.46.25:3306
 Source Schema         : nosql_core

 Target Server Type    : MySQL
 Target Server Version : 50721
 File Encoding         : 65001

 Date: 18/11/2019 09:42:44
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE nosql_core;

USE nosql_core;
-- ----------------------------
-- Table structure for available_features
-- ----------------------------
DROP TABLE IF EXISTS `available_features`;
CREATE TABLE `available_features`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `engine` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库类型',
  `engine_version` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库版本',
  `node_type` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库系列',
  `region_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '地域id',
  `instance_type` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '实例类型',
  `feature_type` char(8) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '特性类型',
  `feature` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '特性描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of available_features
-- ----------------------------
INSERT INTO `available_features` VALUES (1, 'mongodb', '3.6', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'router', 'mongodb_base,mongodb_account,mongodb_rdsmonitor,mongodb_copy,mongodb_param,mongodb_log');
INSERT INTO `available_features` VALUES (3, 'mongodb', '3.6', 'HA', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'router', 'mongodb_base,mongodb_account,mongodb_rdsmonitor,mongodb_copy,mongodb_param,mongodb_log');
INSERT INTO `available_features` VALUES (4, 'mongodb', '3.6', 'HA', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'button', 'mysql_standby_switch');
INSERT INTO `available_features` VALUES (5, 'mongodb', '3.6', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'charge', 'YEAR_MONTH,CHARGING_HOURS');
INSERT INTO `available_features` VALUES (6, 'mongodb', '3.6', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'readonly', 'charge', 'CHARGING_HOURS');
INSERT INTO `available_features` VALUES (7, 'mongodb', '3.6', 'HA', '71661ed7-545a-440b-9360-6fa87280e4d7', 'backupdisaster', 'charge', 'YEAR_MONTH,CHARGING_HOURS');
INSERT INTO `available_features` VALUES (8, 'redis', '3.2', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'router', 'redis_base,redis_rdsmonitor,redis_copy,redis_param,redis_log');
INSERT INTO `available_features` VALUES (9, 'redis', '3.2', 'EE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'router', 'redis_base,redis_rdsmonitor,redis_copy,redis_param');
INSERT INTO `available_features` VALUES (10, 'redis', '3.2', 'EE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'button', 'mysql_standby_switch');
INSERT INTO `available_features` VALUES (11, 'redis', '3.2', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'common', 'charge', 'YEAR_MONTH,CHARGING_HOURS');
INSERT INTO `available_features` VALUES (12, 'redis', '3.2', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'readonly', 'charge', 'CHARGING_HOURS');
INSERT INTO `available_features` VALUES (13, 'redis', '3.2', 'EE', '71661ed7-545a-440b-9360-6fa87280e4d7', 'backupdisaster', 'charge', 'YEAR_MONTH,CHARGING_HOURS');

-- ----------------------------
-- Table structure for available_zones
-- ----------------------------
DROP TABLE IF EXISTS `available_zones`;
CREATE TABLE `available_zones`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `engine` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库类型',
  `engine_version` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库版本',
  `node_type` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库部署方式',
  `region_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '地域id',
  `az_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '可用地域id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of available_zones
-- ----------------------------
INSERT INTO `available_zones` VALUES (1, 'mongodb', '3.6', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', '1a0594ad-548b-487a-8d65-7bbb774fa58c');
INSERT INTO `available_zones` VALUES (2, 'mongodb', '3.6', 'HA', '71661ed7-545a-440b-9360-6fa87280e4d7', '1a0594ad-548b-487a-8d65-7bbb774fa58c');
INSERT INTO `available_zones` VALUES (3, 'redis', '3.2', 'SE', '71661ed7-545a-440b-9360-6fa87280e4d7', '1a0594ad-548b-487a-8d65-7bbb774fa58c');
INSERT INTO `available_zones` VALUES (4, 'redis', '3.2', 'EE', '71661ed7-545a-440b-9360-6fa87280e4d7', '1a0594ad-548b-487a-8d65-7bbb774fa58c');

-- ----------------------------
-- Table structure for engine_params
-- ----------------------------
DROP TABLE IF EXISTS `engine_params`;
CREATE TABLE `engine_params`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `engine` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库类型',
  `engine_version` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库版本',
  `node_type` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '数据库部署方式',
  `param_name` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '参数名',
  `param_description` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '参数描述',
  `location` char(8) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '语言类型',
  `default_value` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '默认值',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 338 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of engine_params
-- ----------------------------
INSERT INTO `engine_params` VALUES (1, 'redis', '3.2', 'SE', 'maxmemory-policy', '内存达到上限时对缓存数据的管理策略', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (2, 'redis', '3.2', 'SE', 'hash-max-ziplist-entries', '当hash表中的数据库条数少于设定的参数值时，使用ziplist编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (3, 'redis', '3.2', 'SE', 'zset-max-ziplist-value', '当有序集合中各字段长度的最大值小于设定的参数值时，使用ziplist编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (4, 'redis', '3.2', 'SE', 'hash-max-ziplist-value', '当hash表中各字段长度的最大值小于设定的参数值时，使用ziplist编码格式，以达到节约省存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (5, 'redis', '3.2', 'SE', 'set-max-intset-entries', '当一个集合存储仅包含字符串且整数数量少于设定的参数值时，使用intset编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (6, 'redis', '3.2', 'SE', 'zset-max-ziplist-entries', '当有序集合中的数据记录数少于设定的参数值时，使用ziplist编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (7, 'redis', '3.2', 'SE', 'maxmemory-policy', 'Management strategy for cached data when memory reaches the upper limit.', 'en', '');
INSERT INTO `engine_params` VALUES (8, 'redis', '3.2', 'SE', 'hash-max-ziplist-entries', 'When the number of databases in the hash table is less than the set parameter value, the ziplist encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (9, 'redis', '3.2', 'SE', 'zset-max-ziplist-entries', 'When the number of data records in the ordered set is less than the set parameter value, the ziplist encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (10, 'redis', '3.2', 'SE', 'set-max-intset-entries', 'When a collection store contains only strings and the number of integers is less than the set parameter value, the intset encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (11, 'redis', '3.2', 'SE', 'zset-max-ziplist-value', 'When the maximum length of each field in the ordered set is less than the set parameter value, the ziplist encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (12, 'redis', '3.2', 'SE', 'hash-max-ziplist-value', 'When the maximum length of each field in the hash table is less than the set parameter value, the ziplist encoding format is used to save the saving.', 'en', '');
INSERT INTO `engine_params` VALUES (13, 'redis', '3.2', 'EE', 'maxmemory-policy', '内存达到上限时对缓存数据的管理策略', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (14, 'redis', '3.2', 'EE', 'hash-max-ziplist-entries', '当hash表中的数据库条数少于设定的参数值时，使用ziplist编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (15, 'redis', '3.2', 'EE', 'zset-max-ziplist-entries', '当有序集合中的数据记录数少于设定的参数值时，使用ziplist编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (16, 'redis', '3.2', 'EE', 'set-max-intset-entries', '当一个集合存储仅包含字符串且整数数量少于设定的参数值时，使用intset编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (17, 'redis', '3.2', 'EE', 'zset-max-ziplist-value', '当有序集合中各字段长度的最大值小于设定的参数值时，使用ziplist编码格式，以达到节省内存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (18, 'redis', '3.2', 'EE', 'hash-max-ziplist-value', '当hash表中各字段长度的最大值小于设定的参数值时，使用ziplist编码格式，以达到节约省存的目的', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (19, 'redis', '3.2', 'EE', 'maxmemory-policy', 'Management strategy for cached data when memory reaches the upper limit.', 'en', '');
INSERT INTO `engine_params` VALUES (20, 'redis', '3.2', 'EE', 'hash-max-ziplist-entries', 'When the number of databases in the hash table is less than the set parameter value, the ziplist encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (21, 'redis', '3.2', 'EE', 'zset-max-ziplist-entries', 'When the number of data records in the ordered set is less than the set parameter value, the ziplist encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (22, 'redis', '3.2', 'EE', 'set-max-intset-entries', 'When a collection store contains only strings and the number of integers is less than the set parameter value, the intset encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (23, 'redis', '3.2', 'EE', 'zset-max-ziplist-value', 'When the maximum length of each field in the ordered set is less than the set parameter value, the ziplist encoding format is used to save memory.', 'en', '');
INSERT INTO `engine_params` VALUES (24, 'redis', '3.2', 'EE', 'hash-max-ziplist-value', 'When the maximum length of each field in the hash table is less than the set parameter value, the ziplist encoding format is used to save the saving.', 'en', '');
INSERT INTO `engine_params` VALUES (25, 'mongodb', '3.6', 'SE', 'operationProfiling.slowOpThresholdMs', '指定慢查询时间', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (26, 'mongodb', '3.6', 'SE', 'setParameter.cursorTimeoutMillis', 'MongoDB删除之前空闲游标的到期阈值', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (27, 'mongodb', '3.6', 'SE', 'setParameter.internalQueryExecMaxBlockingSortBytes', '当前缓冲区值', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (28, 'mongodb', '3.6', 'SE', 'operationProfiling.mode', '改变分析日志输出级别', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (29, 'mongodb', '3.6', 'SE', 'operationProfiling.slowOpThresholdMs', 'specify slow query time', 'en', '');
INSERT INTO `engine_params` VALUES (30, 'mongodb', '3.6', 'SE', 'setParameter.cursorTimeoutMillis', 'free curise expire threshold before delete MongoDB', 'en', '');
INSERT INTO `engine_params` VALUES (31, 'mongodb', '3.6', 'SE', 'setParameter.internalQueryExecMaxBlockingSortBytes', 'current buffer area value', 'en', '');
INSERT INTO `engine_params` VALUES (32, 'mongodb', '3.6', 'SE', 'operationProfiling.mode', 'change output level ofr analysis log', 'en', '');
INSERT INTO `engine_params` VALUES (33, 'mongodb', '3.6', 'HA', 'operationProfiling.slowOpThresholdMs', '指定慢查询时间', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (34, 'mongodb', '3.6', 'HA', 'setParameter.cursorTimeoutMillis', 'MongoDB删除之前空闲游标的到期阈值', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (35, 'mongodb', '3.6', 'HA', 'setParameter.internalQueryExecMaxBlockingSortBytes', '当前缓冲区值', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (36, 'mongodb', '3.6', 'HA', 'operationProfiling.mode', '改变分析日志输出级别', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (37, 'mongodb', '3.6', 'HA', 'operationProfiling.slowOpThresholdMs', 'specify slow query time', 'en', '');
INSERT INTO `engine_params` VALUES (38, 'mongodb', '3.6', 'HA', 'setParameter.cursorTimeoutMillis', 'free curise expire threshold before delete MongoDB', 'en', '');
INSERT INTO `engine_params` VALUES (39, 'mongodb', '3.6', 'HA', 'setParameter.internalQueryExecMaxBlockingSortBytes', 'current buffer area value', 'en', '');
INSERT INTO `engine_params` VALUES (40, 'mongodb', '3.6', 'HA', 'operationProfiling.mode', 'change output level ofr analysis log', 'en', '');
INSERT INTO `engine_params` VALUES (41, 'mongodb', '3.6', 'SE', 'net.compression.compressors', '指定用于此实例mongod或mongos实例之间通信的默认压缩器', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (42, 'mongodb', '3.6', 'SE', 'net.compression.compressors', 'Specifies the default compressor for communication between this instance mongod or mongos instances', 'en', '');
INSERT INTO `engine_params` VALUES (43, 'mongodb', '3.6', 'HA', 'net.compression.compressors', '指定用于此实例mongod或mongos实例之间通信的默认压缩器', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (44, 'mongodb', '3.6', 'HA', 'net.compression.compressors', 'Specifies the default compressor for communication between this instance mongod or mongos instances', 'en', '');
INSERT INTO `engine_params` VALUES (45, 'redis', '3.2', 'SE', 'slowlog-log-slower-than', '决定要对执行时间大于多少微秒的查询进行记录', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (46, 'redis', '3.2', 'SE', 'slowlog-max-len', '最多能保存多少条日志', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (47, 'redis', '3.2', 'SE', 'notify-keyspace-events', '通知客户端的事件类型', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (48, 'redis', '3.2', 'SE', 'slowlog-log-slower-than', 'Determine how many microseconds of query execution time you want to record', 'en', '');
INSERT INTO `engine_params` VALUES (49, 'redis', '3.2', 'SE', 'slowlog-max-len', 'How many logs can be saved at most', 'en', '');
INSERT INTO `engine_params` VALUES (50, 'redis', '3.2', 'SE', 'notify-keyspace-events', 'Notifies the client of the event type', 'en', '');
INSERT INTO `engine_params` VALUES (51, 'redis', '3.2', 'EE', 'slowlog-log-slower-than', '决定要对执行时间大于多少微秒的查询进行记录', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (52, 'redis', '3.2', 'EE', 'slowlog-max-len', '最多能保存多少条日志', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (53, 'redis', '3.2', 'EE', 'notify-keyspace-events', '通知客户端的事件类型', 'zh-CN', '');
INSERT INTO `engine_params` VALUES (54, 'redis', '3.2', 'EE', 'slowlog-log-slower-than', 'Determine how many microseconds of query execution time you want to record', 'en', '');
INSERT INTO `engine_params` VALUES (55, 'redis', '3.2', 'EE', 'slowlog-max-len', 'How many logs can be saved at most', 'en', '');
INSERT INTO `engine_params` VALUES (56, 'redis', '3.2', 'EE', 'notify-keyspace-events', 'Notifies the client of the event type', 'en', '');

-- ----------------------------
-- Table structure for instances
-- ----------------------------
DROP TABLE IF EXISTS `instances`;
CREATE TABLE `instances`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `instance_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '实例id',
  `instance_name` char(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '实例名称',
  `status` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '运行状态',
  `opt_status` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `ip` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT 'ip地址(单实例是ip，集群是vip)',
  `port` int(11) NOT NULL COMMENT '端口',
  `vpc_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `subnet_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '子网id',
  `security_group` char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '安全组标识',
  `pay_type` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '支付方式',
  `charge_type` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `product_category` char(64) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `engine` char(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '数据库类型',
  `node_count` tinyint(3) UNSIGNED NOT NULL DEFAULT 1 COMMENT '节点数目',
  `engine_version` char(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '数据库版本',
  `node_type` char(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '数据库部署方式',
  `uca_api_version` char(8) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '数据库服务版本',
  `instance_class` char(128) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '实例规格码',
  `flavor_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '主机规格id',
  `host_type` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '主机类型',
  `cpu` int(11) NOT NULL COMMENT 'cpu大小',
  `memory` int(11) NOT NULL COMMENT '内存大小',
  `sys_disk` int(11) NULL DEFAULT NULL COMMENT '系统盘',
  `data_disk_type` char(16) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '数据盘存储类型',
  `data_disk` int(11) NOT NULL COMMENT '数据盘大小',
  `region_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '地域id',
  `az_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '可用域id',
  `tenant_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '租户id',
  `user_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '用户id',
  `create_at` timestamp(0) NOT NULL COMMENT '创建实例的时间',
  `end_at` timestamp(0) NULL COMMENT '到期时间',
  `resize_at` timestamp(0) NULL DEFAULT NULL COMMENT '更改配置时间',
  `destroy_at` timestamp(0) NULL DEFAULT NULL COMMENT '释放资源时间',
  `record_start_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录创建时间',
  `record_update_at` timestamp(0) NULL COMMENT '记录更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 380 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for instances_status_scheduled
-- ----------------------------
DROP TABLE IF EXISTS `instances_status_scheduled`;
CREATE TABLE `instances_status_scheduled`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `instance_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '实例id',
  `engine` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '数据库类型',
  `order_id` bigint(20) NOT NULL COMMENT '订单id',
  `user_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户id',
  `region_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '地域id',
  `status` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '状态-是否需要查询',
  `opt_status` char(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `start_at` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '开始调度时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 347 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `request_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '请求id',
  `instance_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '实例id',
  `region_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `engine` char(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '数据库类型',
  `operate_type` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '操作类型',
  `user_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '用户id',
  `tenant_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '租户id',
  `status` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '操作状态',
  `start_at` timestamp(0) NOT NULL COMMENT '开始时间',
  `end_at` timestamp(0) NULL COMMENT '结束时间',
  `info_code` varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '错误码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1378 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_category_sku
-- ----------------------------
DROP TABLE IF EXISTS `product_category_sku`;
CREATE TABLE `product_category_sku`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `region_id` char(36) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '所属的cloudid',
  `sku` varchar(250) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `product_category` varchar(250) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '产品类型1、cpu和内存2、系统盘3、数据盘4、带宽',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_category_sku
-- ----------------------------
INSERT INTO `product_category_sku` VALUES (1, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSMONGODB_NORMAL', 'RDSMONGODB');
INSERT INTO `product_category_sku` VALUES (2, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSMONGODB_DATADISKHIGHIO', 'RDSMONGODB');
INSERT INTO `product_category_sku` VALUES (5, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSMONGODBMASTERSLAVE_NORMAL', 'RDSMONGODB');
INSERT INTO `product_category_sku` VALUES (6, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSMONGODBMASTERSLAVE_DATADISKHIGHIO', 'RDSMONGODB');
INSERT INTO `product_category_sku` VALUES (9, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSREDIS_NORMAL', 'RDSREDIS');
INSERT INTO `product_category_sku` VALUES (10, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSREDIS_DATADISKHIGHIO', 'RDSREDIS');
INSERT INTO `product_category_sku` VALUES (11, '71661ed7-545a-440b-9360-6fa87280e4d7', 'UNIS_PC_LF_A_RDSREDIS_CLUSTER', 'RDSREDIS');

-- ----------------------------
-- Table structure for restore_info
-- ----------------------------
DROP TABLE IF EXISTS `restore_info`;
CREATE TABLE `restore_info`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint(20) NULL DEFAULT NULL COMMENT '订单id',
  `backup_id` char(36) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备份id',
  `status` char(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '状态',
  `create_at` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_at` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for skuprice
-- ----------------------------
DROP TABLE IF EXISTS `skuprice`;
CREATE TABLE `skuprice`  (
  `id` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `product_sku` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `product_price` decimal(19, 2) NULL DEFAULT NULL,
  `product_category` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `node_type` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `region_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `sku_category` int(11) NULL DEFAULT NULL,
  `sku_type` int(11) NULL DEFAULT NULL,
  `cup_size` int(11) NULL DEFAULT NULL,
  `ram_size` int(11) NULL DEFAULT NULL,
  `disk_size` int(11) NULL DEFAULT NULL,
  `db_instance_class` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`, `product_sku`) USING BTREE,
  UNIQUE INDEX `product_sku`(`product_sku`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for system_params
-- ----------------------------
DROP TABLE IF EXISTS `system_params`;
CREATE TABLE `system_params`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键列',
  `param_key` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '参数',
  `param_value` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '参数值',
  `created_at` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `note` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_params
-- ----------------------------
INSERT INTO `system_params` VALUES (1, 'log-kafka-bootstrap-servers-cloudos-tj', '10.0.46.51:9092,10.0.46.51:9093,10.0.46.51:9094', '2019-09-28 13:43:09', '2019-09-28 13:43:09', NULL);
INSERT INTO `system_params` VALUES (2, 'log-kafka-bootstrap-servers-cloudos-lf', '10.0.46.51:9092,10.0.46.51:9093,10.0.46.51:9094', '2019-09-28 13:43:08', '2019-09-28 13:43:08', NULL);
INSERT INTO `system_params` VALUES (3, 'log-kafka-bootstrap-servers-cloudos-bj', '10.0.46.51:9092,10.0.46.51:9093,10.0.46.51:9094', '2019-09-28 13:42:42', '2019-09-28 13:42:42', NULL);
INSERT INTO `system_params` VALUES (4, 'log-kafka-autoOffsetReset', 'latest', '2019-08-21 11:09:20', '2019-08-21 11:09:20', NULL);
INSERT INTO `system_params` VALUES (5, 'log-kafka-enable-auto-commit', 'false', '2019-08-21 11:09:23', '2019-08-21 11:09:23', NULL);
INSERT INTO `system_params` VALUES (6, 'log-kafka-key-deserializer', 'org.apache.kafka.common.serialization.StringDeserializer', '2019-08-21 11:09:31', '2019-08-21 11:09:31', NULL);
INSERT INTO `system_params` VALUES (7, 'log-kafka-value-deserializer', 'org.apache.kafka.common.serialization.StringDeserializer', '2019-08-21 11:09:38', '2019-08-21 11:09:38', NULL);
INSERT INTO `system_params` VALUES (9, 'product-tenancies', '1,2,3,12,24,36', '2019-09-04 09:57:02', '2019-09-04 09:57:02', 'month');
INSERT INTO `system_params` VALUES (10, 'uca_api_version_cloudos-lf', '1.0', '2019-09-25 10:32:40', '2019-09-25 10:32:40', 'uca_api_version_*');
INSERT INTO `system_params` VALUES (11, 'uca_api_version_cloudos-tj', '1.0', '2019-09-25 10:55:12', '2019-09-25 10:55:12', 'uca_api_version_*');
INSERT INTO `system_params` VALUES (12, 'uca_api_version_cloudos-bj', '1.0', '2019-09-25 10:55:25', '2019-09-25 10:55:25', 'uca_api_version_*');
INSERT INTO `system_params` VALUES (13, 'oss_access_key_id', 'JswJZNaNU0v36ZUM', '2019-10-31 14:48:27', '2019-10-31 14:48:27', NULL);
INSERT INTO `system_params` VALUES (14, 'oss_secret_access_key', 'mxR2zU40K4RZudc5iBe28NxnRu5nBa', '2019-10-31 14:48:27', '2019-10-31 14:48:27', NULL);
INSERT INTO `system_params` VALUES (15, 'oss_end_point', 'https://oss-cn-north-1.unicloudsrv.com', '2019-09-29 15:20:52', '2019-09-29 15:20:52', NULL);
INSERT INTO `system_params` VALUES (16, 'oss_log_bucket_name', 'dbaas-log-test', '2019-10-18 15:13:50', '2019-10-18 15:13:50', NULL);

SET FOREIGN_KEY_CHECKS = 1;
