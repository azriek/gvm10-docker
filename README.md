# gvm10-docker
Non-official Greenbone Vulnerability Management (GVM) 10 Docker build

_very simple_ __Work In Progress__ Docker build for GVM10.

## Aims
  - simple to build, just following Greenbone Install files and requirements
  - simple to review, rebuild, no extra functionnality
  - slim image
  
## Run (no persistence)
  - docker  run -p 8443:443  --name gvm10 azriek/gvm10-docker

## Sync
  - nvt: docker exec gvm10 /opt/openvas/sbin/greenbone-nvt-sync
  - scap: docker exec gvm10 /opt/openvas/sbin/greenbone-scapdata-sync
  - cert: docker exec gvm10 /opt/openvas/sbin/greenbone-certdata-sync
