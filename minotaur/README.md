# Monitor linux nodes on the moonshot chassis

For each worker in workers.txt,
if no ping response,
    check last task activity and,
        if last task completed more than WORKER_IDLE_MAX minutes ago
        or if current task started more than WORKER_RUNNING_MAX minutes ago,
    then hardware power-cycle the cartridge.


# Environment configuration
```
## Optional (defaults listed):
WORKER_RUNNING_MAX: 120
WORKER_IDLE_MAX: 30
TASKCLUSTER_URL: https://firefox-ci-tc.services.mozilla.com}/api/queue
TASKCLUSTER_PROVISIONER: releng-hardware

## Required:
ILO_USER
INFLUXDB_URL
INFLUXDB_USER
INFLUXDB_PASSWORD
MOONSHOT_KEY
```

## Why hardcoded workers.txt?
  In the first version,
  this searched workerTypes for each worker based on the hostname pattern.
  Instead, now just a workers.txt hardcoded list (simple to add+remove).
  Add nodes to check like:
```
ip hostname short_hostname workerType workerGroup worker_status_url chassis node host_id
10.49.58.1 t-linux64-ms-001.test.releng.mdc1.mozilla.com t-linux64-ms-001 gecko-t-linux-talos-1804 mdc1 https://firefox-ci-tc.services.mozilla.com/api/queue/v1/provisioners/releng-hardware/worker-types/gecko-t-linux-talos-1804/workers/mdc1/t-linux64-ms-001 1 1 001
```
