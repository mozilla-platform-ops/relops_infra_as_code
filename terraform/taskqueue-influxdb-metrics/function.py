#!/usr/bin/env python

import json
from influxdb import InfluxDBClient
import boto3


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
    cmd = "bitbar_queue_size,queue=%s value=%s" % (wt, val)
    return cmd


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
    TESTING = False
    if TESTING:
        host = "localhost"
        database = "bitbar_test"
        username = "root"
        password = "root"
        port = 8086
    else:
        # load user and password from AWS Secrets Manager
        secrets = boto3.client("secretsmanager")
        key_name = "relops_wo"

        username = key_name
        host = json.dumps(secrets.get_secret_value(SecretId="influxdb_credentials")["host"])
        password = json.dumps(secrets.get_secret_value(SecretId="influxdb_credentials")[key_name])
        database = "relops.autogen"
        port = 8086



    client = InfluxDBClient(
        host=host, port=port, username=username, password=password, database=database
    )

    insert_commands = []
    for url in URLS:
        json_result = get_url(url)
        insert_commands.append(gen_influx_log_line(json_result))
        command = gen_influx_log_line(json_result)

    client.write(insert_commands, {"db": database}, protocol="line")

    print("wrote %s data points to %s/%s" % (len(insert_commands), host, database))
