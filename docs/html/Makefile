# SPDX-License-Identifier: MIT
#
# File:    docs/html/Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-21 18:03:08 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Build html pages.
#

ME := $(lastword $(MAKEFILE_LIST))
HERE := $(dir $(abspath $(ME)))
TOPDIR := $(HERE)../..
PODDIR := $(HERE)../pod

include $(TOPDIR)/common.mk

STATICDIR := static
CSSDIR := $(STATICDIR)/css
POD2HTMLCSSDIR := pod2html.css

HTMLPAGES :=

CLISHE_SH_POD := $(PODDIR)/$(CLISHE_SH).pod
INDEX_HTML := index.html
POD2HTML_CSS := $(CSSDIR)/pod2html.css
HTMLPAGES += $(INDEX_HTML)

HTMLDEST := $(DOCDIR)/html

.PHONY: docs install clean

docs: $(HTMLPAGES)

install:
	$(MKDIR) -p $(HTMLDEST)
	$(MKDIR) -p $(HTMLDEST)/$(CSSDIR)
	$(INSTALL) -p -m 644 $(POD2HTML_CSS) $(HTMLDEST)/$(CSSDIR)
	$(INSTALL) -p -m 644 $(HTMLPAGES) $(HTMLDEST)

clean:
	$(RM) -f *.tmp
	$(RM) -rfd $(STATICDIR)
	$(RM) -f $(HTMLPAGES)

$(INDEX_HTML): $(POD2HTML_CSS)
	$(POD2HTML) --htmldir=. \
                    --infile=$(CLISHE_SH_POD) --outfile=$@ \
                    --podroot=$(PODDIR) --podpath=. --cachedir=. --flush \
                    --nopoderrors \
                    --css=$< \
                    --title="clishe - A CLI Shell Library"

$(POD2HTML_CSS):
	$(MKDIR) -p $(CSSDIR)
	$(CP) $(POD2HTMLCSSDIR)/$(notdir $@) $@
