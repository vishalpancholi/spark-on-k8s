import random
import datetime
import os

# Constants
NUM_FILES = 100
FILE_PREFIX = "access_log"
TARGET_SIZE_MB = 10
TARGET_SIZE_BYTES = TARGET_SIZE_MB * 1024 * 1024

METHODS = ["GET", "POST", "PUT", "DELETE"]
STATUS_CODES = [200, 201, 301, 302, 403, 404, 500]
URLS = [
    "/home", "/about", "/products", "/login", "/signup", "/dashboard",
    "/api/data", "/api/submit", "/images/logo.png", "/docs/index.html"
]

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_5_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:117.0) Gecko/20100101 Firefox/117.0",
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Linux; Android 9; SM-G960F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Mobile Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
    "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)",
    "Googlebot/2.1 (+http://www.google.com/bot.html)",
    "Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)"
]

# Generate 1000 repeatable IPs
REPEATABLE_IPS = [
    ".".join(str(random.randint(1, 255)) for _ in range(4)) for _ in range(1000)
]

# 40% chance to pick from repeatable IP pool
def random_ip():
    return random.choice(REPEATABLE_IPS) if random.random() < 0.4 else ".".join(str(random.randint(1, 255)) for _ in range(4))

def random_april_timestamp():
    start_date = datetime.datetime(2025, 4, 1)
    end_date = datetime.datetime(2025, 4, 30, 23, 59, 59)
    random_seconds = random.randint(0, int((end_date - start_date).total_seconds()))
    dt = start_date + datetime.timedelta(seconds=random_seconds)
    return dt.strftime("[%d/%b/%Y:%H:%M:%S +0000]")

def random_log_entry():
    ip = random_ip()
    timestamp = random_april_timestamp()
    method = random.choice(METHODS)
    url = random.choice(URLS)
    http_version = "HTTP/1.1"
    status = random.choice(STATUS_CODES)
    size = random.randint(200, 5000)
    user_agent = random.choice(USER_AGENTS)
    return f'{ip} - - {timestamp} "{method} {url} {http_version}" {status} {size} "-" "{user_agent}"\n'

def generate_log_file(file_index):
    filename = f"{FILE_PREFIX}{file_index}.txt"
    with open(filename, "w") as f:
        total_size = 0
        while total_size < TARGET_SIZE_BYTES:
            entry = random_log_entry()
            f.write(entry)
            total_size += len(entry)
    print(f"{filename} created (~{round(total_size / (1024 * 1024), 2)} MB)")

def main():
    for i in range(1, NUM_FILES + 1):
        generate_log_file(i)

if __name__ == "__main__":
    main()