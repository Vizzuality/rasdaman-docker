#!/bin/bash
set -e

case "$1" in
    develop)
        echo "Running Development Server"
        exec python main.py
        ;;
    test)
        echo "Test"
        exec python test.py
        ;;
    start)
        echo "Running Start"
        exec gunicorn -c gunicorn.py ps:app
        ;;
    *)
        exec "$@"
esac
