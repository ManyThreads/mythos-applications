

# targets

all: kernel-amd64.log kernel-ihk.log 

setup: 
	git submodule update --init --recursive
	mythos/3rdparty/mcconf/install-python-libs.sh
	mythos/3rdparty/install-libcxx.sh
	mythos/3rdparty/install-ihk.sh

clean:
	rm -f *.log
	rm -rf kernel-amd64
	rm -rf kernel-ihk

# rules

%.log: %.config
	./mythos/3rdparty/mcconf/mcconf -i $<
