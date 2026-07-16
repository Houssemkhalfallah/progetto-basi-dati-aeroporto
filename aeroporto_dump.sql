-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: aeroporto
-- ------------------------------------------------------
-- Server version	8.0.46

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
-- Table structure for table `aereo`
--

DROP TABLE IF EXISTS `aereo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aereo` (
  `Codice_ICAO` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Modello` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Compagnia` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Latitudine` double NOT NULL DEFAULT '0',
  `Longitudine` double NOT NULL DEFAULT '0',
  `Lunghezza` double NOT NULL,
  `Altezza` double NOT NULL,
  `Apertura_alare` double NOT NULL,
  `Tipo` enum('Trasporto merci','Passeggeri') COLLATE utf8mb4_unicode_ci NOT NULL,
  `Capacita` int DEFAULT NULL,
  `Peso_Max` double DEFAULT NULL,
  `Peso_occupato` double DEFAULT NULL,
  `Volume_occupato` double DEFAULT NULL,
  `Capienza` int DEFAULT NULL,
  `Numero_gate` int DEFAULT NULL,
  `Terminal_gate` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ID_itinerario` int DEFAULT NULL,
  PRIMARY KEY (`Codice_ICAO`),
  KEY `Numero_gate` (`Numero_gate`,`Terminal_gate`),
  KEY `ID_itinerario` (`ID_itinerario`),
  CONSTRAINT `aereo_ibfk_1` FOREIGN KEY (`Numero_gate`, `Terminal_gate`) REFERENCES `gate` (`Numero`, `Terminal`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `aereo_ibfk_2` FOREIGN KEY (`ID_itinerario`) REFERENCES `itinerario` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `aereo_chk_1` CHECK (((`Lunghezza` > 0) and (`Altezza` > 0) and (`Apertura_alare` > 0))),
  CONSTRAINT `aereo_chk_2` CHECK (((`Latitudine` between -(90) and 90) and (`Longitudine` between -(180) and 180))),
  CONSTRAINT `aereo_chk_3` CHECK ((((`Peso_Max` is null) or (`Peso_Max` > 0)) and ((`Capacita` is null) or (`Capacita` > 0)))),
  CONSTRAINT `aereo_chk_4` CHECK (((`Capienza` is null) or (`Capienza` > 0))),
  CONSTRAINT `aereo_chk_5` CHECK ((((`Tipo` = _cp850'Trasporto merci') and (`Capienza` is null)) or ((`Tipo` = _cp850'Passeggeri') and (`Capienza` is not null)))),
  CONSTRAINT `aereo_chk_6` CHECK ((((`Tipo` = _cp850'Passeggeri') and (`Peso_Max` is null) and (`Capacita` is null)) or ((`Tipo` = _cp850'Trasporto merci') and (`Peso_Max` is not null) and (`Capacita` is not null)))),
  CONSTRAINT `aereo_chk_7` CHECK (((`Peso_Max` is null) or (`Peso_occupato` is null) or (`Peso_occupato` <= `Peso_Max`))),
  CONSTRAINT `aereo_chk_8` CHECK (((`Capacita` is null) or (`Volume_occupato` is null) or (`Volume_occupato` <= `Capacita`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aereo`
--

LOCK TABLES `aereo` WRITE;
/*!40000 ALTER TABLE `aereo` DISABLE KEYS */;
/*!40000 ALTER TABLE `aereo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_assistenti_itinerario` BEFORE INSERT ON `aereo` FOR EACH ROW BEGIN
    DECLARE numero_assistenti INT;

    IF NEW.Tipo = 'Passeggeri' AND NEW.ID_itinerario IS NOT NULL THEN

        SELECT COUNT(Codice_fiscale)
        INTO numero_assistenti
        FROM Assistente_di_volo
        WHERE Assistente_di_volo.ID_itinerario = NEW.ID_itinerario;

        IF numero_assistenti <> 6 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ci devono essere 6 assistenti di volo per ogni itinerario';
        END IF;

    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_tipo_aereo_itinerario` BEFORE INSERT ON `aereo` FOR EACH ROW BEGIN
IF NEW.Tipo='Trasporto merci' AND NEW.ID_itinerario IS NOT NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Gli itinerari non possono essere assegnati agli aerei trasporto merci';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_gate` BEFORE INSERT ON `aereo` FOR EACH ROW BEGIN
DECLARE tipo_gate VARCHAR(15);
DECLARE lunghezza_gate DOUBLE;
SELECT Tipo, Lunghezza
INTO tipo_gate, lunghezza_gate
FROM Gate
WHERE Numero=NEW.Numero_gate AND Terminal=NEW.Terminal_gate;
IF NEW.Tipo <> tipo_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il tipo di gate non risulta compatibile con il tipo di aereo';
ELSEIF NEW.Lunghezza > lunghezza_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il gate non ha lunghezza sufficiente per questo aereo';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_assistenti_itinerario2` BEFORE UPDATE ON `aereo` FOR EACH ROW BEGIN
DECLARE numero_assistenti INT;
IF NOT(NEW.ID_itinerario <=> OLD.ID_itinerario) AND NEW.ID_itinerario IS NOT NULL THEN
SELECT COUNT(Codice_fiscale)
INTO numero_assistenti
FROM Assistente_di_volo
WHERE ID_itinerario=NEW.ID_itinerario;
IF numero_assistenti <> 6 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Ci devono essere 6 assistenti di volo per ogni itinerario';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_tipo_aereo_itinerario2` BEFORE UPDATE ON `aereo` FOR EACH ROW BEGIN
IF NEW.Tipo='Trasporto merci' AND NEW.ID_itinerario IS NOT NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Gli itinerari non possono essere assegnati agli aerei trasporto merci';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_gate2` BEFORE UPDATE ON `aereo` FOR EACH ROW BEGIN
DECLARE tipo_gate VARCHAR(15);
DECLARE lunghezza_gate DOUBLE;
IF NEW.Numero_gate <> OLD.Numero_gate OR NEW.Terminal_gate <> OLD.Terminal_gate OR NEW.Lunghezza <> OLD.Lunghezza THEN
SELECT Tipo, Lunghezza
INTO tipo_gate, lunghezza_gate
FROM Gate
WHERE Numero=NEW.Numero_gate AND Terminal=NEW.Terminal_gate;
IF NEW.Tipo <> tipo_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il tipo di gate non risulta compatibile con il tipo di aereo';
ELSEIF NEW.Lunghezza > lunghezza_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il gate non ha lunghezza sufficiente per questo aereo';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `assistente_di_volo`
--

DROP TABLE IF EXISTS `assistente_di_volo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assistente_di_volo` (
  `Codice_fiscale` char(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Cognome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Data_nascita` date NOT NULL,
  `Numero_licenza` int NOT NULL,
  `Stipendio` decimal(20,2) NOT NULL,
  `Data_assunzione` date NOT NULL,
  `Valutazione` decimal(2,1) NOT NULL,
  `ID_itinerario` int DEFAULT NULL,
  PRIMARY KEY (`Codice_fiscale`),
  UNIQUE KEY `Numero_licenza` (`Numero_licenza`),
  KEY `ID_itinerario` (`ID_itinerario`),
  CONSTRAINT `assistente_di_volo_ibfk_1` FOREIGN KEY (`ID_itinerario`) REFERENCES `itinerario` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `assistente_di_volo_chk_1` CHECK ((`Stipendio` > 0)),
  CONSTRAINT `assistente_di_volo_chk_2` CHECK ((`Numero_licenza` > 0)),
  CONSTRAINT `assistente_di_volo_chk_3` CHECK ((`Valutazione` between 1 and 5)),
  CONSTRAINT `assistente_di_volo_chk_4` CHECK ((((to_days(`Data_assunzione`) - to_days(`Data_nascita`)) / 365.25) >= 18))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assistente_di_volo`
--

LOCK TABLES `assistente_di_volo` WRITE;
/*!40000 ALTER TABLE `assistente_di_volo` DISABLE KEYS */;
/*!40000 ALTER TABLE `assistente_di_volo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_itinerario_assistente` BEFORE INSERT ON `assistente_di_volo` FOR EACH ROW BEGIN
DECLARE numero_assistenti INT;
SELECT COUNT(Codice_fiscale)
INTO numero_assistenti
FROM Assistente_di_volo
WHERE ID_itinerario=NEW.ID_itinerario;
IF numero_assistenti>=6 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Non si possono inserire piu di 6 assistenti di volo per itinerario';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_itinerario_assistente2` BEFORE UPDATE ON `assistente_di_volo` FOR EACH ROW BEGIN
DECLARE numero_assistenti INT;
IF NOT(OLD.ID_itinerario <=> NEW.ID_itinerario) AND NEW.ID_itinerario IS NOT NULL THEN
SELECT COUNT(Codice_fiscale)
INTO numero_assistenti
FROM Assistente_di_volo
WHERE ID_itinerario=NEW.ID_itinerario;
IF numero_assistenti>=6 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Non si possono inserire piu di 6 assistenti di volo per itinerario';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
INSERT INTO `auth_group` VALUES (4,'gestore_aerei_passeggeri'),(3,'gestore_aerei_trasporto_merci'),(2,'gestore_gate'),(5,'gestore_magazzino_aeroportuale'),(1,'passeggero');
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',3,'add_permission'),(6,'Can change permission',3,'change_permission'),(7,'Can delete permission',3,'delete_permission'),(8,'Can view permission',3,'view_permission'),(9,'Can add group',2,'add_group'),(10,'Can change group',2,'change_group'),(11,'Can delete group',2,'delete_group'),(12,'Can view group',2,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$1200000$KmSqrx65onu6ZviSqx6miD$6M85IHSjAKklZAJnvV3Jvwi1DOop63w0OkKukdODmTs=','2026-07-16 20:52:13.651810',1,'houss','','','houssemkhalfallah39@gmail.com',1,1,'2026-07-16 20:08:29.741584'),(2,'pbkdf2_sha256$1200000$z0pYy2vMXuSYWb6BMUdLLg$CAVeeYC2UklSOaQFyuWp2k7wt+dyx+PsNwCpr9iJIR0=','2026-07-16 20:45:35.933375',0,'Angelica','','','',0,1,'2026-07-16 20:43:39.947324'),(3,'pbkdf2_sha256$1200000$MTq7PDV7Nr3QswSRBYZps8$2HApoqNCIFNtSYNB/aeXyGPlaZKLFRg57+XrGJZPwsI=','2026-07-16 21:05:05.630541',0,'nicola','','','',0,1,'2026-07-16 21:04:19.747613');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
INSERT INTO `auth_user_groups` VALUES (1,2,1),(2,3,1);
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_aereo`
--

DROP TABLE IF EXISTS `container_aereo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_aereo` (
  `ID` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Capacita` double NOT NULL,
  `Compagnia_logistica` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Peso` double NOT NULL,
  `Codice_ICAO` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Data_inizio` date NOT NULL,
  `Data_fine` date NOT NULL,
  `Destinazione` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `Codice_ICAO` (`Codice_ICAO`),
  CONSTRAINT `container_aereo_ibfk_1` FOREIGN KEY (`Codice_ICAO`) REFERENCES `aereo` (`Codice_ICAO`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `container_aereo_chk_1` CHECK (((`Capacita` > 0) and (`Peso` >= 0))),
  CONSTRAINT `container_aereo_chk_2` CHECK (regexp_like(`ID`,_cp850'^[A-Z]{4}[0-9]{7}$')),
  CONSTRAINT `container_aereo_chk_3` CHECK ((`Data_inizio` <= `Data_fine`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_aereo`
--

LOCK TABLES `container_aereo` WRITE;
/*!40000 ALTER TABLE `container_aereo` DISABLE KEYS */;
/*!40000 ALTER TABLE `container_aereo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_peso_e_capacita` BEFORE INSERT ON `container_aereo` FOR EACH ROW BEGIN
    DECLARE peso_max DOUBLE;
    DECLARE peso_occ DOUBLE;
    DECLARE cap_max INT;
    DECLARE volume_occ INT;

    SELECT Peso_Max, Peso_occupato, Capacita, Volume_occupato
    INTO peso_max, peso_occ, cap_max, volume_occ
    FROM Aereo
    WHERE Codice_ICAO = NEW.Codice_ICAO;

    IF peso_occ + NEW.Peso > peso_max OR volume_occ + NEW.Capacita > cap_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il container non entra sull''aereo selezionato';
    ELSE
        UPDATE Aereo
        SET Peso_occupato = Peso_occupato + NEW.Peso,
            Volume_occupato = Volume_occupato + NEW.Capacita
        WHERE Codice_ICAO = NEW.Codice_ICAO;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_tipo_aereo_container` BEFORE INSERT ON `container_aereo` FOR EACH ROW BEGIN
DECLARE tipo_aereo VARCHAR(15);
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF tipo_aereo <> 'Trasporto merci' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non trasporta container';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `aggiornamento_peso_e_capacita` BEFORE UPDATE ON `container_aereo` FOR EACH ROW BEGIN
DECLARE peso_occ DOUBLE;
DECLARE peso_max DOUBLE;
DECLARE volume_occ INT;
DECLARE capacita INT;
SELECT Peso_occupato, Peso_Max, Volume_occupato, Capacita
INTO peso_occ, peso_max, volume_occ, capacita
FROM Aereo
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
IF OLD.Codice_ICAO = NEW.Codice_ICAO THEN
IF peso_occ+NEW.Peso-OLD.Peso>peso_max OR volume_occ+NEW.Capacita-OLD.Capacita>capacita THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il container non entra sull''aereo selezionato';
ELSE
UPDATE Aereo
SET Peso_occupato=Peso_occupato+NEW.Peso-OLD.Peso, Volume_occupato=Volume_occupato+NEW.Capacita-OLD.Capacita
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
END IF;
ELSE
IF peso_occ+NEW.Peso>peso_max OR volume_occ+NEW.Capacita>capacita THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il container non entra sull''aereo selezionato';
ELSE
UPDATE Aereo
SET Peso_occupato=Peso_occupato+NEW.Peso, Volume_occupato=Volume_occupato+NEW.Capacita
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
UPDATE Aereo
SET Peso_occupato=Peso_occupato-OLD.Peso, Volume_occupato=Volume_occupato-OLD.Capacita
WHERE Aereo.Codice_ICAO = OLD.Codice_ICAO;
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_tipo_aereo_container2` BEFORE UPDATE ON `container_aereo` FOR EACH ROW BEGIN
DECLARE tipo_aereo VARCHAR(15);
IF OLD.Codice_ICAO <> NEW.Codice_ICAO THEN
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF tipo_aereo <> 'Trasporto merci' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non trasporta container';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `liberazione_peso_e_capacita` AFTER DELETE ON `container_aereo` FOR EACH ROW BEGIN
    UPDATE Aereo
    SET Peso_occupato = Peso_occupato - OLD.Peso,
        Volume_occupato = Volume_occupato - OLD.Capacita
    WHERE Codice_ICAO = OLD.Codice_ICAO;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE utf8mb4_unicode_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2026-07-16 20:10:32.079607','1','Passeggero',1,'[{\"added\": {}}]',2,1),(2,'2026-07-16 20:10:51.139654','2','Gestore gate',1,'[{\"added\": {}}]',2,1),(3,'2026-07-16 20:10:58.446012','3','Gestore aerei trasporto merci',1,'[{\"added\": {}}]',2,1),(4,'2026-07-16 20:11:05.915584','4','Gestore aerei passeggeri',1,'[{\"added\": {}}]',2,1),(5,'2026-07-16 20:11:14.323259','5','Gestore magazzino aeroportuale',1,'[{\"added\": {}}]',2,1),(6,'2026-07-16 20:12:20.350830','4','Gestore aerei passeggeri',2,'[]',2,1),(7,'2026-07-16 20:14:04.092543','1','passeggero',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',2,1),(8,'2026-07-16 20:14:22.271368','2','gestore_gate',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',2,1),(9,'2026-07-16 20:14:54.565275','3','gestore_aerei_trasporto_merci',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',2,1),(10,'2026-07-16 20:15:24.559605','5','gestore_magazzino_aeroportuale',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',2,1),(11,'2026-07-16 20:16:07.973623','4','gestore_aerei_passegeri',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',2,1),(12,'2026-07-16 20:16:49.675421','4','gestore_aerei_passeggeri',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',2,1);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(2,'auth','group'),(3,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-07-16 18:37:51.056278'),(2,'auth','0001_initial','2026-07-16 18:37:51.455752'),(3,'admin','0001_initial','2026-07-16 18:37:51.582861'),(4,'admin','0002_logentry_remove_auto_add','2026-07-16 18:37:51.587173'),(5,'admin','0003_logentry_add_action_flag_choices','2026-07-16 18:37:51.590855'),(6,'contenttypes','0002_remove_content_type_name','2026-07-16 18:37:51.659518'),(7,'auth','0002_alter_permission_name_max_length','2026-07-16 18:37:51.702837'),(8,'auth','0003_alter_user_email_max_length','2026-07-16 18:37:51.713862'),(9,'auth','0004_alter_user_username_opts','2026-07-16 18:37:51.718563'),(10,'auth','0005_alter_user_last_login_null','2026-07-16 18:37:51.755036'),(11,'auth','0006_require_contenttypes_0002','2026-07-16 18:37:51.756838'),(12,'auth','0007_alter_validators_add_error_messages','2026-07-16 18:37:51.761106'),(13,'auth','0008_alter_user_username_max_length','2026-07-16 18:37:51.807948'),(14,'auth','0009_alter_user_last_name_max_length','2026-07-16 18:37:51.858861'),(15,'auth','0010_alter_group_name_max_length','2026-07-16 18:37:51.871345'),(16,'auth','0011_update_proxy_permissions','2026-07-16 18:37:51.875833'),(17,'auth','0012_alter_user_first_name_max_length','2026-07-16 18:37:51.918705'),(18,'sessions','0001_initial','2026-07-16 18:37:51.941821');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gate`
--

DROP TABLE IF EXISTS `gate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gate` (
  `Numero` int NOT NULL,
  `Terminal` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Tipo` enum('Trasporto merci','Passeggeri') COLLATE utf8mb4_unicode_ci NOT NULL,
  `Lunghezza` double NOT NULL,
  PRIMARY KEY (`Numero`,`Terminal`),
  CONSTRAINT `gate_chk_1` CHECK ((`Numero` > 0)),
  CONSTRAINT `gate_chk_2` CHECK ((`Lunghezza` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gate`
--

LOCK TABLES `gate` WRITE;
/*!40000 ALTER TABLE `gate` DISABLE KEYS */;
/*!40000 ALTER TABLE `gate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itinerario`
--

DROP TABLE IF EXISTS `itinerario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itinerario` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Data_inizio` date NOT NULL,
  `Data_fine` date NOT NULL,
  `Destinazione` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Prezzo` decimal(20,2) NOT NULL,
  PRIMARY KEY (`ID`),
  CONSTRAINT `itinerario_chk_1` CHECK ((`Data_inizio` <= `Data_fine`)),
  CONSTRAINT `itinerario_chk_2` CHECK ((`Prezzo` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itinerario`
--

LOCK TABLES `itinerario` WRITE;
/*!40000 ALTER TABLE `itinerario` DISABLE KEYS */;
/*!40000 ALTER TABLE `itinerario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lingua`
--

DROP TABLE IF EXISTS `lingua`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lingua` (
  `Codice_fiscale` char(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Lingua` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Livello` enum('A1','A2','B1','B2','C1','C2','Nativa') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Codice_fiscale`,`Lingua`),
  CONSTRAINT `lingua_ibfk_1` FOREIGN KEY (`Codice_fiscale`) REFERENCES `assistente_di_volo` (`Codice_fiscale`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lingua`
--

LOCK TABLES `lingua` WRITE;
/*!40000 ALTER TABLE `lingua` DISABLE KEYS */;
/*!40000 ALTER TABLE `lingua` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `magazzino_aeroportuale`
--

DROP TABLE IF EXISTS `magazzino_aeroportuale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `magazzino_aeroportuale` (
  `Nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Posizione` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Tipo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Capacita` double NOT NULL,
  PRIMARY KEY (`Nome`,`Posizione`),
  CONSTRAINT `magazzino_aeroportuale_chk_1` CHECK ((`Capacita` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `magazzino_aeroportuale`
--

LOCK TABLES `magazzino_aeroportuale` WRITE;
/*!40000 ALTER TABLE `magazzino_aeroportuale` DISABLE KEYS */;
/*!40000 ALTER TABLE `magazzino_aeroportuale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merce`
--

DROP TABLE IF EXISTS `merce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merce` (
  `SSCC` char(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Peso` double NOT NULL,
  `Paese` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Categoria` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ID_container` char(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`SSCC`),
  KEY `ID_container` (`ID_container`),
  CONSTRAINT `merce_ibfk_1` FOREIGN KEY (`ID_container`) REFERENCES `container_aereo` (`ID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `merce_chk_1` CHECK ((`Peso` > 0)),
  CONSTRAINT `merce_chk_2` CHECK (regexp_like(`SSCC`,_cp850'^[0-9]{18}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merce`
--

LOCK TABLES `merce` WRITE;
/*!40000 ALTER TABLE `merce` DISABLE KEYS */;
/*!40000 ALTER TABLE `merce` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `aggiorna_peso_container` AFTER INSERT ON `merce` FOR EACH ROW BEGIN UPDATE Container_Aereo SET Container_Aereo.Peso=Container_Aereo.Peso+NEW.Peso WHERE Container_Aereo.ID=NEW.ID_container; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_aggiornamento_tipo_merce` BEFORE UPDATE ON `merce` FOR EACH ROW BEGIN
DECLARE tipo_magazzino VARCHAR(100);
SELECT Magazzino_aeroportuale.Tipo
INTO tipo_magazzino
FROM Stoccaggio JOIN Magazzino_aeroportuale ON Stoccaggio.Nome_magazzino=Magazzino_aeroportuale.Nome AND Stoccaggio.Posizione_magazzino=Magazzino_aeroportuale.Posizione
WHERE Stoccaggio.SSCC=NEW.SSCC;
IF UPPER(NEW.Categoria) <> UPPER(tipo_magazzino) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='La merce risulta stoccata in un magazzino di tipo incompatibile';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_capacita_magazzino3` BEFORE UPDATE ON `merce` FOR EACH ROW BEGIN
DECLARE nome VARCHAR(100);
DECLARE posizione VARCHAR(100);
DECLARE peso_totale DOUBLE;
DECLARE capacita_magazzino DOUBLE;
IF OLD.Peso <> NEW.Peso THEN
SELECT Nome_magazzino, Posizione_magazzino
INTO nome, posizione
FROM Stoccaggio
WHERE Stoccaggio.SSCC=NEW.SSCC;
IF nome IS NOT NULL AND posizione IS NOT NULL THEN
SELECT COALESCE(SUM(Merce.Peso),0)
INTO peso_totale
FROM Merce JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
WHERE Stoccaggio.Nome_magazzino = nome AND Stoccaggio.Posizione_magazzino = posizione;
SELECT Capacita
INTO capacita_magazzino
FROM Magazzino_aeroportuale
WHERE Magazzino_aeroportuale.Nome = nome AND Magazzino_aeroportuale.Posizione = posizione;
IF peso_totale + NEW.Peso - OLD.Peso > capacita_magazzino THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il magazzino non ha abbastanza capacita per stoccare questa merce';
END IF;
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `aggiorna_peso_container2` AFTER UPDATE ON `merce` FOR EACH ROW BEGIN
    IF NEW.ID_container = OLD.ID_container THEN
        UPDATE Container_Aereo
        SET Peso = Peso + NEW.Peso - OLD.Peso
        WHERE ID = NEW.ID_container;
    ELSE
        UPDATE Container_Aereo
        SET Peso = Peso - OLD.Peso
        WHERE ID = OLD.ID_container;

        UPDATE Container_Aereo
        SET Peso = Peso + NEW.Peso
        WHERE ID = NEW.ID_container;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `aggiorna_peso_container3` AFTER DELETE ON `merce` FOR EACH ROW BEGIN UPDATE Container_Aereo SET Container_Aereo.Peso=Container_Aereo.Peso-OLD.Peso WHERE Container_Aereo.ID=OLD.ID_container; END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `passeggero`
--

DROP TABLE IF EXISTS `passeggero`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `passeggero` (
  `Codice_fiscale` char(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Cognome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Data_nascita` date NOT NULL,
  `Telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Codice_fiscale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `passeggero`
--

LOCK TABLES `passeggero` WRITE;
/*!40000 ALTER TABLE `passeggero` DISABLE KEYS */;
/*!40000 ALTER TABLE `passeggero` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posto`
--

DROP TABLE IF EXISTS `posto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posto` (
  `Codice_ICAO` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Numero` int NOT NULL,
  `Classe` enum('Economy','Business','First Class') COLLATE utf8mb4_unicode_ci NOT NULL,
  `Tipologia` enum('Finestrino','Centrale','Corridoio') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Codice_ICAO`,`Numero`),
  CONSTRAINT `posto_ibfk_1` FOREIGN KEY (`Codice_ICAO`) REFERENCES `aereo` (`Codice_ICAO`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posto_chk_1` CHECK ((`Numero` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posto`
--

LOCK TABLES `posto` WRITE;
/*!40000 ALTER TABLE `posto` DISABLE KEYS */;
/*!40000 ALTER TABLE `posto` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_tipo_aereo_posto` BEFORE INSERT ON `posto` FOR EACH ROW BEGIN
DECLARE tipo_aereo VARCHAR(15);
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF tipo_aereo <> 'Passeggeri' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non viene suddiviso in posti';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_capienza_aereo` BEFORE INSERT ON `posto` FOR EACH ROW BEGIN
DECLARE capienza_aereo INT;
DECLARE numero_posti INT;
SELECT Capienza
INTO capienza_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
SELECT COUNT(*)
INTO numero_posti
FROM Posto
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF numero_posti+1 > capienza_aereo THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='L''aereo non ha abbastanza capienza';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_tipo_aereo_posto2` BEFORE UPDATE ON `posto` FOR EACH ROW BEGIN
DECLARE tipo_aereo VARCHAR(15);
IF NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF tipo_aereo <> 'Passeggeri' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non viene suddiviso in posti';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_capienza_aereo2` BEFORE UPDATE ON `posto` FOR EACH ROW BEGIN
DECLARE capienza_aereo INT;
DECLARE numero_posti INT;
IF NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT Capienza
INTO capienza_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
SELECT COUNT(*)
INTO numero_posti
FROM Posto
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF numero_posti+1 > capienza_aereo THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='L''aereo non ha abbastanza capienza';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `prenotazione`
--

DROP TABLE IF EXISTS `prenotazione`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prenotazione` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Codice_ICAO` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Numero` int NOT NULL,
  `Codice_fiscale` char(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Data_inizio` date NOT NULL,
  `Scadenza` date NOT NULL,
  `Bagaglio_extra` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `Codice_ICAO` (`Codice_ICAO`,`Numero`),
  KEY `Codice_fiscale` (`Codice_fiscale`),
  CONSTRAINT `prenotazione_ibfk_1` FOREIGN KEY (`Codice_ICAO`, `Numero`) REFERENCES `posto` (`Codice_ICAO`, `Numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `prenotazione_ibfk_2` FOREIGN KEY (`Codice_fiscale`) REFERENCES `passeggero` (`Codice_fiscale`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `prenotazione_chk_1` CHECK ((`Data_inizio` <= `Scadenza`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prenotazione`
--

LOCK TABLES `prenotazione` WRITE;
/*!40000 ALTER TABLE `prenotazione` DISABLE KEYS */;
/*!40000 ALTER TABLE `prenotazione` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_itinerario_prenotazione` BEFORE INSERT ON `prenotazione` FOR EACH ROW BEGIN
DECLARE itinerario INT;
SELECT ID_itinerario
INTO itinerario
FROM Aereo
WHERE Codice_ICAO=NEW.Codice_ICAO;
IF itinerario IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Non risulta possibile prenotare un posto su un aereo senza itinerario";
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_date_prenotazione` BEFORE INSERT ON `prenotazione` FOR EACH ROW BEGIN
DECLARE inizio DATE;
DECLARE fine DATE;
SELECT Itinerario.Data_inizio, Itinerario.Data_fine
INTO inizio, fine
FROM Aereo JOIN Itinerario ON Aereo.ID_itinerario = Itinerario.ID
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF NEW.Data_inizio < inizio OR NEW.Scadenza > fine THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Le date non sono valide per l''itinerario prenotato';
ELSEIF EXISTS(
SELECT *
FROM Prenotazione
WHERE Codice_ICAO=NEW.Codice_ICAO AND Numero=NEW.Numero AND NOT(NEW.Data_inizio>=Scadenza OR NEW.Scadenza<=Data_inizio)) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il posto selezionato risulta prenotato per questo intervallo di tempo';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_itinerario_prenotazione2` BEFORE UPDATE ON `prenotazione` FOR EACH ROW BEGIN
DECLARE itinerario INT;
IF NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT ID_itinerario
INTO itinerario
FROM Aereo
WHERE Codice_ICAO=NEW.Codice_ICAO;
IF itinerario IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Non risulta possibile prenotare un posto su un aereo senza itinerario";
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_date_prenotazione2` BEFORE UPDATE ON `prenotazione` FOR EACH ROW BEGIN
DECLARE inizio DATE;
DECLARE fine DATE;
IF NEW.Data_inizio < OLD.Data_inizio OR NEW.Scadenza > OLD.Scadenza OR NEW.Codice_ICAO <> OLD.Codice_ICAO OR NEW.Numero <> OLD.Numero THEN
SELECT Itinerario.Data_inizio, Itinerario.Data_fine
INTO inizio, fine
FROM Aereo JOIN Itinerario ON Aereo.ID_itinerario = Itinerario.ID
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF NEW.Data_inizio < inizio OR NEW.Scadenza > fine THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Le date non sono valide per l''itinerario prenotato';
ELSEIF EXISTS(
SELECT *
FROM Prenotazione
WHERE Codice_ICAO=NEW.Codice_ICAO AND Numero=NEW.Numero AND NOT(NEW.Data_inizio>=Scadenza OR NEW.Scadenza<=Data_inizio) AND ID <> OLD.ID) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il posto selezionato risulta prenotato per questo intervallo di tempo';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `scali`
--

DROP TABLE IF EXISTS `scali`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scali` (
  `ID_itinerario` int NOT NULL,
  `Nome_scalo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`ID_itinerario`,`Nome_scalo`),
  CONSTRAINT `scali_ibfk_1` FOREIGN KEY (`ID_itinerario`) REFERENCES `itinerario` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scali`
--

LOCK TABLES `scali` WRITE;
/*!40000 ALTER TABLE `scali` DISABLE KEYS */;
/*!40000 ALTER TABLE `scali` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stoccaggio`
--

DROP TABLE IF EXISTS `stoccaggio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stoccaggio` (
  `SSCC` char(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Nome_magazzino` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Posizione_magazzino` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`SSCC`),
  KEY `Nome_magazzino` (`Nome_magazzino`,`Posizione_magazzino`),
  CONSTRAINT `stoccaggio_ibfk_1` FOREIGN KEY (`Nome_magazzino`, `Posizione_magazzino`) REFERENCES `magazzino_aeroportuale` (`Nome`, `Posizione`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `stoccaggio_ibfk_2` FOREIGN KEY (`SSCC`) REFERENCES `merce` (`SSCC`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stoccaggio`
--

LOCK TABLES `stoccaggio` WRITE;
/*!40000 ALTER TABLE `stoccaggio` DISABLE KEYS */;
/*!40000 ALTER TABLE `stoccaggio` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controlla_tipo_merce_e_magazzino` BEFORE INSERT ON `stoccaggio` FOR EACH ROW BEGIN
    DECLARE tipo_merce VARCHAR(100);
    DECLARE tipo_magazzino VARCHAR(100);

    SELECT Categoria
    INTO tipo_merce
    FROM Merce
    WHERE Merce.SSCC = NEW.SSCC;

    SELECT Tipo
    INTO tipo_magazzino
    FROM Magazzino_aeroportuale
    WHERE Magazzino_aeroportuale.Nome = NEW.Nome_magazzino
      AND Magazzino_aeroportuale.Posizione = NEW.Posizione_magazzino;

    IF UPPER(tipo_merce) <> UPPER(tipo_magazzino) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il magazzino selezionato non stocca questo tipo di merce';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_capacita_magazzino` BEFORE INSERT ON `stoccaggio` FOR EACH ROW BEGIN
DECLARE peso_totale DOUBLE;
DECLARE nuovo_peso DOUBLE;
DECLARE capacita_magazzino DOUBLE;
SELECT COALESCE(SUM(Merce.Peso),0)
INTO peso_totale
FROM Merce JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
WHERE Stoccaggio.Nome_magazzino = NEW.Nome_magazzino AND Stoccaggio.Posizione_magazzino = NEW.Posizione_magazzino;
SELECT Merce.Peso
INTO nuovo_peso
FROM Merce
WHERE Merce.SSCC=NEW.SSCC;
SELECT Capacita
INTO capacita_magazzino
FROM Magazzino_aeroportuale
WHERE Magazzino_aeroportuale.Nome=NEW.Nome_magazzino AND Magazzino_aeroportuale.Posizione=NEW.Posizione_magazzino;
IF peso_totale+nuovo_peso > capacita_magazzino THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il magazzino non ha abbastanza capacita per stoccare questa merce';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controlla_tipo_merce_e_magazzino2` BEFORE UPDATE ON `stoccaggio` FOR EACH ROW BEGIN
DECLARE tipo_merce VARCHAR(100);
DECLARE tipo_magazzino VARCHAR(100);
SELECT Categoria INTO tipo_merce
FROM Merce
WHERE Merce.SSCC=NEW.SSCC;
SELECT Tipo INTO tipo_magazzino
FROM Magazzino_aeroportuale
WHERE NEW.Nome_magazzino=Magazzino_aeroportuale.Nome AND NEW.Posizione_magazzino=Magazzino_aeroportuale.Posizione;
IF UPPER(tipo_merce) <> UPPER(tipo_magazzino) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il magazzino selezionato non stocca questo tipo di merce';
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_capacita_magazzino2` BEFORE UPDATE ON `stoccaggio` FOR EACH ROW BEGIN
    DECLARE peso_totale DOUBLE;
    DECLARE nuovo_peso DOUBLE;
    DECLARE capacita_magazzino DOUBLE;

    SELECT Merce.Peso
    INTO nuovo_peso
    FROM Merce
    WHERE Merce.SSCC = NEW.SSCC;

    SELECT COALESCE(SUM(Merce.Peso),0)
    INTO peso_totale
    FROM Merce
    JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
    WHERE Stoccaggio.Nome_magazzino = NEW.Nome_magazzino
      AND Stoccaggio.Posizione_magazzino = NEW.Posizione_magazzino
      AND Merce.SSCC <> OLD.SSCC;

    SELECT Capacita
    INTO capacita_magazzino
    FROM Magazzino_aeroportuale
    WHERE Magazzino_aeroportuale.Nome = NEW.Nome_magazzino
      AND Magazzino_aeroportuale.Posizione = NEW.Posizione_magazzino;

    IF peso_totale + nuovo_peso > capacita_magazzino THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il magazzino non ha abbastanza capacita per stoccare questa merce';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-17  0:52:14
