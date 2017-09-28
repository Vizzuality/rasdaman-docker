"""XML SERVICE"""

import logging
import xml.etree.ElementTree as ET
from importer.errors import XMLParserError
from collections import OrderedDict
import xmltodict

class XMLService(object):
    """Extracts values from xml responses in Rasdaman"""

    @staticmethod
    def get_coverages(xml):
        logging.info('[XMLService] Parsing XML capabilities')
        capabilities_dict = xmltodict.parse(xml)
        logging.info('capabilities_dict:')
        logging.info(capabilities_dict)
        coverages = XMLService.extract_coverages(capabilities_dict)
        return coverages

    @staticmethod
    def extract_coverages(capabilities_mtd):
        coverages = []
        try:
            for v in capabilities_mtd['wcs:Capabilities']['Contents']['CoverageSummary']:
                coverages.append(v['CoverageId'])
        except KeyError:
            return []
        return coverages
