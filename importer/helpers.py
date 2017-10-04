"""Recipe helper"""

import json
import logging


class RecipeHelper(object):

    @staticmethod
    def generate_recipe(filelist, coverage_id, recipe=None):
        import_config = {
            "service_url": "http://localhost:8080/rasdaman/ows",
            "tmp_directory": "/tmp/",
            "crs_resolver": "http://localhost:8080/def/",
            "default_crs": "http://localhost:8080/def/crs/OGC/0/Index2D",
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
                "paths": filelist
            },
            "recipe": recipe
        }
        logging.info('recipe: ')
        logging.info(json.dumps(final_recipe))
        return final_recipe

    @staticmethod
    def process_recipe(recipe):
        filepaths = []
        recipe['input']['paths'] = filepaths
        return recipe

    @staticmethod
    def ingest_recipe():
        pass
