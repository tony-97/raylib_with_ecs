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
DEFINES += PLATFORM_DESKTOP
