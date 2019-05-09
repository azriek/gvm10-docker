FROM debian:stretch as builder


RUN sed "s/main/main extra non-free/g" /etc/apt/sources.list -i && apt-get update && apt-get install -y \
		cmake \
		pkg-config \
		libglib2.0-dev \
		libgpgme11-dev \
		libgnutls28-dev \
		uuid-dev \
		libssh-gcrypt-dev \
		libhiredis-dev \
		libldap2-dev \
		doxygen \
		git \
		libpcap-dev \
		libgpgme-dev \
		bison \
		libksba-dev \
		libsnmp-dev \
		libgcrypt20-dev \
		python-impacket \ 
		gcc-mingw-w64 \
		perl-base \
		heimdal-dev \
		libpopt-dev \
		apt-transport-https \
		curl \
		libsqlite3-dev \
		libical-dev \
		gnutls-bin \
		xsltproc \
		libmicrohttpd-dev \
		libxml2-dev \
		gettext \
		python-polib \
	&& rm -rf /var/lib/apt/lists/*

RUN curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && echo "deb https://deb.nodesource.com/node_8.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y \
		nodejs \
		yarn 

ENV SOURCE_PATH="/src/openvas10/" \
	GVM_LIBS_URL="https://github.com/greenbone/gvm-libs/archive/v10.0.0.tar.gz" \
	GVM_LIBS="gvm-libs-10.0.0" \
	OPENVAS_SMB_URL="https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz" \
	OPENVAS_SMB="openvas-smb-1.0.5" \
	OPENVAS_SCANNER_URL="https://github.com/greenbone/openvas-scanner/archive/v6.0.0.tar.gz" \
	OPENVAS_SCANNER="openvas-scanner-6.0.0" \
	GVMD_URL="https://github.com/greenbone/gvmd/archive/v8.0.0.tar.gz" \
	GVMD="gvmd-8.0.0" \
	GSA_URL="https://github.com/greenbone/gsa/archive/v8.0.0.tar.gz" \
	GSA="gsa-8.0.0" \
	INSTALL_PREFIX="/opt/openvas"
	
	
WORKDIR ${SOURCE_PATH}

ADD ${GVM_LIBS_URL} ${SOURCE_PATH}/${GVM_LIBS}.tar.gz

RUN export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH && cd ${SOURCE_PATH} && \
	tar -xvzf ${GVM_LIBS}.tar.gz && \
	cd ${GVM_LIBS} && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. && \
	make && \
	make doc && \
	make install

ADD ${OPENVAS_SMB_URL} ${SOURCE_PATH}/${OPENVAS_SMB}.tar.gz

RUN export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH && cd ${SOURCE_PATH} && \
	tar -xvzf ${OPENVAS_SMB}.tar.gz && \
	cd ${OPENVAS_SMB} && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. && \
	make && \
	make install

ADD ${OPENVAS_SCANNER_URL} ${SOURCE_PATH}/${OPENVAS_SCANNER}.tar.gz

RUN export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH && cd ${SOURCE_PATH} && \
	tar -xvzf ${OPENVAS_SCANNER}.tar.gz && \
	cd ${OPENVAS_SCANNER} && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. && \
	make && \
	make doc && \
	make install

ADD ${GVMD_URL} ${SOURCE_PATH}/${GVMD}.tar.gz

RUN export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH && cd ${SOURCE_PATH} && \
	tar -xvzf ${GVMD}.tar.gz && \
	cd ${GVMD} && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. && \
	make && \
	make doc && \
	make install

ADD ${GSA_URL} ${SOURCE_PATH}/${GSA}.tar.gz

RUN export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH && cd ${SOURCE_PATH} && \
	tar -xvzf ${GSA}.tar.gz && \
	cd ${GSA} && \
	curl https://raw.githubusercontent.com/greenbone/gsa/8b4783724dd20a635126eb2e1001ecc392218151/CMakeLists.txt -o CMakeLists.txt && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. && \
	make && \
	make doc && \
	make install && \
	rm -rf ${INSTALL_PREFIX}/share/.cache


FROM debian:stretch-slim

# missing lib :  ldd /usr/local/sbin/openvassd | grep "not found" | sed "s/\t\(.*\) => .*/\1/" | while read n ; do apt-file search $n ; done | sed "s/\(.*\): .*/\1/" | sort | uniq

RUN sed "s/main/main extra non-free/g" /etc/apt/sources.list -i && apt-get update && apt-get install -y \
		apt-transport-https \
		libglib2.0-0 \
		libgpgme11 \
		libssh-gcrypt-4 \
		libkrb5-26-heimdal \
		libgssapi3-heimdal \
		libhdb9-heimdal \
		libheimntlm0-heimdal \
		libhiredis0.13 \
		libpcap0.8 \
		libpopt0 \
		libsnmp30 \
		procps \
		libical2 \
		libmicrohttpd12 \
		curl \
		redis-server \
		gnutls-bin \
		rsync \
		nmap \
		&& rm -rf /var/lib/apt/lists/*


ENV INSTALL_PREFIX="/opt/openvas"		

COPY --from=builder ${INSTALL_PREFIX} ${INSTALL_PREFIX}
COPY gvmd-start.sh /
RUN chmod +x /gvmd-start.sh

RUN echo "${INSTALL_PREFIX}/lib" > /etc/ld.so.conf.d/openvas.conf

EXPOSE 443


CMD ["/gvmd-start.sh"]
