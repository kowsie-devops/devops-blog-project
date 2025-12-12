from flask import Flask, request, render_template, redirect, url_for
import sqlite3
import os


DB_PATH = os.environ.get('DB_PATH', 'blog.db')


app = Flask(__name__)


def get_conn():
conn = sqlite3.connect(DB_PATH, check_same_thread=False)
conn.row_factory = sqlite3.Row
return conn


conn = get_conn()
conn.execute('''CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY, title TEXT, body TEXT)''')
conn.commit()


@app.route('/')
def index():
cur = conn.execute('SELECT * FROM posts ORDER BY id DESC')
posts = cur.fetchall()
return render_template('index.html', posts=posts)


@app.route('/post', methods=['POST'])
def post():
title = request.form.get('title')
body = request.form.get('body')
conn.execute('INSERT INTO posts (title, body) VALUES (?, ?)', (title, body))
conn.commit()
return redirect(url_for('index'))


if __name__ == '__main__':
app.run(host='0.0.0.0', port=5000)
