
require('dotenv').config();
const express = require('express');
const shortid = require('shortid');

const API = '/api';

const app = express();
app.use(express.json());
app.use(express.urlencoded());

app.post(`${API}/register`, (req, res) => {
    const name = req.body.name;
    const teamId = shortid.generate();
});