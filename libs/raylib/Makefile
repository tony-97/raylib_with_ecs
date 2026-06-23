#==============================================================================
# libs/raylib/Makefile — Build configuration for raylib as a static library
#
# This Makefile is invoked by the root Makefile via:
#     $(MAKE) -C libs/raylib lib
#
# It reuses the generic build system (Makefile.vars → Makefile.options →
# Makefile.rules) through symlinks.  All shared variables (CC, CXX, AR,
# TARGET, BUILD_MODE, etc.) are inherited from the parent make.
#==============================================================================

include Makefile.vars

#==============================================================================
# Source layout
#==============================================================================
SRC_DIR      := ../../external/raylib/src
EXCLUDE_SRCS := $(wildcard $(SRC_DIR)/external/glfw/src/*.c) \
                $(wildcard $(SRC_DIR)/external/*.c) \
                $(wildcard $(SRC_DIR)/platforms/*.c)
LIB_NAME     := raylib

INCLUDE_DIRS += ../../external/raylib/src/external/glfw/include
DEFINES      += PLATFORM_DESKTOP

RAYLIB_API_VERSION = 500

#==============================================================================
# Common flags (non-MSVC)
#==============================================================================
ifndef MSVC
    DEBUG_FLAGS += -g -D_DEBUG
    WFLAGS     += -Wall -Wno-missing-braces -Werror=pointer-arith \
                  -Werror=implicit-function-declaration
    CFLAGS     += -D_GNU_SOURCE -D$(PLATFORM) -D$(GRAPHICS) \
                  -fno-strict-aliasing $(CUSTOM_CFLAGS) -fPIC -flto
endif

#==============================================================================
# Per-target flags
#==============================================================================
ifeq ($(TARGET),WEB)
    PLATFORM := PLATFORM_WEB
    GRAPHICS := GRAPHICS_API_OPENGL_ES2
    EXCLUDE_SRCS += $(SRC_DIR)/rglfw.c
    LDFLAGS       += -Wl,-soname,lib$(LIB_NAME).so.$(RAYLIB_API_VERSION) -Oz -flto
    DEBUG_FLAGS   += -O0 -sASSERTIONS=1 --profiling
    RELEASE_FLAGS += -O3 -flto
    WFLAGS        += -Wno-unused-command-line-argument
    CFLAGS        += -std=gnu99 -flto --closure 2 -sMODULARIZE
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
    LDLIBS   += 
    LDFLAGS  += 
    DEBUG_FLAGS   += /Od
    RELEASE_FLAGS += /O2yit
    WFLAGS   += /wd4668 /wd4820 /wd4061 /wd5045 /wd4711 /wd4710 /wd4191 /wd4100 /wd4244 /wd4996 /wd4996
    CPPFLAGS += 
    CXXFLAGS += 
    CFLAGS   += /std:c11 /nologo
else
    PLATFORM      := PLATFORM_DESKTOP
    GRAPHICS      := GRAPHICS_API_OPENGL_33
    LDLIBS        += -lopengl32 -lgdi32 -lwinmm -lshell32
    LDFLAGS       += -Wl,--out-implib,$(BUILD_PATH)/$(LIB_NAME)dll.a
    DEBUG_FLAGS   += -g -ggdb -O0
    RELEASE_FLAGS += -march=native -Ofast -s -DNDEBUG
    CPPFLAGS      += -I$(SRC_DIR)/external/glfw/include \
                     -I$(SRC_DIR)/external/glfw/deps/mingw
    CFLAGS        += -std=c99
endif
endif
ifeq ($(TARGET),LINUX)
    PLATFORM      := PLATFORM_DESKTOP
    GRAPHICS      := GRAPHICS_API_OPENGL_33
    LDLIBS        += -lGL -lc -lm -lpthread -ldl -lrt -lX11
    LDFLAGS       += -Wl,-soname,lib$(LIB_NAME).so.$(RAYLIB_API_VERSION)
    DEBUG_FLAGS   += -g -ggdb -O0
    RELEASE_FLAGS += -march=native -Ofast -s -DNDEBUG
    CPPFLAGS      += -I$(SRC_DIR)/external/glfw/include \
                     -I$(SRC_DIR)/external/glfw/deps/mingw
    CFLAGS        += -std=c99
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

ifeq ($(SDL),1)
    ifndef MSVC
        PLATFORM := PLATFORM_DESKTOP_SDL
        GRAPHICS := GRAPHICS_API_OPENGL_33
        LDLIBS   += -lGL -lc -lm -lpthread -ldl -lrt
        BUILD_DIR := $(BUILD_NAME)_sdl
        CPPFLAGS += -I /usr/include/SDL2
        CFLAGS   += -std=gnu99
    endif
endif

export

#==============================================================================
# Targets — delegate to the generic build system
#==============================================================================
.PHONY: all lib run run_valgrind run_cgdb info clean cleanall

all: lib

lib:
	$(MAKE) -f Makefile.options lib

run:
	$(MAKE) -f Makefile.options run

run_valgrind:
	$(MAKE) -f Makefile.options run_valgrind

run_cgdb:
	$(MAKE) -f Makefile.options run_cgdb

info:
	$(MAKE) -f Makefile.options info

clean:
	$(MAKE) -f Makefile.options clean

cleanall:
	$(MAKE) -f Makefile.options cleanall
