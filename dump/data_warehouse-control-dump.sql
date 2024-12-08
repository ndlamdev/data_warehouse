-- MySQL dump 10.13  Distrib 8.0.40, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: data_warehouse_control
-- ------------------------------------------------------
-- Server version	8.0.40-0ubuntu0.24.10.1

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

DROP DATABASE IF EXISTS `data_warehouse_control`;
CREATE DATABASE `data_warehouse_control`;
USE `data_warehouse_control`;

--
-- Table structure for table `crawl_data_product_css_selectors`
--

DROP TABLE IF EXISTS `crawl_data_product_css_selectors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crawl_data_product_css_selectors` (
  `id` int NOT NULL,
  `button_close_pop_up` varchar(255) DEFAULT '',
  `title` varchar(255) DEFAULT '',
  `product_container` varchar(255) DEFAULT '',
  `specifications_container` varchar(255) DEFAULT '',
  `desks` varchar(255) DEFAULT '',
  `colors` varchar(255) DEFAULT '',
  `desk_links` varchar(255) DEFAULT '',
  `color_links` varchar(255) DEFAULT '',
  `status` varchar(255) DEFAULT '',
  `price` varchar(255) DEFAULT '',
  `discount` varchar(255) DEFAULT '',
  `images` varchar(255) DEFAULT '',
  `show_more_specifications` varchar(255) DEFAULT '',
  `group_specifications` varchar(255) DEFAULT '',
  `name_group_specifications` varchar(255) DEFAULT '',
  `row_specifications` varchar(255) DEFAULT '',
  `title_specifications` varchar(255) DEFAULT '',
  `value_specifications` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crawl_data_product_css_selectors`
--

LOCK TABLES `crawl_data_product_css_selectors` WRITE;
/*!40000 ALTER TABLE `crawl_data_product_css_selectors` DISABLE KEYS */;
INSERT INTO `crawl_data_product_css_selectors` VALUES (1,'','div.box-product-name > h1','div.box-detail-product','','div.box-linked strong@s','ul.list-variants strong.item-variant-name@s','div.box-linked a[href]@s','ul.list-variants li.item-variant a[href]@s','','div#trade-price-tabs .tpt-box:nth-of-type(2) .tpt---sale-price','div#trade-price-tabs .tpt-box:nth-of-type(2) .tpt---price','div.box-gallery .swiper-wrapper img[src]@s','','','','ul.technical-content li.technical-content-item@s','p','div'),(2,'','div.product-name > h1','div.box_main','','div.scrolling_inner:nth-of-type(1) .group a@s','div.scrolling_inner:nth-of-type(2) .group a@s','div.scrolling_inner:nth-of-type(1) .group a[href]@s','div.scrolling_inner:nth-of-type(2) .group a[href]@s','.productstatus','div.box_saving .bs_price em, div.price-one .box-price-present','div.box_saving .bs_price strong, div.price-one .box-price-old','div.owl-stage .item-img[data-thumb]@s','','div.specifications .box-specifi@s','h3','ul > li@s','aside:nth-of-type(1)','aside:nth-of-type(2) a, aside:nth-of-type(2) span@s');
/*!40000 ALTER TABLE `crawl_data_product_css_selectors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crawl_link_css_selectors`
--

DROP TABLE IF EXISTS `crawl_link_css_selectors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crawl_link_css_selectors` (
  `id` int NOT NULL,
  `url` varchar(255) DEFAULT '',
  `is_paging` bit(1) DEFAULT b'1',
  `view_more` varchar(255) DEFAULT '',
  `next_page` varchar(255) DEFAULT '',
  `button_close_pop_up` varchar(255) DEFAULT '',
  `product_item` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crawl_link_css_selectors`
--

LOCK TABLES `crawl_link_css_selectors` WRITE;
/*!40000 ALTER TABLE `crawl_link_css_selectors` DISABLE KEYS */;
INSERT INTO `crawl_link_css_selectors` VALUES (1,'https://cellphones.com.vn/mobile.html?mobile_os_filter=android,iphone-ios',_binary '','a.btn-show-more.button__show-more-product','','button.cancel-button-top','div.product-info > a[href]@s'),(2,'https://www.thegioididong.com/dtdd',_binary '','div.view-more','','','li.item > a[href]@s');
/*!40000 ALTER TABLE `crawl_link_css_selectors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_configs`
--

DROP TABLE IF EXISTS `file_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_configs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `location_file_save` varchar(255) DEFAULT NULL,
  `format_file` varchar(255) DEFAULT NULL,
  `database_staging` varchar(255) DEFAULT NULL,
  `database_warehouse` varchar(255) DEFAULT NULL,
  `table_warehouse` varchar(255) DEFAULT NULL,
  `column_table_warehouse` varchar(255) DEFAULT NULL,
  `table_staging` varchar(255) DEFAULT NULL,
  `column_table_staging` varchar(255) DEFAULT NULL,
  `limit_item` int DEFAULT '100',
  `crawl_link_css_selectors_id` int NOT NULL,
  `crawl_data_product_css_selectors_id` int NOT NULL,
  `table_temp` varchar(255) DEFAULT NULL,
  `procedure_load_data_staging` varchar(255) DEFAULT NULL,
  `procedure_load_data_warehouse` varchar(255) DEFAULT NULL,
  `procedure_load_data_temp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `file_configs_crawl_data_product_css_selectors_id_fk` (`crawl_data_product_css_selectors_id`),
  KEY `file_configs_crawl_link_css_selectors_id_fk` (`crawl_link_css_selectors_id`),
  CONSTRAINT `file_configs_crawl_data_product_css_selectors_id_fk` FOREIGN KEY (`crawl_data_product_css_selectors_id`) REFERENCES `crawl_data_product_css_selectors` (`id`),
  CONSTRAINT `file_configs_crawl_link_css_selectors_id_fk` FOREIGN KEY (`crawl_link_css_selectors_id`) REFERENCES `crawl_link_css_selectors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_configs`
--

LOCK TABLES `file_configs` WRITE;
/*!40000 ALTER TABLE `file_configs` DISABLE KEYS */;
INSERT INTO `file_configs` VALUES (1,'cellphones','/media/lam-nguyen/D/tai_lieu_hoc_tap/data_warehouse/crawl_data/data','csv','data_warehouse_staging','data_warehouse_prepetation','',NULL,'cellphones_product_staging',NULL,50,1,1,'products_cellphones_temp','data_warehouse_control.PROCESS_DATA_TABLE_CELLPHONES_TEMP','data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_CELLPHONES','data_warehouse_control.LOAD_FILE'),(2,'the_gioi_di_dong','/media/lam-nguyen/D/tai_lieu_hoc_tap/data_warehouse/crawl_data/data','csv','data_warehouse_staging','data_warehouse_prepetation','',NULL,'the_gioi_di_dong_product_staging',NULL,50,2,2,'products_the_gioi_di_dong_temp','data_warehouse_control.PROCESS_DATA_TABLE_THE_GIOI_DI_DONG_TEMP','data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_THE_GIOI_DI_DONG','data_warehouse_control.LOAD_FILE');
/*!40000 ALTER TABLE `file_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_logs`
--

DROP TABLE IF EXISTS `file_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `file_config_id` int DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `status` enum('CRAWL_SUCCESS','CRAWL_FAIL','CRAWLING','LOADING_FILE','LOAD_FILE_SUCCESS','DAILY_LOADING','DAILY_SUCCESS','STAGING_PROCESS','STAGING_DONE','TRANSFORM_PROCESSING','TRANSFORM_DONE') DEFAULT NULL,
  `date` date DEFAULT NULL,
  `date_update` datetime DEFAULT NULL,
  `total_crawl` int DEFAULT NULL,
  `total_crawl_success` int DEFAULT NULL,
  `total_crawl_fail` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_file_config_id_file_log_file_config` (`file_config_id`),
  CONSTRAINT `fk_file_config_id_file_log_file_config` FOREIGN KEY (`file_config_id`) REFERENCES `file_configs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_logs`
--

LOCK TABLES `file_logs` WRITE;
/*!40000 ALTER TABLE `file_logs` DISABLE KEYS */;
INSERT INTO `file_logs` VALUES (1,1,'cellphones_2024-10-22','STAGING_DONE','2024-10-22','2024-12-03 00:13:25',50,48,2),(2,2,'the_gioi_di_dong_2024-10-22','STAGING_DONE','2024-10-22','2024-12-03 01:57:15',50,49,1),(3,1,'cellphones_2024-10-24','STAGING_DONE','2024-10-24','2024-12-03 00:13:25',50,49,1),(4,2,'the_gioi_di_dong_2024-10-24','STAGING_DONE','2024-10-24','2024-12-03 01:57:15',50,50,0),(5,1,'cellphones_2024-10-10','STAGING_DONE','2024-10-10','2024-12-03 00:13:25',50,0,0),(6,2,'the_gioi_di_dong_2024-10-10','STAGING_DONE','2024-10-10','2024-12-03 01:57:15',50,0,0),(7,1,'cellphones_2024-11-06','STAGING_DONE','2024-11-06','2024-12-03 00:13:25',50,47,3),(8,2,'the_gioi_di_dong_2024-11-06','STAGING_DONE','2024-11-06','2024-12-03 01:57:15',50,50,0),(9,1,'cellphones_2024-11-07','STAGING_DONE','2024-11-07','2024-12-03 00:13:25',50,48,2),(10,2,'the_gioi_di_dong_2024-11-07','STAGING_DONE','2024-11-07','2024-12-03 01:57:15',50,50,0),(11,1,'cellphones_2024-11-13','STAGING_DONE','2024-11-13','2024-12-03 00:13:25',50,48,2),(12,2,'the_gioi_di_dong_2024-11-13','STAGING_DONE','2024-11-13','2024-12-03 01:57:15',50,50,0),(13,1,'cellphones_2024-11-20','STAGING_DONE','2024-11-20','2024-12-03 00:13:25',50,48,2),(14,2,'the_gioi_di_dong_2024-11-20','STAGING_DONE','2024-11-20','2024-12-03 01:57:15',50,49,1),(16,1,'cellphones_2024-12-03','TRANSFORM_DONE','2024-12-03','2024-12-03 05:31:34',50,49,1),(17,2,'the_gioi_di_dong_2024-12-03','TRANSFORM_DONE','2024-12-03','2024-12-03 05:32:31',50,50,0);
/*!40000 ALTER TABLE `file_logs` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-08  6:12:47
