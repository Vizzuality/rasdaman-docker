#!/bin/bash
# This script automatically starts all relevant services on the container
echo -e "\n\nStarting required services..."
/usr/sbin/sshd -D >/dev/null &
echo -e "... sshd started"
/etc/init.d/postgresql start >/dev/null
sleep 2
echo -e "... postgresql started"
su - rasdaman -c"/opt/rasdaman/bin/start_rasdaman.sh" >/dev/null
sleep 5
echo -e "... rasdaman started"
rstudio-server start
sleep 3
echo -e "... rstudio-server started"
/opt/tomcat6/bin/startup.sh >/dev/null
sleep 10
echo -e "... tomcat6 started"
echo -e "DONE.\n\n"

