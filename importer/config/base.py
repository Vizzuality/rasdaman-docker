"""-"""

import os


SETTINGS = {
    'logging': {
        'level': 'DEBUG'
    },
    'service': {
        'port': os.getenv('PORT')
    },
    'rasdaman': {
        'ip': '54.146.170.2',
        'uri': 'http://54.146.170.2:8080'
    }
}
