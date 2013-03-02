#
# Author:: cookbook@opscode.com
# CreatedBy:: Stathy Touloumis stathy@opscode.com
#
# Cookbook Name:: staticapp
# Recipe:: monitor
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

require 'digest'
require 'fileutils'

static_artifact_path = File.join( Chef::Config['file_cache_path'], "#{node['apps']['static']['artifact_sha256']}.war" )

remote_file 'static' do
  path static_artifact_path
  source node['apps']['static']['artifact_build']
  mode "0644"
  checksum node['apps']['static']['artifact_sha256']

# When initializing, values for artifact_sha256 may not exist so ignore failure or check idempotence
#  ignore_failure true
  retries 0
  action :create

# Not initializing, need to have checksum and source defined, set from Jenkins to env attributes,
# handled implicitly by prov
  not_if { node['apps']['static']['artifact_sha256'].nil? || node['apps']['static']['artifact_build'].nil? }
end

rolling_deploy_artifact 'static' do
  app_name 'static'
# Optional, if we want validation vs. only_if like below
  checksum node['apps']['static']['artifact_sha256']
  desired node['apps']['static']['artifact_sha256']
  artifact_path static_artifact_path

# Optionally deploy through cookbook
  cookbook_name node['apps']['static']['cookbook_name']
  cookbook_version '0.2.0'

  action :deploy

#  subscribes :deploy, resources('remote_file[static]')

# checksum of assumed and what is on file needs to match, handled implicitly by provider or explict below
  only_if {
    ::File.exists?( static_artifact_path ) &&
    Digest::SHA256.file( static_artifact_path ).to_s.eql?( node['apps']['static']['artifact_sha256'] )
  }
end

