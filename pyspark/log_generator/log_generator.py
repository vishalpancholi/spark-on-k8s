import os
import random
import datetime

# Constants
START_DATE = datetime.date(2025, 5, 1)
END_DATE = datetime.date(2025, 5, 10)
TARGET_DIR_SIZE_MB = 1500  # Each directory ~1–1.5 GB
PART_FILE_SIZE_MB = 100
PART_FILE_SIZE_BYTES = PART_FILE_SIZE_MB * 1024 * 1024
USER_AGENT_FILE = "user_agents.txt"

METHODS = ["GET", "POST", "PUT", "DELETE"]
STATUS_CODES = [200, 201, 301, 302, 403, 404, 500]
URLS = [
    "/home", "/about", "/products", "/login", "/signup", "/dashboard",
    "/api/data", "/api/submit", "/images/logo.png", "/docs/index.html"
]

REPEATABLE_IPS = [
    ".".join(str(random.randint(1, 255)) for _ in range(4)) for _ in range(1000)
]

def load_user_agents(filepath):
    with open(filepath, "r") as f:
        return [line.strip() for line in f if line.strip()]

def random_ip():
    return random.choice(REPEATABLE_IPS) if random.random() < 0.4 else ".".join(str(random.randint(1, 255)) for _ in range(4))

def random_timestamp(date: datetime.date, skew_chance=0.15):
    # 10–20% chance to use previous day's date
    if random.random() < random.uniform(0.10, 0.20) and date > START_DATE:
        date = date - datetime.timedelta(days=1)

    start_datetime = datetime.datetime.combine(date, datetime.time.min)
    end_datetime = datetime.datetime.combine(date, datetime.time.max)
    random_seconds = random.randint(0, int((end_datetime - start_datetime).total_seconds()))
    dt = start_datetime + datetime.timedelta(seconds=random_seconds)
    return dt.strftime("[%d/%b/%Y:%H:%M:%S +0000]")

def random_log_entry(user_agents, date):
    ip = random_ip()
    timestamp = random_timestamp(date)
    method = random.choice(METHODS)
    url = random.choice(URLS)
    http_version = "HTTP/1.1"
    status = random.choice(STATUS_CODES)
    size = random.randint(200, 5000)
    user_agent = random.choice(user_agents)
    return f'{ip} - - {timestamp} "{method} {url} {http_version}" {status} {size} "-" "{user_agent}"\n'

def generate_logs_for_day(date: datetime.date, user_agents):
    dir_name = date.strftime("%Y-%m-%d")
    os.makedirs(dir_name, exist_ok=True)

    total_bytes = 0
    part_num = 1
    file_bytes = 0
    file = open(os.path.join(dir_name, f"part-{part_num:04}.txt"), "w")

    print(f"Generating logs for {dir_name}...")

    while total_bytes < random.randint(1024, TARGET_DIR_SIZE_MB) * 1024 * 1024:
        entry = random_log_entry(user_agents, date)
        encoded_entry = entry.encode("utf-8")
        file.write(entry)
        total_bytes += len(encoded_entry)
        file_bytes += len(encoded_entry)

        if file_bytes >= PART_FILE_SIZE_BYTES:
            file.close()
            part_num += 1
            file = open(os.path.join(dir_name, f"part-{part_num:04}.txt"), "w")
            file_bytes = 0

    file.close()
    print(f"Finished {dir_name}: {round(total_bytes / (1024 * 1024), 2)} MB, {part_num} parts\n")

def main():
    user_agents = load_user_agents(USER_AGENT_FILE)
    if not user_agents:
        raise ValueError("User agent list is empty or missing.")

    current_date = START_DATE
    while current_date <= END_DATE:
        generate_logs_for_day(current_date, user_agents)
        current_date += datetime.timedelta(days=1)

if __name__ == "__main__":
    main()
