"""XML SERVICE"""

import logging
import xmltodict


class XMLService(object):
    """Extracts values from xml responses in Rasdaman"""

    @staticmethod
    def get_coverages(xml):
        logging.info('[XMLService] Parsing XML capabilities')
        capabilities_dict = xmltodict.parse(xml)
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
