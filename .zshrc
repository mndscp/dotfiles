# Needed for yadm file encryption
export GPG_TTY=$(tty)

# Source file if it exists
function source_file() {
  [ -f "$1" ] && source "$1"
}

# Clone plugin if needed and source it
function source_zsh_plugin() {
  ZDIR=$HOME/.zsh
  PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)

  if ! [ -d "$ZDIR/$PLUGIN_NAME" ]; then
    git clone "https://github.com/$1.git" "$ZDIR/$PLUGIN_NAME"
  fi

  source_file "$ZDIR/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
  source_file "$ZDIR/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
}

# Import aliases and load them them as session abbreviations
source_file ~/.aliases && source_zsh_plugin "olets/zsh-abbr" && abbr -S -q import-aliases

# Plugins (order is important)
source_zsh_plugin Aloxaf/fzf-tab
source_zsh_plugin zsh-users/zsh-autosuggestions
source_zsh_plugin zsh-users/zsh-syntax-highlighting
source_zsh_plugin zsh-users/zsh-history-substring-search

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source_file ~/.p10k.zsh
source_file /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# # Pre-p10k prompt
# autoload -Uz vcs_info
# precmd_vcs_info() { vcs_info }
# precmd_functions+=( precmd_vcs_info )
# setopt prompt_subst
# zstyle ':vcs_info:git:*' formats ' %b'
# zstyle ':vcs_info:*' enable git
# export PROMPT='%F{blue}%~%f%F{green}$vcs_info_msg_0_%f › '

# General settings
export EDITOR="nvim"
export EXA_ICON_SPACING="2"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export OPENER="code"
export PAGER="bat"

# fzf
export FZF_DEFAULT_COMMAND="fd --type f --hidden --search-path $HOME"
export FZF_DEFAULT_OPTS="-e"
export FZF_CTRL_T_COMMAND="fd --hidden --search-path $HOME"
export FZF_CTRL_T_OPTS="-e --preview 'pistol {}'"
export FZF_ALT_C_COMMAND="fd --type d . --hidden --search-path $HOME"
source_file "/usr/share/fzf/completion.zsh"
source_file "/usr/share/fzf/key-bindings.zsh"

# History
HISTFILE=~/.cache/zsh/history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# Show time for all commands that took longer than 10 seconds to complete
REPORTTIME=5

# Make last directory available through popd, useful after changing directory with lfcd
setopt AUTO_PUSHD

# Auto complete
autoload -Uz compinit

# Auto complete arrow navigation
zstyle ':completion:*' menu select

# Auto complete with case insensitivity
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

zstyle :compinstall filename '~/.zshrc'
zmodload zsh/complist
compinit

# zoxide (init after compinit)
eval "$(zoxide init zsh --cmd j)"

# Arrow keys in tab complete menu
bindkey -M menuselect 'j' backward-char
bindkey -M menuselect 'i' up-line-or-history
bindkey -M menuselect 'l' forward-char
bindkey -M menuselect 'k' down-line-or-history

# Up and down arrow keys in history search
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "^[[A" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey "^[[B" history-substring-search-down

# Archive extraction
# usage: ex <file>
ex ()
{
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  fi
}

# Stay in last lf directory on exit
lfcd () {
  tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
  fi
}

bindkey -s '^o' 'lfcd\n'

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
