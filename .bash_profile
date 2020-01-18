# rbenv 
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# nexustools
export PATH=$PATH:~/.nexustools

# nvm
export NVM_DIR="$HOME/.nvm"
  . "/usr/local/opt/nvm/nvm.sh"

# vim key bindings
set -o vi

# aliases
alias vim='mvim -v'
alias sdroplet='ssh root@159.65.149.238'
## git
alias gs='git status'
alias gd='git diff'
alias gcam='git add . && git commit -m '
alias gco='git checkout'
alias gb='git branch'
alias gcb='git checkout -b '

# react native stuff for android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
