#!/bin/bash

watch --differences "knife search node 'apps_static:* AND apps_static_rolling_deploy:* AND apps_static_rolling_deploy_leg:*' --format json | ruby deploy_monitor.rb"

