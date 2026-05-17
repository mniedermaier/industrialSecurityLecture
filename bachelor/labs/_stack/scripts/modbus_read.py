#!/usr/bin/env python3
"""Lab 02 helper: honest Modbus read against the OpenPLC container."""
from pymodbus.client import ModbusTcpClient

HOST = "172.28.0.10"
PORT = 502

c = ModbusTcpClient(HOST, port=PORT)
c.connect()
rr = c.read_holding_registers(address=0, count=10, slave=1)
if rr.isError():
    print("Error:", rr)
else:
    print("Registers 0..9:", rr.registers)
c.close()
