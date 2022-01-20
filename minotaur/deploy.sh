#!/bin/bash
#set -e
export AWS_RETRY_MODE=standard
SCRIPT_PATH=$(dirname $(realpath -s $0))

name=minotaur
aws_region=$(aws configure get region || echo "us-west-2")
repo=$(aws ec2 describe-security-groups --query 'SecurityGroups[0].OwnerId' --output text).dkr.ecr.${aws_region}.amazonaws.com

cd docker

declare version
declare major_version
function version() {
  read version <$SCRIPT_PATH/version.txt
  [[ $# -eq 0 ]] && return
  major_version=${version0:1}
  version=$(( 10#${version//./} + 1 ))
  while [[ ${#version} -lt 3 ]]; do
    version=0${version}
  done
  version=${version:0:1}.${version:1:10}
}
function save_version() {
  if [[ $major_version -ne ${version:0:1} ]]; then
    echo "Major version change. Please manually set it in version.txt."
    exit 1
  fi
  echo $version | tee $SCRIPT_PATH/version.txt
}
version
tag=$name:$version

id_before=$(docker inspect --format {{.Id}} $tag || echo None)
docker build --build-arg CONTAINER_TAG=$tag -t $tag .

id_after=$(docker inspect --format {{.Id}} $tag)
if [[ "$id_after" == "$id_before" ]]; then
  echo "No change to the container image. Not deployed."
  exit 1
fi
version update
save_version
tag=$name:$version
docker build --build-arg CONTAINER_TAG=$tag -t $tag .

url=$repo/$tag
docker tag $tag $url

aws ecr get-login-password | docker login --username AWS --password-stdin $repo
docker push $url

aws lambda update-function-code --function-name $name --image-uri $url | cat \
  && aws lambda wait function-updated --function-name minotaur

printf "To test/invoke the lambda function, execute:\naws lambda invoke --function-name minotaur out --log-type Tail --query 'LogResult' --output text --cli-binary-format raw-in-base64-out |  base64 -d\n"
