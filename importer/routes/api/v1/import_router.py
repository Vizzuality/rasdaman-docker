"""API ROUTER"""

import logging

from flask import jsonify, Blueprint, request
from importer.services.rasdaman_service import RasdamanService
from importer.services.xml_service import XMLService
from importer.helpers import RecipeHelper
from importer.routes.api import error

import_endpoints = Blueprint('import_endpoints', __name__)


@import_endpoints.route('/import', strict_slashes=False, methods=['POST'])
def upload():
    """Uploads rasters to Rasdaman"""
    logging.info('[ROUTER] Importing rasters')
    logging.info(request.get_json())

    try:
        raster_url = request.get_json().get('connectorUrl', None)
        coverage_name = request.get_json().get('tableName', None)
        # logging.debug(f"raster_url: {raster_url}")
        coverages_xml = RasdamanService.get_rasdaman_coverages()
        coverages_list = XMLService.get_coverages(coverages_xml)
        # logging.debug(f"coverages_list: {coverages_list}")
        if coverage_name not in coverages_list:
            logging.debug("Generating recipe")
            recipe = RecipeHelper.generate_recipe(raster_url, coverage_name)
            # logging.debug(f"recipe: {recipe}")
            processed_recipe = RecipeHelper.process_recipe(recipe)
            # logging.debug(f"processed_recipe: {processed_recipe}")
            RecipeHelper.ingest_recipe(processed_recipe)
        else:
            return error(status=400, detail='coverage already exists')
    except Exception as e:
        logging.debug(e)
        return error(status=500, detail='error creating dataset')
    finally:
        # Remember to clean up any files
        pass

    return jsonify(request.get_json()), 200
