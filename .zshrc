# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =====================================================
# HISTORIAL
# =====================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_find_no_dups


# Limpiar historial manualmente
clearhist() {
    history -c
    rm -f ~/.zsh_history
    fc -p
    echo "🧹 Historial borrado"
} 


# =====================================================
# COMPLETION
# =====================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# =====================================================
# KEYBINDINGS
# =====================================================
bindkey -e

# mover por palabras con ctrl
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# borrar palabra
bindkey '^H' backward-kill-word

# ==============================
# AUTOSUGGESTIONS
# ==============================

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c6f93"

# ==============================
# SYNTAX HIGHLIGHTING
# ==============================

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

typeset -gA ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='fg=2'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=160'

# =====================================================
#
# POWERLEVEL10K
# =====================================================
source ~/powerlevel10k/powerlevel10k.zsh-theme

# cargar config si existe
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# =====================================================
# VARIABLES
# =====================================================
export EDITOR=nvim
export TERMINAL=kitty
export BROWSER=firefox

# =====================================================
# ALIASES
# =====================================================
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias l='eza -lh --icons --group-directories-first'

alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'
alias grep='grep --color=auto'

# =====================================================
# CALIDAD DE VIDA
# =====================================================

# auto cd sin escribir cd
setopt auto_cd

# corrige comandos mal escritos
setopt correct

# muestra color en ls
export LS_COLORS='di=34:ln=36:so=32:pi=33:ex=35:bd=33:cd=33:su=31:sg=31:tw=30:ow=30'

# =====================================================
# TITULO DINAMICO (kitty)
# =====================================================
precmd() {
  print -Pn "\e]0;%n@%m: %~\a"
}

# =====================================================
# PATH EXTRA (opcional)
# =====================================================
export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"



# =====================================================
# AUTOCOMPLETADO
# =====================================================

autoload -Uz compinit
compinit
 
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
 
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


source ~/.config/polybar/scripts/target_utils.sh
