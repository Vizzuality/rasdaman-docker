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
import json
import CTRegisterMicroserviceFlask

import_endpoints = Blueprint('import_endpoints', __name__)

@import_endpoints.route('/import', strict_slashes=False, methods=['POST'])
def upload():
    """Uploads rasters to Rasdaman"""
    logging.info('[ROUTER] Importing rasters')
    logging.info("Request json data:")
    logging.info(request.json)
    try:
        coverages_xml = RasdamanService.get_rasdaman_coverages()
        coverages_dict = XMLService.get_coverages(coverages_xml)
        logging.info('coverages_dict:')
        logging.info(coverages_dict)
    except XMLParserError:
        return "NOT OK", 500
    except:
        return "Something weird", 500
    coverages = XMLService.get_coverages(coverages_xml)
    logging.debug(coverages)
    return "OK", 200
