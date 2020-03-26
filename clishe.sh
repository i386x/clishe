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

C<clishe_tailopts> - a list of options that was on a tail of command line. See
L<clishe_defopt|/clishe_defopt> and
L<clishe_process_options|/clishe_process_options> for better explanation.

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
  declare -Ag __clishe_map_storage2optname
  declare -ag __clishe_list_required
  declare -ag __clishe_list_headopts
  declare -g __clishe_allow_tailopts=""
  declare -g clishe_helplines=""
  declare -g clishe_nopts=0
  declare -g __clishe_shortopts=""
  declare -g __clishe_nshift=1
  declare -ag clishe_tailopts
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
  local _echo_flags=""
  local _echo_color="${CLISHE_COLOR:-}"
  local _echo_reset=""

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --red)
        _echo_color='31'
        shift
        ;;
      --green)
        _echo_color='32'
        shift
        ;;
      --blue)
        _echo_color='34'
        shift
        ;;
      --yellow)
        _echo_color='33;1'
        shift
        ;;
      --color)
        _echo_color="${2:-}"
        shift 2
        ;;
      -*)
        _echo_flags="${_echo_flags}${1:1}"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ "${CLISHE_NOCOLOR:-}" ]]; then
    _echo_color=""
  fi

  if [[ "${_echo_flags}" ]]; then
    _echo_flags="-${_echo_flags}"
  fi
  if [[ "${_echo_color}" ]]; then
    _echo_flags="${_echo_flags} -e"
    _echo_color="\e[${_echo_color}m"
    _echo_reset="\e[0m"
  fi

  if [[ -z "${CLISHE_QUITE:-}" ]]; then
    # shellcheck disable=SC2086
    echo ${_echo_flags} "${_echo_color}$*${_echo_reset}"
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
  local _exitcode=1

  if [[ "${1:-}" =~ ^[1-9][0-9]*$ ]]; then
    _exitcode=${1}
    shift
  fi
  clishe_echo --red "${clishe_scriptname}: $*" >&2
  # shellcheck disable=SC2086
  exit ${_exitcode}
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
  clishe_defopt STORAGE HELP
  clishe_defopt @NAME HELP

Above, there are four forms of how to use C<clishe_defopt>. The first form is a
way of how to define key-value option. The second form is a way of how to
define flag option.

The third form provide a way of how to tell I<clishe> that there are positional
options to be processed before key-value and flag options arrive. Thus

  clishe_defopt USER "user name"
  clishe_defopt EMAIL "user email"
  clishe_defopt --help -h -- "print this screen and exit" help usage
  ...

tells to I<clishe> that the first command line option is should be stored to
USER, the second one to EMAIL, and the following are processed as key-value
options and flags (or as tail options, see the next paragraph). Note that the
order of definitions is important. If we alter first and second definition, we
must also alter first and second option on command line. Also note that
positional options are mandatory, so if one of them is missing it is treated as
error (this does not hold for I<help> options; in case that the help option is
encountered, help action is performed even if command line options do not met
the specification, except the situation when help option comes as a value of
key-value option that consumes it).

The last, fourth, form tells to I<clishe> that after the last key-value or flag
option arrive zero to I<n> positional options, called I<tail options>. The
sequence of tail options ends if command line ends or if C<--> was encountered.
Tail options are optional, the start of tail options sequence is determined by
the first option on command line that not start with dash (C<->). Anything
between the first tail option and C<--> or end of command line is treated as a
tail option. The processed tail options are stored to C<clishe_tailopts> array.

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

In case of

  clishe_defopt STORAGE HELP

form, STORAGE is a name of a variable to which a positional argument will be
stored.

=item help

The keyword C<help> indicates that the flag option fires a function that print
a help screen.

=item ACTION

Applicable only with C<help>, the I<ACTION> is the name of function that is
responsible for printing of help screen.

=item @NAME

C<@> serves for distinguishing between third form and fourth form of
C<clishe_defopt>. I<NAME> is a string that is displayed on help screen, thus

  clishe_defopt "@FILE1 FILE2 ..." "input files"

will result in

  FILE1 FILE2 ...
      input files

=back

Following examples demonstrate how to define command line options. Consider an
excerpt from a script C<script.sh>:

  clishe_defopt VMNAME "virtual machine name"
  clishe_defopt --token=TOKEN -t -- "a security token" required
  clishe_defopt --port=PORT -p -- "port number" optional 8888
  clishe_defopt --email=EMAIL -- "email address" optional
  clishe_defopt --verbose -v -- "verbosity level" V
  clishe_defopt --help -h -? -- "" help usage <<__HELP__
  print this screen and exit
  __HELP__
  clishe_defopt @FILES "input files"

  function usage() {
    cat <<EOF
  Usage: ${clishe_scriptname} VMNAME [OPTIONS] [FILES...]
  where options are

  ${clishe_helplines}

  EOF
    exit 0
  }

If we run

  $ ./script.sh myvm -tfa1afe1 -port=7777 -vvv

then the value of C<VMNAME> will be C<myvm>, the value of C<TOKEN> will be
C<fa1afe1>, the value of C<PORT> will be 7777, the value of C<EMAIL> will be
its default value which is the empty string, and the value of C<V> will be 3
because there are 3 occurences of I<v> option on command line.

If we run

  $ ./script.sh myvm --token=fadeb1ade x.o y.o --help z.o

then the value of C<VMNAME> will be C<myvm>, the value of C<TOKEN> will be
C<fadeb1ade>, C<PORT> and C<EMAIL> will keep their default values, and
C<clishe_tailopts> will contain C<x.o>, C<y.o>, C<--help> and C<z.o>. Observe
that C<--help> in this case will not print help screen.

If we run

  $ ./script.sh vm1 vm2 --token=fadeb1ade --help x.o

then we get an error about missing --I<token> option, because the C<vm1> is
passed to C<VMNAME> and, since C<vm1> not starts with dash, the rest of options
are treated as tail options.

If we just run

  $ ./script.sh myvm -v

we get an error about missing --I<token> option, because this option is marked
as required. If we omit C<myvm>, we get an error about missing positional
option I<VMNAME>.

Printing the help screen is done via C<usage> function. Notice that instead of
--I<help>, options -I<h> and -I<?> can be also used to show the help:

  $ ./script.sh -?
  Usage: script.sh VMNAME [OPTIONS] [FILES...]
  where options are

    VMNAME
        virtual machine name

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

    FILES
        input files

=cut

function clishe_defopt() {
  if [[ "${1}" == -* ]]; then
    __clishe_defopt12 "$@"
  else
    __clishe_defopt34 "$@"
  fi
}

##
# __clishe_defopt12 $@
#
#   $@ - see the 1st and the 2nd form of clishe_defopt
#
# Implementation of the 1st and the 2nd form of clishe_defopt.
function __clishe_defopt12() {
  local _optname=""
  local _storage=""
  local _shorts=""
  local _help=""
  local _kvoptreq=""
  local _default=""
  local _help_action=""

  # ---------------------------------------------------------------------------
  # -- Gather phase

  # Gather option name:
  if [[ "${1}" != --* ]]; then
    clishe_error "${FUNCNAME[1]}: Option name must begin with --"
  fi
  _optname="${1#--}"
  if [[ "${1}" == *=* ]]; then
    _optname="${_optname%%=*}"
    _storage="${1#*=}"
    if [[ -z "${_storage}" ]]; then
      clishe_error "${FUNCNAME[1]}: Expected a variable name after ="
    fi
  fi
  if [[ -z "${_optname}" ]]; then
    clishe_error "${FUNCNAME[1]}: Expected option name."
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
        _shorts="${_shorts}${_shorts:+ }${1#-}"
        ;;
      *)
        clishe_error "${FUNCNAME[1]}: Expected short option name or --"
        ;;
    esac
    shift
  done

  # Gather help text:
  if [[ -z "${1:-}" ]]; then
    # "" indicates that help is on standard input:
    _help=$(
      while read -r; do
        echo "${REPLY:+${CLISHE_HELP_INDENT2:-${__clishe_indent2}}}${REPLY}"
      done
    )
  else
    _help="${CLISHE_HELP_INDENT2:-${__clishe_indent2}}${1}"
  fi

  shift

  # Gather the rest:
  if [[ "${_storage}" ]]; then
    # Storage is defined, we are defining key-value option:
    case "${1:-}" in
      required|optional)
        _kvoptreq="${1}"
        ;;
      *)
        clishe_error "${FUNCNAME[1]}: Missing an inforamtion whether" \
          "key-value option is required or optional."
        ;;
    esac
    # Gather default key-value option value (not used if option is required):
    _default="${2:-}"
  else
    # Storage is undefined yet, we are defining flag option:
    case "${1:-}" in
      # (help action | STORAGE )
      help)
        if [[ -z "${2:-}" ]]; then
          clishe_error "${FUNCNAME[1]}: Missing a help action."
        fi
        _help_action="${2}"
        ;;
      ?*)
        _storage="${1}"
        ;;
      *)
        clishe_error \
          "${FUNCNAME[1]}: Expected 'help' keyword or storage variable name."
        ;;
    esac
  fi

  # ---------------------------------------------------------------------------
  # -- Define phase

  # Check whether option was not defined before:
  if [[ "${__clishe_map_flagopt2storage[${_optname}]:-}" ]] \
  || [[ "${__clishe_map_kvopt2storage[${_optname}]:-}" ]] \
  || [[ "${__clishe_map_help2action[${_optname}]:-}" ]]; then
    clishe_error "${FUNCNAME[1]}: --${_optname} is still defined."
  fi

  # Check whether storage variable is not yet used:
  if [[ "${_storage}" ]] \
  && [[ "${__clishe_map_storage2optname[${_storage}]:-}" ]]; then
    clishe_error \
      "${FUNCNAME[1]}: Storage variable ${_storage} was used before."
  fi

  # Check and setup short name aliases:
  for _opt in ${_shorts}; do
    if [[ "${__clishe_map_shortopt2longopt[${_opt}]:-}" ]]; then
      clishe_error "${FUNCNAME[1]}: -${_opt} is still defined."
    fi
    __clishe_map_shortopt2longopt["${_opt}"]="${_optname}"
  done

  # Map option to its storage:
  if [[ "${_kvoptreq}" ]]; then
    # It is a key-value option:
    __clishe_map_kvopt2storage["${_optname}"]="${_storage}"
    # If it is required, note it:
    if [[ "${_kvoptreq}" == required ]]; then
      __clishe_list_required+=( "${_storage}" )
    fi
  elif [[ "${_storage}" ]]; then
    # It is a flag option:
    __clishe_map_flagopt2storage["${_optname}"]="${_storage}"
  else
    # It is a help:
    __clishe_map_help2action["${_optname}"]="${_help_action}"
  fi

  # Map storage to option and set its default:
  if [[ "${_storage}" ]]; then
    __clishe_map_storage2optname["${_storage}"]="${_optname}"
    clishe_setvar "${_storage}" "${_default}"
  fi

  # Assemble help lines:
  clishe_helplines=$(
    if [[ "${clishe_helplines}" ]]; then
      echo "${clishe_helplines}"
      echo ""
    fi
    echo -n "${CLISHE_HELP_INDENT1:-${__clishe_indent1}}--${_optname}"
    if [[ "${_kvoptreq}" ]]; then
      echo -n "=${_storage}"
    fi
    for _opt in ${_shorts}; do
      echo -n ", -${_opt}"
    done
    echo ""
    echo "${_help}"
    if [[ "${_kvoptreq}" == optional ]]; then
      echo -n "${CLISHE_HELP_INDENT2:-${__clishe_indent2}}"
      echo "(default: \"${_default}\")"
    fi
  )
}

##
# __clishe_defopt34 $@
#
#   $@ - see the 3rd and the 4th form of clishe_defopt
#
# Implementation of the 3rd and the 4th form of clishe_defopt.
function __clishe_defopt34() {
  if [[ "${1}" == @* ]]; then
    __clishe_allow_tailopts="y"
  else
    if [[ "${__clishe_map_storage2optname[${1}]:-}" ]]; then
      clishe_error "${FUNCNAME[1]}: Storage variable ${1} was used before."
    fi
    __clishe_map_storage2optname["${1}"]="${1}"
    __clishe_list_headopts+=( "${1}" )
  fi

  clishe_helplines=$(
    if [[ "${clishe_helplines}" ]]; then
      echo "${clishe_helplines}"
      echo ""
    fi
    echo "${CLISHE_HELP_INDENT1:-${__clishe_indent1}}${1#@}"
    if [[ "${2:-}" ]]; then
      echo "${CLISHE_HELP_INDENT2:-${__clishe_indent2}}${2}"
    else
      while read -r; do
        echo "${REPLY:+${CLISHE_HELP_INDENT2:-${__clishe_indent2}}}${REPLY}"
      done
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

The general format of command line is

  <positional opts> <key-value and flag opts> <tail opts> -- <the rest>

I<positional opts> are specified with the third form of
L<clishe_defopt|/clishe_defopt>, I<key-value and flag opts> are specified with
the first and second form of L<clishe_defopt|/clishe_defopt> and I<tail opts>
are specified with the fourth form of L<clishe_defopt|/clishe_defopt> and they
are stored into C<clishe_tailopts> array. C<--> works as the options end
marker, I<the rest> remains unprocessed.

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

  __clishe_handle_headopts "$@"
  clishe_nopts=$(( clishe_nopts + __clishe_nshift ))
  shift ${__clishe_nshift}

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
        if [[ "${__clishe_allow_tailopts}" ]]; then
          __clishe_handle_tailopts "$@"
          clishe_nopts=$(( clishe_nopts + __clishe_nshift ))
          shift ${__clishe_nshift}
          break
        fi
        clishe_error "Invalid option: ${1}"
        ;;
    esac
    clishe_nopts=$(( clishe_nopts + __clishe_nshift ))
    shift ${__clishe_nshift}
  done

  for _varname in "${__clishe_list_headopts[@]}"; do
    if [[ -z "${!_varname:-}" ]]; then
      clishe_error "Positional option ${_varname} is missing or unset."
    fi
  done

  for _varname in "${__clishe_list_required[@]}"; do
    if [[ -z "${!_varname:-}" ]]; then
      clishe_error \
        "Option --${__clishe_map_storage2optname[${_varname}]:-} is required."
    fi
  done
}

##
# __clishe_handle_headopts $@
#
#   $@ - options to be processed
#
# Handle head positional options. In __clishe_nshift, return the number of
# processed options.
function __clishe_handle_headopts() {
  __clishe_nshift=0
  for _varname in "${__clishe_list_headopts[@]}"; do
    if [[ -z "${1:-}" ]] || [[ "${1:-}" == -* ]]; then
      break
    fi
    clishe_setvar "${_varname}" "${1}"
    __clishe_nshift=$(( __clishe_nshift + 1 ))
    shift
  done
}

##
# __clishe_handle_tailopts $@
#
#   $@ - options to be processed
#
# Handle tail positional options. In __clishe_nshift, return the number of
# processed options.
function __clishe_handle_tailopts() {
  __clishe_nshift=0
  while [[ $# -gt 0 ]]; do
    if [[ "${1}" == "--" ]]; then
      __clishe_nshift=$(( __clishe_nshift + 1 ))
      break
    fi
    clishe_tailopts+=( "${1}" )
    __clishe_nshift=$(( __clishe_nshift + 1 ))
    shift
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
  local _opt=""
  local _longopt=""
  local _storage=""
  local _action=""

  _opt="${__clishe_shortopts:0:1}"
  __clishe_shortopts="${__clishe_shortopts:1}"
  _longopt="${__clishe_map_shortopt2longopt[${_opt}]:-}"

  if [[ -z "${_longopt}" ]]; then
    clishe_error "Invalid option: -${_opt}"
  fi

  _storage="${__clishe_map_kvopt2storage[${_longopt}]:-}"
  if [[ "${_storage}" ]]; then
    if [[ "${__clishe_shortopts}" ]]; then
      clishe_setvar "${_storage}" "${__clishe_shortopts}"
      __clishe_shortopts=""
    elif [[ "${1}" ]]; then
      clishe_setvar "${_storage}" "${1}"
      __clishe_nshift=2
    else
      clishe_error "-${_opt}: Missing value."
    fi
  else
    _storage="${__clishe_map_flagopt2storage[${_longopt}]:-}"
    if [[ -z "${_storage}" ]]; then
      _action="${__clishe_map_help2action[${_longopt}]:-}"
      if [[ -z "${_action}" ]]; then
        clishe_error "Invalid option: -${_opt}"
      fi
      ${_action}
    else
      clishe_setvar "${_storage}" "$(( ${!_storage:-0} + 1 ))"
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
  local _longopt=""
  local _storage=""
  local _value=""
  local _action=""

  _longopt="${1#--}"
  _longopt="${_longopt%%=*}"
  _storage="${__clishe_map_kvopt2storage[${_longopt}]:-}"

  if [[ "${1}" == *=* ]]; then
    if [[ -z "${_storage}" ]]; then
      clishe_error "--${_longopt} is not key-value option."
    fi
    _value="${1#*=}"
    if [[ -z "${_value}" ]]; then
      clishe_error "--${_longopt}: Missing value."
    fi
    clishe_setvar "${_storage}" "${_value}"
  elif [[ "${_storage}" ]]; then
    if [[ -z "${2}" ]]; then
      clishe_error "--${_longopt}: Missing value."
    fi
    clishe_setvar "${_storage}" "${2}"
    __clishe_nshift=2
  else
    _storage="${__clishe_map_flagopt2storage[${_longopt}]:-}"
    if [[ -z "${_storage}" ]]; then
      _action="${__clishe_map_help2action[${_longopt}]:-}"
      if [[ -z "${_action}" ]]; then
        clishe_error "Invalid option: --${_longopt}"
      fi
      ${_action}
    else
      clishe_setvar "${_storage}" "$(( ${!_storage:-0} + 1 ))"
    fi
  fi
}

: <<'=cut'
=pod

=head1 EXAMPLES

The following Bash script prints information about its argumetns:

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

  clishe_defopt ARG1 "positional argument #1"
  clishe_defopt ARG2 "positional argument #2"
  clishe_defopt --token=TOKEN -t -- "security token" required
  clishe_defopt --user=USER -u -- "" optional "Jane Doe <jd@compant.com>" <<EOF
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
  clishe_echo --blue "Files: ${clishe_tailopts[@]}"
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
