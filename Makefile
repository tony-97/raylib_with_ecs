include Makefile.vars

EXEC_NAME := app
LIB_NAME  := mylib
SRC_DIR   := src

#==============================================================================
# Build mode name (debug/release)
# Mirrors the logic in Makefile.options so that lib_config.mk files can
# resolve the correct library output path at include time.
#==============================================================================
ifeq ($(BUILD_MODE),RELEASE)
    BUILD_MODE_NAME := release
else
    BUILD_MODE_NAME := debug
endif

#==============================================================================
# External Libraries — auto-discovered from libs/
#==============================================================================
# Only consider directories that contain a Makefile (i.e. buildable libraries)
LIB_DIRS    := $(foreach d,$(wildcard libs/*),$(if $(wildcard $(d)/Makefile),$(d)))
LIB_CONFIGS := $(wildcard libs/*/lib_config.mk)

# Include each library's consumer configuration.
# These files append to INCLUDE_DIRS, LDLIBS, DEFINES, etc.
ifneq ($(LIB_CONFIGS),)
include $(LIB_CONFIGS)
endif

# Generically add every library's output directory to the linker search path.
# Each lib builds into: libs/<name>/<BUILD_NAME>/<BUILD_MODE_NAME>/
#   BUILD_NAME      = build_windows | build_linux | ...  (from Makefile.vars)
#   BUILD_MODE_NAME = debug | release                    (computed above)
LIBS_PATH += $(addsuffix /$(BUILD_NAME)/$(BUILD_MODE_NAME),$(LIB_DIRS))

ifndef MSVC
    CFLAGS  += -flto
    LDFLAGS += -flto
endif

# Compilation flags
ifeq ($(TARGET),WEB)
    AR  := emar
    CC  := emcc
    CXX := em++
    LDLIBS   += 
    LDFLAGS  += 
    DEBUG_FLAGS   += 
    RELEASE_FLAGS += 
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += 
    CFLAGS   += 
endif
ifeq ($(TARGET),ANDROID)
	ANDROID_ARCH ?= arm64
	ANDROID_API_VERSION ?= 29
    LDLIBS   +=
    LDFLAGS  += 
    DEBUG_FLAGS   += 
    RELEASE_FLAGS += 
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += 
    CFLAGS   += 
endif
ifeq ($(TARGET),WINDOWS)
ifdef MSVC
    LDLIBS   +=  /L:libraylib.a libraylib.a Shell32.lib user32.lib opengl32.lib gdi32.lib winmm.lib
    LDFLAGS  += 
    DEBUG_FLAGS   += 
    RELEASE_FLAGS += 
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += /std:c++latest
    CFLAGS   += 
else
    LDLIBS   += 
    LDFLAGS  += 
    DEBUG_FLAGS   += -g -ggdb -O0
    RELEASE_FLAGS += -march=native -Ofast -s -DNDEBUG
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += 
    CFLAGS   += 
endif
endif
ifeq ($(TARGET),LINUX)
    LDLIBS   += 
    LDFLAGS  += 
    DEBUG_FLAGS   += -g -ggdb -O0
    RELEASE_FLAGS += -march=native -Ofast -s -DNDEBUG
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += 
    CFLAGS   += 
endif
ifeq ($(TARGET),OSX)
    LDLIBS   += 
    LDFLAGS  += 
    DEBUG_FLAGS   += 
    RELEASE_FLAGS += 
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += 
    CFLAGS   += 
endif
# Add more targets

export

#==============================================================================
# Per-library build / clean targets (auto-generated from LIB_DIRS)
#
# For each libs/<name>/ directory with a Makefile, this generates:
#   build-lib-<name>   — builds the library via $(MAKE) -C libs/<name> lib
#   clean-lib-<name>   — cleans the library
#   cleanall-lib-<name> — deep-cleans the library
#
# These individual targets are then collected into:
#   build-libs, clean-libs, cleanall-libs
#==============================================================================
define LIB_BUILD_TEMPLATE
.PHONY: build-lib-$(notdir $(1))
build-lib-$(notdir $(1)):
	$$(MAKE) -C $(1) lib
endef

define LIB_CLEAN_TEMPLATE
.PHONY: clean-lib-$(notdir $(1)) cleanall-lib-$(notdir $(1))
clean-lib-$(notdir $(1)):
	$$(MAKE) -C $(1) clean
cleanall-lib-$(notdir $(1)):
	$$(MAKE) -C $(1) cleanall
endef

.PHONY: all lib run run_valgrind run_cgdb info clean cleanall build-libs clean-libs cleanall-libs

all: build-libs
	$(MAKE) -f Makefile.options all

$(foreach lib,$(LIB_DIRS),$(eval $(call LIB_BUILD_TEMPLATE,$(lib))))
$(foreach lib,$(LIB_DIRS),$(eval $(call LIB_CLEAN_TEMPLATE,$(lib))))

build-libs: $(foreach lib,$(LIB_DIRS),build-lib-$(notdir $(lib)))
clean-libs: $(foreach lib,$(LIB_DIRS),clean-lib-$(notdir $(lib)))
cleanall-libs: $(foreach lib,$(LIB_DIRS),cleanall-lib-$(notdir $(lib)))

lib:
	$(MAKE) -f Makefile.options lib

run:
	$(MAKE) -f Makefile.options run

run_valgrind:
	$(MAKE) -f Makefile.options run_valgrind

run_cgdb:
	$(MAKE) -f Makefile.options run_cgdb

info:
	$(info [INFO] LIB_DIRS       : $(LIB_DIRS))
	$(info [INFO] LIB_CONFIGS    : $(LIB_CONFIGS))
	$(info [INFO] BUILD_MODE_NAME: $(BUILD_MODE_NAME))
	$(info [INFO] LIBS_PATH      : $(LIBS_PATH))
	$(MAKE) -f Makefile.options info

clean: clean-libs
	$(MAKE) -f Makefile.options clean

cleanall: cleanall-libs
	$(MAKE) -f Makefile.options cleanall
