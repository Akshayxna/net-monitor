import psutil
import time
from datetime import datetime

# 1. Open a file. 'a' means 'append' (add to the end, don't overwrite).
# The path is inside the container: /app/traffic_log.txt
log_file_path = "/app/traffic_log.txt"

print(f"Starting Network Monitor Agent...")
print(f"Logging data to {log_file_path}...")
print("-" * 50)

# We use 'with open' to ensure the file closes safely if the script crashes
with open(log_file_path, "a") as f:
    
    # Initialize variables
    stats = psutil.net_io_counters()
    last_sent = stats.bytes_sent
    last_recv = stats.bytes_recv

    while True:
        time.sleep(1)
        
        # Get current stats
        current_stats = psutil.net_io_counters()
        current_sent = current_stats.bytes_sent
        current_recv = current_stats.bytes_recv
        
        # Calculate speed
        upload_speed = current_sent - last_sent
        download_speed = current_recv - last_recv
        
        # Create a timestamp
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # 2. Create the log line
        log_line = f"{timestamp} | UP: {upload_speed:,} bytes | DOWN: {download_speed:,} bytes\n"
        
        # 3. Write to file
        f.write(log_line)
        f.flush() # Force the write to happen immediately (so you see it instantly on Windows)
        
        # Also print to screen so you know it's working
        print(log_line, end="")

        # Reset for next loop
        last_sent = current_sent
        last_recv = current_recv