import socket
import threading
import time

def handle_client(conn, addr):
    # print(f"Connected by {addr}")
    with conn:
        buffer = ""
        while True:
            data = conn.recv(1024)
            if not data:
                break
            buffer += data.decode()
            if "\n" in buffer:
                lines = buffer.split("\n")
                buffer = lines[-1]
                for line in lines[:-1]:
                    line = line.strip()
                    # print(f"Received: {line}")
                    if line.startswith("AUTHENTICATE"):
                        conn.sendall(b"250 OK\r\n")
                    elif line.startswith("SIGNAL NEWNYM"):
                        conn.sendall(b"250 OK\r\n")
                    elif line.startswith("QUIT"):
                        conn.sendall(b"250 closing connection\r\n")
                        return

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('127.0.0.1', 9052))
s.listen(1)
# print("Mock Tor Control Port listening on 9052")

while True:
    conn, addr = s.accept()
    threading.Thread(target=handle_client, args=(conn, addr)).start()
