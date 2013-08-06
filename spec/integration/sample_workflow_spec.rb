require 'aws-sdk'
require 'aws/decider'
require './lib/sample_workflow'
# NOTE for this spec to work, you'll need to export
# AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to your env
# also make sure s3_bucket_name exists in your account,
# and that you have created swf_domain_name in SWF. Workflow
# and activity types should automatically be created for you.

def try_soft_loud
  begin
    yield
  rescue => e
    puts "PROBLEM!! #{e}"
    puts e.backtrace
  end
end


def wait_for_workflow_execution_complete(workflow_execution)
  sleep 1 while :open == (status = workflow_execution.status)
  raise "workflow_execution #{workflow_execution} did not succeed: #{workflow_execution.status}" unless status == :completed
end

describe 'SampleWorkflow' do
  let(:test_run_identifier) {
    "spec-aws-swf/%08x-%08x" % [Time.now.to_i, rand(0xFFFFFFFF)]
  }
  let(:swf_domain_name) { 'aws-swf-test' }
  let(:s3_bucket_name)  { 'change-test' }
  let(:s3_path)         { test_run_identifier }
  let(:task_list)       { [s3_bucket_name, s3_path].join(":") }
  let(:activity_handler_pids) {
    3.times.map {
      Process.spawn({
        'SWF_DOMAIN'     => swf_domain_name,
        'S3_BUCKET'      => s3_bucket_name,
        'S3_PATH'        => s3_path,
      }, "ruby ./lib/sample_activity.rb")
    }
  }

  let(:decision_handler_pids) {
    2.times.map {
      Process.spawn({
        'SWF_DOMAIN'     => swf_domain_name,
        'S3_BUCKET'      => s3_bucket_name,
        'S3_PATH'        => s3_path,
      }, "ruby ./lib/sample_workflow.rb")
    }
  }

  let(:s3_bucket) { AWS::S3.new.buckets[s3_bucket_name] }

  let(:swf) { AWS::SimpleWorkflow.new }

  before do
    test_run_identifier
  end

  it "runs a sample workflow" do
    begin
      # check that we've got AWS credentials
      s3_bucket.exists?

      # start swf decider/worker subprocesses
      activity_handler_pids
      decision_handler_pids

      my_workflow_client = AWS::Flow.workflow_client(swf.client, swf.domains[swf_domain_name]) { {:from_class => "SampleWorkflow", :task_list => task_list } }

      workflow_execution = my_workflow_client.start_execution({ input_param: "some input" })

      wait_for_workflow_execution_complete(workflow_execution)

      s3_bucket.objects[s3_path].read.should == { input_param: "some input", decision_param: "decision", activity_param: "activity"}.to_json

      try_soft_loud { s3_bucket.objects.with_prefix(test_run_identifier).each {|s3_object| s3_object.delete} }

    rescue AWS::Errors::MissingCredentialsError => e
      puts "NOTE: Not really running this test as we've got no AWS credentials"
    ensure
      (activity_handler_pids + decision_handler_pids).each {|pid|
        try_soft_loud { Process.kill('TERM', pid) }
      }
    end
  end



end