#!/bin/sh

ldconfig

/etc/init.d/redis-server start
/etc/init.d/postgresql start

/bin/sleep 5

if psql -d gvmd -c "select 1" ; then 
    echo 'database ok' 
else 
    echo 'database init'
    su -l postgres -c "createuser -DRS root && 
                createdb -O root gvmd && 
                psql -d gvmd -c 'create role dba with superuser noinherit; 
                                grant dba to root; 
                                create extension \"uuid-ossp\"; 
                                create extension \"pgcrypto\";'
"

fi

/opt/openvas/bin/gvm-manage-certs -a

/opt/openvas/sbin/gvmd
/opt/openvas/sbin/gsad
/bin/sleep 2 # wait initialisation
/opt/openvas/sbin/gvmd --create-user=admin --password=Openv4s_
#/opt/openvas/sbin/greenbone-nvt-sync 
#/opt/openvas/sbin/greenbone-certdata-sync  
#/opt/openvas/sbin/greenbone-scapdata-sync 

tail -F /opt/openvas/var/log/gvm/*.log

