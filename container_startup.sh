#!/bin/bash
# This script automatically starts all relevant services on the container
/etc/init.d/postgresql start >/dev/null
sleep 5
echo -e "PostgreSQL started"

su - rasdaman -c"/opt/rasdaman/bin/start_rasdaman.sh"
sleep 5
echo -e "Rasdaman started"
