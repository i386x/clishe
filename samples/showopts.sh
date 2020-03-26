#!/bin/bash
# SPDX-License-Identifier: MIT
#
# File:    samples/showopts.sh
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-17 16:31:00 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   Show options (a clishe demo).
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

clishe_defopt ARG1 "positional argument #1"
clishe_defopt ARG2 "positional argument #2"
clishe_defopt --token=TOKEN -t -- "security token" required
clishe_defopt --user=USER -u -- "" optional "Jane Doe <jd@company.com>" <<EOF
a user name and email; please, keep the following format

  Name Surname <your@email.address>

the email part is optional
EOF
clishe_defopt --prefix=PREFIX -- "prefix" optional
clishe_defopt --verbose -v -- "verbocity level" V
clishe_defopt --help -h -? -- "print this screen and exit" help usage
clishe_defopt "@FILE1 FILE2 ..." "input files"

function usage() {
  cat <<-EOF
	Show options (a clishe demo).

	Usage: ${clishe_scriptname} ARG1 ARG2 [OPTIONS] [FILE1 [FILE2 [...]]]
	where options are

	${clishe_helplines}

	The key-value options with no default value are required.

	EOF
  exit 0
}

clishe_process_options "$@"
shift ${clishe_nopts}

clishe_echo --blue "ARG1: '${ARG1:-}'"
clishe_echo --blue "ARG2: '${ARG2:-}'"
clishe_echo --blue "TOKEN: '${TOKEN:-}'"
clishe_echo --blue "USER: '${USER:-}'"
clishe_echo --blue "PREFIX: '${PREFIX:-}'"
clishe_echo --blue "V: ${V:-0}"
clishe_echo --blue "Files:" "${clishe_tailopts[@]}"
clishe_echo --blue "Processed options: ${clishe_nopts}"
clishe_echo --blue "Rest of options: $*"
