# rules.make - basic build rules -*- Makefile -*-
#
# Copyright (c) 2008-2010, The Chicken Team
# Copyright (c) 2000-2007, Felix L. Winkelmann
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

VPATH=$(SRCDIR)

# Clear Make's default rules for C programs
%.o : %.c
%: %.o

# object files

IMPORT_LIB_OBJECTS_1 = \
	chicken lolevel srfi-1  srfi-4 data-structures \
	ports files posix srfi-13 srfi-69 extras \
	regex irregex srfi-14 tcp foreign scheme \
	csi srfi-18 utils

SETUP_API_IMPORT_LIB_OBJECTS_1 = \
	setup-api setup-download

SETUP_API_OBJECTS = $(SETUP_API_IMPORT_LIB_OBJECTS)

LIBCHICKEN_OBJECTS_1 = \
       library eval data-structures ports files extras lolevel utils tcp srfi-1 srfi-4 srfi-13 \
       srfi-14 srfi-18 srfi-69 $(POSIXFILE) regex scheduler \
       profiler stub expand chicken-syntax chicken-ffi-syntax runtime
LIBCHICKEN_SHARED_OBJECTS = $(LIBCHICKEN_OBJECTS_1:=$(O))
LIBCHICKEN_STATIC_OBJECTS = $(LIBCHICKEN_OBJECTS_1:=-static$(O))

COMPILER_OBJECTS_1 = \
       chicken batch-driver compiler optimizer compiler-syntax scrutinizer unboxing support \
       c-platform c-backend
COMPILER_OBJECTS        = $(COMPILER_OBJECTS_1:=$(O))
COMPILER_STATIC_OBJECTS = $(COMPILER_OBJECTS_1:=-static$(O))

# "Utility programs" is arbitrary. It includes anything but the chicken binary
UTILITY_PROGRAM_OBJECTS_1 = \
	csc csi chicken-install chicken-uninstall chicken-status chicken-profile

ALWAYS_STATIC_UTILITY_PROGRAM_OBJECTS_1 = \
	chicken-bug csi-static

# library objects

define declare-shared-library-object # reused in the setup API bit
$(1)$(O): $(1).c chicken.h $$(CHICKEN_CONFIG_H)
	$$(C_COMPILER) $$(C_COMPILER_OPTIONS) $$(INCLUDES) \
	  $$(C_COMPILER_COMPILE_OPTION) $$(C_COMPILER_OPTIMIZATION_OPTIONS) $$(C_COMPILER_SHARED_OPTIONS) \
	  $$(C_COMPILER_BUILD_RUNTIME_OPTIONS) $$< $$(C_COMPILER_OUTPUT)
endef

declare-libchicken-object = $(declare-shared-library-object)

$(foreach obj, $(LIBCHICKEN_OBJECTS_1),\
          $(eval $(call declare-libchicken-object,$(obj))))

# static versions

define declare-static-library-object
$(1)-static$(O): $(1).c chicken.h $$(CHICKEN_CONFIG_H)
	$$(C_COMPILER) $$(C_COMPILER_OPTIONS) $$(INCLUDES) \
	  $$(C_COMPILER_COMPILE_OPTION) $$(C_COMPILER_OPTIMIZATION_OPTIONS) \
	  $$(C_COMPILER_STATIC_OPTIONS) \
	  $$(C_COMPILER_BUILD_RUNTIME_OPTIONS) $$< $$(C_COMPILER_OUTPUT)
endef

declare-static-libchicken-object = $(declare-static-library-object)

$(foreach obj, $(LIBCHICKEN_OBJECTS_1),\
          $(eval $(call declare-static-libchicken-object,$(obj))))

# import library objects

define declare-import-lib-object
$(1).import$(O): $(1).import.c chicken.h $$(CHICKEN_CONFIG_H)
	$$(HOST_C_COMPILER) $$(HOST_C_COMPILER_OPTIONS) $$(HOST_C_COMPILER_PTABLES_OPTIONS) $$(INCLUDES) -DC_SHARED \
	  $$(HOST_C_COMPILER_COMPILE_OPTION) $$(HOST_C_COMPILER_OPTIMIZATION_OPTIONS) $$(HOST_C_COMPILER_SHARED_OPTIONS) \
	  $$(HOST_C_COMPILER_BUILD_RUNTIME_OPTIONS) $$< $$(HOST_C_COMPILER_OUTPUT)
endef

$(foreach obj,$(IMPORT_LIB_OBJECTS_1),\
          $(eval $(call declare-import-lib-object,$(obj))))

# setup extension objects

declare-setup-api-object = $(declare-shared-library-object)

$(foreach obj,$(SETUP_API_OBJECTS_1),\
          $(eval $(call declare-setup-api-object,$(obj))))


declare-setup-api-import-lib-object = $(declare-import-lib-object)

$(foreach obj,$(SETUP_API_IMPORT_LIB_OBJECTS_1),\
          $(eval $(call declare-setup-api-import-lib-object,$(obj))))

# compiler objects

define declare-compiler-object
$(1)$(O): $(1).c chicken.h $$(CHICKEN_CONFIG_H)
	$$(C_COMPILER) $$(C_COMPILER_OPTIONS) $$(INCLUDES) \
	  $$(C_COMPILER_COMPILE_OPTION) $$(C_COMPILER_OPTIMIZATION_OPTIONS) $$(C_COMPILER_SHARED_OPTIONS) $$< \
	  $$(C_COMPILER_OUTPUT)
endef

$(foreach obj, $(COMPILER_OBJECTS_1),\
          $(eval $(call declare-compiler-object,$(obj))))

# static compiler objects

define declare-static-compiler-object
$(1)-static$(O): $(1).c chicken.h $$(CHICKEN_CONFIG_H)
	$$(C_COMPILER) $$(C_COMPILER_OPTIONS) $$(INCLUDES) \
	  $$(C_COMPILER_STATIC_OPTIONS) \
	  $$(C_COMPILER_COMPILE_OPTION) $$(C_COMPILER_OPTIMIZATION_OPTIONS) $$< $$(C_COMPILER_OUTPUT)
endef

$(foreach obj, $(COMPILER_OBJECTS_1),\
          $(eval $(call declare-static-compiler-object,$(obj))))

# assembler objects

ifneq ($(HACKED_APPLY),)
$(APPLY_HACK_OBJECT): $(SRCDIR)apply-hack.$(ARCH)$(ASM)
	$(ASSEMBLER) $(ASSEMBLER_OPTIONS) $(ASSEMBLER_COMPILE_OPTION) $< $(ASSEMBLER_OUTPUT)
endif

# program objects

define declare-utility-program-object
$(1)$(O): $(1).c chicken.h $$(CHICKEN_CONFIG_H)
	$$(C_COMPILER) $$(C_COMPILER_OPTIONS) $$(INCLUDES) $$(C_COMPILER_SHARED_OPTIONS) \
	  $$(C_COMPILER_COMPILE_OPTION) $$(C_COMPILER_OPTIMIZATION_OPTIONS) $$< $$(C_COMPILER_OUTPUT)
endef

$(foreach obj, $(UTILITY_PROGRAM_OBJECTS_1),\
          $(eval $(call declare-utility-program-object,$(obj))))


# static program objects

define declare-always-static-utility-program-object
$(1)$(O): $(1).c chicken.h $$(CHICKEN_CONFIG_H)
	$$(C_COMPILER) $$(C_COMPILER_OPTIONS) $$(INCLUDES) \
	  $$(C_COMPILER_STATIC_OPTIONS) \
	  $$(C_COMPILER_COMPILE_OPTION) $$(C_COMPILER_OPTIMIZATION_OPTIONS) $$< $$(C_COMPILER_OUTPUT)
endef

$(foreach obj, $(ALWAYS_STATIC_UTILITY_PROGRAM_OBJECTS_1),\
          $(eval $(call declare-always-static-utility-program-object,$(obj))))

# resource objects

.SUFFIXES: .rc

%.rc.o: %.rc
	$(RC_COMPILER) $< $@

# libraries

.PHONY: libs

libs: $(TARGETLIBS)

libchicken$(SO): $(LIBCHICKEN_SHARED_OBJECTS) $(APPLY_HACK_OBJECT)
	$(LINKER) $(LINKER_OPTIONS) $(LINKER_LINK_SHARED_LIBRARY_OPTIONS) $(LIBCHICKEN_SO_LINKER_OPTIONS) \
	  $(LINKER_OUTPUT) $^ $(LIBCHICKEN_SO_LIBRARIES)
ifdef USES_SONAME
	ln -sf $(LIBCHICKEN_SO_FILE) $(LIBCHICKEN_SO_FILE).$(BINARYVERSION)
endif

cygchicken-0.dll: $(LIBCHICKEN_SHARED_OBJECTS) $(APPLY_HACK_OBJECT)
	gcc -shared -o $(LIBCHICKEN_SO_FILE) -Wl,--dll -Wl,--add-stdcall-alias \
	    -Wl,--enable-stdcall-fixup -Wl,--warn-unresolved-symbols \
	    -Wl,--dll-search-prefix=cyg -Wl,--allow-multiple-definition \
	    -Wl,--allow-shlib-undefined -Wl,--export-dynamic \
	    -Wl,--out-implib=libchicken.dll.a -Wl,--export-all-symbols \
	    -Wl,--enable-auto-import \
	    -Wl,--whole-archive $(LIBCHICKEN_SHARED_OBJECTS) $(APPLY_HACK_OBJECT) \
	    -Wl,--no-whole-archive $(LIBCHICKEN_SO_LIBRARIES)

libchicken$(A): $(APPLY_HACK_OBJECT) $(LIBCHICKEN_STATIC_OBJECTS)
	$(LIBRARIAN) $(LIBRARIAN_OPTIONS) $(LIBRARIAN_OUTPUT) $^

# import libraries and extensions

.SUFFIXES: .so

%.so: %.o
	$(HOST_LINKER) $(HOST_LINKER_OPTIONS) $(HOST_LINKER_LINK_SHARED_DLOADABLE_OPTIONS) $^ $(HOST_LINKER_OUTPUT_OPTION) $@ \
	  $(HOST_LINKER_LIBRARY_PREFIX)chicken$(HOST_LINKER_LIBRARY_SUFFIX) \
	  $(HOST_LIBRARIES)

# executables

$(CHICKEN_SHARED_EXECUTABLE): $(COMPILER_OBJECTS) $(PRIMARY_LIBCHICKEN)
	$(LINKER) $(LINKER_OPTIONS) $(LINKER_EXECUTABLE_OPTIONS) $(COMPILER_OBJECTS) $(LINKER_OUTPUT) \
          $(LINKER_LIBRARY_PREFIX)chicken$(LINKER_LIBRARY_SUFFIX) $(LINKER_LINK_SHARED_PROGRAM_OPTIONS) $(LIBRARIES)

define declare-program-from-object
$(1)-RC_FILE = $(if $(and $(RC_COMPILER),$(3)),$(2).rc$(O))

$(1): $(2)$(O) $$(PRIMARY_LIBCHICKEN) $$($(1)-RC_FILE)
	$$(LINKER) $$(LINKER_OPTIONS) $$(LINKER_EXECUTABLE_OPTIONS) $$< \
          $$($(1)-RC_FILE) $$(LINKER_OUTPUT) \
          $$(LINKER_LIBRARY_PREFIX)chicken$$(LINKER_LIBRARY_SUFFIX) \
          $$(LINKER_LINK_SHARED_PROGRAM_OPTIONS) $$(LIBRARIES)
endef

$(eval $(call declare-program-from-object,$(CSI_SHARED_EXECUTABLE),csi))
$(eval $(call declare-program-from-object,$(CHICKEN_INSTALL_PROGRAM)$(EXE),chicken-install,true))
$(eval $(call declare-program-from-object,$(CHICKEN_UNINSTALL_PROGRAM)$(EXE),chicken-uninstall,true))
$(eval $(call declare-program-from-object,$(CHICKEN_STATUS_PROGRAM)$(EXE),chicken-status))
$(eval $(call declare-program-from-object,$(CHICKEN_PROFILE_PROGRAM)$(EXE),chicken-profile))
$(eval $(call declare-program-from-object,$(CSC_PROGRAM)$(EXE),csc))

# static executables

$(CHICKEN_STATIC_EXECUTABLE): $(COMPILER_STATIC_OBJECTS) libchicken$(A)
	$(LINKER) $(LINKER_OPTIONS) $(LINKER_STATIC_OPTIONS) $(COMPILER_STATIC_OBJECTS) $(LINKER_OUTPUT) libchicken$(A) $(LIBRARIES)
$(CSI_STATIC_EXECUTABLE): csi$(O) libchicken$(A)
	$(LINKER) $(LINKER_OPTIONS) $(LINKER_STATIC_OPTIONS) $< $(LINKER_OUTPUT) libchicken$(A) $(LIBRARIES)
$(CHICKEN_BUG_PROGRAM)$(EXE): chicken-bug$(O) libchicken$(A)
	$(LINKER) $(LINKER_OPTIONS) $(LINKER_STATIC_OPTIONS) $< $(LINKER_OUTPUT) libchicken$(A) $(LIBRARIES)

# installation

.PHONY: install uninstall install-libs install-import-libs
.PHONY: install-target install-dev install-bin install-other-files

install: $(TARGETS) install-target install-bin install-libs install-dev install-other-files

install-target: install-libs

install-libs:
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(ILIBDIR)"
ifneq ($(LIBCHICKEN_IMPORT_LIBRARY),) 
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_STATIC_LIBRARY_OPTIONS) $(LIBCHICKEN_IMPORT_LIBRARY) "$(DESTDIR)$(ILIBDIR)"
endif
ifndef STATICBUILD
ifdef DLLSINPATH
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_SHARED_LIBRARY_OPTIONS) $(LIBCHICKEN_SO_FILE) "$(DESTDIR)$(IBINDIR)"
else
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_SHARED_LIBRARY_OPTIONS) $(LIBCHICKEN_SO_FILE) "$(DESTDIR)$(ILIBDIR)$(SEP)$(LIBCHICKEN_SO_FILE)$(SONAME_VERSION)"
endif
ifdef USES_SONAME
ifeq ($(DESTDIR),)
	cd "$(DESTDIR)$(ILIBDIR)" && ln -sf $(LIBCHICKEN_SO_FILE).$(BINARYVERSION) libchicken$(SO)
endif
endif
endif

install-dev: install-libs
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(ILIBDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(ISHAREDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IEGGDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IINCDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IDATADIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_STATIC_LIBRARY_OPTIONS) libchicken$(A) "$(DESTDIR)$(ILIBDIR)"
ifneq ($(POSTINSTALL_STATIC_LIBRARY),true)
	$(POSTINSTALL_STATIC_LIBRARY) $(POSTINSTALL_STATIC_LIBRARY_FLAGS) "$(ILIBDIR)$(SEP)libchicken$(A)"
endif
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken.h "$(DESTDIR)$(IINCDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(CHICKEN_CONFIG_H) "$(DESTDIR)$(IINCDIR)"
ifeq ($(PLATFORM),macosx)
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)mac.r "$(DESTDIR)$(ISHAREDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)CHICKEN.icns "$(DESTDIR)$(IDATADIR)"
endif
ifdef WINDOWS
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken.ico "$(DESTDIR)$(IDATADIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken.rc$(O) "$(DESTDIR)$(IDATADIR)"
endif
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)types.db "$(DESTDIR)$(IEGGDIR)"

ifeq ($(NEEDS_RELINKING),yes)
install-bin:
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CHICKEN_PROGRAM)$(EXE) 
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CSI_PROGRAM)$(EXE)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CSC_PROGRAM)$(EXE)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CHICKEN_PROFILE_PROGRAM)$(EXE)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CHICKEN_INSTALL_PROGRAM)$(EXE)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CHICKEN_UNINSTALL_PROGRAM)$(EXE)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(CHICKEN_STATUS_PROGRAM)$(EXE)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(IMPORT_LIBRARIES:%=%.so)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(IMPORT_LIBRARIES:%=%.import.so)
	$(MAKE) -f $(SRCDIR)Makefile.$(PLATFORM) CONFIG=$(CONFIG) NEEDS_RELINKING=no RUNTIME_LINKER_PATH="$(LIBDIR)" SONAME_VERSION=.$(BINARYVERSION) install-bin
# Damn. What was this for, again?
#
# 	$(MAKE_WRITABLE_COMMAND) $(CHICKEN_PROGRAM)$(EXE) $(CSI_PROGRAM)$(EXE) $(CSC_PROGRAM)$(EXE) $(CHICKEN_PROFILE_PROGRAM)$(EXE)
# ifndef STATICBUILD
# 	$(MAKE_WRITABLE_COMMAND) $(CHICKEN_INSTALL_PROGRAM)$(EXE)
# 	$(MAKE_WRITABLE_COMMAND) $(CHICKEN_UNINSTALL_PROGRAM)$(EXE)
# 	$(MAKE_WRITABLE_COMMAND) $(CHICKEN_STATUS_PROGRAM)$(EXE)
# endif
else
  ifdef STATICBUILD
    define install-import-lib
      $(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(1).import.scm "$(DESTDIR)$(IEGGDIR)"

    endef # Newline at the end is needed
  else
    define install-import-lib
      $(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(1).import.so "$(DESTDIR)$(IEGGDIR)"

    endef # Newline at the end is needed
  endif

install-bin: $(TARGETS) install-libs install-dev
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CHICKEN_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CSI_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CHICKEN_PROFILE_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CSC_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CHICKEN_BUG_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(foreach obj,$(IMPORT_LIB_OBJECTS_1),\
	          $(call install-import-lib,$(obj)))
	$(call install-import-lib, setup-api)
	$(call install-import-lib, setup-download)
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) setup-api.so "$(DESTDIR)$(IEGGDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) setup-download.so "$(DESTDIR)$(IEGGDIR)"
ifndef STATICBUILD
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CHICKEN_INSTALL_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CHICKEN_UNINSTALL_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(CHICKEN_STATUS_PROGRAM)$(EXE) "$(DESTDIR)$(IBINDIR)"
ifneq ($(POSTINSTALL_PROGRAM),true)
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CSI_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_PROFILE_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CSC_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_BUG_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)setup-api.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)setup-download.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)setup-api.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)setup-download.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)chicken.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)lolevel.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)srfi-1.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)srfi-4.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)data-structures.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)ports.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)files.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)posix.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)srfi-13.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)srfi-69.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)extras.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)regex.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)irregex.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)srfi-14.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)tcp.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)foreign.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)scheme.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)csi.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)srfi-18.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IEGGDIR)$(SEP)utils.import.so"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_INSTALL_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_UNINSTALL_PROGRAM)"
	$(POSTINSTALL_PROGRAM) $(POSTINSTALL_PROGRAM_FLAGS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_STATUS_PROGRAM)"
endif
ifeq ($(CROSS_CHICKEN)$(DESTDIR),0)
	-$(IBINDIR)$(SEP)$(CHICKEN_INSTALL_PROGRAM) -update-db
else
	@echo
	@echo "Warning: cannot run \`$(CHICKEN_INSTALL_PROGRAM) -update-db' when cross-compiling or DESTDIR is set"
	@echo
endif
endif
ifdef WINDOWS_SHELL
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_EXECUTABLE_OPTIONS) $(SRCDIR)csibatch.bat "$(DESTDIR)$(IBINDIR)"
endif
endif

install-other-files:
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IMANDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IDOCDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IDATADIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)csi.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)csc.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken-install.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken-uninstall.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken-status.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken-profile.1 "$(DESTDIR)$(IMANDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken-bug.1 "$(DESTDIR)$(IMANDIR)"
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) "$(DESTDIR)$(IDOCDIR)$(SEP)manual"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)manual$(SEP)* "$(DESTDIR)$(IDOCDIR)$(SEP)manual"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)README "$(DESTDIR)$(IDOCDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)LICENSE "$(DESTDIR)$(IDOCDIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)setup.defaults "$(DESTDIR)$(IDATADIR)"
	$(INSTALL_PROGRAM) $(INSTALL_PROGRAM_FILE_OPTIONS) $(SRCDIR)chicken.png "$(DESTDIR)$(IDATADIR)"

uninstall:
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CSI_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_PROFILE_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_INSTALL_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_UNINSTALL_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_STATUS_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CSC_PROGRAM)$(EXE)" \
	  "$(DESTDIR)$(IBINDIR)$(SEP)$(CHICKEN_BUG_PROGRAM)$(EXE)"
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(ILIBDIR)$(SEP)libchicken$(A) "
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(ILIBDIR)$(SEP)libchicken$(SO)"
ifdef USES_SONAME
	-$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(ILIBDIR)$(SEP)libchicken$(SO).$(BINARYVERSION)"
endif
ifdef WINDOWS
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(IBINDIR)$(SEP)libchicken$(SO)"
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(ILIBDIR)$(SEP)$(LIBCHICKEN_IMPORT_LIBRARY)"
endif
ifeq ($(PLATFORM),cygwin)
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(IBINDIR)$(SEP)cygchicken*"
endif
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(IMANDIR)$(SEP)chicken.1" "$(DESTDIR)$(IMANDIR)$(SEP)csi.1" \
	  "$(DESTDIR)$(IMANDIR)$(SEP)csc.1" "$(DESTDIR)$(IMANDIR)$(SEP)chicken-profile.1" "$(DESTDIR)$(IMANDIR)$(SEP)chicken-install.1" \
	  "$(DESTDIR)$(IMANDIR)$(SEP)chicken-bug.1" "$(DESTDIR)$(IMANDIR)$(SEP)chicken-uninstall.1" \
	  "$(DESTDIR)$(IMANDIR)$(SEP)chicken-status.1"
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(IINCDIR)$(SEP)chicken.h $(DESTDIR)$(IINCDIR)$(SEP)chicken-config.h"
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_RECURSIVE_OPTIONS) "$(DESTDIR)$(IDATADIR)"
ifdef WINDOWS_SHELL
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) "$(DESTDIR)$(IBINDIR)$(SEP)csibatch.bat"
endif

# bootstrapping c sources

.SUFFIXES: .scm
.SECONDARY: setup-api.import.scm setup-download.import.scm

setup-api.import.scm: setup-api.c
setup-download.import.scm: setup-download.c

bootstrap-lib = $(CHICKEN) $< $(CHICKEN_LIBRARY_OPTIONS) -output-file $@

library.c: $(SRCDIR)library.scm $(SRCDIR)version.scm $(SRCDIR)banner.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
eval.c: $(SRCDIR)eval.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
expand.c: $(SRCDIR)expand.scm $(SRCDIR)synrules.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
chicken-syntax.c: $(SRCDIR)chicken-syntax.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
chicken-ffi-syntax.c: $(SRCDIR)chicken-ffi-syntax.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
data-structures.c: $(SRCDIR)data-structures.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
ports.c: $(SRCDIR)ports.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
files.c: $(SRCDIR)files.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
extras.c: $(SRCDIR)extras.scm $(SRCDIR)private-namespace.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib)
lolevel.c: $(SRCDIR)lolevel.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
tcp.c: $(SRCDIR)tcp.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
srfi-1.c: $(SRCDIR)srfi-1.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
srfi-4.c: $(SRCDIR)srfi-4.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
srfi-13.c: $(SRCDIR)srfi-13.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
srfi-14.c: $(SRCDIR)srfi-14.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
srfi-18.c: $(SRCDIR)srfi-18.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
srfi-69.c: $(SRCDIR)srfi-69.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) -extend $(SRCDIR)private-namespace.scm
utils.c: $(SRCDIR)utils.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
posixunix.c: $(SRCDIR)posixunix.scm $(SRCDIR)posix-common.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
posixwin.c: $(SRCDIR)posixwin.scm $(SRCDIR)posix-common.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
regex.c: $(SRCDIR)regex.scm $(SRCDIR)irregex.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
scheduler.c: $(SRCDIR)scheduler.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
profiler.c: $(SRCDIR)profiler.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 
stub.c: $(SRCDIR)stub.scm $(SRCDIR)common-declarations.scm
	$(bootstrap-lib) 

define declare-bootstrap-import-lib
$(1).import.c: $$(SRCDIR)$(1).import.scm
	$$(CHICKEN) $$< $$(CHICKEN_IMPORT_LIBRARY_OPTIONS) -output-file $$@
endef

$(foreach obj, $(IMPORT_LIB_OBJECTS_1),\
          $(eval $(call declare-bootstrap-import-lib,$(obj))))

# bootstrap setup API
setup-api.import.c: $(SRCDIR)setup-api.scm
	$(CHICKEN) $(SRCDIR)setup-api.import.scm $(CHICKEN_IMPORT_LIBRARY_OPTIONS) \
	  -output-file $@ 
setup-download.import.c: $(SRCDIR)setup-download.scm
	$(CHICKEN) $(SRCDIR)setup-download.import.scm $(CHICKEN_IMPORT_LIBRARY_OPTIONS) \
	  -output-file $@ 

define declare-compiler-object
$(1).c: $$(SRCDIR)$(1).scm $$(SRCDIR)compiler-namespace.scm \
	  $$(SRCDIR)private-namespace.scm $$(SRCDIR)tweaks.scm
	$$(CHICKEN) $$< $$(CHICKEN_COMPILER_OPTIONS) -output-file $$@ 
endef

$(foreach obj, $(COMPILER_OBJECTS_1),\
          $(eval $(call declare-compiler-object,$(obj))))


csi.c: $(SRCDIR)csi.scm $(SRCDIR)banner.scm $(SRCDIR)private-namespace.scm
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ -extend $(SRCDIR)private-namespace.scm
chicken-profile.c: $(SRCDIR)chicken-profile.scm
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ 
chicken-install.c: $(SRCDIR)chicken-install.scm setup-download.c setup-api.c
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ 
chicken-uninstall.c: $(SRCDIR)chicken-uninstall.scm
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ 
chicken-status.c: $(SRCDIR)chicken-status.scm
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ 
csc.c: $(SRCDIR)csc.scm
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ 
chicken-bug.c: $(SRCDIR)chicken-bug.scm
	$(CHICKEN) $< $(CHICKEN_PROGRAM_OPTIONS) -output-file $@ 

setup-api.c: $(SRCDIR)setup-api.scm
	$(CHICKEN) $< $(CHICKEN_DYNAMIC_OPTIONS) -emit-import-library setup-api \
	  -output-file $@ 
setup-download.c: $(SRCDIR)setup-download.scm setup-api.c
	$(CHICKEN) $< $(CHICKEN_DYNAMIC_OPTIONS) -emit-import-library setup-download \
	  -output-file $@ 

# distribution files

.PHONY: distfiles dist html

DISTFILES = library.c eval.c expand.c chicken-syntax.c chicken-ffi-syntax.c \
	data-structures.c ports.c files.c extras.c lolevel.c utils.c \
	tcp.c srfi-1.c srfi-4.c srfi-13.c srfi-14.c srfi-18.c srfi-69.c \
	posixunix.c posixwin.c regex.c scheduler.c profiler.c stub.c \
	chicken-profile.c chicken-install.c chicken-uninstall.c chicken-status.c \
	csc.c csi.c chicken.c batch-driver.c compiler.c optimizer.c  \
	compiler-syntax.c scrutinizer.c unboxing.c support.c \
	c-platform.c c-backend.c chicken-bug.c $(IMPORT_LIBRARIES:=.import.c)

distfiles: $(DISTFILES)

dist: distfiles
	CSI=$(CSI) $(CSI) -s $(SRCDIR)scripts$(SEP)makedist.scm --platform=$(PLATFORM) CHICKEN=$(CHICKEN)

html:
	$(MAKEDIR_COMMAND) $(MAKEDIR_COMMAND_OPTIONS) $(SRCDIR)html
	$(COPY_COMMAND) $(SRCDIR)misc$(SEP)manual.css $(SRCDIR)html
	$(CSI) -s $(SRCDIR)scripts$(SEP)wiki2html.scm --outdir=html manual$(SEP)*

# cleaning up

.PHONY: clean distclean spotless confclean testclean

clean:
	-$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) chicken$(EXE) csi$(EXE) csc$(EXE) \
	  $(CHICKEN_PROFILE_PROGRAM)$(EXE) \
	  $(CHICKEN_INSTALL_PROGRAM)$(EXE) \
	  $(CHICKEN_UNINSTALL_PROGRAM)$(EXE) \
	  $(CHICKEN_STATUS_PROGRAM)$(EXE) \
	  $(CHICKEN_BUG_PROGRAM)$(EXE) *$(O) \
	  $(LIBCHICKEN_SO_FILE) \
	  libchicken$(A) libchicken$(SO) $(PROGRAM_IMPORT_LIBRARIES) \
	  $(IMPORT_LIBRARIES:=.import.so) $(LIBCHICKEN_IMPORT_LIBRARY) \
	  setup-api.so setup-api.import.scm setup-download.so \
	  setup-download.import.scm \
	  setup-api.c setup-download.c
ifdef USES_SONAME
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) libchicken.so.$(BINARYVERSION)
endif

confclean:
	-$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) \
	  chicken-config.h chicken-defaults.h chicken-install.rc chicken-uninstall.rc

spotless: distclean testclean
	-$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(DISTFILES)

distclean: clean confclean

testclean:
	$(REMOVE_COMMAND) $(REMOVE_COMMAND_OPTIONS) $(SRCDIR)tests$(SEP)a.out $(SRCDIR)tests$(SEP)scrutiny.out \
	  $(SRCDIR)tests$(SEP)tmp* $(SRCDIR)tests$(SEP)*.so $(SRCDIR)tests$(SEP)*.import.scm $(SRCDIR)tests$(SEP)repository

# run tests

.PHONY: check 

check: $(CHICKEN_SHARED_EXECUTABLE) $(CSI_SHARED_EXECUTABLE) $(CSC_PROGRAM)
	cd tests; sh runtests.sh


# benchmark

.PHONY: bench

bench: $(CHICKEN_SHARED_EXECUTABLE) $(CSI_SHARED_EXECUTABLE) $(CSC_PROGRAM)
	cd tests; echo >>bench.log; date >>bench.log; sh runbench.sh 2>&1 | tee -a bench.log


# build current head in sub-directory

.PHONY: buildhead

buildhead:
	rm -fr chicken-`cat buildversion`
	git archive --format=tar --prefix=chicken-`cat buildversion`/ $(HEAD) | tar x
	cd chicken-`cat buildversion`; $(MAKE) -f Makefile.$(PLATFORM) \
	  PLATFORM=$(PLATFORM) PREFIX=`pwd` CONFIG= CHICKEN=$(CHICKEN) all install


# build static bootstrapping chicken

.PHONY: boot-chicken

boot-chicken:
	$(MAKE) -f Makefile.$(PLATFORM) PLATFORM=$(PLATFORM) PREFIX=/nowhere CONFIG= \
	  SRCDIR=$(SRCDIR) CHICKEN=$(CHICKEN) PROGRAM_SUFFIX=-boot-stage1 STATICBUILD=1 \
	  C_COMPILER_OPTIMIZATION_OPTIONS= HACKED_APPLY= \
	  confclean chicken-boot-stage1$(EXE)
	$(MAKE) -f Makefile.$(PLATFORM) PLATFORM=$(PLATFORM) PREFIX=/nowhere CONFIG= \
	  SRCDIR=$(SRCDIR) CHICKEN=$(PWD)/chicken-boot-stage1$(EXE) PROGRAM_SUFFIX=-boot \
	  STATICBUILD=1 HACKED_APPLY= C_COMPILER_OPTIMIZATION_OPTIONS= \
	  touchfiles chicken-boot$(EXE) confclean

.PHONY: touchfiles

touchfiles:
ifdef WINDOWS_SHELL
	for %x in (*.scm) do copy /b %x +,,
else
	touch *.scm
endif
