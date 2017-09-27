"""XML SERVICE"""

import logging
import xml.etree.ElementTree as ET
from importer.errors import XMLParserError

class XMLService(object):
    """."""

    @staticmethod
    def get_coverages(xml):
        logging.info('[XMLService] Parsing XML fields')
        coverages = []
        try:
            root = ET.fromstring(xml)
            for cd in root.findall('{http://www.opengis.net/wcs/2.0}Capabilities'):
	    	logging.debug('cd')
	    	logging.debug(cd)
        except Exception as e:
            raise XMLParserError(message=str(e))
        return coverages

# /wcs:Capabilities[@xsi:schemaLocation="http://www.opengis.net/wcs/2.0 http://schemas.opengis.net/wcs/2.0/wcsAll.xsd"]/Contents[@xmlns="http://www.opengis.net/wcs/2.0"]/CoverageSummary[6]/CoverageId/text()
