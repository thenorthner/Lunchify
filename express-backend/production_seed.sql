-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for osx10.10 (x86_64)
--
-- Host: localhost    Database: lunch_app
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `canteens`
--

DROP TABLE IF EXISTS `canteens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `canteens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `open_time` time DEFAULT '07:00:00',
  `close_time` time DEFAULT '22:00:00',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `canteens_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canteens`
--

LOCK TABLES `canteens` WRITE;
/*!40000 ALTER TABLE `canteens` DISABLE KEYS */;
INSERT INTO `canteens` VALUES (1,1,'Shimla HQ Canteen','HQ Main Block',1,'07:00:00','22:00:00','2026-06-02 07:40:54'),(2,2,'Rampur Executive Canteen','Rampur Block A',1,'07:00:00','22:00:00','2026-06-02 07:40:54'),(3,3,'Nathpa Canteen','Nathpa Main Gate',1,'07:00:00','22:00:00','2026-06-02 07:40:54'),(4,1,'Dummy Canteen','Dummy',1,'07:00:00','22:00:00','2026-07-08 10:16:37');
/*!40000 ALTER TABLE `canteens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_rates`
--

DROP TABLE IF EXISTS `coupon_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupon_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `canteen_id` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `coupon_rates_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_rates`
--

LOCK TABLES `coupon_rates` WRITE;
/*!40000 ALTER TABLE `coupon_rates` DISABLE KEYS */;
INSERT INTO `coupon_rates` VALUES (1,1,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(2,2,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(3,3,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(4,4,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(5,5,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(6,6,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(7,7,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(8,8,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(9,9,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(10,10,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(11,11,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(12,12,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(13,13,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(14,14,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(15,15,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(16,16,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(17,17,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(18,18,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(19,19,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(20,20,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(21,21,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(22,22,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20'),(23,23,50.00,'2023-01-01',NULL,'2026-07-02 10:09:20','2026-07-02 10:09:20');
/*!40000 ALTER TABLE `coupon_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_shares`
--

DROP TABLE IF EXISTS `coupon_shares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupon_shares` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` varchar(255) NOT NULL,
  `receiver_id` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `shared_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_shares`
--

LOCK TABLES `coupon_shares` WRITE;
/*!40000 ALTER TABLE `coupon_shares` DISABLE KEYS */;
INSERT INTO `coupon_shares` VALUES (1,'30609','30612',2,'2026-07-02 11:18:18'),(2,'30609','30210',2,'2026-07-02 12:02:19'),(3,'30609','30210',1,'2026-07-03 10:10:02'),(4,'30609','30210',1,'2026-07-03 11:19:33');
/*!40000 ALTER TABLE `coupon_shares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_item_feedbacks`
--

DROP TABLE IF EXISTS `daily_item_feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `daily_item_feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `canteen_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `rating` int(11) NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `emp_date_item` (`employee_id`,`date`,`item_name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_item_feedbacks`
--

LOCK TABLES `daily_item_feedbacks` WRITE;
/*!40000 ALTER TABLE `daily_item_feedbacks` DISABLE KEYS */;
INSERT INTO `daily_item_feedbacks` VALUES (1,'30609',4,'2026-07-03','tarbooj',4,'','2026-07-03 11:24:01'),(2,'30609',4,'2026-07-03','aam',5,'','2026-07-03 11:24:01'),(3,'30609',4,'2026-07-06','{name: Apple, type: veg}',4,'','2026-07-06 06:45:59'),(4,'30609',4,'2026-07-06','{name: Banana, type: veg}',3,'','2026-07-06 06:45:59'),(5,'30609',4,'2026-07-06','{name: Grapes, type: veg}',5,'','2026-07-06 06:45:59'),(6,'30609',4,'2026-07-06','Paneer Butter Masala',3,'','2026-07-06 10:47:41'),(7,'30609',4,'2026-07-06','Dal Makhani',5,'','2026-07-06 10:47:41'),(8,'30609',4,'2026-07-06','Jeera Rice',4,'','2026-07-06 10:47:41'),(9,'30609',4,'2026-07-06','Butter Naan',4,'','2026-07-06 10:47:41'),(10,'30609',4,'2026-07-06','Gulab Jamun',2,'maza aa gaya','2026-07-06 10:47:41'),(11,'30609',4,'2026-07-06','Apple',2,'','2026-07-06 10:48:19'),(12,'30609',4,'2026-07-06','Banana',5,'','2026-07-06 10:48:19'),(13,'30609',4,'2026-07-06','Grapes',3,'','2026-07-06 10:48:19');
/*!40000 ALTER TABLE `daily_item_feedbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedbacks`
--

DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `canteen_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `rating` int(11) DEFAULT 5,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `feedbacks_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedbacks_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedbacks`
--

LOCK TABLES `feedbacks` WRITE;
/*!40000 ALTER TABLE `feedbacks` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_lunch_orders`
--

DROP TABLE IF EXISTS `food_lunch_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `food_lunch_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `order_type` varchar(50) DEFAULT NULL,
  `room_number` varchar(50) DEFAULT NULL,
  `delivery_time` time DEFAULT NULL,
  `date` date NOT NULL,
  `status` enum('pending','accepted','rejected','delivered','cancelled') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `delivered_at` timestamp NULL DEFAULT NULL,
  `canteen_id` int(11) DEFAULT 1,
  `project_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `canteen_id` (`canteen_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `food_lunch_orders_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `food_lunch_orders_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`),
  CONSTRAINT `food_lunch_orders_ibfk_3` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_lunch_orders`
--

LOCK TABLES `food_lunch_orders` WRITE;
/*!40000 ALTER TABLE `food_lunch_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `food_lunch_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_lunch_qr_tokens`
--

DROP TABLE IF EXISTS `food_lunch_qr_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `food_lunch_qr_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) DEFAULT NULL,
  `employee_id` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_lunch_qr_tokens`
--

LOCK TABLES `food_lunch_qr_tokens` WRITE;
/*!40000 ALTER TABLE `food_lunch_qr_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `food_lunch_qr_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_menu`
--

DROP TABLE IF EXISTS `food_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `food_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_date` date NOT NULL,
  `items` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `food_menu_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_menu`
--

LOCK TABLES `food_menu` WRITE;
/*!40000 ALTER TABLE `food_menu` DISABLE KEYS */;
INSERT INTO `food_menu` VALUES (9,'2026-07-06','[{\"name\": \"Paneer Butter Masala\", \"type\": \"veg\"}, {\"name\": \"Dal Makhani\", \"type\": \"veg\"}, {\"name\": \"Jeera Rice\", \"type\": \"veg\"}, {\"name\": \"Butter Naan\", \"type\": \"veg\"}, {\"name\": \"Gulab Jamun\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(10,'2026-07-06','[{\"name\": \"Paneer Butter Masala\", \"type\": \"veg\"}, {\"name\": \"Dal Makhani\", \"type\": \"veg\"}, {\"name\": \"Jeera Rice\", \"type\": \"veg\"}, {\"name\": \"Butter Naan\", \"type\": \"veg\"}, {\"name\": \"Gulab Jamun\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(11,'2026-07-06','[{\"name\": \"Paneer Butter Masala\", \"type\": \"veg\"}, {\"name\": \"Dal Makhani\", \"type\": \"veg\"}, {\"name\": \"Jeera Rice\", \"type\": \"veg\"}, {\"name\": \"Butter Naan\", \"type\": \"veg\"}, {\"name\": \"Gulab Jamun\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(12,'2026-07-06','[{\"name\": \"Paneer Butter Masala\", \"type\": \"veg\"}, {\"name\": \"Dal Makhani\", \"type\": \"veg\"}, {\"name\": \"Jeera Rice\", \"type\": \"veg\"}, {\"name\": \"Butter Naan\", \"type\": \"veg\"}, {\"name\": \"Gulab Jamun\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(13,'2026-07-07','[{\"name\": \"Chicken Tikka Masala\", \"type\": \"non-veg\"}, {\"name\": \"Mix Veg Curry\", \"type\": \"veg\"}, {\"name\": \"Veg Pulao\", \"type\": \"veg\"}, {\"name\": \"Tandoori Roti\", \"type\": \"veg\"}, {\"name\": \"Rasgulla\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(14,'2026-07-07','[{\"name\": \"Chicken Tikka Masala\", \"type\": \"non-veg\"}, {\"name\": \"Mix Veg Curry\", \"type\": \"veg\"}, {\"name\": \"Veg Pulao\", \"type\": \"veg\"}, {\"name\": \"Tandoori Roti\", \"type\": \"veg\"}, {\"name\": \"Rasgulla\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(15,'2026-07-07','[{\"name\": \"Chicken Tikka Masala\", \"type\": \"non-veg\"}, {\"name\": \"Mix Veg Curry\", \"type\": \"veg\"}, {\"name\": \"Veg Pulao\", \"type\": \"veg\"}, {\"name\": \"Tandoori Roti\", \"type\": \"veg\"}, {\"name\": \"Rasgulla\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(16,'2026-07-07','[{\"name\": \"Chicken Tikka Masala\", \"type\": \"non-veg\"}, {\"name\": \"Mix Veg Curry\", \"type\": \"veg\"}, {\"name\": \"Veg Pulao\", \"type\": \"veg\"}, {\"name\": \"Tandoori Roti\", \"type\": \"veg\"}, {\"name\": \"Rasgulla\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(17,'2026-07-08','[{\"name\": \"Chole Bhature\", \"type\": \"veg\"}, {\"name\": \"Aloo Gobi\", \"type\": \"veg\"}, {\"name\": \"Boondi Raita\", \"type\": \"veg\"}, {\"name\": \"Papad\", \"type\": \"veg\"}, {\"name\": \"Gajar Halwa\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(18,'2026-07-08','[{\"name\": \"Chole Bhature\", \"type\": \"veg\"}, {\"name\": \"Aloo Gobi\", \"type\": \"veg\"}, {\"name\": \"Boondi Raita\", \"type\": \"veg\"}, {\"name\": \"Papad\", \"type\": \"veg\"}, {\"name\": \"Gajar Halwa\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(19,'2026-07-08','[{\"name\": \"Chole Bhature\", \"type\": \"veg\"}, {\"name\": \"Aloo Gobi\", \"type\": \"veg\"}, {\"name\": \"Boondi Raita\", \"type\": \"veg\"}, {\"name\": \"Papad\", \"type\": \"veg\"}, {\"name\": \"Gajar Halwa\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(20,'2026-07-08','[{\"name\": \"Chole Bhature\", \"type\": \"veg\"}, {\"name\": \"Aloo Gobi\", \"type\": \"veg\"}, {\"name\": \"Boondi Raita\", \"type\": \"veg\"}, {\"name\": \"Papad\", \"type\": \"veg\"}, {\"name\": \"Gajar Halwa\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(21,'2026-07-09','[{\"name\": \"Mutton Biryani\", \"type\": \"non-veg\"}, {\"name\": \"Mirchi Ka Salan\", \"type\": \"veg\"}, {\"name\": \"Raita\", \"type\": \"veg\"}, {\"name\": \"Double Ka Meetha\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(22,'2026-07-09','[{\"name\": \"Mutton Biryani\", \"type\": \"non-veg\"}, {\"name\": \"Mirchi Ka Salan\", \"type\": \"veg\"}, {\"name\": \"Raita\", \"type\": \"veg\"}, {\"name\": \"Double Ka Meetha\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(23,'2026-07-09','[{\"name\": \"Mutton Biryani\", \"type\": \"non-veg\"}, {\"name\": \"Mirchi Ka Salan\", \"type\": \"veg\"}, {\"name\": \"Raita\", \"type\": \"veg\"}, {\"name\": \"Double Ka Meetha\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(24,'2026-07-09','[{\"name\": \"Mutton Biryani\", \"type\": \"non-veg\"}, {\"name\": \"Mirchi Ka Salan\", \"type\": \"veg\"}, {\"name\": \"Raita\", \"type\": \"veg\"}, {\"name\": \"Double Ka Meetha\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(25,'2026-07-10','[{\"name\": \"Palak Paneer\", \"type\": \"veg\"}, {\"name\": \"Dal Tadka\", \"type\": \"veg\"}, {\"name\": \"Steamed Rice\", \"type\": \"veg\"}, {\"name\": \"Chapati\", \"type\": \"veg\"}, {\"name\": \"Ice Cream\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(26,'2026-07-10','[{\"name\": \"Palak Paneer\", \"type\": \"veg\"}, {\"name\": \"Dal Tadka\", \"type\": \"veg\"}, {\"name\": \"Steamed Rice\", \"type\": \"veg\"}, {\"name\": \"Chapati\", \"type\": \"veg\"}, {\"name\": \"Ice Cream\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(27,'2026-07-10','[{\"name\": \"Palak Paneer\", \"type\": \"veg\"}, {\"name\": \"Dal Tadka\", \"type\": \"veg\"}, {\"name\": \"Steamed Rice\", \"type\": \"veg\"}, {\"name\": \"Chapati\", \"type\": \"veg\"}, {\"name\": \"Ice Cream\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(28,'2026-07-10','[{\"name\": \"Palak Paneer\", \"type\": \"veg\"}, {\"name\": \"Dal Tadka\", \"type\": \"veg\"}, {\"name\": \"Steamed Rice\", \"type\": \"veg\"}, {\"name\": \"Chapati\", \"type\": \"veg\"}, {\"name\": \"Ice Cream\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(29,'2026-07-11','[{\"name\": \"Rajma Chawal\", \"type\": \"veg\"}, {\"name\": \"Bhindi Masala\", \"type\": \"veg\"}, {\"name\": \"Green Salad\", \"type\": \"veg\"}, {\"name\": \"Kheer\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(30,'2026-07-11','[{\"name\": \"Rajma Chawal\", \"type\": \"veg\"}, {\"name\": \"Bhindi Masala\", \"type\": \"veg\"}, {\"name\": \"Green Salad\", \"type\": \"veg\"}, {\"name\": \"Kheer\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(31,'2026-07-11','[{\"name\": \"Rajma Chawal\", \"type\": \"veg\"}, {\"name\": \"Bhindi Masala\", \"type\": \"veg\"}, {\"name\": \"Green Salad\", \"type\": \"veg\"}, {\"name\": \"Kheer\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(32,'2026-07-11','[{\"name\": \"Rajma Chawal\", \"type\": \"veg\"}, {\"name\": \"Bhindi Masala\", \"type\": \"veg\"}, {\"name\": \"Green Salad\", \"type\": \"veg\"}, {\"name\": \"Kheer\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(33,'2026-07-12','[{\"name\": \"Special Veg Thali\", \"type\": \"veg\"}, {\"name\": \"Kadai Paneer\", \"type\": \"veg\"}, {\"name\": \"Malai Kofta\", \"type\": \"veg\"}, {\"name\": \"Butter Roti\", \"type\": \"veg\"}, {\"name\": \"Jalebi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(34,'2026-07-12','[{\"name\": \"Special Veg Thali\", \"type\": \"veg\"}, {\"name\": \"Kadai Paneer\", \"type\": \"veg\"}, {\"name\": \"Malai Kofta\", \"type\": \"veg\"}, {\"name\": \"Butter Roti\", \"type\": \"veg\"}, {\"name\": \"Jalebi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(35,'2026-07-12','[{\"name\": \"Special Veg Thali\", \"type\": \"veg\"}, {\"name\": \"Kadai Paneer\", \"type\": \"veg\"}, {\"name\": \"Malai Kofta\", \"type\": \"veg\"}, {\"name\": \"Butter Roti\", \"type\": \"veg\"}, {\"name\": \"Jalebi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(36,'2026-07-12','[{\"name\": \"Special Veg Thali\", \"type\": \"veg\"}, {\"name\": \"Kadai Paneer\", \"type\": \"veg\"}, {\"name\": \"Malai Kofta\", \"type\": \"veg\"}, {\"name\": \"Butter Roti\", \"type\": \"veg\"}, {\"name\": \"Jalebi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4);
/*!40000 ALTER TABLE `food_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fruit_lunch_orders`
--

DROP TABLE IF EXISTS `fruit_lunch_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fruit_lunch_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `order_type` varchar(50) DEFAULT NULL,
  `room_number` varchar(50) DEFAULT NULL,
  `delivery_time` time DEFAULT NULL,
  `date` date NOT NULL,
  `status` enum('pending','accepted','rejected','delivered','cancelled') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `delivered_at` timestamp NULL DEFAULT NULL,
  `canteen_id` int(11) DEFAULT 1,
  `project_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `canteen_id` (`canteen_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `fruit_lunch_orders_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fruit_lunch_orders_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`),
  CONSTRAINT `fruit_lunch_orders_ibfk_3` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fruit_lunch_orders`
--

LOCK TABLES `fruit_lunch_orders` WRITE;
/*!40000 ALTER TABLE `fruit_lunch_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `fruit_lunch_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fruit_menu`
--

DROP TABLE IF EXISTS `fruit_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fruit_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_date` date NOT NULL,
  `fruits` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `fruit_menu_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fruit_menu`
--

LOCK TABLES `fruit_menu` WRITE;
/*!40000 ALTER TABLE `fruit_menu` DISABLE KEYS */;
INSERT INTO `fruit_menu` VALUES (7,'2026-07-06','[{\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}, {\"name\": \"Grapes\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(8,'2026-07-06','[{\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}, {\"name\": \"Grapes\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(9,'2026-07-06','[{\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}, {\"name\": \"Grapes\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(10,'2026-07-06','[{\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}, {\"name\": \"Grapes\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(11,'2026-07-07','[{\"name\": \"Watermelon\", \"type\": \"veg\"}, {\"name\": \"Papaya\", \"type\": \"veg\"}, {\"name\": \"Pineapple\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(12,'2026-07-07','[{\"name\": \"Watermelon\", \"type\": \"veg\"}, {\"name\": \"Papaya\", \"type\": \"veg\"}, {\"name\": \"Pineapple\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(13,'2026-07-07','[{\"name\": \"Watermelon\", \"type\": \"veg\"}, {\"name\": \"Papaya\", \"type\": \"veg\"}, {\"name\": \"Pineapple\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(14,'2026-07-07','[{\"name\": \"Watermelon\", \"type\": \"veg\"}, {\"name\": \"Papaya\", \"type\": \"veg\"}, {\"name\": \"Pineapple\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(15,'2026-07-08','[{\"name\": \"Mango\", \"type\": \"veg\"}, {\"name\": \"Pomegranate\", \"type\": \"veg\"}, {\"name\": \"Guava\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(16,'2026-07-08','[{\"name\": \"Mango\", \"type\": \"veg\"}, {\"name\": \"Pomegranate\", \"type\": \"veg\"}, {\"name\": \"Guava\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(17,'2026-07-08','[{\"name\": \"Mango\", \"type\": \"veg\"}, {\"name\": \"Pomegranate\", \"type\": \"veg\"}, {\"name\": \"Guava\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(18,'2026-07-08','[{\"name\": \"Mango\", \"type\": \"veg\"}, {\"name\": \"Pomegranate\", \"type\": \"veg\"}, {\"name\": \"Guava\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(19,'2026-07-09','[{\"name\": \"Orange\", \"type\": \"veg\"}, {\"name\": \"Sweet Lime\", \"type\": \"veg\"}, {\"name\": \"Kiwi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(20,'2026-07-09','[{\"name\": \"Orange\", \"type\": \"veg\"}, {\"name\": \"Sweet Lime\", \"type\": \"veg\"}, {\"name\": \"Kiwi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(21,'2026-07-09','[{\"name\": \"Orange\", \"type\": \"veg\"}, {\"name\": \"Sweet Lime\", \"type\": \"veg\"}, {\"name\": \"Kiwi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(22,'2026-07-09','[{\"name\": \"Orange\", \"type\": \"veg\"}, {\"name\": \"Sweet Lime\", \"type\": \"veg\"}, {\"name\": \"Kiwi\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(23,'2026-07-10','[{\"name\": \"Dragon Fruit\", \"type\": \"veg\"}, {\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(24,'2026-07-10','[{\"name\": \"Dragon Fruit\", \"type\": \"veg\"}, {\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(25,'2026-07-10','[{\"name\": \"Dragon Fruit\", \"type\": \"veg\"}, {\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(26,'2026-07-10','[{\"name\": \"Dragon Fruit\", \"type\": \"veg\"}, {\"name\": \"Apple\", \"type\": \"veg\"}, {\"name\": \"Banana\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(27,'2026-07-11','[{\"name\": \"Strawberry\", \"type\": \"veg\"}, {\"name\": \"Blueberry\", \"type\": \"veg\"}, {\"name\": \"Pear\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(28,'2026-07-11','[{\"name\": \"Strawberry\", \"type\": \"veg\"}, {\"name\": \"Blueberry\", \"type\": \"veg\"}, {\"name\": \"Pear\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(29,'2026-07-11','[{\"name\": \"Strawberry\", \"type\": \"veg\"}, {\"name\": \"Blueberry\", \"type\": \"veg\"}, {\"name\": \"Pear\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(30,'2026-07-11','[{\"name\": \"Strawberry\", \"type\": \"veg\"}, {\"name\": \"Blueberry\", \"type\": \"veg\"}, {\"name\": \"Pear\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4),(31,'2026-07-12','[{\"name\": \"Mixed Fruit Bowl\", \"type\": \"veg\"}]','2026-07-08 10:16:37',1),(32,'2026-07-12','[{\"name\": \"Mixed Fruit Bowl\", \"type\": \"veg\"}]','2026-07-08 10:16:37',2),(33,'2026-07-12','[{\"name\": \"Mixed Fruit Bowl\", \"type\": \"veg\"}]','2026-07-08 10:16:37',3),(34,'2026-07-12','[{\"name\": \"Mixed Fruit Bowl\", \"type\": \"veg\"}]','2026-07-08 10:16:37',4);
/*!40000 ALTER TABLE `fruit_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lunch_logs`
--

DROP TABLE IF EXISTS `lunch_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lunch_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) DEFAULT NULL,
  `scan_time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lunch_logs`
--

LOCK TABLES `lunch_logs` WRITE;
/*!40000 ALTER TABLE `lunch_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `lunch_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `lunch_type` varchar(50) DEFAULT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `date` (`date`,`lunch_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monthly_bills`
--

DROP TABLE IF EXISTS `monthly_bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monthly_bills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) DEFAULT NULL,
  `canteen_id` int(11) DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `bill_month` varchar(7) NOT NULL,
  `total_coupons_used` int(11) NOT NULL DEFAULT 0,
  `coupon_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','submitted','approved','rejected') DEFAULT 'submitted',
  `generated_at` timestamp NULL DEFAULT current_timestamp(),
  `place_generated` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `monthly_bills_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `monthly_bills_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monthly_bills`
--

LOCK TABLES `monthly_bills` WRITE;
/*!40000 ALTER TABLE `monthly_bills` DISABLE KEYS */;
/*!40000 ALTER TABLE `monthly_bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_verifications`
--

DROP TABLE IF EXISTS `otp_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otp_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) DEFAULT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `otp_code` varchar(10) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_verifications`
--

LOCK TABLES `otp_verifications` WRITE;
/*!40000 ALTER TABLE `otp_verifications` DISABLE KEYS */;
INSERT INTO `otp_verifications` VALUES (1,'30609','7014634410','428677','2026-07-06 12:16:28','2026-07-06 06:41:28');
/*!40000 ALTER TABLE `otp_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `state` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,'Shimla HQ','Shimla','Himachal Pradesh','2026-06-02 07:40:54'),(2,'Rampur Project','Rampur','Himachal Pradesh','2026-06-02 07:40:54'),(3,'Nathpa Jhakri Project','Nathpa Jhakri','Himachal Pradesh','2026-06-02 07:40:54');
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_codes`
--

DROP TABLE IF EXISTS `qr_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qr_codes` (
  `id` varchar(100) NOT NULL,
  `type` varchar(50) NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `used_by` varchar(50) DEFAULT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `employee_id` varchar(255) DEFAULT NULL,
  `items` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_codes`
--

LOCK TABLES `qr_codes` WRITE;
/*!40000 ALTER TABLE `qr_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `qr_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_scan_logs`
--

DROP TABLE IF EXISTS `qr_scan_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qr_scan_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `qr_id` varchar(100) NOT NULL,
  `scanned_by` varchar(50) NOT NULL,
  `lunch_type` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `qr_scan_logs_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_scan_logs`
--

LOCK TABLES `qr_scan_logs` WRITE;
/*!40000 ALTER TABLE `qr_scan_logs` DISABLE KEYS */;
INSERT INTO `qr_scan_logs` VALUES (1,'TEST_QR_1','admin_1','regular','2026-07-07 07:30:00',1),(2,'TEST_QR_2','admin_1','regular','2026-07-06 07:30:00',1),(3,'TEST_QR_3','admin_1','regular','2026-07-05 07:30:00',1),(4,'TEST_QR_4','admin_1','regular','2026-07-04 07:30:00',1),(5,'TEST_QR_5','admin_1','regular','2026-07-03 07:30:00',1),(6,'TEST_QR_6','admin_1','regular','2026-07-02 07:30:00',1),(7,'TEST_QR_7','admin_1','regular','2026-07-01 07:30:00',1),(8,'TEST_QR_8','admin_1','regular','2026-06-30 07:30:00',1),(9,'TEST_QR_9','admin_1','regular','2026-06-29 07:30:00',1),(10,'TEST_QR_10','admin_1','regular','2026-06-28 07:30:00',1),(11,'TEST_QR_11','admin_1','regular','2026-06-27 07:30:00',1),(12,'TEST_QR_12','admin_1','regular','2026-06-26 07:30:00',1),(13,'TEST_QR_13','admin_1','regular','2026-06-25 07:30:00',1),(14,'TEST_QR_14','admin_1','regular','2026-06-24 07:30:00',1),(15,'TEST_QR_15','admin_1','regular','2026-06-23 07:30:00',1),(16,'TEST_QR_16','admin_1','regular','2026-06-22 07:30:00',1),(17,'TEST_QR_17','admin_1','regular','2026-06-21 07:30:00',1),(18,'TEST_QR_18','admin_1','regular','2026-06-20 07:30:00',1),(19,'TEST_QR_19','admin_1','regular','2026-06-19 07:30:00',1),(20,'TEST_QR_20','admin_1','regular','2026-06-18 07:30:00',1),(21,'TEST_QR_1','admin_1','regular','2026-07-07 07:30:00',1),(22,'TEST_QR_2','admin_1','regular','2026-07-06 07:30:00',1),(23,'TEST_QR_3','admin_1','regular','2026-07-05 07:30:00',1),(24,'TEST_QR_4','admin_1','regular','2026-07-04 07:30:00',1),(25,'TEST_QR_5','admin_1','regular','2026-07-03 07:30:00',1),(26,'TEST_QR_6','admin_1','regular','2026-07-02 07:30:00',1),(27,'TEST_QR_7','admin_1','regular','2026-07-01 07:30:00',1),(28,'TEST_QR_8','admin_1','regular','2026-06-30 07:30:00',1),(29,'TEST_QR_9','admin_1','regular','2026-06-29 07:30:00',1),(30,'TEST_QR_10','admin_1','regular','2026-06-28 07:30:00',1),(31,'TEST_QR_11','admin_1','regular','2026-06-27 07:30:00',1),(32,'TEST_QR_12','admin_1','regular','2026-06-26 07:30:00',1),(33,'TEST_QR_13','admin_1','regular','2026-06-25 07:30:00',1),(34,'TEST_QR_14','admin_1','regular','2026-06-24 07:30:00',1),(35,'TEST_QR_15','admin_1','regular','2026-06-23 07:30:00',1),(36,'TEST_QR_16','admin_1','regular','2026-06-22 07:30:00',1),(37,'TEST_QR_17','admin_1','regular','2026-06-21 07:30:00',1),(38,'TEST_QR_18','admin_1','regular','2026-06-20 07:30:00',1),(39,'TEST_QR_19','admin_1','regular','2026-06-19 07:30:00',1),(40,'TEST_QR_20','admin_1','regular','2026-06-18 07:30:00',1),(41,'TEST_QR_1','admin_1','regular','2026-07-07 07:30:00',1),(42,'TEST_QR_2','admin_1','regular','2026-07-06 07:30:00',1),(43,'TEST_QR_3','admin_1','regular','2026-07-05 07:30:00',1),(44,'TEST_QR_4','admin_1','regular','2026-07-04 07:30:00',1),(45,'TEST_QR_5','admin_1','regular','2026-07-03 07:30:00',1),(46,'TEST_QR_6','admin_1','regular','2026-07-02 07:30:00',1),(47,'TEST_QR_7','admin_1','regular','2026-07-01 07:30:00',1),(48,'TEST_QR_8','admin_1','regular','2026-06-30 07:30:00',1),(49,'TEST_QR_9','admin_1','regular','2026-06-29 07:30:00',1),(50,'TEST_QR_10','admin_1','regular','2026-06-28 07:30:00',1),(51,'TEST_QR_11','admin_1','regular','2026-06-27 07:30:00',1),(52,'TEST_QR_12','admin_1','regular','2026-06-26 07:30:00',1),(53,'TEST_QR_13','admin_1','regular','2026-06-25 07:30:00',1),(54,'TEST_QR_14','admin_1','regular','2026-06-24 07:30:00',1),(55,'TEST_QR_15','admin_1','regular','2026-06-23 07:30:00',1),(56,'TEST_QR_16','admin_1','regular','2026-06-22 07:30:00',1),(57,'TEST_QR_17','admin_1','regular','2026-06-21 07:30:00',1),(58,'TEST_QR_18','admin_1','regular','2026-06-20 07:30:00',1),(59,'TEST_QR_19','admin_1','regular','2026-06-19 07:30:00',1),(60,'TEST_QR_20','admin_1','regular','2026-06-18 07:30:00',1);
/*!40000 ALTER TABLE `qr_scan_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rooms`
--

DROP TABLE IF EXISTS `rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_number` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rooms`
--

LOCK TABLES `rooms` WRITE;
/*!40000 ALTER TABLE `rooms` DISABLE KEYS */;
INSERT INTO `rooms` VALUES (1,'101',1),(2,'102',1),(3,'103',1),(4,'201',1),(5,'202',1);
/*!40000 ALTER TABLE `rooms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snack_orders`
--

DROP TABLE IF EXISTS `snack_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snack_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `items` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `date` date NOT NULL,
  `status` enum('pending','delivered','cancelled') DEFAULT 'pending',
  `payment_status` enum('pending','paid') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  `project_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `canteen_id` (`canteen_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `snack_orders_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `snack_orders_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`),
  CONSTRAINT `snack_orders_ibfk_3` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snack_orders`
--

LOCK TABLES `snack_orders` WRITE;
/*!40000 ALTER TABLE `snack_orders` DISABLE KEYS */;
INSERT INTO `snack_orders` VALUES (1,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-07','delivered','pending','2026-07-07 11:00:00',1,1),(2,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-06','delivered','pending','2026-07-06 11:00:00',1,1),(3,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-05','delivered','pending','2026-07-05 11:00:00',1,1),(4,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-04','delivered','pending','2026-07-04 11:00:00',1,1),(5,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-03','delivered','pending','2026-07-03 11:00:00',1,1),(6,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-02','delivered','pending','2026-07-02 11:00:00',1,1),(7,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-07-01','delivered','pending','2026-07-01 11:00:00',1,1),(8,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-30','delivered','pending','2026-06-30 11:00:00',1,1),(9,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-29','delivered','pending','2026-06-29 11:00:00',1,1),(10,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-28','delivered','pending','2026-06-28 11:00:00',1,1),(11,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-27','delivered','pending','2026-06-27 11:00:00',1,1),(12,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-26','delivered','pending','2026-06-26 11:00:00',1,1),(13,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-25','delivered','pending','2026-06-25 11:00:00',1,1),(14,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-24','delivered','pending','2026-06-24 11:00:00',1,1),(15,'30609','Test User','[{\"id\":1,\"name\":\"Samosa\",\"price\":15,\"quantity\":2}]',30.00,'2026-06-23','delivered','pending','2026-06-23 11:00:00',1,1);
/*!40000 ALTER TABLE `snack_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snacks_menu`
--

DROP TABLE IF EXISTS `snacks_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snacks_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_date` date NOT NULL,
  `session` varchar(50) NOT NULL,
  `items` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `snacks_menu_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snacks_menu`
--

LOCK TABLES `snacks_menu` WRITE;
/*!40000 ALTER TABLE `snacks_menu` DISABLE KEYS */;
INSERT INTO `snacks_menu` VALUES (13,'2026-07-06','Morning','[{\"name\": \"Samosa\", \"price\": 15}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',1),(14,'2026-07-06','Evening','[{\"name\": \"Vada Pav\", \"price\": 20}, {\"name\": \"Cutting Chai\", \"price\": 10}]','2026-07-08 10:16:37',1),(15,'2026-07-06','Morning','[{\"name\": \"Samosa\", \"price\": 15}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',2),(16,'2026-07-06','Evening','[{\"name\": \"Vada Pav\", \"price\": 20}, {\"name\": \"Cutting Chai\", \"price\": 10}]','2026-07-08 10:16:37',2),(17,'2026-07-06','Morning','[{\"name\": \"Samosa\", \"price\": 15}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',3),(18,'2026-07-06','Evening','[{\"name\": \"Vada Pav\", \"price\": 20}, {\"name\": \"Cutting Chai\", \"price\": 10}]','2026-07-08 10:16:37',3),(19,'2026-07-06','Morning','[{\"name\": \"Samosa\", \"price\": 15}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',4),(20,'2026-07-06','Evening','[{\"name\": \"Vada Pav\", \"price\": 20}, {\"name\": \"Cutting Chai\", \"price\": 10}]','2026-07-08 10:16:37',4),(21,'2026-07-07','Morning','[{\"name\": \"Poha\", \"price\": 25}, {\"name\": \"Jalebi\", \"price\": 20}, {\"name\": \"Coffee\", \"price\": 15}]','2026-07-08 10:16:37',1),(22,'2026-07-07','Evening','[{\"name\": \"Bhel Puri\", \"price\": 30}, {\"name\": \"Sev Puri\", \"price\": 30}, {\"name\": \"Cold Drink\", \"price\": 20}]','2026-07-08 10:16:37',1),(23,'2026-07-07','Morning','[{\"name\": \"Poha\", \"price\": 25}, {\"name\": \"Jalebi\", \"price\": 20}, {\"name\": \"Coffee\", \"price\": 15}]','2026-07-08 10:16:37',2),(24,'2026-07-07','Evening','[{\"name\": \"Bhel Puri\", \"price\": 30}, {\"name\": \"Sev Puri\", \"price\": 30}, {\"name\": \"Cold Drink\", \"price\": 20}]','2026-07-08 10:16:37',2),(25,'2026-07-07','Morning','[{\"name\": \"Poha\", \"price\": 25}, {\"name\": \"Jalebi\", \"price\": 20}, {\"name\": \"Coffee\", \"price\": 15}]','2026-07-08 10:16:37',3),(26,'2026-07-07','Evening','[{\"name\": \"Bhel Puri\", \"price\": 30}, {\"name\": \"Sev Puri\", \"price\": 30}, {\"name\": \"Cold Drink\", \"price\": 20}]','2026-07-08 10:16:37',3),(27,'2026-07-07','Morning','[{\"name\": \"Poha\", \"price\": 25}, {\"name\": \"Jalebi\", \"price\": 20}, {\"name\": \"Coffee\", \"price\": 15}]','2026-07-08 10:16:37',4),(28,'2026-07-07','Evening','[{\"name\": \"Bhel Puri\", \"price\": 30}, {\"name\": \"Sev Puri\", \"price\": 30}, {\"name\": \"Cold Drink\", \"price\": 20}]','2026-07-08 10:16:37',4),(29,'2026-07-08','Morning','[{\"name\": \"Aloo Paratha\", \"price\": 30}, {\"name\": \"Curd\", \"price\": 10}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',1),(30,'2026-07-08','Evening','[{\"name\": \"Pav Bhaji\", \"price\": 50}, {\"name\": \"Tawa Pulao\", \"price\": 60}]','2026-07-08 10:16:37',1),(31,'2026-07-08','Morning','[{\"name\": \"Aloo Paratha\", \"price\": 30}, {\"name\": \"Curd\", \"price\": 10}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',2),(32,'2026-07-08','Evening','[{\"name\": \"Pav Bhaji\", \"price\": 50}, {\"name\": \"Tawa Pulao\", \"price\": 60}]','2026-07-08 10:16:37',2),(33,'2026-07-08','Morning','[{\"name\": \"Aloo Paratha\", \"price\": 30}, {\"name\": \"Curd\", \"price\": 10}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',3),(34,'2026-07-08','Evening','[{\"name\": \"Pav Bhaji\", \"price\": 50}, {\"name\": \"Tawa Pulao\", \"price\": 60}]','2026-07-08 10:16:37',3),(35,'2026-07-08','Morning','[{\"name\": \"Aloo Paratha\", \"price\": 30}, {\"name\": \"Curd\", \"price\": 10}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',4),(36,'2026-07-08','Evening','[{\"name\": \"Pav Bhaji\", \"price\": 50}, {\"name\": \"Tawa Pulao\", \"price\": 60}]','2026-07-08 10:16:37',4),(37,'2026-07-09','Morning','[{\"name\": \"Idli Sambar\", \"price\": 35}, {\"name\": \"Vada\", \"price\": 15}, {\"name\": \"Filter Coffee\", \"price\": 15}]','2026-07-08 10:16:37',1),(38,'2026-07-09','Evening','[{\"name\": \"Paneer Roll\", \"price\": 45}, {\"name\": \"Egg Roll\", \"price\": 35}, {\"name\": \"Lemon Tea\", \"price\": 15}]','2026-07-08 10:16:37',1),(39,'2026-07-09','Morning','[{\"name\": \"Idli Sambar\", \"price\": 35}, {\"name\": \"Vada\", \"price\": 15}, {\"name\": \"Filter Coffee\", \"price\": 15}]','2026-07-08 10:16:37',2),(40,'2026-07-09','Evening','[{\"name\": \"Paneer Roll\", \"price\": 45}, {\"name\": \"Egg Roll\", \"price\": 35}, {\"name\": \"Lemon Tea\", \"price\": 15}]','2026-07-08 10:16:37',2),(41,'2026-07-09','Morning','[{\"name\": \"Idli Sambar\", \"price\": 35}, {\"name\": \"Vada\", \"price\": 15}, {\"name\": \"Filter Coffee\", \"price\": 15}]','2026-07-08 10:16:37',3),(42,'2026-07-09','Evening','[{\"name\": \"Paneer Roll\", \"price\": 45}, {\"name\": \"Egg Roll\", \"price\": 35}, {\"name\": \"Lemon Tea\", \"price\": 15}]','2026-07-08 10:16:37',3),(43,'2026-07-09','Morning','[{\"name\": \"Idli Sambar\", \"price\": 35}, {\"name\": \"Vada\", \"price\": 15}, {\"name\": \"Filter Coffee\", \"price\": 15}]','2026-07-08 10:16:37',4),(44,'2026-07-09','Evening','[{\"name\": \"Paneer Roll\", \"price\": 45}, {\"name\": \"Egg Roll\", \"price\": 35}, {\"name\": \"Lemon Tea\", \"price\": 15}]','2026-07-08 10:16:37',4),(45,'2026-07-10','Morning','[{\"name\": \"Bread Pakora\", \"price\": 20}, {\"name\": \"Green Chutney\", \"price\": 0}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',1),(46,'2026-07-10','Evening','[{\"name\": \"Momos (Veg)\", \"price\": 40}, {\"name\": \"Momos (Chicken)\", \"price\": 50}, {\"name\": \"Soup\", \"price\": 20}]','2026-07-08 10:16:37',1),(47,'2026-07-10','Morning','[{\"name\": \"Bread Pakora\", \"price\": 20}, {\"name\": \"Green Chutney\", \"price\": 0}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',2),(48,'2026-07-10','Evening','[{\"name\": \"Momos (Veg)\", \"price\": 40}, {\"name\": \"Momos (Chicken)\", \"price\": 50}, {\"name\": \"Soup\", \"price\": 20}]','2026-07-08 10:16:37',2),(49,'2026-07-10','Morning','[{\"name\": \"Bread Pakora\", \"price\": 20}, {\"name\": \"Green Chutney\", \"price\": 0}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',3),(50,'2026-07-10','Evening','[{\"name\": \"Momos (Veg)\", \"price\": 40}, {\"name\": \"Momos (Chicken)\", \"price\": 50}, {\"name\": \"Soup\", \"price\": 20}]','2026-07-08 10:16:37',3),(51,'2026-07-10','Morning','[{\"name\": \"Bread Pakora\", \"price\": 20}, {\"name\": \"Green Chutney\", \"price\": 0}, {\"name\": \"Masala Chai\", \"price\": 10}]','2026-07-08 10:16:37',4),(52,'2026-07-10','Evening','[{\"name\": \"Momos (Veg)\", \"price\": 40}, {\"name\": \"Momos (Chicken)\", \"price\": 50}, {\"name\": \"Soup\", \"price\": 20}]','2026-07-08 10:16:37',4),(53,'2026-07-11','Morning','[{\"name\": \"Upma\", \"price\": 25}, {\"name\": \"Kesari Bath\", \"price\": 20}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',1),(54,'2026-07-11','Evening','[{\"name\": \"Dabeli\", \"price\": 25}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',1),(55,'2026-07-11','Morning','[{\"name\": \"Upma\", \"price\": 25}, {\"name\": \"Kesari Bath\", \"price\": 20}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',2),(56,'2026-07-11','Evening','[{\"name\": \"Dabeli\", \"price\": 25}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',2),(57,'2026-07-11','Morning','[{\"name\": \"Upma\", \"price\": 25}, {\"name\": \"Kesari Bath\", \"price\": 20}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',3),(58,'2026-07-11','Evening','[{\"name\": \"Dabeli\", \"price\": 25}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',3),(59,'2026-07-11','Morning','[{\"name\": \"Upma\", \"price\": 25}, {\"name\": \"Kesari Bath\", \"price\": 20}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',4),(60,'2026-07-11','Evening','[{\"name\": \"Dabeli\", \"price\": 25}, {\"name\": \"Kachori\", \"price\": 15}, {\"name\": \"Tea\", \"price\": 10}]','2026-07-08 10:16:37',4),(61,'2026-07-12','Morning','[{\"name\": \"Chole Bhature\", \"price\": 50}, {\"name\": \"Lassi\", \"price\": 25}]','2026-07-08 10:16:37',1),(62,'2026-07-12','Evening','[{\"name\": \"French Fries\", \"price\": 40}, {\"name\": \"Burger\", \"price\": 50}, {\"name\": \"Cold Coffee\", \"price\": 35}]','2026-07-08 10:16:37',1),(63,'2026-07-12','Morning','[{\"name\": \"Chole Bhature\", \"price\": 50}, {\"name\": \"Lassi\", \"price\": 25}]','2026-07-08 10:16:37',2),(64,'2026-07-12','Evening','[{\"name\": \"French Fries\", \"price\": 40}, {\"name\": \"Burger\", \"price\": 50}, {\"name\": \"Cold Coffee\", \"price\": 35}]','2026-07-08 10:16:37',2),(65,'2026-07-12','Morning','[{\"name\": \"Chole Bhature\", \"price\": 50}, {\"name\": \"Lassi\", \"price\": 25}]','2026-07-08 10:16:37',3),(66,'2026-07-12','Evening','[{\"name\": \"French Fries\", \"price\": 40}, {\"name\": \"Burger\", \"price\": 50}, {\"name\": \"Cold Coffee\", \"price\": 35}]','2026-07-08 10:16:37',3),(67,'2026-07-12','Morning','[{\"name\": \"Chole Bhature\", \"price\": 50}, {\"name\": \"Lassi\", \"price\": 25}]','2026-07-08 10:16:37',4),(68,'2026-07-12','Evening','[{\"name\": \"French Fries\", \"price\": 40}, {\"name\": \"Burger\", \"price\": 50}, {\"name\": \"Cold Coffee\", \"price\": 35}]','2026-07-08 10:16:37',4);
/*!40000 ALTER TABLE `snacks_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transfer_requests`
--

DROP TABLE IF EXISTS `transfer_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transfer_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `from_project_id` int(11) NOT NULL,
  `to_project_id` int(11) NOT NULL,
  `coupons_transferred` int(11) NOT NULL,
  `initiated_by` varchar(50) NOT NULL,
  `transferred_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `from_project_id` (`from_project_id`),
  KEY `to_project_id` (`to_project_id`),
  KEY `initiated_by` (`initiated_by`),
  CONSTRAINT `transfer_requests_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transfer_requests_ibfk_2` FOREIGN KEY (`from_project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transfer_requests_ibfk_3` FOREIGN KEY (`to_project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transfer_requests_ibfk_4` FOREIGN KEY (`initiated_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transfer_requests`
--

LOCK TABLES `transfer_requests` WRITE;
/*!40000 ALTER TABLE `transfer_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `transfer_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `department` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `is_registered` tinyint(1) DEFAULT 0,
  `is_admin` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `coupons_left` int(10) unsigned DEFAULT 16,
  `coupons_used` int(10) unsigned DEFAULT 0,
  `monthly_limit` int(10) unsigned DEFAULT 16,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `role` enum('employee','canteen_admin','hr_admin','it_admin','scanner') DEFAULT 'employee',
  `project_id` int(11) DEFAULT NULL,
  `canteen_id` int(11) DEFAULT NULL,
  `last_coupon_reset_month` varchar(7) DEFAULT '2026-05',
  `session_token` varchar(255) DEFAULT NULL,
  `device_id` varchar(255) DEFAULT NULL,
  `admin_id` varchar(255) DEFAULT NULL,
  `portal_password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('30609','Test User','IT','9999999999','placeholder',1,0,1,0,0,16,'2026-07-06 11:01:35','employee',1,1,'2026-05',NULL,NULL,NULL,NULL),('CANTEEN001','Demo Canteen Admin','F&B Operations','7777777777','$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu',1,0,1,16,0,16,'2026-06-02 08:47:34','canteen_admin',1,1,'2026-05',NULL,NULL,NULL,'$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu'),('EMP001','Demo Employee','Engineering','6666666666','$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu',1,0,1,16,0,16,'2026-06-02 08:47:34','employee',1,1,'2026-05',NULL,NULL,NULL,NULL),('HR001','Demo HR Admin','HR Department','8888888888','$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu',1,0,1,16,0,16,'2026-06-02 08:47:34','hr_admin',1,1,'2026-05',NULL,'unknown_admin_device',NULL,'$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu'),('IT001','Demo IT Admin','IT Department','9999999999','$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu',1,1,1,16,0,16,'2026-06-02 08:47:34','it_admin',1,1,'2026-05','072f551a6b90010399460aa82000976791f6a5171e281fb46582acbf4a79b1a8','unknown_admin_device',NULL,'$2b$10$BQRXBPYDRZK6GlqaamHjTuAB.nweEE6E2PEi41.kaO6WIYwiJX7hu');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weekly_food_menu`
--

DROP TABLE IF EXISTS `weekly_food_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weekly_food_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `day_of_week` (`day_of_week`,`canteen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weekly_food_menu`
--

LOCK TABLES `weekly_food_menu` WRITE;
/*!40000 ALTER TABLE `weekly_food_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `weekly_food_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weekly_fruit_menu`
--

DROP TABLE IF EXISTS `weekly_fruit_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weekly_fruit_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `fruits` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`fruits`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `day_of_week` (`day_of_week`,`canteen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weekly_fruit_menu`
--

LOCK TABLES `weekly_fruit_menu` WRITE;
/*!40000 ALTER TABLE `weekly_fruit_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `weekly_fruit_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weekly_snacks_menu`
--

DROP TABLE IF EXISTS `weekly_snacks_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weekly_snacks_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `session` enum('morning','evening') NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `day_of_week` (`day_of_week`,`session`,`canteen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weekly_snacks_menu`
--

LOCK TABLES `weekly_snacks_menu` WRITE;
/*!40000 ALTER TABLE `weekly_snacks_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `weekly_snacks_menu` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-08 15:56:18
