require 'aws/decider'
require './lib/utils'
require './lib/sample_workflow'

# Get a workflow client to start the workflow
my_workflow_client = AWS::Flow.workflow_client(@swf.client, @domain) {
  {:from_class => "SampleWorkflow"} }

puts "Starting an execution..."
workflow_execution = my_workflow_client.start_execution({ input_param: "some input" })