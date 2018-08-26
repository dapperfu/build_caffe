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

.PHONY: caffe.cmake.make
caffe.cmake.make: caffe
	rm -rf build.make
	mkdir -p build.make
	cd build.make && cmake -G"Unix Makefiles" ../caffe/ -DPYTHON_EXECUTABLE=$(shell which ${PYTHON}) -DCMAKE_CXX_COMPILER=${CUSTOM_CXX}

.PHONY: caffe.cmake.ninja
caffe.cmake.ninja: caffe
	rm -rf build.ninja
	mkdir -p build.ninja
	cd build.ninja && cmake -G"Ninja" ../caffe/ -DPYTHON_EXECUTABLE=${PYTHON} -DCMAKE_CXX_COMPILER=${CUSTOM_CXX}
