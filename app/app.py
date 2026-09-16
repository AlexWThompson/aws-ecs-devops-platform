import os
from flask import Flask, render_template

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "dev")

@app.route("/")
def dashboard():
    return render_template("index.html")

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

    