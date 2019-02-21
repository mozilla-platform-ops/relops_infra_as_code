# Nightly event to trigger lambda
resource "aws_cloudwatch_event_rule" "every minute" {
  name        = "schedule_timeline_repo_mirror_sync"
  description = "Triggers the Timeline Repo lambda nightly"
  # cron nightly around 2am PST/9am UTC (aka mozilla time)
	schedule_expression = "cron(0 9 * * ? *)"
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = "${aws_cloudwatch_event_rule.nightly.name}"
  target_id = "TriggerLambda"
  arn       = "${aws_lambda_function.timeline_repo_mirror_sync.arn}"
}