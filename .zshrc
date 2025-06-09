# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# export ZSH_THEME="amuse"
export ZSH_THEME="af-magic"
# export ZSH_THEME="awesomepanda"
# export ZSH_THEME="eastwood"
# source "/opt/homebrew/opt/spaceship/spaceship.zsh"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
# plugins=(git textmate osx ruby)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
# added my path 2011.7.19
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Applications/Wireshark.app/Contents/MacOS:/Users/namuuntuul.baterdene/.local/bin:/Users/namuuntuul.baterdene/.cargo/bin:/Applications/iTerm.app/Contents/Resources/utilities:/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:/opt/homebrew/Cellar/postgresql@15/15.12_1/bin:/opt/homebrew/opt:/Users/namuuntuul.baterdene/.pyenv/versions/3.8.20/bin

# copied from .bash_aliases 2001.07.19
# -------------------------------------------------------------------
# some alias settings, just for fun
# -------------------------------------------------------------------
#alias 'today=calendar -A 0 -f ~/calendar/calendar.mark | sort'
alias 'today=calendar -A 0 -f /usr/share/calendar/calendar.mark | sort'
alias 'dus=du -sckx * | sort -nr'
alias 'ttop=top -ocpu -R -F -s 2 -n30'

# -------------------------------------------------------------------
# gcloud stuff
# -------------------------------------------------------------------
export CLOUDSDK_PYTHON="/opt/homebrew/bin/python3.11"
alias 'sqldev=cloud_sql_proxy -instances='phrasal-academy-214017:us-west1:wonderful-dev'=tcp:5433'
alias 'sqlprod=cloud_sql_proxy -instances='phrasal-academy-214017:us-west2:wonderful-production'=tcp:5433'

# -------------------------------------------------------------------
# poetry aliases
# -------------------------------------------------------------------
alias 'p=poetry'
alias 'pact=source .venv/bin/activate'

export export PATH="$(brew --prefix python)/libexec/bin:$PATH"

eval "$(direnv hook $SHELL)"
# Added by Windsurf
export PATH="/Users/namuuntuul.baterdene/.codeium/windsurf/bin:$PATH"
