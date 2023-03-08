# Turbo Navigator demo server

This Rails server accompanies the demo app for the iOS package.

## Getting started

The server requires the usual Rails dependencies:

* Ruby 3.2.1
* [libpq](https://www.postgresql.org/docs/9.5/libpq.html) - `brew install libpq`
    * Needed to use the native `pg` gem without Rosetta on M1 macs.
* [postgresql](https://www.postgresql.org) - `brew install postgresql` 
* [node](https://nodejs.org/en/) - `brew install node`
* [Yarn](https://yarnpkg.com) - `brew install yarn`
* [Redis](https://redis.io) - `brew install redis`
* [foreman](https://github.com/ddollar/foreman) - `gem install foreman`

## Initial setup

Install dependencies and prepare the database via `bin/setup`.

## Running the server

Run the server and JavaScript/CSS processes via `bin/dev`.
