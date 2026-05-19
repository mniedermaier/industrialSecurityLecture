#!/usr/bin/env python3
"""Lab 04 helper: browse the OPC UA example server (anonymous, no encryption)."""
import asyncio
from asyncua import Client

URL = "opc.tcp://172.28.0.11:4840"

async def main():
    async with Client(url=URL) as c:
        print("Connected to:", URL)
        objects = c.nodes.objects
        children = await objects.get_children()
        for n in children:
            name = await n.read_browse_name()
            print(" -", name)

asyncio.run(main())
