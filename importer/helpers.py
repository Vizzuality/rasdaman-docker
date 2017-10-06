'''Recipe helper'''

import json
import logging
import tempfile
from subprocess import call
from importer.config import SETTINGS
from importer.services.download_service import DownloadService


class RecipeHelper(object):
    @staticmethod
    def generate_recipe(filelist, coverage_id, recipe=None):
        rasdaman_uri = SETTINGS.get('rasdaman').get('uri')
        import_config = {
            'service_url': rasdaman_uri+'/rasdaman/ows',
            'tmp_directory': '/tmp/',
            'crs_resolver': rasdaman_uri+'/def/',
            'default_crs': rasdaman_uri+'/def/crs/OGC/0/Index2D',
            'mock': False,
            'automated': True
        }

        if not recipe:
            recipe = {
                'name': 'map_mosaic',
                'options': {
                    'wms_import': True
                }
            }
        final_recipe = {
            'config': import_config,
            'input': {
                'coverage_id': coverage_id,
                'paths': [filelist]
            },
            'recipe': recipe
        }
        return final_recipe

    @staticmethod
    def process_recipe(recipe):
        rasdaman_ip = SETTINGS.get('rasdaman').get('ip')
        filepaths = recipe['input']['paths']
        # Only one file for now!
        import_url = filepaths[0]
        tiffile = DownloadService.get_tiff_file(import_url)
        with open(tiffile, 'a+') as f:
            call(['ssh', 'ubuntu@'+rasdaman_ip, 'sudo', 'chown', 'rasdaman:rasdaman', f.name, '&&', 'sudo', 'chmod', '777', f.name])
        recipe['input']['paths'] = [tiffile]
        return recipe

    @staticmethod
    def ingest_recipe(recipe):
        with tempfile.NamedTemporaryFile(suffix='.json', mode='w', delete=False) as temp:
            json.dump(recipe, temp)
            temp.flush()
            call(['ssh', 'ubuntu@54.146.170.2', 'sudo', 'chown', 'rasdaman:rasdaman', temp.name, '&&', 'sudo', 'chmod', '777', temp.name, '&&', 'bash', '/opt/rasdaman/bin/wcst_import.sh', temp.name])
            logging.debug('DONE')
