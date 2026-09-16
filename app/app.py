import os
from flask import Flask, render_template

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "dev")

@app.route("/")
def dashboard():
    return render_template("index.html", version=VERSION)

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

@app.route("/cpu-test")
def cpu_test():
    import time
    from flask import request

    seconds = int(request.args.get("seconds", 30))
    end = time.time() + seconds

    while time.time() < end:
        pass

    return {"status": "completed", "seconds": seconds}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

    