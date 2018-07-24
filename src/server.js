
require('dotenv').config();
const express = require('express');
const mysql = require('mysql');
const shortid = require('shortid');

const API = '/api';

const PORT = process.env.PORT || 3000;
const SERVER = process.env.SERVER || 'localhost';
const DB_SERVER = process.env.DB_SERVER || 'localhost';
const DB_USER = process.env.DB_USER || '';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_DATABASE = process.env.DB_DATABASE || '';

const connection = mysql.createConnection({
    host: DB_SERVER,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_DATABASE,
    multipleStatements: true
});

connection.connect((err) => {
    if (err) {
        console.error('Cannot connect to the database!');
        process.exit();
    }

    console.info(`Connected to the database with id ${connection.threadId}`);
})

const app = express();
app.use(express.json());
app.use(express.urlencoded());

/**
 * Register a new team.
 */
app.post(`${API}/register`, (req, res) => {
    const name = req.body.name;
    const team_shortId = shortid.generate();

    const query = 'INSERT INTO team SET ?'
    const options = {
        team_uuid: team_shortId,
        team_name: name
    };
    connection.query(query, options, (err, results, fields) => {
        if (err) {
            console.error(`Could not register new team ${name}`);
            res.status(500).send();
            return;
        }

        res.status(201).json({
            teamId: team_shortId
        });
        console.info(`New team ${name} has been successfully registered.`);
    });
});


/**
 * Start a survey for a team
 */
app.post(`${API}/team/:teamId/start-survey`, (req, res) => {
    const team_shortId = req.params.teamId;
    const surveyId = shortid.generate();
    const survey_name = req.body.name;

    const query = `INSERT INTO survey (survey_uuid, survey_name, team_id) VALUES 
                   (${connection.escape(surveyId)}, ${connection.escape(survey_name)}, (SELECT team_id FROM team WHERE team.team_uuid = ${connection.escape(team_shortId)}))`;

    connection.query(query, (err, results, fields) => {
            if (err) {
                console.error(`Could not create survey ${surveyId} for team ${team_shortId}`);
                res.status(500).send();
                return;
            }

            res.status(201).json({
                surveyId
            });
        }
    );
});


/**
 * Submit a survey
 */
app.post(`${API}/survey/:surveyId/submit`, (req, res) => {
    const surveyId = req.params.surveyId;

    let query = 'INSERT INTO answer (answer_uuid, answer_comment, question_id, survey_id, answer_result) VALUES ';
    req.body.answers.forEach((answer, index, array) => {
        query += `('${shortid.generate()}', `;
        query += `${connection.escape((answer.comments) ? answer.comments : '')}, `
        query += `(SELECT question_id FROM question WHERE question.question_uuid = ${connection.escape(answer.questionId)}), `;
        query += `(SELECT survey_id FROM survey WHERE survey.survey_uuid = ${connection.escape(surveyId)}), `; 
        query += `${connection.escape(answer.answer)})${(index === array.length - 1) ? `;`: `, `}`;
    });

    if (req.body.comments) {
        query += ' INSERT INTO survey_response (survey_response_uuid, survey_response_comment, survey_id) VALUES ';
        query += `('${shortid.generate()}', ${connection.escape(req.body.comments)}, (SELECT survey_id FROM survey WHERE survey.survey_uuid = ${connection.escape(surveyId)}))`;
    }

    connection.query(query, (err) => {
        if (err) {
            console.error(`Could not save survey ${surveyId}`);
            res.status(500).send();
            return;
        }

        res.status(201).send();
    })
});


/**
 * Retrieves team info
 */
app.get(`${API}/team/:teamId`, (req, res) => {
    const team_shortId = req.params.teamId;
    const query = 'SELECT team_uuid AS id, team_name AS name FROM team WHERE team_uuid = ?';
    connection.query(query, [team_shortId], (err, results) => {
        if (err) {
            console.error('Could not retrieve surveys for team from database');
            console.error(err);
            res.status(500).send();
            return;
        }
        res.status(200).json(results[0]);
    });
});


/**
 * Retrieve a list of surveys for a team
 */
app.get(`${API}/team/:teamId/surveys`, (req, res) => {
    const team_shortId = req.params.teamId;
    const query = 'SELECT survey_uuid AS id, survey_name AS name FROM survey INNER JOIN team ON survey.team_id = team.team_id WHERE team_uuid = ?';
    connection.query(query, [team_shortId], (err, results) => {
        if (err) {
            console.error('Could not retrieve team from database');
            console.error(err);
            res.status(500).send();
            return;
        }
        res.status(200).json(results);
    });
});
 
 
/**
 * Retrieves survey info
 */
app.get(`${API}/survey/:surveyId`, (req, res) => {
    const survey_shortId = req.params.surveyId;
    const query = 'SELECT survey_uuid AS id, survey_name AS name FROM survey WHERE survey_uuid = ?';
    connection.query(query, [survey_shortId], (err, results) => {
        if (err) {
            console.error('Could not retrieve survey from database');
            console.error(err);
            res.status(500).send();
            return;
        }

        res.status(200).json(results[0]);
    });
});


/**
 * Retrieve average results for a specific survey
 */
app.get(`${API}/survey/:teamId/:surveyId/result`, (req, res) => {
    const team_shortId = req.params.teamId;
    const survey_shortId = req.params.surveyId;

    const query = 'CALL getResultsBySurvey(?, ?)';

    connection.query(query, [team_shortId, survey_shortId], (err, results) => {
        if (err) {
            console.error(`Could not retieve results for survey ${survey_shortId} for team ${team_shortId}`);
            console.error(err);
            res.status(500).send();
            return;
        }

        res.status(200).json(results);

    });
});


/**
 *  Retrieve trending results for a team
 */
app.get(`${API}/survey/:teamId/result`, (req, res) => {
    const team_shortId = req.params.teamId;

    const query = 'CALL getTrendResultsByTeam(?, ?)';

    connection.query(query, [team_shortId, 6], (err, results) => {
        if (err) {
            console.error(`Could not retieve trend results for team ${team_shortId}`);
            console.error(err);
            res.status(500).send();
            return;
        }

        res.status(200).json(results);
    });
})


/**
 * Retrieve a list of questions
 */
app.get(`${API}/questions`, (req, res) => {
    connection.query('SELECT question_uuid AS questionId, question_text AS text FROM question', (err, results, fields) => {
        if (err) {
            console.error('Could not retrieve questions from database');
            res.status(500).send();
            return;
        }
        res.status(200).json(results);
    });
});


app.listen(PORT, () => {
    console.info(`Server has been started on port ${PORT}`);
})