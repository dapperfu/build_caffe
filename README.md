# Build caffe on Ubuntu 18.04

## Instructions / Tutorial.

Acquire ```build_caffe````

    git clone --depth 1 --recurse-submodules -j8 https://github.com/jed-frey/build_caffe.git
    cd build_caffe
    
Install Ubuntu 18.04 host packages:

    sudo make env.host
    
Create Python Virtual Environment:

    make env
    
### Build

There are multiple ways to invoke building caffe with this project:

- [GNU Make](https://www.gnu.org/software/make/)
- [CMake](https://cmake.org/) w/[GNU Make](https://www.gnu.org/software/make/)
- [CMake](https://cmake.org/) w/[Ninja](https://ninja-build.org/)

Instructions for each are below. 

Configuration is done in [Makefile.config](Makefile.config). GNU Make alone requires most configuration. CMake should automatically figure out if you have CUDA & cudNN installed.

#### GNU Make

Build with defaults:

  make make.caffe
  
Build without GPU support:

  make make.caffe -j8 USE_CUDNN=0 CPU_ONLY=1
  
Output files are in:

  caffe/distribute/
  
#### CMake w/GNU Make

  make caffe.cmake.make
  cd build.make
  make -j8
  
Files are in the build directory.

#### CMake w/Ninja 
  
Install [Ninja build system](https://ninja-build.org/):

  sudo apt-get install ninja-build

  make caffe.cmake.ninja
  cd build.ninja
  ninja -j8
    
