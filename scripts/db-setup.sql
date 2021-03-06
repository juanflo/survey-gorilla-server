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
  `survey_name` text NOT NULL,
  `team_id` int(10) unsigned NOT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`survey_id`),
  UNIQUE KEY `survey_uuid` (`survey_uuid`),
  KEY `team_id` (`team_id`),
  KEY `create_date` (`create_date`),
  CONSTRAINT `delete_survey_as_team_removed` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



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
  `answer_comment` text NOT NULL,
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


# Dump of table survey_response
# ------------------------------------------------------------

DROP TABLE IF EXISTS `survey_response`;

CREATE TABLE `survey_response` (
  `survey_response_id` bigint(11) unsigned NOT NULL AUTO_INCREMENT,
  `survey_response_uuid` char(32) NOT NULL DEFAULT '',
  `survey_response_comment` text NOT NULL,
  `survey_id` bigint(11) NOT NULL,
  `create_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`survey_response_id`),
  UNIQUE KEY `survey_response_uuid` (`survey_response_uuid`),
  KEY `survey_id` (`survey_id`),
  KEY `create_date` (`create_date`),
  CONSTRAINT `delete_survey_response_as_survey_removed` FOREIGN KEY (`survey_id`) REFERENCES `survey` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE
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


# Get the average score of a survey of a team
# ------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS `getResultsBySurvey`; $$
CREATE PROCEDURE `getResultsBySurvey`(IN team_uuid VARCHAR(32), IN survey_uuid VARCHAR(32))
BEGIN
	WITH avgTable AS 
	(
		SELECT
			ans.survey_id, 
			ans.question_id,
			AVG(ans.answer_result) AS averageScore,
			COUNT(ans.answer_id) AS responseCount
		FROM answer AS ans
			INNER JOIN survey sur ON sur.survey_id = ans.survey_id
			INNER JOIN team tea ON tea.team_id = sur.team_id
		WHERE
			tea.team_uuid = team_uuid
			AND sur.survey_uuid = survey_uuid
		GROUP BY
			ans.survey_id, 
			ans.question_id
	)
	SELECT
		que.question_uuid AS questionId,
		que.question_area AS category,
		DATE(sur.create_date) AS surveyDate,
		ans.averageScore,
		ans.responseCount
	FROM avgTable ans
		INNER JOIN question que ON que.question_id = ans.question_id
		INNER JOIN survey sur ON sur.survey_id = ans.survey_id
	ORDER BY
		ans.question_id
    ;	
END$$
DELIMITER ;



# Get the average score of the last 6 surveys of a team
# ----------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS `getTrendResultsByTeam`; $$
CREATE PROCEDURE `getTrendResultsByTeam`(IN team_uuid VARCHAR(32), IN surveyLimit INT)
BEGIN
    WITH filteredSurvey AS
    (
        SELECT
            sur.*
        FROM survey sur
            INNER JOIN team tea on tea.team_id = sur.team_id
        WHERE
            tea.team_uuid = team_uuid
        ORDER BY 
            sur.create_date DESC
        LIMIT surveyLimit
    ),
    avgTable AS 
    (
        SELECT
            ans.survey_id, 
            ans.question_id,
            AVG(ans.answer_result) AS averageScore,
            COUNT(ans.answer_id) AS responseCount
        FROM answer AS ans
            INNER JOIN filteredSurvey sur ON sur.survey_id = ans.survey_id
            INNER JOIN team tea ON tea.team_id = sur.team_id
        GROUP BY
            ans.survey_id, 
            ans.question_id
    )
    SELECT
        sur.survey_uuid AS surveyId,
        sur.survey_name AS surveyName,
        DATE(sur.create_date) AS surveyDate,
        que.question_uuid AS questionId,
        que.question_area AS category,
        ans.averageScore,
        ans.responseCount
    FROM avgTable ans
        INNER JOIN question que ON que.question_id = ans.question_id
        INNER JOIN survey sur ON sur.survey_id = ans.survey_id
    ORDER BY
        sur.create_date,
        ans.survey_id,
        ans.question_id
    ;
END$$
DELIMITER ;


# Get the average score of a question of provided number of surveys of particular team
# ------------------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS `getResultsByTeamAndQuestion`; $$
CREATE PROCEDURE `getResultsByTeamAndQuestion`(IN team_uuid VARCHAR(32), IN question_uuid VARCHAR(32), IN surveyLimit INT)
BEGIN
    WITH filteredSurvey AS
    (
        SELECT
            sur.*
        FROM survey sur
            INNER JOIN team tea on tea.team_id = sur.team_id
        WHERE
            tea.team_uuid = team_uuid
        ORDER BY 
            sur.create_date DESC
        LIMIT surveyLimit
    ),
    avgTable AS 
    (
        SELECT
            ans.survey_id, 
            ans.question_id,
            que.question_uuid,
            AVG(ans.answer_result) AS averageScore,
            COUNT(ans.answer_id) AS responseCount
        FROM answer AS ans
            INNER JOIN filteredSurvey sur ON sur.survey_id = ans.survey_id
            INNER JOIN team tea ON tea.team_id = sur.team_id
            INNER JOIN question que ON que.question_id = ans.question_id
        WHERE
            que.question_uuid = question_uuid
        GROUP BY
            ans.survey_id, 
            ans.question_id
    )
    SELECT
        sur.survey_uuid AS surveyId,
        sur.survey_name AS surveyName,
        DATE(sur.create_date) AS surveyDate,
        ans.question_uuid AS questionId,
        que.question_area AS category,
        ans.averageScore,
        ans.responseCount
    FROM avgTable ans
        INNER JOIN survey sur ON sur.survey_id = ans.survey_id
        INNER JOIN question que ON que.question_id = ans.question_id
    ORDER BY
        sur.create_date,
        ans.survey_id,
        ans.question_id
    ;
END$$
DELIMITER ;