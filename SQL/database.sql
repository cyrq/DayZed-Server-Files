-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Wersja serwera:               5.6.13 - MySQL Community Server (GPL)
-- Serwer OS:                    Win64
-- HeidiSQL Wersja:              8.1.0.4545
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Zrzut struktury bazy danych dayzed
DROP DATABASE IF EXISTS `dayzed`;
CREATE DATABASE IF NOT EXISTS `dayzed` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `dayzed`;


-- Zrzut struktury tabela dayzed.deployable
DROP TABLE IF EXISTS `deployable`;
CREATE TABLE IF NOT EXISTS `deployable` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `class_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq1_deployable` (`class_name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.deployable: ~15 rows (około)
/*!40000 ALTER TABLE `deployable` DISABLE KEYS */;
INSERT INTO `deployable` (`id`, `class_name`) VALUES
	(2, 'BearTrap_DZ'),
	(9, 'CamoNet_DZ'),
	(8, 'DomeTentStorage'),
	(4, 'Hedgehog_DZ'),
	(5, 'Sandbag1_DZ'),
	(7, 'StashMedium'),
	(6, 'StashSmall'),
	(16, 'StorageBox'),
	(1, 'TentStorage'),
	(15, 'TrapBearTrapFlare'),
	(12, 'TrapBearTrapSmoke'),
	(11, 'TrapTripwireFlare'),
	(13, 'TrapTripwireGrenade'),
	(14, 'TrapTripwireSmoke'),
	(10, 'Trap_Cans'),
	(3, 'Wire_cat1');
/*!40000 ALTER TABLE `deployable` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.instance
DROP TABLE IF EXISTS `instance`;
CREATE TABLE IF NOT EXISTS `instance` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `world_id` smallint(5) unsigned NOT NULL DEFAULT '1',
  `inventory` varchar(2048) NOT NULL DEFAULT '[]',
  `backpack` varchar(2048) NOT NULL DEFAULT '["DZ_Patrol_Pack_EP1",[[],[]],[[],[]]]',
  PRIMARY KEY (`id`),
  KEY `fk1_instance` (`world_id`),
  CONSTRAINT `instance_ibfk_1` FOREIGN KEY (`world_id`) REFERENCES `world` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.instance: ~0 rows (około)
/*!40000 ALTER TABLE `instance` DISABLE KEYS */;
INSERT INTO `instance` (`id`, `world_id`, `inventory`, `backpack`) VALUES
	(1, 1, '[[],[\'ItemPainkiller\',\'ItemBandage\']]', '[\'DZ_Patrol_Pack_EP1\',[[],[]],[[],[]]]');
/*!40000 ALTER TABLE `instance` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.instance_deployable
DROP TABLE IF EXISTS `instance_deployable`;
CREATE TABLE IF NOT EXISTS `instance_deployable` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(60) NOT NULL,
  `deployable_id` smallint(5) unsigned NOT NULL,
  `owner_id` int(10) unsigned NOT NULL,
  `instance_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `worldspace` varchar(60) NOT NULL DEFAULT '[0,[0,0,0]]',
  `inventory` varchar(2048) NOT NULL DEFAULT '[]',
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Hitpoints` varchar(500) NOT NULL DEFAULT '[]',
  `Fuel` double(13,0) NOT NULL DEFAULT '0',
  `Damage` double(13,0) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx1_instance_deployable` (`deployable_id`),
  KEY `idx2_instance_deployable` (`owner_id`),
  KEY `idx3_instance_deployable` (`instance_id`),
  CONSTRAINT `instance_deployable_ibfk_1` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`),
  CONSTRAINT `instance_deployable_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `survivor` (`id`),
  CONSTRAINT `instance_deployable_ibfk_3` FOREIGN KEY (`deployable_id`) REFERENCES `deployable` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.instance_deployable: ~0 rows (około)
/*!40000 ALTER TABLE `instance_deployable` DISABLE KEYS */;
/*!40000 ALTER TABLE `instance_deployable` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.instance_vehicle
DROP TABLE IF EXISTS `instance_vehicle`;
CREATE TABLE IF NOT EXISTS `instance_vehicle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `world_vehicle_id` bigint(20) unsigned NOT NULL,
  `instance_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `worldspace` varchar(60) NOT NULL DEFAULT '[0,[0,0,0]]',
  `inventory` varchar(2048) NOT NULL DEFAULT '[]',
  `parts` varchar(1024) NOT NULL DEFAULT '[]',
  `fuel` double NOT NULL DEFAULT '0',
  `damage` double NOT NULL DEFAULT '0',
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `idx3_instance_vehicle` (`instance_id`),
  KEY `fk3_instance_vehicle` (`world_vehicle_id`),
  CONSTRAINT `fk3_instance_vehicle` FOREIGN KEY (`world_vehicle_id`) REFERENCES `world_vehicle` (`id`),
  CONSTRAINT `instance_vehicle_ibfk_1` FOREIGN KEY (`instance_id`) REFERENCES `instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.instance_vehicle: ~0 rows (około)
/*!40000 ALTER TABLE `instance_vehicle` DISABLE KEYS */;
/*!40000 ALTER TABLE `instance_vehicle` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.log_code
DROP TABLE IF EXISTS `log_code`;
CREATE TABLE IF NOT EXISTS `log_code` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_log_code` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.log_code: ~5 rows (około)
/*!40000 ALTER TABLE `log_code` DISABLE KEYS */;
INSERT INTO `log_code` (`id`, `name`, `description`) VALUES
	(1, 'Login', 'Player has logged in'),
	(2, 'Logout', 'Player has logged out'),
	(3, 'Ban', 'Player was banned'),
	(4, 'Connect', 'Player has connected'),
	(5, 'Disconnect', 'Player has disconnected');
/*!40000 ALTER TABLE `log_code` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.log_entry
DROP TABLE IF EXISTS `log_entry`;
CREATE TABLE IF NOT EXISTS `log_entry` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(128) NOT NULL DEFAULT '',
  `log_code_id` int(11) unsigned NOT NULL,
  `text` varchar(1024) DEFAULT '',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `instance_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk1_log_entry` (`log_code_id`),
  CONSTRAINT `fk1_log_entry` FOREIGN KEY (`log_code_id`) REFERENCES `log_code` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.log_entry: ~0 rows (około)
/*!40000 ALTER TABLE `log_entry` DISABLE KEYS */;
/*!40000 ALTER TABLE `log_entry` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.migration_schema_log
DROP TABLE IF EXISTS `migration_schema_log`;
CREATE TABLE IF NOT EXISTS `migration_schema_log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `schema_name` varchar(255) NOT NULL,
  `event_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `old_version` varchar(255) NOT NULL,
  `new_version` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.migration_schema_log: ~46 rows (około)
/*!40000 ALTER TABLE `migration_schema_log` DISABLE KEYS */;
INSERT INTO `migration_schema_log` (`id`, `schema_name`, `event_time`, `old_version`, `new_version`) VALUES
	(1, 'Reality', '2013-10-30 00:39:30', '0.000000', '0.010000'),
	(2, 'Reality', '2013-10-30 00:39:31', '0.010000', '0.020000'),
	(3, 'Reality', '2013-10-30 00:39:31', '0.020000', '0.030000'),
	(4, 'Reality', '2013-10-30 00:39:31', '0.030000', '0.040000'),
	(5, 'Reality', '2013-10-30 00:39:36', '0.040000', '0.050000'),
	(6, 'Reality', '2013-10-30 00:39:36', '0.050000', '0.060000'),
	(7, 'Reality', '2013-10-30 00:39:36', '0.060000', '0.070000'),
	(8, 'Reality', '2013-10-30 00:39:36', '0.070000', '0.080000'),
	(9, 'Reality', '2013-10-30 00:39:36', '0.080000', '0.090000'),
	(10, 'Reality', '2013-10-30 00:39:36', '0.090000', '0.100000'),
	(11, 'Reality', '2013-10-30 00:39:36', '0.100000', '0.110000'),
	(12, 'Reality', '2013-10-30 00:39:36', '0.110000', '0.120000'),
	(13, 'Reality', '2013-10-30 00:39:36', '0.120000', '0.130000'),
	(14, 'Reality', '2013-10-30 00:39:36', '0.130000', '0.140000'),
	(15, 'Reality', '2013-10-30 00:39:36', '0.140000', '0.150000'),
	(16, 'Reality', '2013-10-30 00:39:36', '0.150000', '0.160000'),
	(17, 'Reality', '2013-10-30 00:39:36', '0.160000', '0.170000'),
	(18, 'Reality', '2013-10-30 00:39:36', '0.170000', '0.180000'),
	(19, 'Reality', '2013-10-30 00:39:36', '0.180000', '0.190000'),
	(20, 'Reality', '2013-10-30 00:39:37', '0.190000', '0.200000'),
	(21, 'Reality', '2013-10-30 00:39:37', '0.200000', '0.210000'),
	(22, 'Reality', '2013-10-30 00:39:37', '0.210000', '0.220000'),
	(23, 'Reality', '2013-10-30 00:39:37', '0.220000', '0.230000'),
	(24, 'Reality', '2013-10-30 00:39:37', '0.230000', '0.240000'),
	(25, 'Reality', '2013-10-30 00:39:37', '0.240000', '0.250000'),
	(26, 'Reality', '2013-10-30 00:39:37', '0.250000', '0.260000'),
	(27, 'Reality', '2013-10-30 00:39:37', '0.260000', '0.270000'),
	(28, 'Reality', '2013-10-30 00:39:37', '0.270000', '0.280000'),
	(29, 'Reality', '2013-10-30 00:39:37', '0.280000', '0.290000'),
	(30, 'Reality', '2013-10-30 00:39:37', '0.290000', '0.300000'),
	(31, 'Reality', '2013-10-30 00:39:37', '0.300000', '0.310000'),
	(32, 'Reality', '2013-10-30 00:39:37', '0.310000', '0.320000'),
	(33, 'Reality', '2013-10-30 00:39:37', '0.320000', '0.330000'),
	(34, 'Reality', '2013-10-30 00:39:37', '0.330000', '0.340000'),
	(35, 'Reality', '2013-10-30 00:39:37', '0.340000', '0.350000'),
	(36, 'Reality', '2013-10-30 00:39:37', '0.350000', '0.360000'),
	(37, 'Reality', '2013-10-30 00:39:37', '0.360000', '0.370000'),
	(38, 'Reality', '2013-10-30 00:39:37', '0.370000', '0.380000'),
	(39, 'Reality', '2013-10-30 00:39:37', '0.380000', '0.390000'),
	(40, 'Reality', '2013-10-30 00:39:37', '0.390000', '0.400000'),
	(41, 'Reality', '2013-10-30 00:39:37', '0.400000', '0.410000'),
	(42, 'Reality', '2013-10-30 00:39:37', '0.410000', '0.420000'),
	(43, 'Reality', '2013-10-30 00:39:37', '0.420000', '0.430000'),
	(44, 'Reality', '2013-10-30 00:39:37', '0.430000', '0.440000'),
	(45, 'Reality', '2013-10-30 00:39:37', '0.440000', '0.450000'),
	(46, 'Reality', '2013-10-30 00:39:37', '0.450000', '0.460000');
/*!40000 ALTER TABLE `migration_schema_log` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.migration_schema_version
DROP TABLE IF EXISTS `migration_schema_version`;
CREATE TABLE IF NOT EXISTS `migration_schema_version` (
  `name` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.migration_schema_version: ~0 rows (około)
/*!40000 ALTER TABLE `migration_schema_version` DISABLE KEYS */;
INSERT INTO `migration_schema_version` (`name`, `version`) VALUES
	('Reality', '0.460000');
/*!40000 ALTER TABLE `migration_schema_version` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.profile
DROP TABLE IF EXISTS `profile`;
CREATE TABLE IF NOT EXISTS `profile` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(128) NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `humanity` int(6) NOT NULL DEFAULT '2500',
  `survival_attempts` int(3) unsigned NOT NULL DEFAULT '1',
  `total_survival_time` int(5) unsigned NOT NULL DEFAULT '0',
  `total_survivor_kills` int(4) unsigned NOT NULL DEFAULT '0',
  `total_bandit_kills` int(4) unsigned NOT NULL DEFAULT '0',
  `total_zombie_kills` int(5) unsigned NOT NULL DEFAULT '0',
  `total_headshots` int(5) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_profile` (`unique_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.profile: ~0 rows (około)
/*!40000 ALTER TABLE `profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `profile` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.survivor
DROP TABLE IF EXISTS `survivor`;
CREATE TABLE IF NOT EXISTS `survivor` (
  `id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(128) NOT NULL,
  `world_id` smallint(5) unsigned NOT NULL DEFAULT '1',
  `worldspace` varchar(60) NOT NULL DEFAULT '[]',
  `inventory` varchar(2048) NOT NULL DEFAULT '[]',
  `backpack` varchar(2048) NOT NULL DEFAULT '[]',
  `medical` varchar(255) NOT NULL DEFAULT '[false,false,false,false,false,false,false,12000,[],[0,0],0]',
  `is_dead` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `model` varchar(128) NOT NULL DEFAULT 'Survivor2_DZ',
  `state` varchar(128) NOT NULL DEFAULT '["","aidlpercmstpsnonwnondnon_player_idlesteady04",36]',
  `survivor_kills` int(3) unsigned NOT NULL DEFAULT '0',
  `bandit_kills` int(3) unsigned NOT NULL DEFAULT '0',
  `zombie_kills` int(4) unsigned NOT NULL DEFAULT '0',
  `headshots` int(4) unsigned NOT NULL DEFAULT '0',
  `last_ate` int(3) unsigned NOT NULL DEFAULT '0',
  `last_drank` int(3) unsigned NOT NULL DEFAULT '0',
  `survival_time` int(3) unsigned NOT NULL DEFAULT '0',
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `start_time` datetime NOT NULL,
  `DistanceFoot` int(50) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx1_main` (`unique_id`)
) ENGINE=InnoDB AUTO_INCREMENT=784 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.survivor: ~0 rows (około)
/*!40000 ALTER TABLE `survivor` DISABLE KEYS */;
/*!40000 ALTER TABLE `survivor` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.vehicle
DROP TABLE IF EXISTS `vehicle`;
CREATE TABLE IF NOT EXISTS `vehicle` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `class_name` varchar(100) DEFAULT NULL,
  `damage_min` decimal(4,3) NOT NULL DEFAULT '0.100',
  `damage_max` decimal(4,3) NOT NULL DEFAULT '0.700',
  `fuel_min` decimal(4,3) NOT NULL DEFAULT '0.200',
  `fuel_max` decimal(4,3) NOT NULL DEFAULT '0.800',
  `limit_min` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `limit_max` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `parts` varchar(1024) DEFAULT NULL,
  `inventory` varchar(2048) NOT NULL DEFAULT '[]',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq1_vehicle` (`class_name`),
  KEY `idx1_vehicle` (`class_name`)
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.vehicle: ~35 rows (około)
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehicle` ENABLE KEYS */;


-- Zrzut struktury widok dayzed.v_deployable
DROP VIEW IF EXISTS `v_deployable`;
-- Tworzenie tymczasowej tabeli aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `v_deployable` (
	`instance_deployable_id` BIGINT(20) UNSIGNED NOT NULL,
	`vehicle_id` SMALLINT(5) UNSIGNED NOT NULL,
	`class_name` VARCHAR(100) NULL COLLATE 'utf8_general_ci',
	`owner_id` INT(8) UNSIGNED NOT NULL,
	`owner_name` VARCHAR(64) NOT NULL COLLATE 'utf8_general_ci',
	`owner_unique_id` VARCHAR(128) NOT NULL COLLATE 'utf8_general_ci',
	`is_owner_dead` TINYINT(3) UNSIGNED NOT NULL,
	`worldspace` VARCHAR(60) NOT NULL COLLATE 'utf8_general_ci',
	`inventory` VARCHAR(2048) NOT NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;


-- Zrzut struktury widok dayzed.v_player
DROP VIEW IF EXISTS `v_player`;
-- Tworzenie tymczasowej tabeli aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `v_player` (
	`player_name` VARCHAR(64) NOT NULL COLLATE 'utf8_general_ci',
	`humanity` INT(6) NOT NULL,
	`alive_survivor_id` INT(8) UNSIGNED NULL,
	`alive_survivor_world_id` SMALLINT(5) UNSIGNED NULL
) ENGINE=MyISAM;


-- Zrzut struktury widok dayzed.v_vehicle
DROP VIEW IF EXISTS `v_vehicle`;
-- Tworzenie tymczasowej tabeli aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `v_vehicle` (
	`instance_vehicle_id` BIGINT(20) UNSIGNED NOT NULL,
	`vehicle_id` SMALLINT(5) UNSIGNED NOT NULL,
	`instance_id` BIGINT(20) UNSIGNED NOT NULL,
	`world_id` SMALLINT(5) UNSIGNED NOT NULL,
	`class_name` VARCHAR(100) NULL COLLATE 'utf8_general_ci',
	`worldspace` VARCHAR(60) NOT NULL COLLATE 'utf8_general_ci',
	`inventory` VARCHAR(2048) NOT NULL COLLATE 'utf8_general_ci',
	`parts` VARCHAR(1024) NOT NULL COLLATE 'utf8_general_ci',
	`damage` DOUBLE NOT NULL,
	`fuel` DOUBLE NOT NULL
) ENGINE=MyISAM;


-- Zrzut struktury tabela dayzed.weather
DROP TABLE IF EXISTS `weather`;
CREATE TABLE IF NOT EXISTS `weather` (
  `overcast` varchar(50) DEFAULT '0',
  `windx` varchar(50) DEFAULT '0',
  `windz` varchar(50) DEFAULT '0',
  `rain` varchar(50) DEFAULT '0',
  `fog` varchar(50) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.weather: ~0 rows (około)
/*!40000 ALTER TABLE `weather` DISABLE KEYS */;
INSERT INTO `weather` (`overcast`, `windx`, `windz`, `rain`, `fog`) VALUES
	('0', '0', '0', '0', '0');
/*!40000 ALTER TABLE `weather` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.world
DROP TABLE IF EXISTS `world`;
CREATE TABLE IF NOT EXISTS `world` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL DEFAULT '0',
  `max_x` mediumint(9) DEFAULT '0',
  `max_y` mediumint(9) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_world` (`name`),
  KEY `idx1_world` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.world: ~10 rows (około)
/*!40000 ALTER TABLE `world` DISABLE KEYS */;
INSERT INTO `world` (`id`, `name`, `max_x`, `max_y`) VALUES
	(1, 'chernarus', 14700, 15360),
	(2, 'lingor', 10000, 10000),
	(3, 'utes', 5100, 5100),
	(4, 'takistan', 14000, 14000),
	(5, 'panthera2', 10200, 10200),
	(6, 'fallujah', 10200, 10200),
	(7, 'zargabad', 8000, 8000),
	(8, 'namalsk', 12000, 12000),
	(9, 'mbg_celle2', 13000, 13000),
	(10, 'tavi', 25600, 25600);
/*!40000 ALTER TABLE `world` ENABLE KEYS */;


-- Zrzut struktury tabela dayzed.world_vehicle
DROP TABLE IF EXISTS `world_vehicle`;
CREATE TABLE IF NOT EXISTS `world_vehicle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `vehicle_id` smallint(5) unsigned NOT NULL DEFAULT '1',
  `world_id` smallint(5) unsigned NOT NULL DEFAULT '1',
  `worldspace` varchar(60) NOT NULL DEFAULT '[]',
  `description` varchar(1024) DEFAULT NULL,
  `chance` decimal(4,3) unsigned NOT NULL DEFAULT '0.000',
  `last_modified` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx1_world_vehicle` (`vehicle_id`),
  KEY `idx2_world_vehicle` (`world_id`),
  CONSTRAINT `world_vehicle_ibfk_1` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicle` (`id`),
  CONSTRAINT `world_vehicle_ibfk_2` FOREIGN KEY (`world_id`) REFERENCES `world` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2855 DEFAULT CHARSET=utf8;

-- Zrzucanie danych dla tabeli dayzed.world_vehicle: ~46 rows (około)
/*!40000 ALTER TABLE `world_vehicle` DISABLE KEYS */;
/*!40000 ALTER TABLE `world_vehicle` ENABLE KEYS */;


-- Zrzut struktury widok dayzed.v_deployable
DROP VIEW IF EXISTS `v_deployable`;
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `v_deployable`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_deployable` AS select `id`.`id` AS `instance_deployable_id`,`d`.`id` AS `vehicle_id`,`d`.`class_name` AS `class_name`,`s`.`id` AS `owner_id`,`p`.`name` AS `owner_name`,`p`.`unique_id` AS `owner_unique_id`,`s`.`is_dead` AS `is_owner_dead`,`id`.`worldspace` AS `worldspace`,`id`.`inventory` AS `inventory` from (((`instance_deployable` `id` join `deployable` `d` on((`id`.`deployable_id` = `d`.`id`))) join `survivor` `s` on((`id`.`owner_id` = `s`.`id`))) join `profile` `p` on((`s`.`unique_id` = `p`.`unique_id`))) ;


-- Zrzut struktury widok dayzed.v_player
DROP VIEW IF EXISTS `v_player`;
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `v_player`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_player` AS select `p`.`name` AS `player_name`,`p`.`humanity` AS `humanity`,`s`.`id` AS `alive_survivor_id`,`s`.`world_id` AS `alive_survivor_world_id` from (`profile` `p` left join `survivor` `s` on(((`p`.`unique_id` = `s`.`unique_id`) and (`s`.`is_dead` = 0)))) ;


-- Zrzut struktury widok dayzed.v_vehicle
DROP VIEW IF EXISTS `v_vehicle`;
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `v_vehicle`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_vehicle` AS select `iv`.`id` AS `instance_vehicle_id`,`v`.`id` AS `vehicle_id`,`iv`.`instance_id` AS `instance_id`,`i`.`world_id` AS `world_id`,`v`.`class_name` AS `class_name`,`iv`.`worldspace` AS `worldspace`,`iv`.`inventory` AS `inventory`,`iv`.`parts` AS `parts`,`iv`.`damage` AS `damage`,`iv`.`fuel` AS `fuel` from (((`instance_vehicle` `iv` join `world_vehicle` `wv` on((`iv`.`world_vehicle_id` = `wv`.`id`))) join `vehicle` `v` on((`wv`.`vehicle_id` = `v`.`id`))) join `instance` `i` on((`iv`.`instance_id` = `i`.`id`))) ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
