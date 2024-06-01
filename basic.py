from flask import Flask, render_template, request, redirect, url_for
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        database="dawid",
        user="dawid"
    )
    return conn


@app.route('/')
def index():
    return render_template('html/index.html')

@app.route('/login')
def login():
    return render_template('html/login.html')

@app.route("/aboutus")
def aboutus():
    return render_template('html/aboutus.html')

@app.route("/home")
def home():
    return render_template('html/index.html')

if __name__ == '__main__':
    app.run(debug=True)
