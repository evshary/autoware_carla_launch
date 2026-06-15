#!/usr/bin/env python3
"""Load Town01 once, up front. load_world blocks until the map is fully loaded."""
import sys
import time

import carla

ip = sys.argv[1] if len(sys.argv) > 1 else '172.17.0.1'

print('[load_town01] loading Town01...', flush=True)
# Give CARLA a moment to finish starting up before connecting.
time.sleep(5)

client = carla.Client(ip, 2000)
client.set_timeout(60.0)
client.load_world('Town01')
print('[load_town01] Town01 loaded', flush=True)
