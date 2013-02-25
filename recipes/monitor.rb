#
# Author:: 
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
  source node['apps']['static']['source']
  mode "0644"
  checksum node['apps']['static']['artifact_sha256']

#  ignore_failure true
  retries 0
  action :create

# Not initializing, need to have checksum and source defined, set from Jenkins to env attributes,
# handled implicitly by provider or explict below
#  only_if { node['apps']['static']['artifact_sha256'].defined? && node['apps']['static']['source'].defined? }
end

rolling_deploy_artifact 'static' do
  app_name 'static'
  checksum node['apps']['static']['artifact_sha256']
  artifact_path static_artifact_path
  cookbook_name 'static_artifact'

  action :nothing

  subscribes resources('remote_file[static]')

# checksum of assumed and what is on file needs to match, handled implicitly by provider or explict below
#  only_if { Digest::SHA256.file( static_artifact_path ).eql?( node['apps']['static']['artifact_sha256'] ) }
end

