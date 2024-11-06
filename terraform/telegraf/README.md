# telegraf

## overview

most of the work is done via `aws_ecs_service` and `aws_ecs_task_definition` instances. search for those.

### details


####  map of tf files to `aws_ecs_service` names

```
ecs-cluster.tf:
  52: resource "aws_ecs_task_definition" "app" {
  53    family                   = "telegraf"

ecs-queues.tf:
  17: resource "aws_ecs_task_definition" "app_queues" {
  38:       { "name" : "TELEGRAF_CONFIG", "value" : "telegraf_queues.conf" },

ecs-vcs.tf:
  16
  17: resource "aws_ecs_task_definition" "app_vcs" {
  38:       { "name" : "TELEGRAF_CONFIG", "value" : "telegraf_vcs.conf" },

ecs-workers.tf:
  17: resource "aws_ecs_task_definition" "app_workers" {
  38:       { "name" : "TELEGRAF_CONFIG", "value" : "telegraf_workers.conf" },
```

#### docker image ekr versions

```
telegraf: 1.9
telegraf_queues: 1.9
telegraf_vcs: 1.9
telegraf_worker: 1.16
```

#### what they do

```bash
# format: conf file used, what it does/runs, instances (default is 1)
telegraf: telgraf.conf, listens for webhooks, 2 instances
telegraf_queues: telegraf_queues.conf, provides tc worker pool info,
            runs queue.sh and tc-web.sh,
            tc-web example output:
                (  "workers": 2,
                "runningWorkers": 0,
                "idleWorkers": 0,
                "quarantinedWorkers": 2,
                "pendingTasks": 0
                )
telegraf_vcs: telegraf_vcs.conf, runs:
            release_cal.sh
            google_chrome_releases.sh
            check_vcs.sh
            treestatus2.sh
telegraf_worker: telegraf_workers.conf, provides tc worker success info,
            runs queue2.sh which provides:
                "workers":4,"completed": 2, "failed": 3, "idle":4,"quarantined":0,"pendingTasks": 0

```

#### running locally (gcp)

```bash
# open a interactive docker container
./docker_build && ./docker_run

# run stuff
TELEGRAF_CONFIG=telegraf_workers.conf ./docker_run

# another example
TELEGRAF_CONFIG=telegraf-aerickson-testing.conf ./docker_run

# lower level test, collects data, prints data, exits
docker_run /bin/bash
TELEGRAF_CONFIG=telegraf-aerickson-testing-2.conf /etc/telegraf/startup.sh --test

# test
curl http://localhost:9273/metrics
./test.sh

# kill leftover containers
docker stop $(docker ps | grep moz_telegraf_gcp | cut -f 1 -d ' ')

```

## reverse engineering the dockerfile

The dockerfile was missing. Recreated from the image running in AWS.

### pulling an image from ECR

see https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-pull-ecr-image.html

### login to ECR

```bash
# get these from the aws SSO portal
#
# project is:
#   relops-aws-prod
#     961225894672 | relops-aws-prod@mozilla.com
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...

 aws ecr get-login-password --region us-west-2  | docker login --username AWS --password-stdin 961225894672.dkr.ecr.us-west-2.amazonaws.com

#  docker login
```

### list ECR repos and images

```bash
aws ecr describe-repositories

# for help: `aws ecr describe-images help`

aws ecr describe-images --repository-name telegraf

aws ecr describe-images \
    --repository-name telegraf \
    --image-ids imageTag=1.7

# list tags
aws ecr describe-images --repository-name telegraf --query "sort_by(imageDetails,& imagePushedAt)[ * ].imageTags[ * ]"
```

### pulling a container

```bash
docker pull 961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:latest

docker pull 961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:'1.7'

# run it
docker run -it 961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf /bin/bash
```

### reverse-engineering an image to a Dockerfile

From https://stackoverflow.com/questions/19104847/how-to-generate-a-dockerfile-from-an-image.

Uses https://hub.docker.com/r/alpine/dfimage (that uses https://github.com/P3GLEG/Whaler).

```
alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"

# once image has been pulled, see above
dfimage -sV=1.36 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf:latest
```

### exporting layers of a Docker image

https://github.com/micahyoung/docker-layer-extract

```bash
go install github.com/micahyoung/docker-layer-extract@latest
~/go/bin/docker-layer-extract -h

```

## reference links
- aws services
  - https://docs.aws.amazon.com/ecs/
  - https://docs.aws.amazon.com/ecr/
- prometheus
  - https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format
  - https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md
  - https://github.com/influxdata/telegraf/tree/master/plugins/outputs/prometheus_client
- telegraf
  - https://github.com/influxdata/telegraf/blob/master/plugins/inputs/exec/README.md