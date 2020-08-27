# DEMO

https://arcane-island-35232.herokuapp.com/

# README -

[![Build Status](https://travis-ci.com/UK-CoVid19/opencell-testing.svg?branch=master)](https://travis-ci.com/UK-CoVid19/opencell-testing)

## How To Run

 - Ruby Version `2.7.1`
 - Requires running Postgres db with user called `postgres` and password of `password` on `localhost:5432`
 - Requires`node.js`
 - `bundle install`
 - `npm install`
 - `rake db:create`
 - `rake db:schema:load`
 - `rake db:seed`
 - `rails s`
 
 ## Demo version
 
A Demo version of the software is availabe to view here: https://arcane-island-35232.herokuapp.com/

Login link is here: https://arcane-island-35232.herokuapp.com/users/sign_in

 - To access the staff version of the site, log in with the credentials of 'email@example.com' and password of 'password' 

 - To access the patient version of the you can sign up with your own details. 

As a staff member you can navigate with the links at the top to see samples as different stages of the process, the dashboard link (https://arcane-island-35232.herokuapp.com/samples/dashboard) gives an overview of which samples are at which state.

The 'pending prepare' step shows how a QR labeled sample can be assigned to a plate using a camera to scan the code.

https://arcane-island-35232.herokuapp.com/samples/pendingprepare

To do a full demo, a user would need to print off the code / show the sample code on a separate screen. A fallback mechanism with an autocomplete exists where the camera may not be available.
