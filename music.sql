DROP TABLE IF EXISTS `play`;
CREATE TABLE `play` (
      `title` VARCHAR(256) NOT NULL DEFAULT '',
      `artist` VARCHAR(256) NOT NULL DEFAULT '',
      `service` VARCHAR(128) DEFAULT NULL,
      `user_id` BIGINT UNSIGNED DEFAULT NULL,
      `created_time` BIGINT UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
      `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
      `name` VARCHAR(24) NOT NULL DEFAULT '',
      UNIQUE KEY `name_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;