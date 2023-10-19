# telegraf

## overview

most of the work is done via `aws_ecs_service` and `aws_ecs_task_definition` instances. search for those.

## pulling an image from ECR

### login to ECR

```bash
 aws ecr get-login-password --region us-east-1  | docker login --username AWS --password-stdin 961225894672.dkr.ecr.us-east-1.amazonaws.com
```

## reference links

- https://docs.aws.amazon.com/ecs/
- https://docs.aws.amazon.com/ecr/