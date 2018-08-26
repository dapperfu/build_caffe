# Build caffe on Ubuntu 18.04

## Instructions / Tutorial.

Acquire ```build_caffe```.

    git clone --depth 1 --recurse-submodules -j8 https://github.com/jed-frey/build_caffe.git
    cd build_caffe

Install Ubuntu 18.04 host packages:

    sudo make env.host

## Build

Build with defaults:

  make caffe.make

Build without GPU support:

  make caffe.make -j8 USE_CUDNN=0 CPU_ONLY=1

Output files are in:

  caffe/distribute/

## Build Speed Improvements

### [icecc](https://github.com/icecc/icecream) distributed builds.

> Icecream takes compile jobs from a build and distributes it among remote machines allowing a parallel build.

If you have a few, or a lot of machines laying around, you can distribute the build so that it goes faster.

Link your compiler:

	ln -s `which icecc` /usr/lib/icecc/bin/gcc-7
	ln -s `which icecc` /usr/lib/icecc/bin/g++-7

Add icecc path to path:

**C shells**:

	set path = (/usr/lib/icecc/bin $path)

**Bourne shells**:

	export PATH=/usr/lib/icecc/bin:$PATH

### [ccache](https://ccache.samba.org/)

> ccache is a compiler cache. It speeds up recompilation by caching previous compilations and detecting when the same compilation is being done again. Supported languages are C, C++, Objective-C and Objective-C++.

> ccache is free software, released under the GNU General Public License version 3 or later. See also the license page.

Link your compiler:

	mkdir -p /opt/ccache/bin
	ln -s `which ccache` /opt/ccache/bin/gcc-7
	ln -s `which ccache` /opt/ccache/bin/g++-7

To just use ccache without icecc omit ```CCACHE_PREFIX```:

**C shells**:

	setenv CCACHE_PREFIX icecc
	set path = (/opt/ccache/bin $path)

**Bourne shells**:

	export CCACHE_PREFIX=icecc
	export PATH=/opt/ccache/bin:$PATH


### Build Timing Results.

w/ccache w/icecc, ccache cache 'hot'.

	export CCACHE_PREFIX=icecc
	export PATH=/opt/ccache/bin:$PATH
	make clean; time make -j28

	real    1m25.215s
	user    7m9.134s
	sys     0m47.519s


	export CCACHE_PREFIX=
	export PATH=/opt/ccache/bin:$PATH
	make clean; time make -j28

	real    1m33.204s
	user    8m10.721s
	sys     0m49.360s

w/icecc w/o ccache:

	export PATH=/usr/lib/icecc/bin:$PATH
	make clean; time make -j28

	real    1m40.280s
	user    8m24.388s
	sys     0m53.219s

w/o icecc, w/o ccache:

	make clean; make -j6

	real    2m8.371s
	user    11m19.414s
	sys     0m59.418s

icecc build machines:

- i5-8600K CPU @ 3.60GHz. 64 GB RAM (Master)
- i7-4770K CPU @ 3.50GHz. 16 GB RAM
- Dell M6700. i7-3940XM CPU @ 3.00GHz. 32GB RAM
- Dell N5010. i3 CPU M 350  @ 2.27Ghz. 4GB RAM.
