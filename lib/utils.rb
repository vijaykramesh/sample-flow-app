require 'aws/decider'


$S3_BUCKET               = ENV['S3_BUCKET']
$S3_PATH                 = ENV['S3_PATH']
$RUBYFLOW_DECIDER_DOMAIN = ENV['SWF_DOMAIN']
$TASK_LIST               = [ $S3_BUCKET, $S3_PATH ].join(":")

# make sure ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY'] are set
@swf = AWS::SimpleWorkflow.new

if $RUBYFLOW_DECIDER_DOMAIN
  begin
    @domain = @swf.domains[$RUBYFLOW_DECIDER_DOMAIN]
    @domain.status
  rescue AWS::SimpleWorkflow::Errors::UnknownResourceFault => e
    raise "I'm not going to create your SWF domain #{$RUBYFLOW_DECIDER_DOMAIN} as domains are a limited resource."
  end
end