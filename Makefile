
.PHONY: fio nvme-cli openssl iperf_config iperf_prepare iperf_make iperf linux nginx perf wrk

all: fio nvme-cli openssl iperf linux nginx perf wrk

fio:
	(cd fio && ./configure && make && make install)

nvme-cli:
	(cd nvme-cli && make && make install)

openssl:
	(cd openssl && \
	 ./config enable-ktls enable-ssl3 enable-threads linux-x86_64 && \
	 make -j && make -j)

iperf_config:
	(cd iperf && \
	 ./configure)

iperf_prepare:
	 $(shell cd iperf; echo DEFAULT_INCLUDES = -I. -I$$\(top_builddir\) -I$$\(top_builddir\)/../openssl/include >> src/Makefile) 
	 $(shell cd iperf; echo LIBS = -lrt -lcrypto -lssl -L$$\(top_builddir\)/../openssl -I$$\(top_builddir\)/../openssl/include >> src/Makefile)
	 $(shell cd iperf; sed -i 's/#define bool int/\/\/#define bool int/g' config.h)

iperf_make:
	 (cd iperf && make -j)

iperf: iperf_config iperf_prepare iperf_make

nginx:
	(cd nginx &&\
	 ./auto/configure --with-openssl=../openssl --with-threads --with-http_ssl_module --with-openssl-opt="enable-ktls enable-ssl3 enable-threads linux-x86_64" && \
	 make -j && make -j)

linux:
	(cd linux && \
	 cp config.nvme .config && \
	 make olddefconfig && \
	 make -j && \
	 sudo make -j modules_install && \
	 sudo make headers_install ARCH=i386 INSTALL_HDR_PATH=/usr)

perf:
	(cd linux/tools/perf &&\
	 make -j)

wrk:
	(cd wrk &&\
	 make -j)
