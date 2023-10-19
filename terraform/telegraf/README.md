# telegraf

## overview

most of the work is done via `aws_ecs_service` and `aws_ecs_task_definition` instances. search for those.

## pulling an image from ECR

see https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-pull-ecr-image.html

### login to ECR

```bash
 aws ecr get-login-password --region us-east-1  | docker login --username AWS --password-stdin 961225894672.dkr.ecr.us-east-1.amazonaws.com
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

### using curl

```bash

TOKEN=$(aws ecr get-authorization-token --region us-east-1 --output text --query 'authorizationData[].authorizationToken')

# list tags
curl -i -H "Authorization: Basic $TOKEN" https://961225894672.dkr.ecr.us-east-1.amazonaws.com/v2/telegraf/tags/list
# shows only latest!?!

```

### pulling a container

```bash
docker pull 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf:latest

docker pull 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf:'1.7'

# run it
docker run -it 961225894672.dkr.ecr.us-east-1.amazonaws.com/telegraf /bin/bash
```

## reference links

- https://docs.aws.amazon.com/ecs/
- https://docs.aws.amazon.com/ecr/