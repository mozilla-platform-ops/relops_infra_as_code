tag_project_name = "telegraf"

relay_image = "961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:1.6"
relay_port = 8086
webhook_port = 1619

relay_count = 2
relay_cpu = 512
relay_memory = 1024

collection_image = "961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:1.6"

collection_count = 1
collection_cpu = 4096
collection_memory = 8192

influxdb_url = "https://hilldale-b40313e5.influxcloud.net:8086"
influxdb_db = "relops_workers"
influxdb_user = "relops_wo"

interval = "300s"
medium_interval = "600s"
long_interval = "1200s"
