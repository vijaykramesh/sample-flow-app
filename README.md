sample-flow-app
===============

Sample app with [aws-flow-ruby](https://github.com/aws/aws-flow-ruby)



You will need to create the `aws-swf-test` domain (or rename it accordingly in [the integration spec](spec/integration/sample_workflow_spec.rb)), and ensure you have an s3 bucket matching s3_bucket_name (with read/write permissions).

You will need to export `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your ENV for [the integration spec](spec/integration/sample_workflow_spec.rb) to run.


```bash
~/oss/sample-flow-app(Vijay Ramesh)[master] AWS_ACCESS_KEY_ID=REDACTED AWS_SECRET_ACCESS_KEY=REDACTED bundle exec rspec
Starting ActivityWorker on change-test:spec-aws-swf/52015966-45d12704
Starting ActivityWorker on change-test:spec-aws-swf/52015966-45d12704
Starting ActivityWorker on change-test:spec-aws-swf/52015966-45d12704
Starting WorkflowWorker on change-test:spec-aws-swf/52015966-45d12704
Starting WorkflowWorker on change-test:spec-aws-swf/52015966-45d12704
.

Finished in 7.05 seconds
1 example, 0 failures
```