#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# ===== Locale Configuration =====
# Set language environment variables
if locale -a | grep -q 'en_IE.utf8'; then
    export LANG="en_IE.UTF-8"
    export LANGUAGE="en_IE:en"
    export LC_ALL="en_IE.UTF-8"
    export LC_CTYPE="en_IE.UTF-8"
    export LC_MESSAGES="en_IE.UTF-8"
    export LC_COLLATE="en_IE.UTF-8"
    export LC_TIME="en_IE.UTF-8"
    export LC_NUMERIC="en_IE.UTF-8"
    export LC_MONETARY="en_IE.UTF-8"
    export LC_PAPER="en_IE.UTF-8"
    export LC_NAME="en_IE.UTF-8"
    export LC_ADDRESS="en_IE.UTF-8"
    export LC_TELEPHONE="en_IE.UTF-8"
    export LC_MEASUREMENT="en_IE.UTF-8"
    export LC_IDENTIFICATION="en_IE.UTF-8"
fi

# ===== History Configuration =====
HISTCONTROL=ignoreboth                 # ignore duplicates and commands starting with space
HISTSIZE=10000                         # increased history size
HISTFILESIZE=20000
HISTIGNORE="ls:cd:pwd:exit:date:* --help:clear"  # don't record common commands
HISTTIMEFORMAT="%F %T "               # add timestamps to history
shopt -s histappend                    # append don't overwrite history
shopt -s cmdhist                       # save multi-line commands in single entry

# ===== Shell Options =====
shopt -s checkwinsize                  # check window size after each command
shopt -s autocd                        # change directory without cd
shopt -s cdspell                       # autocorrect cd misspellings
shopt -s dirspell                      # autocorrect directory spelling
shopt -s globstar                      # enable ** pattern
shopt -s dotglob                       # include dotfiles in pathname expansion
shopt -s nocaseglob                    # case-insensitive pathname expansion

# ===== Environment Variables =====
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# ===== Path Configuration =====
# Add paths in a more organized way
paths=(
    "$HOME/.config/emacs/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "/usr/local/texlive/2024/bin/x86_64-linux"
    "$HOME/opt"
    "/home/linuxbrew/.linuxbrew/bin"
)

for p in "${paths[@]}"; do
    if [ -d "$p" ]; then
        PATH="$p:$PATH"
    fi
done
export PATH

# ===== Terminal Colors =====
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ===== Aliases =====
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

# Modern alternatives
alias ls='exa -al --color=always --group-directories-first'
alias ll='exa -l --icons --git'
alias la='exa -a --icons'
alias lt='exa -aT --icons --git-ignore'        # tree listing
alias l.='exa -a | grep -E "^\."'              # show only dot files

# System
alias df='df -h'                                # human-readable sizes
alias free='free -m'                            # show sizes in MB
alias sshserver='ssh -i /home/lkslba/.ssh/id_ed25519_server contact@45.77.53.233'
alias config='/usr/bin/git --git-dir=/home/lkslba/.config/ --work-tree=/home/lkslba'

# Package management
alias apt='nala'                                # use nala instead of apt
alias apt-get='nala'                           # use nala instead of apt-get
alias update='sudo nala update'                # quick update
alias upgrade='sudo nala upgrade'              # quick upgrade
alias install='sudo nala install'              # quick install
alias remove='sudo nala remove'                # quick remove
alias search='nala search'                     # quick search

# Editor
alias v='nvim'

alias src='source ~/.bashrc'
alias brc='nvim .bashrc'

# Safety features
alias cp='cp -i'                                # confirm before overwriting
alias mv='mv -i'                                # confirm before overwriting
alias rm='rm -i'                                # confirm before removing
alias ln='ln -i'                                # confirm before linking

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# ===== Functions =====
# Create a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various compressed file formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ===== Program-Specific Configurations =====
# Texlive
export MANPATH="$MANPATH:/usr/local/texlive/2024/texmf-dist/doc/man"
export INFOPATH="$INFOPATH:/usr/local/texlive/2024/texmf-dist/doc/info"

# Starship prompt
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init bash)"

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Zoxide (better cd)
eval "$(zoxide init bash)"
alias cd='z'

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Load additional configurations
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Run neofetch at startup
neofetch
