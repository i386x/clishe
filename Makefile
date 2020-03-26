# SPDX-License-Identifier: MIT
#
# File:    Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-18 15:20:48 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Makefile for project maintenance.
#

include ./common.mk

VERSION := $(shell $(CAT) VERSION)
TAG := v$(VERSION)
DISTNAME := $(NAME)-$(VERSION)
DISTTMPDIR := $(TMPDIR)/$(DISTNAME)
TARBALL := $(DISTNAME).tar.gz
ZIPBALL := $(DISTNAME).zip

.PHONY: all docs install clean check dist

all: check docs

docs:
	$(MAKE) -C docs docs

install:
	$(MKDIR) -p $(DESTDIR)
	$(MKDIR) -p $(DOCDIR)
	$(INSTALL) -p -m 644 $(CLISHE_SH) $(DESTDIR)
	$(INSTALL) -p -m 644 LICENSE $(DOCDIR)
	$(INSTALL) -p -m 644 README.md $(DOCDIR)
	$(INSTALL) -p -m 644 VERSION $(DOCDIR)
	$(INSTALL) -p -m 644 CHANGELOG $(DOCDIR)
	$(MAKE) -C docs install
	$(MAKE) -C samples install

clean:
	$(MAKE) -C docs clean
	$(RM) -rfd $(TMPDIR)/$(NAME)-*
	$(RM) -f *.gz *.zip

check:
	$(SHELLCHECK) -s bash -S style $(CLISHE_SH)
	$(PODCHECKER) -warnings -warnings -warnings $(CLISHE_SH)
	$(MAKE) -C samples check

dist: clean
	$(MKDIR) -p $(DISTTMPDIR)
	$(CP) -r . $(DISTTMPDIR)
	$(CD) $(DISTTMPDIR) && $(GIT) clean -dxff
	$(CD) $(DISTTMPDIR) && $(GIT) checkout $(TAG)
	$(CD) $(TMPDIR) && $(TAR) --exclude .\* -czvf $(TARBALL) $(DISTNAME)
	$(CD) $(TMPDIR) && $(ZIP) -9rv $(ZIPBALL) $(DISTNAME) -x \*/.\*
	$(MV) $(TMPDIR)/$(TARBALL) .
	$(MV) $(TMPDIR)/$(ZIPBALL) .
	$(RM) -rfd $(DISTTMPDIR)
