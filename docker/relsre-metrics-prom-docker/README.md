# relsre-metrics-prom-docker

This image was ported from `relops_infra_as_code/terraform/telegraf/docker_aws_influx/` (telegraf pushing to influx).

It is used to collect data from taskcluster and push it to prometheus (GMP in this case).

This runs in a GCP GKE v2 cluster (https://console.cloud.google.com/kubernetes/deployment/us-west1/webservices-low-prod/relsre-metrics-prod/relsre-metrics-telegraf-queues/overview?authuser=1&inv=1&invt=AboWTA&project=moz-fx-webservices-low-prod).

Helm charts and terraform are located at https://github.com/mozilla-it/webservices-infra/tree/main/relsre-metrics.

Tenant (https://mozilla-hub.atlassian.net/wiki/spaces/SRE/pages/588742735/Tenant+Definition#Definitions) configuration is done in the global-platform-admin repo. This tenant's config is at https://github.com/mozilla-it/global-platform-admin/blob/main/tenants/relsre-metrics.yaml.

Metrics are displayed on Yardstick (our grafana instance, https://mozilla-hub.atlassian.net/wiki/spaces/CS1/pages/886866077/Prometheus+and+Grafana+Yardstick).

## development

#### running locally (gcp)

```bash
# open a interactive docker container
./docker_build && ./docker_run

# test single scripts
./docker_run /etc/telegraf/release_cal_prom.sh
./docker_run '/etc/telegraf/queue2_prom.sh proj-autophone'

# testing entire configs
./docker_run /bin/bash
# run one of the next two lines
TELEGRAF_CONFIG=telegraf_workers.conf /etc/telegraf/startup.sh --debug &
TELEGRAF_CONFIG=telegraf_queues.conf /etc/telegraf/startup.sh --debug &

# run stuff
TELEGRAF_CONFIG=telegraf_workers.conf ./docker_run

# another example
TELEGRAF_CONFIG=telegraf-aerickson-testing.conf ./docker_run

# lower level test, collects data, prints data, exits
docker_run /bin/bash
TELEGRAF_CONFIG=telegraf-aerickson-testing-2.conf /etc/telegraf/startup.sh --test

# test
curl http://localhost:8000/metrics
./test.sh

# kill leftover containers
docker stop $(docker ps | grep moz_telegraf_gcp | cut -f 1 -d ' ')

```

## deployment

### build image and push to artifact registry

```shell
# ./docker_build
docker buildx build --no-cache --platform linux/amd64 -t relsre-metrics .
# note the resulting image sha1 (`docker images`), use it below in the `docker tag` command

# replace VERSION with next version (check artifact registry, link below)
#   - https://console.cloud.google.com/artifacts/docker/moz-fx-relsre-metrics-prod/us/relsre-metrics-prod/relsre-metrics?authuser=1&invt=AboNNQ&project=moz-fx-relsre-metrics-prod)
docker tag SHA1 us-docker.pkg.dev/moz-fx-relsre-metrics-prod/relsre-metrics-prod/relsre-metrics:VERSION
docker push us-docker.pkg.dev/moz-fx-relsre-metrics-prod/relsre-metrics-prod/relsre-metrics:VERSION
```

### helm deploy

#### first run

```shell
# install helm diff plugin
helm plugin install https://github.com/databus23/helm-diff

# install gcp-bastion-tunnel
#   see https://github.com/mozilla-it/gcp-bastion-tunnel/tree/main

```

#### every run

```shell
# authenticate
gcloud container clusters get-credentials webservices-high-prod --region=us-west1 --project moz-fx-webservices-high-prod

# set the context (can use kubectx also)
#   from ntade:
#     so webservices-high-nonprod would be for i.e. dev and stage, and webservices-high-prod would be for prod
kubectl config use-context webservices-low-prod_us-west1

# start the tunnel (will use current context to infer details)
gcp-bastion-tunnel

# set the namespace (can use kubens also)
# kubectl config set-context --namespace=relsre-metrics????
#
# https://stackoverflow.com/questions/61171487/what-is-the-difference-between-namespaces-and-contexts-in-kubernetes
kubens relsre-metrics-prod

cd ~/git/webservices-infra/relsre-metrics/k8s/relsre-metrics

# view diff between running and local
helm diff upgrade --install relsre-metrics . -f values-prod.yaml --namespace=relsre-metrics-prod

# apply it if it looks good
helm upgrade --install relsre-metrics . -f values-prod.yaml --namespace=relsre-metrics-prod --debug

# view deployments
helm list --namespace relsre-metrics-prod

# inspect pod for errors
kubectl describe pod relsre-metrics-telegraf-queues  -n relsre-metrics-prod

# view quotas
kubectl get resourcequota -n relsre-metrics-prod

# view cpu/ram usage for running pods
kubectl top pod

# misc
kubectl get pods
kubectl get services

# tunneling to a pod to check a web page
kubectl port-forward relsre-metrics-telegraf-queues-5c5647dfd5-hpwvp 8000
# then surf to http://localhost:8000/metrics

```

## notes

### chatgpt prompts used for rewriting oringal influx scripts

```
  rewrite this script to work with the prometheus telegraf plugin (vs influx). critical fields to keep are: BLAH. the script:
```

### analyzing our coverage on provisioners

```shell
rg queue2_prom.sh ./etc/telegraf_queues.conf | sed 's/^ *//' | sort
rg tc_web_prom.sh ./etc/telegraf_workers.conf | sed 's/^ *//' | sort
```
