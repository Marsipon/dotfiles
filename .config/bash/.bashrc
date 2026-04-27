# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
# fzf
export FZF_CTRL_T_OPTS="--walker-skip .git,node_modules,target --preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --color header:italic --header 'Press CTRL-Y to copy command into clipboard'"

export NVM_DIR="$HOME/.nvm"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

export JAVA_HOME="/home/fedoraremix/.jdks/corretto-25.0.2"

alias lg='lazygit'
alias ld='lazydocker'
alias ecr-login='saml2aws login --skip-prompt --force --role "arn:aws:iam::484134168910:role/AC-ADFS-Developers" && aws --profile saml --region eu-west-1 ecr get-login-password | docker login --username AWS --password-stdin 484134168910.dkr.ecr.eu-west-1.amazonaws.com'
alias ff='fzf --preview '\''rg --ignore-case --pretty --context 3 {q} {}'\'''
alias l='ls -CF'
alias la='ls -A'
alias lg='lazygit'
alias ll='ls -alF'
alias nuget='saml2aws login --skip-prompt --skip-verify --force --role "arn:aws:iam::311937376626:role/SharedServicesDeveloper" && aws codeartifact login --tool dotnet --repository production --domain wow-group --domain-owner 311937376626 --region eu-west-1 --profile saml'
alias gcat='saml2aws login --skip-prompt --skip-verify --force --role "arn:aws:iam::311937376626:role/SharedServicesDeveloper" && export CODEARTIFACT_AUTH_TOKEN=$(saml2aws exec -- aws codeartifact get-authorization-token --domain wow-group --domain-owner 311937376626 --region eu-west-1 --query authorizationToken --output text)'
alias tf-eval='eval $(saml2aws script)'
alias tf-login='saml2aws login --skip-verify --force && eval $(saml2aws script)'
alias fix-network='sudo ip link set dev eth0 mtu 1350'
