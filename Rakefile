require 'confidante'
require 'rake_terraform'
require 'rake_docker'

require_relative 'lib/paths'
require_relative 'lib/terraform_output'
require_relative 'lib/version'

configuration = Confidante.configuration
version = Version.from_file('build/version')

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.11.7')


task :default => [ :deploy_plan ]

desc 'Show the plan for provisioning a deployment of everything in the component'
task :deployment_plan => [
  :'deployment:statebucket:plan',
  :'deployment:cluster:plan',
  :'deployment:nginx:plan'
]

desc 'Provision a deployment of everything in the component'
task :deployment => [
  :'deployment:statebucket:provision',
  :'deployment:cluster:provision',
  :'deployment:nginx:provision'
]

desc 'Show the plan for provisioning all of the delivery infrastructure for the component'
task :delivery_plan => [
  :'delivery:statebucket:plan',
  :'delivery:nginx:repository:plan'
]

desc 'Provision all of the delivery infrastructure for the component'
task :delivery => [
  :'delivery:statebucket:provision',
  :'delivery:nginx:repository:provision'
]


namespace :deployment do

  namespace :statebucket do
    RakeTerraform.define_command_tasks do |t|
      t.configuration_name = 'deployment-statebucket'
      t.source_directory = 'component/deployment-statebucket'
      t.work_directory = 'build'

      # puts "============================="
      # puts "DEBUG: DEPLOYMENT-STATEBUCKET"
      # puts "============================="

      t.backend_config = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(deployment: 'statebucket')
            .backend_config
      end
      # puts "DEBUG: backend:"
      # puts "---------------------------------------"
      # puts "#{t.backend_config.call({}).to_yaml}"
      # puts "---------------------------------------"

      t.vars = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(deployment: 'statebucket')
            .vars
      end
      # puts "DEBUG: tfvars:"
      # puts "---------------------------------------"
      # puts "#{t.vars.call({}).to_yaml}"
      # puts "---------------------------------------"
    end
  end

  namespace :cluster do
    RakeTerraform.define_command_tasks do |t|
      t.configuration_name = 'cluster'
      t.source_directory = 'role-cluster/infra'
      t.work_directory = 'build'

      t.backend_config = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(role: 'cluster')
            .backend_config
      end

      t.vars = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(role: 'cluster')
            .vars
      end
    end
  end

  namespace :nginx do
    RakeTerraform.define_command_tasks do |t|
      t.configuration_name = 'nginx'
      t.source_directory = 'role-nginx/infra'
      t.work_directory = 'build'

      t.backend_config = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(role: 'nginx')
            .backend_config
      end

      t.vars = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(role: 'nginx')
            .vars
      end
      puts "DEBUG: tfvars:"
      puts "---------------------------------------"
      puts "#{t.vars.call({}).to_yaml}"
      puts "---------------------------------------"
    end
  end

end

namespace :delivery do

  namespace :statebucket do
    RakeTerraform.define_command_tasks do |t|
      t.configuration_name = 'delivery-statebucket'
      t.source_directory = 'component/delivery-statebucket'
      t.work_directory = 'build'

      t.state_file = lambda do
        Paths.from_project_root_directory('state', 'component-delivery', 'state_bucket.tfstate')
      end

      t.vars = lambda do |args|
        configuration
            .for_overrides(args)
            .for_scope(delivery: 'statebucket')
            .vars
      end
    end
  end

  namespace :nginx do
    namespace :repository do
      RakeTerraform.define_command_tasks do |t|
        t.configuration_name = 'nginx-repository-delivery'
        t.source_directory = 'role-nginx-repository-delivery/infra'
        t.work_directory = 'build'

        t.backend_config = lambda do |args|
          configuration
              .for_overrides(args)
              .for_scope(role_delivery: 'nginx-repository')
              .backend_config
        end

        t.vars = lambda do |args|
          configuration
              .for_overrides(args)
              .for_scope(role_delivery: 'nginx-repository')
              .vars
        end
      end
    end
  end
end
