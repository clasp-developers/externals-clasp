# Copy local.config.template  to  local.config
# Edit local.config for your local configuration

export EXTERNALS_CLASP_HOME ?= $(shell pwd)
export PJOBS ?= 1

include $(wildcard $(EXTERNALS_CLASP_HOME)/local.config)
ifndef PJOBS
	PJOBS=1
endif

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

export LLVM_VERSION_ID ?= 60
export LLVM_VERSION_ID := $(or  $(filter $(LLVM_VERSION_ID), 60 ), \
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


# llvm version 5.0 Aug 22
#export LLVM_COMMIT = 0bc70c306ccbf483a029a25a6fd851bc332accff
#export CLANG_COMMIT = 8e4862b5be221092291aaf7ea40d72274acb9d96
#export CLANG_TOOLS_EXTRA_COMMIT = e8e7da5b0c98685b16b4a9b601549d18430a3fb2
#export COMPILER_RT = e6bb43d8b68ab16a71b060fc32fcba18d20f8828


export LLVM_COMMIT = 5136df4d089a086b70d452160ad5451861269498
export CLANG_COMMIT = 2f27999df400d17b33cdd412fdd606a88208dfcc 
export CLANG_TOOLS_EXTRA_COMMIT = 0ea5aed4817afebb7fbdea644b723052a0ef370c
export COMPILER_RT = f0835eb0195c477ca9bfb5a782eff9be6cb0bfee

export LLVM_SOURCE_DIR = llvm60

gitllvm:
	./fetch-revision.sh http://llvm.org/git/llvm.git $(LLVM_SOURCE_DIR) $(LLVM_COMMIT)
	./fetch-revision.sh http://llvm.org/git/clang.git $(LLVM_SOURCE_DIR)/tools/clang $(CLANG_COMMIT)
	./fetch-revision.sh http://llvm.org/git/clang-tools-extra.git $(LLVM_SOURCE_DIR)/tools/clang/tools/extras $(CLANG_TOOLS_EXTRA_COMMIT)
#	make llvm_patch

git-compiler-rt:
	./fetch-revision.sh http://github.com/llvm-mirror/compiler-rt.git $(LLVM_SOURCE_DIR)/projects/compiler-rt $(COMPILER_RT)
#	make llvm_patch

llvm_patch:
	(cd $(LLVM_SOURCE_DIR); patch -p1 <../patches/llvm5-orc-notifier.patch)

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
			-DLLVM_ENABLE_DUMP:BOOL=true \
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
			-DLLVM_ENABLE_DUMP:BOOL=true \
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
			-DLLVM_ENABLE_DUMP:BOOL=true \
			-DLLVM_BUILD_TOOLS:BOOL=true \
			-DLLVM_ENABLE_RTTI:BOOL=true \
			-DLLVM_TARGETS_TO_BUILD:STRING="X86" \
			-DCMAKE_CXX_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			-DCMAKE_C_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			.. )

#			-DLLVM_USE_SANITIZER=Address \
#			-DCMAKE_C_COMPILER:STRING=$(GCC_EXECUTABLE) 
#			-DCMAKE_CXX_COMPILER:STRING=$(GXX_EXECUTABLE) 
#		export LINKFLAGS="-L$(PYTHON_LIB)"; 
#darwin
#
# Was Release
llvm-setup-release:
	-mkdir -p $(LLVM_SOURCE_DIR)/build-release
	(cd $(LLVM_SOURCE_DIR)/build-release; \
		export CXXFLAGS=-DLLVM_ENABLE_DUMP; \
		cmake -DCMAKE_BUILD_TYPE:STRING="RelWithDebInfo" \
			-DCMAKE_INSTALL_PREFIX:STRING=$(CLASP_APP_RESOURCES_EXTERNALS_RELEASE_DIR) \
			-DLLVM_BUILD_LLVM_DYLIB:BOOL=false \
			-DLLVM_PARALLEL_COMPILE_JOBS:STRING=$(PJOBS) \
			-DLLVM_ENABLE_CXX11:BOOL=true \
			-DLLVM_ENABLE_DUMP:BOOL=true \
			-DLLVM_BUILD_TOOLS:BOOL=true \
			-DLLVM_ENABLE_RTTI:BOOL=true \
			-DLLVM_TARGETS_TO_BUILD:STRING="X86" \
			-DCMAKE_CXX_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			-DCMAKE_C_FLAGS:STRING="-I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" \
			.. )

#			-DCMAKE_CXX_FLAGS:STRING="-static-libstdc++ -static-libgcc -I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" 
#			-DCMAKE_C_FLAGS:STRING="-static-libgcc -I$(CLASP_APP_RESOURCES_EXTERNALS_COMMON_INCLUDE_DIR)" 


endif

