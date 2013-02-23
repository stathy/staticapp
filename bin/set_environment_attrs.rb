#!/opt/chef/embedded/bin/ruby
#

require 'chef/environment'
require 'chef'
require 'digest'

Chef::Config.from_file("/path/to/knife.rb")

environment_name = 'dev'
app_name = 'athena-proxy'

env_obj = Chef::Environment.load(environment_name)

#artifact_path = "/var/www/html/artifacts/#{ENV['JOB_NAME']}/#{ENV['BUILD_NUMBER']}/dbapp.war"
#checksum = Digest::SHA256.file(artifact_path).hexdigest

env_obj.override_attributes['apps'][app_name]['source'] = 'http://path/to/artifacts.tgz'
env_obj.override_attributes['apps'][app_name]['checksum'] = ''
env_obj.save



__END__