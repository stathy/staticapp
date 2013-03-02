#
# Author:: cookbook@opscode.com
# CreatedBy:: Stathy Touloumis stathy@opscode.com
#
# Cookbook Name:: staticapp
# Recipe:: default
#
# Copyright 2013, Opscode, Inc.
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
#

include_recipe "java"

case node.platform
when "centos","redhat","fedora"
  include_recipe "jpackage"
end

value_for_platform(
  ["debian","ubuntu"] => {
    "default" => ["tomcat6","tomcat6-admin"]
  },
  ["centos","redhat","fedora"] => {
    "default" => ["tomcat6","tomcat6-admin-webapps"]
  },
  "default" => ["tomcat6"]
).each do |pkg|
  package pkg do
    action :install
  end
end

%w( shared releases ).each do |dir|
  directory "#{node['apps']['static']['deploy_dir']}/#{dir}" do
    owner 'nobody'
    mode '0755'
    recursive true
  end
end

template "/etc/default/tomcat6" do
  source "default_tomcat6.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/tomcat6/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode "0644"
end

#Identify the leg this node should fall into
#
rolling_deploy_leg "set leg" do
  app_name 'static'
  action :tag
end

rolling_deploy_leg 'install to current' do
  app_name 'static'
  desired node['apps']['static']['desired']
  action :ready
end

cookbook_file 'static' do
  cookbook 'static_artifact'
  path "#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['desired']}.war"
  source node['apps']['static']['source']
  mode "0644"
  checksum node['apps']['static']['desired']
  action :nothing

  subscribes :create, resources('rolling_deploy_leg[install to current]'), :immediately
end

remote_file 'static' do
  path "#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['desired']}.war"
  source "http://foo.com/bar.war"
  mode "0644"
  checksum node['apps']['static']['desired']
  action :nothing
  
# Optional way to obtain payload if we are not using cookbook method.
#  subscribes :create, resources('rolling_deploy_leg[install to current]'), :immediately
  only_if { false }
end

# Only write out new application context when we are ready to install on this leg and have acquired app
template "#{node['apps']['static']['deploy_dir']}/shared/static.xml" do
  source "context.xml.erb"
  owner "nobody"
  mode "644"
  variables(
    :app => 'static',
    :war => "#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['desired']}.war"
  )
  action :create

#  subscribes :create, resources('cookbook_file[static]'), :immediately
end

#Link ROOT context to our custom app
link "#{node['tomcat']['context_dir']}/ROOT.xml" do
  to "#{node['apps']['static']['deploy_dir']}/shared/static.xml"
end

#Cleanup caches and old application ONLY if we are ready to install AND have acquired artifact
directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :nothing

  subscribes :delete, resources("template[#{node['apps']['static']['deploy_dir']}/shared/static.xml]"), :immediately
end

directory "#{node['tomcat']['work_dir']}/Catalina" do
  recursive true
  action :nothing

  subscribes :delete, resources("template[#{node['apps']['static']['deploy_dir']}/shared/static.xml]"), :immediately
end

#Keep checking for the running process for tomcat every minute, in case server is down...start it else in case server is still up ..don't do anything.
service "tomcat" do
  service_name "tomcat6"
  supports :stop => true, :start => true
  retries 5
  retry_delay 10
  action [:enable, :start]

  subscribes :stop, resources( 'remote_file[static]' ), :immediately

  subscribes :stop, resources( "template[/etc/default/tomcat6]" )
  subscribes :stop, resources( "template[/etc/tomcat6/server.xml]" )
  subscribes :stop, resources( "link[#{node['tomcat']['context_dir']}/ROOT.xml]" )
  subscribes :stop, resources( "template[#{node['apps']['static']['deploy_dir']}/shared/static.xml]" )
    
  subscribes :start, resources( "template[/etc/default/tomcat6]" )
  subscribes :start, resources( "template[/etc/tomcat6/server.xml]" )
  subscribes :start, resources( "link[#{node['tomcat']['context_dir']}/ROOT.xml]" )
  subscribes :start, resources( 'remote_file[static]' )
  subscribes :start, resources( "template[#{node['apps']['static']['deploy_dir']}/shared/static.xml]" )

end

http_request "validate deployment" do
  url "http://localhost:8080/static"
#  url "http://localhost:8080/fail"
  message ""
  action :get

  retries 2
  retry_delay 5

  only_if { File.exists?("#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['desired']}.war") }
end

rolling_deploy_node "successful deploy" do
  app_name 'static'
  action :nothing
  desired node['apps']['static']['desired']

  subscribes :success, resources('http_request[validate deployment]'), :immediately
end

