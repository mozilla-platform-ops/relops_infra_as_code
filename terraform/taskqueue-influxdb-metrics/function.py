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


URLS = [
    # tc-w queues
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-ap-unit-p2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-ap-perf-p2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-ap-batt-p2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-ap-unit-g5",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-ap-perf-g5",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-ap-batt-g5",
    # g-w queues
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-batt-p2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-perf-p2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-unit-p2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-batt-g5",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-perf-g5",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-unit-g5",
    # g-w test queues
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-test-g5",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-test-1",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-test-2",
    "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/pending/proj-autophone/gecko-t-bitbar-gw-test-3",
]


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


def main():
    TESTING = False
    if TESTING:
        host = "localhost"
        database = "bitbar_test"
        username = "root"
        password = "root"
        port = 8086
        ssl = False
        ssl_verify = False
    else:
        # load user and password from AWS Secrets Manager
        secrets = boto3.client("secretsmanager")
        key_name = "relops_wo"
        secrets_str = secrets.get_secret_value(SecretId="influxdb_credentials")[
            "SecretString"
        ]
        secret_dict = json.loads(secrets_str)

        username = key_name
        host = secret_dict["host"]
        password = secret_dict[key_name]
        database = "relops"
        port = 8086
        ssl = True
        ssl_verify = True

    insert_commands = []
    for url in URLS:
        if TESTING:
            print("fetching url '%s'..." % url)
        json_result = get_url(url)
        insert_commands.append(gen_influx_log_line(json_result))
    if TESTING:
        print(insert_commands)

    client = InfluxDBClient(
        host=host,
        port=port,
        username=username,
        password=password,
        database=database,
        ssl=ssl,
        verify_ssl=ssl_verify,
    )

    client.write(insert_commands, {"db": database}, protocol="line")

    print("wrote %s data points to %s/%s" % (len(insert_commands), host, database))


def lambda_handler(_event, _context):
    main()


if __name__ == "__main__":
    main()
