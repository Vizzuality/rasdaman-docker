"""DOWNLOAD SERVICE"""

import logging
from requests import Request, Session
import tempfile

class DownloadService(object):

    @staticmethod
    def get_tiff_file(download_url):
        logging.info('[DownloadService] Downloading tiff from URL')
        request = Request(
            method='GET',
            url= download_url
        )
        session = Session()
        prepped = session.prepare_request(request)
        response = session.send(prepped)
        with tempfile.NamedTemporaryFile(suffix='.tiff', delete=False) as f:
            for chunk in response.iter_content(chunk_size=1024):
                f.write(chunk)
            raster_filename = f.name
            #logging.debug(f"[QueryService] Temporary raster filename: {raster_filename}")
            f.close()
            return raster_filename
