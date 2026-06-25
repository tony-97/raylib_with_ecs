#==============================================================================
# libs/raylib/lib_config.mk — Consumer-facing configuration for raylib
#
# This file is auto-included by the root Makefile.  It declares what any
# project that links against raylib needs: include paths, link libraries,
# and preprocessor defines.
#
# Library search paths (LIBS_PATH) are handled generically by the root
# Makefile — every libs/<name>/ directory gets its
# <BUILD_NAME>/<BUILD_MODE_NAME>/ added automatically.
#==============================================================================

# Include path so #include <raylib.h> works
INCLUDE_DIRS += ./external/raylib/src/

# Link against the static library
ifndef MSVC
    LDLIBS += -lraylib
endif

# Required defines
BACKEND ?= PLATFORM_DESKTOP_GLFW

ifndef MSVC
    CFLAGS  += -flto
    LDFLAGS += -flto
endif

DEFINES += $(BACKEND) $(GRAPHICS)

RAYLIB_VERSION     := 6.0.0
RAYLIB_API_VERSION := 600

#==============================================================================
# Common flags (non-MSVC)
#==============================================================================
ifndef MSVC
    LDLIBS  += -lc -lm -latomic
endif

ifeq ($(TARGET),WEB)
    BACKEND = PLATFORM_WEB
endif

# Configure backend flags
ifneq ($(filter LINUX WINDOWS OSX,$(TARGET)),)
    GRAPHICS := GRAPHICS_API_OPENGL_33

    BACKEND ?= PLATFORM_DESKTOP_GLFW
    ifeq ($(BACKEND),PLATFORM_DESKTOP_GLFW)
        ifeq ($(TARGET),LINUX)
            ifdef WAYLAND
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
    LDFLAGS  += -sUSE_GLFW=3
endif
ifeq ($(TARGET),ANDROID)
	ANDROID_ARCH ?= arm64
	ANDROID_API_VERSION ?= 35
    BACKEND  := PLATFORM_ANDROID
    LDLIBS   += -llog -landroid -lEGL -lGLESv2 -lOpenSLES
    LDFLAGS  += -Wl,--exclude-libs,libatomic.a
endif
ifeq ($(TARGET),WINDOWS)
ifdef MSVC
    LDLIBS += /L:libraylib.a libraylib.a Shell32.lib user32.lib opengl32.lib gdi32.lib winmm.lib
else
    LDLIBS +=
endif
endif
ifeq ($(TARGET),LINUX)
    LDLIBS +=
endif
ifeq ($(TARGET),OSX)
    LDLIBS +=
endif
# Add more targets

export