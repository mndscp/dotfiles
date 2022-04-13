export PROMPT='%F{blue}%~%f%F{green}$vcs_info_msg_0_%f › '
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export EDITOR=nvim
export EXA_ICON_SPACING=2

# fzf
export FZF_DEFAULT_COMMAND='fd --type file --hidden --strip-cwd-prefix'
# export FZF_DEFAULT_OPTS="--preview 'bat --color=always --line-range :50 {}'"
export FZF_CTRL_T_OPTS="-e --preview 'bat --color=always --line-range :50 {}'"
export FZF_ALT_C_COMMAND='fd --type d . --hidden --search-path $HOME'
# export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"

# Needed for yadm file encryption
export GPG_TTY=$(tty)

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
# RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats ' %b'
zstyle ':vcs_info:*' enable git

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
REPORTTIME=10

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

# Arrow keys in tab complete menu
bindkey -M menuselect 'j' backward-char
bindkey -M menuselect 'i' up-line-or-history
bindkey -M menuselect 'l' forward-char
bindkey -M menuselect 'k' down-line-or-history

# Source file if it exists
function zsh_source_file() {
  [ -f "$HOME/.zsh/$1" ] && source "$HOME/.zsh/$1"
}

# Clone plugin if needed and source it
function zsh_source_plugin() {
  ZDIR=$HOME/.zsh
  PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)

  if ! [ -d "$ZDIR/$PLUGIN_NAME" ]; then
    git clone "https://github.com/$1.git" "$ZDIR/$PLUGIN_NAME"
  fi

  zsh_source_file "$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
  zsh_source_file "$PLUGIN_NAME/$PLUGIN_NAME.zsh"
}

# Various sources (order is important)
zsh_source_plugin "agkozak/zsh-z"
zsh_source_plugin "zsh-users/zsh-autosuggestions"
zsh_source_plugin "zsh-users/zsh-syntax-highlighting"
zsh_source_plugin "zsh-users/zsh-history-substring-search"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Import aliases and make them into session abbreviations
source ~/.aliases
zsh_source_plugin "olets/zsh-abbr"
[ -d "$HOME/.zsh/zsh-abbr" ] && abbr -S -q import-aliases

# Up and down arrow keys in history search
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "^[[A" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey "^[[B" history-substring-search-down

# Archive extraction
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
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

bindkey -s '^b' 'bat < fzf -e\n'

export LF_ICONS="\
tw=:\
st=:\
ow=:\
dt=:\
di=:\
fi=:\
ln=:\
or=:\
ex=:\
*.c=:\
*.cc=:\
*.clj=:\
*.coffee=:\
*.cpp=:\
*.css=:\
*.d=:\
*.dart=:\
*.erl=:\
*.exs=:\
*.fs=:\
*.go=:\
*.h=:\
*.hh=:\
*.hpp=:\
*.hs=:\
*.html=:\
*.java=:\
*.jl=:\
*.js=:\
*.json=:\
*.lua=:\
*.md=:\
*.php=:\
*.pl=:\
*.pro=:\
*.py=:\
*.rb=:\
*.rs=:\
*.scala=:\
*.ts=:\
*.vim=:\
*.cmd=:\
*.ps1=:\
*.sh=:\
*.bash=:\
*.zsh=:\
*.fish=:\
*.tar=:\
*.tgz=:\
*.arc=:\
*.arj=:\
*.taz=:\
*.lha=:\
*.lz4=:\
*.lzh=:\
*.lzma=:\
*.tlz=:\
*.txz=:\
*.tzo=:\
*.t7z=:\
*.zip=:\
*.z=:\
*.dz=:\
*.gz=:\
*.lrz=:\
*.lz=:\
*.lzo=:\
*.xz=:\
*.zst=:\
*.tzst=:\
*.bz2=:\
*.bz=:\
*.tbz=:\
*.tbz2=:\
*.tz=:\
*.deb=:\
*.rpm=:\
*.jar=:\
*.war=:\
*.ear=:\
*.sar=:\
*.rar=:\
*.alz=:\
*.ace=:\
*.zoo=:\
*.cpio=:\
*.7z=:\
*.rz=:\
*.cab=:\
*.wim=:\
*.swm=:\
*.dwm=:\
*.esd=:\
*.jpg=:\
*.jpeg=:\
*.mjpg=:\
*.mjpeg=:\
*.gif=:\
*.bmp=:\
*.pbm=:\
*.pgm=:\
*.ppm=:\
*.tga=:\
*.xbm=:\
*.xpm=:\
*.tif=:\
*.tiff=:\
*.png=:\
*.svg=:\
*.svgz=:\
*.mng=:\
*.pcx=:\
*.mov=:\
*.mpg=:\
*.mpeg=:\
*.m2v=:\
*.mkv=:\
*.webm=:\
*.ogm=:\
*.mp4=:\
*.m4v=:\
*.mp4v=:\
*.vob=:\
*.qt=:\
*.nuv=:\
*.wmv=:\
*.asf=:\
*.rm=:\
*.rmvb=:\
*.flc=:\
*.avi=:\
*.fli=:\
*.flv=:\
*.gl=:\
*.dl=:\
*.xcf=:\
*.xwd=:\
*.yuv=:\
*.cgm=:\
*.emf=:\
*.ogv=:\
*.ogx=:\
*.aac=:\
*.au=:\
*.flac=:\
*.m4a=:\
*.mid=:\
*.midi=:\
*.mka=:\
*.mp3=:\
*.mpc=:\
*.ogg=:\
*.ra=:\
*.wav=:\
*.oga=:\
*.opus=:\
*.spx=:\
*.xspf=:\
*.pdf=:\
*.nix=:\
"
