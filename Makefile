include Makefile.vars

EXEC_NAME := app
LIB_NAME  := mylib
SRC_DIR   := src
ARFLAGS   := rcs
BUILD_NAME := build$(addprefix _,$(call to_lower,$(TARGET)))
BUILD_DIR  := $(BUILD_NAME)

ifndef MSVC
    CPPFLAGS += -I ./external/raylib/src/ -I ./external/oop-ecs/src -I ./external/oop-ecs/external/
    CXXFLAGS += -std=c++20
    RELEASE_FLAGS += -flto
    LDFLAGS += -L ./libs/raylib/$(BUILD_NAME)/release -flto
    LDLIBS += -lraylib
else
    CPPFLAGS += /I \./external/raylib/src /I \./external/oop-ecs/src /I \./external/oop-ecs/external/
    CXXFLAGS += /std:c++20
	LDFLAGS += /LIBPATH: ./libs/raylib/$(BUILD_NAME)/release
    LDLIBS += raylib.lib Shell32.lib user32.lib opengl32.lib gdi32.lib winmm.lib
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
    LDLIBS   += 
    LDFLAGS  += 
    DEBUG_FLAGS   += 
    RELEASE_FLAGS += 
    WFLAGS   += 
    CPPFLAGS += 
    CXXFLAGS += 
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
    LDFLAGS  += -ltbb
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

.PHONY: all run run_cgdb info clean cleanall

all:
	$(MAKE) -f Makefile.options all

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
