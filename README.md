# Dotfiles repository

A neat way of managing dotfiles that is usable cross-platform is described at [1].

Essentially the idea is to have the home directory a git workspace but to keep the repository data 
not in .git but in a separate folder and define an alias to access the combination of workspace and 
repository.

Summarizing, to bootstrap:

    git clone --bare ssh://git@github.com/stkr/dotfiles.git $HOME/.dotfiles
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
    git df config --local status.showUntrackedFiles no
    git df config --local user.name "stkr"
    git df config --local user.email "stkr@users.noreply.github.com"

In case files are existing, move them out of the way and redo the checkout.

Note, in case the port 22 is blocked, github is also available on https port on a different subdomain:

    ssh://git@ssh.github.com:443/stkr/dotfiles.git

## Exemplary ~/.dotfiles/config:

    [user]
        name = stkr
        email = stkr@users.noreply.github.com 
    [core]
        repositoryformatversion = 0
        filemode = false
        bare = true
        ignorecase = true
    [remote "origin"]
        url = ssh://git@github.com/stkr/dotfiles.git
        fetch = +refs/heads/*:refs/remotes/origin/* 
    [status]
        showUntrackedFiles = no
    [branch "master"]
        remote = origin
        merge = refs/heads/master 


# msys2 specific installation notes


## Starting an msys2 bash under ConEmu

To get the shell started in a particular working directory, use the following commandline from
extern:

    c:\Program Files\ConEmu\ConEmu64.exe -Single -run {Bash::Msys2-64} -new_console:d:"DIRECTORY"

E.g., to start one in the current working directory in Total Commander, create the following Start
Menu entry:

    Command:    c:\Program Files\ConEmu\ConEmu64.exe
    Parameter:  -Single -run {Bash::Msys2-64} -new_console:d:"%P"


## Starting git bash in a directory

To start git-bash in a directory from Total Commander, the following Start Menu would work:

    Command:    cmd /c (start /b "%P" "C:\Program Files\Git\git-bash.exe") && exit
    Parameter: 


## Color mapping between ConEmu and ANSI

The mapping between ConEmu and the ANSI escape codes for colors is not 100% straightforward. The
following table contains the mapping:

| ConEmu | Name           | ANSI FG | ANSI BG  |
| ------ | -------------- | ------- | -------- |
| 0.     | Black          | 30      |  40      |
| 4/1.   | Red            | 31      |  41      |
| 2.     | Green          | 32      |  42      |
| 6/3.   | Yellow         | 33      |  43      |
| 1/4.   | Blue           | 34      |  44      |
| 5.     | Magenta        | 35      |  45      |
| 3/6.   | Cyan           | 36      |  46      |
| 7.     | White          | 37      |  47      |
| 8.     | Bright Black   | 90      | 100      |
| 12.    | Bright Red     | 91      | 101      |
| 10.    | Bright Green   | 92      | 102      |
| 14.    | Bright Yellow  | 93      | 103      |
| 9.     | Bright Blue    | 94      | 104      |
| 13.    | Bright Magenta | 95      | 105      |
| 11.    | Bright Cyan    | 96      | 106      |
| 15.    | Bright White   | 97      | 107      |




## Git credential manager for windows

To enable git credential management, microsoft provides the Git Credential Manager for Windows at
[2]:

    To use the GCM along with git installed with pacman in an MSYS2 environment, simply download a
    release zip and extract the contents directly into C:\msys64\usr\lib\git-core (assuming your
    MSYS2 environment is installed in C:\msys64). Then run:

    git config --global credential.helper manager 


## fzf 

Fzf under windows does not work in case the TERM environment is set ([3]). Also, fzf seems to have
issues with mintty. However, it is possible to run fzf in msys-bash with conemu. Still, it is
necessary, that the TERM environment is unset. In order to achieve that, but without compromising
other programs, a small wrapper script which does just unset TERM and calls fzf afterwards is
necessary. In addition, the --height argument to fzf is not supported for windows. This requires
some script files that come with fzf to be changed for msys environment. It is not 100% the same
experience as running if from linux, but coming rather close.


## Using vimdiff as diff and mergetool

### From git commandline

Git commandline has support for using vim built-in. However, when used as difftool, it opens the
working copy file in readonly mode which is slightly annoying. Therefore it is advised to manually
configure a difftool.

### From TortoiseGit:

For diffing, use:

    gvim.exe -d %base %mine -O2 -c "wincmd l"

Explanation: open vim with 2 vertical splits, open the files, jump to the right to get to the
working copy.

For merging, use:

    gvim.exe -d %mine %base %theirs %merged -O4 -c "3wincmd l" -c "wincmd J"

Explanation: open vim with 4 vertical splits, open the files, jump 3 times to the right, and
position the current window at the bottom of the screen. 


## Clipboard and the terminal

When working remotely in ssh sessions, it is usually not possible to access the hosts clipboard.
There are several solutions existing to that problem 

  - using xclip and X11 forwarding 
  - using terminal escape codes

### OSC 52 on mintty

Support for OSC 52 is built-in for mintty. However, it needs to be enabled with a setting in the
config file: "AllowSetSelection=yes" (see ~/.config/mintty/config).

### OSC 52 on conemu

There are settings decribed at [5], however i was not able to sucessfully reproduce that.


## nvim and vim using the same plugins

The config file for neovim on windows is at

    nvim: ~/AppData/Local/nvim

On windows, the directories where nvim and vim searches for plugin is:

    ~/AppData/Local/nvim-data/site

It is possible to make nvim pick up the plugins of vim by including vim's plugin path into nvim's
runtimepath and also use the same vimrc file:

    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath=&runtimepath
    source ~/.vim/vimrc


## building nvim from sources and install using stow

As mentioned in [10], the assumption of stow is that a package is compiled for
the target tree. That means no custom installation prefix for compilation of
nvim is required/expected. However, it is a bit "special" to get nvim installed
into the stow tree. The nvim discussion forum has a solution at [11].

    # checkout the tag to build
    git checkout v0.8.0

    export NVIM_VERSION="$( git describe )"
    export STOW_TREE="/usr/local/stow"
    export NVIM_INSTALL_PREFIX="${STOW_TREE}/nvim-${NVIM_VERSION}"
    export MACHINE="$( gcc -dumpmachine )"

    # build with final target
    make CMAKE_BUILD_TYPE=Release 

    # create a stow folder for this version
    sudo mkdir "${NVIM_INSTALL_PREFIX}"

    # "install" neovim into the stow folder
    cd build
    sudo cmake -DCMAKE_INSTALL_PREFIX="${NVIM_INSTALL_PREFIX}" -P cmake_install.cmake

    # create an archive of the build
    cd "${STOW_TREE}"
    tar cvzf "/tmp/nvim-${NVIM_VERSION}-${MACHINE}.tar.gz" "nvim-${NVIM_VERSION}"


## Alacritty and the conpty disaster

On windows, alacritty since some time uses the conpty. However, the version of
conpty + conhost/OpenConsole shipped with windows is quite outdated and broken. 

alacritty to replace those components Per default, they are taken from the
windows installation. However since version 0.13.0 (Dec 2023), alacritty takes
conpty.dll and OpenConsole.exe from the same directory as the alacritty.exe if
they are present [12]. 

Source and compilation -instructions for conpty.dll and
OpenConsole can be found at [8]. After opening the .sln file in -visual studio
it prompts to install one million of things (20 GB!). However, the only thing
really -needed is the Windows SDK.

Alternatively, WezTerm comes with pre-built binaries of conpty.dll and
OpenConsole.exe. They can be obtained from the WezTerm github at [13].


## Hostname specific colorization of the tmux status line

In order to easily identify the machine that a tmux session is running on (when working remotely),
for each machine, a separate ~/.tmux.conf file exists. The per-machine split is done by using
different branches. The table below gives an overview of useful color combinations (in the solarized
color scheme).

background | foreground | used on hosts
---        | ---        | ---
cyan       | colour255  | la5410
blue       | colour255  | graz-pi3, nxdi.us-cdc01.nxp.com
green      | colour255  | ardning-pi3
yellow     | colour255  | atlanta
red        | colour255  | 
magenta    | colour255  | 
black      | white      | others


[1]: https://www.atlassian.com/git/tutorials/dotfiles
[2]: https://github.com/microsoft/Git-Credential-Manager-for-Windows
[3]: https://medium.com/free-code-camp/tmux-in-practice-integration-with-system-clipboard-bcd72c62ff7b
[4]: https://jdhao.github.io/2021/01/05/nvim_copy_from_remote_via_osc52/
[5]: https://conemu.github.io/en/SettingsANSI.html
[6]: https://github.com/fredizzimo/alacritty/commit/5121f4aaa09a921c236701c202a0f4c9a3276978?diff=unified
[7]: https://github.com/alacritty/alacritty/pull/4501
[8]: https://github.com/alacritty/alacritty/issues/3889
[9]: https://github.com/microsoft/terminal
[10]: https://www.gnu.org/software/stow/manual/stow.html#Compile_002dtime-vs-Install_002dtime
[11]: https://neovim.discourse.group/t/building-and-installing-neovim-to-location-different-from-cmake-install-prefix/1859/2
[12]: https://github.com/alacritty/alacritty/pull/4501
[13]: https://github.com/wez/wezterm/tree/main/assets/windows/conhost
