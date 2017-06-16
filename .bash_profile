if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
set -o vi
alias vim='mvim -v'
alias ssunfire='ssh deshunc@sunfire.comp.nus.edu.sg'
export PATH=$PATH:~/.nexustools
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
