# encoding: utf-8

title 'vpc'

deployment_id = attribute('deployment_id', default: 'unknown', description: 'Which deployment_id to inspect')
component = attribute('component', description: 'Which component things should be tagged')

describe aws_vpc_list do
  its('name') { should include "vpc-#{component}-#{deployment_id}" }
end
