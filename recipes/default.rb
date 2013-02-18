#
# Cookbook Name:: staticapp
# Recipe:: default
#

include_recipe "java"

case node.platform
when "centos","redhat","fedora"
  include_recipe "jpackage"
end

#Scenario 1
#Master should install a tar file containing tomcat in user space on 5 to 6nodes by un tarring the tar ball and executing the start server shell command for tomcat.
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
#Scenario 3
#Node six and seven joins the cluster,  deploy the same tomcat to these servers and add both these servers as dependency to node 5 and node 6 i.e they will wait for node 5 and 6 to complete their deployment and health check, before they can go ahead and start their deployments.
rolling_deploy_leg "set leg" do
  app_name 'static'
  action :tag
end

#Scenario 2
#1) New tar gets deployed on to chef master with a different checksum (and same name),  for demo this can be done by un tarring the tar file manually and again tarring it back.
#2) Master should install this new tar file (after stopping the already running server and archiving the current build) on one node by un tarring the tar ball and executing the start server shell.
#3) After starting the tomcat, agent should wait for 15 seconds ( just to let it warm up and load user caches ), may be through shell sleep command
#4) Perform the health check of running tomcat by doing jps>>log.out on the first node and parsing the log.out to check if there is a process running, may be a simple shell script.
#5) If the health check succeeds, move to second node to further do the same process,
#6) if the health check on second node succeeds, move to third and forth (together or in parallel) nodes and do the deployments
#7) finally if both third and forth node succeeds then move to fifth and sixth node to do the deployments.
rolling_deploy_leg 'install to current' do
  app_name 'static'
  checksum node['apps']['static']['checksum']
  action :ready
end

remote_file 'static' do
  path "#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['checksum']}.war"
  source node['apps']['static']['source']
  mode "0644"
  checksum node['apps']['static']['checksum']
  action :nothing

  subscribes :create, resources('rolling_deploy_leg[install to current]'), :immediately
end

# Only write out new application context when we are ready to install on this leg and have acquired app
template "#{node['apps']['static']['deploy_dir']}/shared/static.xml" do
  source "context.xml.erb"
  owner "nobody"
  mode "644"
  variables(
    :app => 'static',
    :war => "#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['checksum']}.war"
  )
  action :nothing

  subscribes :create, resources('remote_file[static]'), :immediately
end

#Link ROOT context to our custom app
link "#{node['tomcat']['context_dir']}/ROOT.xml" do
  to "#{node['apps']['static']['deploy_dir']}/shared/static.xml"
end

#Cleanup caches and old application ONLY if we are ready to install AND have acquired artifact
directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :nothing

  subscribes :delete, resources('remote_file[static]'), :immediately
end

directory "#{node['tomcat']['work_dir']}/Catalina" do
  recursive true
  action :nothing

  subscribes :delete, resources('remote_file[static]'), :immediately
end


#3) After starting the tomcat, agent should wait for 15 seconds ( just to let it warm up and load user caches ), may be through shell sleep command
#4) Perform the health check of running tomcat by doing jps>>log.out on the first node and parsing the log.out to check if there is a process running, may be a simple shell script.
#
#Scenario 2.
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
    
  subscribes :start, resources( "template[/etc/default/tomcat6]" )
  subscribes :start, resources( "template[/etc/tomcat6/server.xml]" )
  subscribes :start, resources( "link[#{node['tomcat']['context_dir']}/ROOT.xml]" )
  subscribes :start, resources( 'remote_file[static]' )

end

#4) Perform the health check of running tomcat by doing jps>>log.out on the first node and parsing the log.out to check if there is a process running, may be a simple shell script.
#
http_request "validate deployment" do
  url "http://localhost:8080/static"
#  url "http://localhost:8080/fail"
  message ""
  action :get

  only_if { File.exists?("#{node['apps']['static']['deploy_dir']}/releases/#{node['apps']['static']['checksum']}.war") }
end

rolling_deploy_node "successful deploy" do
  app_name 'static'
  action :nothing

  subscribes :success, resources('http_request[validate deployment]')
end

#require 'chef/mixin/shell_out'
#require 'chef/mixin/language'
#include Chef::Mixin::ShellOut
#
#execute "start_tomcat" do
#  command "startup.sh"
#
#  returns 0
#
# retries 5
# retry_delay 12
#
#  not_if { shell_out!('jps').match(/bootstrap/i) }
#end
