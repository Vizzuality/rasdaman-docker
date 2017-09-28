"""API ROUTER"""

import logging

from flask import jsonify, Blueprint, request
from importer.routes.api import error
from importer.validators import validate_greeting
from importer.middleware import set_something
from importer.serializers import serialize_greeting
from importer.services.rasdaman_service import RasdamanService
from importer.services.xml_service import XMLService
from importer.helpers import RecipeHelper
from importer.errors import XMLParserError
import json
import CTRegisterMicroserviceFlask

import_endpoints = Blueprint('import_endpoints', __name__)

@import_endpoints.route('/import', strict_slashes=False, methods=['POST'])
def upload():
    """Uploads rasters to Rasdaman"""
    logging.info('[ROUTER] Importing rasters')
    logging.info("Request json data:")
    logging.info(request.json)
    input = request.json['input']
    try:
        coverages_xml = RasdamanService.get_rasdaman_coverages()
        coverages_list = XMLService.get_coverages(coverages_xml)
        logging.info('coverages_list:')
        logging.info(coverages_list)

        if input['coverage_id'] not in coverages_list:
            recipe = RecipeHelper.generate_recipe(input['paths'], input['coverage_id'])
            logging.info('recipe:')
            logging.info(recipe)
        
    except XMLParserError:
        return "NOT OK", 500
    return "OK", 200
