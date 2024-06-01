from flask import Flask, render_template, request, redirect, url_for
import psycopg2
import sys

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        database="dawid",
        user="dawid"
    )
    return conn


@app.route('/')
def index():
    return redirect(url_for('home'))

@app.route('/login')
def login():
    return render_template('html/login.html')

@app.route("/aboutus")
def aboutus():
    return render_template('html/aboutus.html')

@app.route("/home")
def home():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT nazwa from spolecznosci")
    spolecznosci = cur.fetchall()
    conn.commit()
    print("TEST", file=sys.stderr)
    print(spolecznosci, file=sys.stderr)
    return render_template('html/index.html', spolecznosci=spolecznosci)

if __name__ == '__main__':
    app.run(debug=True)
