# externals-clasp
## An auxiliary repo to assist building Clasp on systems that don't provide llvm/clang4.0 through their package manager
===============

Updated June 29, 2017:

**This repo now only builds the version of llvm/clang required to build Clasp**

Use the branch of this repo that matches the branch of Clasp you want to build.

Clasp can be found at:   https://github.com/drmeister/clasp

I am waiting for Apple to upgrade Xcode (currently I use Xcode 8.3.3) to the point where it can build and link Clasp.
Currently externals-clasp incorporates a recent patch for llvm/clang.

**Building externals-clasp**

_You need to have gcc 4.8 or higher to build externals-clasp._

To build everything from within the top level directory (externals-clasp/) do the following.

1. Create the file externals-clasp/local.config (you can copy local.config.template) and add:   export PJOBS=# where # is the maximum number of copies of gcc you can run at once.
2. Type:  _make_    - this will download llvm/clang, build everything.
3. Go to the Clasp library and configure and build it.

Clasp will require other libraries that you can install with your package manager
