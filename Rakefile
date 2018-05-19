require 'confidante'
require 'rake_terraform'
require 'rake_docker'
require 'rake/clean'

require_relative 'lib/paths'
require_relative 'lib/terraform_output'
require_relative 'lib/version'

configuration = Confidante.configuration
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

      stack_configuration = configuration
        .for_scope(delivery: delivery_stack)

      RakeTerraform.define_command_tasks do |t|
        t.configuration_name = "delivery-#{delivery_stack}"
        t.source_directory = "delivery/#{delivery_stack}/infra"
        t.work_directory = 'work'

        puts "============================="
        puts "delivery/#{delivery_stack}"
        puts "============================="

        t.backend_config = {
          :region => stack_configuration.region,
          :bucket=> "delivery-state-#{stack_configuration.estate}-#{stack_configuration.component}",
          :key => "state/#{delivery_stack}.tfstate",
          :encrypt => "true"
        }
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
end


namespace :deployment do

  Dir.entries('deployment').select { |entry|
    File.directory? File.join('deployment',entry) and !(entry =='.' || entry == '..')
  }.each { |deployment_stack|

    namespace deployment_stack do

      stack_configuration = configuration
        .for_scope(deployment: deployment_stack)

      RakeTerraform.define_command_tasks do |t|

        t.configuration_name = "deployment-#{deployment_stack}"
        t.source_directory = "deployment/#{deployment_stack}/infra"
        t.work_directory = 'work'

        puts "============================="
        puts "deployment/#{deployment_stack}"
        puts "============================="

        t.backend_config = {
          :region => stack_configuration.region,
          :bucket=> "deployment-state-#{stack_configuration.estate}-#{stack_configuration.component}-#{stack_configuration.deployment_identifier}",
          :key => "state/#{deployment_stack}.tfstate",
          :encrypt => "true"
        }
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
