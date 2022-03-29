-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema adnu_acrms_3
-- -----------------------------------------------------
-- Primary database of whole system.

-- -----------------------------------------------------
-- Schema adnu_acrms_3
--
-- Primary database of whole system.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `adnu_acrms_3` DEFAULT CHARACTER SET utf8 ;
USE `adnu_acrms_3` ;

-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`devices_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`devices_list` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`devices_list` (
  `device_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment',
  `name` VARCHAR(10) NOT NULL COMMENT 'Device Name',
  `type` VARCHAR(20) NULL DEFAULT '' COMMENT 'Device Type',
  `description` VARCHAR(20) NULL DEFAULT '' COMMENT 'Device Description',
  `create_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`device_id`))
ENGINE = InnoDB
COMMENT = 'List of devices. Device_id primary key required by other tables.';

CREATE UNIQUE INDEX `device_id_UNIQUE` ON `adnu_acrms_3`.`devices_list` (`device_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`user_groups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`user_groups` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`user_groups` (
  `group_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Group ID',
  `name` VARCHAR(15) NOT NULL COMMENT 'Group Name',
  `description` VARCHAR(20) NULL DEFAULT '' COMMENT 'Group Description',
  PRIMARY KEY (`group_id`))
ENGINE = InnoDB
COMMENT = 'User groups.';

CREATE UNIQUE INDEX `group_id_UNIQUE` ON `adnu_acrms_3`.`user_groups` (`group_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`user_credentials`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`user_credentials` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`user_credentials` (
  `user_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `username` VARCHAR(16) NOT NULL COMMENT 'Account Username',
  `password` VARCHAR(16) NOT NULL COMMENT 'Password',
  `group_id` TINYINT UNSIGNED NOT NULL COMMENT 'Group ID. Value must exist in user_groups table.',
  `create_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_account_credentials_groups1`
    FOREIGN KEY (`group_id`)
    REFERENCES `adnu_acrms_3`.`user_groups` (`group_id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
COMMENT = 'User accounts.';

CREATE UNIQUE INDEX `user_id_UNIQUE` ON `adnu_acrms_3`.`user_credentials` (`user_id` ASC) VISIBLE;

CREATE UNIQUE INDEX `username_UNIQUE` ON `adnu_acrms_3`.`user_credentials` (`username` ASC) VISIBLE;

CREATE INDEX `fk_account_credentials_groups1_idx` ON `adnu_acrms_3`.`user_credentials` (`group_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`alarm_parameters`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`alarm_parameters` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`alarm_parameters` (
  `alarm_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Alarm ID',
  `name` VARCHAR(10) NOT NULL DEFAULT '' COMMENT 'Alarm Nickname',
  `device_id` TINYINT UNSIGNED NOT NULL COMMENT 'Device where the alarm is set.',
  `user_id` TINYINT UNSIGNED NOT NULL,
  `temp_min` DECIMAL(4,1) NULL,
  `temp_max` DECIMAL(4,1) NULL,
  `humid_min` DECIMAL(4,1) UNSIGNED NULL,
  `humid_max` DECIMAL(4,1) UNSIGNED NULL,
  `create_date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`alarm_id`),
  CONSTRAINT `fk_alarm_parameters_account_credentials1`
    FOREIGN KEY (`user_id`)
    REFERENCES `adnu_acrms_3`.`user_credentials` (`user_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_alarm_parameters_devices1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
COMMENT = 'Custom alarm parameters set by users.';

CREATE UNIQUE INDEX `alarm_id_UNIQUE` ON `adnu_acrms_3`.`alarm_parameters` (`alarm_id` ASC) VISIBLE;

CREATE UNIQUE INDEX `device_id_UNIQUE` ON `adnu_acrms_3`.`alarm_parameters` (`device_id` ASC) VISIBLE;

CREATE INDEX `fk_alarm_parameters_devices1_idx` ON `adnu_acrms_3`.`alarm_parameters` (`device_id` ASC) VISIBLE;

CREATE INDEX `fk_alarm_parameters_account_credentials1_idx` ON `adnu_acrms_3`.`alarm_parameters` (`user_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`data_temp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`data_temp` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`data_temp` (
  `record_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Record ID',
  `device_id` TINYINT UNSIGNED NOT NULL,
  `temp_data` DECIMAL(5,2) NULL DEFAULT NULL COMMENT 'Temperature reading in decimal format. Can store five digits with two decimal places.',
  `record_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  CONSTRAINT `fk_records_temperature_devices1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
COMMENT = 'Temperature data from SHT21 Temperature and Humidity digital sensor.';

CREATE UNIQUE INDEX `log_id_UNIQUE` ON `adnu_acrms_3`.`data_temp` (`record_id` ASC) VISIBLE;

CREATE INDEX `fk_records_temperature_devices1_idx` ON `adnu_acrms_3`.`data_temp` (`device_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`logs_alarm_temp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`logs_alarm_temp` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`logs_alarm_temp` (
  `log_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `alarm_id` TINYINT UNSIGNED NOT NULL,
  `record_id` INT UNSIGNED NOT NULL,
  `log_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  CONSTRAINT `fk_alarm_logs_temperature_alarm_parameters1`
    FOREIGN KEY (`alarm_id`)
    REFERENCES `adnu_acrms_3`.`alarm_parameters` (`alarm_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_log_temperature_records_temperature1`
    FOREIGN KEY (`record_id`)
    REFERENCES `adnu_acrms_3`.`data_temp` (`record_id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
COMMENT = 'List of logs for temperature.';

CREATE INDEX `fk_log_temperature_records_temperature1_idx` ON `adnu_acrms_3`.`logs_alarm_temp` (`record_id` ASC) VISIBLE;

CREATE INDEX `fk_alarm_logs_temperature_alarm_parameters1_idx` ON `adnu_acrms_3`.`logs_alarm_temp` (`alarm_id` ASC) VISIBLE;

CREATE UNIQUE INDEX `log_id_UNIQUE` ON `adnu_acrms_3`.`logs_alarm_temp` (`log_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`data_hmd`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`data_hmd` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`data_hmd` (
  `record_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Record ID',
  `device_id` TINYINT UNSIGNED NOT NULL,
  `hmd_data` DECIMAL(5,2) NULL DEFAULT NULL COMMENT 'Relative humidity reading in decimal format. Can store five digits with two decimal places. Non-negative.',
  `record_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  CONSTRAINT `fk_records_humidity_devices1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
COMMENT = 'Humidity data from SHT21 Temperature and Humidity digital sensor.';

CREATE UNIQUE INDEX `log_id_UNIQUE` ON `adnu_acrms_3`.`data_hmd` (`record_id` ASC) VISIBLE;

CREATE INDEX `fk_records_humidity_devices1_idx` ON `adnu_acrms_3`.`data_hmd` (`device_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`logs_alarm_hmd`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`logs_alarm_hmd` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`logs_alarm_hmd` (
  `log_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `alarm_id` TINYINT UNSIGNED NOT NULL,
  `record_id` INT UNSIGNED NOT NULL,
  `log_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  CONSTRAINT `fk_alarm_logs_humidity_alarm_parameters1`
    FOREIGN KEY (`alarm_id`)
    REFERENCES `adnu_acrms_3`.`alarm_parameters` (`alarm_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_logs_humidity_records_humidity1`
    FOREIGN KEY (`record_id`)
    REFERENCES `adnu_acrms_3`.`data_hmd` (`record_id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
COMMENT = 'List of logs for humidity.';

CREATE INDEX `fk_logs_humidity_records_humidity1_idx` ON `adnu_acrms_3`.`logs_alarm_hmd` (`record_id` ASC) VISIBLE;

CREATE INDEX `fk_alarm_logs_humidity_alarm_parameters1_idx` ON `adnu_acrms_3`.`logs_alarm_hmd` (`alarm_id` ASC) VISIBLE;

CREATE UNIQUE INDEX `log_id_UNIQUE` ON `adnu_acrms_3`.`logs_alarm_hmd` (`log_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`data_current`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`data_current` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`data_current` (
  `record_id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Record ID',
  `device_id` TINYINT UNSIGNED NOT NULL COMMENT 'Device ID. Reference primary key from devices_list.',
  `amp_data` DECIMAL(5,2) NULL DEFAULT NULL COMMENT 'Current reading in decimal format. Can store five digits with two decimal places.',
  `record_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  CONSTRAINT `fk_records_current_devices1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
COMMENT = 'AC current data from ACS712 AC/DC Hall Effect analog sensor.';

CREATE UNIQUE INDEX `log_id_UNIQUE` ON `adnu_acrms_3`.`data_current` (`record_id` ASC) VISIBLE;

CREATE INDEX `fk_records_current_devices1_idx` ON `adnu_acrms_3`.`data_current` (`device_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`logs_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`logs_list` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`logs_list` (
  `log_id` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `log_id_temperature` TINYINT UNSIGNED NULL DEFAULT NULL,
  `log_id_humidity` TINYINT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  CONSTRAINT `fk_logs_list_logs_alarm_humidity1`
    FOREIGN KEY (`log_id_humidity`)
    REFERENCES `adnu_acrms_3`.`logs_alarm_hmd` (`log_id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_logs_list_logs_alarm_temperature1`
    FOREIGN KEY (`log_id_temperature`)
    REFERENCES `adnu_acrms_3`.`logs_alarm_temp` (`log_id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
COMMENT = 'Summary list of logs.';

CREATE INDEX `fk_logs_list_logs_alarm_temperature1_idx` ON `adnu_acrms_3`.`logs_list` (`log_id_temperature` ASC) INVISIBLE;

CREATE INDEX `fk_logs_list_logs_alarm_humidity1_idx` ON `adnu_acrms_3`.`logs_list` (`log_id_humidity` ASC) VISIBLE;

CREATE UNIQUE INDEX `log_id_UNIQUE` ON `adnu_acrms_3`.`logs_list` (`log_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`user_data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`user_data` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`user_data` (
  `user_id` TINYINT UNSIGNED NOT NULL COMMENT 'User ID. References primary key from user_credentials.',
  `first_name` VARCHAR(20) NOT NULL COMMENT 'First Name',
  `middle_name` VARCHAR(20) NULL DEFAULT '' COMMENT 'Middle Name',
  `last_name` VARCHAR(20) NULL DEFAULT '' COMMENT 'Last Name',
  `create_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_records_account_credentials1`
    FOREIGN KEY (`user_id`)
    REFERENCES `adnu_acrms_3`.`user_credentials` (`user_id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
COMMENT = 'User information.';

CREATE INDEX `fk_user_records_account_credentials1_idx` ON `adnu_acrms_3`.`user_data` (`user_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`data_gas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`data_gas` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`data_gas` (
  `record_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` TINYINT UNSIGNED NOT NULL,
  `vout_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `vref_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `vout_status` VARCHAR(15) NULL DEFAULT NULL,
  `vref_status` VARCHAR(15) NULL DEFAULT NULL,
  `alarm_status` VARCHAR(15) NULL DEFAULT NULL,
  `record_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  CONSTRAINT `fk_records_gas_devices_list1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'Vout and Vref data from FCM-2630-C01 R-32 analog sensor.';

CREATE INDEX `fk_records_gas_devices_list1_idx` ON `adnu_acrms_3`.`data_gas` (`device_id` ASC) VISIBLE;

CREATE UNIQUE INDEX `record_id_UNIQUE` ON `adnu_acrms_3`.`data_gas` (`record_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`data_accelerometer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`data_accelerometer` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`data_accelerometer` (
  `record_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` TINYINT UNSIGNED NOT NULL,
  `xa_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `ya_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `za_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `record_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  CONSTRAINT `fk_records_accelerometer_devices_list1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
COMMENT = 'X, Y, and Z acceleration data from ADXL345 digital accelerometer.';

CREATE INDEX `fk_records_accelerometer_devices_list1_idx` ON `adnu_acrms_3`.`data_accelerometer` (`device_id` ASC) VISIBLE;

CREATE UNIQUE INDEX `record_id_UNIQUE` ON `adnu_acrms_3`.`data_accelerometer` (`record_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `adnu_acrms_3`.`data_temp_hmd`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`data_temp_hmd` ;

CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`data_temp_hmd` (
  `record_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` TINYINT UNSIGNED NOT NULL,
  `temp_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `hmd_data` DECIMAL(5,2) NULL DEFAULT NULL,
  `record_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  CONSTRAINT `fk_records_temperature_humidity_devices_list1`
    FOREIGN KEY (`device_id`)
    REFERENCES `adnu_acrms_3`.`devices_list` (`device_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Temperature and humidity data from SHT21 Temperature and Humidity digital sensor.';

CREATE UNIQUE INDEX `record_id_UNIQUE` ON `adnu_acrms_3`.`data_temp_hmd` (`record_id` ASC) VISIBLE;

CREATE INDEX `fk_records_temperature_humidity_devices_list1_idx` ON `adnu_acrms_3`.`data_temp_hmd` (`device_id` ASC) VISIBLE;

USE `adnu_acrms_3` ;

-- -----------------------------------------------------
-- Placeholder table for view `adnu_acrms_3`.`view_groups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`view_groups` (`name` INT, `description` INT);

-- -----------------------------------------------------
-- Placeholder table for view `adnu_acrms_3`.`view_users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `adnu_acrms_3`.`view_users` (`user_id` INT, `username` INT, `first_name` INT, `middle_name` INT, `last_name` INT, `group_id` INT, `description` INT);

-- -----------------------------------------------------
-- procedure add_current_data
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`add_current_data`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_current_data`(
	IN `p_device_id` TINYINT,
	IN `p_current_data` DECIMAL(5,2)
)
    MODIFIES SQL DATA
    DETERMINISTIC
    COMMENT 'Add a current reading to the database. Requires the device id and current reading in decimal (5,2) format.'
BEGIN
	INSERT INTO data_current (device_id, amp_data)
    VALUES (p_device_id, p_current_data);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_hmd_data
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`add_hmd_data`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_hmd_data`(
	IN `p_device_id` TINYINT,
	IN `p_hmd_data` DECIMAL(5,2)
)
	MODIFIES SQL DATA
	DETERMINISTIC
	COMMENT 'Add a humidity reading to the database. Requires the device id and humidity reading in decimal (5,2) format.'
BEGIN
	INSERT INTO data_hmd (device_id, hmd_data)
	VALUES (p_device_id, p_hmd_data);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_temp_data
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`add_temp_data`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_temp_data`(
	IN `p_device_id` TINYINT,
	IN `p_temp_reading` DECIMAL(5,2)
)
	MODIFIES SQL DATA
	DETERMINISTIC
	COMMENT 'Add a temperature reading to the database. Requires the device id and temperature reading in decimal (5,2) format.'
BEGIN
	INSERT INTO records_temperature (device_id, temp_data)
    VALUES (p_device_id, p_temp_reading);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_new_device
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`add_new_device`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_device`(
	IN `p_name` VARCHAR(10),
	IN `p_type` VARCHAR(20),
	IN `p_description` VARCHAR(20)
)
	MODIFIES SQL DATA
	DETERMINISTIC
BEGIN
	IF p_type IS NULL THEN
		SET p_type = '';
	END IF;
	IF p_description IS NULL THEN
		SET p_description = '';
	END IF;
	INSERT INTO devices_list (`name`, `type`, `description`)
	VALUES (p_name, p_type, p_description);
	SELECT dl.name, dl.type, dl.description, dl.create_date FROM devices_list dl
	WHERE dl.name = p_name;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure create_user
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`create_user`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user`(
	IN `p_username` VARCHAR(16),
	IN `p_password` VARCHAR(16),
	IN `p_first_name` VARCHAR(20),
	IN `p_middle_name` VARCHAR(20),
	IN `p_last_name` VARCHAR(20),
	IN `p_group_id` TINYINT
)
	MODIFIES SQL DATA
	DETERMINISTIC
BEGIN
	IF p_middle_name IS NULL THEN
		SET p_middle_name = '';
	END IF;
	IF p_last_name IS NULL THEN
		SET p_middle_name = '';
	END IF;
	INSERT INTO user_credentials (username, `password`, group_id)
	VALUES (p_username, p_password, p_group_id);
	
    SELECT uc.user_id INTO @p_user_id
    FROM user_credentials uc
    WHERE uc.username = p_username;
    
	INSERT INTO user_records (user_id, first_name, middle_name, last_name)
	VALUES (@p_user_id, p_first_name, p_middle_name, p_last_name);
    
	SET @p_user_id = NULL;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure create_group
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`create_group`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_group`(
	IN `p_name` VARCHAR(15),
	IN `p_description` VARCHAR(20)
)
	MODIFIES SQL DATA
	DETERMINISTIC
BEGIN
	IF p_description IS NULL THEN
		SET p_description  = '';
	END IF;
	INSERT INTO user_groups (name, description)
	VALUES (p_name, p_description);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure create_alarm_parameter
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`create_alarm_parameter`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_alarm_parameter`(
	IN `p_name` VARCHAR(10),
	IN `p_dev_id` TINYINT,
	IN `p_username` TINYINT,
	IN `p_temp_min` DECIMAL(5,2),
	IN `p_temp_max` DECIMAL(5,2),
	IN `p_humid_min` DECIMAL(5,2),
	IN `p_humid_max` DECIMAL(5,2)
)
	MODIFIES SQL DATA
	DETERMINISTIC
BEGIN
	IF p_temp_min IS NULL THEN
		SET p_temp_min = -40;   -- Degrees Celsius
    END IF;
	IF p_temp_max IS NULL THEN
		SET p_temp_max = 120;
    END IF;
	IF p_humid_min IS NULL THEN
		SET p_humid_min = 0;    -- Percent value
    END IF;
	IF p_humid_max IS NULL THEN
		SET p_humid_max = 100;
	END IF;
	CALL get_user_id(p_username);
	INSERT INTO alarm_paramaters (name, device_id, user_id, temp_min,
		temp_max, humid_min, humid_max)
	VALUES (p_name, p_dev_id, @p_user_id, p_temp_min, p_temp_max,
		p_humid_min, p_humid_max);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure drop_user
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`drop_user`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `drop_user`(
	IN `p_username` VARCHAR(16)
)
	MODIFIES SQL DATA
	DETERMINISTIC
BEGIN
	DELETE FROM user_credentials uc
	WHERE uc.username = p_username;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure get_user_id
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`get_user_id`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_id`(
	IN `p_username` VARCHAR(16),
	OUT `p_user_id` TINYINT
)
	READS SQL DATA
	DETERMINISTIC
BEGIN  
	SELECT uc.user_id INTO p_user_id
	FROM user_credentials uc
	WHERE uc.username = p_username;
	SET @p_user_id = NULL;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_gas_data
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`add_gas_data`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_gas_data`(
	IN `p_device_id` TINYINT,
	IN `p_vout_data` DECIMAL(5,2),
	IN `p_vref_data` DECIMAL(5,2)
)
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
	IF (p_vout_reading > 4.95 OR p_vout_reading < 0.05) THEN
		SET @p_vout_status= 1;
	ELSE
		SET @p_vout_status= 0;
	END IF;
	IF (p_vref_reading > 3.70 OR p_vref_reading < 2.50) THEN
		SET @p_vref_status = 1;
	ELSE
		SET @p_vref_status= 0;
	END IF;
	IF (@p_vout_status = 1 OR @p_vref_status = 1) THEN
		SET @p_alarm_status= 1;
	ELSE
		IF p_vout_reading < p_vref_reading THEN
			SET @p_alarm_status= 0;
		ELSE
			SET @p_alarm_status= 0;
		END IF;
	END IF;
	INSERT INTO data_gas (device_id, vout_reading, vref_reading, vout_status, vref_status, alarm_status)
	VALUES (p_device_id, p_vout_data, p_vref_data, @p_vout_status, @p_vref_status, @p_alarm_status);
	SET @p_alarm_status = NULL;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_temp_hmd_data
-- -----------------------------------------------------

USE `adnu_acrms_3`;
DROP procedure IF EXISTS `adnu_acrms_3`.`add_temp_hmd_data`;

DELIMITER $$
USE `adnu_acrms_3`$$
CREATE PROCEDURE `add_temp_hmd_data` (
	IN `p_device_id` TINYINT,
	IN `p_temp_reading` DECIMAL(5,2),
	IN `p_hmd_reading` DECIMAL(5,2)
)
	DETERMINISTIC
	MODIFIES SQL DATA
BEGIN
	INSERT INTO data_temp_hmd (device_id, temp_data, hmd_data)
	VALUES (p_device_id, p_temp_reading, p_hmd_reading);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `adnu_acrms_3`.`view_groups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`view_groups`;
DROP VIEW IF EXISTS `adnu_acrms_3`.`view_groups` ;
USE `adnu_acrms_3`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `adnu_acrms_3`.`view_groups` AS select `ug`.`name` AS `name`,`ug`.`description` AS `description` from `adnu_acrms_3`.`user_groups` `ug`;

-- -----------------------------------------------------
-- View `adnu_acrms_3`.`view_users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `adnu_acrms_3`.`view_users`;
DROP VIEW IF EXISTS `adnu_acrms_3`.`view_users` ;
USE `adnu_acrms_3`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `adnu_acrms_3`.`view_users` AS select `uc`.`user_id` AS `user_id`,`uc`.`username` AS `username`,`ur`.`first_name` AS `first_name`,`ur`.`middle_name` AS `middle_name`,`ur`.`last_name` AS `last_name`,`ug`.`group_id` AS `group_id`,`ug`.`description` AS `description` from ((`adnu_acrms_3`.`user_credentials` `uc` join `adnu_acrms_3`.`user_data` `ur` on((`uc`.`user_id` = `ur`.`user_id`))) join `adnu_acrms_3`.`user_groups` `ug` on((`uc`.`group_id` = `ug`.`group_id`)));
USE `adnu_acrms_3`;

DELIMITER $$

USE `adnu_acrms_3`$$
DROP TRIGGER IF EXISTS `adnu_acrms_3`.`data_validation_temp` $$
USE `adnu_acrms_3`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `adnu_acrms_3`.`data_validation_temp`
AFTER INSERT ON `adnu_acrms_3`.`data_temp`
FOR EACH ROW
BEGIN
	IF NEW.temp_data < -40 OR NEW.temp_data > 120 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data is out of range (-40 to 120).';
	END IF;
END$$


USE `adnu_acrms_3`$$
DROP TRIGGER IF EXISTS `adnu_acrms_3`.`data_validation_hmd` $$
USE `adnu_acrms_3`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `adnu_acrms_3`.`data_validation_hmd`
AFTER INSERT ON `adnu_acrms_3`.`data_hmd`
FOR EACH ROW
BEGIN
	IF NEW.hmd_data < 0 OR NEW.hmd_data > 100 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data is out of range (0 to 100).';
	END IF;
END$$


USE `adnu_acrms_3`$$
DROP TRIGGER IF EXISTS `adnu_acrms_3`.`data_temp_hmd_AFTER_INSERT` $$
USE `adnu_acrms_3`$$
CREATE DEFINER = CURRENT_USER TRIGGER `adnu_acrms_3`.`data_temp_hmd_AFTER_INSERT` AFTER INSERT ON `data_temp_hmd` FOR EACH ROW
BEGIN
	IF NEW.temp_data < -40 OR NEW.temp_data > 120 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data is out of range (-40 to 120).';
	END IF;
    
	IF NEW.hmd_data < 0 OR NEW.hmd_data > 100 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data is out of range (0 to 100).';
	END IF;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS arduino;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'arduino' IDENTIFIED BY 'arduino';

GRANT SELECT, INSERT, TRIGGER ON TABLE `adnu_acrms_3`.* TO 'arduino';
GRANT SELECT, INSERT, TRIGGER, UPDATE, DELETE ON TABLE `adnu_acrms_3`.* TO 'arduino';
GRANT EXECUTE ON ROUTINE `adnu_acrms_3`.* TO 'arduino';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
