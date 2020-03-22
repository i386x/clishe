# SPDX-License-Identifier: MIT
#
# File:    docs/Makefile
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-21 17:21:40 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Build all documentation.
#

.PHONY: docs install clean

docs:
	$(MAKE) -C pod $(MAKECMDGOALS)
	$(MAKE) -C html $(MAKECMDGOALS)
	$(MAKE) -C man $(MAKECMDGOALS)

install:
	$(MAKE) -C html $(MAKECMDGOALS)
	$(MAKE) -C man $(MAKECMDGOALS)

clean:
	$(MAKE) -C pod $(MAKECMDGOALS)
	$(MAKE) -C html $(MAKECMDGOALS)
	$(MAKE) -C man $(MAKECMDGOALS)
