#
### Copyright (C) 2015 CESNET z.s.p.o. (http://www.cesnet.cz/)
#
### This is free software, licensed under the GNU General Public License v2.
# #
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eapwatchdog
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Ondrej Caletka <ondrej.caletka@cesnet.cz>

include $(INCLUDE_DIR)/package.mk

# The built is empty. But as there's no makefile in the git repo, we need to
# # override the default that runs "make".
define Build/Compile
	true
endef

define Package/$(PKG_NAME)
	TITLE:=Enable and disable wireless depending on RADIUS server reachability
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+eapol-test
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin/ $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/eapwatchdog.sh $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/eapwatchdog.init $(1)/etc/init.d/eapwatchdog
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
