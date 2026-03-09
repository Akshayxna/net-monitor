from flask import Flask, render_template
import psutil
import time

app = Flask(__name__)

# Initialize stats outside the route so they persist
last_stats = psutil.net_io_counters()
last_time = time.time()

def get_speed():
    global last_stats, last_time
    
    current_stats = psutil.net_io_counters()
    current_time = time.time()
    
    # Calculate time difference to get speed per second
    time_diff = current_time - last_time
    
    sent_speed = (current_stats.bytes_sent - last_stats.bytes_sent) / time_diff
    recv_speed = (current_stats.bytes_recv - last_stats.bytes_recv) / time_diff
    
    # Update for next loop
    last_stats = current_stats
    last_time = current_time
    
    return sent_speed, recv_speed

@app.route('/')
def home():
    # Get the speed
    up, down = get_speed()
    
    # Render the HTML file and pass the data to it
    return render_template('index.html', upload=up, download=down)

if __name__ == '__main__':
    # Run the web server on port 5000
    app.run(host='0.0.0.0', port=5000)