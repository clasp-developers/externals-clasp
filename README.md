**externals-clasp**
===============

Update Aug 18, 2016:   **This repo now only builds the version of llvm/clang required to build Clasp**

Clasp can be found at:   https://github.com/drmeister/clasp

I am working to eliminate the need for externals-clasp when installing clasp and rely on a standard version of llvm/clang. Currently externals-clasp incorporates a recent patch for llvm/clang.

**Building externals-clasp**

_You need to have gcc 4.8 or higher to build externals-clasp._

To build everything from within the top level directory (externals-clasp/) do the following.

1. Create the file externals-clasp/local.config (you can copy local.config.template) and add:   export PJOBS=# where # is the maximum number of copies of gcc you can run at once.
2. Type:  _make_    - this will download llvm/clang, build everything.
3. Go to the Clasp library and configure and build it.

Clasp will require other libraries that you can install with your package manager
