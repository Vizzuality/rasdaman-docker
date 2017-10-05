"""API ROUTER"""

import logging

from flask import jsonify, Blueprint, request
from importer.routes.api import error
from importer.services.rasdaman_service import RasdamanService
from importer.services.xml_service import XMLService
from importer.helpers import RecipeHelper
from importer.errors import XMLParserError

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
            #logging.debug(f"recipe: {recipe}")
            processed_recipe = RecipeHelper.process_recipe(recipe)
            #logging.debug(f"processed_recipe: {processed_recipe}")
            RecipeHelper.ingest_recipe(recipe)
            
        else:
            None
            # coverage already existing - we should avoid overwriting for now
            
    except Exception as e:
        logging.debug(e)
    finally:
        # Remember to clean up any files
        None
    
    #
    #     if req_input['coverage_id'] not in coverages_list:
    #         recipe = RecipeHelper.generate_recipe(req_input['paths'], req_input['coverage_id'])
    #         logging.info('recipe:')
    #         logging.info(recipe)
    #
    # except XMLParserError:
    #     return "NOT OK", 500
    return jsonify(request.get_json()), 200


@import_endpoints.route('/import', strict_slashes=False, methods=['GET'])
def get():
    return "OK", 200
