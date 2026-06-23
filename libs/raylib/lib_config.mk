include Makefile.vars

LIB_NAME := raylib
BUILD_MODE := RELEASE

ifndef MSVC
    LDLIBS += -l$(LIB_NAME)
	CFLAGS += -D_GNU_SOURCE -D$(PLATFORM) -D$(GRAPHICS) -fno-strict-aliasing $(CUSTOM_CFLAGS) -fPIC -flto
endif

# Compilation flags
ifeq ($(TARGET),WEB)
    PLATFORM := PLATFORM_WEB
    GRAPHICS := GRAPHICS_API_OPENGL_ES2
    EXCLUDE_SRCS += $(SRC_DIR)/rglfw.c
    LDFLAGS  += -Wl,-soname,lib$(LIB_NAME).so.$(RAYLIB_API_VERSION) -Oz -flto
    DEBUG_FLAGS   += -O0 -sASSERTIONS=1 --profiling
    RELEASE_FLAGS += -O3 -flto
    WFLAGS   += -Wno-unused-command-line-argument
    CFLAGS   += -std=gnu99 -flto --closure 2 -sMODULARIZE
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
    PLATFORM := PLATFORM_DESKTOP
    GRAPHICS := GRAPHICS_API_OPENGL_33
    LDLIBS   += -lopengl32 -lgdi32 -lwinmm -lshell32
    LDFLAGS  += -Wl,--out-implib,$(BUILD_PATH)/$(LIB_NAME)dll.a
    DEBUG_FLAGS   += -g -ggdb -O0
    RELEASE_FLAGS += -march=native -Ofast -s -DNDEBUG
    CPPFLAGS += -I$(SRC_DIR)/external/glfw/include -I$(SRC_DIR)/external/glfw/deps/mingw
    CFLAGS   += -std=c99
endif
endif
ifeq ($(TARGET),LINUX)
    PLATFORM := PLATFORM_DESKTOP
    GRAPHICS := GRAPHICS_API_OPENGL_33
    LDLIBS   += -lGL -lc -lm -lpthread -ldl -lrt -lX11
    LDFLAGS  += -Wl,-soname,lib$(LIB_NAME).so.$(RAYLIB_API_VERSION)
    DEBUG_FLAGS   += -g -ggdb -O0
    RELEASE_FLAGS += -march=native -Ofast -s -DNDEBUG
    CPPFLAGS += -I$(SRC_DIR)/external/glfw/include -I$(SRC_DIR)/external/glfw/deps/mingw
    CFLAGS += -std=c99
endif
ifeq ($(TARGET),OSX)
    LDLIBS   := 
    LDFLAGS  := 
    DEBUG_FLAGS   := 
    RELEASE_FLAGS := 
    WFLAGS   := 
    CPPFLAGS := 
    CXXFLAGS := 
    CFLAGS   := 
endif
# Add more targets

ifeq ($(SDL),1)
    ifndef MSVC
        PLATFORM := PLATFORM_DESKTOP_SDL
        GRAPHICS := GRAPHICS_API_OPENGL_33
        LDLIBS += -lGL -lc -lm -lpthread -ldl -lrt
        BUILD_DIR := $(BUILD_NAME)_sdl
        CPPFLAGS += -I /usr/include/SDL2
        CFLAGS += -std=gnu99
    endif
endif

export

.PHONY: all run run_cgdb info clean cleanall

all: lib
	$(MAKE) -f Makefile.options lib

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
