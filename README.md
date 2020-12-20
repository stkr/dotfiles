# Dotfiles repository

A neat way of managing dotfiles that is usable cross-platform is described at [1].

Essentially the idea is to have the home directory a git workspace but to keep the repository data 
not in .git but in a separate folder and define an alias to access the conbination of workspace and 
repository.

Sumarizing, to bootstrap:

	git clone --bare ssh://git@github.com/stkr/dotfiles.git $HOME/.dotfiles
	alias dt="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
	dt checkout
	dt config --local status.showUntrackedFiles no

In case files are existing, move them out of the way and redo the checkout.

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


# msys2 specific intallation notes


## Starting an msys2 bash under ConEmu

To get the shell started in a particular working directory, use the following commandline from
extern:

    c:\Program Files\ConEmu\ConEmu64.exe -Single -run {Bash::Msys2-64} -new_console:d:"DIRECTORY"

E.g., to start one in the current working directory in Total Commander, create the following Start
Menu entry:

    Command:    c:\Program Files\ConEmu\ConEmu64.exe
    Parameter:  -Single -run {Bash::Msys2-64} -new_console:d:"%P"


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

## Copying within tmux

[3]


[1]: https://www.atlassian.com/git/tutorials/dotfiles
[2]: https://github.com/microsoft/Git-Credential-Manager-for-Windows
[3]: https://medium.com/free-code-camp/tmux-in-practice-integration-with-system-clipboard-bcd72c62ff7b

