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

# shellcheck source=../clishe.sh
. /usr/share/clishe/clishe.sh >/dev/null 2>&1 || \
. "${SCRIPTDIR}/../clishe.sh" >/dev/null 2>&1 || {
  echo "clishe library is not installed"
  exit 1
}

clishe_init

clishe_defopt --token=TOKEN -t -- "security token" required
clishe_defopt --user=USER -u -- "" optional "Jane Doe <jdoe@company.com>" <<EOF
a user name and email; please, keep the following format

  Name Surname <your@email.address>

the email part is optional
EOF
clishe_defopt --prefix=PREFIX -- "prefix" optional
clishe_defopt --verbose -v -- "verbocity level" V
clishe_defopt --help -h -? -- "print this screen and exit" help usage

function usage() {
  cat <<-EOF
	Show options (a clishe demo).

	Usage: ${clishe_scriptname} OPTIONS
	where OPTIONS are

	${clishe_helplines}

	The key-value options with no default value are required.

	EOF
  exit 0
}

clishe_process_options "$@"
shift ${clishe_nopts}

clishe_echo --blue "TOKEN: '${TOKEN:-}'"
clishe_echo --blue "USER: '${USER:-}'"
clishe_echo --blue "PREFIX: '${PREFIX:-}'"
clishe_echo --blue "V: ${V:-0}"
clishe_echo --blue "Processed options: ${clishe_nopts}"
clishe_echo --blue "Rest of options: $*"
