    WITH filteredSurvey AS
    (
        SELECT
            sur.*
        FROM survey sur
            INNER JOIN team tea on tea.team_id = sur.team_id
        WHERE
            tea.team_uuid = '000001'
        ORDER BY 
            sur.create_date DESC
        LIMIT 6
    ),
    avgTable AS 
    (
        SELECT
            ans.survey_id, 
            ans.question_id,
            AVG(ans.answer_result) AS avgScore,
            COUNT(ans.answer_id) AS countOfAnswers
        FROM answer AS ans
            INNER JOIN filteredSurvey sur ON sur.survey_id = ans.survey_id
            INNER JOIN team tea ON tea.team_id = sur.team_id
        GROUP BY
            ans.survey_id, 
            ans.question_id
    )
    SELECT
        sur.survey_uuid,
        sur.survey_name,
        sur.create_date AS surveyDate,
        que.question_uuid,
        ans.avgScore,
        ans.countOfAnswers
    FROM avgTable ans
        INNER JOIN question que ON que.question_id = ans.question_id
        INNER JOIN survey sur ON sur.survey_id = ans.survey_id
        INNER JOIN team tea ON tea.team_id = sur.team_id
    ORDER BY
        sur.create_date,
        ans.survey_id,
        ans.question_id