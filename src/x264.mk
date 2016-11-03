# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := x264
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 20160706-2245
$(PKG)_CHECKSUM := 8f9176385c3a15706fbdd08cc32c735d926471f0d33d9cf0664e9d82c38ac10f
$(PKG)_SUBDIR   := $(PKG)-snapshot-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-snapshot-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := http://download.videolan.org/pub/videolan/$(PKG)/snapshots/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc yasm liblsmash

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://git.videolan.org/?p=x264.git;a=shortlog' | \
    $(SED) -n 's,.*\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\).*,\1\2\3-2245,p' | \
    sort | \
    tail -1
endef

define $(PKG)_BUILD
    $(SED) -i 's,yasm,$(TARGET)-yasm,g' '$(1)/configure'
    cd '$(1)' && \
        ./configure \
        --extra-ldflags="-Wl,--output-def,x264.def" \
        $(MXE_CONFIGURE_OPTS) \
        --cross-prefix='$(TARGET)'- \
        --enable-win32thread \
        --disable-lavf \
        --disable-swscale   # Avoid circular dependency with ffmpeg. Remove if undesired.
    $(MAKE) -C '$(1)' -j 1 uninstall
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install

    $(TARGET)-dlltool -l $(PREFIX)/$(TARGET)/bin/x264.lib -d $(1)/x264.def
endef
