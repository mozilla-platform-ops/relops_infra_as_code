tag_project_name = "telegraf"

app_count = 1

app_image = "961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:latest"

fargate_cpu = 4096

fargate_memory = 8192

app_port = 8086

webhook_port = 1619

influxdb_url = "http://34.214.39.141:8086"

influxdb_db = "relops"

influxdb_user = "relops_wo"

interval = "150s"

medium_interval = "300s"

long_interval = "600s"
