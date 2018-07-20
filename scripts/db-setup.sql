DROP DATABASE IF EXISTS gorilla;
CREATE DATABASE gorilla;
USE gorilla;

# Dump of table team
# ------------------------------------------------------------

DROP TABLE IF EXISTS `team`;

CREATE TABLE `team` (
  `team_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `team_uuid` char(32) DEFAULT '''',
  `team_name` varchar(200) DEFAULT '''',
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`team_id`),
  UNIQUE KEY `team_uuid` (`team_uuid`),
  KEY `create_date` (`create_date`),
  KEY `team_name` (`team_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table survey
# ------------------------------------------------------------

DROP TABLE IF EXISTS `survey`;

CREATE TABLE `survey` (
  `survey_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `survey_uuid` char(32) NOT NULL DEFAULT '''',
  `team_id` int(10) unsigned NOT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`survey_id`),
  UNIQUE KEY `survey_uuid` (`survey_uuid`),
  KEY `team_id` (`team_id`),
  KEY `create_date` (`create_date`),
<<<<<<< HEAD
  CONSTRAINT `delete_survey_as_team_removed` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
=======
  CONSTRAINT `delete_surveys_as_team_removed` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
>>>>>>> c052b880a42c933f7a1d406a32ff7a9a68f75ebc



# Dump of table question
# ------------------------------------------------------------

DROP TABLE IF EXISTS `question`;

CREATE TABLE `question` (
  `question_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `question_uuid` char(32) NOT NULL DEFAULT '',
  `question_text` text NOT NULL,
  `question_area` text NOT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`question_id`),
  UNIQUE KEY `question_uuid` (`question_uuid`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table answer
# ------------------------------------------------------------

DROP TABLE IF EXISTS `answer`;

CREATE TABLE `answer` (
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
  CONSTRAINT `delete_answers_as_question_removed` FOREIGN KEY (`question_id`) REFERENCES `question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `delete_answers_as_survey_removed` FOREIGN KEY (`survey_id`) REFERENCES `survey` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Insert survey questions into the question table.
# ------------------------------------------------------------

INSERT INTO question 
  (question_uuid, question_text, question_area)
VALUES
  ('000001', 'We know exactly why we are here, and we are really excited about it.', 'mission'),
  ('000002', 'We deliver great stuff! We’re proud of it and our stakeholders are really happy.', 'value'),
  ('000003', 'We love going to work, and have great fun working together.', 'fun'),
  ('000004', 'We’re learning lots of interesting stuff all the time!', 'learning'),
  ('000005', 'Releasing is simple, safe, painless & mostly automated.', 'release'),
  ('000006', 'Our way of working fits us perfectly.', 'process'),
  ('000007', 'We’re proud of the quality of our code! It is clean, easy to read, and has great test coverage.', 'quality'),
  ('000008', 'We get stuff done really quickly.No waiting, no delays.', 'speed'),
  ('000009', 'We always get great support & help when we ask for it!', 'support'),
  ('000010', 'We are in control of our destiny! We decide what to build and how to build it.', 'self-organization');