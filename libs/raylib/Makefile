#==============================================================================
# libs/raylib/Makefile — Build configuration for raylib as a static library
#
# This Makefile is invoked by the root Makefile via:
#     $(MAKE) -C libs/raylib lib
#
# It reuses the generic build system (Makefile.vars → Makefile.rules) through
# symlinks.  All shared variables (CC, CXX, AR, TARGET, BUILD_MODE, etc.)
# are inherited from the parent make.
#==============================================================================

include Makefile.vars

#==============================================================================
# Source layout
#==============================================================================
LIB_NAME     := raylib

SRC_DIR      := ../../external/raylib/src
EXCLUDE_SRCS := $(wildcard $(SRC_DIR)/external/glfw/src/*.c) \
                $(wildcard $(SRC_DIR)/external/*.c) \
                $(wildcard $(SRC_DIR)/platforms/*.c)

# Shared config: backend detection, system libs, defines, per-target link flags
include lib_config.mk

#==============================================================================
# Build-only flags (not needed by consumers)
#==============================================================================
ifndef MSVC
    DEBUG_FLAGS   += -g -ggdb -O0 -D_DEBUG
    RELEASE_FLAGS += -Ofast -DNDEBUG
    DEFINES       += _GNU_SOURCE
    CFLAGS        += -std=c99 -fno-strict-aliasing $(CUSTOM_CFLAGS) -fPIC -flto
    WFLAGS        += -Wall -Wno-missing-braces -Wno-unused-parameter \
                     -Wno-c11-extensions -Wno-shadow \
                     -Werror=pointer-arith -Werror=implicit-function-declaration
endif

# GLFW include path (build-only — consumers use ./external/raylib/src/)
ifeq ($(filter PLATFORM_DESKTOP_GLFW PLATFORM_WEB,$(BACKEND)),)
    INCLUDE_DIRS += $(SRC_DIR)/external/glfw/include
endif

# Exclude rglfw.c if not using GLFW backend
ifneq ($(BACKEND),PLATFORM_DESKTOP_GLFW)
    EXCLUDE_SRCS += $(SRC_DIR)/rglfw.c
endif

#==============================================================================
# Per-target build-only flags
#==============================================================================
ifeq ($(TARGET),WEB)
    WFLAGS        += -Wno-unused-command-line-argument
    CFLAGS         = -std=gnu99 -fno-strict-aliasing
    DEBUG_FLAGS    = -O0 -sASSERTIONS=1 --profiling
    RELEASE_FLAGS  = -Oz --closure 2 -sMODULARIZE -flto
endif
ifeq ($(TARGET),ANDROID)
    LDFLAGS  += -Wl,-soname,libraylib.$(RAYLIB_API_VERSION).so -L$(SRC_DIR)
endif
ifeq ($(TARGET),WINDOWS)
ifdef MSVC
    DEBUG_FLAGS   += /Od
    RELEASE_FLAGS += /O2yit
    WFLAGS        += /wd4668 /wd4820 /wd4061 /wd5045 /wd4711 /wd4710 /wd4191 /wd4100 /wd4244 /wd4996
    CFLAGS        += /std:c11 /nologo
else
    LDLIBS        += -lshell32
    INCLUDE_DIRS  += $(SRC_DIR)/external/glfw/deps/mingw
endif
endif

export

#==============================================================================
# Targets — delegate to the generic build system
#==============================================================================
.PHONY: all lib run run_cgdb info clean cleanall

all:
	@$(MAKE) -f Makefile.rules all

lib:
	@$(MAKE) -f Makefile.rules lib

run:
	@$(MAKE) -f Makefile.rules run

run_valgrind:
	@$(MAKE) -f Makefile.rules run_valgrind

run_cgdb:
	@$(MAKE) -f Makefile.rules run_cgdb

info:
	@$(MAKE) -f Makefile.rules info

clean:
	@$(MAKE) -f Makefile.rules clean

cleanall:
	@$(MAKE) -f Makefile.rules cleanall
