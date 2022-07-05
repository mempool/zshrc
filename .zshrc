# wiz zshrc

## Configuration {{{
# set umask first
umask 22

# locale/encoding
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
#export LC_ALL=ja_JP.UTF-8
#export LANG=ja_JP.UTF-8

export GOPATH=$HOME/Development/go

export ANDROID_HOME=$HOME/Library/Android.SDK

export GRADLE_HOME=/usr/local/apache-maven/gradle-2.2.1
export PATH=$PATH:$GRADLE_HOME/bin

export MAVEN_HOME=/usr/local/apache-maven/apache-maven-3.2.5
export PATH=$PATH:$MAVEN_HOME/bin

export ECLIPSE_HOME=/usr/local/eclipse
export PATH=$PATH:$ECLIPSE_HOME

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
# }}}

## Functions {{{
# go for 256 color as long as not physical console
[ `tty` != '/dev/ttyv0' ] && export TERM=xterm-256color

get_hash_id() {
	result=$($1|sum|cut -d' ' -f1)
}

get_color_index() {
	# There are 7 colors and black then use them cyclic.
	result=$(($1 % 7 + 1))
}

get_prompt_color_indexes() {
	get_hash_id "whoami"; get_color_index $result
	local user=$result
	get_hash_id "hostname"; get_color_index $result
	local host=$result
	get_color_index $(($SHLVL + 2))
	local shlvl=$result
	result=($user $host $shlvl)
}

init_editor() {
	for i in nvim vim vi; do
		if which "$i" 2>&1 1>/dev/null; then
			export EDITOR="$i"
			alias vi=$i
			break
		fi
	done
}

init_paths() {
	if [ -x /usr/libexec/path_helper ]; then
		# path_helper needs MANPATH env to assign values.
		export MANPATH=$MANPATH
		eval `/usr/libexec/path_helper -s`
	fi

	# standard paths
	for i in '' /usr /usr/local /usr/local/opt /opt/local /usr/local/MacGPG2;do
		local bin_path="$i/bin"
		if [ -d "$bin_path" ]; then
			PATH=$bin_path:$PATH
		fi
		local sbin_path="$i/sbin"
		if [ -d "$sbin_path" ]; then
			PATH=$sbin_path:$PATH
		fi
		local gcloud_platform_path=$HOME/google-cloud-sdk
		if [ -d "$gcloud_platform_path" ];then
			PATH=$gcloud_platform_path/bin/:$PATH
		fi
		local android_sdk_platform_path=$HOME/Library/Android/sdk/platform-tools
		if [ -d "$android_sdk_platform_path" ];then
			PATH=$android_sdk_platform_path:$PATH
		fi
		local android_sdk_tools_path=$HOME/Library/Android/sdk/tools
		if [ -d "$android_sdk_tools_path" ];then
			PATH=$android_sdk_tools_path:$PATH
		fi
		local android_ndk_platform_path=$HOME/Library/Android/ndk
		if [ -d "$android_ndk_platform_path" ];then
			PATH=$android_ndk_platform_path:$PATH
		fi
		local man_path="$i/share/man"
		if [ -d "$man_path" ]; then
			MANPATH=$man_path:$MANPATH
		fi
	done

	# /opt/(symlink)/bin, /usr/local/(symlink)/bin
#	for i in /usr/local/* /opt/*; do
#		if [ -L "$i" ]; then
#			local bin_path="$i/bin"
#			if [ -d "$bin_path" ]; then
#				PATH=$bin_path:$PATH
#			fi
#			local sbin_path="$i/sbin"
#			if [ -d "$sbin_path" ]; then
#				PATH=$sbin_path:$PATH
#			fi
#			local man_path="$i/share/man"
#			if [ -d "$man_path" ]; then
#				MANPATH=$man_path:$MANPATH
#			fi
#		fi
#	done

	# add homedir bin as first priority
	if [ -d "$HOME/bin" ];then
		PATH=$HOME/bin:$PATH
	fi

	clean_paths
}

clean_paths() {
	for i in PATH MANPATH; do
		get_path_cleaned $i
		eval "export $i=$result"
	done
}

get_path_cleaned() {
	result=$(eval "echo -n \$$1" \
		| tr -s ':' '\n' \
		| awk '!($0 in a){a[$0]; print}' \
		| tr -s '\n' ':' \
		| sed -e 's/:$//' \
		| sed -e 's/^://')
}

init_ls_colors() {
#
#	FreeBSD / Darwin colors:
#
#	a	 black
#	b	 red
#	c	 green
#	d	 brown
#	e	 blue
#	f	 magenta
#	g	 cyan
#	h	 light grey
#	A	 bold black, usually shows up as dark grey
#	B	 bold red
#	C	 bold green
#	D	 bold brown, usually shows up as yellow
#	E	 bold blue
#	F	 bold magenta
#	G	 bold cyan
#	H	 bold light grey; looks like bright white
#	x	 default foreground or background
#
#	Linux colors:
#
#	Effects
#		00	Defaultcolour
#		01	Bold
#		04	Underlined
#		05	Flashingtext
#		07	Reversetd
#		08	Concealed
#	Colours
#		31	Red
#		32	Green
#		33	Orange
#		34	Blue
#		35	Purple
#		36	Cyan
#		37	Grey
#	Backgrounds
#		40	Blackbackground
#		41	Redbackground
#		42	Greenbackground
#		43	Orangebackground
#		44	Bluebackground
#		45	Purplebackground
#		46	Cyanbackground
#		47	Greybackground
#	Extracolours
#		90	Darkgrey
#		91	Lightred
#		92	Lightgreen
#		93	Yellow
#		94	Lightblue
#		95	Lightpurple
#		96	Turquoise
#		97	White
#	Background
#		100	Darkgrey background
#		101	Lightred background
#		102	Lightgreen background
#		103	Yellowbackground
#		104	Lightblue background
#		105	Lightpurple background
#		106	Turquoisebackground

#	build color schemes for each OS
		COLORS_BSD=''
		COLORS_LINUX=''
#	directory: cyan fg, default bg
		COLORS_BSD+=gx
		COLORS_LINUX+=di=36:
#	symbolic link: magenta fg, default bg
		COLORS_BSD+=fx
		COLORS_LINUX+=ln=35:
#	socket: green fg, default bg
		COLORS_BSD+=cx
		COLORS_LINUX+=so=32:
#	pipe: brown fg, default bg
		COLORS_BSD+=dx
		COLORS_LINUX+=pi=91:
#	executable: red fg, default bg
		COLORS_BSD+=bx
		COLORS_LINUX+=ex=31:
#	block special: blue fg, cyan bg
		COLORS_BSD+=eg
		COLORS_LINUX+="bd=34;46:"
#	character special: blue fg, brown bg
		COLORS_BSD+=ed
		COLORS_LINUX+="cd=34;101:"
#	executable with setuid bit set: black fg, red bg
		COLORS_BSD+=ab
		COLORS_LINUX+="su=30;41:"
#	executable with setgid bit set: black fg, cyan bg
		COLORS_BSD+=ag
		COLORS_LINUX+="sg=30;46:"
#	directory writable to others, with sticky bit: black fg, green bg
		COLORS_BSD+=ac
		COLORS_LINUX+="tw=30;42:"
#	directory writable to others, without sticky bit: black fg, brown bg
		COLORS_BSD+=ad
		COLORS_LINUX+="ow=30;101:"

	local arch=`uname`
	if [ "$arch" = "Darwin" -o "$arch" = "FreeBSD" ]; then
		export LSCOLORS=${COLORS_BSD}
	elif [ "$arch" = "Linux" ]; then
		export LS_COLORS=${COLORS_LINUX}
	fi
}

init_aliases() {

	local arch=`uname`
	if [ "$arch" = "Darwin" -o "$arch" = "FreeBSD" ]; then
		alias ls='ls -hG'
	elif [ "$arch" = "Linux" ]; then
		alias ls='LANG=C LC_COLLATE=C LC_ALL=C ls -h --show-control-chars --color=auto'
	fi

	# ls
	alias ls-al="ls -al"
	alias ll="ls -al"

	# os x mysql port
	if which mysql5 >/dev/null 2>&1 && ! which mysql >/dev/null 2>&1;then
		alias mysql=mysql5
		alias mysqldump=mysqldump5
		alias mysqladmin=mysqladmin5
	fi

	# screen
	alias sr='screen -r'

	# gitk
	alias gitk='gitk --all'

	# subversion related
	alias svndiff="svn diff -x --ignore-all-space -x --ignore-eol-style | vi -v -"
	alias svndiffd="svn diff -x --ignore-all-space -x --ignore-eol-style -r \"{\`date -v-1d +%Y%m%d\`}\" | vi -v -"
	alias svnst="svn st | grep -v '^[X?]'"

	# grep related
	if type 'ack' >/dev/null 2>&1; then
		alias gr="ack"
	else
		if grep --help 2>&1|grep -e '--exclude-dir' 2>&1 >/dev/null; then
			alias gr="grep -r -E -n --color=always --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' --exclude-dir='**/tmp' --exclude-dir='CVS' --exclude-dir='.svn' --exclude-dir='.git' . -e "
		else
			alias gr="grep -r -E -n --color=always --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' . -e "
		fi
	fi

	alias ge="grepedit"

	# for testing an https webserver
	alias stelnet='openssl s_client -CAfile /etc/ssl/certs/ca-certificates.crt -connect'

	# git related
	alias d="git diff"
	alias dc="git diff --cached"
	alias s="git status"
	alias a="git add"
	alias grf="git remote -v|cut -f1|sort|uniq|xargs -n 1 git fetch"
	alias gb="git symbolic-ref HEAD|cut -d'/' -f3"
	alias gpoh="git push origin HEAD"
	alias gpodh="git push origin :\$(git symbolic-ref HEAD|cut -d"/" -f3)"

	alias now="date +%Y%m%d%H%M%S"
	alias wget="wget --ca-certificate=/usr/local/share/certs/ca-root-nss.crt"
	alias fn="find . -not -ipath '*/tmp/*' -not -ipath '*/.*/*' -name "
	alias rand="ruby -ropenssl -e 'print OpenSSL::Digest::SHA1.hexdigest(rand().to_s)'"

	# awk
	for i in 1 2 3 4 5 6 7 8 9; do
		alias a$i="awk '{print \$$i}'"
	done

	# Terminal.app related
	if type 'term' > /dev/null 2>&1; then
		alias t="term -t"
	fi
}

init_rvm() {
	if [ -s "$HOME/.rvm/scripts/rvm" ]; then
		source "$HOME/.rvm/scripts/rvm"
		rvm default 1>/dev/null 2>&1
		if [ -f ".rvmrc" ]; then
			source ".rvmrc"
		fi
		return 0
	fi
	return 1
}

init_rubies() {
	if [ -s "$HOME/.rubies/src/rubies.sh" ]; then
		source "$HOME/.rubies/src/rubies.sh"
		enable_rubies_cd_hook
		return 0
	fi
	return 1
}

init_locallib() {
	if [ -s "$HOME/.perl5/lib/perl5/local/lib.pm" ]; then
		eval $(perl -I$HOME/.perl5/lib/perl5 -Mlocal::lib=$HOME/.perl5)
		return 0
	fi
	return 1
}


pdffix()
{
	pdftk "$1" cat 1-endwest output "$2"
}

gdns_prune()
{
	tr '\n' ' ' \
	| sed \
		-e 's/  */ /g' \
		-e 's/{ "kind/\n{ "kind/g' \
		-e 's/ *$//g' \
		-e 's/\]$/,/' \
	| grep -v '"SOA"' \
	| grep -v '"NS"' \
	| grep -v '^\[' \
	| grep .
}

gdns_sort()
{
	sed -e 's/\(.*\)", "name": "\([^"]*\)\."/\2\1", "name": "\2\."/' \
	|sort -n \
	|sed -e 's/.*{ "kind"/{ "kind"/'
}

gdns_get()
{
	gcloud dns records -z "$1" list \
	| gdns_prune \
	| gdns_sort
}

gdns_record()
{
	echo "{ \"kind\": \"dns#resourceRecordSet\", \"name\": \"$1\", \"rrdatas\": [ \"$3\" ], \"ttl\": $4, \"type\": \"$2\" },"
}

iptohex()
{
	while read line
	do
		addr=(`echo $line|sed -e 's/.*"\([0-9]*\)-\([0-9]*\)-\([0-9]*\)-\([0-9]*\).*/\1-\2-\3-\4/'`)
		octets=(`echo $addr|sed -e 's/\-/ /g'`)
		hex=`printf '%02X' ${octets}|awk '{print tolower($0)}'`
		echo $line|sed -e "s/${addr}$1/${hex}$2/"
	done
}

# }}}

## Pre Configurations {{{

# Avoid 'no matches found' error.
unsetopt nullglob

# Add PATH and MAN_PATH.
init_paths

# Initialize EDITOR.
init_editor

## }}}

## Aliases {{{

init_aliases
init_ls_colors

# Aliases using pipes, works only on Zsh.
alias -g V="| vi -v -"
alias -g G="| grep"
alias -g T="| tail"
alias -g H="| head"
alias -g L="| less -r"

## }}}

## Zsh Basic Configurations {{{

# Initialize hook functions array.
typeset -ga preexec_functions
typeset -ga precmd_functions

# Use vi key bindings.
#bindkey -v

# Use emacs key bindings.
bindkey -e

# Use colors.
autoload -Uz colors
colors

# Expand parameters in the prompt.
setopt prompt_subst

# Load wunjo prompt
autoload -U promptinit
promptinit
prompt wunjo

# Change directory if the command doesn't exist.
setopt auto_cd

# Resume the command if the command is suspended.
setopt auto_resume

# No beep.
setopt no_beep

# Enable expansion from {a-c} to a b c.
setopt brace_ccl

# Disable spell check.
unsetopt correct

# Expand =command to the path of the command.
setopt equals

# Use #, ~ and ^ as regular expression.
setopt extended_glob

# No follow control by C-s and C-q.
setopt no_flow_control

# Don't send SIGHUP to background jobs when shell exits.
unsetopt no_hup

# Disable C-d to exit shell.
unsetopt ignore_eof

# Show long list for jobs command.
setopt long_list_jobs

# Enable completion after = like --prefix=/usr...
setopt magic_equal_subst

# Append / if complete directory.
setopt mark_dirs

# Don't show the list for completions.
unsetopt no_auto_menu

# Don't show completions when using *.
setopt glob_complete

# Perform implicit tees or cats when multiple redirections are attempted.
setopt multios

# Use numeric sort instead of alphabetic sort.
setopt numeric_glob_sort

# Enable file names using 8 bits, important to rendering Japanese file names.
setopt print_eightbit

# Show exit code if exits non 0.
unsetopt print_exit_value

# Don't push multiple copies of the same directory onto the directory stack.
setopt pushd_ignore_dups

# Use single-line command line editing instead of multi-line.
unsetopt single_line_zle

# Allow comments typed on command line.
setopt interactive_comments

# Print commands and their arguments as they are executed.
unsetopt xtrace

# Show CR if the prompt doesn't end with CR.
unsetopt promptcr

# Remove any right prompt from display when accepting a command line.
setopt transient_rprompt

# Pushd by cd -[tab]
setopt auto_pushd

# Don't report the status of background and suspended jobs.
setopt no_check_jobs

# for ** and other advanced expansions
setopt extended_glob

# Enable predict completion
#autoload -Uz predict-on
#predict-on

# Remove directory word by C-w.
autoload -Uz select-word-style
select-word-style bash

# }}}

## Zsh VCS Info and RPROMPT {{{

if autoload +X vcs_info 2> /dev/null; then
	autoload -Uz vcs_info
	zstyle ':vcs_info:*' enable git cvs svn # hg - slow, it scans all parent directories.
	zstyle ':vcs_info:*' formats '%s %b'
	zstyle ':vcs_info:*' actionformats '%s %b (%a)'
	precmd_vcs_info() {
		psvar[1]=""
		LANG=en_US.UTF-8 vcs_info
		[[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
	}
	precmd_functions+=precmd_vcs_info
	RPROMPT="${RPROMPT}%1(V. %F{green}%1v%f.)"
fi

# }}}

## Zsh Completion System {{{

# Use zsh completion system.
autoload -Uz compinit
compinit

# Colors completions.
zstyle ':completion:*' list-colors ''

# Colors processes for kill completion.
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# Ignore case.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Formatting and messages.
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*' group-name ''

# Make the completion menu selectable.
zstyle ':completion:*:default' menu select=1

# Fuzzy match.
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'

# Hostname completion
local knownhosts
if [ -f $HOME/.ssh/known_hosts ]; then
	knownhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} ) 
	zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts
fi

## }}}

## Zsh History {{{

# Don't save history in file
unset HISTFILE

# Max history in memory.
HISTSIZE=100000

# Max history on disk.
SAVEHIST=0

# Remove command lines from the history list when the first character on the line is a space.
setopt hist_ignore_space

# Remove the history (fc -l) command from the history list when invoked.
setopt hist_no_store

# Read new commands from the history and your typed commands to be appended to the history file.
unsetopt share_history

# Append the history list to the history file for mutiple Zsh sessions.
unsetopt append_history

# Save each command's beginning timestamp.
unsetopt extended_history

# Don't add duplicates.
setopt hist_ignore_dups

# Don't require confirmation of !$ etc.
unsetopt hist_verify

# Seach history.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

## }}}

## Zsh Keybinds {{{
## based on http://github.com/kana/config/

# To delete characters beyond the starting point of the current insertion.
bindkey -M viins '\C-h' backward-delete-char
bindkey -M viins '\C-w' backward-kill-word
bindkey -M viins '\C-u' backward-kill-line

# Undo/redo more than once.
bindkey -M vicmd 'u' undo
bindkey -M vicmd '\C-r' redo

# History
# See also 'autoload history-search-end'.
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M viins '^p' history-beginning-search-backward-end
bindkey -M viins '^n' history-beginning-search-forward-end

bindkey -M emacs '^p' history-beginning-search-backward-end
bindkey -M emacs '^n' history-beginning-search-forward-end

# Transpose
bindkey -M vicmd '\C-t' transpose-words
bindkey -M viins '\C-t' transpose-words

# }}}

## Zsh Terminal Title Changes {{{

case "${TERM}" in
screen*|ansi*)
	preexec_term_title() {
		print -n "\ek$1\e\\"
	}
	preexec_functions+=preexec_term_title
	precmd_term_title() {
		print -n "\ek$(whoami)@$(hostname -s):$(basename "${PWD}")\e\\"
	}
	precmd_functions+=precmd_term_title
	;;
xterm*)
	preexec_term_title() {
		print -n "\e]0;$1\a"
	}
	preexec_functions+=preexec_term_title
	precmd_term_title() {
		print -n "\e]0;$(basename "${PWD}")\a"
	}
	precmd_functions+=precmd_term_title
	;;
esac

# }}}

## Scan Additonal Configurations {{{

setopt no_nomatch
#init_additionl_configration "*.zsh"

# }}}

## Post Configurations {{{

if init_rubies; then
	RPROMPT="${RPROMPT} %{$fg[red]%}\${RUBIES_RUBY_NAME}%{$reset_color%}"
fi

# Load Perl local::lib.
init_locallib

# Cleanup PATH, MANPATH.
clean_paths

# }}}

# vim:ts=4:sw=4:noexpandtab:foldmethod=marker:nowrap:ft=sh:
