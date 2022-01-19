# Monitor linux nodes on the moonshot chassis

For each worker in workers.txt,
if no ping response,
    check last task activity and,
        if last task completed more than WORKER_IDLE_MAX minutes ago
        or if current task started more than WORKER_RUNNING_MAX minutes ago,
    then hardware power-cycle the cartridge.


# Environment configuration

## Optional (defaults listed):
WORKER_RUNNING_MAX: 120
WORKER_IDLE_MAX: 30
TASKCLUSTER_URL: https://firefox-ci-tc.services.mozilla.com}/api/queue
TASKCLUSTER_PROVISIONER: releng-hardware

## Required:
ILO_USER
ILO_PASSWORD
INFLUXDB_URL
INFLUXDB_USER
INFLUXDB_PASSWORD
MOONSHOT_KEY

