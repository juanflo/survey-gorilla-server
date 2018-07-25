# Survey-Gorilla-Server


As part of PI2 Innovation Week, we decided to improve our squad health check process by building a simple survey app which we take before every retro meeting. The hope is we can see trends, foster conversations and improve our overall team health.

API Server Contributors:
[Juan Flores](https://github.com/juanflo), 
[Sinh Nguyen](https://github.com/sinkng), 
[Matt Wong](https://github.com/wongm3)

------------------------------------------

## Build and Deploy Locally

In order to run the server you will need [mariadb](https://mariadb.org/). On a Mac it is recommened to use [Homebrew](https://brew.sh/).


1. Run the `db-setup.sql` script in terminal:
```
mysql -u <db user> -p<password> < scripts/db-setup.sql
```
* Make sure you create a database user for this app. _DO NOT USE THE ROOT USER_.

2. With your database already installed and setup, create a `.env` file copying the fields from `.env.sample`:
```
SERVER=localhost
PORT=8080
DB_SERVER=localhost
DB_USER=
DB_PASSWORD=
DB_DATABASE=gorilla
```
3. In the root folder run `yarn` to install all the dependencies.

4. To start the server, run `yarn start`.

The server should start up with the following logging:
```
Server has been started on port 8080
Connected to the database with id 75
```