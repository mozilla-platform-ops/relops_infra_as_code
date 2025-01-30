# telegraf: docker_gcp_prom

## deployment

### build image and push to artifact registry

```shell
# ./docker_build
docker buildx build --no-cache --platform linux/amd64 -t relsre-metrics .
# not the resulting image sha1, use it below in the `docker tag` command

# works
docker tag SHA1 us-docker.pkg.dev/moz-fx-relsre-metrics-prod/relsre-metrics-prod/relsre-metrics:1.0.0
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

# set the context (can use kubectx also)
#   from ntade:
#     so webservices-high-nonprod would be for i.e. dev and stage, and webservices-high-prod would be for prod
kubectl config use-context webservices-low-prod_us-west1

# set the namespace (can use kubens also)
# kubectl config set-context --namespace=relsre-metrics????
#
# https://stackoverflow.com/questions/61171487/what-is-the-difference-between-namespaces-and-contexts-in-kubernetes
kubens relsre-metrics-prod

# start the tunnel (will use current context to infer details)
gcp-bastion-tunnel

cd ~/git/webservices-infra/relsre-metrics/k8s/relsre-metrics

# view diff between running and local
helm diff upgrade --install relsre-metrics . -f values-prod.yaml --namespace=relsre-metrics-prod
# TODO: why isn't this applying when run?

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
