WITH avgTable AS 
(
	SELECT
		ans.survey_id, 
		ans.question_id,
		AVG(ans.answer_result) AS avgScore,
		COUNT(ans.answer_id) AS 'countOfAnswers'
	FROM answer AS ans
		INNER JOIN survey sur ON sur.survey_id = ans.survey_id
		INNER JOIN team tea ON tea.team_id = sur.team_id
	WHERE
		sur.survey_uuid = '000004'
		AND tea.team_id = '000001'
	GROUP BY
		ans.survey_id, 
		ans.question_id
)
SELECT
	tea.team_name,
	sur.survey_name,
	sur.create_date AS surveyDate,
	CONCAT(month(sur.create_date), '/', year(sur.create_date)) AS surveyDate2,
	que.question_text,
	ans.*
FROM avgTable ans
	INNER JOIN question que ON que.question_id = ans.question_id
	INNER JOIN survey sur ON sur.survey_id = ans.survey_id
	INNER JOIN team tea ON tea.team_id = sur.team_id
ORDER BY
	ans.question_id