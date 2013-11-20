# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# CreatedBy:: Stathy Touloumis <stathy@opscode.com>
#
#
# Add RVM's lib directory to the load path.
# $:.unshift(File.expand_path('./gems', '/home/touloumiss/.rvm/gems/ruby-1.9.3-p448@chef/'))

require 'chef/environment'
require 'chef/knife'
require 'chef'

require 'digest'

Chef::Log.level = :info

ID = Time.new.strftime("%Y%m%d_%H_%M_%S")

Vagrant::Config.run do |config|

    config.vm.box = "ubuntu_10_11-4"

    {
      :monitor => {
            :ip       => '192.168.65.205',
            :memory   => 256,
            :run_list => %w( role[base_core] recipe[staticapp::monitor] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'leg' => 0 } } } }
      },
      :a1 => {
            :ip       => '192.168.65.211',
            :memory   => 374,
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
      :a2 => {
            :ip       => '192.168.65.212',
            :memory   => 374,
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
      :a3 => {
            :ip       => '192.168.65.213',
            :memory   => 374,
            :env      => 'static',
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
      :a4 => {
            :ip       => '192.168.65.214',
            :memory   => 374,
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
      :a5 => {
            :ip       => '192.168.65.215',
            :memory   => 374,
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
      :a6 => {
            :ip       => '192.168.65.216',
            :memory   => 374,
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
      :a7 => {
            :ip       => '192.168.65.217',
            :memory   => 374,
            :run_list => %w( role[base_core] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'rolling_deploy' => { 'bootstrap_group' => ID, } } } }
      },
    }.each do |name,cfg|

        group_label = cfg[:env]
        chef_env = create_chef_env(group_label)

        hash = Digest::MD5.new.hexdigest(group_label)
        vagrant_group = "/#{group_label}"

        config.vm.define name do |vm_cfg|
            vm_cfg.vm.host_name = "java-#{name}-#{hash}"
            vm_cfg.vm.network :hostonly, cfg[:ip] if cfg[:ip]
            vm_cfg.vm.box = cfg[:box] if cfg[:box]

            vm_cfg.vm.customize ["modifyvm", :id, "--name", vm_cfg.vm.host_name]
            vm_cfg.vm.customize ["modifyvm", :id, "--memory", cfg[:memory]]
            vm_cfg.vm.customize ["modifyvm", :id, "--groups", vagrant_group]
            vm_cfg.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          
            if cfg[:forwards]
              cfg[:forwards].each do |from,to|
                vm_config.vm.forward_port from, to
              end 
            end
    
            vm_cfg.vm.provision :chef_client do |chef|
                chef.chef_server_url = "https://chef.localdomain/organizations/opscode"
                chef.validation_key_path = "#{ENV['HOME']}/.chef/chef_localdomain-opscode-validator.pem"
                chef.validation_client_name = "opscode-validator"
                chef.node_name = vm_cfg.vm.host_name
                chef.provisioning_path = "/etc/chef"
                chef.log_level = :info
    #            chef.output = 'doc'
                chef.environment = chef_env
                chef.json = cfg[:attr] if cfg[:attr].is_a?(Hash)
    
                if cfg[:run_list].nil?
                    cfg[:roles] ||= []
                    cfg[:roles].each { |r| chef.add_role(r) }
                    cfg[:recipes] ||= []                
                    cfg[:recipes].each { |r| chef.add_recipe(r) }
                else
                    chef.run_list = cfg[:run_list]
                end
    
            end
    
        end
    
    end

end

def create_chef_env(ce = '_default')
    Chef::Config.from_file("#{ENV['HOME']}/.chef/knife.rb")

    if ce.nil? then
        ce = '_default'

    else
        env_obj = Chef::Environment.new
        env_obj.name( ce )
      
        begin
            env_obj = Chef::Environment.load( ce )

        rescue Net::HTTPServerException => e
            raise e unless e.response.code == "404"
            env_obj.default_attributes['created_by'] ||= 'Vagrant'
            env_obj.default_attributes['created_date'] ||= Time.new.strftime("%Y_%m_%d-%H:%M:%S")

            env_obj.override_attributes( { 'apps' => { 'static' => {} } } )

            env_obj.create
        end

    end

    return ce
end


__END__

master_config.vm.provision :shell, :inline => <<-INSTALL_OMNIBUS
    if [ ! -d '/opt/chef' ] || 
       [ ! $(chef-solo --v | awk "{print \\$2}") = "#{OMNIBUS_CHEF_VERSION}" ]
    then
       wget -qO- https://www.opscode.com/chef/install.sh | sudo bash -s -- -v "#{OMNIBUS_CHEF_VERSION}"
    else
       echo "Chef #{OMNIBUS_CHEF_VERSION} already installed...skipping installation."
    fi 
INSTALL_OMNIBUS
