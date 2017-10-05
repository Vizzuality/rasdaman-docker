"""Recipe helper"""

import json
import logging
import tempfile
from subprocess import call
from importer.services.download_service import DownloadService

class RecipeHelper(object):
    @staticmethod
    def generate_recipe(filelist, coverage_id, recipe=None):
        import_config = {
            "service_url": "http://54.146.170.2:8080/rasdaman/ows",
            "tmp_directory": "/tmp/",
            "crs_resolver": "http://54.146.170.2:8080/def/",
            "default_crs": "http://54.146.170.2:8080/def/crs/OGC/0/Index2D",
            "mock": False,
            "automated": True
        }

        if not recipe:
            recipe = {
                "name": "map_mosaic",
                "options": {
                    "wms_import": True
                }
            }

        final_recipe = {
            "config": import_config,
            "input": {
                "coverage_id": coverage_id,
                "paths": [ filelist ]
            },
            "recipe": recipe
        }
        return final_recipe

    @staticmethod
    def process_recipe(recipe):
        filepaths = recipe['input']['paths']
        # Only one file for now!
        import_url = filepaths[0]
        tiffile = DownloadService.get_tiff_file(import_url)
        logging.debug(tiffile)
        recipe['input']['paths'] = [ tiffile ]
        return recipe

    @staticmethod
    def ingest_recipe(recipe):
        with tempfile.NamedTemporaryFile(suffix='.json', mode='r', delete=False) as temp:
            #logging.debug(f"temp: {temp.name}")
            json.dump(recipe, temp)
            temp.flush()
            call(['ssh', 'ubuntu@54.146.170.2', 'sudo', 'chown', 'rasdaman:rasdaman', temp.name, '&&', 'sudo', 'chmod', '777', temp.name, '&&', 'bash', '/opt/rasdaman/bin/wcst_import.sh', temp.name])
            logging.debug("DONE")
