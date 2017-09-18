"""."""

import os
import json


PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE_DIR = os.path.dirname(PROJECT_DIR)


def load_config_json(name):
    json_path = os.path.abspath(os.path.join(BASE_DIR, 'microservice'))+'/'+name+'.json'
    with open(json_path) as data_file:
        info = json.load(data_file)
    return info
