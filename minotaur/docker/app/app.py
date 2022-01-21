#!/bin/env python3

import os
import json
import subprocess


def handler(event, context):
    try:
        cmd = '/var/task/moonshot.sh ' + event.get('cmd', '')
        #debug:
        print(json.dumps(event, indent=2))
        print(cmd)
        #cmd = event.get('cmd', 'set')
        result = subprocess.run(cmd, shell=True, check=True)
        print('subprocess returned ' + result.returncode)
        return [ result.returncode, result.stdout ]
    except Exception as e:
        return str(e)
