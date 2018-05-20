require 'confidante'
require 'rake_terraform'
require 'rake_docker'
require 'rake/clean'

require_relative 'lib/paths'
require_relative 'lib/terraform_output'
require_relative 'lib/version'
require_relative 'lib/secure_parameter'
require_relative 'lib/key_maker'

configuration = Confidante.configuration
delivery_statebucket_name = "delivery-state-#{configuration.estate}-#{configuration.component}"
deployment_statebucket_name = "deployment-state-#{configuration.estate}-#{configuration.component}-#{configuration.deployment_identifier}"

delivery_statebucket_config = {
  :region => configuration.region,
  :bucket=> delivery_statebucket_name,
  :encrypt => "true"
}

deployment_statebucket_config = {
  :region => configuration.region,
  :bucket=> deployment_statebucket_name,
  :encrypt => "true"
}

version = Version.from_file('build/version')

RakeTerraform.define_installation_tasks(
  path: File.join(Dir.pwd, 'vendor', 'terraform'),
  version: '0.11.7'
)

CLEAN.include('build')
CLEAN.include('work')
CLEAN.include('dist')
CLOBBER.include('vendor')



namespace :delivery do

  Dir.entries('delivery').select { |entry|
    File.directory? File.join('delivery',entry) and !(entry =='.' || entry == '..')
  }.each { |delivery_stack|

    namespace delivery_stack do

      RakeTerraform.define_command_tasks do |t|
        t.configuration_name = "delivery-#{delivery_stack}"
        t.source_directory = "delivery/#{delivery_stack}/infra"
        t.work_directory = 'work'

        puts "============================="
        puts "delivery/#{delivery_stack}"
        puts "============================="


        t.backend_config = delivery_statebucket_config.clone
        t.backend_config[:key] = "state/#{delivery_stack}.tfstate"
        puts "backend:"
        puts "---------------------------------------"
        puts "#{t.backend_config.to_yaml}"
        puts "---------------------------------------"

        t.vars = lambda do |args|
          configuration
              .for_overrides(args)
              .for_scope(delivery: delivery_stack)
              .vars
        end
        puts "tfvars:"
        puts "---------------------------------------"
        puts "#{t.vars.call({}).to_yaml}"
        puts "---------------------------------------"
      end

    end
  }

  namespace :statebucket do

    puts "============================="
    puts "delivery/statebucket"
    puts "============================="

    RakeTerraform.define_command_tasks do |t|
      t.configuration_name = 'delivery-statebucket'
      t.source_directory = 'delivery-statebucket/infra'
      t.work_directory = 'work'

      t.state_file = lambda do
        Paths.from_project_root_directory('state', 'delivery', 'statebucket', 'statebucket.tfstate')
      end

      t.vars = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(delivery: 'statebucket')
            .vars
      end
      puts "statefile: #{t.state_file.call}"
      puts "tfvars:"
      puts "---------------------------------------"
      puts "#{t.vars.call({}).to_yaml}"
      puts "---------------------------------------"
    end
  end

end


namespace :deployment do

  Dir.entries('deployment').select { |entry|
    File.directory? File.join('deployment',entry) and !(entry =='.' || entry == '..')
  }.each { |deployment_stack|

    namespace deployment_stack do

      stack_configuration = configuration
        .for_scope(deployment: deployment_stack)

      unless stack_configuration.ssh_keys.nil?
        desc "Ensure ssh keys for #{deployment_stack}"
        task :ssh_keys do
          puts  "Need ssh keys:"
          stack_configuration.ssh_keys.each { |ssh_key_name|
            puts "  - #{ssh_key_name}"
            secure_parameter_ssh_key_public = "/#{configuration.estate}/#{configuration.component}/#{deployment_stack}/#{configuration.deployment_identifier}/ssh_key/#{ssh_key_name}/public"
            secure_parameter_ssh_key_private = "/#{configuration.estate}/#{configuration.component}/#{deployment_stack}/#{configuration.deployment_identifier}/ssh_key/#{ssh_key_name}/private"

            public_key = SecureParameter.get_parameter(secure_parameter_ssh_key_public, configuration.region)
            if public_key.nil? then
              key = KeyMaker.make_key(ssh_key_name)
              SecureParameter.put_parameter(secure_parameter_ssh_key_public, key[:public], configuration.region)
              SecureParameter.put_parameter(secure_parameter_ssh_key_private, key[:private], configuration.region)
              public_key = key[:public]
            end
            puts "Putting key into 'work/deployment/#{deployment_stack}/ssh_keys/#{ssh_key_name}.pub'"
            mkpath "work/deployment/#{deployment_stack}/ssh_keys"
            File.open("work/deployment/#{deployment_stack}/ssh_keys/#{ssh_key_name}.pub", 'w') {|f| f.write(public_key) }
          }
        end

        task :plan => [ :ssh_keys ]
        task :provision => [ :ssh_keys ]
      end

      RakeTerraform.define_command_tasks do |t|

        t.configuration_name = "deployment-#{deployment_stack}"
        t.source_directory = "deployment/#{deployment_stack}/infra"
        t.work_directory = 'work'

        puts "============================="
        puts "deployment/#{deployment_stack}"
        puts "============================="

        if deployment_stack == 'statebucket'
          t.backend_config = delivery_statebucket_config.clone
          t.backend_config[:key] = "state/deployment/#{configuration.deployment_identifier}/#{deployment_stack}.tfstate"
        else
          t.backend_config = deployment_statebucket_config.clone
          t.backend_config[:key] = "state/#{deployment_stack}.tfstate"
        end

        puts "backend:"
        puts "---------------------------------------"
        puts "#{t.backend_config.to_yaml}"
        puts "---------------------------------------"

        t.vars = lambda do |args|
          configuration
              .for_overrides(args)
              .for_scope(deployment: deployment_stack)
              .vars
        end
        puts "tfvars:"
        puts "---------------------------------------"
        puts "#{t.vars.call({}).to_yaml}"
        puts "---------------------------------------"
      end

    end
  }
end


namespace :account do

  Dir.entries('account').select { |entry|
    File.directory? File.join('account',entry) and !(entry =='.' || entry == '..')
  }.each { |account_stack|

    namespace account_stack do

      stack_configuration = configuration
        .for_scope(account: account_stack)

      RakeTerraform.define_command_tasks do |t|
        t.configuration_name = "account-#{account_stack}"
        t.source_directory = "account/#{account_stack}/infra"
        t.work_directory = 'work'

        puts "============================="
        puts "account/#{account_stack}"
        puts "============================="

        t.backend_config = {
          :region => stack_configuration.region,
          :bucket=> "account-state-#{stack_configuration.estate}-#{stack_configuration.component}",
          :key => "state/#{account_stack}.tfstate",
          :encrypt => "true"
        }

        puts "backend:"
        puts "---------------------------------------"
        puts "#{t.backend_config.to_yaml}"
        puts "---------------------------------------"

        t.vars = lambda do |args|
          configuration
              .for_overrides(args)
              .for_scope(account: account_stack)
              .vars
        end
        puts "tfvars:"
        puts "---------------------------------------"
        puts "#{t.vars.call({}).to_yaml}"
        puts "---------------------------------------"
      end

    end
  }
end
