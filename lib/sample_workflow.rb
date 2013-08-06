require './lib/utils'
require './lib/sample_activity'

class SampleWorkflow
  extend AWS::Flow::Workflows

  workflow :sample_workflow do
    {
      :version => "1", :task_list => $TASK_LIST,
      :execution_start_to_close_timeout => 3600
    }
  end

  activity_client(:activity) { {:from_class => "SampleActivity"} }

  def sample_workflow(workflow_input)
    activity.sample_activity(workflow_input.merge({decision_param: 'decision'}))
  end
end

if __FILE__ == $0

  worker = AWS::Flow::WorkflowWorker.new(
    @swf.client, @domain, $TASK_LIST, SampleWorkflow)

  # Start the worker if this file is called directly
  # from the command line.
  puts "Starting WorkflowWorker on #{$TASK_LIST}"
  worker.start
end