# SPDX-License-Identifier: MIT
#
# File:    Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-18 15:20:48 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Makefile for project maintenance.
#

ME := $(lastword $(MAKEFILE_LIST))
HERE := $(dir $(abspath $(ME)))
TOPDIR := $(HERE)

include $(TOPDIR)/common.mk

.PHONY: all docs install clean check

all: check docs

docs:
	$(MAKE) -C docs docs

install: all
	$(MKDIR) -p $(DESTDIR)
	$(MKDIR) -p $(DOCDIR)
	$(INSTALL) -p -m 644 $(CLISHE_SH) $(DESTDIR)
	$(INSTALL) -p -m 644 LICENSE $(DOCDIR)
	$(INSTALL) -p -m 644 README.md $(DOCDIR)
	$(INSTALL) -p -m 644 VERSION $(DOCDIR)
	$(MAKE) -C docs install
	$(MAKE) -C samples install

clean:
	$(MAKE) -C docs clean

check:
	$(SHELLCHECK) -s bash -S style $(CLISHE_SH)
	$(PODCHECKER) -warnings -warnings -warnings $(CLISHE_SH)
	$(MAKE) -C samples check
