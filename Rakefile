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


namespace :images do

  namespace "nginx" do
    RakeDocker.define_image_tasks do |t|
      t.argument_names = [:deployment_identifier]

      t.image_name = "nginx"
      t.work_directory = 'build/images'

      t.copy_spec = [
        "role-nginx/src/Dockerfile",
        "role-nginx/src/html"
      ]

      t.create_spec = [
        {content: version.to_s, to: 'VERSION'},
        {content: version.to_docker_tag, to: 'TAG'}
      ]

      estate = configuration
          .for_overrides({})
          .for_scope(role_delivery: 'nginx-repository')
          .estate
      component = configuration
          .for_overrides({})
          .for_scope(role_delivery: 'nginx-repository')
          .component

      t.repository_name = "#{estate}/#{component}/nginx"

      t.repository_url = lambda do |args|
        backend_config =
            configuration
                .for_overrides(args)
                .for_scope(role_delivery: 'nginx-repository')
                .backend_config

        TerraformOutput.for(
            name: 'repository_url',
            source_directory: "role-nginx-repository-delivery/infra",
            work_directory: 'build',
            backend_config: backend_config)
      end

      t.credentials = lambda do |args|
        backend_config =
            configuration
                .for_overrides(args)
                .for_scope(role_delivery: 'nginx-repository')
                .backend_config

        region =
            configuration
                .for_overrides(args)
                .for_scope(role_delivery: 'nginx-repository')
                .region

        authentication_factory = RakeDocker::Authentication::ECR.new do |c|
          c.region = region
          c.registry_id = TerraformOutput.for(
              name: 'registry_id',
              source_directory: "role-nginx-repository-delivery/infra",
              work_directory: 'build',
              backend_config: backend_config)
        end

        authentication_factory.call
      end

      t.tags = [version.to_docker_tag, 'latest']
    end

    desc 'Build and push custom image'
    task :publish, [:deployment_identifier] do |_, args|
      deployment_identifier =
          configuration
              .for_overrides(args)
              .deployment_identifier
      Rake::Task["service:nginx:clean"].invoke(deployment_identifier)
      Rake::Task["service:nginx:build"].invoke(deployment_identifier)
      Rake::Task["service:nginx:tag"].invoke(deployment_identifier)
      Rake::Task["service:nginx:push"].invoke(deployment_identifier)
    end

  end
end


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
