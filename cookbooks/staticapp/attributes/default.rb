#
# Cookbook Name:: staticapp
# Attributes:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default["apps"]['static']['source'] = 'static.war'
default["apps"]['static']['cookbook_name'] = 'static_artifact'
default["apps"]['static']['desired'] = '604bc894d6ffd68c321ba5a61d419ee0901112af88554e23c07578bfab07c7d7'
default["apps"]['static']['artifact_build'] = 'http://chef.localdomain:10080/artifacts/static.war'
default["apps"]['static']['artifact_sha256'] = '604bc894d6ffd68c321ba5a61d419ee0901112af88554e23c07578bfab07c7d7'
#default["apps"]['static']['rolling_deploy']['leg'] = 0

default["apps"]['static']['rolling_deploy']['bootstrap_group'] = Time.new.strftime("%Y%m%d_%H_%M_%S")
default["apps"]['static']['rolling_deploy']['andon_cord'] = false

default["apps"]['static']["deploy_dir"] = "/srv/static_app"

default["tomcat"]["port"] = 8080
default["tomcat"]["ssl_port"] = 8443
default["tomcat"]["ajp_port"] = 8009
default["tomcat"]["java_options"] = "-Xmx128M -Djava.awt.headless=true"
default["tomcat"]["use_security_manager"] = false
default["tomcat"]["service"]["retries"] = 12
default["tomcat"]["service"]["retry_delay"] = 5

case platform
when "centos","redhat","fedora"
  set["tomcat"]["user"] = "tomcat"
  set["tomcat"]["group"] = "tomcat"
  set["tomcat"]["home"] = "/usr/share/tomcat6"
  set["tomcat"]["base"] = "/usr/share/tomcat6"
  set["tomcat"]["config_dir"] = "/etc/tomcat6"
  set["tomcat"]["log_dir"] = "/var/log/tomcat6"
  set["tomcat"]["tmp_dir"] = "/var/cache/tomcat6/temp"
  set["tomcat"]["work_dir"] = "/var/cache/tomcat6/work"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "/var/lib/tomcat6/webapps"
when "debian","ubuntu"
  set["tomcat"]["user"] = "tomcat6"
  set["tomcat"]["group"] = "tomcat6"
  set["tomcat"]["home"] = "/usr/share/tomcat6"
  set["tomcat"]["base"] = "/var/lib/tomcat6"
  set["tomcat"]["config_dir"] = "/etc/tomcat6"
  set["tomcat"]["log_dir"] = "/var/log/tomcat6"
  set["tomcat"]["tmp_dir"] = "/tmp/tomcat6-tmp"
  set["tomcat"]["work_dir"] = "/var/cache/tomcat6"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "/var/lib/tomcat6/webapps"
else
  set["tomcat"]["user"] = "tomcat6"
  set["tomcat"]["group"] = "tomcat6"
  set["tomcat"]["home"] = "/usr/share/tomcat6"
  set["tomcat"]["base"] = "/var/lib/tomcat6"
  set["tomcat"]["config_dir"] = "/etc/tomcat6"
  set["tomcat"]["log_dir"] = "/var/log/tomcat6"
  set["tomcat"]["tmp_dir"] = "/tmp/tomcat6-tmp"
  set["tomcat"]["work_dir"] = "/var/cache/tomcat6"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "/var/lib/tomcat6/webapps"
end