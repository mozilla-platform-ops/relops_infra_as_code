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

#### issues pulling numbered or sha256'd images

```bash
# works
docker pull 961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:latest

# fails
docker pull 961225894672.dkr.ecr.us-west-2.amazonaws.com/telegraf:1.9
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

 aws ecr get-login-password --region us-east-1  | docker login --username AWS --password-stdin 961225894672.dkr.ecr.us-east-1.amazonaws.com

 docker login
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
docker pull 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf:latest

docker pull 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf:'1.7'

# run it
docker run -it 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf /bin/bash
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

- https://docs.aws.amazon.com/ecs/
- https://docs.aws.amazon.com/ecr/