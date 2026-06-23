include Makefile.vars

EXEC_NAME := app
LIB_NAME  := mylib
SRC_DIR   := src

ifndef MSVC
    CFLAGS += -I ./external/raylib/src/ -flto
    LDFLAGS += -L ./libs/raylib/$(BUILD_NAME)/release -flto
    LDLIBS += -lraylib
endif

make_libs := $(wildcard libs/*)
LIBS_PATH += $(addsuffix /$(BUILD_NAME),$(make_libs))

INCLUDE_DIRS += ./external/raylib/src/
LIBS_PATH    += ./libs/raylib/build/build_windows/libraylib.a ./libs/raylib/build_windows/debug
DEFINES += PLATFORM_DESKTOP



define compile_lib:
$(1):
    $(MAKE) -c $(1)
endef

print:
    $(info $(make_libs))


$(foreach lib_dir,$(make_libs),$(eval $(call compile_lib,$(lib_dir))))

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
