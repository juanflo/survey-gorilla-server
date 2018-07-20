DROP DATABASE IF EXISTS gorilla;
CREATE DATABASE gorilla;
USE gorilla;

# Dump of table teams
# ------------------------------------------------------------

DROP TABLE IF EXISTS `teams`;

CREATE TABLE `teams` (
  `team_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `team_uuid` char(32) DEFAULT '''',
  `team_name` varchar(200) DEFAULT '''',
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`team_id`),
  UNIQUE KEY `team_uuid` (`team_uuid`),
  KEY `create_date` (`create_date`),
  KEY `team_name` (`team_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;



# Dump of table surveys
# ------------------------------------------------------------

DROP TABLE IF EXISTS `surveys`;

CREATE TABLE `surveys` (
  `survey_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `survey_uuid` char(32) NOT NULL DEFAULT '''',
  `team_id` int(10) unsigned NOT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`survey_id`),
  UNIQUE KEY `survey_uuid` (`survey_uuid`),
  KEY `team_id` (`team_id`),
  KEY `create_date` (`create_date`),
  CONSTRAINT `delete_surveys_as_team_removed` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;



# Dump of table questions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `questions`;

CREATE TABLE `questions` (
  `question_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `question_uuid` char(32) NOT NULL DEFAULT '',
  `question_text` text NOT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`question_id`),
  UNIQUE KEY `question_uuid` (`question_uuid`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table answers
# ------------------------------------------------------------

DROP TABLE IF EXISTS `answers`;

CREATE TABLE `answers` (
  `answer_id` bigint(11) unsigned NOT NULL AUTO_INCREMENT,
  `answer_uuid` char(32) NOT NULL DEFAULT '',
  `question_id` bigint(20) NOT NULL,
  `survey_id` bigint(11) NOT NULL,
  `answer_result` int(11) DEFAULT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`answer_id`),
  UNIQUE KEY `answer_uuid` (`answer_uuid`),
  KEY `question_id` (`question_id`),
  KEY `survey_id` (`survey_id`),
  KEY `create_date` (`create_date`),
  CONSTRAINT `delete_answers_as_question_removed` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `delete_answers_as_survey_removed` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;