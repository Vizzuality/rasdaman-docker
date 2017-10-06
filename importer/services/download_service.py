"""DOWNLOAD SERVICE"""

import logging
import random
import urllib.request as req


class DownloadService(object):

    @staticmethod
    def get_tiff_file(download_url):
        logging.info('[DownloadService] Downloading tiff from URL')
        with req.urlopen(download_url) as d, open('/tmp/' + str(random.randint(0, 10000)) + '.tiff', 'wb') as opfile:
            data = d.read()
            opfile.write(data)
        return opfile.name
