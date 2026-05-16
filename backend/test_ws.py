import asyncio
import websockets
import json

async def test():
    async with websockets.connect("ws://127.0.0.1:8000/ws/mobile") as ws:
        print("Mobile bağlandı")
        async for message in ws:
            print("Gelen:", json.loads(message))

asyncio.run(test())