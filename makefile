# Copy local.config.template  to  local.config
# Edit local.config for your local configuration

export EXTERNALS_CLASP_HOME ?= $(shell pwd)
export PJOBS ?= 1

include $(wildcard $(EXTERNALS_CLASP_HOME)/local.config)

export BUILTIN_INCLUDES ?= /Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1

######################################################################
######################################################################
######################################################################
#
# Shouldn't need changes below here
#
export TARGET_OS ?= $(shell uname)
export TARGET_OS := $(or $(filter $(TARGET_OS), Linux), \
			$(filter $(TARGET_OS), Darwin),\
			$(error Invalid TARGET_OS: $(TARGET_OS)))


TOP = $(shell pwd)
export EXTERNALS_INTERNAL_BUILD_TARGET_DIR = $(TOP)/build

export PATH := $(PATH):$(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)/release/bin:$(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)/common/bin

export LLVM_VERSION_ID ?= 40
export LLVM_VERSION_ID := $(or $(filter $(LLVM_VERSION_ID), 36 ),\
				$(filter $(LLVM_VERSION_ID), 37 ), \
				$(filter $(LLVM_VERSION_ID), 38 ), \
				$(filter $(LLVM_VERSION_ID), 39 ), \
				$(filter $(LLVM_VERSION_ID), 40 ), \
				$(error Invalid LLVM_VERSION_ID: $(LLVM_VERSION_ID) ))
export LLVM_VERSION = llvm$(LLVM_VERSION_ID)

export CLASP_REQUIRES_RTTI=1
export CLASP_APP_RESOURCES_DIR = $(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)
export CLASP_APP_RESOURCES_EXTERNALS_DIR = $(CLASP_APP_RESOURCES_DIR)
export CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/debug
export CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/release
export CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/common
export CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR)/include
export LLVM_RELEASE_TARGET = $(CLASP_APP_RESOURCES_DIR)/llvm/release
export LLVM_DEBUG_TARGET = $(CLASP_APP_RESOURCES_DIR)/llvm/debug
export BJAM = $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/bin/bjam

#
# Needed by gmp fixlibgmpxx.sh scrip
#
export CLASP_APP_RESOURCES_EXTERNALS_COMMON_LIB_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_COMMON_DIR)/lib
CLASP_APP_RESOURCES_EXTERNALS_DEBUG_LIB_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR)/lib
CLASP_APP_RESOURCES_EXTERNALS_RELEASE_LIB_DIR = $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/lib

ifeq ($(TARGET_OS),Darwin)
all:
	make gitllvm
	make gitlibcxx
	make allnoget
endif

ifeq ($(TARGET_OS),Linux)
all:
	make gitllvm
	make allnoget
endif

devshell:
	bash

allnoget:
	make setup
	make subAll
	make subBundle

ifeq ($(GCC_EXECUTABLE),)
export GCC_EXECUTABLE = $(GCC_TOOLCHAIN)/bin/gcc
endif
ifeq ($(GXX_EXECUTABLE),)
export GXX_EXECUTABLE = $(GCC_TOOLCHAIN)/bin/g++
endif


ifeq ($(TARGET_OS),Linux)
CLASP_CXXFLAGS="-std=c++11"
else
CLASP_CXXFLAGS="-std=c++11 -stdlib=libc++"
endif

export REQUIRES_RTTI=$(CLASP_REQUIRES_RTTI)
BOEHM_VERSION=7.2
CC = $(CLASP_CC)

ifneq ($(CXXFLAGS),)
	BOOST_CXXFLAGS="cxxflags=$(CXXFLAGS)"
endif
ifneq ($(LDFLAGS),)
	BOOST_LDFLAGS="linkflags=$(LDFLAGS) -lc++"
endif

LLDB_SOURCE_DIR = lldb

#export LLVM_SOURCE_DIR = llvm$(LLVM_VERSION_ID)


## October 21, 2016
#export LLVM_COMMIT = 13656b412f6d3095c81dd3916e80c5dcf59b05dc
#export CLANG_COMMIT = a663b0aee8fef8552996f03415d3e48ee72e838f
#export CLANG_TOOLS_EXTRA_COMMIT = ce95fe531f66b8335bec3f00358a7048f7ad166b

# December 28, 2016
#export LLVM_COMMIT = c54021df3fd4d71d822b3112cba4e43d94927378
#export CLANG_COMMIT = 715c2ef7122c091bc6f5899a6120deb5390a6fac
#export CLANG_TOOLS_EXTRA_COMMIT = 046e611b264a4e6471f070b1e0ed1360ef02c7d5

# llvm version 4.0  yayyyy!
#  These commit hashes are all for release_40 of each package
export LLVM_COMMIT = 08142cb734b8d2cefec8b1629f6bb170b3f94610
export CLANG_COMMIT = 559aa046fe3260d8640791f2249d7b0d458b5700
export CLANG_TOOLS_EXTRA_COMMIT = a54885bd540dd3c35fc166e3fe4aabe53c8f570b
export COMPILER_RT = 1fdc27db84c9d0d9ae4ae60185629e8c43b4a11c

export LLVM_SOURCE_DIR = llvm40ToT

gitllvm:
	./fetch-revision.sh http://llvm.org/git/llvm.git $(LLVM_SOURCE_DIR) $(LLVM_COMMIT)
	./fetch-revision.sh http://llvm.org/git/clang.git $(LLVM_SOURCE_DIR)/tools/clang $(CLANG_COMMIT)
	./fetch-revision.sh http://llvm.org/git/clang-tools-extra.git $(LLVM_SOURCE_DIR)/tools/clang/tools/extras $(CLANG_TOOLS_EXTRA_COMMIT)

git-compiler-rt:
	./fetch-revision.sh http://github.com/llvm-mirror/compiler-rt.git $(LLVM_SOURCE_DIR)/projects/compiler-rt $(COMPILER_RT)

gitlibcxx:
	-(cd $(LLVM_SOURCE_DIR)/projects; git clone https://github.com/llvm-mirror/libcxx.git libcxx)
#	-(cd $(LLVM_SOURCE_DIR)/projects; git clone https://github.com/llvm-mirror/libcxx.git libcxxabi)

gitllvm-latest:
	git clone http://llvm.org/git/llvm.git $(LLVM_SOURCE_DIR)
	git clone http://llvm.org/git/clang.git $(LLVM_SOURCE_DIR)/tools/clang
	git clone http://llvm.org/git/clang-tools-extra.git $(LLVM_SOURCE_DIR)/tools/clang/tools/extras




all-dependencies:
	make subClean
	make setup
	make subAll


printenv:
	printenv
	echo EXTERNALS_DIR=$(EXTERNALS_DIR)
	echo CLASP_APP_INSTALL_ROOT=$(CLASP_APP_INSTALL_ROOT)
	echo BJAM=$(BJAM)


setup:
	install -d $(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)
	install -d $(CLASP_APP_RESOURCES_DIR)
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_DIR)
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR)
	install -d $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)
	make subClean
	make llvm-setup

build subAll sa:
	make llvm-release

subClean:
	-make llvm-clean


shell:
	bash

clean:
	-rm -rf ./build/*
	make subClean
ifneq ($(EXTERNALS_INTERNAL_BUILD_TARGET_DIR),)
	-(find $(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)/release -type f -print0 | xargs -0 rm -f)
	-(find $(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)/debug -type f -print0 | xargs -0 rm -f)
	-(find $(EXTERNALS_INTERNAL_BUILD_TARGET_DIR)/common -type f -print0 | xargs -0 rm -f)
endif


#
# This removes the llvm source
# and the build directory
#
really-clean:
	make clean
ifneq ($(LLVM_SOURCE_DIR),)
	rm -rf ./$(LLVM_SOURCE_DIR)
endif
ifneq ($(BOEHM_SOURCE_DIR),)
	rm -rf ./$(BOEHM_SOURCE_DIR)
endif

rpath-fix:
	make llvm-rpath-fix

lldb-get:
	svn co http://llvm.org/svn/llvm-project/lldb/trunk lldb

lldb-setup:
	-mkdir -p $(LLVM_SOURCE_DIR)/tools/lldb/build
	(cd $(LLVM_SOURCE_DIR)/tools/lldb/build; \
		CC=clang; CXX=clang++; CXXFLAGS="-I$(HOME)/Development/cando/externals/src/libcxx/include -std=c++11 -stdlib=libc++"\
		../../../configure \
		--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR);)

lldb-build:
	(cd $(LLDB_SOURCE_DIR); xcodebuild -jobs 4 -project lldb.xcodeproj)


llvm-rpath-fix:
	make llvm-rpath-fix-debug
	make llvm-rpath-fix-release

llvm-clean:
	make llvm-clean-release
	make llvm-clean-debug

llvm-clean-release:
	-(rm -rf $(LLVM_SOURCE_DIR)/build-release;)

llvm-clean-debug:
	-(rm -rf $(LLVM_SOURCE_DIR)/build-debug;)


llvm-setup-rtti-test:
	echo REQUIRES_RTTI=$(REQUIRES_RTTI)

llvm-setup:
	echo REQUIRES_RTTI=$(REQUIRES_RTTI)
#	-ln -s ./clang llvm/tools/clang
#-ln -s libcxx llvm/projects
	make llvm-setup-debug
	make llvm-setup-release



llvm-build:
	make llvm-debug
	make llvm-release

llvm-debug:
	(cd $(LLVM_SOURCE_DIR)/build-debug; make -j$(PJOBS) ; make install)
#	make llvm-debug-symlinks

llvm-release:
	(cd $(LLVM_SOURCE_DIR)/build-release; make -j$(PJOBS) ; make install)
#	make llvm-release-symlinks

#Depreciated
llvm-release-symlinks:
ifeq ($(TARGET_OS),Darwin)
	install -d build/release/include/c++
	-ln -s $(BUILTIN_INCLUDES) build/release/include/c++/v1
endif

#Depreciated
llvm-debug-symlinks:
ifeq ($(TARGET_OS),Darwin)
	install -d build/debug/include/c++
	-ln -s $(BUILTIN_INCLUDES) build/debug/include/c++/v1
endif



llvm-doxygen:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-doxygen
	(cd $(LLVM_SOURCE_DIR)/build-doxygen; export REQUIRES_RTTI=1; \
		../configure --enable-doxygen \
		--prefix=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR);)
	(cd $(LLVM_SOURCE_DIR)/build-dbg; export REQUIRES_RTTI=1; make -j$(PJOBS) REQUIRES_RTTI=1; make install) 2>&1 | tee ../logs/_llvm-doxygen.log




clang-setup:
	make clang-setup-release


cmake-setup:
	(cd $(CMAKE_VERSION); ./configure;)

cmake-install:
	(cd $(CMAKE_VERSION); make install; )

subBundle sb:
#	install -d $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/bin
#	install -c jamfile.jam.lib $(CLASP_APP_RESOURCES_EXTERNALS_DIR)/jamfile.jam
#	-install -c $(OPENMM_INSTALL)/lib/lib* $(CLASP_APP_LIB_DIR)
#	-install -c $(OPENMM_INSTALL)/lib/plugins/* $(CLASP_APP_LIB_DIR)/plugins
#	make rpath-fix
# This first link allows LibTooling to find the clang include directories relative to the clasp executable path
#	install -d $(CLASP_APP_BIN_DIR)
#	-ln -s $(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR)/lib $(CLASP_APP_BIN_DIR)/../lib
	@echo IF YOU GOT HERE EVERYTHING IS GOING TO BE JUST FINE!!!
	@echo PROCEED WITH CONFIDENCE TO BUILD CLASP!!!




############################################################
#
# linux linux linux linux linux linux linux linux linux
#
##

ifeq ($(TARGET_OS),Linux)
#
# Set clang-setup --prefix to $(CLASP_APP_RESOURCES_DIR)
#
# This will also move the clang executable into the CLASP_APP_RESOURCES_DIR
# so adjust your path accordingly
#




#linux
llvm-setup-debug:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-debug
	(cd $(LLVM_SOURCE_DIR)/build-debug; \
		cmake -DCMAKE_BUILD_TYPE:STRING="Debug" \
			-DCMAKE_INSTALL_PREFIX:STRING=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR) \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=false \
			-DLLVM_PARALLEL_COMPILE_JOBS:STRING=$(PJOBS) \
			-DLLVM_ENABLE_CXX11:BOOL=true \
			-DLLVM_BUILD_TOOLS:BOOL=true \
			-DLLVM_ENABLE_RTTI:BOOL=true \
			-DLLVM_TARGETS_TO_BUILD:STRING="X86" \
			-DLLVM_BINUTILS_INCDIR=/usr/include \
			-DCMAKE_CXX_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			-DCMAKE_C_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			.. )

#			-DLLVM_USE_SANITIZER=Address \

#			-DCMAKE_C_COMPILER:STRING=$(GCC_EXECUTABLE) 
#			-DCMAKE_CXX_COMPILER:STRING=$(GXX_EXECUTABLE) 
#		export LINKFLAGS="-L$(PYTHON_LIB)"; 
#linux
llvm-setup-release:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-release
	(cd $(LLVM_SOURCE_DIR)/build-release; \
		cmake -DCMAKE_BUILD_TYPE:STRING="Release" \
			-DCMAKE_INSTALL_PREFIX:STRING=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=false \
			-DLLVM_PARALLEL_COMPILE_JOBS:STRING=$(PJOBS) \
			-DLLVM_ENABLE_CXX11:BOOL=true \
			-DLLVM_BUILD_TOOLS:BOOL=true \
			-DLLVM_ENABLE_RTTI:BOOL=true \
			-DLLVM_TARGETS_TO_BUILD:STRING="X86" \
			-DLLVM_BINUTILS_INCDIR=/usr/include \
			-DCMAKE_CXX_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			-DCMAKE_C_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			.. )

#../configure --enable-targets=x86_64  --enable-optimized --enable-assertions \
#		--with-gcc-toolchain=$(GCC_TOOLCHAIN) \
#		--enable-shared=no --enable-cxx11 )

llvm-rpath-fix-debug:
	echo Do nothing


llvm-rpath-fix-release:
	echo Do nothing
endif


############################################################
#
# darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG darwin-CLANG
#
##

ifeq ($(TARGET_OS),Darwin)

export RPATH_RELEASE_FIX = @executable_path/../Resources/externals/release/lib
export RPATH_DEBUG_FIX = @executable_path/../Resources/externals/debug/lib
export RPATH_COMMON_FIX = @executable_path/../Resources/externals/common/lib


#darwin
#			-DCMAKE_C_COMPILER:STRING=$(GCC_EXECUTABLE) 
#			-DCMAKE_CXX_COMPILER:STRING=$(GXX_EXECUTABLE) 
llvm-setup-debug:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-debug
	(cd $(LLVM_SOURCE_DIR)/build-debug; \
		cmake -DCMAKE_BUILD_TYPE:STRING="Debug" \
			-DCMAKE_INSTALL_PREFIX:STRING=$(CLASP_APP_RESOURCES_EXTERNALS_DEBUG_DIR) \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=false \
			-DLLVM_PARALLEL_COMPILE_JOBS:STRING=$(PJOBS) \
			-DLLVM_ENABLE_CXX11:BOOL=true \
			-DLLVM_BUILD_TOOLS:BOOL=true \
			-DLLVM_ENABLE_RTTI:BOOL=true \
			-DLLVM_USE_SANITIZER=Address \
			-DLLVM_TARGETS_TO_BUILD:STRING="X86" \
			-DCMAKE_CXX_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			-DCMAKE_C_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			.. )


#			-DCMAKE_C_COMPILER:STRING=$(GCC_EXECUTABLE) 
#			-DCMAKE_CXX_COMPILER:STRING=$(GXX_EXECUTABLE) 
#		export LINKFLAGS="-L$(PYTHON_LIB)"; 
#darwin
llvm-setup-release:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-release
	(cd $(LLVM_SOURCE_DIR)/build-release; \
		cmake -DCMAKE_BUILD_TYPE:STRING="Release" \
			-DCMAKE_INSTALL_PREFIX:STRING=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=false \
			-DLLVM_PARALLEL_COMPILE_JOBS:STRING=$(PJOBS) \
			-DLLVM_ENABLE_CXX11:BOOL=true \
			-DLLVM_BUILD_TOOLS:BOOL=true \
			-DLLVM_ENABLE_RTTI:BOOL=true \
			-DLLVM_TARGETS_TO_BUILD:STRING="X86" \
			-DCMAKE_CXX_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			-DCMAKE_C_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			.. )

#			-DCMAKE_CXX_FLAGS:STRING="-static-libstdc++ -static-libgcc -I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" 
#			-DCMAKE_C_FLAGS:STRING="-static-libgcc -I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" 


endif

