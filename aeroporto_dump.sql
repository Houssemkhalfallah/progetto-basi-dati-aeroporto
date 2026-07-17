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
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `inizializzazione_contatori_aereo` BEFORE INSERT ON `aereo` FOR EACH ROW BEGIN
IF NEW.Tipo='Trasporto merci' THEN
SET NEW.Peso_occupato=0, NEW.Volume_occupato=0;
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `rimuovi_prenotazioni` AFTER UPDATE ON `aereo` FOR EACH ROW BEGIN
IF NOT(OLD.ID_itinerario <=> NEW.ID_itinerario) AND OLD.ID_itinerario IS NOT NULL THEN
DELETE
FROM Prenotazione
WHERE Codice_ICAO = NEW.Codice_ICAO;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `aeroporto_useraereo`
--

DROP TABLE IF EXISTS `aeroporto_useraereo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeroporto_useraereo` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `aereo_id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aeroporto_useraereo_user_id_aereo_id_31eb1be9_uniq` (`user_id`,`aereo_id`),
  KEY `aeroporto_useraereo_aereo_id_67d1b1aa_fk_aereo_Codice_ICAO` (`aereo_id`),
  CONSTRAINT `aeroporto_useraereo_aereo_id_67d1b1aa_fk_aereo_Codice_ICAO` FOREIGN KEY (`aereo_id`) REFERENCES `aereo` (`Codice_ICAO`),
  CONSTRAINT `aeroporto_useraereo_user_id_9d46458f_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporto_useraereo`
--

LOCK TABLES `aeroporto_useraereo` WRITE;
/*!40000 ALTER TABLE `aeroporto_useraereo` DISABLE KEYS */;
/*!40000 ALTER TABLE `aeroporto_useraereo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aeroporto_userassistentedivolo`
--

DROP TABLE IF EXISTS `aeroporto_userassistentedivolo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeroporto_userassistentedivolo` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assistente_id` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aeroporto_userassistente_user_id_assistente_id_4ac42177_uniq` (`user_id`,`assistente_id`),
  KEY `aeroporto_userassist_assistente_id_051d5dd6_fk_assistent` (`assistente_id`),
  CONSTRAINT `aeroporto_userassist_assistente_id_051d5dd6_fk_assistent` FOREIGN KEY (`assistente_id`) REFERENCES `assistente_di_volo` (`Codice_fiscale`),
  CONSTRAINT `aeroporto_userassistentedivolo_user_id_f165799c_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporto_userassistentedivolo`
--

LOCK TABLES `aeroporto_userassistentedivolo` WRITE;
/*!40000 ALTER TABLE `aeroporto_userassistentedivolo` DISABLE KEYS */;
/*!40000 ALTER TABLE `aeroporto_userassistentedivolo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aeroporto_usergate`
--

DROP TABLE IF EXISTS `aeroporto_usergate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeroporto_usergate` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `numero_gate` int NOT NULL,
  `terminal_gate` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aeroporto_usergate_user_id_numero_gate_term_a98b9b32_uniq` (`user_id`,`numero_gate`,`terminal_gate`),
  CONSTRAINT `aeroporto_usergate_user_id_0a9e543d_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporto_usergate`
--

LOCK TABLES `aeroporto_usergate` WRITE;
/*!40000 ALTER TABLE `aeroporto_usergate` DISABLE KEYS */;
INSERT INTO `aeroporto_usergate` VALUES (2,3,'T2',4),(3,7,'T1',4),(1,12,'T1',4);
/*!40000 ALTER TABLE `aeroporto_usergate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aeroporto_useritinerario`
--

DROP TABLE IF EXISTS `aeroporto_useritinerario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeroporto_useritinerario` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `itinerario_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aeroporto_useritinerario_user_id_itinerario_id_537c8a00_uniq` (`user_id`,`itinerario_id`),
  KEY `aeroporto_useritinerario_itinerario_id_0eea3d3c_fk_itinerario_ID` (`itinerario_id`),
  CONSTRAINT `aeroporto_useritinerario_itinerario_id_0eea3d3c_fk_itinerario_ID` FOREIGN KEY (`itinerario_id`) REFERENCES `itinerario` (`ID`),
  CONSTRAINT `aeroporto_useritinerario_user_id_3b083bb9_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporto_useritinerario`
--

LOCK TABLES `aeroporto_useritinerario` WRITE;
/*!40000 ALTER TABLE `aeroporto_useritinerario` DISABLE KEYS */;
/*!40000 ALTER TABLE `aeroporto_useritinerario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aeroporto_usermagazzinoaeroportuale`
--

DROP TABLE IF EXISTS `aeroporto_usermagazzinoaeroportuale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeroporto_usermagazzinoaeroportuale` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nome_magazzino` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `posizione_magazzino` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aeroporto_usermagazzinoa_user_id_nome_magazzino_p_546b88ec_uniq` (`user_id`,`nome_magazzino`,`posizione_magazzino`),
  CONSTRAINT `aeroporto_usermagazz_user_id_8e8fd1c2_fk_auth_user` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporto_usermagazzinoaeroportuale`
--

LOCK TABLES `aeroporto_usermagazzinoaeroportuale` WRITE;
/*!40000 ALTER TABLE `aeroporto_usermagazzinoaeroportuale` DISABLE KEYS */;
/*!40000 ALTER TABLE `aeroporto_usermagazzinoaeroportuale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aeroporto_userpasseggero`
--

DROP TABLE IF EXISTS `aeroporto_userpasseggero`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aeroporto_userpasseggero` (
  `user_id` int NOT NULL,
  `passeggero_id` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `passeggero_id` (`passeggero_id`),
  CONSTRAINT `aeroporto_userpasseg_passeggero_id_154a5e03_fk_passegger` FOREIGN KEY (`passeggero_id`) REFERENCES `passeggero` (`Codice_fiscale`),
  CONSTRAINT `aeroporto_userpasseggero_user_id_c0a85011_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aeroporto_userpasseggero`
--

LOCK TABLES `aeroporto_userpasseggero` WRITE;
/*!40000 ALTER TABLE `aeroporto_userpasseggero` DISABLE KEYS */;
INSERT INTO `aeroporto_userpasseggero` VALUES (2,'khlhsm01r07f923e');
/*!40000 ALTER TABLE `aeroporto_userpasseggero` ENABLE KEYS */;
UNLOCK TABLES;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_codice_fiscale_assistente` BEFORE INSERT ON `assistente_di_volo` FOR EACH ROW BEGIN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Passeggero) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un passeggero";
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_codice_fiscale_assistente2` BEFORE UPDATE ON `assistente_di_volo` FOR EACH ROW BEGIN
IF NEW.Codice_fiscale <> OLD.Codice_fiscale THEN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Passeggero) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un passeggero";
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
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',3,'add_permission'),(6,'Can change permission',3,'change_permission'),(7,'Can delete permission',3,'delete_permission'),(8,'Can view permission',3,'view_permission'),(9,'Can add group',2,'add_group'),(10,'Can change group',2,'change_group'),(11,'Can delete group',2,'delete_group'),(12,'Can view group',2,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add container aereo',9,'add_containeraereo'),(26,'Can change container aereo',9,'change_containeraereo'),(27,'Can delete container aereo',9,'delete_containeraereo'),(28,'Can view container aereo',9,'view_containeraereo'),(29,'Can add gate',10,'add_gate'),(30,'Can change gate',10,'change_gate'),(31,'Can delete gate',10,'delete_gate'),(32,'Can view gate',10,'view_gate'),(33,'Can add lingua',12,'add_lingua'),(34,'Can change lingua',12,'change_lingua'),(35,'Can delete lingua',12,'delete_lingua'),(36,'Can view lingua',12,'view_lingua'),(37,'Can add magazzino aeroportuale',13,'add_magazzinoaeroportuale'),(38,'Can change magazzino aeroportuale',13,'change_magazzinoaeroportuale'),(39,'Can delete magazzino aeroportuale',13,'delete_magazzinoaeroportuale'),(40,'Can view magazzino aeroportuale',13,'view_magazzinoaeroportuale'),(41,'Can add posto',16,'add_posto'),(42,'Can change posto',16,'change_posto'),(43,'Can delete posto',16,'delete_posto'),(44,'Can view posto',16,'view_posto'),(45,'Can add prenotazione',17,'add_prenotazione'),(46,'Can change prenotazione',17,'change_prenotazione'),(47,'Can delete prenotazione',17,'delete_prenotazione'),(48,'Can view prenotazione',17,'view_prenotazione'),(49,'Can add scali',18,'add_scali'),(50,'Can change scali',18,'change_scali'),(51,'Can delete scali',18,'delete_scali'),(52,'Can view scali',18,'view_scali'),(53,'Can add merce',14,'add_merce'),(54,'Can change merce',14,'change_merce'),(55,'Can delete merce',14,'delete_merce'),(56,'Can view merce',14,'view_merce'),(57,'Can add stoccaggio',19,'add_stoccaggio'),(58,'Can change stoccaggio',19,'change_stoccaggio'),(59,'Can delete stoccaggio',19,'delete_stoccaggio'),(60,'Can view stoccaggio',19,'view_stoccaggio'),(61,'Can add user aereo',20,'add_useraereo'),(62,'Can change user aereo',20,'change_useraereo'),(63,'Can delete user aereo',20,'delete_useraereo'),(64,'Can view user aereo',20,'view_useraereo'),(65,'Can add aereo',7,'add_aereo'),(66,'Can change aereo',7,'change_aereo'),(67,'Can delete aereo',7,'delete_aereo'),(68,'Can view aereo',7,'view_aereo'),(69,'Can add user itinerario',23,'add_useritinerario'),(70,'Can change user itinerario',23,'change_useritinerario'),(71,'Can delete user itinerario',23,'delete_useritinerario'),(72,'Can view user itinerario',23,'view_useritinerario'),(73,'Can add user assistente di volo',21,'add_userassistentedivolo'),(74,'Can change user assistente di volo',21,'change_userassistentedivolo'),(75,'Can delete user assistente di volo',21,'delete_userassistentedivolo'),(76,'Can view user assistente di volo',21,'view_userassistentedivolo'),(77,'Can add user magazzino aeroportuale',24,'add_usermagazzinoaeroportuale'),(78,'Can change user magazzino aeroportuale',24,'change_usermagazzinoaeroportuale'),(79,'Can delete user magazzino aeroportuale',24,'delete_usermagazzinoaeroportuale'),(80,'Can view user magazzino aeroportuale',24,'view_usermagazzinoaeroportuale'),(81,'Can add itinerario',11,'add_itinerario'),(82,'Can change itinerario',11,'change_itinerario'),(83,'Can delete itinerario',11,'delete_itinerario'),(84,'Can view itinerario',11,'view_itinerario'),(85,'Can add assistente di volo',8,'add_assistentedivolo'),(86,'Can change assistente di volo',8,'change_assistentedivolo'),(87,'Can delete assistente di volo',8,'delete_assistentedivolo'),(88,'Can view assistente di volo',8,'view_assistentedivolo'),(89,'Can add user gate',22,'add_usergate'),(90,'Can change user gate',22,'change_usergate'),(91,'Can delete user gate',22,'delete_usergate'),(92,'Can view user gate',22,'view_usergate'),(93,'Can add passeggero',15,'add_passeggero'),(94,'Can change passeggero',15,'change_passeggero'),(95,'Can delete passeggero',15,'delete_passeggero'),(96,'Can view passeggero',15,'view_passeggero'),(97,'Can add user passeggero',25,'add_userpasseggero'),(98,'Can change user passeggero',25,'change_userpasseggero'),(99,'Can delete user passeggero',25,'delete_userpasseggero'),(100,'Can view user passeggero',25,'view_userpasseggero');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$1200000$KmSqrx65onu6ZviSqx6miD$6M85IHSjAKklZAJnvV3Jvwi1DOop63w0OkKukdODmTs=','2026-07-16 20:52:13.651810',1,'houss','','','houssemkhalfallah39@gmail.com',1,1,'2026-07-16 20:08:29.741584'),(2,'pbkdf2_sha256$1200000$z0pYy2vMXuSYWb6BMUdLLg$CAVeeYC2UklSOaQFyuWp2k7wt+dyx+PsNwCpr9iJIR0=','2026-07-16 23:03:44.671940',0,'Angelica','','','',0,1,'2026-07-16 20:43:39.947324'),(3,'pbkdf2_sha256$1200000$MTq7PDV7Nr3QswSRBYZps8$2HApoqNCIFNtSYNB/aeXyGPlaZKLFRg57+XrGJZPwsI=','2026-07-16 21:05:05.630541',0,'nicola','','','',0,1,'2026-07-16 21:04:19.747613'),(4,'pbkdf2_sha256$1200000$jJmoLNZZOBB9KvmXWcShq0$BANwNZ8tjXS9GLLYP2QGC8RdEF5xrhb87k26jiyzSgo=','2026-07-17 06:06:33.395183',0,'carmine','','','',0,1,'2026-07-17 06:06:02.572971');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
INSERT INTO `auth_user_groups` VALUES (1,2,1),(2,3,1),(3,4,2);
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `elimina_merce_non_stoccata` AFTER DELETE ON `container_aereo` FOR EACH ROW BEGIN
    DELETE Merce
    FROM Merce
    LEFT JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
    WHERE Merce.ID_container = OLD.ID
      AND Stoccaggio.Nome_magazzino IS NULL;
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(7,'aeroporto','aereo'),(8,'aeroporto','assistentedivolo'),(9,'aeroporto','containeraereo'),(10,'aeroporto','gate'),(11,'aeroporto','itinerario'),(12,'aeroporto','lingua'),(13,'aeroporto','magazzinoaeroportuale'),(14,'aeroporto','merce'),(15,'aeroporto','passeggero'),(16,'aeroporto','posto'),(17,'aeroporto','prenotazione'),(18,'aeroporto','scali'),(19,'aeroporto','stoccaggio'),(20,'aeroporto','useraereo'),(21,'aeroporto','userassistentedivolo'),(22,'aeroporto','usergate'),(23,'aeroporto','useritinerario'),(24,'aeroporto','usermagazzinoaeroportuale'),(25,'aeroporto','userpasseggero'),(2,'auth','group'),(3,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(6,'sessions','session');
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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-07-16 18:37:51.056278'),(2,'auth','0001_initial','2026-07-16 18:37:51.455752'),(3,'admin','0001_initial','2026-07-16 18:37:51.582861'),(4,'admin','0002_logentry_remove_auto_add','2026-07-16 18:37:51.587173'),(5,'admin','0003_logentry_add_action_flag_choices','2026-07-16 18:37:51.590855'),(6,'contenttypes','0002_remove_content_type_name','2026-07-16 18:37:51.659518'),(7,'auth','0002_alter_permission_name_max_length','2026-07-16 18:37:51.702837'),(8,'auth','0003_alter_user_email_max_length','2026-07-16 18:37:51.713862'),(9,'auth','0004_alter_user_username_opts','2026-07-16 18:37:51.718563'),(10,'auth','0005_alter_user_last_login_null','2026-07-16 18:37:51.755036'),(11,'auth','0006_require_contenttypes_0002','2026-07-16 18:37:51.756838'),(12,'auth','0007_alter_validators_add_error_messages','2026-07-16 18:37:51.761106'),(13,'auth','0008_alter_user_username_max_length','2026-07-16 18:37:51.807948'),(14,'auth','0009_alter_user_last_name_max_length','2026-07-16 18:37:51.858861'),(15,'auth','0010_alter_group_name_max_length','2026-07-16 18:37:51.871345'),(16,'auth','0011_update_proxy_permissions','2026-07-16 18:37:51.875833'),(17,'auth','0012_alter_user_first_name_max_length','2026-07-16 18:37:51.918705'),(18,'sessions','0001_initial','2026-07-16 18:37:51.941821'),(19,'aeroporto','0001_initial','2026-07-16 23:09:04.072100');
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
INSERT INTO `django_session` VALUES ('eppg4rix1cwhs1vd12y9i3jcw7yybnld','.eJxVjDEOgzAMAP_iuYowJA4wdu8bkLFNoa0SicBU9e8VEkO73p3uDQPv2zzsxdZhUejBw-WXjSxPS4fQB6d7dpLTti6jOxJ32uJuWe11Pdu_wcxlhh4iia8nq9Aic6AGWVqqJXqpTdEQvVShrbpAHWKkaQyknXrl1segUwOfL9d7N3k:1wkbiT:pAHoje8KQAPTdsRnBE9rUYbHYCtKcqF4ykNpznHKoYg','2026-07-31 06:06:33.398646'),('gjvg1prbk2bvnq6txocuchenczrwv6pi','.eJxVjLsOwjAMAP_FM4oSu0ncjux8Q5XELimgVupjQvw7qtQB1rvTvaFP-1b7fdWlHwU6QLj8spzKU6dDyCNN99mUedqWMZsjMaddzW0WfV3P9m9Q01qhA27QkneKiJmGHDgphULYikoTLVPyMbSog3O2ZRskkrCnyL7EwJrh8wW5hTbF:1wkV7I:OFj-VxRwIYxM2WBgg2BFKLqeP-yB-18m4R-_B82qAls','2026-07-30 23:03:44.677672');
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
INSERT INTO `gate` VALUES (3,'T2','Trasporto merci',80),(7,'T1','Passeggeri',72),(12,'T1','Passeggeri',65);
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `aggiorna_prenotazioni` AFTER UPDATE ON `itinerario` FOR EACH ROW BEGIN
IF NEW.Data_inizio <> OLD.Data_inizio OR NEW.Data_fine <> OLD.Data_fine THEN
UPDATE Prenotazione
SET Data_inizio = NEW.Data_inizio, Scadenza = NEW.Data_fine
WHERE Codice_ICAO IN (SELECT Codice_ICAO FROM Aereo WHERE ID_itinerario = NEW.ID);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `cancella_prenotazione` BEFORE DELETE ON `itinerario` FOR EACH ROW BEGIN
DELETE Prenotazione
FROM Aereo JOIN Prenotazione ON Prenotazione.Codice_ICAO = Aereo.Codice_ICAO
WHERE Aereo.ID_itinerario = OLD.ID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controlla_aggiornamento_tipo_magazzino` BEFORE UPDATE ON `magazzino_aeroportuale` FOR EACH ROW BEGIN
DECLARE numero_riferimenti INT;
IF UPPER(NEW.Tipo) <> UPPER(OLD.Tipo) THEN
SELECT COUNT(Stoccaggio.SSCC)
INTO numero_riferimenti
FROM Stoccaggio
WHERE Stoccaggio.Nome_magazzino = OLD.Nome AND Stoccaggio.Posizione_magazzino = OLD.Posizione;
IF numero_riferimenti > 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Non risulta consentito modificare il tipo di un magazzino contenente delle merci';
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
INSERT INTO `passeggero` VALUES ('khlhsm01r07f923e','angelica','bianco','2001-10-06','3894420398');
/*!40000 ALTER TABLE `passeggero` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_codice_fiscale_passeggero` BEFORE INSERT ON `passeggero` FOR EACH ROW BEGIN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Assistente_di_volo) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un assistente di volo";
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
/*!50003 CREATE*/ /*!50017 DEFINER=`django`@`localhost`*/ /*!50003 TRIGGER `controllo_codice_fiscale_passeggero2` BEFORE UPDATE ON `passeggero` FOR EACH ROW BEGIN
IF NEW.Codice_fiscale <> OLD.Codice_fiscale THEN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Assistente_di_volo) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un assistente di volo";
END IF;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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

-- Dump completed on 2026-07-17  9:13:25
