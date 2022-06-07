#!/usr/bin/env python3
# example:
# ./pending.py gecko-3/b-linux

import sys

import taskcluster

root_url = taskcluster.optionsFromEnvironment()['rootUrl']
queue = taskcluster.Queue(taskcluster.optionsFromEnvironment())

source = sys.argv[1]
p=source.split('/')[0]
wt=source.split('/')[1]
source = queue.getWorkerType(p,wt)
print(queue.pendingTasks('{}/{}'.format(p,wt))['pendingTasks'])

