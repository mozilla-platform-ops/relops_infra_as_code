#!/usr/bin/env python3
# example:
# ./stage.py gecko-3/b-linux gecko-3/b-linux-gcp 1

# stager
#
# duplicate production tasks onto a staging workertype
#
# 1. get source and target types
# 2. get parameters for tasks to copy. how many, and filters on what metadata?
# 3. find tasks
# 4. copy tasks with altered workertype and email addresses (anything else needed to change? some tagging? or a way to track results or drop results?)
#
debug=False

import os
import sys
import time
import datetime
import json

import taskcluster

# expects env vars:
# TASKCLUSTER_ROOT_URL
# TASKCLUSTER_CLIENT_ID
# TASKCLUSTER_ACCESS_TOKEN
#auth = taskcluster.Auth(taskcluster.optionsFromEnvironment())
root_url = taskcluster.optionsFromEnvironment()['rootUrl']

queue = taskcluster.Queue(taskcluster.optionsFromEnvironment())

if '@' in sys.argv[1]:
    email = sys.argv[1]
    sys.argv.pop(0)
else:
    email = '{}@mozilla.com'.format(os.environ.get('USER'))
print('email: {}'.format(email))

source = sys.argv[1]
target = sys.argv[2]

if len(sys.argv) > 3:
    batch = int(sys.argv[3])
else:
    batch = 1

if len(sys.argv) > 4:
    recent_time_hours = int(sys.argv[4])
else:
    recent_time_hours = 48

print('source: {}'.format(source))
print('target: {}'.format(target))
print('batch: {}'.format(batch))

if (batch < 1 or batch > 500):
    print('batch < 1 or batch > 500. batch:{}'.format(batch))
    exit()

# look up worker type to copy from
print('provisioners:', [c['provisionerId'] for c in queue.listProvisioners()['provisioners']])

source_p = source.split('/')[0]
print(source_p + ':', [c['workerType'] for c in queue.listWorkerTypes(source_p)['workerTypes']])
source_wt = source.split('/')[1]
source = queue.getWorkerType(source_p, source_wt)
print(source)

target_p = target.split('/')[0]
if target_p != source_p:
    print(target_p + ':', [c['workerType'] for c in queue.listWorkerTypes(target_p)['workerTypes']])
target_wt = target.split('/')[1]
target = queue.getWorkerType(target_p, target_wt)
print(target)

print('')
# created deadline expires
# REMOVE: routes
# dependencies extra metadata payload priority provisionerId requires retries schedulerId scopes tags taskGroupId workerType
# CHANGE: tags['createdForUser']
now = taskcluster.fromNowJSON('')
deadline = taskcluster.fromNowJSON('1 days')
expires = taskcluster.fromNowJSON('1 months')
tags = {'createdForUser': email}
routes = [
]

def copy_task(task_id):
    new_task = queue.task(task_id)
    new_task = { k: new_task[k] for k in ['dependencies', 'extra', 'metadata', 'payload', 'priority', 'requires', 'schedulerId', 'scopes'] }
    try:
        del new_task['payload']['artifacts']
    except:
        pass
    new_task['metadata']['owner'] = email
    now = taskcluster.fromNowJSON('')
    new_task['created'] = now
    new_task['deadline'] = deadline
    new_task['expires'] = expires
    new_task['tags'] = tags
    new_task['routes'] = routes
    new_task['provisionerId'] = target_p
    new_task['workerType'] = target_wt
    new_task_id = taskcluster.slugId()
    queue.createTask(new_task_id, new_task)
    return new_task_id

"""
task_id = 'UkPeJ8iDTRWzT3clqWUpSg'
new_task = copy_task(task_id)
print(json.dumps(new_task, sort_keys=True, indent=2))
new_task_id = taskcluster.slugId()
print(new_task_id)
result = queue.createTask(new_task_id, new_task)
print(result)
exit()
"""

# get tasks

# collect recently executed tasks
def task_is_running(worker):
    # {'status': {'taskId': 'EpnwMllwScaRkgX6-ZM5BA', 'provisionerId': 'gecko-3', 'workerType': 'b-linux', 'schedulerId': 'gecko-level-3', 'taskGroupId': 'FlFx5eOvQIO5aR2SlmLsEw', 'deadline': '2020-04-23T14:12:46.655Z', 'expires': '2021-04-22T14:12:46.655Z', 'retriesLeft': 4, 'state': 'completed', 'runs': [{'runId': 0, 'state': 'exception', 'reasonCreated': 'scheduled', 'reasonResolved': 'worker-shutdown', 'workerGroup': 'aws', 'workerId': 'i-031777e24c3a85075', 'takenUntil': '2020-04-22T16:21:50.488Z', 'scheduled': '2020-04-22T15:41:50.087Z', 'started': '2020-04-22T15:41:50.170Z', 'resolved': '2020-04-22T16:02:54.868Z'}, {'runId': 1, 'state': 'completed', 'reasonCreated': 'retry', 'reasonResolved': 'completed', 'workerGroup': 'aws', 'workerId': 'i-0ed5cd55fd114c2cf', 'takenUntil': '2020-04-22T17:02:56.274Z', 'scheduled': '2020-04-22T16:02:54.868Z', 'started': '2020-04-22T16:02:55.599Z', 'resolved': '2020-04-22T16:43:37.590Z'}]}}
    try:
        task_id = worker.get('latestTask',{}).get('taskId','')
        run_id = worker.get('latestTask',{}).get('runId','')
        state = queue.status(task_id).get('status', {})
        if state['runs'][run_id].get('resolved'):
            return False
        else:
            if state['runs'][run_id].get('started'):
                return True
            else:
                return False
    except:
        return False


def count_active_workers(provisionerId, workerType):
    workers = 0
    result = queue.listWorkers(provisionerId, workerType, quarantined=False)
    while result.get('continuationToken'):
        continuationToken = result.get('continuationToken')
        if continuationToken:
            result = queue.listWorkers(provisionerId, workerType, quarantined=False, query={'continuationToken': continuationToken})
        for worker in filter(task_is_running, result.get('workers', [])):
            workers += 1
    if debug: print('%s / %s has %d active workers' % (provisionerId, workerType, workers))
    return workers


def get_workers(source_p, source_wt):
    workers = []
    result = queue.listWorkers(source_p, source_wt, quarantined=False)
    workers.extend(result.get('workers', []))
    while result.get('continuationToken'):
        continuationToken = result.get('continuationToken')
        result = queue.listWorkers(source_p, source_wt, quarantined=False, query={'continuationToken': continuationToken})
        workers.extend(result.get('workers', []))
        if debug:
            break
    print('workerType %s has %d workers' % (source_wt, len(workers)))

    # {'workerGroup': 'aws', 'workerId': 'i-031777e24c3a85075', 'firstClaim': '2020-04-22T14:40:25.211Z', 'latestTask': {'taskId': 'EpnwMllwScaRkgX6-ZM5BA', 'runId': 0}}
    if debug: print(workers[0])
    return workers

workers = get_workers(source_p, source_wt)
if len(workers) <= 0:
    print('No workers found in {}'.format(source))
    exit(1)

tasks = []

after = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours = recent_time_hours)
def task_is_recent(worker):
    # {'status': {'taskId': 'EpnwMllwScaRkgX6-ZM5BA', 'provisionerId': 'gecko-3', 'workerType': 'b-linux', 'schedulerId': 'gecko-level-3', 'taskGroupId': 'FlFx5eOvQIO5aR2SlmLsEw', 'deadline': '2020-04-23T14:12:46.655Z', 'expires': '2021-04-22T14:12:46.655Z', 'retriesLeft': 4, 'state': 'completed', 'runs': [{'runId': 0, 'state': 'exception', 'reasonCreated': 'scheduled', 'reasonResolved': 'worker-shutdown', 'workerGroup': 'aws', 'workerId': 'i-031777e24c3a85075', 'takenUntil': '2020-04-22T16:21:50.488Z', 'scheduled': '2020-04-22T15:41:50.087Z', 'started': '2020-04-22T15:41:50.170Z', 'resolved': '2020-04-22T16:02:54.868Z'}, {'runId': 1, 'state': 'completed', 'reasonCreated': 'retry', 'reasonResolved': 'completed', 'workerGroup': 'aws', 'workerId': 'i-0ed5cd55fd114c2cf', 'takenUntil': '2020-04-22T17:02:56.274Z', 'scheduled': '2020-04-22T16:02:54.868Z', 'started': '2020-04-22T16:02:55.599Z', 'resolved': '2020-04-22T16:43:37.590Z'}]}}
    try:
        task_id = worker.get('latestTask',{}).get('taskId','')
        run_id = worker.get('latestTask',{}).get('runId','')
        state = queue.status(task_id).get('status', {})
        task_time = state['runs'][run_id].get('resolved')
        if task_time and after < datetime.datetime.fromisoformat(task_time.replace('Z', '+00:00')):
            tasks.append(task_id)
            return True
        else:
            return False
    except:
        return False

if debug: print('check task from first worker {} is recent: {}'.format(workers[0], task_is_recent(workers[0])))

i=0
for worker in filter(task_is_recent, workers):
    i+=1
    if i >= batch or (debug and i >= 10):
        break

print(tasks)
print(len(tasks))
# alter tasks
if len(tasks) <= 0:
    print("No tasks found in {} hours".format(recent_time_hours))
    exit(1)


# pattern: ^[a-zA-Z0-9-_]{1,38}/[a-z]([-a-z0-9]{0,36}[a-z0-9])?$

print(target_p + '/' + target_wt)
try:
    print(target_wt, queue.pendingTasks(target_p, target_wt))
except Exception as e:
    print(e)
# create/apply new load

new_tasks = { task_id:copy_task(task_id) for task_id in tasks }
# for task_id in tasks:
#     new_task = copy_task(task_id)
#     new_task_id = taskcluster.slugId()
#     result = queue.createTask(new_task_id, new_task)
#     print('{}/tasks/{}'.format(root_url, new_task_id))
#     if debug:
#         print('created a single task copy')
#         break
if debug: print(json.dumps(new_tasks, indent=2))
print(new_tasks.values())


json.dump(new_tasks, open('staged.json', 'w'))

def get_task_log(task_id):
    log = queue.getLatestArtifact(task_id, 'public/logs/live_backing.log')
    print(log)

# get result or method to verify result
for i in range(90):
    print(datetime.datetime.now())
    states = {}
    def task_result(task_id):
        state = queue.status(task_id).get('status', {})['state']
        states[state] = states.get(state, 0) + 1
    [ task_result(new_tasks[task]) for task in new_tasks ]
    print(states)
    
    print(target_p, target_wt, 'pending:{}'.format(queue.pendingTasks(target_p, target_wt)['pendingTasks']), 'active:{}'.format(count_active_workers(target_p, target_wt)))
    time.sleep(60)
