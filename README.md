# Build, Distribute, & Install caffe on Ubuntu 18.04 with Python 3.6.

## Instructions / Tutorial.

Acquire ```build_caffe```.

    git clone --depth 1 --recurse-submodules -j8 https://github.com/jed-frey/build_caffe.git
    cd build_caffe

Install Ubuntu 18.04 host packages:

    sudo make env.host

## Build

Build with defaults:

  make dist

Build without GPU support:

  make dist -j8 USE_CUDNN=0 CPU_ONLY=1

Output distributable package is:

  caffe_dist.tar.xz

## Install Distributable Package

**Local installation** of caffe package.

For shared machines where you don't have admin access.

	tar -xJvf caffe_dist.tar.xz -C ~/.local/

Configure your shell to find the library and path:

	echo 'export LD_LIBRARY_PATH=~/.local/caffe/distribute/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
	echo 'export PATH=~/.local/caffe/distribute/bin:$PATH' >> ~/.bashrc

**Global installation** of caffe package for all users:

For shared machines or devices you own where you have admin access:

As root:

	# Extract distribution archive.
	tar -xJvf caffe_dist.tar.xz -C /opt/
	# Add libraries.
	echo /opt/caffe/distribute/lib > /etc/ld.so.conf.d/caffe.conf
	ldconfig
	# Ensure that that the libraries are found
	ldconfig --print-cache | grep caffe
	# Add caffe to everyone's path:
	echo 'export PATH=/opt/caffe/distribute/bin:$PATH' > /etc/profile.d/caffe.sh

Installing in a directory other than ```/opt``` is left as an exercise to the reader.

# Python Integration

There are multiple ways to expose the ```caffe``` Python modules to Python.


**Local** install, Permanently:

	echo 'export PYTHONPATH=~/.local/caffe/distribute/python:$PYTHONPATH' >> ~/.bashrc

**Global** install, Permanently:

	echo 'PYTHONPATH=/opt/caffe/distribute/python:$PYTHONPATH' >> /etc/profile.d/caffe.sh

**Local** install, for each script/notebook:

Add this before ```import caffe```

```python
import os, sys
sys.path.append(os.path.expanduser("~/.local/caffe/distribute/python"))
```

**Global** install, for each script/notebook:

Add this before ```import caffe```

```python
import sys
sys.path.append("/opt/caffe/distribute/python")
```

## Uninstall:

**Local installation** of caffe package:

	rm -rf ~/.local/caffe

Remove caffe ```LD_LIBRARY_PATH``` and ```PATH``` lines from ~/.bashrc

**Global installation**:

	rm -rf /opt/caffe
	rm -rf /etc/ld.so.conf.d/caffe.conf && ldconfig
	rm -rf /etc/profile.d/caffe.sh

# Issues

Anything *doesn't* work, open an issue: https://github.com/jed-frey/build_caffe/issues/new

Describe what actions you took, what it did, what you expected it to do, what you tried to fix it.

# Build Speed Improvements

## [icecc](https://github.com/icecc/icecream) distributed builds.

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

## [ccache](https://ccache.samba.org/)

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
