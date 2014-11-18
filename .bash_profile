function directory_to_titlebar {
  printf "\033]0;%s\007" `fancy_directory`
}

function fancy_directory {
    local pwd_length=42  # The maximum length we want (seems to fit nicely
                         # in a default length Terminal title bar).

    # Get the current working directory.  We'll format it in $dir.
    local dir="$PWD"     

    # Substitute a leading path that's in $HOME for "~"
    if [[ "$HOME" == ${dir:0:${#HOME}} ]] ; then
        dir="~${dir:${#HOME}}"
    fi

    # Append a trailing slash if it's not there already.
    if [[ ${dir:${#dir}-1} != "/" ]] ; then 
        dir="$dir"
    fi

    # Truncate if we're too long.
    # We preserve the leading '/' or '~/', and substitute
    # ellipses for some directories in the middle.
    if [[ "$dir" =~ (~){0,1}/.*(.{${pwd_length}}) ]] ; then  
        local tilde=${BASH_REMATCH[1]}
        local directory=${BASH_REMATCH[2]}

        # At this point, $directory is the truncated end-section of the 
        # path.  We will now make it only contain full directory names
        # (e.g. "ibrary/Mail" -> "/Mail").
        if [[ "$directory" =~ [^/]*(.*) ]] ; then
            directory=${BASH_REMATCH[1]} 
        fi

        # Ellipsis
        dir="$tilde/...$directory"
    fi

    # Don't embed $dir directly in printf's first argument, because it's 
    # possible it could contain printf escape sequences.
    # printf "\033]0;%s\007" "$dir"
    # printf "➙ \033]0;%s\007" "$dir"
    echo "$dir"
}

if [[ "$TERM" == "xterm" || "$TERM" == "xterm-color" || "$TERM" == "xterm-256color" ]] ; then
export PROMPT_COMMAND="directory_to_titlebar"
fi

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo " ⨳"
}
function parse_git_needs_push {
  [[ $(git status 2> /dev/null | grep 'Your branch is ahead') ]] && echo " ↗↗"
}

function number_of_background_jobs {
  NUMBER_OF_JOBS=$(jobs | wc -l | tr -d ' ')
  [[ $NUMBER_OF_JOBS != "0" ]] && echo " $NUMBER_OF_JOBS ↺ "
}

export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:~/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/share/npm/bin:$PATH"
export PATH=$PATH:/usr/local/Cellar/go/1.2/libexec/bin
export PATH=~/.cabal/bin:/Users/myobie/Library/Haskell/bin/:$PATH
export GOPATH=~/.gocode
PS1='➙ `fancy_directory` $(__git_ps1 "⎇ %s$(parse_git_dirty)$(parse_git_needs_push) ")`number_of_background_jobs`\[\033[00;33m\]$\[\033[00m\] '; export PS1

# basic ls
if [ `uname` = 'Darwin' ]; then
  alias ls='ls -FG'
  alias mv='mv -nv'
else
  alias ls='ls -p --color'
  alias mv='mv -v'
fi
alias ll='ls -lah'

alias gemserv="gem server -d /Library/Ruby/Gems/1.8"
alias flushdns="dscacheutil -flushcache"

# colors
export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

# bundle exec stuff

function r {
  if [ -a .bundle ]
  then
  bundle exec ruby $@
  else
  ruby $@
  fi
}

function e {
  if [ -a .bundle ]
  then
  bundle exec $@
  else
  $@
  fi
}

# via mojombo http://gist.github.com/180587
function psg {
  ps wwwaux | egrep "($1|%CPU)" | grep -v grep
}

# sweetness from tim pease:

p() {
  if [ -n "$1" ]; then
    ps -O ppid -U $USER | grep -i "$1" | grep -v grep
  else
    ps -O ppid -U $USER
  fi
}

pkill() {
  if [ -z "$1" ]; then
    echo "Usage: pkill [process name]"
    return 1
  fi

  local pid
  pid=$(p $1 | awk '{ print $1 }')

  if [ -n "$pid" ]; then
    echo -n "Killing \"$1\" (process $pid)..."
    kill -9 $pid
    echo "done."
  else
    echo "Process \"$1\" not found."
  fi
}

# finder

alias twd=new_terminal_working_directory
function new_terminal_working_directory() {
osascript <<END 
tell application "Terminal"
  tell application "System Events" to tell process "Terminal" to keystroke "t" using command down
  do script "cd \"$(pwd)\"" in first window
end tell
END
}

alias cf=copy_finder_window_path
function copy_finder_window_path() {
osascript <<END
tell application "Finder"
	set the_folder to (the target of the front window) as alias
	set the_path to (get POSIX path of the_folder)
	set the clipboard to the_path as text
end tell
END
}

alias gf="cf && cd \`pbpaste\` && clear && pwd"

export EDITOR="vim"

# This resolves issues install the mysql, postgres, and other gems with native non universal binary extensions
export ARCHFLAGS='-arch x86_64'

# History: don't store duplicates
export HISTCONTROL=erasedups
# History: 10,000 entries
export HISTSIZE=10000

# bash-completion

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

# xcode stuff
alias iphone='open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'

# git-completion

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash  ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash 
fi

# git shortcuts

function search-history {
  git log --pretty=format:'%h was %an, %ar, message: %s' | grep $@ | less
}

# test?
export FAKE_POSTS=true

# node
export NODE_PATH="/usr/local/lib/node_modules"

# extras that shouldn't be in the repo?
if [ -f ~/.bash_extras  ]; then
  . ~/.bash_extras
fi

# export CC=/usr/local/bin/gcc-4.2

# disable control s
stty stop ''

# rbenv
export PATH="/usr/local/bin:/usr/local/sbin:$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
source ~/.rbenv/completions/rbenv.bash
rbenv rehash

alias git=hub

alias code="cd ~/Dropbox/Code"
alias W="cd ~/W/"

export JEKYLL_ENV=development
export ANDROID_HOME=/usr/local/opt/android-sdk
