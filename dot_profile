# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set manpath so it includes users' private man if it exists
if [ -d "${home}/man" ]; then
  manpath="${home}/man:${manpath}"
fi

# set infopath so it includes users' private info if it exists
if [ -d "${home}/info" ]; then
  infopath="${home}/info:${infopath}"
fi 

# set PATH so it includes user's local bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set manpath so it includes users' private man if it exists
if [ -d "${home}/.local/man" ]; then
  manpath="${home}/.local/man:${manpath}"
fi

# set infopath so it includes users' private info if it exists
if [ -d "${home}/.local/info" ]; then
  infopath="${home}/.local/info:${infopath}"
fi 

#  make vim the default editor if it exists
if command -v vim >/dev/null 2>&1; then
    export VISUAL=vim
    export EDITOR=$VISUAL
fi

# start into x upon login on vt1
if command -v startx >/dev/null 2>&1; then
    if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
        exec startx
    fi
fi
