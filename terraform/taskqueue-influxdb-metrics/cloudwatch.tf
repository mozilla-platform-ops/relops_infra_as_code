# Nightly event to trigger lambda
resource "aws_cloudwatch_event_rule" "1m" {
  name        = "trigger_bitbar_influx_logging"
	schedule_expression = "cron(* * * * * *)"
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule      = "${aws_cloudwatch_event_rule.1m.name}"
  target_id = "lambda_trigger"
  arn       = "${aws_lambda_function.log_bitbar_data_to_influx.arn}"
}