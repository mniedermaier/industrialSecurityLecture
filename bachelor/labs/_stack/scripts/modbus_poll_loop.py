#!/usr/bin/env python3
"""Lab 06 helper: generate a steady stream of legitimate Modbus reads
so that Zeek can build a baseline.
"""
import time
from pymodbus.client import ModbusTcpClient

HOST = "172.28.0.10"
PORT = 502

c = ModbusTcpClient(HOST, port=PORT)
c.connect()
try:
    while True:
        rr = c.read_holding_registers(address=0, count=10, slave=1)
        if rr.isError():
            print("err:", rr)
        time.sleep(2)
except KeyboardInterrupt:
    pass
finally:
    c.close()
