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