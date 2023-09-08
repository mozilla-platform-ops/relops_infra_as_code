# circleci-ubuntu-2004

used to generate https://hub.docker.com/repository/docker/mozillarelops/circleci-ubuntu-2204

## build, test, publish process

```shell
# build
docker build . --platform linux/amd64 -t mozillarelops/circleci-ubuntu-2204(:VERSION_TAG_GOES_HERE)

# get a shell and test
docker run -it --platform linux/amd64 mozillarelops/circleci-ubuntu-2204
# inspect
docker image inspect mozillarelops/circleci-ubuntu-2204

# publish
docker push mozillarelops/circleci-ubuntu-2204:VERSION_TAG_GOES_HERE
```

