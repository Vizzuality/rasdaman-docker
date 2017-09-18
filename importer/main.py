"""Main Script"""

import os
from ps import app


# This is only used when running locally. When running live, Gunicorn runs
# the application.
if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT')),
        debug=os.getenv('DEBUG') == 'True',
        threaded=True
    )
