#!/bin/bash
# Batch script for optimizing postgres parameters based on http://rasdaman.org/wiki/Performance
# Parameters 
# 1) Available RAM for postgres in MB,
# 2) number of users working with the DB
# 3) filename and path of postgresql.conf
# Usage ./pgconfig.sh 1024 2  /etc/postgresql/9.1/main/postgresql.conf


if [ $# -lt 3 ]; then
    echo -e One or more arguments missing!\nUsage ./pgconfig.sh TOTAL_RAM NUM_USERS PGCONF_FILE
    exit 1
fi


TOTAL_RAM=$1
USERS=$2
POSTGRES_CONFFILE=$3


MAX_CONNECTIONS=$((USERS*40))
SHARED_BUFFERS=$((TOTAL_RAM/4))
WORK_MEM=$((TOTAL_RAM/USERS/8))
if [ $WORK_MEM -lt 128 ]; then
    WORK_MEM=128
fi
MAINTANANCE_WORK_MEM=$((TOTAL_RAM/16))
SYNCHRONOUS_COMMIT=off
WAL_BUFFERS=16
CHECKPOINT_SEGMENTS=256
CHECKPOINT_COMPLETION_TARGET=0.0
RANDOM_PAGE_COST=2.0 # CHANGE TO 1.01 for SSD of RAM DBs
EFFECTIVE_CACHE_SIZE=$((TOTAL_RAM-SHARED_BUFFERS))
LOGGING_COLLECTION=on
LOG_LINE_PREFIX='%t '


SHARED_BUFFERS="${SHARED_BUFFERS}MB"
WORK_MEM="${WORK_MEM}MB"
MAINTANANCE_WORK_MEM="${MAINTANANCE_WORK_MEM}MB"
WAL_BUFFERS="${WAL_BUFFERS}MB"
EFFECTIVE_CACHE_SIZE="${EFFECTIVE_CACHE_SIZE}MB"


# Test output
echo -e "The following settings will be written to postgresql.conf:"
echo -e "max_connections = ${MAX_CONNECTIONS}"
echo -e "shared_buffers = ${SHARED_BUFFERS}"
echo -e "work_mem = ${WORK_MEM}"
#echo -e "maintanance_work_mem = ${MAINTANANCE_WORK_MEM}"
echo -e "synchronous_commit = ${SYNCHRONOUS_COMMIT}"
echo -e "wal_buffers = ${WAL_BUFFERS}"
echo -e "checkpoint_segments = ${CHECKPOINT_SEGMENTS}"
echo -e "checkpoint_completion_target = ${CHECKPOINT_COMPLETION_TARGET}"
echo -e "random_page_cost = ${RANDOM_PAGE_COST}"
echo -e "effective_cache_size = ${EFFECTIVE_CACHE_SIZE}"
echo -e "logging_collector = ${LOGGING_COLLECTION}"
#echo -e "log_line_prefix = ${LOG_LINE_PREFIX}"


read -p "Are you sure you want to use these postgres settings? Type y or n"  -n 1 -r REPLY
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi





# Write to postgresql.conf

# Comment old settings
sed -i 's!^max_connections!#max_connections!' $POSTGRES_CONFFILE
sed -i 's!^shared_buffers!#shared_buffers!' $POSTGRES_CONFFILE
#sed -i 's!^maintanance_work_mem!#maintenance_work_mem!' $POSTGRES_CONFFILE
sed -i 's!^work_mem!#work_mem!' $POSTGRES_CONFFILE
sed -i 's!^synchronous_commit!#synchronous_commit!' $POSTGRES_CONFFILE
sed -i 's!^wal_buffers!#wal_buffers!' $POSTGRES_CONFFILE
sed -i 's!^checkpoint_segments!#checkpoint_segments!' $POSTGRES_CONFFILE
sed -i 's!^checkpoint_completion_target!#checkpoint_completion_target!' $POSTGRES_CONFFILE
sed -i 's!^random_page_cost!#random_page_cost!' $POSTGRES_CONFFILE
sed -i 's!^effective_cache_size!#effective_cache_size!' $POSTGRES_CONFFILE
sed -i 's!^logging_collector!#logging_collector!' $POSTGRES_CONFFILE
#sed -i 's!^log_line_prefix!#log_line_prefix!' $POSTGRES_CONFFILE

# Append new settings
echo -e "\n\n###### CUSTOM SETTINGS OPTIMIZED FOR RASDAMAN GIVEN ${TOTAL_RAM} MB RAM AND ${USERS} USERS #######"  >> $POSTGRES_CONFFILE
echo -e "max_connections = ${MAX_CONNECTIONS}" >> $POSTGRES_CONFFILE
echo -e "shared_buffers = ${SHARED_BUFFERS}" >> $POSTGRES_CONFFILE
echo -e "work_mem = ${WORK_MEM}" >> $POSTGRES_CONFFILE
#echo -e "maintanance_work_mem = ${MAINTANANCE_WORK_MEM}" >> $POSTGRES_CONFFILE
echo -e "synchronous_commit = ${SYNCHRONOUS_COMMIT}"  >> $POSTGRES_CONFFILE
echo -e "wal_buffers = ${WAL_BUFFERS}" >>  $POSTGRES_CONFFILE
echo -e "checkpoint_segments = ${CHECKPOINT_SEGMENTS}" >> $POSTGRES_CONFFILE
echo -e "checkpoint_completion_target = ${CHECKPOINT_COMPLETION_TARGET}" >> $POSTGRES_CONFFILE
echo -e "random_page_cost = ${RANDOM_PAGE_COST}" >> $POSTGRES_CONFFILE
echo -e "effective_cache_size = ${EFFECTIVE_CACHE_SIZE}" >> $POSTGRES_CONFFILE
echo -e "logging_collector = ${LOGGING_COLLECTION}" >> $POSTGRES_CONFFILE
#echo -e "log_line_prefix = ${LOG_LINE_PREFIX}"  >> $POSTGRES_CONFFILE
echo -e "###################################################################\n\n" >> $POSTGRES_CONFFILE




# Restart postgres
echo -e "Restarting postgres..."
service postgresql restart >/dev/null 2>&1
echo -e "DONE"