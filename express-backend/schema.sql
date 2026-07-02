-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: localhost    Database: lunch_app
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

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
-- Table structure for table `billing`
--

DROP TABLE IF EXISTS `billing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `billing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bill_date` date NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `idx_billing_date` (`bill_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `canteens`
--

DROP TABLE IF EXISTS `canteens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `canteens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `open_time` time DEFAULT '07:00:00',
  `close_time` time DEFAULT '22:00:00',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `canteens_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_shares`
--

DROP TABLE IF EXISTS `coupon_shares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_shares` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` varchar(32) NOT NULL,
  `receiver_id` varchar(32) NOT NULL,
  `amount` int(11) NOT NULL,
  `shared_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `daily_item_feedbacks`
--

DROP TABLE IF EXISTS `daily_item_feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
-- Table structure for table `feedbacks`
--

DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `canteen_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `rating` int(11) DEFAULT 5,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `feedbacks_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedbacks_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `food_lunch_orders`
--

DROP TABLE IF EXISTS `food_lunch_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_lunch_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `order_type` varchar(32) DEFAULT NULL,
  `room_number` varchar(64) DEFAULT NULL,
  `delivery_time` time DEFAULT NULL,
  `date` date NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'pending',
  `created_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `canteen_id` int(11) DEFAULT 1,
  `project_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_food_emp_date` (`employee_id`,`date`),
  KEY `idx_food_date_status` (`date`,`status`),
  KEY `canteen_id` (`canteen_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `food_lunch_orders_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`),
  CONSTRAINT `food_lunch_orders_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `food_lunch_qr_tokens`
--

DROP TABLE IF EXISTS `food_lunch_qr_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_lunch_qr_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(32) NOT NULL,
  `token` text NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `food_menu`
--

DROP TABLE IF EXISTS `food_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_date` date NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_food_menu_date` (`menu_date`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `food_menu_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fruit_lunch_orders`
--

DROP TABLE IF EXISTS `fruit_lunch_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fruit_lunch_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `order_type` varchar(32) DEFAULT NULL,
  `room_number` varchar(64) DEFAULT NULL,
  `delivery_time` time DEFAULT NULL,
  `date` date NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'pending',
  `created_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `canteen_id` int(11) DEFAULT 1,
  `project_id` int(11) DEFAULT 1,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`id`),
  KEY `idx_fruit_emp_date` (`employee_id`,`date`),
  KEY `idx_fruit_date_status` (`date`,`status`),
  KEY `canteen_id` (`canteen_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `fruit_lunch_orders_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`),
  CONSTRAINT `fruit_lunch_orders_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fruit_menu`
--

DROP TABLE IF EXISTS `fruit_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fruit_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_date` date NOT NULL,
  `fruits` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`fruits`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fruit_menu_date` (`menu_date`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `fruit_menu_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lunch_logs`
--

DROP TABLE IF EXISTS `lunch_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lunch_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(32) NOT NULL,
  `scan_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `lunch_type` varchar(32) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_menu_date_type` (`date`,`lunch_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `monthly_bills`
--

DROP TABLE IF EXISTS `monthly_bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `monthly_bills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `bill_month` varchar(7) NOT NULL,
  `total_coupons_used` int(11) NOT NULL DEFAULT 0,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','submitted','approved','rejected','review') DEFAULT 'submitted',
  `generated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `place_generated` varchar(255) NOT NULL,
  `canteen_id` int(11) DEFAULT 1,
  `coupon_price` decimal(10,2) DEFAULT 0.00,
  `comments` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `monthly_bills_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `monthly_bills_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `otp_verifications`
--

DROP TABLE IF EXISTS `otp_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `otp_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) DEFAULT NULL,
  `phone_number` varchar(32) NOT NULL,
  `otp_code` varchar(12) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_phone_created` (`phone_number`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `state` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qr_codes`
--

DROP TABLE IF EXISTS `qr_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qr_codes` (
  `id` char(36) NOT NULL,
  `employee_id` varchar(50) DEFAULT NULL,
  `type` varchar(32) NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `used_by` varchar(32) DEFAULT NULL,
  `used_at` datetime DEFAULT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qr_scan_logs`
--

DROP TABLE IF EXISTS `qr_scan_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qr_scan_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `qr_id` char(36) NOT NULL,
  `scanned_by` varchar(32) NOT NULL,
  `lunch_type` varchar(32) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `qr_scan_logs_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rooms`
--

DROP TABLE IF EXISTS `rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_number` varchar(64) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snack_orders`
--

DROP TABLE IF EXISTS `snack_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snack_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(32) NOT NULL,
  `room` varchar(128) DEFAULT NULL,
  `session` varchar(32) DEFAULT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  `total` int(11) DEFAULT 0,
  `status` varchar(32) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `canteen_id` int(11) DEFAULT 1,
  `project_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `canteen_id` (`canteen_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `snack_orders_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`),
  CONSTRAINT `snack_orders_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snacks_menu`
--

DROP TABLE IF EXISTS `snacks_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snacks_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_date` date NOT NULL,
  `session` varchar(32) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_snacks_menu_session` (`menu_date`,`session`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `snacks_menu_ibfk_1` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transfer_requests`
--

DROP TABLE IF EXISTS `transfer_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transfer_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(50) NOT NULL,
  `from_project_id` int(11) NOT NULL,
  `to_project_id` int(11) NOT NULL,
  `coupons_transferred` int(11) NOT NULL,
  `initiated_by` varchar(50) NOT NULL,
  `transferred_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `employee_id` (`employee_id`),
  KEY `from_project_id` (`from_project_id`),
  KEY `to_project_id` (`to_project_id`),
  KEY `initiated_by` (`initiated_by`),
  CONSTRAINT `transfer_requests_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transfer_requests_ibfk_2` FOREIGN KEY (`from_project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transfer_requests_ibfk_3` FOREIGN KEY (`to_project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transfer_requests_ibfk_4` FOREIGN KEY (`initiated_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `department` varchar(255) DEFAULT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `portal_password` varchar(255) DEFAULT NULL,
  `is_registered` tinyint(1) NOT NULL DEFAULT 0,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `coupons_left` int(10) unsigned DEFAULT 16,
  `coupons_used` int(10) unsigned DEFAULT 0,
  `monthly_limit` int(10) unsigned DEFAULT 16,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `role` enum('employee','canteen_admin','hr_admin','it_admin','scanner') DEFAULT 'employee',
  `project_id` int(11) DEFAULT NULL,
  `canteen_id` int(11) DEFAULT NULL,
  `last_coupon_reset_month` varchar(7) DEFAULT '2026-05',
  `session_token` varchar(255) DEFAULT NULL,
  `device_id` varchar(255) DEFAULT NULL,
  `admin_id` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_id` (`admin_id`),
  KEY `project_id` (`project_id`),
  KEY `canteen_id` (`canteen_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`canteen_id`) REFERENCES `canteens` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `weekly_food_menu`
--

DROP TABLE IF EXISTS `weekly_food_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weekly_food_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `day_of_week` (`day_of_week`,`canteen_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `weekly_fruit_menu`
--

DROP TABLE IF EXISTS `weekly_fruit_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weekly_fruit_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `fruits` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`fruits`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `day_of_week` (`day_of_week`,`canteen_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `weekly_snacks_menu`
--

DROP TABLE IF EXISTS `weekly_snacks_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weekly_snacks_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` int(11) NOT NULL,
  `session` enum('morning','evening') NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `canteen_id` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `day_of_week` (`day_of_week`,`session`,`canteen_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-02 18:00:32
