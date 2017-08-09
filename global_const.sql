-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
-- This file is part of rasdaman community.
--
-- Rasdaman community is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Rasdaman community is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with rasdaman community.  If not, see <http://www.gnu.org/licenses/>.
--
-- Copyright 2003, 2004, 2005, 2006, 2007, 2008, 2009 Peter Baumann /
-- rasdaman GmbH.
--
-- For more information please see <http://www.rasdaman.org>
-- or contact Peter Baumann via <baumann@rasdaman.com>.
-- ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=

-- ####################################################################
-- |                 constants for database scripting                 |
-- ####################################################################
--
-- PURPOSE
-- Sets constant variables for database SQL scripts which
--
-- PREREQUISITES:
--   - `utilities.sql' has been imported for `cset()'
-----------------------------------------------------------------------

-- set constants, parametrizing the prefix of the _new_ tables (see further comments below)
CREATE OR REPLACE FUNCTION set_constants(new_tables_prefix text) RETURNS void AS
$$
    -- General
    SELECT cset('GMLCOV_METADATA_TYPE', 'gmlcov');
    SELECT cset('ID_FIELD',             'id');
    SELECT cset('OCTET_STREAM_MIME',    'application/x-octet-stream');
    SELECT cset('SWE_QUANTITY_FIELD',   'Quantity');
    SELECT cset('UOM_PURE_NUM',         '10^0');
    -- Regex patterns
    SELECT cset('NAME_PATTERN',            E'^[_A-Za-z][-._A-Za-z0-9]*$');
    SELECT cset('SERVICE_VERSION_PATTERN', E'^\\d+\\.\\d?\\d\\.\\d?\\d$');
    SELECT cset('UOM_PATTERN',             E'^[^: \\n\\r\\t]+$');
    SELECT cset('INDEX_ND_PATTERN',        E'Index\\dD'); -- Used when converting CRS:1 to Index CRSs during migration.
    SELECT cset('CRS_CODE_PATTERN',         '([^/:]*)$');
    SELECT cset('EPSG_PATTERN',             'EPSG|epsg');
    -- Service and service provider metadata
    SELECT cset('WCS_SERVICE_TYPE',             'OGC WCS');
    SELECT cset('WCS_SERVICE_TYPE_VERSIONS',    '2.0.1'); -- use commas for different supported versions
    SELECT cset('WCS_SERVICE_TITLE',            'rasdaman');
    SELECT cset('WCS_SERVICE_ABSTRACT',         'rasdaman server - free download from www.rasdaman.org');
    SELECT cset('WCS_PROVIDER_NAME',            'Vizzuality');
    SELECT cset('WCS_PROVIDER_SITE',            'http://vizzuality.org/');
    SELECT cset('WCS_PROVIDER_CONTACT_NAME',    'Enrique Cornejo');
    SELECT cset('WCS_PROVIDER_CONTACT_CITY',    'Madrid');
    SELECT cset('WCS_PROVIDER_CONTACT_PCODE',   '28010');
    SELECT cset('WCS_PROVIDER_CONTACT_COUNTRY', 'Spain');
    SELECT cset('WCS_PROVIDER_CONTACT_EMAIL',   'enrique.cornejo@vizzuality.com');
    SELECT cset('WCS_PROVIDER_CONTACT_ROLE',    'Data Scientist');
    -- CRSs
    SELECT cset('CRS_1',                'CRS:1'); -- resolution formula is different on CRS:1 grids (-1 term is dropped).
    SELECT cset('CRS_4326',             '4326'); -- resolution formula is different on CRS:1 grids (-1 term is dropped).
    SELECT cset('SECORE_ENTRY',         '%SECORE_URL%'); -- [!] This shall match with Petascope constant to replace it with the configured resolver.
    SELECT cset('TIME_AXIS_TYPE',       't'); -- CRS becomes CRS_ANSI for temporal axis on pre-upgrade 8.X coverages.
    SELECT cset('Y_AXIS_TYPE',          'y'); -- Origin is Upper-Left corner
    SELECT cset('CRS_ANSI',         cget('SECORE_ENTRY') || '/crs/OGC/0/AnsiDate');
    SELECT cset('CRS_INDEX_1D',     cget('SECORE_ENTRY') || '/crs/OGC/0/Index1D');
    SELECT cset('CRS_INDEX_2D',     cget('SECORE_ENTRY') || '/crs/OGC/0/Index2D');
    SELECT cset('CRS_INDEX_3D',     cget('SECORE_ENTRY') || '/crs/OGC/0/Index3D');
    SELECT cset('CRS_INDEX_4D',     cget('SECORE_ENTRY') || '/crs/OGC/0/Index4D');
    SELECT cset('CRS_INDEX_5D',     cget('SECORE_ENTRY') || '/crs/OGC/0/Index5D');
    SELECT cset('CRS_EOBSTEST_T',   cget('SECORE_ENTRY') || '/crs/OGC/0/Temporal?epoch="1950-01-01T00:00:00"&uom="d"');
    SELECT cset('CRS_WGS84_2D',     cget('SECORE_ENTRY') || '/crs/EPSG/0/4326');
    SELECT cset('CRS_WGS84_3D',     cget('SECORE_ENTRY') || '/crs/EPSG/0/4327');
    -- GML coverage types
    SELECT cset('GML_ABSTRACT_COV',              'AbstractCoverage');
    SELECT cset('GML_ABSTRACT_DISCRETE_COV',     'AbstractDiscreteCoverage');
    SELECT cset('GML_GRID_COV',                  'GridCoverage');
    SELECT cset('GML_RECTIFIED_GRID_COV',        'RectifiedGridCoverage');
    SELECT cset('GML_REFERENCEABLE_GRID_COV',    'ReferenceableGridCoverage');
    SELECT cset('GML_MULTIPOINT_COV',            'MultiPointCoverage');
    SELECT cset('GML_MULTICURVE_COV',            'MultiCurveCoverage');
    SELECT cset('GML_MULTISURFACE_COV',          'MultiSurfaceCoverage');
    SELECT cset('GML_MULTISOLID_COV',            'MultiSolidCoverage');
    -- Extra metadata types (internal naming)
    SELECT cset('METADATA_TYPE_OWS',          'ows');
    SELECT cset('METADATA_TYPE_GMLCOV',       'gmlcov');
    SELECT cset('METADATA_TYPE_ATTRTABLE',    'attrtable_name');
    -- Range data types
    SELECT cset('PRIMITIVE',    'primitive'); -- these types/quantities will not be dropped (CASCADE)
    SELECT cset('DT_BOOLEAN',   'boolean');
    SELECT cset('DT_CHAR',      'char');
    SELECT cset('DT_UCHAR',     'unsigned char');
    SELECT cset('DT_SHORT',     'short');
    SELECT cset('DT_USHORT',    'unsigned short');
    SELECT cset('DT_INT',       'int');
    SELECT cset('DT_UINT',      'unsigned int');
    SELECT cset('DT_LONG',      'long');
    SELECT cset('DT_ULONG',     'unsigned long');
    SELECT cset('DT_FLOAT',     'float');
    SELECT cset('DT_DOUBLE',    'double');
    SELECT cset('DT_COMPLEX',   'complex');
    SELECT cset('DT_COMPLEX2',  'complex2');
    -- Range data types meanings
    SELECT cset('DT_BOOLEAN_MEANING',    'Boolean');
    SELECT cset('DT_CHAR_MEANING',       '8-bit signed integer');
    SELECT cset('DT_UCHAR_MEANING',      '8-bit unsigned integer');
    SELECT cset('DT_SHORT_MEANING',      '16-bit signed integer');
    SELECT cset('DT_USHORT_MEANING',     '16-bit unsigned integer');
    SELECT cset('DT_INT_MEANING',        '32-bit signed integer');
    SELECT cset('DT_UINT_MEANING',       '32-bit unsigned integer');
    SELECT cset('DT_LONG_MEANING',       '64-bit signed integer');
    SELECT cset('DT_ULONG_MEANING',      '64-bit unsigned integer');
    SELECT cset('DT_FLOAT_MEANING',      'Single precision floating point number');
    SELECT cset('DT_DOUBLE_MEANING',     'Double precision floating point number');
    SELECT cset('DT_COMPLEX_MEANING',    'Single precision complex number');
    SELECT cset('DT_COMPLEX2_MEANING',   'Double precision complex number');
    -- Range data types definition URIs
    SELECT cset('DT_CHAR_DEFINITION',       'http://www.opengis.net/def/dataType/OGC/0/signedByte');
    SELECT cset('DT_UCHAR_DEFINITION',      'http://www.opengis.net/def/dataType/OGC/0/unsignedByte');
    SELECT cset('DT_SHORT_DEFINITION',      'http://www.opengis.net/def/dataType/OGC/0/signedShort');
    SELECT cset('DT_USHORT_DEFINITION',     'http://www.opengis.net/def/dataType/OGC/0/unsignedShort');
    SELECT cset('DT_INT_DEFINITION',        'http://www.opengis.net/def/dataType/OGC/0/signedInt');
    SELECT cset('DT_UINT_DEFINITION',       'http://www.opengis.net/def/dataType/OGC/0/unsignedInt');
    SELECT cset('DT_LONG_DEFINITION',       'http://www.opengis.net/def/dataType/OGC/0/signedLong');
    SELECT cset('DT_ULONG_DEFINITION',      'http://www.opengis.net/def/dataType/OGC/0/unsignedLong');
    SELECT cset('DT_FLOAT_DEFINITION',      'http://www.opengis.net/def/dataType/OGC/0/float32');
    SELECT cset('DT_DOUBLE_DEFINITION',     'http://www.opengis.net/def/dataType/OGC/0/float64');
    -- Data intervals
    SELECT cset('CHAR_MIN',                        -128);
    SELECT cset('CHAR_MAX',                         127);
    SELECT cset('UCHAR_MIN',                          0);
    SELECT cset('UCHAR_MAX',                        255);
    SELECT cset('SHORT_MIN',                     -32768);
    SELECT cset('SHORT_MAX',                      32767);
    SELECT cset('USHORT_MIN',                         0);
    SELECT cset('USHORT_MAX',                     65535);
    SELECT cset('INT_MIN',                  -2147483648);
    SELECT cset('INT_MAX',                   2147483647);
    SELECT cset('UINT_MIN',                           0);
    SELECT cset('UINT_MAX',                  4294967295);
    SELECT cset('LONG_MIN',        -9223372036854775808);
    SELECT cset('LONG_MAX',         9223372036854775807);
    SELECT cset('ULONG_MIN',                          0);
    SELECT cset('ULONG_MAX',       18446744073709551615);
    SELECT cset('FLOAT_MIN',              -3.4028234^38::numeric); -- Wrong values (ticket #748) :
    SELECT cset('FLOAT_MAX',               3.4028234^38::numeric); -- 38/308 are 10th powers: eg 3.4028234 * (10^38)
    SELECT cset('DOUBLE_MIN',   -1.7976931348623157^308::numeric); --
    SELECT cset('DOUBLE_MAX',    1.7976931348623157^308::numeric); -- See update9.sql for the correct bounds.
    -- PS_ (COVERAGE)
    SELECT cset('PS_PREFIX','ps');
    SELECT cset('TABLE_PS_AXISTYPE',             cget('PS_PREFIX') || '_axistype');
          SELECT cset('PS_AXISTYPE_ID',         'id');
          SELECT cset('PS_AXISTYPE_TYPE',       'axistype');
    SELECT cset('TABLE_PS_COVERAGE',             cget('PS_PREFIX') || '_coverage');
          SELECT cset('PS_COVERAGE_ID',         'id');
          SELECT cset('PS_COVERAGE_NAME',       'name');
          SELECT cset('PS_COVERAGE_TYPE',       'type');
    SELECT cset('TABLE_PS_CRS',                  cget('PS_PREFIX') || '_crs');
          SELECT cset('PS_CRS_ID',              'id');
          SELECT cset('PS_CRS_NAME',            'name');
    SELECT cset('TABLE_PS_CRSSET',               cget('PS_PREFIX') || '_crsset');
          SELECT cset('PS_CRSSET_AXIS',         'axis');
          SELECT cset('PS_CRSSET_CRS',          'crs');
    SELECT cset('TABLE_PS_DATATYPE',             cget('PS_PREFIX') || '_datatype');
          SELECT cset('PS_DATATYPE_ID',         'id');
          SELECT cset('PS_DATATYPE_TYPE',       'datatype');
    SELECT cset('TABLE_PS_DOMAIN',               cget('PS_PREFIX') || '_domain');
          SELECT cset('PS_DOMAIN_ID',           'id');
          SELECT cset('PS_DOMAIN_COVERAGE',     'coverage');
          SELECT cset('PS_DOMAIN_NAME',         'name');
          SELECT cset('PS_DOMAIN_TYPE',         'type');
          SELECT cset('PS_DOMAIN_NUMLO',        'numlo');
          SELECT cset('PS_DOMAIN_NUMHI',        'numhi');
          SELECT cset('PS_DOMAIN_I',            'i');
    SELECT cset('TABLE_PS_CELLDOMAIN',           cget('PS_PREFIX') || '_celldomain');
          SELECT cset('PS_CELLDOMAIN_COVERAGE', 'coverage');
          SELECT cset('PS_CELLDOMAIN_I',        'i');
          SELECT cset('PS_CELLDOMAIN_LO',       'lo');
          SELECT cset('PS_CELLDOMAIN_HI',       'hi');
    SELECT cset('TABLE_PS_METADATA',             cget('PS_PREFIX') || '_metadata');
          SELECT cset('PS_METADATA_COVERAGE',   'coverage');
          SELECT cset('PS_METADATA_METADATA',   'metadata');
    SELECT cset('TABLE_PS_RANGE',                cget('PS_PREFIX') || '_range');
          SELECT cset('PS_RANGE_COVERAGE',      'coverage');
          SELECT cset('PS_RANGE_I',             'i');
          SELECT cset('PS_RANGE_NAME',          'name');
          SELECT cset('PS_RANGE_TYPE',          'type');
          SELECT cset('PS_RANGE_UOM',           'uom');
    SELECT cset('TABLE_PS_UOM',                  cget('PS_PREFIX') || '_uom');
          SELECT cset('PS_UOM_ID',              'id');
          SELECT cset('PS_UOM_UOM',             'uom');
          SELECT cset('PS_UOM_LINK',            'link');
    -- PS_ (WMS)
    SELECT cset('TABLE_PS_SERVICES',           cget('PS_PREFIX') || '_services');
    SELECT cset('TABLE_PS_LAYERS',             cget('PS_PREFIX') || '_layers');
    SELECT cset('TABLE_PS_SERVICELAYER',       cget('PS_PREFIX') || '_servicelayer');
    SELECT cset('TABLE_PS_STYLES',             cget('PS_PREFIX') || '_styles');
    SELECT cset('TABLE_PS_PYRAMIDLEVELS',      cget('PS_PREFIX') || '_pyramidlevels');
    -- PS9_
    -- This prefix is set as argument since during upgrade these tables have a first
    -- interim prefix 'ps9_' to avoid clash while co-existing with old tables,
    -- and then are renamed back to 'ps_*'.
    SELECT cset('PS9_PREFIX', $1);
    SELECT cset('TABLE_PS9_COVERAGE',                         cget('PS9_PREFIX') || '_coverage');
          SELECT cset('PS9_COVERAGE_ID',                     'id');
          SELECT cset('PS9_COVERAGE_NAME',                   'name');
          SELECT cset('PS9_COVERAGE_GML_TYPE_ID',            'gml_type_id');
          SELECT cset('PS9_COVERAGE_FORMAT_ID',              'native_format_id');
    SELECT cset('TABLE_PS9_CRS',                              cget('PS9_PREFIX') || '_crs');
          SELECT cset('PS9_CRS_ID',                          'id');
          SELECT cset('PS9_CRS_URI',                         'uri');
    SELECT cset('TABLE_PS9_DBUPDATES',                        cget('PS9_PREFIX') || '_dbupdates');
    SELECT cset('TABLE_PS9_DOMAINSET',                        cget('PS9_PREFIX') || '_domain_set');
          SELECT cset('PS9_DOMAINSET_COVERAGE_ID',           'coverage_id');
          SELECT cset('PS9_DOMAINSET_CRS_IDS',               'native_crs_ids');
    SELECT cset('TABLE_PS9_GRIDDED_DOMAINSET',                cget('PS9_PREFIX') || '_gridded_domain_set');
          SELECT cset('PS9_GRIDDED_DOMAINSET_COVERAGE_ID',   'coverage_id');
          SELECT cset('PS9_GRIDDED_DOMAINSET_ORIGIN',        'grid_origin');
    SELECT cset('TABLE_PS9_GRID_AXIS',                        cget('PS9_PREFIX') || '_grid_axis');
          SELECT cset('PS9_GRID_AXIS_ID',                    'id');
          SELECT cset('PS9_GRID_AXIS_COVERAGE_ID',           'gridded_coverage_id');
          SELECT cset('PS9_GRID_AXIS_RASDAMAN_ORDER',        'rasdaman_order');
    SELECT cset('TABLE_PS9_DESCRIPTION',                      cget('PS9_PREFIX') || '_description');
          SELECT cset('PS9_DESCRIPTION_KEYWORD_GROUP_IDS',    'keyword_group_ids');
    SELECT cset('TABLE_PS9_EXTRA_METADATA',                   cget('PS9_PREFIX') || '_extra_metadata');
          SELECT cset('PS9_EXTRA_METADATA_COVERAGE_ID',      'coverage_id');
          SELECT cset('PS9_EXTRA_METADATA_TYPE',             'metadata_type_id');
          SELECT cset('PS9_EXTRA_METADATA_VALUE',            'value');
    SELECT cset('TABLE_PS9_EXTRA_METADATA_TYPE',              cget('PS9_PREFIX') || '_extra_metadata_type');
          SELECT cset('PS9_EXTRA_METADATA_TYPE_ID',          'id');
          SELECT cset('PS9_EXTRA_METADATA_TYPE_TYPE',        'type');
    SELECT cset('TABLE_PS9_GML_SUBTYPE',                      cget('PS9_PREFIX') || '_gml_subtype');
          SELECT cset('PS9_GML_SUBTYPE_ID',                  'id');
          SELECT cset('PS9_GML_SUBTYPE_SUBTYPE',             'subtype');
    SELECT cset('TABLE_PS9_KEYWORD',                          cget('PS9_PREFIX') || '_keyword');
          SELECT cset('PS9_KEYWORD_ID',                      'id');
    SELECT cset('TABLE_PS9_KEYWORD_GROUP',                    cget('PS9_PREFIX') || '_keyword_group');
          SELECT cset('PS9_KEYWORD_GROUP_ID',                 'id');
          SELECT cset('PS9_KEYWORD_GROUP_KEYWORD_IDS',        'keyword_ids');
    SELECT cset('TABLE_PS9_INTERVAL',                         cget('PS9_PREFIX') || '_interval');
          SELECT cset('PS9_INTERVAL_ID',                     'id');
          SELECT cset('PS9_INTERVAL_MIN',                    'min');
          SELECT cset('PS9_INTERVAL_MAX',                    'max');
    SELECT cset('TABLE_PS9_NIL_VALUE',                        cget('PS9_PREFIX') || '_nil_value');
          SELECT cset('PS9_NIL_VALUE_ID',                     'id');
    SELECT cset('TABLE_PS9_QUANTITY_INTERVAL',                cget('PS9_PREFIX') || '_quantity_interval');
          SELECT cset('PS9_QUANTITY_INTERVAL_QID',           'quantity_id');
          SELECT cset('PS9_QUANTITY_INTERVAL_IID',           'interval_id');
    SELECT cset('TABLE_PS9_MIME_TYPE',                        cget('PS9_PREFIX') || '_mime_type');
          SELECT cset('PS9_MIME_TYPE_ID',                    'id');
          SELECT cset('PS9_MIME_TYPE_MIME',                  'mime_type');
    SELECT cset('TABLE_PS9_QUANTITY',                         cget('PS9_PREFIX') || '_quantity');
          SELECT cset('PS9_QUANTITY_ID',                     'id');
          SELECT cset('PS9_QUANTITY_UOM_ID',                 'uom_id');
          SELECT cset('PS9_QUANTITY_URI',                    'definition_uri');
          SELECT cset('PS9_QUANTITY_DESCRIPTION',            'description');
          SELECT cset('PS9_QUANTITY_LABEL',                  'label');
          SELECT cset('PS9_QUANTITY_NIL_IDS',                'nil_ids');
    SELECT cset('TABLE_PS9_RANGE_DATATYPE',                   cget('PS9_PREFIX') || '_range_data_type');
          SELECT cset('PS9_RANGE_DATATYPE_ID',               'id');
          SELECT cset('PS9_RANGE_DATATYPE_NAME',             'name');
    SELECT cset('TABLE_PS9_RANGESET',                         cget('PS9_PREFIX') || '_range_set');
          SELECT cset('PS9_RANGESET_COVERAGE_ID',            'coverage_id');
          SELECT cset('PS9_RANGESET_STORAGE_ID',             'storage_id');
          SELECT cset('PS9_RANGESET_STORAGE_TABLE',          'storage_table');
    SELECT cset('TABLE_PS9_RANGETYPE_COMPONENT',              cget('PS9_PREFIX') || '_range_type_component');
          SELECT cset('PS9_RANGETYPE_COMPONENT_ID',          'id');
          SELECT cset('PS9_RANGETYPE_COMPONENT_COVERAGE_ID', 'coverage_id');
          SELECT cset('PS9_RANGETYPE_COMPONENT_NAME',        'name');
          SELECT cset('PS9_RANGETYPE_COMPONENT_TYPE_ID',     'data_type_id');
          SELECT cset('PS9_RANGETYPE_COMPONENT_ORDER',       'component_order');
          SELECT cset('PS9_RANGETYPE_COMPONENT_FIELD_ID',    'field_id');
          SELECT cset('PS9_RANGETYPE_COMPONENT_FIELD_TABLE', 'field_table');
    SELECT cset('TABLE_PS9_RASDAMAN_COLLECTION',              cget('PS9_PREFIX') || '_rasdaman_collection');
          SELECT cset('PS9_RASDAMAN_COLLECTION_ID',          'id');
          SELECT cset('PS9_RASDAMAN_COLLECTION_NAME',        'name');
          SELECT cset('PS9_RASDAMAN_COLLECTION_OID',         'oid');
          SELECT cset('PS9_RASDAMAN_COLLECTION_BASETYPE',    'base_type');
    SELECT cset('TABLE_PS9_RECTILINEAR_AXIS',                 cget('PS9_PREFIX') || '_rectilinear_axis');
          SELECT cset('PS9_RECTILINEAR_AXIS_ID',             'grid_axis_id');
          SELECT cset('PS9_RECTILINEAR_AXIS_OFFSET_VECTOR',  'offset_vector');
    SELECT cset('TABLE_PS9_SERVICE_IDENTIFICATION',           cget('PS9_PREFIX') || '_service_identification');
          SELECT cset('PS9_SERVICE_IDENTIFICATION_ID',       'id');
          SELECT cset('PS9_SERVICE_IDENTIFICATION_TYPE',     'type');
    SELECT cset('TABLE_PS9_SERVICE_PROVIDER',                 cget('PS9_PREFIX') || '_service_provider');
    SELECT cset('TABLE_PS9_UOM',                              cget('PS9_PREFIX') || '_uom');
          SELECT cset('PS9_UOM_ID',                          'id');
          SELECT cset('PS9_UOM_CODE',                        'code');
    SELECT cset('TABLE_PS9_VECTOR_COEFFICIENTS',              cget('PS9_PREFIX') || '_vector_coefficients');
          SELECT cset('PS9_VECTOR_COEFFICIENTS_ID',          'grid_axis_id');
          SELECT cset('PS9_VECTOR_COEFFICIENTS_VALUE',       'coefficient');
          SELECT cset('PS9_VECTOR_COEFFICIENTS_ORDER',       'coefficient_order');
    -- PS migration (dropped after migration)
    SELECT cset('TABLE_PS9_NORTH_FIRST_CRSS',       cget('PS9_PREFIX') || '_north_first_crs');
          SELECT cset('PS9_NORTH_FIRST_CRSS_CODE', 'crs_code');
    -- RAS_
    SELECT cset('DB_RASBASE', 'RASBASE');
    SELECT cset('RAS_PREFIX', 'ras');
    SELECT cset('TABLE_RAS_MDD_COLLECTIONS',            cget('RAS_PREFIX') || '_mddcollections');
          SELECT cset('RAS_MDD_COLLECTIONS_MDDID',     'mddid');
          SELECT cset('RAS_MDD_COLLECTIONS_MDDCOLLID', 'mddcollid');
    SELECT cset('TABLE_RAS_MDD_COLLNAMES',              cget('RAS_PREFIX') || '_mddcollnames');
          SELECT cset('RAS_MDD_COLLNAMES_COLLID',      'mddcollid');
          SELECT cset('RAS_MDD_COLLNAMES_COLLNAME',    'mddcollname');
    SELECT cset('TABLE_RAS_MDD_OBJECTS',                cget('RAS_PREFIX') || '_mddobjects');
          SELECT cset('RAS_MDD_OBJECTS_MDDID',         'mddid');
    -- TODO: WCPS/GDAL/MIME format IDs
    -- ...
$$ LANGUAGE 'sql';
SELECT set_constants('ps9');
