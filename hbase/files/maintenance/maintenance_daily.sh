#!/bin/bash
# Maintainer: Francesco Salbaroli
set -e

logger -t hbase_maintenance "Executing HBASE daily maintenance"

# EXECUTE ONLY IF ON ACTIVE MASTER
CURRENT_HOST=`hostname --fqdn`
ACTIVE_MASTER=`hbase org.jruby.Main /usr/lib/hbase/bin/get-active-master.rb`
if [ $ACTIVE_MASTER != $CURRENT_HOST ]
then
  logger -t hbase_maintenance "Current host ($CURRENT_HOST) is not the hbase master ($ACTIVE_MASTER). Terminating."
  exit 0
fi

# RUN MAJOR COMPACTION FOR ALL THE TABLES
logger -t hbase_maintenance "Triggering major compaction"
hbase shell /etc/hbase/scripts/major_compaction.hql

logger -t hbase_maintenance "Finished HBASE daily maintenance"
