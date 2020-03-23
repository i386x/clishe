# SPDX-License-Identifier: MIT
#
# File:    common.mk
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-21 23:08:09 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Variables and settings shared across Makefiles.
#

NAME := clishe

ECHO ?= echo
CAT ?= cat
TR ?= tr
SED ?= sed
CP ?= cp
INSTALL ?= install
MKDIR ?= mkdir
RM ?= rm
GZIP ?= gzip
POD2HTML ?= pod2html
POD2MAN ?= pod2man
SHELLCHECK ?= shellcheck
PODCHECKER ?= podchecker

PREFIX ?= /usr/local

DESTDIR := $(PREFIX)/share/$(NAME)
DOCDIR := $(PREFIX)/share/doc/$(NAME)
MANDIR := $(PREFIX)/share/man

CLISHE_SH := $(NAME).sh
