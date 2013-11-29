from flask import Flask, render_template
from os import environ
from urlparse import urlparse

app = Flask(__name__)
app.config['DEBUG'] = False if environ.get('HEROKU') else True
REDIS_URL = urlparse(environ.get('REDIS_URL', 'redis://:@localhost:6379/'))

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    port = int(environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=app.config['DEBUG'])
