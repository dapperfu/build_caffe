# Config

# Environments to setup for this project
# Available options: python arduino
ENVS:=python

## make_sandwich includes
# https://github.com/jed-frey/make_sandwich
include .mk_inc/env.mk
include Makefile.config

caffe:
	git clone --depth 1 --recurse-submodules -j8  https://github.com/BVLC/caffe.git

.PHONY: clean.caffe
clean.caffe:
	rm -rf caffe

.PHONY: caffe.make
caffe.make: caffe
	${MAKE} -C $(realpath ${MK_DIR}/caffe) CONFIG_FILE=$(realpath ${MK_DIR}/Makefile.config) clean
	${MAKE} -C $(realpath ${MK_DIR}/caffe) CONFIG_FILE=$(realpath ${MK_DIR}/Makefile.config)
	make -C $(realpath ${MK_DIR}/caffe) CONFIG_FILE=$(realpath ${MK_DIR}/Makefile.config) distribute


CMAKE_BOOSTLIBS = Boost_ATOMIC_LIBRARY_DEBUG Boost_ATOMIC_LIBRARY_RELEASE Boost_CHRONO_LIBRARY_DEBUG Boost_CHRONO_LIBRARY_RELEASE Boost_DATE_TIME_LIBRARY_DEBUG Boost_DATE_TIME_LIBRARY_RELEASE Boost_FILESYSTEM_LIBRARY_DEBUG Boost_FILESYSTEM_LIBRARY_RELEASE Boost_PYTHON_LIBRARY_DEBUG Boost_PYTHON_LIBRARY_RELEASE Boost_SYSTEM_LIBRARY_DEBUG Boost_SYSTEM_LIBRARY_RELEASE Boost_THREAD_LIBRARY_DEBUG Boost_THREAD_LIBRARY_RELEASE
CMAKE_FLAGS+=$(foreach CMAKE_BOOSTLIB, ${CMAKE_BOOSTLIBS},-D${CMAKE_BOOSTLIB}=/usr/lib/x86_64-linux-gnu/libboost_python3-py36.so)

CMAKE_FLAGS+=-DPYTHON_EXECUTABLE=$(shell which python3)
CMAKE_FLAGS+=-DCMAKE_CXX_COMPILER=${CUSTOM_CXX}

.PHONY: debug.cmake
debug.cmake:
	@$(info $${CMAKE_FLAGS}=${CMAKE_FLAGS})

.PHONY: dist
dist: caffe_dist.tar.xz
	@echo ${^} is available for distribution.

caffe_dist.tar.xz: caffe_dist.tar
	xz --compress --keep --extreme --threads=0 ${^}

caffe_dist.tar: caffe/distribute/bin/caffe.bin caffe/CHANGELOG.txt
	tar -cf caffe_dist.tar caffe/CHANGELOG.txt caffe/distribute

caffe/distribute/bin/caffe.bin: caffe.make

caffe/CHANGELOG.txt:
	$(shell git --git-dir=caffe/.git log >> ${@})


.PHONY: caffe.cmake.make
caffe.cmake.make: caffe
	rm -rf build.make
	mkdir -p build.make
	cd build.make && cmake -G"Unix Makefiles" ../caffe/ ${CMAKE_FLAGS}
	make -C build.make -j22

.PHONY: caffe.cmake.ninja
caffe.cmake.ninja: caffe
	rm -rf build.ninja
	mkdir -p build.ninja
	cd build.ninja && cmake -G"Ninja" ../caffe/ ${CMAKE_FLAGS}
	ninja -C build.ninja -j22
