
from functools import wraps

def set_something(func):
    """Set something"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        kwargs["something"] = "something"
        return func(*args, **kwargs)
    return wrapper
