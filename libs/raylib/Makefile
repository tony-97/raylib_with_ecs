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

DEFINES += $(BACKEND) $(GRAPHICS)

RAYLIB_API_VERSION = 500

#==============================================================================
# Common flags (non-MSVC)
#==============================================================================
ifndef MSVC
    DEBUG_FLAGS   += -g -ggdb -O0 -D_DEBUG
    RELEASE_FLAGS += -Ofast -DNDEBUG
    DEFINES += _GNU_SOURCE
    CFLAGS  += -std=c99 -fno-strict-aliasing $(CUSTOM_CFLAGS) -fPIC -flto
    WFLAGS  += -Wall -Wno-missing-braces -Wno-unused-parameter -Wno-c11-extensions -Wno-shadow -Werror=pointer-arith -Werror=implicit-function-declaration
    LDLIBS  += -lm -latomic
endif

ifeq ($(TARGET),WEB)
    BACKEND = PLATFORM_WEB
endif

ifeq ($(filter PLATFORM_DESKTOP_GLFW PLATFORM_WEB,$(BACKEND)),)
    INCLUDE_DIRS += $(SRC_DIR)/external/glfw/include
endif

# Configure backend flags
ifneq ($(filter LINUX WINDOWS OSX,$(TARGET)),)
    GRAPHICS := GRAPHICS_API_OPENGL_33

    BACKEND ?= PLATFORM_DESKTOP_GLFW
    ifeq ($(BACKEND),PLATFORM_DESKTOP_GLFW)
        ifeq ($(TARGET),LINUX)
            ifdef WAYLAND
                CFLAGS += -D_GLFW_WAYLAND
                LDFLAGS += $(shell pkg-config wayland-client wayland-cursor wayland-egl xkbcommon --libs)

                WL_PROTOCOLS_DIR := external/glfw/deps/wayland

                wl_generate = \
                    $(eval protocol=$(1)) \
                    $(eval basename=$(2)) \
                    $(shell wayland-scanner client-header $(protocol) $(RAYLIB_SRC_PATH)/$(basename).h) \
                    $(shell wayland-scanner private-code $(protocol) $(RAYLIB_SRC_PATH)/$(basename)-code.h)

                $(call wl_generate, $(WL_PROTOCOLS_DIR)/wayland.xml, wayland-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/xdg-shell.xml, xdg-shell-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/xdg-decoration-unstable-v1.xml, xdg-decoration-unstable-v1-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/viewporter.xml, viewporter-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/relative-pointer-unstable-v1.xml, relative-pointer-unstable-v1-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/pointer-constraints-unstable-v1.xml, pointer-constraints-unstable-v1-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/fractional-scale-v1.xml, fractional-scale-v1-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/xdg-activation-v1.xml, xdg-activation-v1-client-protocol)
                $(call wl_generate, $(WL_PROTOCOLS_DIR)/idle-inhibit-unstable-v1.xml, idle-inhibit-unstable-v1-client-protocol)
            endif
        endif
    endif

    ifeq ($(BACKEND),PLATFORM_DESKTOP_SDL)
        LDLIBS += $(SDL_LIBRARIES)
    endif

    ifeq ($(BACKEND),PLATFORM_DESKTOP_RGFW)
        ifeq ($(TARGET),LINUX)
            # Libraries for Debian GNU/Linux desktop compipling
            # NOTE: Required packages: libegl1-mesa-dev
            LDLIBS += -lX11 -lXrandr -lXinerama -lXi -lXcursor
        endif
    endif
endif

# Common graphics system flags
ifneq ($(filter PLATFORM_DESKTOP_GLFW PLATFORM_DESKTOP_SDL PLATFORM_DESKTOP_RGFW,$(BACKEND)),)
    ifeq ($(TARGET),WINDOWS)
        # Libraries for Windows desktop compilation
        LDLIBS += -static-libgcc -lopengl32 -lgdi32 -lwinmm
    endif
    ifeq ($(TARGET),LINUX)
        # Libraries for Debian GNU/Linux desktop compipling
        # NOTE: Required packages: libegl1-mesa-dev
        LDLIBS += -lGL -lpthread -ldl -lrt

        ifdef X11
            DEFINES += _GLFW_X11
            LDLIBS  += -lX11
        endif
    endif
    ifeq ($(TARGET),OSX)
        # Libraries for Debian MacOS desktop compiling
        # NOTE: Required packages: libegl1-mesa-dev
        LDLIBS += -framework Cocoa -framework OpenGL -framework CoreVideo -framework IOKit -framework CoreAudio
    endif
endif

ifneq ($(filter ANDROID WEB DRM,$(TARGET)),)
    GRAPHICS := GRAPHICS_API_OPENGL_ES2
endif

#==============================================================================
# Per-target flags
#==============================================================================
ifeq ($(TARGET),WEB)
    EXCLUDE_SRCS += $(SRC_DIR)/rglfw.c
    LDFLAGS  += -sUSE_GLFW=3
    WFLAGS   += -Wno-unused-command-line-argument
    CFLAGS   = -std=gnu99 -fno-strict-aliasing
    DEBUG_FLAGS   = -O0 -sASSERTIONS=1 --profiling
    RELEASE_FLAGS = -Oz --closure 2 -sMODULARIZE -flto
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
    DEBUG_FLAGS   += /Od
    RELEASE_FLAGS += /O2yit
    WFLAGS   += /wd4668 /wd4820 /wd4061 /wd5045 /wd4711 /wd4710 /wd4191 /wd4100 /wd4244 /wd4996 /wd4996
    CFLAGS   += /std:c11 /nologo
else
    LDLIBS   += -lshell32
    LDFLAGS  +=
    CPPFLAGS += -I$(SRC_DIR)/external/glfw/include -I$(SRC_DIR)/external/glfw/deps/mingw
endif
endif
ifeq ($(TARGET),LINUX)
    LDFLAGS  +=
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
# Targets — delegate to the generic build system
#==============================================================================
.PHONY: all lib info clean cleanall

all: lib

lib:
	$(MAKE) -f Makefile.rules lib

info:
	$(MAKE) -f Makefile.rules info

clean:
	$(MAKE) -f Makefile.rules clean

cleanall:
	$(MAKE) -f Makefile.rules cleanall
