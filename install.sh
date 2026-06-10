#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"


clear

echo -e "\e[95m"
cat << "EOF"

           ░██           ░██           ░██
                                       ░██
░████████  ░██░████████  ░██ ░███████  ░██    ░██ ░██████   ░██░████  ░███████
░██    ░██ ░██░██    ░██ ░██░██    ░██ ░██   ░██       ░██  ░███     ░██    ░██
░██    ░██ ░██░██    ░██ ░██░██    ░██ ░███████   ░███████  ░██      ░██    ░██
░██    ░██ ░██░██    ░██ ░██░██    ░██ ░██   ░██ ░██   ░██  ░██      ░██    ░██
░██    ░██ ░██░██    ░██ ░██ ░███████  ░██    ░██ ░█████░██ ░██       ░███████

EOF

echo -e "\e[96m             🌙 uwu 🌙"
echo -e "\e[97m                 by Niniokaro"
echo -e "\e[0m"

sleep 2




echo "🚀 Instalando dotfiles desde: $DOTFILES_DIR"

# =====================================================
# DETECTAR DISTRO
# =====================================================

if command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
elif command -v apt >/dev/null 2>&1; then
    DISTRO="parrot"
else
    echo "❌ Distro no soportada. Solo Arch o Parrot/Debian."
    exit 1
fi

echo "🧠 Sistema detectado: $DISTRO"

# =====================================================
# FUNCIONES
# =====================================================

install_eww_debian() {
    if command -v eww >/dev/null 2>&1; then
        echo "✅ eww ya está instalado."
        return
    fi

    echo "📦 Instalando dependencias para eww..."

    sudo apt install -y \
        git curl build-essential pkg-config \
        libgtk-3-dev libgtk-layer-shell-dev \
        libpango1.0-dev libgdk-pixbuf-2.0-dev \
        libdbusmenu-gtk3-dev libcairo2-dev libglib2.0-dev

    if ! command -v cargo >/dev/null 2>&1; then
        echo "🦀 Instalando Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        source "$HOME/.cargo/env" 2>/dev/null || true
    fi

    if [ ! -d "$HOME/eww" ]; then
        git clone https://github.com/elkowar/eww.git "$HOME/eww"
    fi

    echo "🔨 Compilando eww..."
    cd "$HOME/eww"
    cargo build --release --no-default-features --features x11

    sudo install -m 755 target/release/eww /usr/local/bin/eww

    echo "✅ eww instalado."
}

install_eww_arch() {
    if command -v eww >/dev/null 2>&1; then
        echo "✅ eww ya instalado."
        return
    fi

    if ! command -v yay >/dev/null 2>&1; then
        echo "📦 Instalando yay..."

        sudo pacman -S --needed --noconfirm git base-devel

        rm -rf /tmp/yay
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
    fi

    echo "📦 Instalando eww..."
    yay -S --noconfirm eww
}

install_zsh_plugins() {
    echo "🐚 Instalando plugins ZSH..."

    mkdir -p "$HOME/.zsh"

    if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.zsh/zsh-autosuggestions"
    else
        echo "✅ zsh-autosuggestions ya existe."
    fi

    if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$HOME/.zsh/zsh-syntax-highlighting"
    else
        echo "✅ zsh-syntax-highlighting ya existe."
    fi
}

install_powerlevel10k() {
    echo "⚡ Instalando Powerlevel10k..."

    if [ ! -d "$HOME/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
    else
        echo "✅ Powerlevel10k ya existe."
    fi
}

install_nvchad() {
    echo "🧠 Instalando NvChad..."

    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        echo "📦 Backup de nvim existente..."
        mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
    fi

    if [ -L "$HOME/.config/nvim" ]; then
        echo "⚠️ ~/.config/nvim es un symlink. No se sobreescribe."
        return
    fi

    if [ ! -d "$HOME/.config/nvim" ]; then
        git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
        echo "✅ NvChad instalado."
    else
        echo "✅ NvChad/config nvim ya existe."
    fi
}

fix_bat_debian() {
    echo "🦇 Verificando bat..."

    if command -v bat >/dev/null 2>&1; then
        echo "✅ bat funciona."
        return
    fi

    if command -v batcat >/dev/null 2>&1; then
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        echo "✅ Symlink bat -> batcat creado."
    fi
}

set_default_zsh() {
    echo "🐚 Configurando ZSH como shell por defecto..."

    if ! command -v zsh >/dev/null 2>&1; then
        echo "⚠️ zsh no está instalado."
        return
    fi

    ZSH_PATH="$(command -v zsh)"

    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    sudo chsh -s "$ZSH_PATH" "$USER" 2>/dev/null || chsh -s "$ZSH_PATH" || true

    echo "✅ Shell configurada: $ZSH_PATH"
}

setup_root_zsh() {
    echo "👑 Configurando root..."

    sudo cp "$HOME/.zshrc" /root/.zshrc 2>/dev/null || true
    sudo cp "$HOME/.p10k.zsh" /root/.p10k.zsh 2>/dev/null || true

    if [ ! -d "/root/powerlevel10k" ]; then
        sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
    fi

    if command -v zsh >/dev/null 2>&1; then
        sudo chsh -s "$(command -v zsh)" root 2>/dev/null || true
    fi
}

# =====================================================
# INSTALAR PAQUETES
# =====================================================

echo "📦 Instalando paquetes..."

if [ "$DISTRO" = "arch" ]; then
    sudo pacman -Syu --needed --noconfirm \
        bspwm sxhkd polybar rofi kitty picom dunst feh git zsh \
        playerctl networkmanager xorg-xrandr xorg-xinit \
        curl jq xclip xsel flameshot maim scrot \
        pavucontrol pulseaudio pulseaudio-alsa \
        pacman-contrib \
        unzip wget \
        eza bat neovim firefox \
        zsh-autosuggestions zsh-syntax-highlighting \
        procps-ng coreutils cliphist clipmenu \
        base-devel

    install_eww_arch

elif [ "$DISTRO" = "parrot" ]; then
    sudo apt update

    sudo apt install -y \
        bspwm sxhkd polybar rofi kitty picom dunst feh git zsh \
        playerctl network-manager x11-xserver-utils \
        curl jq xclip xsel flameshot maim scrot \
        pavucontrol pulseaudio-utils \
        fonts-font-awesome unzip wget \
        eza bat neovim \
        zsh-autosuggestions zsh-syntax-highlighting \
        procps coreutils build-essential

    install_eww_debian
    fix_bat_debian
fi

# =====================================================
# BACKUP
# =====================================================

echo "📦 Creando backup en: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

[ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/"
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
[ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$BACKUP_DIR/"

# =====================================================
# LINKEAR CONFIGS
# =====================================================

echo "🔗 Linkeando configs..."
mkdir -p "$HOME/.config"

for dir in "$DOTFILES_DIR/.config/"*; do
    [ -e "$dir" ] || continue

    name="$(basename "$dir")"
    dest="$HOME/.config/$name"

    if [ "$name" = "nvim" ]; then
        echo "ℹ️ Saltando .config/nvim para que NvChad lo maneje."
        continue
    fi

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Moviendo $dest al backup..."
        mv "$dest" "$BACKUP_DIR/$name"
    fi

    ln -sfn "$dir" "$dest"
done

# =====================================================
# ZSH / P10K / NVCHAD
# =====================================================

echo "💻 Copiando configuración de ZSH..."

[ -f "$DOTFILES_DIR/.zshrc" ] && cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.p10k.zsh" ] && cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

install_zsh_plugins
install_powerlevel10k
install_nvchad
set_default_zsh
setup_root_zsh

# =====================================================
# FUENTES
# =====================================================

echo "🔤 Instalando fuentes..."

mkdir -p "$HOME/.local/share/fonts"

if [ -d "$DOTFILES_DIR/fonts" ]; then
    cp -r "$DOTFILES_DIR/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
    fc-cache -fv
fi

# =====================================================
# WALLPAPERS
# =====================================================

echo "🖼 Instalando wallpapers..."

if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    sudo mkdir -p /usr/share/wallpapers
    sudo cp -r "$DOTFILES_DIR/wallpapers/"* /usr/share/wallpapers/ 2>/dev/null || true
fi

# =====================================================
# PERMISOS
# =====================================================

echo "🔧 Dando permisos a scripts..."

chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null || true
chmod -R +x "$HOME/.config/bspwm/scripts" 2>/dev/null || true
chmod -R +x "$HOME/.config/polybar/scripts" 2>/dev/null || true
chmod -R +x "$HOME/.config/eww/scripts" 2>/dev/null || true
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true

# =====================================================
# NETWORKMANAGER
# =====================================================

echo "🌐 Activando NetworkManager..."

sudo systemctl enable NetworkManager 2>/dev/null || true
sudo systemctl start NetworkManager 2>/dev/null || true

# =====================================================
# XINITRC
# =====================================================

echo "🪟 Configurando .xinitrc..."

cat > "$HOME/.xinitrc" <<EOF
exec bspwm
EOF

# =====================================================
# FINAL
# =====================================================

echo ""
echo "✅ Instalación completa."
echo "📦 Backup guardado en: $BACKUP_DIR"
echo ""
echo "⚠️ Cerrá sesión y volvé a entrar para que ZSH quede como shell por defecto."
echo ""
echo "Para iniciar BSPWM:"
echo "startx"
echo ""
