#!/bin/bash

cat > app.py << 'EOF'
from flask import Flask, render_template_string, request, redirect
import redis
import json

app = Flask(__name__)
# Connect to Redis container
r = redis.Redis(host='redis-db', port=6379, decode_responses=True)
GUESTBOOK_KEY = 'guestbook:guests'

def load_guests():
    guests_json = r.get(GUESTBOOK_KEY)
    if guests_json:
        return json.loads(guests_json)
    return []

def save_guests(guests):
    r.set(GUESTBOOK_KEY, json.dumps(guests))

HTML = '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Guestbook</title>
  <style>
    body{font-family:Arial;margin:40px auto;max-width:520px;padding:16px}
    h1{margin:0 0 12px}
    form{display:flex;gap:8px;margin:12px 0}
    input,button{padding:10px;font-size:16px}
    input{flex:1}
    button{cursor:pointer}
    ul{margin:12px 0 0;padding-left:18px}
    small{display:block;margin-top:18px;color:#666}
  </style>
</head>
<body>
  <h1>Guestbook</h1>

  <form method="POST" action="/add">
    <input name="name" placeholder="Your name" required>
    <button>Add</button>
  </form>

  <ul>
    {% for guest in guests %}<li>{{ guest }}</li>{% endfor %}
  </ul>
</body>
</html>
'''

@app.route('/')
def index():
    guests = load_guests()
    return render_template_string(HTML, guests=guests)

@app.route('/add', methods=['POST'])
def add_guest():
    name = request.form.get('name')
    if name:
        guests = load_guests()
        guests.append(name)
        save_guests(guests)
    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2000)
EOF

cat > requirements.txt << 'EOF'
Flask
Werkzeug
redis
EOF

cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 2000

CMD ["python", "-u", "app.py"]
EOF

mkdir -p redis-data

docker network create guestbook-network 2>/dev/null

docker stop redis-db 2>/dev/null
docker rm redis-db 2>/dev/null
docker stop guestbook-app 2>/dev/null
docker rm guestbook-app 2>/dev/null

docker container run -d \
  --name redis-db \
  --network guestbook-network \
  -v "$(pwd)/redis-data:/data" \
  --restart unless-stopped \
  redis:7-alpine redis-server --appendonly yes

docker build -t guestbook-app:latest .

docker container run -d \
  --name guestbook-app \
  --network guestbook-network \
  -p 2000:2000 \
  --restart unless-stopped \
  guestbook-app:latest
