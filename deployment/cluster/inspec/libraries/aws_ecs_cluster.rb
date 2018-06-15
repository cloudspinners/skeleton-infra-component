class AwsEcsCluster < Inspec.resource(1)
  name 'aws_ecs_cluster'
  desc 'Verifies settings for an AWS ECS Cluster'
  example "
    describe aws_ecs_cluster('mycluster') do
      it { should exist }
    end
  "
  supports platform: 'aws'

  include AwsSingularResourceMixin

  attr_reader :status,
              :cluster_name, 
              :instances_count, 
              :pending_tasks_count, 
              :running_tasks_count, 
              :active_services_count

  def to_s
    "AWS ECS #{cluster_name}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:cluster_name],
      allowed_scalar_name: :cluster_name,
      allowed_scalar_type: String,
    )

    if validated_params.empty?
      raise ArgumentError, 'You must provide a cluster_name to aws_ecs_cluster.'
    end

    validated_params
  end

  def fetch_from_api
    backend = BackendFactory.create(inspec_runner)
    begin
      clusters = backend.describe_clusters(clusters: [cluster_name]).clusters
      @exists = true
      unpack_describe_clusters_response(clusters.first)
    rescue Aws::ElasticLoadBalancing::Errors::LoadBalancerNotFound
      @exists = false
      populate_as_missing
    end
  end

  def unpack_describe_clusters_response(lb_struct)
    @status = lb_struct.status
    @cluster_name = lb_struct.cluster_name
    @instances_count = lb_struct.registered_container_instances_count
    @pending_tasks_count = lb_struct.pending_tasks_count
    @running_tasks_count = lb_struct.running_tasks_count
    @active_services_count = lb_struct.active_services_count
  end

  def populate_as_missing
    @status = []
    @cluster_name = []
    @instances_count = []
    @pending_tasks_count = []
    @running_tasks_count = []
    @active_services_count = []
  end

  class Backend
    class AwsClientApi < AwsBackendBase
      BackendFactory.set_default_backend(self)
      self.aws_client_class = Aws::ECS::Client

      def describe_clusters(query = {})
        aws_service_client.describe_clusters(query)
      end
    end
  end
end

