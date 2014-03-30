#!/usr/sh

rake assets:precompile
jammit-s3
git push heroku master
