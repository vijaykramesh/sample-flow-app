require './lib/utils'

class SampleActivity
  extend AWS::Flow::Activities

  activity :sample_activity do
    {
      :version => "1",
      :task_list => $TASK_LIST,
      :default_task_schedule_to_start_timeout => 3600,
      :default_task_start_to_close_timeout => 3600
    }
  end

  def sample_activity(activity_task_input)
    AWS::S3.new.buckets[$S3_BUCKET].objects[$S3_PATH].write(
      {
        input_param: activity_task_input[:input_param],
        decision_param: activity_task_input[:decision_param],
        activity_param: "activity"
      }.to_json
    )
  end
end


if __FILE__ == $0
  activity_worker = AWS::Flow::ActivityWorker.new(
    @swf.client, @domain, $TASK_LIST, SampleActivity)

  # Start the worker if this file is called directly
  # from the command line.
  puts "Starting ActivityWorker on #{$TASK_LIST}"
  activity_worker.start
end
