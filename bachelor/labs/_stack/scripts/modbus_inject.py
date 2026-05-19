#!/usr/bin/env python3
"""Lab 02 helper: unauthenticated write to coil 0 on the OpenPLC container.

This script exists ONLY to demonstrate the absence of authentication in
Modbus TCP, against a PLC you own (the lab container).
"""
from pymodbus.client import ModbusTcpClient

HOST = "172.28.0.10"
PORT = 502

c = ModbusTcpClient(HOST, port=PORT)
c.connect()
rr = c.write_coil(address=0, value=True, slave=1)
print("Write result:", rr)
c.close()
