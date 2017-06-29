# externals-clasp
An auxiliary repo to assist building Clasp on OS X and Linux systems that don't provide llvm/clang4.0
===============

Updated June 29, 2017:

**This repo builds the version of llvm/clang required to build Clasp**

Clasp can be found at:   https://github.com/drmeister/clasp

### Is this needed on OS X?

**Answer:** Maybe

As of the date above I am developing Clasp on OS X 10.12.5
I have Xcode 8.3.3 with command line tools installed.
I have not recently tried to build Clasp with the stock Xcode 8.3.3 - I use externals-clasp because it works fine on OS X and because I can use externals-clasp to build various debugging versions of llvm/clang

### Is externals-clasp needed on Linux?

**Answer:** If your package manager provides llvm/clang-4.0 use those - they are more convenient.

Otherwise feel free to use externals-clasp

### Building externals-clasp

_You need to have gcc 4.8 or higher to build externals-clasp._

To build everything from within the top level directory (externals-clasp/) do the following.

1. Create the file externals-clasp/local.config (you can copy local.config.template) and add:   export PJOBS=# where # is the maximum number of copies of gcc you can run at once.
2. Type:  _make_    - this will download llvm/clang, and build everything.
3. Go to the Clasp library and configure and build it.  You will need to edit the wscript.config file to point it at your /path/to/externals-clasp/build/release/bin/llvm-config
