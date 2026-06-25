mysqldump: [Warning] Using a password on the command line interface can be insecure.
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: campusmarket
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `cmt_id` int NOT NULL AUTO_INCREMENT COMMENT '评论编号，自增主键',
  `post_id` int NOT NULL COMMENT '所属帖子编号',
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论者学号',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `cmt_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  PRIMARY KEY (`cmt_id`),
  KEY `idx_comments_post_id` (`post_id`) COMMENT '按帖子查评论',
  KEY `idx_comments_user_id` (`user_id`) COMMENT '按评论者查询',
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (1,1,'2021004','教材还在吗？我想买','2026-06-15 22:36:37'),(2,1,'2021001','还在的，私聊我','2026-06-15 22:36:37'),(3,3,'2021001','我也在找兼职，有合适的可以一起','2026-06-15 22:36:37'),(4,4,'2021005','已联系失主，感谢同学！','2026-06-15 22:36:37'),(5,5,'2021002','笔记能预览一下吗？','2026-06-15 22:36:37'),(6,2,'2021003','还有位置吗？我想拼车','2026-06-15 22:36:37'),(7,1,'2021002','高数教材还在吗？我想要','2026-06-18 22:48:20'),(8,1,'2021003','30元能便宜点吗','2026-06-18 22:48:20'),(9,5,'2021001','可以','2026-06-18 22:48:20'),(10,27,'1024005007','你好!','2026-06-18 22:52:59'),(11,32,'1024005006','我想!','2026-06-18 23:08:42'),(12,26,'2021001','我知道解庆老师的电话，私聊发你','2026-06-18 23:18:50'),(13,26,'2021004','解庆老师周二上午在教三楼有课，可以去堵','2026-06-18 23:18:50'),(14,26,'2021002','已私信，注意查收','2026-06-18 23:18:50'),(15,33,'1024005006','我我我!','2026-06-18 23:34:09'),(16,34,'1024005006','太有道理了!','2026-06-20 13:09:24'),(17,34,'1024005007','谢谢!','2026-06-20 13:09:39');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_insert_comment` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
    UPDATE posts
    SET comment_count = comment_count + 1,
        hot_score = view_count * 0.3 + (comment_count + 1) * 0.5 + like_count * 0.2
    WHERE post_id = NEW.post_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_delete_comment` AFTER DELETE ON `comments` FOR EACH ROW BEGIN
    UPDATE posts
    SET comment_count = comment_count - 1,
        hot_score = view_count * 0.3 + (comment_count - 1) * 0.5 + like_count * 0.2
    WHERE post_id = OLD.post_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorites` (
  `post_id` int NOT NULL COMMENT '帖子编号',
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收藏者学号',
  `fav_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`post_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`),
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES (1,'2021004','2026-06-15 22:36:37'),(5,'2021002','2026-06-15 22:36:37'),(9,'2021001','2026-06-15 22:36:37'),(32,'1024005006','2026-06-18 23:08:36'),(33,'1024005006','2026-06-18 23:34:14'),(33,'1024005007','2026-06-18 23:33:21'),(34,'1024005006','2026-06-20 13:09:16');
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `likes`
--

DROP TABLE IF EXISTS `likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `likes` (
  `post_id` int NOT NULL COMMENT '帖子编号',
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '点赞者学号',
  `like_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`post_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`),
  CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `likes`
--

LOCK TABLES `likes` WRITE;
/*!40000 ALTER TABLE `likes` DISABLE KEYS */;
INSERT INTO `likes` VALUES (1,'2021001','2026-06-18 22:00:16'),(1,'2021002','2026-06-18 22:00:16'),(1,'2021003','2026-06-15 22:36:37'),(1,'2021004','2026-06-15 22:36:37'),(3,'2021001','2026-06-15 22:36:37'),(3,'2021004','2026-06-15 22:36:37'),(4,'2021002','2026-06-15 22:36:37'),(4,'2021003','2026-06-15 22:36:37'),(4,'2021005','2026-06-15 22:36:37'),(5,'2021002','2026-06-15 22:36:37'),(9,'2021001','2026-06-15 22:36:37'),(9,'2021002','2026-06-15 22:36:37'),(9,'2021003','2026-06-15 22:36:37'),(9,'2021004','2026-06-15 22:36:37'),(27,'1024005007','2026-06-18 22:53:38'),(28,'1024005007','2026-06-18 22:53:19'),(32,'1024005006','2026-06-18 23:08:35'),(32,'1024005007','2026-06-18 23:07:08'),(33,'1024005006','2026-06-18 23:34:12'),(33,'1024005007','2026-06-18 23:33:22'),(34,'1024005006','2026-06-20 13:09:17');
/*!40000 ALTER TABLE `likes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_insert_like` AFTER INSERT ON `likes` FOR EACH ROW BEGIN
    UPDATE posts
    SET like_count = like_count + 1,
        hot_score = view_count * 0.3 + comment_count * 0.5 + (like_count + 1) * 0.2
    WHERE post_id = NEW.post_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_delete_like` AFTER DELETE ON `likes` FOR EACH ROW BEGIN
    UPDATE posts
    SET like_count = like_count - 1,
        hot_score = view_count * 0.3 + comment_count * 0.5 + (like_count - 1) * 0.2
    WHERE post_id = OLD.post_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `post_log`
--

DROP TABLE IF EXISTS `post_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int DEFAULT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'DELETE',
  `deleted_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_log`
--

LOCK TABLES `post_log` WRITE;
/*!40000 ALTER TABLE `post_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_views`
--

DROP TABLE IF EXISTS `post_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_views` (
  `post_id` int NOT NULL,
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `view_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`,`user_id`),
  CONSTRAINT `post_views_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_views`
--

LOCK TABLES `post_views` WRITE;
/*!40000 ALTER TABLE `post_views` DISABLE KEYS */;
INSERT INTO `post_views` VALUES (9,'1024005007','2026-06-20 13:14:38'),(27,'1024005007','2026-06-18 23:33:32'),(32,'1024005006','2026-06-18 23:29:17'),(32,'1024005007','2026-06-18 23:29:41'),(33,'1024005006','2026-06-18 23:33:55'),(33,'1024005007','2026-06-18 23:33:20'),(34,'1024005006','2026-06-20 13:09:05'),(34,'1024005007','2026-06-20 13:08:52');
/*!40000 ALTER TABLE `post_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `post_id` int NOT NULL AUTO_INCREMENT COMMENT '帖子编号，自增主键',
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '发布者学号',
  `sec_id` int NOT NULL COMMENT '所属板块编号',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子标题',
  `content` text COLLATE utf8mb4_unicode_ci COMMENT '帖子正文内容',
  `contact` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系方式',
  `red_amount` decimal(10,2) DEFAULT NULL,
  `red_remaining` decimal(10,2) DEFAULT NULL,
  `pub_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `status` enum('正常','已结束','已删除') COLLATE utf8mb4_unicode_ci DEFAULT '正常' COMMENT '帖子状态',
  `view_count` int DEFAULT '0' COMMENT '浏览量',
  `like_count` int DEFAULT '0' COMMENT '点赞数（冗余字段，用于热度计算）',
  `comment_count` int DEFAULT '0' COMMENT '评论数（冗余字段，用于热度计算）',
  `hot_score` decimal(10,4) DEFAULT '0.0000' COMMENT '热度值，公式：view_count*0.3 + comment_count*0.5 + like_count*0.2',
  PRIMARY KEY (`post_id`),
  KEY `idx_posts_user_id` (`user_id`) COMMENT '按发布者查询',
  KEY `idx_posts_sec_id` (`sec_id`) COMMENT '按板块查询',
  KEY `idx_posts_status` (`status`) COMMENT '按状态筛选',
  KEY `idx_posts_pub_time` (`pub_time`) COMMENT '按发布时间排序',
  KEY `idx_posts_hot_score` (`hot_score` DESC) COMMENT '按热度排序（降序）',
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`sec_id`) REFERENCES `sections` (`sec_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
INSERT INTO `posts` VALUES (1,'2021001',9,'出二手高数教材，九成新','大一下学期的高等数学教材，几乎全新，有笔记，30元出','QQ:123456',NULL,NULL,'2026-06-15 22:36:37','正常',120,4,4,39.3000),(2,'2021002',4,'周五拼车去武汉站','周五下午3点南湖出发去武汉站，还有3个位置，每人15','微信:lisi2021',NULL,NULL,'2026-06-15 22:36:37','正常',85,0,1,26.0000),(3,'2021003',8,'找周末兼职，校内优先','大二学生，周六日有时间，希望能找校内兼职，工资面议','电话:13800001003',NULL,NULL,'2026-06-15 22:36:37','正常',200,2,1,60.9000),(4,'2021001',5,'捡到一张校园卡','在图书馆三楼捡到校园卡，学号2021008，请失主联系','QQ:123456',NULL,NULL,'2026-06-15 22:36:37','正常',300,3,1,91.1000),(5,'2021004',3,'计算机组成原理复习笔记','自己整理的计组复习笔记，涵盖所有考点，5元一份电子版','微信:zhaoliu2021',NULL,NULL,'2026-06-15 22:36:37','正常',150,1,2,46.7000),(6,'2021002',9,'出售二手电动车','骑了一年的电动车，电池还很好，800元出，可看车','电话:13800001002',NULL,NULL,'2026-06-15 22:36:37','正常',90,0,0,27.0000),(7,'2021003',5,'求推荐校内打印店','哪家打印店价格实惠？求学长学姐推荐','直接回复即可',NULL,NULL,'2026-06-15 22:36:37','正常',45,0,0,13.5000),(8,'2021004',9,'出四级真题卷','2024年四级真题卷，全新未做，20元带走','微信:zhaoliu2021',NULL,NULL,'2026-06-15 22:36:37','已结束',60,0,0,0.0000),(9,'2021005',1,'【管理员】失物招领规范','请发布失物招领时注明物品特征、丢失地点和联系方式','-',NULL,NULL,'2026-06-15 22:36:37','正常',511,4,0,153.0000),(26,'2021003',2,'在线求解庆老师联系方式','有没有人知道xq老师电话，急求！红包200元酬谢','微信:wangwu_2021',200.00,200.00,'2026-06-16 10:00:00','正常',154,3,7,50.5000),(27,'2021001',3,'解庆老师的课必须吹一波','解庆老师讲课深入浅出，给分也良心，这学期多亏了老师，强烈推荐！评分10.0','直接回复即可',NULL,NULL,'2026-06-16 10:00:00','正常',193,6,3,59.9000),(28,'2021002',4,'拿快递','有没有同学代领在菜鸟驿站的快递，东西有点重一个人不好拿，红包100元','微信:lisi2021',100.00,100.00,'2026-06-16 10:00:00','正常',62,2,1,19.4000),(29,'2021004',5,'南湖食堂二楼现在开了哪些窗口','好久没去二楼了，想吃麻辣香锅不知道还开着没，求告知','直接回复即可',NULL,NULL,'2026-06-16 10:00:00','正常',35,0,0,10.5000),(30,'2021005',6,'周末南湖组局打羽毛球','周末下午南湖操场打羽毛球，找搭子一起，男女不限，来的私我','QQ:999999',NULL,NULL,'2026-06-16 10:00:00','正常',81,2,3,30.2000),(31,'2021001',7,'在图书馆遇到一只橘猫','今天去图书馆发现一只橘猫趴在空调下面乘凉，太会挑了，看到的人都笑了','直接回复即可',NULL,NULL,'2026-06-16 10:00:00','正常',221,6,5,78.6000),(32,'1024005007',2,'交朋友','有没有同学想和我交朋友\n\n[红包 100 元]','3364534205@qq.com',50.00,0.00,'2026-06-18 23:07:03','已结束',21,2,1,2.3000),(33,'1024005007',2,'代课','能不能帮我代实验课?\n\n[红包 10.0 元]','3364534205@qq.com',10.00,8.00,'2026-06-18 23:33:17','正常',2,2,1,1.7000),(34,'1024005007',1,'不要占座!','请各位同学自觉遵守规定,不要长时间占座,谢谢!','',NULL,NULL,'2026-06-20 13:08:48','正常',2,1,2,2.3000);
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_post_delete` BEFORE DELETE ON `posts` FOR EACH ROW BEGIN
    INSERT INTO post_log(post_id, title, user_id) VALUES (OLD.post_id, OLD.title, OLD.user_id);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `red_distribution`
--

DROP TABLE IF EXISTS `red_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `red_distribution` (
  `dist_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `from_user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `to_user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `dist_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dist_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `red_distribution_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `red_distribution`
--

LOCK TABLES `red_distribution` WRITE;
/*!40000 ALTER TABLE `red_distribution` DISABLE KEYS */;
INSERT INTO `red_distribution` VALUES (1,32,'1024005007','1024005006',50.00,'2026-06-18 23:24:13'),(2,33,'1024005007','1024005006',2.00,'2026-06-18 23:34:43');
/*!40000 ALTER TABLE `red_distribution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `rp_id` int NOT NULL AUTO_INCREMENT COMMENT '举报编号，自增主键',
  `post_id` int NOT NULL COMMENT '被举报帖子编号',
  `reporter_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报者学号',
  `reason` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报原因',
  `status` enum('待处理','已处理','驳回') COLLATE utf8mb4_unicode_ci DEFAULT '待处理' COMMENT '处理状态',
  `report_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '举报时间',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `handle_note` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '处理备注',
  PRIMARY KEY (`rp_id`),
  KEY `reporter_id` (`reporter_id`),
  KEY `idx_reports_post_id` (`post_id`) COMMENT '按被举报帖子查',
  KEY `idx_reports_status` (`status`) COMMENT '按处理状态查',
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`),
  CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='举报表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1,6,'2021001','价格虚高，与实际不符','待处理','2026-06-15 22:36:37',NULL,NULL),(2,9,'1024005007','违规内容','待处理','2026-06-18 22:32:36',NULL,NULL);
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sections` (
  `sec_id` int NOT NULL AUTO_INCREMENT COMMENT '板块编号，自增主键',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '板块名称',
  `description` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '板块描述',
  `sort_order` int DEFAULT '0' COMMENT '排序序号',
  PRIMARY KEY (`sec_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='板块表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES (1,'集市24小时火文','每日热门帖子汇总',1),(2,'红包帖','带红包奖励的帖子',2),(3,'课程评价','课程评分与学习心得',3),(4,'跑腿代办','校园跑腿服务需求',4),(5,'打听求助','校园生活问题咨询',5),(6,'恋爱交友','交友找搭子',6),(7,'校园趣事','校园生活趣事分享',7),(8,'兼职招聘','校园寻找工作',8),(9,'二手闲置','校园二手交易',9);
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学号，主键',
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户昵称',
  `wechat_openid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信OpenID，唯一',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
  `reg_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `status` enum('正常','禁言') COLLATE utf8mb4_unicode_ci DEFAULT '正常' COMMENT '用户状态',
  `role` enum('普通','管理员') COLLATE utf8mb4_unicode_ci DEFAULT '普通' COMMENT '用户角色',
  `exp` int DEFAULT '0',
  `red_balance` decimal(10,2) DEFAULT '0.00',
  `red_sent` decimal(10,2) DEFAULT '0.00',
  `red_received` decimal(10,2) DEFAULT '0.00',
  `level` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT '小学生',
  `school` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '武汉理工大学',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `wechat_openid` (`wechat_openid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('1024005005','123',NULL,'','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',NULL,'2026-06-20 11:39:08','正常','普通',0,0.00,0.00,0.00,'小学生','武汉理工大学',NULL),('1024005006','1234',NULL,'','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',NULL,'2026-06-18 23:08:02','正常','普通',0,52.00,0.00,52.00,'小学生','武汉理工大学',NULL),('1024005007','shangran',NULL,'13317503976','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',NULL,'2026-06-18 22:07:28','正常','普通',0,40.00,60.00,0.00,'小学生','武汉理工大学','/static/uploads/avatar_1024005007.jpg'),('2021001','张三','wx_openid_001','13800001001','1ec5191ecabebe304d2b78230942b3a2a299be17425c618fdf672d77289e7e5e',NULL,'2026-06-15 22:36:37','正常','普通',520,50.00,20.00,5.00,'大学生','武汉理工大学',NULL),('2021002','李四','wx_openid_002','13800001002','bcfef4969df32d5da59db6398f8cf440359a80e5dc9b1572366967d41f5c1ef5',NULL,'2026-06-15 22:36:37','正常','普通',200,30.00,0.00,15.00,'高中生','武汉理工大学',NULL),('2021003','王五','wx_openid_003','13800001003','14d5865624d63428b328cc98b0c74896920dea317dca8885ee78c4975c00c1b0',NULL,'2026-06-15 22:36:37','正常','普通',80,100.00,50.00,60.00,'初中生','武汉理工大学',NULL),('2021004','赵六','wx_openid_004','13800001004','a1655dc2a229fe0639cab290976a87090287048e1bf5b52571ce4dcce4ca220e',NULL,'2026-06-15 22:36:37','正常','普通',30,10.00,0.00,0.00,'小学生','武汉理工大学',NULL),('2021005','管理员小陈','wx_openid_005','13800001005','0fcba3f42698aa58cc0b7a0a4c8bbd4a7d75f7dede8bc022c0ca2125437a814a',NULL,'2026-06-15 22:36:37','正常','管理员',999,200.00,80.00,120.00,'博士','武汉理工大学',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'campusmarket'
--

--
-- Dumping routines for database 'campusmarket'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-20 14:05:11
