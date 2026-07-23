from flask import Flask
import mysql.connector
import os

app = Flask(__name__)

@app.route("/")
def home():
    return "Docker Compose Working!"

@app.route("/db")
def db():
    conn = mysql.connector.connect(
        host=os.getenv("MYSQL_HOST"),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE")
    )
    return "Database Connected"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)