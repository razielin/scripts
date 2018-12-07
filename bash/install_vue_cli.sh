#!/usr/bin/env bash

sudo npm install -g @vue/cli

# make project
vue create --no-git app_name
cd app_name
# fixes Unresolved function issue for jest functions in Phpstorm
npm i @types/jest

# run unit tests in watch mode
npm run test:unit -- --watch

# DO NOT RUN jest in watch mode in Phpstorm otherwise it runs with error and all subsequent runs will fail too (including from cli)