# telegraf: docker_gcp_prom

## deployment

### build image and push to artifact registry

```shell
./docker_build

# works
docker tag 931f921e988c us-docker.pkg.dev/moz-fx-relsre-metrics-prod/relsre-metrics-prod/relsre-metrics:1.0.0
docker push us-docker.pkg.dev/moz-fx-relsre-metrics-prod/relsre-metrics-prod/relsre-metrics:1.0.0
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

# set the context
#   from ntade:
#     so webservices-high-nonprod would be for i.e. dev and stage, and webservices-high-prod would be for prod
kubectl config use-context gke_moz-fx-webservices-high-prod_us-west1_webservices-high-prod

# start the tunnel
gcp-bastion-tunnel

cd ~/git/webservices-infra/relsre-metrics/k8s/relsre-metrics

# helm diff upgrade --install -f <values-env>.yaml <chart name> .
helm diff upgrade --install -f values-prod.yaml relsre-metrics .

```
