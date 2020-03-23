# SPDX-License-Identifier: MIT
#
# File:    clishe.sh
# Author:  Jiří Kučera, <sanczes AT gmail.com>
# Date:    2020-03-10 07:24:00 +0100
# Project: A CLI Shell Library (clishe)
# Brief:   A command line interface (a.k.a CLI) shell library.
#

: <<'=cut'
=pod

=encoding utf8

=begin html

<div class="header">
  clishe
</div>

=end html

=head1 NAME

clishe - A CLI Shell Library

=head1 DESCRIPTION

Provides a set of function for creating command line interface scripts in
Bourne Again Shell (bash) easily.

See L<samples directory|https://github.com/i386x/clishe/tree/master/samples> or
L<EXAMPLES|/EXAMPLES> section below for examples.

=head1 INSTALLATION

Before building and installing I<clishe>, make sure you have installed
L<pod2man|https://perldoc.perl.org/pod2man.html>,
L<pod2html|https://perldoc.perl.org/pod2html.html>,
L<podchecker|https://perldoc.perl.org/podchecker.html> and
L<shellcheck|https://github.com/koalaman/shellcheck> on your system.

Next, get the L<tarball|https://github.com/i386x/clishe/releases> and unpack it
or, if you want the most recent snapshot, clone the I<clishe> repository:

  $ git clone --recurse-submodules https://github.com/i386x/clishe.git

Inside the I<clishe> top directory, type:

  $ make && make install

This will install I<clishe> and all its documentation under the C</usr/local>
location. To change the install destination, use C<PREFIX>:

  $ PREFIX=/usr make install

This will install I<clishe> under the C</usr> location.

=head1 USAGE

To use I<clishe>, simply insert the following line to your script:

  . /usr/local/share/clishe/clishe.sh

You can also use a more robust way:

  SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
  CLISHEPATH="${SCRIPTDIR}:/usr/local/share/clishe:/usr/share/clishe"

  PATH="${CLISHEPATH}${PATH:+:}${PATH}" \
  . clishe.sh >/dev/null 2>&1 || {
    echo "clishe library is not installed"
    exit 1
  }

This will prefer bundled C<clishe.sh> with your script over C<clishe.sh> from
C</usr/local/share/clishe> and C<clishe.sh> from C</usr/local/share/clishe>
over C<clishe.sh> from C</usr/share/clishe>.

Do not forget also to initialize I<clishe> before using anything from it:

  clishe_init

=head1 ENVIRONMENT VARIABLES

C<CLISHE_COLOR> - set a color of text printed by L<clishe_echo|/clishe_echo>.
See L<clishe_echo|/clishe_echo> for more details.

C<CLISHE_NOCOLOR> - if non-empty, suppress colored output of
L<clishe_echo|/clishe_echo>. See L<clishe_echo|/clishe_echo> for more details.

C<CLISHE_QUITE> - if non-empty, suppress L<clishe_echo|/clishe_echo>'s output.
See L<clishe_echo|/clishe_echo> for more details.

C<CLISHE_HELP_INDENT1> - spaces before option name in help screen. See
L<clishe_defopt|/clishe_defopt>.

C<CLISHE_HELP_INDENT2> - spaces before paragraph with option description. See
L<clishe_defopt|/clishe_defopt>.

=head1 VARIABLES

C<clishe_scriptname> - a base name of the script. See
L<clishe_defopt|/clishe_defopt> for example of use.

C<clishe_helplines> - holds the description of defined script options. See
L<clishe_defopt|/clishe_defopt>.

C<clishe_nopts> - a number of options processed by
L<clishe_process_options|/clishe_process_options>. See
L<clishe_process_options|/clishe_process_options>.

=head1 FUNCTIONS

=cut

__clishe_indent1="  "
__clishe_indent2="      "

: <<'=cut'
=pod

=head2 Initialization

=head3 clishe_init

Initialize I<clishe> shell library. This function should be invoked before any
other function from I<clishe> library is invoked.

=cut

function clishe_init() {
  declare -g clishe_scriptname
  clishe_scriptname="$(basename "$0")"
  declare -Ag __clishe_map_flagopt2storage
  declare -Ag __clishe_map_kvopt2storage
  declare -Ag __clishe_map_help2action
  declare -Ag __clishe_map_shortopt2longopt
  declare -Ag __clishe_map_storage2longopt
  declare -ag __clishe_list_required
  declare -g clishe_helplines=""
  declare -g clishe_nopts=0
  declare -g __clishe_shortopts=""
  declare -g __clishe_nshift=1
}

: <<'=cut'
=pod

=head2 Auxiliary functions

=head3 clishe_setvar

Globally set the value of a variable.

Usage:

  clishe_setvar VARIABLE VALUE

=over

=item VARIABLE

A variable name.

=item VALUE

A value to be assigned to I<VARIABLE>.

=back

Assign I<VALUE> to I<VARIABLE>.

=cut

function clishe_setvar() {
  declare -g "$1"="$2"
}

: <<'=cut'
=pod

=head2 Reporting

=head3 clishe_echo

Print a text given in parameters to the standard output.

Usage:

  clishe_echo [-X|--red|--green|--blue|--yellow|--color COLOR_CODE] \
              [MSG1 [MSG2 [...]]]

=over

=item -X

Option of the form -I<X> is passed directly to C<echo>, i.e.

  clishe_echo -n "foo"

is the same as

  echo -n "foo"

=item --red

Print text in red color.

=item --green

Print text in green color.

=item --blue

Print text in blue color.

=item --yellow

Print text in yellow color.

=item --color COLOR_CODE

Print text in I<COLOR_CODE> color. The I<COLOR_CODE> must be written in a way
so

  \e[${COLOR_CODE}m

is a valid ANSI escape color code. For example

  clishe_echo --color '33;1' "foo"

prints C<foo> in yellow to the terminal window.

=item MSG1 MSG2 ...

Messages to be printed. When printed, a space character is put between two
messages.

=back

To set a color, environment variable B<CLISHE_COLOR> can be set to the value of
the same format as in the case of I<COLOR_CODE>. Therefore,

  CLISHE_COLOR='33;1' clishe_echo "foo"

prints C<foo> in yellow. The value of B<CLISHE_COLOR> can be overriden by
command line arguments, so

  CLISHE_COLOR='33;1' clishe_echo --red "foo"

prints C<foo> in red instead of yellow. If B<CLISHE_NOCOLOR> has non-empty
value, it suppresses color output entirely, no matter whether the color is set
via B<CLISHE_COLOR> or via command line. Thus,

  CLISHE_NOCOLOR=1 CLISHE_COLOR='33;1' clishe_echo --red "foo"

prints C<foo> in default terminal colors. If B<CLISHE_QUITE> is set, no output
is printed. For example

  CLISHE_QUITE=1 CLISHE_COLOR='33;1' clishe_echo --red "foo"

prints nothing to standard output.

=cut

function clishe_echo() {
  local __echo_flags=""
  local __echo_color="${CLISHE_COLOR:-}"
  local __echo_reset=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --red)
        __echo_color='31'
        shift
        ;;
      --green)
        __echo_color='32'
        shift
        ;;
      --blue)
        __echo_color='34'
        shift
        ;;
      --yellow)
        __echo_color='33;1'
        shift
        ;;
      --color)
        __echo_color="${2:-}"
        shift 2
        ;;
      -*)
        __echo_flags="${__echo_flags}${1:1}"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ "${CLISHE_NOCOLOR:-}" ]]; then
    __echo_color=""
  fi

  if [[ "${__echo_flags}" ]]; then
    __echo_flags="-${__echo_flags}"
  fi
  if [[ "${__echo_color}" ]]; then
    __echo_flags="${__echo_flags} -e"
    __echo_color="\e[${__echo_color}m"
    __echo_reset="\e[0m"
  fi

  if [[ -z "${CLISHE_QUITE:-}" ]]; then
    # shellcheck disable=SC2086
    echo ${__echo_flags} "${__echo_color}$*${__echo_reset}"
  fi
}

: <<'=cut'
=pod

=head3 clishe_error

Print I<EMSG1 EMSG2 ...> to the standard error output in red and exit with exit
code I<N> (if I<N> is not specified, exit with 1).

Usage:

  clishe_error [N] [EMSG1 [EMSG2 [...]]]

=over

=item N

Exit code. Must be a positive integer. Default exit code is 1.

=item EMSG1 EMSG2 ...

Error messages to be printed to the standard error output.

=back

If the first argument matches C<^[1-9][0-9]*$> (that is, if the first argument
is a positive integer), it is treated as exit code instead of message text.
Therefore

  clishe_error "Foo:" "error"

prints C<Foo: error> to the standard error output and exit with 1 whereas

  clishe_error 2 "Foo:" "error"

prints the same but exit with 2.

As I<clishe_error> uses L<clishe_echo|/clishe_echo>, its output can be
influenced by B<CLISHE_NOCOLOR> and B<CLISHE_QUITE> environment variables.

=cut

function clishe_error() {
  local __exitcode=1

  if [[ "${1}" =~ ^[1-9][0-9]*$ ]]; then
    __exitcode=${1}
    shift
  fi
  clishe_echo --red "${clishe_scriptname}: $*" >&2
  # shellcheck disable=SC2086
  exit ${__exitcode}
}

: <<'=cut'
=pod

=head2 Options

=head3 clishe_defopt

Define a command line option.

Usage:

  clishe_defopt --key=STORAGE [-a [-b [...]]] -- HELP \
                ( required | optional [DEFAULT] )
  clishe_defopt --flag [-a [-b [...]]] -- HELP ( STORAGE | help ACTION )

=over

=item --key=STORAGE

This form of the first argument specify that the defined option is key-value
option. I<key> is the name of the option, I<STORAGE> is the name of the
variable to which a value of --I<key> given on command line should be stored.

=item --flag

This form of the first argument specify that the defined option is flag option
named I<flag>.

=item -a -b ...

A list of short options which works as an aliases/shortcuts for the long one.
The list is terminated with C<-->.

=item HELP

A help text to be displayed as the description of the defined option. If this
option is empty (C<"">), the help text is read from the standard input. If the
option is optional key-value option, the information about its default value
is appended to the help text.

The help text is accumulated in C<clishe_helplines> variable that can be used
in user defined help printing routines. Environment variables
C<CLISHE_HELP_INDENT1> and C<CLISHE_HELP_INDENT2> influence the indentation of
help text. Given an excerpt of help screen

  Usage: script.sh [OPTIONS]
  where OPTIONS are

    --help, -h, -?
        print this screen and exit

the spaces that are before C<--help, -h, -?> are taken from
C<CLISHE_HELP_INDENT1> whereas the spaces before C<print this screen and exit>
comes from C<CLISHE_HELP_INDENT2>. If no C<CLISHE_HELP_INDENT1> or
C<CLISHE_HELP_INDENT2> are provided, the default amount of spaces is 2 and 6,
respectively. Because the help text is assembled dynamically during
C<clishe_defopt> invokation, it is recommended to set them before a first use
C<clishe_defopt>.

=item required

The keyword C<required> is applicable to key-value options only. It says that
the key-value option must be present on the command line and its value must be
non-empty.

=item optional

The keyword C<optional> is applicable to key-value options only and it says
that the key-value option is optional.

=item DEFAULT

A default value of the key-value option if it was declared as optional. The
default value should be specified only in connection with C<optional> keyword.
If no default value is specified, the default value of key-value option is
the empty string.

=item STORAGE

A name of a variable to which the presence of flag option should be recorded.
The storage variable holds the number of occurences of flag option on command
line. If the corresponding flag option was not encountered during the command
line processing, the storage variable remains unset. Thus, to test whether the
flag option has been set, use

  [[ ${STORAGE_VARIABLE:-0} -gt 0 ]]

=item help

The keyword C<help> indicates that the flag option fires a function that print
a help screen.

=item ACTION

Applicable only with C<help>, the I<ACTION> is the name of function that is
responsible for printing of help screen.

=back

Following examples demonstrate how to define command line options. Consider an
excerpt from a script C<script.sh>:

  clishe_defopt --token=TOKEN -t -- "a security token" required
  clishe_defopt --port=PORT -p -- "port number" optional 8888
  clishe_defopt --email=EMAIL -- "email address" optional
  clishe_defopt --verbose -v -- "verbosity level" V
  clishe_defopt --help -h -? -- "" help usage <<__HELP__
  print this screen and exit
  __HELP__

  function usage() {
    cat <<EOF
  Usage: ${clishe_scriptname} [OPTIONS]
  where OPTIONS are

  ${clishe_helplines}

  EOF
    exit 0
  }

If we run

  $ ./script.sh -tfa1afe1 -port=7777 -vvv

then the value of C<TOKEN> will be C<fa1afe1>, the value of C<PORT> will be
7777, the value of C<EMAIL> will be its default value which is the empty
string, and the value of C<V> will be 3 because there are 3 occurences of I<v>
option on command line.

If we just run

  $ ./script.sh -v

we get an error about missing --I<token> option, because this option is marked
as required.

Printing the help screen is done via C<usage> function. Notice that instead of
--I<help>, options -I<h> and -I<?> can be also used to show the help:

  $ ./script.sh -?
  Usage: script.sh [OPTIONS]
  where OPTIONS are

    --token=TOKEN, -t
        a security token

    --port=PORT, -p
        port number
        (default: "8888")

    --email=EMAIL
        email address
        (default: "")

    --verbose, -v
        verbosity level

    --help, -h, -?
        print this screen and exit

=cut

function clishe_defopt() {
  local __optname=""
  local __storage=""
  local __shorts=""
  local __help=""
  local __kvoptreq=""
  local __default=""
  local __help_action=""

  # ---------------------------------------------------------------------------
  # -- Gather phase

  # Gather option name:
  if [[ "${1}" != --* ]]; then
    clishe_error "${FUNCNAME[0]}: Option name must begin with --"
  fi
  __optname="${1#--}"
  if [[ "${1}" == *=* ]]; then
    __optname="${__optname%%=*}"
    __storage="${1#*=}"
    if [[ -z "${__storage}" ]]; then
      clishe_error "${FUNCNAME[0]}: Expected a variable name after ="
    fi
  fi
  if [[ -z "${__optname}" ]]; then
    clishe_error "${FUNCNAME[0]}: Expected option name."
  fi

  shift

  # Gather short aliases:
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --)
        shift
        break
        ;;
      -?)
        __shorts="${__shorts}${__shorts:+ }${1#-}"
        ;;
      *)
        clishe_error "${FUNCNAME[0]}: Expected short option name or --"
        ;;
    esac
    shift
  done

  # Gather help text:
  if [[ -z "${1:-}" ]]; then
    # "" indicates that help is on standard input:
    __help=$(
      while read -r; do
        echo "${REPLY:+${CLISHE_HELP_INDENT2:-${__clishe_indent2}}}${REPLY}"
      done
    )
  else
    __help="${CLISHE_HELP_INDENT2:-${__clishe_indent2}}${1}"
  fi

  shift

  # Gather the rest:
  if [[ "${__storage}" ]]; then
    # Storage is defined, we are defining key-value option:
    case "${1:-}" in
      required|optional)
        __kvoptreq="${1}"
        ;;
      *)
        clishe_error "${FUNCNAME[0]}: Missing an inforamtion whether" \
          "key-value option is required or optional."
        ;;
    esac
    # Gather default key-value option value (not used if option is required):
    __default="${2:-}"
  else
    # Storage is undefined yet, we are defining flag option:
    case "${1:-}" in
      # (help action | STORAGE )
      help)
        if [[ -z "${2:-}" ]]; then
          clishe_error "${FUNCNAME[0]}: Missing a help action."
        fi
        __help_action="${2}"
        ;;
      ?*)
        __storage="${1}"
        ;;
      *)
        clishe_error \
          "${FUNCNAME[0]}: Expected 'help' keyword or storage variable name."
        ;;
    esac
  fi

  # ---------------------------------------------------------------------------
  # -- Define phase

  # Check whether option was not defined before:
  if [[ "${__clishe_map_flagopt2storage[${__optname}]:-}" ]] \
  || [[ "${__clishe_map_kvopt2storage[${__optname}]:-}" ]] \
  || [[ "${__clishe_map_help2action[${__optname}]:-}" ]]; then
    clishe_error "${FUNCNAME[0]}: --${__optname} is still defined."
  fi

  # Check whether storage variable is not yet used:
  if [[ "${__storage}" ]] \
  && [[ "${__clishe_map_storage2longopt[${__storage}]:-}" ]]; then
    clishe_error \
      "${FUNCNAME[0]}: Storage variable ${__storage} was used before."
  fi

  # Check and setup short name aliases:
  for __opt in ${__shorts}; do
    if [[ "${__clishe_map_shortopt2longopt[${__opt}]:-}" ]]; then
      clishe_error "${FUNCNAME[0]}: -${__opt} is still defined."
    fi
    __clishe_map_shortopt2longopt["${__opt}"]="${__optname}"
  done

  # Map option to its storage:
  if [[ "${__kvoptreq}" ]]; then
    # It is a key-value option:
    __clishe_map_kvopt2storage["${__optname}"]="${__storage}"
    # If it is required, note it:
    if [[ "${__kvoptreq}" == required ]]; then
      __clishe_list_required+=( "${__storage}" )
    fi
  elif [[ "${__storage}" ]]; then
    # It is a flag option:
    __clishe_map_flagopt2storage["${__optname}"]="${__storage}"
  else
    # It is a help:
    __clishe_map_help2action["${__optname}"]="${__help_action}"
  fi

  # Map storage to option and set its default:
  if [[ "${__storage}" ]]; then
    __clishe_map_storage2longopt["${__storage}"]="${__optname}"
    clishe_setvar "${__storage}" "${__default}"
  fi

  # Assemble help lines:
  clishe_helplines=$(
    if [[ "${clishe_helplines}" ]]; then
      echo "${clishe_helplines}"
      echo ""
    fi
    echo -n "${CLISHE_HELP_INDENT1:-${__clishe_indent1}}--${__optname}"
    if [[ "${__kvoptreq}" ]]; then
      echo -n "=${__storage}"
    fi
    for __opt in ${__shorts}; do
      echo -n ", -${__opt}"
    done
    echo ""
    echo "${__help}"
    if [[ "${__kvoptreq}" == optional ]]; then
      echo -n "${CLISHE_HELP_INDENT2:-${__clishe_indent2}}"
      echo "(default: \"${__default}\")"
    fi
  )
}

: <<'=cut'
=pod

=head3 clishe_process_options

Process command line options and store the number of processed options to
C<clishe_nopts>.

Usage:

  clishe_process_options [OPT1 [OPT2 [...]]]

=over

=item OPT1 OPT2 ...

Options to be processed. If one of the options is C<-->, the processing is
terminated.

=back

Given an excerpt from C<script.sh>

  clishe_process_options "$@"

after running C<script.sh> as

  $ ./script.sh --foo=bar -x -- a b c

options C<--foo=bar> and C<-x> will be processed. When C<--> will be reached,
it will be consumed and the processing of options will be terminated. The value
of C<clishe_nopts> variable becomes 3. The value of C<clishe_nopts> can be used
for shifting command line options to get the access to the yet unprocessed part
of command line.

=cut

function clishe_process_options() {
  clishe_nopts=0

  while [[ $# -gt 0 ]]; do
    __clishe_nshift=1
    case "${1}" in
      --)
        clishe_nopts=$(( clishe_nopts + 1 ))
        shift
        break
        ;;
      --*)
        __clishe_handle_longopt "${1}" "${2:-}"
        ;;
      -*)
        __clishe_shortopts="${1#-}"
        while [[ "${__clishe_shortopts}" ]]; do
          __clishe_handle_shortopt "${2:-}"
        done
        ;;
      *)
        clishe_error "Invalid option: ${1}"
        ;;
    esac
    clishe_nopts=$(( clishe_nopts + __clishe_nshift ))
    shift ${__clishe_nshift}
  done

  for __varname in "${__clishe_list_required[@]}"; do
    if [[ -z "${!__varname:-}" ]]; then
      clishe_error \
        "Option --${__clishe_map_storage2longopt[${__varname}]:-} is required."
    fi
  done
}

##
# __clishe_handle_shortopt $1
#
#   $1 - a possible value of key-value option
#
# Handle one short option from __clishe_shortopts. Set __clishe_nshift to 2 if
# the handled option was a key-value option and $1 was used. Modify
# __clishe_shortopts so it contains the rest of unprocessed short options.
function __clishe_handle_shortopt() {
  local __opt=""
  local __longopt=""
  local __storage=""
  local __action=""

  __opt="${__clishe_shortopts:0:1}"
  __clishe_shortopts="${__clishe_shortopts:1}"
  __longopt="${__clishe_map_shortopt2longopt[${__opt}]:-}"

  if [[ -z "${__longopt}" ]]; then
    clishe_error "Invalid option: -${__opt}"
  fi

  __storage="${__clishe_map_kvopt2storage[${__longopt}]:-}"
  if [[ "${__storage}" ]]; then
    if [[ "${__clishe_shortopts}" ]]; then
      clishe_setvar "${__storage}" "${__clishe_shortopts}"
      __clishe_shortopts=""
    elif [[ "${1}" ]]; then
      clishe_setvar "${__storage}" "${1}"
      __clishe_nshift=2
    else
      clishe_error "-${__opt}: Missing value."
    fi
  else
    __storage="${__clishe_map_flagopt2storage[${__longopt}]:-}"
    if [[ -z "${__storage}" ]]; then
      __action="${__clishe_map_help2action[${__longopt}]:-}"
      if [[ -z "${__action}" ]]; then
        clishe_error "Invalid option: -${__opt}"
      fi
      ${__action}
    else
      clishe_setvar "${__storage}" "$(( ${!__storage:-0} + 1 ))"
    fi
  fi
}

##
# __clishe_handle_longopt $1 $2
#
#   $1 - a long option
#   $2 - a possible value of the long option
#
# Handle $1. If $2 was used, set __clishe_nshift to 2.
function __clishe_handle_longopt() {
  local __longopt=""
  local __storage=""
  local __value=""
  local __action=""

  __longopt="${1#--}"
  __longopt="${__longopt%%=*}"
  __storage="${__clishe_map_kvopt2storage[${__longopt}]:-}"

  if [[ "${1}" == *=* ]]; then
    if [[ -z "${__storage}" ]]; then
      clishe_error "--${__longopt} is not key-value option."
    fi
    __value="${1#*=}"
    if [[ -z "${__value}" ]]; then
      clishe_error "--${__longopt}: Missing value."
    fi
    clishe_setvar "${__storage}" "${__value}"
  elif [[ "${__storage}" ]]; then
    if [[ -z "${2}" ]]; then
      clishe_error "--${__longopt}: Missing value."
    fi
    clishe_setvar "${__storage}" "${2}"
    __clishe_nshift=2
  else
    __storage="${__clishe_map_flagopt2storage[${__longopt}]:-}"
    if [[ -z "${__storage}" ]]; then
      __action="${__clishe_map_help2action[${__longopt}]:-}"
      if [[ -z "${__action}" ]]; then
        clishe_error "Invalid option: --${__longopt}"
      fi
      ${__action}
    else
      clishe_setvar "${__storage}" "$(( ${!__storage:-0} + 1 ))"
    fi
  fi
}

: <<'=cut'
=pod

=head1 EXAMPLES

The following Bash script print information about its argumetns:

  #!/bin/bash

  set -euo pipefail

  SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
  CLISHEPATH="${SCRIPTDIR}:/usr/local/share/clishe:/usr/share/clishe"

  PATH="${CLISHEPATH}${PATH:+:}${PATH}" \
  . clishe.sh >/dev/null 2>&1 || {
    echo "clishe library is not installed"
    exit 1
  }

  clishe_init

  clishe_defopt --token=TOKEN -t -- "security token" required
  clishe_defopt --user=USER -u -- "" optional "Jane Doe <jd@compant.com>" <<EOF
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

=head1 AUTHORS

=over

=item *

Jiří Kučera, I<sanczes@gmail.com>

=back

=head1 VERSION

=over

=item *

@VERSION@

=back

=head1 LICENSE

=over

=item *

MIT

=back

=head1 BUG REPORTS

If you found a bug, please
L<open an issue|https://github.com/i386x/clishe/issues>.

=begin html

<div class="footer">
  &copy; 2020 Jiří Kučera | v@VERSION@
</div>

=end html

=cut
