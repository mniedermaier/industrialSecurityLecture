#!/usr/bin/env python3
"""Lab side-quest: anonymous publish to the lab MQTT broker."""
import time
import paho.mqtt.client as mqtt

BROKER = "172.28.0.12"

c = mqtt.Client()
c.connect(BROKER, 1883, 60)
for i in range(5):
    c.publish("sensors/vibration", f'{{"v": {i*0.5}, "ts": {int(time.time())}}}')
    time.sleep(0.2)
c.disconnect()
print("published 5 messages to topic sensors/vibration")
