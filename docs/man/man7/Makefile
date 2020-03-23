# SPDX-License-Identifier: MIT
#
# File:    docs/man/man7/Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-21 11:23:21 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Build manual pages for section 7.
#

ME := $(lastword $(MAKEFILE_LIST))
HERE := $(dir $(abspath $(ME)))
TOPDIR := $(HERE)../../..
PODDIR := $(HERE)../../pod

include $(TOPDIR)/common.mk

VERSION := $(shell $(CAT) $(TOPDIR)/VERSION)
MANSEC := 7

MANPAGES :=

CLISHE_SH_POD := $(PODDIR)/$(CLISHE_SH).pod
CLISHE_SH_MANSEC := $(CLISHE_SH).$(MANSEC)
CLISHE_SH_NAME := $(shell $(ECHO) $(CLISHE_SH) | $(TR) [:lower:] [:upper:])
CLISHE_SH_MANSEC_GZ := $(CLISHE_SH_MANSEC).gz
MANPAGES += $(CLISHE_SH_MANSEC_GZ)

MANDEST := $(MANDIR)/man$(MANSEC)

.PHONY: docs install clean

docs: $(MANPAGES)

install:
	$(MKDIR) -p $(MANDEST)
	$(INSTALL) -p -m 644 $(MANPAGES) $(MANDEST)

clean:
	$(RM) -f $(CLISHE_SH_MANSEC)
	$(RM) -f $(MANPAGES)

$(CLISHE_SH_MANSEC_GZ): $(CLISHE_SH_MANSEC)
	$(GZIP) -9 -k -c $< > $@

$(CLISHE_SH_MANSEC):
	$(POD2MAN) --center="User Manual" \
                   --name="$(CLISHE_SH_NAME)" \
                   --release="$(NAME) v$(VERSION)" \
                   --section=$(MANSEC) \
                   --utf8 \
                   $(CLISHE_SH_POD) $@
