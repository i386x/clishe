# SPDX-License-Identifier: MIT
#
# File:    samples/Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-22 10:33:29 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Install samples as extra documentation.
#

ME := $(lastword $(MAKEFILE_LIST))
HERE := $(dir $(abspath $(ME)))
TOPDIR := $(HERE)/..

include $(TOPDIR)/common.mk

SAMPLESDIR := $(DOCDIR)/samples

SAMPLES := showopts.sh

.PHONY: install check

install:
	$(MKDIR) -p $(SAMPLESDIR)
	$(INSTALL) -p -m 755 $(SAMPLES) $(SAMPLESDIR)

check:
	$(SHELLCHECK) -s bash -S style -x $(SAMPLES)
