"""DOWNLOAD SERVICE"""

import logging
import random
from urllib.request import urlretrieve
import tempfile

class DownloadService(object):

    @staticmethod
    def get_tiff_file(download_url):
        logging.info('[DownloadService] Downloading tiff from URL')
        f, _ = urlretrieve(download_url, '/tmp/' + str(random.randint(0, 10000)) + '.tiff')
        return f
