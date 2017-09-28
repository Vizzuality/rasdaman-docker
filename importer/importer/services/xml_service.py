"""XML SERVICE"""

import logging
import xml.etree.ElementTree as ET
from importer.errors import XMLParserError
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
        for k, v in capabilities_mtd.iteritems():
            if isinstance(v, OrderedDict):
                extract_coverages(v)
            else:
                coverages.append(v)
        return coverages
        
        

# /wcs:Capabilities[@xsi:schemaLocation="http://www.opengis.net/wcs/2.0 http://schemas.opengis.net/wcs/2.0/wcsAll.xsd"]/Contents[@xmlns="http://www.opengis.net/wcs/2.0"]/CoverageSummary[6]/CoverageId/text()
