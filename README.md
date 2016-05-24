**externals-clasp**
===============

Update May 24, 2016:   **This repo now only builds the version of llvm/clang required to build Clasp**

Clasp can be found at:   https://github.com/drmeister/clasp

I am working to eliminate the need for externals-clasp when installing clasp and rely on a standard version of llvm/clang. Currently externals-clasp incorporates a recent patch for llvm/clang.

**Building externals-clasp**

_You need to have gcc 4.8 or higher to build externals-clasp._

To build everything from within the top level directory (externals-clasp/) do the following.

1) If you need to make local build changes, copy local.config.template to local.config

2) Edit local.config and configure it for your system<br>
  The following configuration variables are important:
  
| Variable  |   Description 
| ------------- | --------------|
|**TARGET_OS**                    |Currently either _linux_ or _darwin_|
|**PJOBS**                        |The number of processors you have available to build with|
|**GCC_TOOLCHAIN**                |Important on Linux systems. | 
|                                 |gcc and g++ must be found in $(**GCC_TOOLCHAIN**)/bin/ |
|                                 |On a linux system with an up-to-date (>= 4.8) gcc/g++ you can use /usr |
|**GCC_EXECUTABLE**               |Set this if the gcc you use is NOT found at $(**GCC_TOOLCHAIN**)/bin/gcc |
|**GXX_EXECUTABLE**               |Set this if the g++ you use is NOT found at $(**GCC_TOOLCHAIN**)/bin/g++ |
  
3) Type:  _make_    - this will download llvm/clang, build everything and install it in $(**EXTERNALS_BUILD_TARGET_DIR**)

4) Go to the Clasp library and configure and build it.


The libraries are built and put into the $PREFIX (see local.config) directory

Other useful make targets:<br>
make            - this is the same as:  make clean; make setup; make subAll<br>
make setup      - configures all libraries<br>
make subAll     - makes all libraries<br>
make clean      - Clean out all built files under this directory, but not the $PREFIX target directory.<br>
make llvm-debug - Build the debug version of the LLVM library.
