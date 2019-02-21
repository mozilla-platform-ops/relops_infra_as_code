#!/usr/bin/env python

# https://github.com/influxdata/influxdb-python

import json
from influxdb import InfluxDBClient

try:
    # For Python 3.0 and later
    from urllib.request import urlopen
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen


def get_url(url):
    data = urlopen(url).read()
    output = json.loads(data)
    return output


def display_json_blob(blob):
    print("%s: %s" % (blob["workerType"], blob["pendingTasks"]))

def gen_influx_log_line(blob):
    wt = blob["workerType"]
    val = blob["pendingTasks"]
    cmd = "current,queue=%s value=%s" % (
        wt,
        val,
    )
    return cmd

# def log_json_blob(blob):
#     wt = blob["workerType"]
#     val = blob["pendingTasks"]
#     cmd = "influx -database bitbar -execute 'INSERT current,queue=%s value=%s' " % (
#         wt,
#         val,
#     )
#     subprocess.call(cmd, shell=True)


URLS = [
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-unit-p2",
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-perf-p2",
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-batt-p2",
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-unit-g5",
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-perf-g5",
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-batt-g5",
    "https://queue.taskcluster.net/v1/pending/proj-autophone/gecko-t-ap-test-g5",
]

if __name__ == "__main__":
  host = 'localhost'
  database = 'bitbar_test'
  # client = InfluxDBClient('localhost', 8086, 'root', 'root', 'example')
  client = InfluxDBClient(host=host, port=8086, username='root', password='root', database=database)
  # print(client.get_list_database())

  insert_commands = []
  for url in URLS:
    json_result = get_url(url)
    insert_commands.append(gen_influx_log_line(json_result))
    command = gen_influx_log_line(json_result)

  client.write(insert_commands, {'db':'bitbar_test'}, protocol='line')

  print("wrote %s data points to %s/%s" % (len(insert_commands), host, database))