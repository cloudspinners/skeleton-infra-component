# encoding: utf-8

title 'ecs cluster'

deployment_identifier = attribute('deployment_identifier', default: 'unknown', description: 'Which deployment_identifier to inspect')
component = attribute('component', description: 'Which component things should be tagged')

describe aws_ecs_cluster("#{component}-#{deployment_identifier}-main") do
  it { should exist }
end
