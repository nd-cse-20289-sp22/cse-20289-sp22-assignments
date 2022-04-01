#!/usr/bin/env python3

import asyncio
import os
import sys

# Constants

HOST = 'chat.ndlug.org'
PORT = 6697
NICK = f'ircle-{os.environ["USER"]}'

# Functions

async def ircle():
    # Connect to IRC server
    reader, writer = await asyncio.open_connection(HOST, PORT, ssl=True)

    # Identify ourselves
    writer.write(f'USER {NICK} 0 * :{NICK}\r\n'.encode())
    writer.write(f'NICK {NICK}\r\n'.encode())
    await writer.drain()

    # Join #bots channel
    writer.write(f'JOIN #bots\r\n'.encode())
    await writer.drain()
    
    # Write message to channel
    writer.write(f"PRIVMSG #bots :I've fallen and I can't get up!\r\n".encode())
    await writer.drain()

    # Read and display
    while True:
        message = (await reader.readline()).decode().strip()
        print(message)

# Main execution

def main():
    asyncio.run(ircle())

if __name__ == '__main__':
    main()
