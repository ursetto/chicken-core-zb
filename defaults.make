# defaults.make - default settings -*- Makefile -*-
#
# Copyright (c) 2008-2011, The Chicken Team
# Copyright (c) 2007, Felix L. Winkelmann
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following
# conditions are met:
#
#   Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#     disclaimer. 
#   Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided with the distribution. 
#   Neither the name of the author nor the names of its contributors may be used to endorse or promote
#     products derived from this software without specific prior written permission. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


# basic parameters

BINARYVERSION = 6
STACKDIRECTION ?= 1
CROSS_CHICKEN ?= 0

ifeq ($(ARCH),x86-64)
NURSERY ?= (256*1024)
else
NURSERY ?= (128*1024)
endif

# directories

SEP ?= /
SRCDIR ?= .$(SEP)
DESTDIR ?=
PREFIX ?= /usr/local
BRANCHNAME ?= $(shell sh $(SRCDIR)identify-branch.sh $(SRCDIR))

BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib
SHAREDIR = $(PREFIX)/share
DATADIR = $(SHAREDIR)/$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
TOPMANDIR = $(SHAREDIR)/man
MANDIR = $(TOPMANDIR)/man1
INCDIR = $(PREFIX)/include/$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
DOCDIR = $(DATADIR)/doc
VARDIR ?= $(LIBDIR)
CHICKENLIBDIR = $(VARDIR)/$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
EGGDIR = $(CHICKENLIBDIR)/$(BINARYVERSION)

ifdef WINDOWS_SHELL
SPREFIX = $(subst /,$(SEP),$(PREFIX))
IBINDIR = $(SPREFIX)$(SEP)bin
ILIBDIR = $(SPREFIX)$(SEP)lib
ISHAREDIR = $(SPREFIX)$(SEP)share
IDATADIR = $(ISHAREDIR)$(SEP)$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
ITOPMANDIR = $(ISHAREDIR)$(SEP)man
IMANDIR = $(ITOPMANDIR)$(SEP)man1
IINCDIR = $(SPREFIX)$(SEP)include$(SEP)$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
IDOCDIR = $(IDATADIR)$(SEP)doc
ICHICKENLIBDIR = $(ILIBDIR)$(SEP)$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
IEGGDIR = $(ICHICKENLIBDIR)$(SEP)$(BINARYVERSION)
else
SPREFIX = $(PREFIX)
IBINDIR = $(BINDIR)
ILIBDIR = $(LIBDIR)
ISHAREDIR = $(SHAREDIR)
IDATADIR = $(DATADIR)
ITOPMANDIR = $(TOPMANDIR)
IMANDIR = $(MANDIR)
IINCDIR = $(INCDIR)
IDOCDIR = $(DOCDIR)
ICHICKENLIBDIR = $(CHICKENLIBDIR)
IEGGDIR = $(EGGDIR)
endif

INSTALL_LIB_NAME = $(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
RUNTIME_LINKER_PATH ?= .

# commands

ifdef HOSTSYSTEM
C_COMPILER ?= $(HOSTSYSTEM)-gcc
CXX_COMPILER ?= $(HOSTSYSTEM)-g++
LIBRARIAN ?= $(HOSTSYSTEM)-ar
else
C_COMPILER ?= gcc
CXX_COMPILER ?= g++
LIBRARIAN ?= ar
endif
ifdef WINDOWS
ifdef HOSTSYSTEM
RC_COMPILER ?= $(HOSTSYSTEM)-windres
else
RC_COMPILER ?= windres
endif
endif
LINKER ?= $(C_COMPILER)
ifdef WINDOWS_SHELL
REMOVE_COMMAND ?= del
else
REMOVE_COMMAND ?= rm
endif
ASSEMBLER ?= $(C_COMPILER)
ifdef WINDOWS_SHELL
INSTALL_PROGRAM ?= xcopy
MAKEDIR_COMMAND ?= -mkdir
else
INSTALL_PROGRAM ?= install
MAKEDIR_COMMAND ?= mkdir
endif
POSTINSTALL_STATIC_LIBRARY ?= true
POSTINSTALL_PROGRAM ?= true

# target variables

ifdef TARGETSYSTEM
TARGET_C_COMPILER ?= $(TARGETSYSTEM)-$(C_COMPILER)
TARGET_CXX_COMPILER ?= $(TARGETSYSTEM)-$(CXX_COMPILER)
TARGET_RC_COMPILER ?= $(TARGETSYSTEM)-$(RC_COMPILER)
else
TARGET_C_COMPILER ?= $(C_COMPILER)
TARGET_CXX_COMPILER ?= $(CXX_COMPILER)
TARGET_RC_COMPILER ?= $(RC_COMPILER)
endif

TARGET_C_COMPILER_OPTIONS ?= $(C_COMPILER_OPTIONS)
TARGET_C_COMPILER_OPTIMIZATION_OPTIONS ?= $(C_COMPILER_OPTIMIZATION_OPTIONS)
TARGET_PREFIX ?= $(PREFIX)
TARGET_RUN_PREFIX ?= $(TARGET_PREFIX)
TARGET_LIBRARIES ?= $(LIBRARIES)
TARGET_LINKER_OPTIONS ?= $(LINKER_OPTIONS)
TARGET_LINKER_OPTIMIZATION_OPTIONS ?= $(LINKER_OPTIMIZATION_OPTIONS)
TARGET_FEATURES ?=
TARGET_LIB_NAME ?= chicken

ifneq ($(TARGET_C_COMPILER),$(C_COMPILER))
CROSS_CHICKEN = 1
else
CROSS_CHICKEN = 0
endif


# options

INCLUDES ?= -I. -I$(SRCDIR)
C_COMPILER_COMPILE_OPTION ?= -c
C_COMPILER_OUTPUT_OPTION ?= -o
C_COMPILER_OUTPUT ?= $(C_COMPILER_OUTPUT_OPTION) $@

ifndef NOPTABLES
C_COMPILER_OPTIONS += -DC_ENABLE_PTABLES
endif

ifdef DEBUGBUILD
ifeq ($(C_COMPILER),gcc)
C_COMPILER_OPTIMIZATION_OPTIONS ?= -g -Wall -Wno-unused
endif
endif
C_COMPILER_BUILD_RUNTIME_OPTIONS ?= -DC_BUILDING_LIBCHICKEN
C_COMPILER_SHARED_OPTIONS ?= -fPIC -DPIC
LINKER_EXECUTABLE_OPTIONS ?= -L.
LINKER_STATIC_OPTIONS ?= $(LINKER_EXECUTABLE_OPTIONS)
LINKER_OUTPUT_OPTION ?= -o
LINKER_OUTPUT ?= $(LINKER_OUTPUT_OPTION) $@
LINKER_LIBRARY_OPTION ?= -l
ifdef STATICBUILD
LINKER_LIBRARY_PREFIX ?= lib
LINKER_LIBRARY_SUFFIX ?= .a
else
LINKER_LIBRARY_PREFIX ?= -l
LINKER_LIBRARY_SUFFIX ?= 
endif
LINKER_LINK_SHARED_LIBRARY_OPTIONS ?= -shared
LINKER_LINK_SHARED_DLOADABLE_OPTIONS ?= -shared -L.
LIBRARIAN_OPTIONS ?= cru
LIBRARIAN_OUTPUT_OPTION ?=
LIBRARIAN_OUTPUT ?= $(LIBRARIAN_OUTPUT_OPTION) $@
LIBRARIES ?= -lm
ifdef WINDOWS_SHELL
REMOVE_COMMAND_OPTIONS ?= /f /q
REMOVE_COMMAND_RECURSIVE_OPTIONS ?= /f /s /q
MAKE_WRITABLE_COMMAND ?= rem
else
REMOVE_COMMAND_OPTIONS ?= -f
REMOVE_COMMAND_RECURSIVE_OPTIONS ?= -fr
MAKE_WRITABLE_COMMAND ?= chmod 0755
endif
ifdef WINDOWS_SHELL
INSTALL_PROGRAM_SHARED_LIBRARY_OPTIONS ?= /Y
INSTALL_PROGRAM_STATIC_LIBRARY_OPTIONS ?= /Y
INSTALL_PROGRAM_EXECUTABLE_OPTIONS ?= /Y
INSTALL_PROGRAM_FILE_OPTIONS ?= /Y
else
INSTALL_PROGRAM_SHARED_LIBRARY_OPTIONS ?= -m755
INSTALL_PROGRAM_STATIC_LIBRARY_OPTIONS ?= -m644
INSTALL_PROGRAM_EXECUTABLE_OPTIONS ?= -m755
INSTALL_PROGRAM_FILE_OPTIONS ?= -m644
MAKEDIR_COMMAND_OPTIONS ?= -p
endif
ASSEMBLER_OPTIONS ?= $(C_COMPILER_OPTIONS)
ASSEMBLER_OUTPUT_OPTION ?= -o
ASSEMBLER_OUTPUT ?= $(ASSEMBLER_OUTPUT_OPTION) $@
ASSEMBLER_COMPILE_OPTION ?= -c
ifdef STATICBUILD
PRIMARY_LIBCHICKEN ?= lib$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)$(A)
else
ifeq ($(PLATFORM),cygwin)
PRIMARY_LIBCHICKEN = cyg$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)-0.dll
LIBCHICKEN_SO_FILE = cyg$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)-0.dll
else
PRIMARY_LIBCHICKEN ?= lib$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)$(SO)
LIBCHICKEN_SO_FILE ?= lib$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)$(SO)
endif
endif
LIBCHICKEN_SO_LIBRARIES ?= $(LIBRARIES)

# other settings

HOSTNAME ?= $(shell hostname)

ifdef WINDOWS_SHELL
BUILD_TIME ?= $(shell date /t)
COPY_COMMAND = copy /Y
else
BUILD_TIME ?= $(shell date +%Y-%m-%d)
UNAME_SYS ?= $(shell uname)
COPY_COMMAND = cp
endif
BUILD_TAG ?= compiled $(BUILD_TIME) on $(HOSTNAME) ($(UNAME_SYS))
BUILD_ID ?= $(shell sh $(SRCDIR)identify-revision.sh $(SRCDIR))
COPYMANY =


# file extensions

O ?= .o
A ?= .a
# EXE ?=
SO ?= .so
ASM ?= .S

# special files

POSIXFILE ?= posixunix
CHICKEN_CONFIG_H = chicken-config.h

ifneq ($(ARCH),)
HACKED_APPLY ?= 1
APPLY_HACK_SRC ?= apply-hack.$(ARCH)$(ASM)
APPLY_HACK_OBJECT ?= apply-hack.$(ARCH)$(O)
endif

ifeq ($(HACKED_APPLY),)
APPLY_HACK_OBJECT =
endif

# bootstrapping compiler

CHICKEN ?= chicken$(EXE)

# interpreter for scripts

CSI ?= csi$(EXE)

# Scheme compiler flags

CHICKEN_OPTIONS = -optimize-level 2 -include-path . -include-path $(SRCDIR) -inline -ignore-repository -feature chicken-bootstrap
ifdef DEBUGBUILD
CHICKEN_OPTIONS += -feature debugbuild -scrutinize -types $(SRCDIR)types.db
else
CHICKEN_OPTIONS += -no-warnings
endif
CHICKEN_OPTIONS += $(EXTRA_CHICKEN_OPTIONS)
CHICKEN_LIBRARY_OPTIONS = $(CHICKEN_OPTIONS) -explicit-use -no-trace
CHICKEN_PROGRAM_OPTIONS = $(CHICKEN_OPTIONS) -no-lambda-info -local
CHICKEN_COMPILER_OPTIONS = $(CHICKEN_PROGRAM_OPTIONS) -extend private-namespace.scm
CHICKEN_DYNAMIC_OPTIONS = $(CHICKEN_OPTIONS) -feature chicken-compile-shared -dynamic
CHICKEN_IMPORT_LIBRARY_OPTIONS = $(CHICKEN_DYNAMIC_OPTIONS) -no-trace

ifndef DEBUGBUILD
CHICKEN_PROGRAM_OPTIONS += -no-trace
CHICKEN_COMPILER_OPTIONS += -no-trace
endif

# targets

CHICKEN_PROGRAM = $(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)
CSC_PROGRAM = $(PROGRAM_PREFIX)csc$(PROGRAM_SUFFIX)
CSI_PROGRAM = $(PROGRAM_PREFIX)csi$(PROGRAM_SUFFIX)
CHICKEN_PROFILE_PROGRAM = $(PROGRAM_PREFIX)chicken-profile$(PROGRAM_SUFFIX)
CHICKEN_INSTALL_PROGRAM = $(PROGRAM_PREFIX)chicken-install$(PROGRAM_SUFFIX)
CHICKEN_UNINSTALL_PROGRAM = $(PROGRAM_PREFIX)chicken-uninstall$(PROGRAM_SUFFIX)
CHICKEN_STATUS_PROGRAM = $(PROGRAM_PREFIX)chicken-status$(PROGRAM_SUFFIX)
CHICKEN_BUG_PROGRAM = $(PROGRAM_PREFIX)chicken-bug$(PROGRAM_SUFFIX)
IMPORT_LIBRARIES = chicken lolevel srfi-1 srfi-4 data-structures ports files posix srfi-13 srfi-69 extras srfi-14 tcp foreign scheme srfi-18 utils csi irregex
IMPORT_LIBRARIES += setup-api setup-download
SCRUTINIZED_LIBRARIES = library eval data-structures ports files extras lolevel utils tcp srfi-1 srfi-4 srfi-13 srfi-14 srfi-18 srfi-69 $(POSIXFILE) irregex scheduler profiler stub expand modules chicken-syntax chicken-ffi-syntax

ifdef STATICBUILD
CHICKEN_STATIC_EXECUTABLE = $(CHICKEN_PROGRAM)$(EXE)
CSI_STATIC_EXECUTABLE = $(CSI_PROGRAM)$(EXE)
CHICKEN_SHARED_EXECUTABLE = $(CHICKEN_PROGRAM)-shared$(EXE)
CSI_SHARED_EXECUTABLE = $(CSI_PROGRAM)-shared$(EXE)
TARGETLIBS ?= lib$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)$(A)
TARGETS += $(TARGETLIBS) $(CHICKEN_STATIC_EXECUTABLE) \
	$(CSI_STATIC_EXECUTABLE) $(CHICKEN_PROFILE_PROGRAM)$(EXE) \
	$(CSC_PROGRAM)$(EXE) \
	$(CHICKEN_BUG_PROGRAM)$(EXE)
else
CHICKEN_STATIC_EXECUTABLE = $(CHICKEN_PROGRAM)-static$(EXE)
CSI_STATIC_EXECUTABLE = $(CSI_PROGRAM)-static$(EXE)
CHICKEN_SHARED_EXECUTABLE = $(CHICKEN_PROGRAM)$(EXE)
CSI_SHARED_EXECUTABLE = $(CSI_PROGRAM)$(EXE)
TARGETLIBS ?= lib$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)$(A) $(LIBCHICKEN_SO_FILE)
TARGETS += $(TARGETLIBS) $(CHICKEN_SHARED_EXECUTABLE) \
	$(CSI_SHARED_EXECUTABLE) $(CHICKEN_PROFILE_PROGRAM)$(EXE) \
	$(CSC_PROGRAM)$(EXE) $(CHICKEN_INSTALL_PROGRAM)$(EXE) $(CHICKEN_UNINSTALL_PROGRAM)$(EXE) \
	$(CHICKEN_STATUS_PROGRAM)$(EXE) setup-download.so setup-api.so \
	$(CHICKEN_BUG_PROGRAM)$(EXE) \
	$(IMPORT_LIBRARIES:%=%.import.so)
endif
ifdef WINDOWS
TARGETS += chicken.rc$(O)
endif

ifeq ($(HEAD),)
HEAD = HEAD
endif


# main rule

.PHONY: all

all: $(TARGETS)

# generic part of chicken-config.h

ifndef CUSTOM_CHICKEN_DEFAULTS
chicken-defaults.h:
ifdef OPTIMIZE_FOR_SPEED
	echo "/* (this build was optimized for speed) */" >$@
endif
	echo "#define C_CHICKEN_PROGRAM \"$(CHICKEN_PROGRAM)$(EXE)\"" >>$@
	echo "#ifndef C_INSTALL_CC" >>$@
	echo "# define C_INSTALL_CC \"$(C_COMPILER)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_CXX" >>$@
	echo "# define C_INSTALL_CXX \"$(CXX_COMPILER)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_RC_COMPILER" >>$@
	echo "# define C_INSTALL_RC_COMPILER \"$(RC_COMPILER)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_CFLAGS" >>$@
	echo "# define C_INSTALL_CFLAGS \"$(C_COMPILER_OPTIONS) $(C_COMPILER_OPTIMIZATION_OPTIONS)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_LDFLAGS" >>$@
	echo "# define C_INSTALL_LDFLAGS \"$(LINKER_OPTIONS) $(LINKER_OPTIMIZATION_OPTIONS)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_PREFIX" >>$@
	echo "# define C_INSTALL_PREFIX \"$(PREFIX)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_SHARE_HOME" >>$@
	echo "# define C_INSTALL_SHARE_HOME \"$(DATADIR)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_BIN_HOME" >>$@
	echo "# define C_INSTALL_BIN_HOME \"$(BINDIR)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_EGG_HOME" >>$@
	echo "# define C_INSTALL_EGG_HOME \"$(EGGDIR)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_LIB_HOME" >>$@
	echo "# define C_INSTALL_LIB_HOME \"$(LIBDIR)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_LIB_NAME" >>$@
	echo "# define C_INSTALL_LIB_NAME \"$(INSTALL_LIB_NAME)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_STATIC_LIB_HOME" >>$@
	echo "# define C_INSTALL_STATIC_LIB_HOME \"$(LIBDIR)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_INCLUDE_HOME" >>$@
	echo "# define C_INSTALL_INCLUDE_HOME \"$(INCDIR)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_MORE_LIBS" >>$@
	echo "# define C_INSTALL_MORE_LIBS \"$(LIBRARIES)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_INSTALL_MORE_STATIC_LIBS" >>$@
	echo "# define C_INSTALL_MORE_STATIC_LIBS \"$(LIBRARIES)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_DEFAULT_TARGET_STACK_SIZE" >>$@
	echo "# define C_DEFAULT_TARGET_STACK_SIZE $(NURSERY)" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_DEFAULT_TARGET_HEAP_SIZE" >>$@
	echo "# define C_DEFAULT_TARGET_HEAP_SIZE 0" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_STACK_GROWS_DOWNWARD" >>$@
	echo "# define C_STACK_GROWS_DOWNWARD $(STACKDIRECTION)" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_MORE_LIBS" >>$@
	echo "# define C_TARGET_MORE_LIBS \"$(TARGET_LIBRARIES)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_MORE_STATIC_LIBS" >>$@
	echo "# define C_TARGET_MORE_STATIC_LIBS \"$(TARGET_LIBRARIES)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_CC" >>$@
	echo "# define C_TARGET_CC \"$(TARGET_C_COMPILER)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_CXX" >>$@
	echo "# define C_TARGET_CXX \"$(TARGET_CXX_COMPILER)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_RC_COMPILER" >>$@
	echo "# define C_TARGET_RC_COMPILER \"$(TARGET_RC_COMPILER)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_CFLAGS" >>$@
	echo "# define C_TARGET_CFLAGS \"$(TARGET_C_COMPILER_OPTIONS) $(TARGET_C_COMPILER_OPTIMIZATION_OPTIONS)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_LDFLAGS" >>$@
	echo "# define C_TARGET_LDFLAGS \"$(TARGET_LINKER_OPTIONS) $(TARGET_LINKER_OPTIMIZATION_OPTIONS)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_FEATURES" >>$@
	echo "# define C_TARGET_FEATURES \"$(TARGET_FEATURES)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CROSS_CHICKEN" >>$@
	echo "# define C_CROSS_CHICKEN $(CROSS_CHICKEN)" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_PREFIX" >>$@
	echo "# define C_TARGET_PREFIX \"$(TARGET_PREFIX)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_BIN_HOME" >>$@
	echo "# define C_TARGET_BIN_HOME \"$(TARGET_PREFIX)/bin\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_LIB_HOME" >>$@
	echo "# define C_TARGET_LIB_HOME \"$(TARGET_PREFIX)/lib\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_LIB_NAME" >>$@
	echo "# define C_TARGET_LIB_NAME \"$(TARGET_LIB_NAME)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_RUN_LIB_HOME" >>$@
	echo "# define C_TARGET_RUN_LIB_HOME \"$(TARGET_RUN_PREFIX)/lib\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_SHARE_HOME" >>$@
	echo "# define C_TARGET_SHARE_HOME \"$(TARGET_PREFIX)/share\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_INCLUDE_HOME" >>$@
	echo "# define C_TARGET_INCLUDE_HOME \"$(TARGET_PREFIX)/include/$(PROGRAM_PREFIX)chicken$(PROGRAM_SUFFIX)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_TARGET_STATIC_LIB_HOME" >>$@
	echo "# define C_TARGET_STATIC_LIB_HOME \"$(TARGET_PREFIX)/lib\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CHICKEN_PROGRAM" >>$@
	echo "# define C_CHICKEN_PROGRAM \"$(CHICKEN_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CSC_PROGRAM" >>$@
	echo "# define C_CSC_PROGRAM \"$(CSC_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CSI_PROGRAM" >>$@
	echo "# define C_CSI_PROGRAM \"$(CSI_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CHICKEN_BUG_PROGRAM" >>$@
	echo "# define C_CHICKEN_BUG_PROGRAM \"$(CHICKEN_BUG_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CHICKEN_INSTALL_PROGRAM" >>$@
	echo "# define C_CHICKEN_INSTALL_PROGRAM \"$(CHICKEN_INSTALL_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CHICKEN_UNINSTALL_PROGRAM" >>$@
	echo "# define C_CHICKEN_UNINSTALL_PROGRAM \"$(CHICKEN_UNINSTALL_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_CHICKEN_STATUS_PROGRAM" >>$@
	echo "# define C_CHICKEN_STATUS_PROGRAM \"$(CHICKEN_STATUS_PROGRAM)\"" >>$@
	echo "#endif" >>$@
	echo "#ifndef C_WINDOWS_SHELL" >>$@
ifdef WINDOWS_SHELL
	echo "# define C_WINDOWS_SHELL 1" >>$@
else
	echo "# define C_WINDOWS_SHELL 0" >>$@
endif
	echo "#endif" >>$@
	echo "#ifndef C_BINARY_VERSION" >>$@
	echo "# define C_BINARY_VERSION $(BINARYVERSION)" >>$@
	echo "#endif" >>$@
	echo "/* END OF FILE */" >>$@
endif

ifndef CUSTOM_RC_FILE
chicken-install.rc:
	echo '/* GENERATED */' >$@
	echo '1 24 MOVEABLE PURE' >>$@
	echo 'BEGIN' >>$@
	echo '  "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>\r\n"' >>$@
	echo '  "<assembly xmlns=""urn:schemas-microsoft-com:asm.v1"" manifestVersion=""1.0"">\r\n"' >>$@
	echo '  "  <assemblyIdentity version=""1.0.0.0"" processorArchitecture=""*"" name=""chicken-install"" type=""win32""/>\r\n"' >>$@
	echo '  "  <ms_asmv2:trustInfo xmlns:ms_asmv2=""urn:schemas-microsoft-com:asm.v2"">\r\n"' >>$@
	echo '  "    <ms_asmv2:security>\r\n"' >>$@
	echo '  "      <ms_asmv2:requestedPrivileges>\r\n"' >>$@
	echo '  "        <ms_asmv2:requestedExecutionLevel level=""asInvoker"" uiAccess=""false""/>\r\n"' >>$@
	echo '  "      </ms_asmv2:requestedPrivileges>\r\n"' >>$@
	echo '  "    </ms_asmv2:security>\r\n"' >>$@
	echo '  "  </ms_asmv2:trustInfo>\r\n"' >>$@
	echo '  "</assembly>\r\n"' >>$@
	echo 'END' >>$@
	echo '/* END OF FILE */' >>$@

chicken-uninstall.rc:
	echo '/* GENERATED */' >$@
	echo '1 24 MOVEABLE PURE' >>$@
	echo 'BEGIN' >>$@
	echo '  "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>\r\n"' >>$@
	echo '  "<assembly xmlns=""urn:schemas-microsoft-com:asm.v1"" manifestVersion=""1.0"">\r\n"' >>$@
	echo '  "  <assemblyIdentity version=""1.0.0.0"" processorArchitecture=""*"" name=""$(PROGRAM_PREFIX)chicken-install$(PROGRAM_SUFFIX)"" type=""win32""/>\r\n"' >>$@
	echo '  "  <ms_asmv2:trustInfo xmlns:ms_asmv2=""urn:schemas-microsoft-com:asm.v2"">\r\n"' >>$@
	echo '  "    <ms_asmv2:security>\r\n"' >>$@
	echo '  "      <ms_asmv2:requestedPrivileges>\r\n"' >>$@
	echo '  "        <ms_asmv2:requestedExecutionLevel level=""asInvoker"" uiAccess=""false""/>\r\n"' >>$@
	echo '  "      </ms_asmv2:requestedPrivileges>\r\n"' >>$@
	echo '  "    </ms_asmv2:security>\r\n"' >>$@
	echo '  "  </ms_asmv2:trustInfo>\r\n"' >>$@
	echo '  "</assembly>\r\n"' >>$@
	echo 'END' >>$@
	echo '/* END OF FILE */' >>$@
endif
