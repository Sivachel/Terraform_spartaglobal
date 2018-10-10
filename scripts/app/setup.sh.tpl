#!/bin/bash

export DB_HOST=${db_host}
cd /home/ubuntu/app
npm i
pm2 kill
pm2 start app.js
