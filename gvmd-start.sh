#!/bin/sh

ldconfig

# Start redis server 

redis-server /opt/openvas/share/doc/openvas-scanner/redis_config_examples/redis_3_2.conf


/opt/openvas/bin/gvm-manage-certs -a
/opt/openvas/sbin/openvassd
/opt/openvas/sbin/gvmd
/opt/openvas/sbin/gsad
/bin/sleep 2 # wait initialisation
/opt/openvas/sbin/gvmd --create-user=admin --password=Openv4s_
#/opt/openvas/sbin/greenbone-nvt-sync 
#/opt/openvas/sbin/greenbone-certdata-sync  
#/opt/openvas/sbin/greenbone-scapdata-sync 

tail -F /opt/openvas/var/log/gvm/*.log

