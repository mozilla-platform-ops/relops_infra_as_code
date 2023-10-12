# circleci-ubuntu-2204

used to generate https://hub.docker.com/r/mozillarelops/circleci-ubuntu-2204

management link (requires login): https://hub.docker.com/repository/docker/mozillarelops/circleci-ubuntu-2204

## build, test, publish process

```shell
# build
docker build . --platform linux/amd64 -t mozillarelops/circleci-ubuntu-2204:latest

# get a shell and test
docker run -it --platform linux/amd64 mozillarelops/circleci-ubuntu-2204
# inspect
docker image inspect mozillarelops/circleci-ubuntu-2204

# publish latest
# TODO: publish to beta (vs latest)
docker push mozillarelops/circleci-ubuntu-2204:latest

# publish version if it looks good
# - version tags are like v0.0.1
docker tag mozillarelops/circleci-ubuntu-2204:latest mozillarelops/circleci-ubuntu-2204:VERSION_TAG
docker push mozillarelops/circleci-ubuntu-2204:VERSION_TAG
```

