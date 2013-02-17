# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'digest'

ID = Time.new.strftime("%Y%m%d_%H_%M_%S")

Vagrant::Config.run do |config|

    config.vm.box = "ubuntu_10_pkg"

    {
      :a1 => {
            :ip       => '192.168.65.211',
            :memory   => 256,
            :run_list => %w( role[base_ubuntu] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'bootstrap_group' => ID, } } }
      },
      :a2 => {
            :ip       => '192.168.65.212',
            :memory   => 256,
            :run_list => %w( role[base_ubuntu] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'bootstrap_group' => ID, } } }
      },
      :a3 => {
            :ip       => '192.168.65.213',
            :memory   => 256,
            :env      => 'static',
            :run_list => %w( role[base_ubuntu] recipe[staticapp] ),
            :attr     => { 'apps' => { 'static' => { 'bootstrap_group' => ID, } } }
      },
      :a4 => {
            :ip       => '192.168.65.214',
            :memory   => 256,
            :run_list => %w( role[base_ubuntu] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'bootstrap_group' => ID, } } }
      },
      :a5 => {
            :ip       => '192.168.65.215',
            :memory   => 256,
            :run_list => %w( role[base_ubuntu] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'bootstrap_group' => ID, } } }
      },
      :a6 => {
            :ip       => '192.168.65.216',
            :memory   => 256,
            :run_list => %w( role[base_ubuntu] recipe[staticapp] ),
            :env      => 'static',
            :attr     => { 'apps' => { 'static' => { 'bootstrap_group' => ID, } } }
      },

    }.each do |name,cfg|

        chef_env = create_chef_env(cfg[:env] || ENV['CHEF_ENV'])
        vagrant_group = "/#{chef_env}"
        hash = Digest::MD5.new.hexdigest(chef_env)

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
                    cfg['role'] ||= []
                    cfg['role'].each { |r| chef.add_role(r) }
                    cfg['recipe'] ||= []                
                    cfg['recipe'].each { |r| chef.add_recipe(r) }
                else
                    chef.run_list = cfg[:run_list]
                end
    
            end
    
        end
    
    end

end

def create_chef_env(ce = '_default')
    url = "https://chef.localdomain/organizations/opscode"
    c_name = "chef"
    c_file = %Q(#{ENV['HOME']}/.chef/#{c_name}@chef.localdomain.pem)

    unless ce == '_default'
        require 'ridley'
        require 'pathname'
        require 'openssl'

        org_name = Pathname.new(url).basename
        conn = Ridley.connection({
            server_url: url,
            organization: org_name,
            client_name: c_name,
            client_key: c_file,
            ssl: { verify: false }
        })

        if conn.environment.find(ce).nil?
            env = conn.environment.new
            env.name = ce
            env.save
        end

    end

    return ce
end


__END__

