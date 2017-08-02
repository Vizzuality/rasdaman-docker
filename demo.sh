#!/bin/bash
# run this as rasdaman user inside the container

rasql -q "select r from RAS_COLLECTIONNAMES as r" --out string
rasdaman_insertdemo.sh localhost 7001 $RMANHOME/share/rasdaman/examples/images rasadmin rasadmin
rasql -q "select r from RAS_COLLECTIONNAMES as r" --out string

# Insert demo dataset # see http://www.rasdaman.org/wiki/RasgeoUserGuide
rasimport  -f $RMANHOME/share/rasdaman/petascope/mean_summer_airtemp.tif --coll mean_summer_airtemp --coverage-name msat_cov -t GreyImage:GreySet --crs-uri 'http://www.opengis.net/def/crs/EPSG/0/4326' --crs-order 1:0 
