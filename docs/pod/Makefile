# SPDX-License-Identifier: MIT
#
# File:    docs/pod/Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-21 22:33:59 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Prepare POD files.
#

ME := $(lastword $(MAKEFILE_LIST))
HERE := $(dir $(abspath $(ME)))
TOPDIR := $(HERE)../..

include $(TOPDIR)/common.mk

VERSION := $(shell $(CAT) $(TOPDIR)/VERSION)
EDIT := -e 's|@VERSION@|$(VERSION)|g'

PODFILES :=

CLISHE_SH_POD := $(CLISHE_SH).pod
PODFILES += $(CLISHE_SH_POD)

.PHONY: docs clean

docs: $(PODFILES)

clean:
	$(RM) -f $(PODFILES)

$(CLISHE_SH_POD):
	$(SED) $(EDIT) $(TOPDIR)/$(CLISHE_SH) > $(CLISHE_SH_POD)
