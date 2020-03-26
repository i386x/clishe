#!/bin/bash
# SPDX-License-Identifier: MIT
#
# File:    samples/echodemo.sh
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-26 16:26:43 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Demonstrate clishe_echo (a clishe demo).
#

set -euo pipefail

SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
CLISHEPATH="${SCRIPTDIR}/..:/usr/local/share/clishe:/usr/share/clishe"

# shellcheck source=../clishe.sh
PATH="${CLISHEPATH}${PATH:+:}${PATH}" \
. clishe.sh >/dev/null 2>&1 || {
  echo "clishe library is not installed"
  exit 1
}

clishe_init

clishe_echo "Normal text."
clishe_echo --red "Red text."
clishe_echo --green "Green text."
clishe_echo --blue Blue text.
clishe_echo --yellow Yellow text.
clishe_echo --color 35 Magenta text.
CLISHE_COLOR=34 clishe_echo -n Test CLISHE_COLOR and -n
CLISHE_COLOR=34 clishe_echo --green " [OK]"
CLISHE_NOCOLOR=1 CLISHE_COLOR=34 clishe_echo --green Test CLISHE_NOCOLOR
CLISHE_QUITE=1 CLISHE_COLOR=34 clishe_echo --green Test CLISHE_QUITE
