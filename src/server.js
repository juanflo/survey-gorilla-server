
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
    database: DB_DATABASE
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

    const options = {
        team_uuid: team_shortId,
        team_name: name
    };
    connection.query('INSERT INTO team SET ?', options, (err, results, fields) => {
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

    connection.query(
        `INSERT INTO survey (survey_uuid, team_id) 
         SELECT '${surveyId}', team_id FROM team WHERE team.team_uuid = '${team_shortId}'`, (err, results, fields) => {
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
app.post(`${API}/survey/:teamId/:surveyId`, (req, res) => {
    const team_shortId = req.params.teamId;
    const surveyId = req.params.surveyId;
});


/**
 * Retrieve a list of questions
 */
app.get(`${API}/questions`, (req, res) => {
    connection.query('SELECT question_id, question_text FROM question', (err, results, fields) => {
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