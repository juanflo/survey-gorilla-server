
require('dotenv').config();
const express = require('express');
const mysql = require('mysql');
const shortid = require('shortid');

const API = '/api';

const PORT = process.env.PORT || 3000;
const SERVER = process.env.SERVER || 'localhost';

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'gorilla',
    password: '1234567890',
    database: 'gorilla'
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
    connection.query('INSERT INTO teams SET ?', options, (err, results, fields) => {
        if (err) {
            console.error(`Could not register new team ${name}`);
            return;
        }

        console.info(`New team ${name} has been successfully registered.`);
    });

    res.status(201).json({
        teamId: team_shortId
    });
});

/**
 * Start a survey for a team
 */
app.post(`${API}/team/:teamId/start-survey`, (req, res) => {
    const team_shortId = req.params.teamId;
    const surveyId = shortid.generate();

    connection.query(
        `INSERT INTO surveys (survey_uuid, team_id) 
         SELECT '${surveyId}', team_id FROM teams WHERE teams.team_uuid = '${team_shortId}'`, (err, results, fields) => {
            if (err) {
                console.error(`Could not create survey ${surveyId} for team ${team_shortId}`);
                return;
            }

            res.status(201).json({
                surveyId
            });
        }
    );
});


app.get(`${API}/questions`, (req, res) => {
    connection.query('SELECT question_id, question_text FROM questions', (err, results, fields) => {
        res.status(200).json(results);
    });
});


app.listen(PORT, () => {
    console.info(`Server has been started on port ${PORT}`);
})